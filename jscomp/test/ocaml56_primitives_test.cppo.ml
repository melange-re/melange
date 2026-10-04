#if OCAML_VERSION >= (5, 6, 0)

external int32_to_float : int32 -> float = "%int32_to_float"
external nativeint_of_float : float -> nativeint = "%nativeint_of_float"
external nativeint_to_float : nativeint -> float = "%nativeint_to_float"
external nativeint_of_int : int -> nativeint = "%nativeint_of_int"
external nativeint_to_int : nativeint -> int = "%nativeint_to_int"
external int64_of_float : float -> int64 = "%int64_of_float"
external int64_to_float : int64 -> float = "%int64_to_float"

let int64_converters = (int64_of_float, int64_to_float)
let is_int x = Obj.is_int x

type mixed = Zero | One | Value of int | Pair of int * int

let value = function
  | Zero -> 0
  | One -> 1
  | Value x -> x
  | Pair (x, y) -> x + y

let cases name convert inputs =
  List.mapi
    (fun i (input, expected) ->
      (Printf.sprintf "%s_%d" name i,
       fun () -> Mt.Eq (convert input, expected)))
    inputs

let suites =
  let of_float, to_float = int64_converters in
  cases "int32_to_float" int32_to_float
    [ (0l, 0.); (-1l, -1.); (2147483647l, 2147483647.);
      (-2147483648l, -2147483648.) ]
  @ cases "nativeint_of_float"
      (fun x -> nativeint_to_int (nativeint_of_float x))
      [ (0., 0); (-0., 0); (42.875, 42); (-42.875, -42);
        (2147483647., 2147483647); (-2147483648., -2147483648) ]
  @ cases "nativeint_to_float"
      (fun x -> nativeint_to_float (nativeint_of_int x))
      [ (0, 0.); (-1, -1.); (2147483647, 2147483647.);
        (-2147483648, -2147483648.) ]
  @ cases "int64_of_float" of_float
      [ (0., 0L); (42.875, 42L); (-42.875, -42L);
        (4294967296.75, 4294967296L); (-4294967296.75, -4294967296L);
        (9007199254740991., 9007199254740991L);
        (-9223372036854775808., Int64.min_int) ]
  @ cases "int64_to_float" to_float
      [ (0L, 0.); (-1L, -1.); (4294967296L, 4294967296.);
        (-4294967296L, -4294967296.);
        (9007199254740991L, 9007199254740991.);
        (Int64.max_int, 9223372036854775808.);
        (Int64.min_int, -9223372036854775808.) ]
  @ Mt.[
      "int64_of_float_evaluates_argument_once", (fun () ->
        let evaluations = ref 0 in
        let input () = incr evaluations; 42.875 in
        let converted = of_float (input ()) in
        Eq ((converted, !evaluations), (42L, 1)));
      "nativeint_of_float_evaluates_argument_once", (fun () ->
        let evaluations = ref 0 in
        let input () = incr evaluations; 42.875 in
        let converted = nativeint_to_int (nativeint_of_float (input ())) in
        Eq ((converted, !evaluations), (42, 1)));
      "is_int_on_integer", (fun () ->
        Eq (is_int (Obj.repr 42), true));
      "is_int_on_tuple", (fun () ->
        Eq (is_int (Obj.repr (1, 2)), false));
      "is_int_on_constant_constructor", (fun () ->
        Eq (is_int (Obj.repr Zero), true));
      "is_int_on_block_constructor", (fun () ->
        Eq (is_int (Obj.repr (Value 42)), false));
    ]
  @ cases "variant_matching" value
      [ (Zero, 0); (One, 1); (Value 42, 42); (Pair (3, 4), 7) ]

let () = Mt.from_pair_suites __MODULE__ suites

#endif
