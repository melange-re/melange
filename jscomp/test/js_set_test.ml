let suites = Mt.[
    "fromArray/toArray", (fun _ ->
      let set = Js.Set.fromArray [|1;2;3|] in
      Eq([|1;2;3;|], Js.Set.toArray set)
    );
    "size - empty set", (fun _ ->
      let set = Js.Set.make () in
      Eq(0, Js.Set.size set)
    );
    "size", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"; "two"|] in
      Eq(2, Js.Set.size set)
    );
    "size - with duplicates", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "one"|] in
      Eq(1, Js.Set.size set)
    );
    "has - true", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"|] in
      Eq(true, Js.Set.has set ~value:"two")
    );
    "has - false", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"|] in
      Eq(false, Js.Set.has set ~value:"three")
    );
    "delete", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"|] in
      let deleted = Js.Set.delete set ~value:"two" in
      Eq((true, false), (deleted, Js.Set.has set ~value:"two"))
    );
    "add", (fun _ ->
      let set = Js.Set.(make () |> add ~value:"one" |> add ~value:"two" ) in
      Eq([|"one"; "two"|], Js.Set.toArray set)
    );
    "clear", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"|] in
      Js.Set.clear set;
      Eq(0, Js.Set.size set)
    );
    "add mutate + return new set", (fun _ ->
      (* demonstrate that [add] returns a new set + mutates the original one. *)
      let set_1 = Js.Set.make () in
      let set_2 = Js.Set.add ~value:"one" set_1 in
      let set_3 = Js.Set.add ~value:"two" set_2 in
      let all_same_size = 
        let size = 2 in
        Js.Set.size set_1 = size && Js.Set.size set_2 = size && Js.Set.size set_3 = size in
      let all_same_ref = set_1 == set_2 && set_2 == set_3 in
      Eq((true, true), (all_same_size, all_same_ref))
    );
    "forEach", (fun _ ->
      let set = Js.Set.fromArray [|"one"; "two"|] in
      let arr = ref([||]) in
      set |> Js.Set.forEach ~f:(fun value -> let (_i: int) = Js.Array.push !arr ~value in ());
      Eq([|"one"; "two"|], !arr)
    );
]

;; Mt.from_pair_suites __MODULE__ suites
