open Melangelib

let test_serialize_preserves_global_margin () =
  let path = Filename.temp_file "melange-lam-print" ".tmp" in
  let old_margin = Format.get_margin () in
  Fun.protect
    ~finally:(fun () ->
      Format.set_margin old_margin;
      Sys.remove path)
    (fun () ->
      let expected_margin = 80 in
      Format.set_margin expected_margin;
      let filename = Filename.concat path "dump.lam" in
      (match Lam_print.serialize filename Lam.unit with
      | () -> Alcotest.fail "expected serialize to raise"
      | exception Sys_error _ -> ()
      | exception Unix.Unix_error _ -> ());
      Alcotest.(check int)
        "global formatter margin" expected_margin (Format.get_margin ()))

let suite =
  [
    Alcotest.test_case "serialize preserves global margin" `Quick
      test_serialize_preserves_global_margin;
  ]
