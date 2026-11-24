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
  "empty input does not invoke predicates", (fun () ->
    let predicate _ = assert false in
    Eq ((false, true),
        (String.exists predicate "", String.for_all predicate "")));
  "left-to-right short circuit", (fun () ->
    let visited = ref [] in
    let p c = visited := c :: !visited; c = 'c' in
    let found = String.exists p "abcd" in
    let exists_visits = List.rev !visited in
    visited := [];
    let all = String.for_all (fun c -> not (p c)) "abcd" in
    Eq ((true, ['a'; 'b'; 'c'], false, ['a'; 'b'; 'c']),
        (found, exists_visits, all, List.rev !visited)));
  "full traversal and character values", (fun () ->
    let s = "\x00\x7f\x80\xff" in
    Ok (String.for_all (fun c -> Char.code c <= 255) s
        && not (String.exists (fun c -> c = 'a') s)
        && String.exists (fun c -> c = '\xff') s));
  "predicate exceptions propagate", (fun () ->
    let raises f = match f (fun _ -> raise Exit) "a" with
      | _ -> false | exception Exit -> true in
    Ok (raises String.exists && raises String.for_all));
  "early answers do not read the remaining input", (fun () ->
    let s = String.make 4096 'a' in
    let found, exists_reads = count_reads s (fun [@u] () ->
      String.exists (fun c -> c = 'a') s) in
    let all, for_all_reads = count_reads s (fun [@u] () ->
      String.for_all (fun c -> c <> 'a') s) in
    Ok (found && not all && exists_reads <= 1 && for_all_reads <= 1));
]
