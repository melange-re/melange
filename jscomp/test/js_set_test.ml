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
      let set = Js.Set.fromArray [|"one"; "two"|] in
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
    "difference", (fun _ ->
      let odds = Js.Set.fromArray [|1; 3; 5; 7; 9|] in
      let squares = Js.Set.fromArray [|1; 4; 9|] in
      Eq([|3; 5; 7|], Js.Set.difference odds ~other:squares |> Js.Set.toArray)
    );
]

;; Mt.from_pair_suites __MODULE__ suites
