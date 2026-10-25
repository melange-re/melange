let integer text =
  let expression = Parse.expression (Lexing.from_string text) in
  match expression.pexp_desc with
  | Pexp_constant constant -> (
      match Typecore.constant constant with
      | Ok (Asttypes.Const_int n) -> n
      | _ -> Alcotest.fail "expected an integer constant")
  | _ -> Alcotest.fail "expected a constant expression"

let modes () =
  let previous = !Config.bs_only in
  Fun.protect
    ~finally:(fun () -> Config.bs_only := previous)
    (fun () ->
      Config.bs_only := false;
      Alcotest.(check int)
        "native hexadecimal literal" 0xFFFF_FFFF (integer "0xFFFF_FFFF");
      Config.bs_only := true;
      (* Baseline: target typing still uses the host integer representation. *)
      Alcotest.(check int)
        "Melange hexadecimal literal" 0xFFFF_FFFF (integer "0xFFFF_FFFF");
      Alcotest.(check int)
        "Melange decimal literal" 4294967296 (integer "4294967296");
      Config.bs_only := false;
      Alcotest.(check int)
        "native decimal literal after mode switch" 4294967296
        (integer "4294967296"))

let () =
  Alcotest.run "Target integer constants"
    [ ("mode", [ ("normalization", `Quick, modes) ]) ]
