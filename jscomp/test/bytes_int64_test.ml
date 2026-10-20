(* Reduced from https://github.com/eWert-Online/melange-endian-error/blob/8329340a4a52de234a2fa7bf4b1aec43c9a4984d/bin/error.ml *)
let string_roundtrip add_int64 get_int64 input =
  let buffer = Buffer.create (8 * String.length input) in
  String.iter (fun c -> add_int64 buffer (Int64.of_int (Char.code c))) input;
  let bytes = Bytes.of_string (Buffer.contents buffer) in
  String.init (String.length input) (fun i ->
      Char.chr (Int64.to_int (get_int64 bytes (8 * i))))

let suites =
  Mt.[
    ("Buffer.add_int64_be encodes H", fun () ->
      let buffer = Buffer.create 8 in
      Buffer.add_int64_be buffer 72L;
      Eq (Buffer.contents buffer, "\x00\x00\x00\x00\x00\x00\x00\x48"));
    ("Bytes.set_int64_be encodes H", fun () ->
      let bytes = Bytes.create 8 in
      Bytes.set_int64_be bytes 0 72L;
      Eq (Bytes.to_string bytes, "\x00\x00\x00\x00\x00\x00\x00\x48"));
    ("Bytes.get_int64_be decodes H", fun () ->
      let bytes = Bytes.of_string "\x00\x00\x00\x00\x00\x00\x00\x48" in
      Eq (Bytes.get_int64_be bytes 0, 72L));
    ("Bytes.get_int64_le decodes H", fun () ->
      let bytes = Bytes.of_string "\x48\x00\x00\x00\x00\x00\x00\x00" in
      Eq (Bytes.get_int64_le bytes 0, 72L));
    ("Bytes.int64_be_roundtrip", fun () ->
      let bytes = Bytes.create 8 in
      Bytes.set_int64_be bytes 0 72L;
      Eq (Bytes.get_int64_be bytes 0, 72L));
    ("Bytes.get_int64_le third byte", fun () ->
      let bytes = Bytes.of_string "\x00\x00\x01\x00\x00\x00\x00\x00" in
      Eq (Bytes.get_int64_le bytes 0, 0x0000000000010000L));
    ("Bytes.get_int64_le all bytes", fun () ->
      let bytes = Bytes.of_string "\x08\x07\x06\x05\x04\x03\x02\x01" in
      Eq (Bytes.get_int64_le bytes 0, 0x0102030405060708L));
    ("Bytes.get_int64_be all bytes", fun () ->
      let bytes = Bytes.of_string "\x01\x02\x03\x04\x05\x06\x07\x08" in
      Eq (Bytes.get_int64_be bytes 0, 0x0102030405060708L));
    ("int64_be_string_roundtrip", fun () ->
      Eq
        (string_roundtrip Buffer.add_int64_be Bytes.get_int64_be "Hello World!",
         "Hello World!"));
    ("int64_le_string_roundtrip", fun () ->
      Eq
        (string_roundtrip Buffer.add_int64_le Bytes.get_int64_le "Hello World!",
         "Hello World!"));
  ]

let () = Mt.from_pair_suites __MODULE__ suites
