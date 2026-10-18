let cases =
  [
    (0l, 0l, "\x00\x00\x00\x00", "\x00\x00\x00\x00");
    (0x01020304l, 0x04030201l, "\x01\x02\x03\x04", "\x04\x03\x02\x01");
    (0x12345678l, 0x78563412l, "\x12\x34\x56\x78", "\x78\x56\x34\x12");
    (0x12345680l, 0x80563412l, "\x12\x34\x56\x80", "\x80\x56\x34\x12");
    (0x89abcdefl, 0xefcdab89l, "\x89\xab\xcd\xef", "\xef\xcd\xab\x89");
    (Int32.min_int, 0x00000080l, "\x80\x00\x00\x00", "\x00\x00\x00\x80");
    (Int32.max_int, 0xffffff7fl, "\x7f\xff\xff\xff", "\xff\xff\xff\x7f");
    (-1l, -1l, "\xff\xff\xff\xff", "\xff\xff\xff\xff");
  ]

let suites =
  List.concat_map
    (fun offset ->
      List.concat_map
        (fun (value, swapped, be, le) ->
          let padding = String.make offset '\xaa' in
          let padded s = padding ^ s ^ padding in
          let encode set =
            let bytes = Bytes.make (4 + (2 * offset)) '\xaa' in
            set bytes offset value;
            bytes
          in
          let test name f =
            (Printf.sprintf "%s %lx at offset %d" name value offset, f)
          in
          [
            test "set_int32_be" (fun () ->
                Mt.Eq (Bytes.to_string (encode Bytes.set_int32_be), padded be));
            test "set_int32_le" (fun () ->
                Mt.Eq (Bytes.to_string (encode Bytes.set_int32_le), padded le));
            test "get_int32_be" (fun () ->
                Mt.Eq (Bytes.get_int32_be (Bytes.of_string (padded be)) offset, value));
            test "get_int32_le" (fun () ->
                Mt.Eq (Bytes.get_int32_le (Bytes.of_string (padded le)) offset, value));
            test "int32_be_roundtrip" (fun () ->
                Mt.Eq (Bytes.get_int32_be (encode Bytes.set_int32_be) offset, value));
            test "int32_le_roundtrip" (fun () ->
                Mt.Eq (Bytes.get_int32_le (encode Bytes.set_int32_le) offset, value));
            (* Reading with the opposite endianness reverses the bytes. *)
            test "set_int32_be_get_int32_le" (fun () ->
                Mt.Eq (Bytes.get_int32_le (encode Bytes.set_int32_be) offset, swapped));
            test "set_int32_le_get_int32_be" (fun () ->
                Mt.Eq (Bytes.get_int32_be (encode Bytes.set_int32_le) offset, swapped));
          ])
        cases)
    [ 0; 1 ]

let () = Mt.from_pair_suites __MODULE__ suites
