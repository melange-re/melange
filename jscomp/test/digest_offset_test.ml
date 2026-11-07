let invalid f = match f () with
  | _ -> false
  | exception Invalid_argument _ -> true

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "substring offsets and lengths", (fun () ->
    let s = "XabcdefghijY" in
    Eq ("a925576942e94b2ef57a066101b48876",
        Digest.to_hex (Digest.substring s 1 10)));
  "subbytes offsets and lengths", (fun () ->
    let b = Bytes.of_string "XabcdefghijY" in
    Eq ("a925576942e94b2ef57a066101b48876",
        Digest.to_hex (Digest.subbytes b 1 10)));
  "block boundaries, suffixes, and empty slices", (fun () ->
    let b = Bytes.init 260 (fun i -> Char.chr ((i * 37) land 255)) in
    let s = Bytes.to_string b in
    Ok (List.for_all (fun (offset, len) ->
      let expected = Digest.string (Bytes.sub_string b offset len) in
      Digest.substring s offset len = expected
      && Digest.subbytes b offset len = expected
    ) [0, 0; 0, 260; 1, 10; 19, 0; 19, 1; 19, 55; 19, 56;
       19, 63; 19, 64; 19, 65; 19, 128; 200, 60; 260, 0]));
  "invalid slice bounds", (fun () ->
    let s = "abc" and b = Bytes.of_string "abc" in
    Ok (List.for_all (fun (offset, len) ->
      invalid (fun () -> Digest.substring s offset len)
      && invalid (fun () -> Digest.subbytes b offset len)
    ) [-1, 1; 0, -1; 4, 0; 2, 2; max_int, 1; 1, max_int]));
]
