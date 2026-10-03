OCaml 5.6 boxed-integer float conversions use the existing JavaScript operations.
Both forms of the upstream integer test preserve variant matching and Obj.is_int.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.21)
  > (using melange 1.0)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target output)
  >  (libraries melange))
  > EOF
  $ cat > primitives.ml <<'EOF'
  > external int32_to_float : int32 -> float = "%int32_to_float"
  > external nativeint_of_float : float -> nativeint = "%nativeint_of_float"
  > external nativeint_to_float : nativeint -> float = "%nativeint_to_float"
  > external nativeint_of_int : int -> nativeint = "%nativeint_of_int"
  > external nativeint_to_int : nativeint -> int = "%nativeint_to_int"
  > external int64_of_float : float -> int64 = "%int64_of_float"
  > external int64_to_float : int64 -> float = "%int64_to_float"
  > let int32_to_float x = int32_to_float x
  > let nativeint_of_float x = nativeint_of_float x
  > let nativeint_to_float x = nativeint_to_float x
  > let int64_converters = (int64_of_float, int64_to_float)
  > let is_int x = Obj.is_int x
  > type mixed = Zero | One | Value of int | Pair of int * int
  > let value = function
  >   | Zero -> 0
  >   | One -> 1
  >   | Value x -> x
  >   | Pair (x, y) -> x + y
  > EOF
  $ cat > check.ml <<'EOF'
  > let () =
  >   List.iter
  >     (fun (input, expected) ->
  >       assert (Primitives.int32_to_float input = expected))
  >     [ (0l, 0.); (-1l, -1.); (2147483647l, 2147483647.);
  >       (-2147483648l, -2147483648.) ];
  >   List.iter
  >     (fun (input, expected) ->
  >       assert (Primitives.nativeint_to_int (Primitives.nativeint_of_float input) = expected))
  >     [ (0., 0); (-0., 0); (42.875, 42); (-42.875, -42);
  >       (2147483647., 2147483647); (-2147483648., -2147483648) ];
  >   List.iter
  >     (fun (input, expected) ->
  >       assert (Primitives.nativeint_to_float (Primitives.nativeint_of_int input) = expected))
  >     [ (0, 0.); (-1, -1.); (2147483647, 2147483647.);
  >       (-2147483648, -2147483648.) ];
  >   let of_float, to_float = Primitives.int64_converters in
  >   List.iter
  >     (fun (input, expected) -> assert (of_float input = expected))
  >     [ (0., 0L); (42.875, 42L); (-42.875, -42L);
  >       (4294967296.75, 4294967296L); (-4294967296.75, -4294967296L);
  >       (9007199254740991., 9007199254740991L);
  >       (-9223372036854775808., Int64.min_int) ];
  >   List.iter
  >     (fun (input, expected) -> assert (to_float input = expected))
  >     [ (0L, 0.); (-1L, -1.); (4294967296L, 4294967296.);
  >       (-4294967296L, -4294967296.);
  >       (9007199254740991L, 9007199254740991.);
  >       (Int64.max_int, 9223372036854775808.);
  >       (Int64.min_int, -9223372036854775808.) ];
  >   let evaluations = ref 0 in
  >   let input () = incr evaluations; 42.875 in
  >   assert (of_float (input ()) = 42L);
  >   assert (!evaluations = 1);
  >   assert (Primitives.nativeint_to_int (Primitives.nativeint_of_float (input ())) = 42);
  >   assert (!evaluations = 2);
  >   assert (Primitives.is_int (Obj.repr 42));
  >   assert (not (Primitives.is_int (Obj.repr (1, 2))));
  >   assert (Primitives.is_int (Obj.repr Primitives.Zero));
  >   assert (not (Primitives.is_int (Obj.repr (Primitives.Value 42))));
  >   List.iter
  >     (fun (input, expected) -> assert (Primitives.value input = expected))
  >     Primitives.[ (Zero, 0); (One, 1); (Value 42, 42); (Pair (3, 4), 7) ]
  > EOF
  $ dune build @melange
  $ node _build/default/output/check.js
