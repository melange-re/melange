let suites = Mt.[
  "captures", (fun _ ->
    let re = [%re "/(\\d+)-(?:(\\d+))?/g"] in
    let str = "3-" in
    match re |> Js.Re.exec ~str with
      | Some result ->
        let defined = (Js.Re.captures result).(1) in
        let undefined = (Js.Re.captures result).(2) in
        Eq((Js.Nullable.return "3", Js.Nullable.null), (defined, undefined))
      | None -> Fail()
  );

  "fromString", (fun _ ->
    (* From the example in js_re.mli *)
    let contentOf tag xmlString =
      Js.Re.fromString ("<" ^ tag ^ ">(.*?)<\\/" ^ tag ^">")
        |> Js.Re.exec ~str:xmlString
        |. function
          | Some result -> Js.Nullable.toOption (Js.Re.captures result).(1)
          | None -> None in
    Eq (contentOf "div" "<div>Hi</div>", Some "Hi")
  );

  "exec_literal", (fun _ ->
    match [%re "/[^.]+/"] |> Js.Re.exec ~str:"http://xxx.domain.com" with
    | Some res ->
      Eq(Js.Nullable.return "http://xxx", (Js.Re.captures res).(0))
    | None ->
      FailWith "regex should match"
  );

  "exec_no_match", (fun _ ->
    match [%re "/https:\\/\\/(.*)/"] |> Js.Re.exec ~str:"http://xxx.domain.com" with
    | Some _ ->  FailWith "regex should not match"
    | None -> Ok true
  );

  "test_str", (fun _ ->
    let res = "foo"
      |. Js.Re.fromString
      |> Js.Re.test ~str:"#foo#" in

    Eq(true, res)
  );

  "fromStringWithFlags", (fun _ ->
    let res = Js.Re.fromStringWithFlags "foo" ~flags:"g" in

    Eq(true, res |. Js.Re.global)
  );
  "result_index", (fun _ ->
    match "zbar" |. Js.Re.fromString |> Js.Re.exec ~str:"foobarbazbar" with
    | Some res ->
      Eq(8, res |> Js.Re.index)
    | None ->
      Fail ()
  );
  "result_input", (fun _ ->
    let input = "foobar" in

    match [%re "/foo/g"] |> Js.Re.exec ~str:input with
    | Some res ->
      Eq(input,  res |> Js.Re.input)
    | None ->
      Fail ()
  );

  (* es2015 *)
  "t_flags", (fun _ ->
    Eq("gi", [%re "/./ig"] |. Js.Re.flags)
  );

  "t_global", (fun _ ->
    Eq(true, [%re "/./ig"] |. Js.Re.global)
  );
  "t_ignoreCase", (fun _ ->
    Eq(true, [%re "/./ig"] |. Js.Re.ignoreCase)
  );
  "t_lastIndex", (fun _ ->
    let re = [%re "/na/g"] in
    let _ = re |> Js.Re.exec ~str:"banana" in     (* Caml_option.null_to_opt post operation is not dropped in 4.06 which seems to be reduandant *)
    Eq(4,  re |. Js.Re.lastIndex)
  );
  "t_setLastIndex", (fun _ ->
    let re = [%re "/na/g"] in

    let before = Js.Re.lastIndex re in
    let () = Js.Re.setLastIndex re 42 in
    let after = Js.Re.lastIndex re in

    Eq((0, 42),  (before, after))
  );
  "t_multiline", (fun _ ->
    Eq(false, [%re "/./ig"] |. Js.Re.multiline)
  );
  "t_source", (fun _ ->
    Eq("f.+o", [%re "/f.+o/ig"] |. Js.Re.source)
  );

  (* es2015 *)
  "t_sticky", (fun _ ->
    Eq(true, [%re "/./yg"] |. Js.Re.sticky)
  );
  "t_unicode", (fun _ ->
    Eq(false, [%re "/./yg"] |. Js.Re.unicode)
  );
]

;; Mt.from_pair_suites __MODULE__ suites
