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
      let check mode label expected text =
        Config.bs_only := mode;
        Alcotest.(check int) label expected (integer text)
      in
      check false "native hexadecimal literal" 0xFFFF_FFFF "0xFFFF_FFFF";
      (* Baseline: target typing still uses the host integer representation. *)
      check true "Melange hexadecimal literal" 0xFFFF_FFFF "0xFFFF_FFFF";
      check true "Melange decimal literal" 4294967296 "4294967296";
      check false "native decimal after mode switch" 4294967296 "4294967296")

let () =
  Alcotest.run "Target integer constants"
    [ ("mode", [ ("normalization", `Quick, modes) ]) ]
