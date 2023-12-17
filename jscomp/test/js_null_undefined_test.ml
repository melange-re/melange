open Js.Nullable

let suites = Mt.[
  "toOption - null", (fun _ -> Eq(None, null |> toOption));
  "toOption - undefined", (fun _ -> Eq(None, undefined |> toOption));
  "toOption - empty", (fun _ -> Eq(None, undefined |> toOption));
  __LOC__, (fun _ -> Eq(Some "foo", return "foo" |> toOption));
  "return", (fun _ -> Eq(Some "something", return "something" |> toOption));
  "test - null", (fun _ -> Eq(true, null |> isNullable));
  "test - undefined", (fun _ -> Eq(true, undefined |> isNullable));
  "test - empty", (fun _ -> Eq(true, undefined |> isNullable));
  __LOC__, (fun _ -> Eq(true, return () |> isNullable));
  "map - null", (fun _ -> StrictEq(null, map null ~f:((fun v -> v) [@u])));
  "map - undefined", (fun _ -> StrictEq(undefined, map undefined ~f:((fun v -> v) [@u])));
  "map - empty", (fun _ -> StrictEq(undefined, map undefined ~f:((fun v -> v) [@u])));
  "map - 'a", (fun _ -> Eq(return 4, map (return 2) ~f:((fun n -> n * 2) [@u])));
  "iter - null", (fun _ ->
    let hit = ref false in
    let _ = iter null ~f:((fun _ -> hit := true) [@u]) in
    Eq(false, !hit)
  );
  "iter - undefined", (fun _ ->
    let hit = ref false in
    let _ = iter undefined ~f:((fun _ -> hit := true) [@u]) in
    Eq(false, !hit)
  );
  "iter - empty", (fun _ ->
    let hit = ref false in
    let _ = iter undefined ~f:((fun _ -> hit := true) [@u]) in
    Eq(false, !hit)
  );
  "iter - 'a", (fun _ ->
    let hit = ref 0 in
    let _ = iter (return 2) ~f:((fun v -> hit := v) [@u]) in
    Eq(2, !hit)
  );
  "fromOption - None", (fun _ -> Eq(undefined, None |> fromOption));
  "fromOption - Some", (fun _ -> Eq(return 2, Some 2 |> fromOption));
  "null <> undefined", (fun _ -> Ok(null <> undefined));
  "null <> empty", (fun _ -> Ok(null <> undefined));
  "undefined = empty", (fun _ -> Ok(undefined = undefined));
  __LOC__, (fun _ ->
    Ok(
      let null =3 in
      not (Js.isNullable (Js.Nullable.return null ))
    )
  )
]
;; Mt.from_pair_suites __MODULE__ suites
