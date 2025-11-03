let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) a b = OUnit.assert_equal ~cmp:String.equal a b

module Utf8_string = Melange_ffi.Utf8_string
module String_interp = Melange_ppx__String_interp

let content = function
  | String_interp.String content -> content
  | Var { content; _ } -> content

(* Note [Var] kind can not be mpty  *)
let empty_segment { String_interp.Private.content = ct; _ } =
  String.length (content ct) = 0

(** Test for single line *)
let ( ==~ ) a b =
  OUnit.assert_equal
    (List.map
       (fun ({ start = { offset = a; _ }; finish = { offset = b; _ }; content } :
              String_interp.Private.segment) ->
         ( a,
           b,
           match content with
           | Var { loffset; roffset; content; lident = _ } ->
               String_interp.Var
                 { loffset; roffset; content; lident = Lident "" }
           | String x -> String x ))
       (String_interp.Private.transform_test a
       |> List.filter (fun x -> not @@ empty_segment x)))
    b

let ( ==* ) a b =
  let segments =
    List.map
      (fun ({
              start = { lnum = la; offset = a; _ };
              finish = { lnum = lb; offset = b; _ };
              content;
            } :
             String_interp.Private.segment) ->
        ( la,
          a,
          lb,
          b,
          match content with
          | Var { loffset; roffset; content; lident = _ } ->
              String_interp.Var
                { loffset; roffset; content; lident = Lident "" }
          | String x -> String x ))
      (String_interp.Private.transform_test a
      |> List.filter (fun x -> not @@ empty_segment x))
  in
  OUnit.assert_equal segments b

let varParen content =
  String_interp.Var { loffset = 2; roffset = -1; content; lident = Lident "" }

let var content =
  String_interp.Var { loffset = 1; roffset = 0; content; lident = Lident "" }

