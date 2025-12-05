module Utf8_string = Melange_ffi.Utf8_string
module String_interp = Melange_ppx__String_interp

let content = function
  | String_interp.String content -> content
  | Var { content; _ } -> content

(* Note [Var] kind can not be mpty  *)
let empty_segment { String_interp.Private.content = ct; _ } =
  String.length (content ct) = 0

let string_interp fmt interp = Format.pp_print_string fmt (content interp)

let segment =
  let string_interp =
    Alcotest.testable string_interp (fun a b ->
        String.equal (content a) (content b))
  in
  Alcotest.(triple int int string_interp)

(** Test for single line *)
let test_segment loc a b =
  Alcotest.(check (list segment))
    loc
    (List.map
       ~f:(fun
           ({ start = { offset = a; _ }; finish = { offset = b; _ }; content } :
             String_interp.Private.segment)
         ->
         ( a,
           b,
           match content with
           | Var { loffset; roffset; content; lident = _ } ->
               String_interp.Var
                 { loffset; roffset; content; lident = Lident "" }
           | String x -> String x ))
       (String_interp.Private.transform_test a
       |> List.filter ~f:(fun x -> not @@ empty_segment x)))
    b

let full_segment =
  let eq (a1, b1, c1, d1, s1) (a2, b2, c2, d2, s2) =
    Int.equal a1 a2 && Int.equal b1 b2 && Int.equal c1 c2 && Int.equal d1 d2
    && String.equal (content s1) (content s2)
  in
  let pp =
    Fmt.(
      parens
        (using (fun (x, _, _, _, _) -> x) (box int)
        ++ comma
        ++ using (fun (_, x, _, _, _) -> x) (box int)
        ++ comma
        ++ using (fun (_, _, x, _, _) -> x) (box int)
        ++ comma
        ++ using (fun (_, _, _, x, _) -> x) (box int)
        ++ comma
        ++ using (fun (_, _, _, _, x) -> x) (box string_interp)))
  in
  Alcotest.testable pp eq

let test_full_segment loc a b =
  let segments =
    List.map
      ~f:(fun
          ({
             start = { lnum = la; offset = a; _ };
             finish = { lnum = lb; offset = b; _ };
             content;
           } :
            String_interp.Private.segment)
        ->
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
      |> List.filter ~f:(fun x -> not @@ empty_segment x))
  in
  Alcotest.(check (list full_segment)) loc segments b

let varParen content =
  String_interp.Var { loffset = 2; roffset = -1; content; lident = Lident "" }

let var content =
  String_interp.Var { loffset = 1; roffset = 0; content; lident = Lident "" }

