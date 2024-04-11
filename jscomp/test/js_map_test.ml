let suites = Mt.[
  "fromArray/toArray", (fun _ ->
    let array = [|(1, "a"); (2, "b"); (3, "c")|] in
    let map = Js.Map.fromArray array in
    Eq(array, Js.Map.toArray map)
  );
  "size - empty map", (fun _ ->
    let map = Js.Map.make () in
    Eq(0, Js.Map.size map)
  );
  "size", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two"); (2, "two")|] in
    Eq(2, Js.Map.size map)
  );
  "size - with duplicates", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (1, "one")|] in
    Eq(1, Js.Map.size map)
  );
  "has - true", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    Eq(true, Js.Map.has map ~key:1)
  );
  "has - false", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    Eq(false, Js.Map.has map ~key:3)
  );
  "get", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    let one = map |> Js.Map.get ~key:1 in
    let two = map |> Js.Map.get ~key:2 in
    let three = map |> Js.Map.get ~key:3 in
    Eq([|Some "one"; Some "two"; None|], [|one; two; three|])
  );
  "set", (fun _ ->
    let map = Js.Map.(make () |> set ~key:1 ~value:"one" |> set ~key:2 ~value:"two" ) in
    Eq([|(1, "one"); (2, "two")|], Js.Map.toArray map)
  );
  "delete", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    let deleted = Js.Map.delete map ~key:2 in
    Eq((true, false), (deleted, Js.Map.has map ~key:2))
  );
  "clear", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    Js.Map.clear map;
    Eq(0, Js.Map.size map)
  );
  "set mutate + return new map", (fun _ ->
    (* demonstrate that [add] returns a new map + mutates the original one. *)
    let map_1 = Js.Map.make () in
    let map_2 = Js.Map.set ~key:1 ~value:"one" map_1 in
    let map_3 = Js.Map.set ~key:2 ~value:"two" map_2 in
    let all_same_size =
      let size = 2 in
      Js.Map.size map_1 = size && Js.Map.size map_2 = size && Js.Map.size map_3 = size in
    let all_same_ref = map_1 == map_2 && map_2 == map_3 in
    Eq((true, true), (all_same_size, all_same_ref))
  );
  "forEach", (fun _ ->
    let map = Js.Map.fromArray [|(1, "one"); (2, "two")|] in
    let arr = ref [||] in
    map |> Js.Map.forEach ~f:(fun value key _ ->
      let _ = Js.Array.push !arr ~value:(key, value) in
      ());
    Eq([|(1, "one"); (2, "two")|], !arr)
  );
  "keys", (fun _ ->
    let keys = Js.Map.fromArray [|(1, "one"); (2, "two")|] |> Js.Map.keys |> Js.Iterator.toArray in
    Eq([|1; 2|], keys)
  );
  "values", (fun _ ->
    let values = Js.Map.fromArray [|(1, "one"); (2, "two")|] |> Js.Map.values |> Js.Iterator.toArray in
    Eq([|"one"; "two"|], values)
  );
  "entries", (fun _ ->
    let array = [|(1, "one"); (2, "two")|] in
    let entries = Js.Map.fromArray array |> Js.Map.entries |> Js.Iterator.toArray in
    Eq(array, entries))
]

;; Mt.from_pair_suites __MODULE__ suites
