open Js.Undefined

let suites = Mt.[
  "toOption - empty", (fun _ -> Eq(None, empty |> toOption));
  __LOC__, (fun _ -> Eq(None, return () |> toOption));
  "return", (fun _ -> Eq(Some "something", return "something" |> toOption));
  "test - empty", (fun _ -> Eq(true, empty = Js.undefined));
  __LOC__, (fun _ -> Eq(true, return () = Js.undefined));
  "bind - empty", (fun _ -> Eq(empty, bind empty ~f:((fun v -> v) [@u])));
  "map - 'a", (fun _ -> Eq(return 4, map (return 2) ~f:((fun n -> n * 2) [@u])));
  "iter - empty", (fun _ ->
    let hit = ref false in
    let _ = iter empty ~f:((fun _ -> hit := true) [@u]) in
    Eq(false, !hit)
  );
  "iter - 'a", (fun _ ->
    let hit = ref 0 in
    let _ = iter (return 2) ~f:((fun v -> hit := v) [@u]) in
    Eq(2, !hit)
  );
  "fromOption - None", (fun _ -> Eq(empty, None |> fromOption));
  "fromOption - Some", (fun _ -> Eq(return 2, Some 2 |> fromOption));
]
;; Mt.from_pair_suites __MODULE__ suites