let test_transform () =
  Alcotest.(check string) __LOC__ (Utf8_string.Private.transform {|x|}) {|x|};
  Alcotest.(check string)
    __LOC__
    (Utf8_string.Private.transform "a\nb")
    {|a\nb|};
  Alcotest.(check string) __LOC__ (Utf8_string.Private.transform "\\n") "\\n";
  Alcotest.(check string)
    __LOC__
    (Utf8_string.Private.transform "\\\\\\b\\t\\n\\v\\f\\r\\0\\$")
    "\\\\\\b\\t\\n\\v\\f\\r\\0\\$";

  (match Utf8_string.Private.transform {|\|} with
  | exception Utf8_string.Error (offset, _) ->
      Alcotest.(check int) __LOC__ offset 1
  | _ -> Alcotest.fail __LOC__);

  (match Utf8_string.Private.transform {|你\|} with
  | exception Utf8_string.Error (offset, _) ->
      Alcotest.(check int) __LOC__ offset 2
  | _ -> Alcotest.fail __LOC__);

  Alcotest.(check string)
    __LOC__
    (Utf8_string.Private.transform {|\h\e\l\lo \"world\"!|})
    {|\h\e\l\lo \"world\"!|};

  match Utf8_string.Private.transform {|你BuckleScript,好啊\uffff\|} with
  | exception Utf8_string.Error (offset, _) ->
      Alcotest.(check int) __LOC__ offset 23
  | _ -> Alcotest.fail __LOC__

let test_segment_single_line () =
  test_segment __LOC__ "hie $x hi 你好"
    [
      (0, 4, String_interp.String "hie ");
      (4, 6, var "x");
      (6, 16, String " hi 你好");
    ];
  test_segment __LOC__ "x" [ (0, 1, String "x") ];
  test_segment __LOC__ "" [];
  test_segment __LOC__ "你好" [ (0, 6, String "你好") ];
  test_segment __LOC__ "你好$x" [ (0, 6, String "你好"); (6, 8, var "x") ];
  test_segment __LOC__ "你好$this" [ (0, 6, String "你好"); (6, 11, var "this") ];
  test_segment __LOC__ "你好$(this)"
    [ (0, 6, String "你好"); (6, 13, varParen "this") ];

  test_segment __LOC__ "你好$this)"
    [ (0, 6, String "你好"); (6, 11, var "this"); (11, 12, String ")") ];
  test_segment __LOC__ {|\xff\xff你好 $x |}
    [ (0, 15, String {|\xff\xff你好 |}); (15, 17, var "x"); (17, 18, String " ") ];

  test_segment __LOC__ {|\xff\xff你好 $x 不吃亏了buckle $y $z = $sum|}
    [
      (0, 15, String {|\xff\xff你好 |});
      (15, 17, var "x");
      (17, 37, String {| 不吃亏了buckle |});
      (37, 39, var "y");
      (39, 40, String " ");
      (40, 42, var "z");
      (42, 45, String " = ");
      (45, 49, var "sum");
    ];
  test_segment __LOC__ "你好 $(this_is_a_var)  x"
    [
      (0, 7, String "你好 ");
      (7, 23, varParen "this_is_a_var");
      (23, 26, String "  x");
    ]

let test_segment_multi_line () =
  test_full_segment __LOC__ "hi\n$x\n"
    [
      (0, 0, 0, 3, String "hi\n");
      (0, 3, 0, 5, var "x");
      (0, 5, 0, 6, String "\n");
    ];
  test_full_segment __LOC__ "$x" [ (0, 0, 0, 2, var "x") ];

  test_full_segment __LOC__ "\n$x\n"
    [
      (0, 0, 0, 1, String "\n"); (0, 1, 0, 3, var "x"); (0, 3, 0, 4, String "\n");
    ];
  test_full_segment __LOC__ "\n$(x_this_is_cool) "
    [
      (0, 0, 0, 1, String "\n");
      (0, 1, 0, 18, varParen "x_this_is_cool");
      (0, 18, 0, 19, String " ");
    ];
  test_full_segment __LOC__ " $x + $y = $sum "
    [
      (0, 0, 0, 1, String " ");
      (0, 1, 0, 3, var "x");
      (0, 3, 0, 6, String " + ");
      (0, 6, 0, 8, var "y");
      (0, 8, 0, 11, String " = ");
      (0, 11, 0, 15, var "sum");
      (0, 15, 0, 16, String " ");
    ];
  test_full_segment __LOC__ "中文 | $a "
    [
      (0, 0, 0, 9, String "中文 | ");
      (0, 9, 0, 11, var "a");
      (0, 11, 0, 12, String " ");
    ];
  test_full_segment __LOC__ {|Hello \\$world|}
    [ (0, 0, 0, 8, String "Hello \\\\"); (0, 8, 0, 14, var "world") ];
  test_full_segment __LOC__ {|$x)|}
    [ (0, 0, 0, 2, var "x"); (0, 2, 0, 3, String ")") ]

let test_transform_check () =
  (match String_interp.Private.transform_test {j| $( ()) |j} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 1; byte_bol = 0 },
          { lnum = 0; offset = 6; byte_bol = 0 },
          Invalid_syntax_of_var " (" ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);
  (match String_interp.Private.transform_test {|$ ()|} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 0; byte_bol = 0 },
          { lnum = 0; offset = 1; byte_bol = 0 },
          Invalid_syntax_of_var "" ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);
  (match String_interp.Private.transform_test {|$()|} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 0; byte_bol = 0 },
          { lnum = 0; offset = 0; byte_bol = 3 },
          Invalid_syntax_of_var "" ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);
  (match String_interp.Private.transform_test {|$(hello world)|} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 0; byte_bol = 0 },
          { lnum = 0; offset = 14; byte_bol = 0 },
          Invalid_syntax_of_var "hello world" ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);
  (match String_interp.Private.transform_test {|$( hi |} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 0; byte_bol = 0 },
          { lnum = 0; offset = 7; byte_bol = 0 },
          Unmatched_paren ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);

  (match String_interp.Private.transform_test {|xx $|} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 3; byte_bol = 0 },
          { lnum = 0; offset = 3; byte_bol = 0 },
          Unterminated_variable ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__);

  match String_interp.Private.transform_test {|$(world |} with
  | exception
      String_interp.Error
        ( { lnum = 0; offset = 0; byte_bol = 0 },
          { lnum = 0; offset = 9; byte_bol = 0 },
          Unmatched_paren ) ->
      Alcotest.(check pass) __LOC__ true true
  | _ -> Alcotest.fail __LOC__

let suite =
  [
    ("transform", `Quick, test_transform);
    ("segment single line", `Quick, test_segment_single_line);
    ("segment multi line", `Quick, test_segment_multi_line);
    ("transform check", `Quick, test_transform_check);
  ]
