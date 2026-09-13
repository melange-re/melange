let ok_exn = function Ok value -> value | Error exn -> raise exn

let with_temp_path ~f =
  let path = Filename.temp_file "melange-io" ".tmp" in
  Sys.remove path;
  Fun.protect
    ~finally:(fun () -> if Sys.file_exists path then Sys.remove path)
    (fun () -> f path)

let with_temp_dir ~f =
  let path = Filename.temp_file "melange-io" ".tmp" in
  Sys.remove path;
  Unix.mkdir path 0o700;
  Fun.protect ~finally:(fun () -> Unix.rmdir path) (fun () -> f path)

let expect_error label = function
  | Error _ -> ()
  | Ok _ -> Alcotest.failf "%s: expected Error" label

let expect_exception label f =
  match f () with
  | exception _ -> ()
  | _ -> Alcotest.failf "%s: expected exception" label

let test_read_and_write_file () =
  List.iter [ true; false ] ~f:(fun binary ->
      with_temp_path ~f:(fun path ->
          let mode = if binary then "binary" else "text" in
          let contents = "hello\n\000world\n" in
          ok_exn (Io.write_file ~binary ~perm:0o600 path contents);
          Alcotest.(check string)
            (mode ^ " round trip") contents
            (ok_exn (Io.read_file ~binary path));
          if not Sys.win32 then
            Alcotest.(check int)
              (mode ^ " permissions") 0o600 (Unix.stat path).st_perm;
          ok_exn (Io.write_file ~binary ~perm:0o600 path "");
          Alcotest.(check string)
            (mode ^ " truncation") ""
            (ok_exn (Io.read_file ~binary path))))

let test_read_and_write_filev () =
  List.iter [ true; false ] ~f:(fun binary ->
      with_temp_path ~f:(fun path ->
          let mode = if binary then "binary" else "text" in
          let chunks = [ "hello\n"; ""; "\000world\n" ] in
          let contents = String.concat ~sep:"" chunks in
          ok_exn (Io.write_filev ~binary ~perm:0o600 path chunks);
          Alcotest.(check string)
            (mode ^ " round trip") contents
            (ok_exn (Io.read_file ~binary path));
          if not Sys.win32 then
            Alcotest.(check int)
              (mode ^ " permissions") 0o600 (Unix.stat path).st_perm;
          ok_exn (Io.write_filev ~binary ~perm:0o600 path []);
          Alcotest.(check string)
            (mode ^ " truncation") ""
            (ok_exn (Io.read_file ~binary path))))

let test_file_errors () =
  with_temp_dir ~f:(fun dir ->
      let missing = Filename.concat (Filename.concat dir "missing") "file" in
      List.iter [ true; false ] ~f:(fun binary ->
          let mode = if binary then "binary" else "text" in
          let check label result = expect_error (mode ^ " " ^ label) result in
          check "read missing" (Io.read_file ~binary missing);
          check "write missing" (Io.write_file ~binary missing "contents");
          check "writev missing" (Io.write_filev ~binary missing [ "contents" ]);
          check "read directory" (Io.read_file ~binary dir);
          check "write directory" (Io.write_file ~binary dir "contents");
          check "writev directory" (Io.write_filev ~binary dir [ "contents" ]));
      expect_exception "read_file_exn" (fun () -> Io.read_file_exn missing);
      expect_exception "write_file_exn" (fun () ->
          Io.write_file_exn missing "contents");
      expect_exception "write_filev_exn" (fun () ->
          Io.write_filev_exn missing [ "contents" ]))

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

let test_cleanup_preserves_original_error () =
  let path = Filename.temp_file "melange-io" ".txt" in
  let raise_original_error () : unit = failwith "original error" in
  Fun.protect
    ~finally:(fun () -> Sys.remove path)
    (fun () ->
      try
        Io.with_file_in_fd path ~f:(fun fd ->
            Unix.close fd;
            raise_original_error ());
        Alcotest.fail "expected an exception"
      with
      | Failure message ->
          Alcotest.(check string) "error" "original error" message
      | exn ->
          Alcotest.failf "unexpected exception: %s" (Printexc.to_string exn))

let test_cleanup_error_propagates () =
  let path = Filename.temp_file "melange-io" ".txt" in
  Fun.protect
    ~finally:(fun () -> Sys.remove path)
    (fun () ->
      match Io.with_file_in_fd path ~f:Unix.close with
      | exception Unix.Unix_error (EBADF, _, _) -> ()
      | exception exn ->
          Alcotest.failf "unexpected exception: %s" (Printexc.to_string exn)
      | () -> Alcotest.fail "expected cleanup to fail")

let suite =
  [
    Alcotest.test_case "read and write files" `Quick test_read_and_write_file;
    Alcotest.test_case "read and write filev" `Quick test_read_and_write_filev;
    Alcotest.test_case "file errors" `Quick test_file_errors;
    Alcotest.test_case "read zero-size streams" `Quick
      test_read_file_with_zero_reported_size;
    Alcotest.test_case "preserve errors during cleanup" `Quick
      test_cleanup_preserves_original_error;
    Alcotest.test_case "propagate cleanup errors" `Quick
      test_cleanup_error_propagates;
  ]
