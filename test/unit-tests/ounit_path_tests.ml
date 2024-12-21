open Melstd

let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let normalize = Paths.normalize_absolute_path

let os_adapt s =
  let regexp = Str.regexp "\\(/\\)" in
  Str.global_replace regexp (String.escaped Filename.dir_sep) s

let ( =~ ) x y = OUnit.assert_equal ~printer:(fun x -> x) ~cmp:String.equal x y

let suites =
  __FILE__
  >::: [
         ( "linux path tests" >:: fun _ ->
           let norm =
             Array.map ~f:normalize
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
           OUnit.assert_equal norm
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
             |] );
         ( __LOC__ >:: fun _ ->
           normalize "/./a/.////////j/k//../////..///././b/./c/d/./."
           =~ os_adapt "/a/b/c/d" );
         ( __LOC__ >:: fun _ ->
           normalize "/./a/.////////j/k//../////..///././b/./c/d/././../"
           =~ os_adapt "/a/b/c" );
         ( __LOC__ >:: fun _ ->
           let aux a b result =
             Paths.rel_normalized_absolute_path ~from:a b =~ result;

             Paths.rel_normalized_absolute_path
               ~from:(String.sub a ~pos:0 ~len:(String.length a - 1))
               b
             =~ result;

             Paths.rel_normalized_absolute_path ~from:a
               (String.sub b ~pos:0 ~len:(String.length b - 1))
             =~ result;

             Paths.rel_normalized_absolute_path
               ~from:(String.sub a ~pos:0 ~len:(String.length a - 1))
               (String.sub b ~pos:0 ~len:(String.length b - 1))
             =~ result
           in
           aux "/a/b/c/" "/a/b/c/d/" (os_adapt "d");
           aux "/a/b/c/" "/a/b/c/d/e/f/" (os_adapt "d/e/f");
           aux "/a/b/c/d/" "/a/b/c/" "..";
           aux "/a/b/c/d/" "/a/b/" (os_adapt "../..");
           aux "/a/b/c/d/" "/a/" (os_adapt "../../..");
           aux "/a/b/c/d/" "//" (os_adapt "../../../..") );
         (* This is still correct just not optimal depends
            on user's perspective *)
         ( __LOC__ >:: fun _ ->
           Paths.rel_normalized_absolute_path ~from:"/a/b/c/d" "/x/y"
           =~ os_adapt "../../../../x/y";

           Paths.rel_normalized_absolute_path
             ~from:"/a/b/c/d/e/./src/bindings/Navigation" "/a/b/c/d/e"
           =~ os_adapt "../../..";

           Paths.rel_normalized_absolute_path ~from:"/a/b/c/./d" "/a/b/c"
           =~ "..";

           Paths.rel_normalized_absolute_path ~from:"/a/b/c/./src"
             "/a/b/d/./src"
           =~ os_adapt "../../d/src" );
         (* used in module system: [es6-global] and [amdjs-global] *)
         ( __LOC__ >:: fun _ ->
           Paths.rel_normalized_absolute_path
             ~from:"/usr/local/lib/node_modules/" "//"
           =~ os_adapt "../../../..";
           Paths.rel_normalized_absolute_path
             ~from:"/usr/local/lib/node_modules/" "/"
           =~ os_adapt "../../../..";
           Paths.rel_normalized_absolute_path ~from:"./"
             "./node_modules/xx/./xx.js"
           =~ os_adapt "./node_modules/xx/xx.js";
           Paths.rel_normalized_absolute_path ~from:"././"
             "./node_modules/xx/./xx.js"
           =~ os_adapt "./node_modules/xx/xx.js" );
         ( __LOC__ >:: fun _ ->
           Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/src" "b"
           =~ "./a/b";
           Paths.node_rebase_file ~to_:"lib/js/src/" ~from:"lib/js/src" "b"
           =~ "./b";
           Paths.node_rebase_file ~to_:"lib/js/src" ~from:"lib/js/src/a" "b"
           =~ "../b";
           Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/" "b"
           =~ "./src/a/b";
           Paths.node_rebase_file ~to_:"lib/js/./src/a" ~from:"lib/js/src/a/"
             "b"
           =~ "./b";

           Paths.node_rebase_file ~to_:"lib/js/src/a" ~from:"lib/js/src/a/" "b"
           =~ "./b";
           Paths.node_rebase_file ~to_:"lib/js/src/a/" ~from:"lib/js/src/a/" "b"
           =~ "./b" );
       ]
