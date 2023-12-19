let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) a b = OUnit.assert_equal ~cmp:String.equal a b

module Utf8_string = Melange_ffi.Utf8_string

(* Note [Var] kind can not be mpty  *)
let empty_segment { Utf8_string.Interp.Private.content; _ } =
  String.length content = 0

(** Test for single line *)
let ( ==~ ) a b =
  OUnit.assert_equal
    (List.map
       (fun ({
               start = { offset = a; _ };
               finish = { offset = b; _ };
               kind;
               content;
             } :
              Utf8_string.Interp.Private.segment) -> (a, b, kind, content))
       (Utf8_string.Interp.Private.transform_test a
       |> List.filter (fun x -> not @@ empty_segment x)))
    b

let ( ==* ) a b =
  let segments =
    List.map
      (fun ({
              start = { lnum = la; offset = a; _ };
              finish = { lnum = lb; offset = b; _ };
              kind;
              content;
            } :
             Utf8_string.Interp.Private.segment) ->
        (la, a, lb, b, kind, content))
      (Utf8_string.Interp.Private.transform_test a
      |> List.filter (fun x -> not @@ empty_segment x))
  in
  OUnit.assert_equal segments b

let varParen : Utf8_string.Interp.kind = Var (2, -1)
let var : Utf8_string.Interp.kind = Var (1, 0)

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           Utf8_string.Utf8_string.Private.transform {|x|} =~ {|x|} );
         ( __LOC__ >:: fun _ ->
           Utf8_string.Utf8_string.Private.transform "a\nb" =~ {|a\nb|} );
         ( __LOC__ >:: fun _ ->
           Utf8_string.Utf8_string.Private.transform "\\n" =~ "\\n" );
         ( __LOC__ >:: fun _ ->
           Utf8_string.Utf8_string.Private.transform
             "\\\\\\b\\t\\n\\v\\f\\r\\0\\$"
           =~ "\\\\\\b\\t\\n\\v\\f\\r\\0\\$" );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Utf8_string.Private.transform {|\|} with
           | exception Utf8_string.Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 1
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Utf8_string.Private.transform {|你\|} with
           | exception Utf8_string.Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 2
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           Utf8_string.Utf8_string.Private.transform {|\h\e\l\lo \"world\"!|}
           =~ {|\h\e\l\lo \"world\"!|} );
         ( __LOC__ >:: fun _ ->
           match
             Utf8_string.Utf8_string.Private.transform
               {|你BuckleScript,好啊\uffff\|}
           with
           | exception Utf8_string.Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 23
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           "hie $x hi 你好"
           ==~ [
                 (0, 4, String, "hie ");
                 (4, 6, var, "x");
                 (6, 12, String, " hi 你好");
               ] );
         (__LOC__ >:: fun _ -> "x" ==~ [ (0, 1, String, "x") ]);
         (__LOC__ >:: fun _ -> "" ==~ []);
         (__LOC__ >:: fun _ -> "你好" ==~ [ (0, 2, String, "你好") ]);
         ( __LOC__ >:: fun _ ->
           "你好$x" ==~ [ (0, 2, String, "你好"); (2, 4, var, "x") ] );
         ( __LOC__ >:: fun _ ->
           "你好$this" ==~ [ (0, 2, String, "你好"); (2, 7, var, "this") ] );
         ( __LOC__ >:: fun _ ->
           "你好$(this)" ==~ [ (0, 2, String, "你好"); (2, 9, varParen, "this") ];

           "你好$this)"
           ==~ [
                 (0, 2, String, "你好"); (2, 7, var, "this"); (7, 8, String, ")");
               ];
           {|\xff\xff你好 $x |}
           ==~ [
                 (0, 11, String, {|\xff\xff你好 |});
                 (11, 13, var, "x");
                 (13, 14, String, " ");
               ];
           {|\xff\xff你好 $x 不吃亏了buckle $y $z = $sum|}
           ==~ [
                 (0, 11, String, {|\xff\xff你好 |});
                 (11, 13, var, "x");
                 (13, 25, String, {| 不吃亏了buckle |});
                 (25, 27, var, "y");
                 (27, 28, String, " ");
                 (28, 30, var, "z");
                 (30, 33, String, " = ");
                 (33, 37, var, "sum");
               ] );
         ( __LOC__ >:: fun _ ->
           "你好 $(this_is_a_var)  x"
           ==~ [
                 (0, 3, String, "你好 ");
                 (3, 19, varParen, "this_is_a_var");
                 (19, 22, String, "  x");
               ] );
         ( __LOC__ >:: fun _ ->
           "hi\n$x\n"
           ==* [
                 (0, 0, 1, 0, String, "hi\\n");
                 (1, 0, 1, 2, var, "x");
                 (1, 2, 2, 0, String, "\\n");
               ];
           "$x" ==* [ (0, 0, 0, 2, var, "x") ];

           "\n$x\n"
           ==* [
                 (0, 0, 1, 0, String, "\\n");
                 (1, 0, 1, 2, var, "x");
                 (1, 2, 2, 0, String, "\\n");
               ] );
         ( __LOC__ >:: fun _ ->
           "\n$(x_this_is_cool) "
           ==* [
                 (0, 0, 1, 0, String, "\\n");
                 (1, 0, 1, 17, varParen, "x_this_is_cool");
                 (1, 17, 1, 18, String, " ");
               ] );
         ( __LOC__ >:: fun _ ->
           " $x + $y = $sum "
           ==* [
                 (0, 0, 0, 1, String, " ");
                 (0, 1, 0, 3, var, "x");
                 (0, 3, 0, 6, String, " + ");
                 (0, 6, 0, 8, var, "y");
                 (0, 8, 0, 11, String, " = ");
                 (0, 11, 0, 15, var, "sum");
                 (0, 15, 0, 16, String, " ");
               ] );
         ( __LOC__ >:: fun _ ->
           "中文 | $a "
           ==* [
                 (0, 0, 0, 5, String, "中文 | ");
                 (0, 5, 0, 7, var, "a");
                 (0, 7, 0, 8, String, " ");
               ] );
         ( __LOC__ >:: fun _ ->
           {|Hello \\$world|}
           ==* [
                 (0, 0, 0, 8, String, "Hello \\\\"); (0, 8, 0, 14, var, "world");
               ] );
         ( __LOC__ >:: fun _ ->
           {|$x)|} ==* [ (0, 0, 0, 2, var, "x"); (0, 2, 0, 3, String, ")") ] );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {j| $( ()) |j} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 1; byte_bol = 0 },
                   { lnum = 0; offset = 6; byte_bol = 0 },
                   Invalid_syntax_of_var " (" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {|$ ()|} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 1; byte_bol = 0 },
                   Invalid_syntax_of_var "" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {|$()|} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 0; byte_bol = 3 },
                   Invalid_syntax_of_var "" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match
             Utf8_string.Interp.Private.transform_test {|$(hello world)|}
           with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 14; byte_bol = 0 },
                   Invalid_syntax_of_var "hello world" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {|$( hi*) |} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 7; byte_bol = 0 },
                   Invalid_syntax_of_var " hi*" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {|xx $|} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 3; byte_bol = 0 },
                   { lnum = 0; offset = 3; byte_bol = 0 },
                   Unterminated_variable ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Interp.Private.transform_test {|$(world |} with
           | exception
               Utf8_string.Interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 9; byte_bol = 0 },
                   Unmatched_paren ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
       ]
