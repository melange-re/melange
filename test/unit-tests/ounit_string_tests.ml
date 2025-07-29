open Melstd

let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal ~printer:Ounit_test_util.dump
let printer_string x = x
let string_eq = OUnit.assert_equal ~printer:(fun id -> id)

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           OUnit.assert_bool "not found " (String.rindex_neg "hello" 'x' < 0) );
         ( __LOC__ >:: fun _ ->
           String.rindex_neg "hello" 'h' =~ 0;
           String.rindex_neg "hello" 'e' =~ 1;
           String.rindex_neg "hello" 'l' =~ 3;
           String.rindex_neg "hello" 'l' =~ 3;
           String.rindex_neg "hello" 'o' =~ 4 );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_bool "empty string" (String.rindex_neg "" 'x' < 0) );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_bool __LOC__
             (not
                (String.for_all_from "xABc" ~from:1 ~f:(function
                  | 'A' .. 'Z' -> true
                  | _ -> false)));
           OUnit.assert_bool __LOC__
             (String.for_all_from "xABC" ~from:1 ~f:(function
               | 'A' .. 'Z' -> true
               | _ -> false));
           OUnit.assert_bool __LOC__
             (String.for_all_from "xABC" ~from:1_000 ~f:(function
               | 'A' .. 'Z' -> true
               | _ -> false)) );
         ( __LOC__ >:: fun _ ->
           String.tail_from "ghsogh" ~from:1 =~ "hsogh";
           String.tail_from "ghsogh" ~from:0 =~ "ghsogh" );
         (* __LOC__ >:: begin fun _ ->
            String.digits_of_str "11_js" ~offset:0 2 =~ 11
            end; *)
         ( __LOC__ >:: fun _ ->
           let ( =~ ) = OUnit.assert_equal ~printer:printer_string in
           Filename.chop_all_extensions_maybe "a.bs.js" =~ "a";
           Filename.chop_all_extensions_maybe "a.js" =~ "a";
           Filename.chop_all_extensions_maybe "a" =~ "a";
           Filename.chop_all_extensions_maybe "a.x.bs.js" =~ "a" );
         (* let (=~) = OUnit.assert_equal ~printer:(fun x -> x) in  *)
         ( __LOC__ >:: fun _ ->
           let k = Modulename.js_id_name_of_hint_name in
           k "xx" =~ "Xx";
           k "react-dom" =~ "ReactDom";
           k "a/b/react-dom" =~ "ReactDom";
           k "a/b" =~ "B";
           k "a/" =~ "A/";
           (*TODO: warning?*)
           k "#moduleid" =~ "Moduleid";
           k "@bundle" =~ "Bundle";
           k "xx#bc" =~ "Xxbc";
           k "hi@myproj" =~ "Himyproj";
           k "ab/c/xx.b.js" =~ "XxBJs";
           (* improve it in the future*)
           k "c/d/a--b" =~ "AB";
           k "c/d/ac--" =~ "Ac" );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_equal (String.length (Digest.string "")) 16 );
         ( __LOC__ >:: fun _ ->
           let bench =
             String.concat ~sep:";"
               (List.init ~len:11 ~f:(fun i -> string_of_int i))
           in
           let buf = Buffer.create 10 in
           OUnit.assert_bool __LOC__ (Buffer.contents buf <> bench);
           for i = 0 to 9 do
             Buffer.add_string buf (string_of_int i);
             Buffer.add_string buf ";"
           done;
           OUnit.assert_bool __LOC__ (Buffer.contents buf <> bench);
           Buffer.add_string buf "10";
           (* print_endline (Ext_buffer.contents buf);
              print_endline bench; *)
           OUnit.assert_bool __LOC__ (Buffer.contents buf = bench) );
         ( __LOC__ >:: fun _ ->
           string_eq (Filename.new_extension "a.c" ".xx") "a.xx";
           string_eq (Filename.new_extension "abb.c" ".xx") "abb.xx";
           string_eq (Filename.new_extension ".c" ".xx") ".xx";
           string_eq (Filename.new_extension "a/b" ".xx") "a/b.xx";
           string_eq (Filename.new_extension "a/b." ".xx") "a/b.xx";
           string_eq (Filename.chop_all_extensions_maybe "a.b.x") "a";
           string_eq (Filename.chop_all_extensions_maybe "a.b") "a";
           string_eq (Filename.chop_all_extensions_maybe ".a.b.x") "";
           string_eq (Filename.chop_all_extensions_maybe "abx") "abx" );
         ( __LOC__ >:: fun _ ->
           String.split "" ~sep:':' =~ [];
           String.split "a:b:" ~sep:':' =~ [ "a"; "b" ];
           String.split "a:b:" ~sep:':' ~keep_empty:true =~ [ "a"; "b"; "" ] );
       ]
