[@@@ocaml.warning "-3"]

let suites = Mt.[
    (* es2015, unable to test because nothing currently implements array_like
    "from", (fun _ ->
      Eq(
        [| 0; 1 |],
        [| "a"; "b" |] |. Js.Array.keys |. Js.Array.from)
    );
    *)

    (* es2015, unable to test because nothing currently implements array_like
    "fromMap", (fun _ ->
      Eq(
        [| (-1); 0 |],
        Js.Array.fromMap
          ([| "a"; "b" |] |. Js.Array.keys)
          ((fun x -> x - 1) [@u]))
    );
    *)

    (* es2015 *)
    "isArray_array", (fun _ ->
      Eq(true, [||] |. Js.Array.isArray)
    );
    "isArray_int", (fun _ ->
      Eq(false, 34 |. Js.Array.isArray)
    );

    "length", (fun _ ->
      Eq(3, [| 1; 2; 3 |] |. Js.Array.length)
    );

    (* es2015 *)
    "copyWithin", (fun _ ->
      Eq([| 1; 2; 3; 1; 2 |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.copyWithin ~to_:(-2))
    );
    "copyWithinFrom", (fun _ ->
      Eq([| 4; 5; 3; 4; 5 |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.copyWithin ~to_:0 ~start:3)
    );
    "copyWithinFromRange", (fun _ ->
      Eq([| 4; 2; 3; 4; 5 |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.copyWithin ~to_:0 ~start:3 ~end_:4)
    );

    (* es2015 *)
    "fillInPlace", (fun _ ->
      Eq([| 4; 4; 4 |],
         [| 1; 2; 3 |] |. Js.Array.fill ~value:4)
    );
    "fillFromInPlace", (fun _ ->
      Eq([| 1; 4; 4 |],
         [| 1; 2; 3 |] |. Js.Array.fill ~value:4 ~start:1)
    );
    "fillRangeInPlace", (fun _ ->
      Eq([| 1; 4; 3 |],
         [| 1; 2; 3 |] |. Js.Array.fill ~value:4 ~start:1 ~end_:2)
    );

    "pop", (fun _ ->
      Eq(Some 3, [| 1; 2; 3 |] |. Js.Array.pop)
    );
    "pop - empty array", (fun _ ->
      Eq(None, [||] |. Js.Array.pop)
    );
    "push", (fun _ ->
      Eq(4, [| 1; 2; 3 |] |. Js.Array.push ~value:4)
    );
    "pushMany", (fun _ ->
      Eq(5, [| 1; 2; 3 |] |. Js.Array.pushMany ~values:[| 4; 5 |])
    );

    "reverseInPlace", (fun _ ->
      Eq([| 3; 2; 1 |],
         [| 1; 2; 3 |] |. Js.Array.reverseInPlace)
    );

    "shift", (fun _ ->
      Eq(Some 1, [| 1; 2; 3 |] |. Js.Array.shift)
    );
    "shift - empty array", (fun _ ->
      Eq(None, [||] |. Js.Array.shift)
    );

    "sortInPlace", (fun _ ->
      Eq([| 1; 2; 3 |],
         [| 3; 1; 2 |] |. Js.Array.sortInPlace)
    );
    "sortInPlaceWith", (fun _ ->
      Eq([| 3; 2; 1 |],
         [| 3; 1; 2 |] |. Js.Array.sortInPlaceWith ~f:((fun a b -> b - a) ))
    );

    "spliceInPlace", (fun _ ->
      let arr = [| 1; 2; 3; 4 |] in
      let removed = arr |. Js.Array.spliceInPlace ~start:2 ~remove:0 ~add:[| 5 |] in

      Eq(([| 1; 2; 5; 3; 4 |], [||]), (arr, removed))
    );
    "removeFromInPlace", (fun _ ->
      let arr = [| 1; 2; 3; 4 |] in
      let removed = arr |. Js.Array.removeFromInPlace ~start:2 in

      Eq(([| 1; 2 |], [| 3; 4 |]), (arr, removed))
    );
    "removeCountInPlace", (fun _ ->
      let arr = [| 1; 2; 3; 4 |] in
      let removed = arr |. Js.Array.removeCountInPlace ~start:2 ~count:1 in

      Eq(([| 1; 2; 4 |], [| 3 |]), (arr, removed))
    );

    "unshift", (fun _ ->
      Eq(4, [| 1; 2; 3 |] |. Js.Array.unshift ~value:4)
    );
    "unshiftMany", (fun _ ->
      Eq(5, [| 1; 2; 3 |] |. Js.Array.unshiftMany ~values:[| 4; 5 |])
    );

    "append", (fun _ ->
      Eq([| 1; 2; 3; 4 |],
         [| 1; 2; 3 |] |. Js.Array.concat ~other:[|4|])
    );
    "concat", (fun _ ->
      Eq([| 1; 2; 3; 4; 5 |],
         [| 1; 2; 3 |] |. Js.Array.concat ~other:[| 4; 5 |])
    );
    "concatMany", (fun _ ->
      Eq([| 1; 2; 3; 4; 5; 6; 7 |],
         [| 1; 2; 3 |] |. Js.Array.concatMany ~arrays:[| [| 4; 5; |]; [| 6; 7; |] |])
    );

    (* es2016 *)
    "includes", (fun _ ->
      Eq(true, [| 1; 2; 3 |] |. Js.Array.includes ~value:3)
    );

    "indexOf", (fun _ ->
      Eq(1, [| 1; 2; 3 |] |. Js.Array.indexOf ~value:2)
    );
    "indexOfFrom", (fun _ ->
      Eq(3, [| 1; 2; 3; 2 |] |. Js.Array.indexOf ~value:2 ~start:2)
    );

    "join", (fun _ ->
      Eq("1,2,3", [| 1; 2; 3 |] |. Js.Array.join ~sep:",")
    );
    "joinWith", (fun _ ->
      Eq("1;2;3", [| 1; 2; 3 |] |. Js.Array.join ~sep:";")
    );

    "lastIndexOf", (fun _ ->
      Eq(1, [| 1; 2; 3 |] |. Js.Array.lastIndexOf ~value:2 )
    );
    "lastIndexOfFrom", (fun _ ->
      Eq(1, [| 1; 2; 3; 2 |] |. Js.Array.lastIndexOfFrom ~value:2 ~start:2 )
    );

    "slice", (fun _ ->
      Eq([| 2; 3; |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.slice ~start:1 ~end_:3)
    );
    "copy", (fun _ ->
      Eq([| 1; 2; 3; 4; 5 |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.copy)
    );
    "sliceFrom", (fun _ ->
      Eq([| 3; 4; 5 |],
         [| 1; 2; 3; 4; 5 |] |. Js.Array.slice ~start:2)
    );

    "toString", (fun _ ->
      Eq("1,2,3", [| 1; 2; 3 |] |. Js.Array.toString)
    );
    "toLocaleString", (fun _ ->
      Eq("1,2,3", [| 1; 2; 3 |] |. Js.Array.toLocaleString)
    );

    (* es2015, iterator
    "entries", (fun _ ->
      Eq([| (0, "a"); (1, "b"); (2, "c") |],
         [| "a"; "b"; "c" |] |. Js.Array.entries |. Js.Array.from)
    );
    *)

    "every", (fun _ ->
      Eq(true, [| 1; 2; 3 |] |. Js.Array.every ~f:((fun n ->  (n > 0)) ))
    );
    "everyi", (fun _ ->
      Eq(false, [| 1; 2; 3 |] |. Js.Array.everyi ~f:((fun _ i ->  (i > 0)) ))
    );

    "filter", (fun _ ->
      Eq([| 2; 4 |],
         [| 1; 2; 3; 4 |] |. Js.Array.filter ~f:((fun n -> n mod 2 = 0) ))
    );
    "filteri", (fun _ ->
      Eq([| 1; 3 |],
         [| 1; 2; 3; 4 |] |. Js.Array.filteri ~f:((fun _ i ->  (i mod 2 = 0)) ))
    );

    (* es2015 *)
    "find", (fun _ ->
      Eq(Some 2, [| 1; 2; 3; 4 |] |. Js.Array.find ~f:((fun n -> n mod 2 = 0) ))
    );
    "find - no match", (fun _ ->
      Eq(None, [| 1; 2; 3; 4 |] |. Js.Array.find ~f:((fun n -> n mod 2 = 5) ))
    );
    "findi", (fun _ ->
      Eq(Some 1, [| 1; 2; 3; 4 |] |. Js.Array.findi ~f:((fun _ i -> i mod 2 = 0) ))
    );
    "findi - no match", (fun _ ->
      Eq(None, [| 1; 2; 3; 4 |] |. Js.Array.findi ~f:((fun _ i -> i mod 2 = 5) ))
    );

    (* es2015 *)
    "findIndex", (fun _ ->
      Eq(1, [| 1; 2; 3; 4 |] |. Js.Array.findIndex ~f:((fun n -> n mod 2 = 0) ))
    );
    "findIndexi", (fun _ ->
      Eq(0, [| 1; 2; 3; 4 |] |. Js.Array.findIndexi ~f:((fun _ i -> i mod 2 = 0) ))
    );

    "forEach", (fun _ ->
      let sum = ref 0 in
      let _ = [| 1; 2; 3; |] |. Js.Array.forEach ~f:((fun n -> sum := !sum + n) ) in

      Eq(6, !sum)
    );
    "forEachi", (fun _ ->
      let sum = ref 0 in
      let _ = [| 1; 2; 3; |] |. Js.Array.forEachi ~f:((fun _ i -> sum := !sum + i) ) in

      Eq(3, !sum)
    );

    (* es2015, iterator
    "keys", (fun _ ->
      Eq([| 0; 1; 2 |],
         [| "a"; "b"; "c" |] |. Js.Array.keys |. Js.Array.from)
    );
    *)

    "map", (fun _ ->
      Eq([| 2; 4; 6; 8 |],
         [| 1; 2; 3; 4 |] |. Js.Array.map ~f:((fun n -> n * 2) ))
    );
    "map", (fun _ ->
      Eq([| 0; 2; 4; 6 |],
         [| 1; 2; 3; 4 |] |. Js.Array.mapi ~f:((fun _ i -> i * 2) ))
    );

    "reduce", (fun _ ->
      Eq(-10,
         [| 1; 2; 3; 4 |] |. Js.Array.reduce ~f:((fun acc n -> acc - n) ) ~init:0)
    );
    "reducei", (fun _ ->
      Eq(-6,
         [| 1; 2; 3; 4 |] |. Js.Array.reducei ~f:((fun acc _ i -> acc - i) ) ~init:0)
    );

    "reduceRight", (fun _ ->
      Eq(-10, [| 1; 2; 3; 4 |] |. Js.Array.reduceRight ~f:((fun acc n -> acc - n) ) ~init:0)
    );
    "reduceRighti", (fun _ ->
      Eq(-6, [| 1; 2; 3; 4 |] |. Js.Array.reduceRighti ~f:((fun acc _ i -> acc - i) ) ~init:0)
    );

    "some", (fun _ ->
      Eq(false, [| 1; 2; 3; 4 |] |. Js.Array.some ~f:((fun n ->  (n <= 0)) ))
    );
    "somei", (fun _ ->
      Eq(true, [| 1; 2; 3; 4 |] |. Js.Array.somei ~f:((fun _ i ->  (i <= 0)) ))
    );

    (* es2015, iterator
    "values", (fun _ ->
      Eq([| "a"; "b"; "c" |],
         [| "a"; "b"; "c" |] |. Js.Array.values |. Js.Array.from)
    );
    *)
]

;; Mt.from_pair_suites __MODULE__ suites
