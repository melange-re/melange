open Mt

module A = Atomic.Array

let invalid_argument_message f =
  match f () with
  | () -> None
  | exception Invalid_argument message -> Some message

let array_contents a = Array.init (A.length a) (A.get a)

let suites = [
  "atomic_update", (fun () ->
    let a = Atomic.make 2 in
    Atomic.update (fun x -> x * 3) a;
    Eq (Atomic.get a, 6));
  "atomic_update_retry", (fun () ->
    let a = Atomic.make 0 in
    let seen = ref [] in
    Atomic.update (fun x ->
      seen := x :: !seen;
      if x = 0 then Atomic.set a 10;
      x + 1) a;
    Eq ((List.rev !seen, Atomic.get a), ([0; 10], 11)));
  "atomic_update_physical_equality_does_not_store", (fun () ->
    let original = ref 0 in
    let replacement = ref 1 in
    let a = Atomic.make original in
    let calls = ref 0 in
    Atomic.update (fun old ->
      incr calls;
      Atomic.set a replacement;
      old) a;
    Eq ((!calls, Atomic.get a == replacement), (1, true)));
  "atomic_update_structural_equality_still_stores", (fun () ->
    let original = ref 0 in
    let replacement = ref 0 in
    let a = Atomic.make original in
    Atomic.update (fun _ -> replacement) a;
    Ok (Atomic.get a == replacement));
  "atomic_update_exception", (fun () ->
    let a = Atomic.make 7 in
    let error = invalid_argument_message (fun () ->
      Atomic.update (fun _ -> invalid_arg "callback") a) in
    Eq ((error, Atomic.get a), (Some "callback", 7)));
  "atomic_incr_decr_wraparound", (fun () ->
    let a = Atomic.make max_int in
    Atomic.incr a;
    let wrapped = Atomic.get a in
    Atomic.decr a;
    Eq ((wrapped, Atomic.get a), (min_int, max_int)));
  "array_make_shares_initial_value", (fun () ->
    let value = ref 1 in
    let a = A.make 3 value in
    value := 2;
    Ok (A.length a = 3 && A.get a 0 == value && A.get a 2 == value
        && !(A.get a 1) = 2));
  "array_get_set_exchange", (fun () ->
    let a = A.make 2 3 in
    A.set a 0 7;
    let old = A.exchange a 1 9 in
    Eq ((old, array_contents a), (3, [|7; 9|])));
  "array_compare_and_set_is_physical", (fun () ->
    let original = ref 1 in
    let equal_but_distinct = ref 1 in
    let replacement = ref 2 in
    let a = A.make 1 original in
    let failed = A.compare_and_set a 0 equal_but_distinct replacement in
    let unchanged = A.get a 0 == original in
    let succeeded = A.compare_and_set a 0 original replacement in
    Eq ((failed, unchanged, succeeded, A.get a 0 == replacement),
        (false, true, true, true)));
  "array_fetch_and_add_wraparound", (fun () ->
    let a = A.make 1 max_int in
    let before = A.fetch_and_add a 0 1 in
    let wrapped = A.get a 0 in
    let before_decrement = A.fetch_and_add a 0 (-1) in
    Eq ((before, wrapped, before_decrement, A.get a 0),
        (max_int, min_int, min_int, max_int)));
  "array_update_retry", (fun () ->
    let a = A.make 2 0 in
    let seen = ref [] in
    A.update (fun x ->
      seen := x :: !seen;
      if x = 0 then A.set a 1 10;
      x + 1) a 1;
    Eq ((List.rev !seen, array_contents a), ([0; 10], [|0; 11|])));
  "array_update_physical_equality_does_not_store", (fun () ->
    let original = ref 0 in
    let replacement = ref 1 in
    let a = A.make 1 original in
    let calls = ref 0 in
    A.update (fun old ->
      incr calls;
      A.set a 0 replacement;
      old) a 0;
    Eq ((!calls, A.get a 0 == replacement), (1, true)));
  "array_update_structural_equality_still_stores", (fun () ->
    let replacement = ref 0 in
    let a = A.make 1 (ref 0) in
    A.update (fun _ -> replacement) a 0;
    Ok (A.get a 0 == replacement));
  "array_update_exception", (fun () ->
    let a = A.make 1 7 in
    let error = invalid_argument_message (fun () ->
      A.update (fun _ -> invalid_arg "callback") a 0) in
    Eq ((error, A.get a 0), (Some "callback", 7)));
  "array_unsafe_operations", (fun () ->
    let a = A.make 1 1 in
    A.unsafe_set a 0 2;
    let old = A.unsafe_exchange a 0 3 in
    let failed = A.unsafe_compare_and_set a 0 2 4 in
    let succeeded = A.unsafe_compare_and_set a 0 3 4 in
    let before = A.unsafe_fetch_and_add a 0 5 in
    A.unsafe_update (fun x -> x * 2) a 0;
    Eq ((old, failed, succeeded, before, A.unsafe_get a 0),
        (2, false, true, 4, 18)));
  "array_init_order", (fun () ->
    let seen = ref [] in
    let a = A.init 4 (fun i -> seen := i :: !seen; i * 2) in
    Eq ((List.rev !seen, array_contents a),
        ([0; 1; 2; 3], [|0; 2; 4; 6|])));
  "array_empty_init_does_not_call_callback", (fun () ->
    let a = A.init 0 (fun _ -> failwith "unexpected callback") in
    Eq ((A.length a, A.length (A.make 0 42)), (0, 0)));
  "array_negative_lengths", (fun () ->
    let calls = ref 0 in
    let make_error = invalid_argument_message (fun () ->
      ignore (A.make (-1) 0)) in
    let init_error = invalid_argument_message (fun () ->
      ignore (A.init (-1) (fun _ -> incr calls; 0))) in
    Eq ((make_error, init_error, !calls),
        (Some "Atomic.Array.make", Some "Atomic_array.init", 0)));
  "hash_variant_known_values", (fun () ->
    Eq (List.map Obj.hash_variant
          [""; "A"; "foo"; "xxyyzzuuxxzzyy00112233"; "xxyyzxzzyy"],
        [0; 65; 5097222; 544087776; -449896130]));
]

let bounds_suites =
  let operations = [
    "get", (fun a i _ -> ignore (A.get a i));
    "set", (fun a i _ -> A.set a i 20);
    "exchange", (fun a i _ -> ignore (A.exchange a i 20));
    "compare_and_set", (fun a i _ ->
      ignore (A.compare_and_set a i 10 20));
    "fetch_and_add", (fun a i _ -> ignore (A.fetch_and_add a i 1));
    "update", (fun a i calls ->
      A.update (fun x -> incr calls; x + 1) a i);
  ] in
  List.concat_map (fun (name, operation) ->
    List.map (fun (length, index) ->
      "array_" ^ name ^ "_bounds_" ^ string_of_int length
        ^ "_" ^ string_of_int index,
      (fun () ->
        let a = A.make length 10 in
        let calls = ref 0 in
        let error = invalid_argument_message (fun () ->
          operation a index calls) in
        Eq ((error, !calls, array_contents a),
            (Some "index out of bounds", 0, Array.make length 10))))
      [0, -1; 0, 0; 2, -1; 2, 2]) operations

let () = from_pair_suites __MODULE__ (suites @ bounds_suites)
