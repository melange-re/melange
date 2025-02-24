let suites = Mt.[
    "add", (fun _ ->
      let value = Js.Dict.empty () in
      let weakset = Js.WeakSet.(make () |> add ~value) in
      Eq(true, Js.WeakSet.has ~value weakset)
    );
    "delete - true", (fun _ ->
      let value = Js.Dict.empty () in
      let weakset = Js.WeakSet.(make () |> add ~value) in
      let deleted = Js.WeakSet.delete ~value weakset in
      Eq((true, false), (deleted, Js.WeakSet.has ~value weakset))
    );
    "delete - false", (fun _ ->
      let a = Js.Dict.empty () in
      let b = Js.Dict.empty () in
      let weakset = Js.WeakSet.(make () |> add ~value:a) in
      let deleted = Js.WeakSet.delete ~value:b weakset in
      Eq(false, deleted)
    );
    "has", (fun _ ->
      let a = Js.Dict.empty () in
      let b = Js.Dict.empty () in
      let weakset = Js.WeakSet.(make () |> add ~value:a |> add ~value:b) in
      let has_b_before = Js.WeakSet.has ~value:b weakset in
      let _deleted = Js.WeakSet.delete ~value:b weakset in
      let has_b_after = Js.WeakSet.has ~value:b weakset in
      Eq((has_b_before, has_b_after), (true, false))
    );
    "add mutate + return new weakset", (fun _ ->
      (* demonstrate that [add] returns a new weakset + mutates the original one. *)
      let a = Js.Dict.empty () in
      let b = Js.Dict.empty () in
      let weakset_1 = Js.WeakSet.make () in
      let weakset_2 = Js.WeakSet.add ~value:a weakset_1 in
      let weakset_3 = Js.WeakSet.add ~value:b weakset_2 in
      let all_has_b = 
        Js.WeakSet.has ~value:b weakset_1 = true 
          && Js.WeakSet.has ~value:b weakset_2 && Js.WeakSet.has ~value:b weakset_3 in
      let all_same_ref = weakset_1 == weakset_2 && weakset_2 == weakset_3 in
      Eq((true, true), (all_has_b, all_same_ref))
    );
    "record", (fun _ ->
      let value = Js.Dict.empty () in
      Js.Dict.set value "k" 1;
      let weakset = Js.WeakSet.(make () |> add ~value) in
      Eq(true, Js.WeakSet.has ~value weakset)
    );
]

;; Mt.from_pair_suites __MODULE__ suites
