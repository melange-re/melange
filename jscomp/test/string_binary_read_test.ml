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

let readers = [
  (fun s i -> string_of_int (String.get_int8 s i)),
  (fun b i -> string_of_int (Bytes.get_int8 b i));
  (fun s i -> string_of_int (String.get_uint16_le s i)),
  (fun b i -> string_of_int (Bytes.get_uint16_le b i));
  (fun s i -> string_of_int (String.get_uint16_be s i)),
  (fun b i -> string_of_int (Bytes.get_uint16_be b i));
  (fun s i -> string_of_int (String.get_int16_ne s i)),
  (fun b i -> string_of_int (Bytes.get_int16_ne b i));
  (fun s i -> string_of_int (String.get_int16_le s i)),
  (fun b i -> string_of_int (Bytes.get_int16_le b i));
  (fun s i -> string_of_int (String.get_int16_be s i)),
  (fun b i -> string_of_int (Bytes.get_int16_be b i));
  (fun s i -> Int32.to_string (String.get_int32_le s i)),
  (fun b i -> Int32.to_string (Bytes.get_int32_le b i));
  (fun s i -> Int32.to_string (String.get_int32_be s i)),
  (fun b i -> Int32.to_string (Bytes.get_int32_be b i));
  (fun s i -> Int64.to_string (String.get_int64_le s i)),
  (fun b i -> Int64.to_string (Bytes.get_int64_le b i));
  (fun s i -> Int64.to_string (String.get_int64_be s i)),
  (fun b i -> Int64.to_string (Bytes.get_int64_be b i));
]

let outcome f x i =
  match f x i with
  | value -> Ok value
  | exception Invalid_argument msg -> Error msg

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "byte order, signs, and offsets", (fun () ->
    let s = "\x00\x7f\x80\xff\x10\x32\x54\x76\x98\xba\xdc\xfe" in
    let b = Bytes.of_string s in
    Ok (List.for_all (fun (read_string, read_bytes) ->
      List.for_all (fun i -> outcome read_string s i = outcome read_bytes b i)
        [-1; 0; 1; 4; 5; 8; 10; 11; 12]
    ) readers));
  "empty input and extreme offsets", (fun () ->
    Ok (List.for_all (fun (read, _) ->
      List.for_all (fun i -> outcome read "" i = Error "index out of bounds")
        [-1; 0; max_int; min_int]
    ) readers));
  "reads are bounded by integer width", (fun () ->
    let s = String.make 4096 'a' in
    let b = Bytes.of_string s in
    Ok (List.for_all (fun (read, read_bytes) ->
      let value, reads = count_reads s (fun [@u] () -> read s 100) in
      value = read_bytes b 100 && reads <= 8
    ) readers));
]
