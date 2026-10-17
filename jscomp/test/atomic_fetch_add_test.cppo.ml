#if OCAML_VERSION >= (5, 6, 0)

type counter = {
  before : int;
  mutable value : int [@atomic];
  after : int;
}

type renamed = {
  mutable count : int [@atomic] [@mel.as "data-count"];
}

type numeric_name = {
  mutable count : int [@atomic] [@mel.as "2"];
}

type inline =
  | Counter of { before : int; mutable value : int [@atomic] }
  | Other of int

type extensible = ..
type extensible +=
  | Extended of { before : int; mutable value : int [@atomic] }

(* Read the actual JavaScript property independently of the atomic location.
   Atomic field loads are not yet supported by the backend. *)
external get_value : 'a -> int = "value" [@@mel.get]
external get_count : renamed -> int = "data-count" [@@mel.get]
external get_numeric_count : numeric_name -> int = "2" [@@mel.get]
external fetch_ref : int Atomic.t -> int -> int = "%atomic_fetch_add"
external fetch_field : int array -> int -> int -> int = "%atomic_fetch_add_field"
external array_location : int array -> int -> int Atomic.Loc.t =
  "%atomic_unsafe_index"

let suites = Mt.[
  "record_field", (fun () ->
    let c : counter = { before = 7; value = 41; after = 9 } in
    let old = Atomic.Loc.fetch_and_add [%atomic.loc c.value] 1 in
    Eq ((old, get_value c, c.before, c.after), (41, 42, 7, 9)));
  "escaped_locations_with_different_field_names", (fun () ->
    let c : counter = { before = 7; value = 41; after = 9 } in
    let renamed : renamed = { count = 10 } in
    let locations = [ [%atomic.loc c.value]; [%atomic.loc renamed.count] ] in
    List.iter Atomic.Loc.incr locations;
    List.iter Atomic.Loc.decr locations;
    List.iter Atomic.Loc.incr locations;
    Eq ((get_value c, get_count renamed), (42, 11)));
  "renamed_field", (fun () ->
    let c : renamed = { count = 41 } in
    let old = Atomic.Loc.fetch_and_add [%atomic.loc c.count] 1 in
    Eq ((old, get_count c), (41, 42)));
  "numeric_property_name", (fun () ->
    let c : numeric_name = { count = 41 } in
    let old = Atomic.Loc.fetch_and_add [%atomic.loc c.count] 1 in
    Eq ((old, get_numeric_count c), (41, 42)));
  "inline_record", (fun () ->
    let value = Counter { before = 7; value = 41 } in
    let old = match value with
      | Counter c -> Atomic.Loc.fetch_and_add [%atomic.loc c.value] 1
      | Other _ -> assert false
    in
    Eq ((old, get_value value), (41, 42)));
  "extension_record", (fun () ->
    let value = Extended { before = 7; value = 41 } in
    let old = match value with
      | Extended c -> Atomic.Loc.fetch_and_add [%atomic.loc c.value] 1
      | _ -> assert false
    in
    Eq ((old, get_value value), (41, 42)));
  "record_arguments_evaluated_once", (fun () ->
    let c : counter = { before = 7; value = 41; after = 9 } in
    let receivers = ref 0 and increments = ref 0 in
    let receiver () = incr receivers; c in
    let increment () = incr increments; 1 in
    let old =
      Atomic.Loc.fetch_and_add [%atomic.loc (receiver ()).value] (increment ())
    in
    Eq ((old, get_value c, !receivers, !increments), (41, 42, 1, 1)));
  "record_wraparound", (fun () ->
    let c : counter = { before = 7; value = max_int; after = 9 } in
    let loc = [%atomic.loc c.value] in
    let upper = Atomic.Loc.fetch_and_add loc 1 in
    let wrapped = get_value c in
    let lower = Atomic.Loc.fetch_and_add loc (-1) in
    Eq ((upper, wrapped, lower, get_value c),
        (max_int, min_int, min_int, max_int)));
  "atomic_reference_primitive", (fun () ->
    let a = Atomic.make 41 in
    let old = fetch_ref a 1 in
    Eq ((old, Atomic.get a), (41, 42)));
  "first_class_atomic_reference_primitive", (fun () ->
    let a = Atomic.make max_int in
    let functions = [| fetch_ref |] in
    let old = functions.(0) a 1 in
    Eq ((old, Atomic.get a), (max_int, min_int)));
  "array_location", (fun () ->
    let a = [| 7; 41; 9 |] in
    let loc = array_location a 1 in
    let old = Atomic.Loc.fetch_and_add loc 1 in
    Atomic.Loc.incr loc;
    Atomic.Loc.decr loc;
    Eq ((old, a), (41, [| 7; 42; 9 |])));
  "array_arguments_evaluated_once", (fun () ->
    let a = [| 7; 41; 9 |] in
    let receivers = ref 0 and indices = ref 0 and increments = ref 0 in
    let receiver () = incr receivers; a in
    let index () = incr indices; 1 in
    let increment () = incr increments; 1 in
    let old = fetch_field (receiver ()) (index ()) (increment ()) in
    Eq ((old, a, !receivers, !indices, !increments),
        (41, [| 7; 42; 9 |], 1, 1, 1)));
]

let () = Mt.from_pair_suites __MODULE__ suites

#endif
