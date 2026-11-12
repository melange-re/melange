let count_reads : bytes -> (bytes -> 'a [@u]) -> 'a * int = [%mel.raw {|
  function (source, run) {
    let reads = 0;
    const observed = new Proxy(source, {
      get(target, key, receiver) {
        if (typeof key === "string" && /^[0-9]+$/.test(key)) ++reads;
        return Reflect.get(target, key, receiver);
      }
    });
    return [run(observed), reads];
  }
|}]

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "only the requested bytes are read", (fun () ->
    let b = Bytes.make 8192 'a' in
    let expected = Digest.string "aaaaaaaaaa" in
    let digest, reads = count_reads b (fun [@u] b -> Digest.subbytes b 0 10) in
    Ok (digest = expected && reads <= 10));
  "nonzero offsets and conversion chunk boundaries", (fun () ->
    let b = Bytes.init 8192 (fun i -> Char.chr ((i * 37) land 255)) in
    Ok (List.for_all (fun (offset, len) ->
      let expected = Digest.string (Bytes.sub_string b offset len) in
      let digest, reads = count_reads b (fun [@u] b -> Digest.subbytes b offset len) in
      digest = expected && reads <= len
    ) [17, 0; 17, 1; 17, 10; 17, 1023; 17, 1024; 17, 1025;
       17, 4096; 4000, 4192; 8192, 0]));
  "full buffer conversion", (fun () ->
    let b = Bytes.init 8192 (fun i -> Char.chr (i land 255)) in
    Eq (Digest.string (Bytes.to_string b), Digest.subbytes b 0 (Bytes.length b)));
]
