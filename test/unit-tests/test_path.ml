let os_adapt s =
  let regexp = Str.regexp "\\(/\\)" in
  Str.global_replace regexp (String.escaped Filename.dir_sep) s

let test_linux_path () =
  let norm =
    Array.map ~f:Paths.normalize_absolute_path
      [|
        "/gsho/./..";
        "/a/b/../c../d/e/f";
        "/a/b/../c/../d/e/f";
        "/gsho/./../..";
        "/a/b/c/d";
        "/a/b/c/d/";
        "/a/";
        "/a";
        "/a.txt/";
        "/a.txt";
        "/foo/bar/./baz";
      |]
  in
  Alcotest.(check (array string))
    __LOC__ norm
    [|
      "/";
      "/a/c../d/e/f";
      "/a/d/e/f";
      "/";
      "/a/b/c/d";
      "/a/b/c/d";
      "/a";
      "/a";
      "/a.txt";
      "/a.txt";
      "/foo/bar/baz";
    |];
  Alcotest.(check string)
    __LOC__
    (Paths.normalize_absolute_path
       "/./a/.////////j/k//../////..///././b/./c/d/./.")
    (os_adapt "/a/b/c/d");
  Alcotest.(check string)
    __LOC__
    (Paths.normalize_absolute_path
       "/./a/.////////j/k//../////..///././b/./c/d/././../")
    (os_adapt "/a/b/c")

let test_normalized_absolute () =
  let aux a b result =
    Alcotest.(check string)
      __LOC__
      (Paths.rel_normalized_absolute_path ~from:a b)
      result;

    Alcotest.(check string)
      __LOC__
      (Paths.rel_normalized_absolute_path
         ~from:(String.sub a ~pos:0 ~len:(String.length a - 1))
         b)
      result;

    Alcotest.(check string)
      __LOC__
      (Paths.rel_normalized_absolute_path ~from:a
         (String.sub b ~pos:0 ~len:(String.length b - 1)))
      result;
    Alcotest.(check string)
      __LOC__
      (Paths.rel_normalized_absolute_path
         ~from:(String.sub a ~pos:0 ~len:(String.length a - 1))
         (String.sub b ~pos:0 ~len:(String.length b - 1)))
      result
  in
  aux "/a/b/c/" "/a/b/c/d/" (os_adapt "d");
  aux "/a/b/c/" "/a/b/c/d/e/f/" (os_adapt "d/e/f");
  aux "/a/b/c/d/" "/a/b/c/" "..";
  aux "/a/b/c/d/" "/a/b/" (os_adapt "../..");
  aux "/a/b/c/d/" "/a/" (os_adapt "../../..");
  aux "/a/b/c/d/" "//" (os_adapt "../../../..")

let test_normalized_absolute_uncommon () =
  (* This is still correct just not optimal depends
            on user's perspective *)
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"/a/b/c/d" "/x/y")
    (os_adapt "../../../../x/y");

  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path
       ~from:"/a/b/c/d/e/./src/bindings/Navigation" "/a/b/c/d/e")
    (os_adapt "../../..");
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"/a/b/c/./d" "/a/b/c")
    "..";

  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"/a/b/c/./src" "/a/b/d/./src")
    (os_adapt "../../d/src")

let test_normalized_module_system () =
  (* used in module system: [es6-global] and [amdjs-global] *)
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"/usr/local/lib/node_modules/"
       "//")
    (os_adapt "../../../..");
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"/usr/local/lib/node_modules/" "/")
    (os_adapt "../../../..");
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"./" "./node_modules/xx/./xx.js")
    (os_adapt "./node_modules/xx/xx.js");
  Alcotest.(check string)
    __LOC__
    (Paths.rel_normalized_absolute_path ~from:"././" "./node_modules/xx/./xx.js")
    (os_adapt "./node_modules/xx/xx.js")

let test_normalized_node_rebase () =
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/src" "b")
    "./a/b";
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src/" ~from:"lib/js/src" "b")
    "./b";
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src" ~from:"lib/js/src/a" "b")
    "../b";
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/" "b")
    "./src/a/b";
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/./src/a" ~from:"lib/js/src/a/" "b")
    "./b";

  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/src/a/" "b")
    "./b";
  Alcotest.(check string)
    __LOC__
    (Paths.node_rebase_file ~to_:"lib/js/src/a/" ~from:"lib/js/src/a/" "b")
    "./b"

let suite =
  [
    ("linux path tests", `Quick, test_linux_path);
    ("normalized absolute", `Quick, test_normalized_absolute);
    ("normalized absolute uncommon", `Quick, test_normalized_absolute_uncommon);
    ("normalized module system", `Quick, test_normalized_module_system);
    ("normalized node rebase", `Quick, test_normalized_node_rebase);
  ]
