external get16u : string -> int -> int = "%caml_string_get16u"
external get32u : string -> int -> int32 = "%caml_string_get32u"
external get64u : string -> int -> int64 = "%caml_string_get64u"

let invalid f =
  match f () with
  | () -> false
  | exception Invalid_argument msg -> msg = "index out of bounds"

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "native-endian integer values", (fun () ->
    Eq ((0x6261, 0x61616161l, 0x3837363534333231L),
        (String.get_uint16_ne "ab" 0,
         String.get_int32_ne "aaaa" 0,
         String.get_int64_ne "12345678" 0)));
  "offsets and high bits", (fun () ->
    let s = "x\x10\x32\x54\x76\x98\xba\xdc\xfey" in
    Eq ((0x3210, 0xfedcba98l, 0xfedcba9876543210L),
        (String.get_uint16_ne s 1,
         String.get_int32_ne s 5,
         String.get_int64_ne s 1)));
  "unchecked primitives", (fun () ->
    let s = "x\xff\xff\xff\xff\xff\xff\xff\xff" in
    Eq ((65535, -1l, -1L), (get16u s 1, get32u s 1, get64u s 1)));
  "bounds", (fun () ->
    let readers = [
      2, (fun s i -> ignore (String.get_uint16_ne s i));
      4, (fun s i -> ignore (String.get_int32_ne s i));
      8, (fun s i -> ignore (String.get_int64_ne s i));
    ] in
    Ok (List.for_all (fun (width, read) ->
      let s = String.make width '\xff' in
      List.for_all (fun i -> invalid (fun () -> read s i))
        [-1; 1; max_int; min_int]
      && invalid (fun () -> read "" 0)
      && invalid (fun () -> read (String.make (width - 1) 'a') 0)
    ) readers));
]