let suites =
  __FILE__
  >::: [
         (__LOC__ >:: fun _ -> Utf8_string.Private.transform {|x|} =~ {|x|});
         (__LOC__ >:: fun _ -> Utf8_string.Private.transform "a\nb" =~ {|a\nb|});
         (__LOC__ >:: fun _ -> Utf8_string.Private.transform "\\n" =~ "\\n");
         ( __LOC__ >:: fun _ ->
           Utf8_string.Private.transform "\\\\\\b\\t\\n\\v\\f\\r\\0\\$"
           =~ "\\\\\\b\\t\\n\\v\\f\\r\\0\\$" );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Private.transform {|\|} with
           | exception Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 1
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Private.transform {|你\|} with
           | exception Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 2
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           Utf8_string.Private.transform {|\h\e\l\lo \"world\"!|}
           =~ {|\h\e\l\lo \"world\"!|} );
         ( __LOC__ >:: fun _ ->
           match Utf8_string.Private.transform {|你BuckleScript,好啊\uffff\|} with
           | exception Utf8_string.Error (offset, _) ->
               OUnit.assert_equal offset 23
           | _ -> OUnit.assert_failure __LOC__ );
         ( __LOC__ >:: fun _ ->
           "hie $x hi 你好"
           ==~ [
                 (0, 4, String_interp.String "hie ");
                 (4, 6, var "x");
                 (6, 16, String " hi 你好");
               ] );
         (__LOC__ >:: fun _ -> "x" ==~ [ (0, 1, String "x") ]);
         (__LOC__ >:: fun _ -> "" ==~ []);
         (__LOC__ >:: fun _ -> "你好" ==~ [ (0, 6, String "你好") ]);
         ( __LOC__ >:: fun _ ->
           "你好$x" ==~ [ (0, 6, String "你好"); (6, 8, var "x") ] );
         ( __LOC__ >:: fun _ ->
           "你好$this" ==~ [ (0, 6, String "你好"); (6, 11, var "this") ] );
         ( __LOC__ >:: fun _ ->
           "你好$(this)" ==~ [ (0, 6, String "你好"); (6, 13, varParen "this") ];

           "你好$this)"
           ==~ [
                 (0, 6, String "你好"); (6, 11, var "this"); (11, 12, String ")");
               ];
           {|\xff\xff你好 $x |}
           ==~ [
                 (0, 15, String {|\xff\xff你好 |});
                 (15, 17, var "x");
                 (17, 18, String " ");
               ];
           {|\xff\xff你好 $x 不吃亏了buckle $y $z = $sum|}
           ==~ [
                 (0, 15, String {|\xff\xff你好 |});
                 (15, 17, var "x");
                 (17, 37, String {| 不吃亏了buckle |});
                 (37, 39, var "y");
                 (39, 40, String " ");
                 (40, 42, var "z");
                 (42, 45, String " = ");
                 (45, 49, var "sum");
               ] );
         ( __LOC__ >:: fun _ ->
           "你好 $(this_is_a_var)  x"
           ==~ [
                 (0, 7, String "你好 ");
                 (7, 23, varParen "this_is_a_var");
                 (23, 26, String "  x");
               ] );
         ( __LOC__ >:: fun _ ->
           "hi\n$x\n"
           ==* [
                 (0, 0, 0, 3, String "hi\n");
                 (0, 3, 0, 5, var "x");
                 (0, 5, 0, 6, String "\n");
               ];
           "$x" ==* [ (0, 0, 0, 2, var "x") ];

           "\n$x\n"
           ==* [
                 (0, 0, 0, 1, String "\n");
                 (0, 1, 0, 3, var "x");
                 (0, 3, 0, 4, String "\n");
               ] );
         ( __LOC__ >:: fun _ ->
           "\n$(x_this_is_cool) "
           ==* [
                 (0, 0, 0, 1, String "\n");
                 (0, 1, 0, 18, varParen "x_this_is_cool");
                 (0, 18, 0, 19, String " ");
               ] );
         ( __LOC__ >:: fun _ ->
           " $x + $y = $sum "
           ==* [
                 (0, 0, 0, 1, String " ");
                 (0, 1, 0, 3, var "x");
                 (0, 3, 0, 6, String " + ");
                 (0, 6, 0, 8, var "y");
                 (0, 8, 0, 11, String " = ");
                 (0, 11, 0, 15, var "sum");
                 (0, 15, 0, 16, String " ");
               ] );
         ( __LOC__ >:: fun _ ->
           "中文 | $a "
           ==* [
                 (0, 0, 0, 9, String "中文 | ");
                 (0, 9, 0, 11, var "a");
                 (0, 11, 0, 12, String " ");
               ] );
         ( __LOC__ >:: fun _ ->
           {|Hello \\$world|}
           ==* [ (0, 0, 0, 8, String "Hello \\\\"); (0, 8, 0, 14, var "world") ]
         );
         ( __LOC__ >:: fun _ ->
           {|$x)|} ==* [ (0, 0, 0, 2, var "x"); (0, 2, 0, 3, String ")") ] );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {j| $( ()) |j} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 1; byte_bol = 0 },
                   { lnum = 0; offset = 6; byte_bol = 0 },
                   Invalid_syntax_of_var " (" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|$ ()|} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 1; byte_bol = 0 },
                   Invalid_syntax_of_var "" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|$()|} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 0; byte_bol = 3 },
                   Invalid_syntax_of_var "" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|$(hello world)|} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 14; byte_bol = 0 },
                   Invalid_syntax_of_var "hello world" ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|$( hi |} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 7; byte_bol = 0 },
                   Unmatched_paren ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|xx $|} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 3; byte_bol = 0 },
                   { lnum = 0; offset = 3; byte_bol = 0 },
                   Unterminated_variable ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
         ( __LOC__ >:: fun _ ->
           match String_interp.Private.transform_test {|$(world |} with
           | exception
               String_interp.Error
                 ( { lnum = 0; offset = 0; byte_bol = 0 },
                   { lnum = 0; offset = 9; byte_bol = 0 },
                   Unmatched_paren ) ->
               OUnit.assert_bool __LOC__ true
           | _ -> OUnit.assert_bool __LOC__ false );
       ]
