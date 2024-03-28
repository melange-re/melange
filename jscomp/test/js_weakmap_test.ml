let suites = Mt.[
    "add", (fun _ ->
      let (key, value) = (Js.Dict.empty (), "value") in
      let weakmap = Js.WeakMap.(make () |> set ~key ~value) in
      Eq(true, Js.WeakMap.has ~key weakmap)
    );
    "delete - true", (fun _ ->
      let (key, value) = (Js.Dict.empty (), "value") in
      let weakmap = Js.WeakMap.(make () |> set ~key ~value) in
      let deleted = Js.WeakMap.delete ~key weakmap in
      Eq((true, false), (deleted, Js.WeakMap.has ~key weakmap))
    );
    "delete - false", (fun _ ->
      let (key, value) = (Js.Dict.empty (), "value") in
      let weakmap = Js.WeakMap.(make () |> set ~key ~value) in
      let deleted = Js.WeakMap.delete ~key:(Js.Dict.empty ()) weakmap in
      Eq(false, deleted)
    );
    "get", (fun _ ->
      let (key_a, value_a) = (Js.Dict.empty (), "value_a") in
      let (key_b, _) = (Js.Dict.empty (), "value_b") in
      let weakmap = Js.WeakMap.(make () |> set ~key:key_a ~value:value_a) in
      let a = Js.WeakMap.get ~key:key_a weakmap in
      let b = Js.WeakMap.get ~key:key_b weakmap in
      Eq((Some "value_a", None), (a, b))
    );
    "has", (fun _ ->
      let (key_a, value_a) = (Js.Dict.empty (),"value_a") in
      let (key_b, value_b) = (Js.Dict.empty (),"value_b") in
      let weakmap = Js.WeakMap.(make () 
        |> set ~key:key_a ~value:value_a 
        |> set ~key:key_b ~value:value_b) in
      let has_b_before = Js.WeakMap.has ~key:key_b weakmap in
      let _deleted = Js.WeakMap.delete ~key:key_b weakmap in
      let has_b_after = Js.WeakMap.has ~key:key_b weakmap in
      Eq((has_b_before, has_b_after), (true, false))
    );
    "set mutate + return new weakmap", (fun _ ->
      (* demonstrate that [set] returns a new weakmap + mutates the original one. *)
      let (key_a, value_a) = (Js.Dict.empty (), "value_a") in
      let (key_b, value_b) = (Js.Dict.empty (), "value_b") in
      let weakmap_1 = Js.WeakMap.make () in
      let weakmap_2 = Js.WeakMap.set ~key:key_a ~value:value_a weakmap_1 in
      let weakmap_3 = Js.WeakMap.set ~key:key_b ~value:value_b weakmap_2 in
      let all_has_b = 
        Js.WeakMap.has ~key:key_b weakmap_1 = true 
          && Js.WeakMap.has ~key:key_b weakmap_2 && Js.WeakMap.has ~key:key_b weakmap_3 in
      let all_same_ref = weakmap_1 == weakmap_2 && weakmap_2 == weakmap_3 in
      Eq((true, true), (all_has_b, all_same_ref))
    );
]

;; Mt.from_pair_suites __MODULE__ suites
