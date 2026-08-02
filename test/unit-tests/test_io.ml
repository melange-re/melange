let test_read_file_error () =
  match Io.read_file "/does/not/exist" with
  | Error _ -> ()
  | Ok _ -> Alcotest.fail "expected read_file to return Error"

let test_write_file_error () =
  match Io.write_file "/does/not/exist/file" "contents" with
  | Error _ -> ()
  | Ok () -> Alcotest.fail "expected write_file to return Error"

let test_write_filev_error () =
  match Io.write_filev "/does/not/exist/file" [ "contents" ] with
  | Error _ -> ()
  | Ok () -> Alcotest.fail "expected write_filev to return Error"

let suite =
  [
    Alcotest.test_case "read_file returns errors" `Quick test_read_file_error;
    Alcotest.test_case "write_file returns errors" `Quick test_write_file_error;
    Alcotest.test_case "write_filev returns errors" `Quick
      test_write_filev_error;
  ]
