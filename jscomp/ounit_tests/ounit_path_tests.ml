let ((>::),
     (>:::)) = OUnit.((>::),(>:::))


let normalize = Ext_path.normalize_absolute_path
let os_adapt s =
  let regexp = Str.regexp "\\(/\\)" in
  Str.global_replace regexp (String.escaped Filename.dir_sep) s

let (=~) x y =
  OUnit.assert_equal
  ~printer:(fun x -> x)
  ~cmp:(fun x y ->   Ext_string.equal x y ) x y

let suites =
  __FILE__
  >:::
  [
    "linux path tests" >:: begin fun _ ->
      let norm =
        Array.map normalize
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
            "/a.txt"
          |] in
      OUnit.assert_equal norm
        [|
          "/";
          "/a/c../d/e/f";
          "/a/d/e/f";
          "/";
          "/a/b/c/d" ;
          "/a/b/c/d";
          "/a";
          "/a";
          "/a.txt";
          "/a.txt"
        |]
    end;
    __LOC__ >:: begin fun _ ->
      normalize "/./a/.////////j/k//../////..///././b/./c/d/./." =~ (os_adapt "/a/b/c/d")
    end;
    __LOC__ >:: begin fun _ ->
      normalize "/./a/.////////j/k//../////..///././b/./c/d/././../" =~ (os_adapt "/a/b/c")
    end;

    __LOC__ >:: begin fun _ ->
      let aux a b result =

        Ext_path.rel_normalized_absolute_path
          ~from:a b =~ result ;

        Ext_path.rel_normalized_absolute_path
          ~from:(String.sub a 0 (String.length a - 1))
          b  =~ result ;

        Ext_path.rel_normalized_absolute_path
          ~from:a
          (String.sub b 0 (String.length b - 1))  =~ result
        ;


        Ext_path.rel_normalized_absolute_path
          ~from:(String.sub a 0 (String.length a - 1 ))
          (String.sub b 0 (String.length b - 1))
        =~ result
      in
      aux
        "/a/b/c/"
        "/a/b/c/d/"  (os_adapt "./d");
      aux
        "/a/b/c/"
        "/a/b/c/d/e/f/" (os_adapt "./d/e/f") ;
      aux
        "/a/b/c/d/"
        "/a/b/c/"  ".."  ;
      aux
        "/a/b/c/d/"
        "/a/b/"  (os_adapt "../..")  ;
      aux
        "/a/b/c/d/"
        "/a/"  (os_adapt "../../.." ) ;
      aux
        "/a/b/c/d/"
        "//"  (os_adapt"../../../..")  ;

    end;
    (* This is still correct just not optimal depends
       on user's perspective *)
    __LOC__ >:: begin fun _ ->
      Ext_path.rel_normalized_absolute_path
        ~from:"/a/b/c/d"
        "/x/y" =~ (os_adapt "../../../../x/y");

      Ext_path.rel_normalized_absolute_path
             ~from:"/a/b/c/d/e/./src/bindings/Navigation"
             "/a/b/c/d/e" =~ (os_adapt "../../..");

      Ext_path.rel_normalized_absolute_path
        ~from:"/a/b/c/./d" "/a/b/c" =~ ".." ;

      Ext_path.rel_normalized_absolute_path
        ~from:"/a/b/c/./src" "/a/b/d/./src" =~ (os_adapt "../../d/src") ;
    end;

    (* used in module system: [es6-global] and [amdjs-global] *)
    __LOC__ >:: begin fun _ ->
      Ext_path.rel_normalized_absolute_path
        ~from:"/usr/local/lib/node_modules/"
        "//" =~ (os_adapt "../../../..");
      Ext_path.rel_normalized_absolute_path
        ~from:"/usr/local/lib/node_modules/"
        "/" =~ (os_adapt "../../../..");
      Ext_path.rel_normalized_absolute_path
        ~from:"./"
        "./node_modules/xx/./xx.js" =~ (os_adapt "./node_modules/xx/xx.js");
      Ext_path.rel_normalized_absolute_path
        ~from:"././"
        "./node_modules/xx/./xx.js" =~ (os_adapt "./node_modules/xx/xx.js")
    end;

     __LOC__ >:: begin fun _ ->
      Ext_path.node_rebase_file
        ~to_:( "lib/js/src/a")
        ~from:( "lib/js/src") "b" =~ "./a/b" ;
      Ext_path.node_rebase_file
        ~to_:( "lib/js/src/")
        ~from:( "lib/js/src") "b" =~ "./b" ;
      Ext_path.node_rebase_file
        ~to_:( "lib/js/src")
        ~from:("lib/js/src/a") "b" =~ "../b";
      Ext_path.node_rebase_file
        ~to_:( "lib/js/src/a")
        ~from:("lib/js/") "b" =~ "./src/a/b" ;
      Ext_path.node_rebase_file
        ~to_:("lib/js/./src/a")
        ~from:("lib/js/src/a/") "b"
        =~ "./b";

      Ext_path.node_rebase_file
        ~to_:"lib/js/src/a"
        ~from: "lib/js/src/a/" "b"
      =~ "./b";
      Ext_path.node_rebase_file
        ~to_:"lib/js/src/a/"
        ~from:"lib/js/src/a/" "b"
      =~ "./b"
    end
  ]
