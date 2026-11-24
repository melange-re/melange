let count_reads : string -> (unit -> 'a [@u]) -> 'a * int = [%mel.raw {|
  function (source, run) {
    const original = String.prototype.charCodeAt;
    let reads = 0;
    String.prototype.charCodeAt = function (i) {
      if (this.valueOf() === source) ++reads;
      return original.call(this, i);
    };
    try { return [run(), reads]; }
    finally { String.prototype.charCodeAt = original; }
  }
|}]

let codecs = [
  String.get_utf_8_uchar, Bytes.get_utf_8_uchar,
  String.is_valid_utf_8, Bytes.is_valid_utf_8;
  String.get_utf_16be_uchar, Bytes.get_utf_16be_uchar,
  String.is_valid_utf_16be, Bytes.is_valid_utf_16be;
  String.get_utf_16le_uchar, Bytes.get_utf_16le_uchar,
  String.is_valid_utf_16le, Bytes.is_valid_utf_16le;
]

let same_decodes s =
  let b = Bytes.of_string s in
  List.for_all (fun (decode, decode_bytes, valid, valid_bytes) ->
    let same = ref (valid s = valid_bytes b) in
    for i = 0 to String.length s - 1 do
      same := !same && decode s i = decode_bytes b i
    done;
    !same
  ) codecs

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "UTF boundaries, invalid sequences, and truncations", (fun () ->
    let cases = [
      ""; "abc"; "\x00\x7f"; "\xc2\x80"; "\xdf\xbf";
      "\xe0\xa0\x80"; "\xed\x9f\xbf"; "\xee\x80\x80"; "\xef\xbf\xbf";
      "\xf0\x90\x80\x80"; "\xf4\x8f\xbf\xbf";
      "\xc0\x80"; "\xc1\xbf"; "\xe0\x9f\xbf"; "\xed\xa0\x80";
      "\xf0\x8f\xbf\xbf"; "\xf4\x90\x80\x80"; "\xf5\x80\x80\x80";
      "\x80\xbf\xff"; "\xe1\x80\xe2\xf0\x91\x92\xf1\xbf\x41";
      "\xd8\x00\xdc\x00"; "\xdb\xff\xdf\xff";
      "\x00\xd8\x00\xdc"; "\xff\xdb\xff\xdf";
      "\xd8\x00\x00\x41"; "\xdc\x00"; "\x00\xdc";
    ] in
    Ok (List.for_all (fun s ->
      let result = ref true in
      for len = 0 to String.length s do
        let prefix = Bytes.sub_string (Bytes.of_string s) 0 len in
        result := !result && same_decodes prefix && same_decodes ("x" ^ prefix)
      done;
      !result
    ) cases));
  "all two-byte combinations", (fun () ->
    let result = ref true in
    let b = Bytes.create 2 in
    for first = 0 to 255 do
      for second = 0 to 255 do
        Bytes.set_uint8 b 0 first;
        Bytes.set_uint8 b 1 second;
        result := !result && same_decodes (Bytes.to_string b)
      done
    done;
    Ok !result);
  "invalid starting indices", (fun () ->
    let invalid decode s i = match decode s i with
      | _ -> false
      | exception Invalid_argument msg -> msg = "index out of bounds" in
    Ok (List.for_all (fun (decode, _, _, _) ->
      invalid decode "" 0 && List.for_all (invalid decode "abc")
        [-1; 3; max_int; min_int]
    ) codecs));
  "decoding reads at most four bytes", (fun () ->
    let s = String.make 4096 'a' in
    let b = Bytes.of_string s in
    Ok (List.for_all (fun (decode, decode_bytes, _, _) ->
      let value, reads = count_reads s (fun [@u] () -> decode s 100) in
      value = decode_bytes b 100 && reads <= 4
    ) codecs));
  "validators stop at invalid input", (fun () ->
    let tail = String.make 4096 'a' in
    Ok (List.for_all (fun (prefix, valid) ->
      let s = prefix ^ tail in
      let result, reads = count_reads s (fun [@u] () -> valid s) in
      not result && reads <= 4
    ) ["\xff", String.is_valid_utf_8;
       "\xdc\x00", String.is_valid_utf_16be;
       "\x00\xdc", String.is_valid_utf_16le]));
  "edit distance preprocessing reads input linearly", (fun () ->
    let s = String.make 256 'a' in
    let distance, reads = count_reads s (fun [@u] () -> String.edit_distance ~limit:1 s s) in
    Ok (distance = 0 && reads <= 4 * String.length s));
  "edit distance and spellchecking", (fun () ->
    let words = ["\xc3\xa9"; "a"; "\xc3\xa8"] in
    Eq ((1, ["\xc3\xa9"]),
        (String.edit_distance "\xc3\xa9" "\xc3\xa8",
         String.spellcheck (fun f -> List.iter f words) "\xc3\xa9")));
]
