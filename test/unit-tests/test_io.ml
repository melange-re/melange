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

let test_read_file_with_zero_reported_size () =
  let path = Filename.temp_file "melange-io" ".fifo" in
  Sys.remove path;
  Unix.mkfifo path 0o600;
  Fun.protect
    ~finally:(fun () -> Sys.remove path)
    (fun () ->
      match Unix.fork () with
      | 0 -> (
          try
            let oc = open_out_bin path in
            output_string oc "contents";
            close_out oc;
            Unix._exit 0
          with _ -> Unix._exit 1)
      | pid -> (
          let result = Io.read_file path in
          let _, status = Unix.waitpid [] pid in
          Alcotest.(check int)
            "writer exited successfully" 0
            (match status with
            | WEXITED code -> code
            | WSIGNALED _ | WSTOPPED _ -> 1);
          match result with
          | Ok contents ->
              Alcotest.(check string) "contents" "contents" contents
          | Error exn -> raise exn))

let suite =
  [
    Alcotest.test_case "read_file returns errors" `Quick test_read_file_error;
    Alcotest.test_case "write_file returns errors" `Quick test_write_file_error;
    Alcotest.test_case "write_filev returns errors" `Quick
      test_write_filev_error;
    Alcotest.test_case "read zero-size streams" `Quick
      test_read_file_with_zero_reported_size;
  ]
