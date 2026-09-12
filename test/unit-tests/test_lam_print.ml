open Melangelib

let test_serialize_returns_write_error () =
  let path = Filename.temp_file "melange-lam-print" ".tmp" in
  let old_margin = Format.get_margin () in
  Fun.protect
    ~finally:(fun () ->
      Format.set_margin old_margin;
      Sys.remove path)
    (fun () ->
      let filename = Filename.concat path "dump.lam" in
      match Lam_print.serialize filename Lam.unit with
      | Error _ ->
          Alcotest.(check int)
            "global formatter margin" old_margin (Format.get_margin ())
      | Ok () -> Alcotest.fail "expected serialize to return Error")

let suite =
  [
    Alcotest.test_case "serialize returns write errors" `Quick
      test_serialize_returns_write_error;
  ]
