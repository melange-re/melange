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

let () = Mt.from_pair_suites __MODULE__ Mt.[
  "empty sequences", (fun () ->
    Eq (([], []),
        (List.of_seq (String.to_seq ""), List.of_seq (String.to_seqi ""))));
  "character values and indices", (fun () ->
    let s = "\x00\x7f\x80\xff" in
    Eq (([0; 127; 128; 255], [(0, 0); (1, 127); (2, 128); (3, 255)]),
        (List.of_seq (Seq.map Char.code (String.to_seq s)),
         List.of_seq (Seq.map (fun (i, c) -> i, Char.code c) (String.to_seqi s)))));
  "sequences can be traversed repeatedly", (fun () ->
    let seq = String.to_seq "ab" and seqi = String.to_seqi "ab" in
    Eq ((['a'; 'b'], ['a'; 'b'], [(0, 'a'); (1, 'b')], [(0, 'a'); (1, 'b')]),
        (List.of_seq seq, List.of_seq seq, List.of_seq seqi, List.of_seq seqi)));
  "JavaScript UTF-16 code units", (fun () ->
    let s = {js|😺|js} in
    Eq ([0xd83d; 0xde3a], List.of_seq (Seq.map Char.code (String.to_seq s))));
  "construction and partial consumption are lazy", (fun () ->
    let s = String.make 4096 'a' in
    let seq, construction_reads = count_reads s (fun [@u] () -> String.to_seq s) in
    let seqi, indexed_construction_reads = count_reads s (fun [@u] () -> String.to_seqi s) in
    let first, first_reads = count_reads s (fun [@u] () -> seq ()) in
    let firsti, firsti_reads = count_reads s (fun [@u] () -> seqi ()) in
    let values = match first, firsti with
      | Seq.Cons ('a', _), Seq.Cons ((0, 'a'), _) -> true
      | _ -> false in
    Ok (values && construction_reads = 0 && indexed_construction_reads = 0
        && first_reads <= 1 && firsti_reads <= 1));
]
