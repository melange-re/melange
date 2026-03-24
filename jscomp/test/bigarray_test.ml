(* Tests for Bigarray runtime support *)

(* Tests for the runtime primitives directly via external declarations.
   See bigarray_stdlib_test.ml for tests using the stdlib Bigarray module. *)

(* Kind constants matching OCaml GADT constructor order *)
let float32_kind = 0
let float64_kind = 1
let int8_signed_kind = 2
let int8_unsigned_kind = 3
let int16_signed_kind = 4
let int16_unsigned_kind = 5
let int32_kind = 6
let _int64_kind = 7
let int_kind = 8
let _nativeint_kind = 9
let char_kind = 12

(* Layout constants *)
let c_layout = 0
let fortran_layout = 1

(* Runtime primitive declarations *)
external caml_ba_create : int -> int -> int array -> 'a = "caml_ba_create"
external caml_ba_num_dims : 'a -> int = "caml_ba_num_dims"
external caml_ba_dim : 'a -> int -> int = "caml_ba_dim"
external caml_ba_dim_1 : 'a -> int = "caml_ba_dim_1"
external caml_ba_kind : 'a -> int = "caml_ba_kind"
external caml_ba_layout : 'a -> int = "caml_ba_layout"
external caml_ba_get_1 : 'a -> int -> 'b = "caml_ba_get_1"
external caml_ba_set_1 : 'a -> int -> 'b -> unit = "caml_ba_set_1"
external caml_ba_get_2 : 'a -> int -> int -> 'b = "caml_ba_get_2"
external caml_ba_set_2 : 'a -> int -> int -> 'b -> unit = "caml_ba_set_2"
external caml_ba_get_3 : 'a -> int -> int -> int -> 'b = "caml_ba_get_3"
external caml_ba_set_3 : 'a -> int -> int -> int -> 'b -> unit = "caml_ba_set_3"
external caml_ba_get_generic : 'a -> int array -> 'b = "caml_ba_get_generic"
external caml_ba_set_generic : 'a -> int array -> 'b -> unit = "caml_ba_set_generic"
external caml_ba_fill : 'a -> 'b -> unit = "caml_ba_fill"
external caml_ba_blit : 'a -> 'a -> unit = "caml_ba_blit"
external caml_ba_sub : 'a -> int -> int -> 'a = "caml_ba_sub"
external caml_ba_slice : 'a -> int array -> 'a = "caml_ba_slice"
external caml_ba_reshape : 'a -> int array -> 'a = "caml_ba_reshape"
external caml_ba_change_layout : 'a -> int -> 'a = "caml_ba_change_layout"

let suites : Mt.pair_suites ref = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y
let ok loc x = Mt.bool_suites ~test_id ~suites loc x
let throw loc x = Mt.throw_suites ~test_id ~suites loc x

(* === 1D Float64 C layout === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 5 |] in
  eq __LOC__ (caml_ba_num_dims ba) 1;
  eq __LOC__ (caml_ba_dim ba 0) 5;
  eq __LOC__ (caml_ba_dim_1 ba) 5;
  eq __LOC__ (caml_ba_kind ba) float64_kind;
  eq __LOC__ (caml_ba_layout ba) c_layout;

  (* set and get *)
  caml_ba_set_1 ba 0 1.5;
  caml_ba_set_1 ba 1 2.5;
  caml_ba_set_1 ba 4 9.9;
  eq __LOC__ (caml_ba_get_1 ba 0) 1.5;
  eq __LOC__ (caml_ba_get_1 ba 1) 2.5;
  eq __LOC__ (caml_ba_get_1 ba 4) 9.9;

  (* bounds checking *)
  throw __LOC__ (fun () -> ignore (caml_ba_get_1 ba 5));
  throw __LOC__ (fun () -> ignore (caml_ba_get_1 ba (-1)));

  ()

(* === 1D Float64 Fortran layout === *)
let () =
  let ba = caml_ba_create float64_kind fortran_layout [| 5 |] in
  eq __LOC__ (caml_ba_layout ba) fortran_layout;

  (* Fortran layout: 1-based indexing *)
  caml_ba_set_1 ba 1 10.0;
  caml_ba_set_1 ba 5 50.0;
  eq __LOC__ (caml_ba_get_1 ba 1) 10.0;
  eq __LOC__ (caml_ba_get_1 ba 5) 50.0;

  (* bounds checking for Fortran layout *)
  throw __LOC__ (fun () -> ignore (caml_ba_get_1 ba 0));
  throw __LOC__ (fun () -> ignore (caml_ba_get_1 ba 6));

  ()

(* === 1D Float32 === *)
let () =
  let ba = caml_ba_create float32_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 1.0;
  caml_ba_set_1 ba 1 2.0;
  caml_ba_set_1 ba 2 3.0;
  eq __LOC__ (caml_ba_get_1 ba 0) 1.0;
  eq __LOC__ (caml_ba_get_1 ba 1) 2.0;
  eq __LOC__ (caml_ba_get_1 ba 2) 3.0;
  ()

(* === 1D Int8 signed === *)
let () =
  let ba = caml_ba_create int8_signed_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 42;
  caml_ba_set_1 ba 1 (-1);
  eq __LOC__ (caml_ba_get_1 ba 0) 42;
  eq __LOC__ (caml_ba_get_1 ba 1) (-1);  (* signed wrap *)
  ()

(* === 1D Uint8 === *)
let () =
  let ba = caml_ba_create int8_unsigned_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 200;
  caml_ba_set_1 ba 1 0;
  eq __LOC__ (caml_ba_get_1 ba 0) 200;
  eq __LOC__ (caml_ba_get_1 ba 1) 0;
  ()

(* === 1D Int16 signed === *)
let () =
  let ba = caml_ba_create int16_signed_kind c_layout [| 2 |] in
  caml_ba_set_1 ba 0 (-32000);
  caml_ba_set_1 ba 1 32000;
  eq __LOC__ (caml_ba_get_1 ba 0) (-32000);
  eq __LOC__ (caml_ba_get_1 ba 1) 32000;
  ()

(* === 1D Int16 unsigned === *)
let () =
  let ba = caml_ba_create int16_unsigned_kind c_layout [| 2 |] in
  caml_ba_set_1 ba 0 60000;
  eq __LOC__ (caml_ba_get_1 ba 0) 60000;
  ()

(* === 1D Int32 === *)
let () =
  let ba = caml_ba_create int32_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 42l;
  caml_ba_set_1 ba 1 (-1l);
  eq __LOC__ (caml_ba_get_1 ba 0) 42l;
  eq __LOC__ (caml_ba_get_1 ba 1) (-1l);
  ()

(* === 1D Int (OCaml int) === *)
let () =
  let ba = caml_ba_create int_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 42;
  caml_ba_set_1 ba 1 (-7);
  eq __LOC__ (caml_ba_get_1 ba 0) 42;
  eq __LOC__ (caml_ba_get_1 ba 1) (-7);
  ()

(* === 1D Char kind === *)
let () =
  let ba = caml_ba_create char_kind c_layout [| 3 |] in
  caml_ba_set_1 ba 0 (Char.code 'A');
  caml_ba_set_1 ba 1 (Char.code 'B');
  eq __LOC__ (caml_ba_get_1 ba 0) (Char.code 'A');
  eq __LOC__ (caml_ba_get_1 ba 1) (Char.code 'B');
  ()

(* === fill === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 5 |] in
  caml_ba_fill ba 42.0;
  eq __LOC__ (caml_ba_get_1 ba 0) 42.0;
  eq __LOC__ (caml_ba_get_1 ba 4) 42.0;
  ()

(* === blit === *)
let () =
  let src = caml_ba_create float64_kind c_layout [| 3 |] in
  let dst = caml_ba_create float64_kind c_layout [| 3 |] in
  caml_ba_set_1 src 0 1.0;
  caml_ba_set_1 src 1 2.0;
  caml_ba_set_1 src 2 3.0;
  caml_ba_blit src dst;
  eq __LOC__ (caml_ba_get_1 dst 0) 1.0;
  eq __LOC__ (caml_ba_get_1 dst 1) 2.0;
  eq __LOC__ (caml_ba_get_1 dst 2) 3.0;
  ()

(* === sub (C layout) === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 10 |] in
  for i = 0 to 9 do caml_ba_set_1 ba i (Float.of_int i) done;
  let sub = caml_ba_sub ba 3 4 in
  eq __LOC__ (caml_ba_dim_1 sub) 4;
  eq __LOC__ (caml_ba_get_1 sub 0) 3.0;
  eq __LOC__ (caml_ba_get_1 sub 3) 6.0;

  (* sub shares storage: mutating sub is visible in original *)
  caml_ba_set_1 sub 0 99.0;
  eq __LOC__ (caml_ba_get_1 ba 3) 99.0;
  ()

(* === sub (Fortran layout) === *)
let () =
  let ba = caml_ba_create float64_kind fortran_layout [| 10 |] in
  for i = 1 to 10 do caml_ba_set_1 ba i (Float.of_int i) done;
  let sub = caml_ba_sub ba 3 4 in
  eq __LOC__ (caml_ba_dim_1 sub) 4;
  eq __LOC__ (caml_ba_get_1 sub 1) 3.0;
  eq __LOC__ (caml_ba_get_1 sub 4) 6.0;
  ()

(* === reshape === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 6 |] in
  for i = 0 to 5 do caml_ba_set_1 ba i (Float.of_int i) done;
  let reshaped = caml_ba_reshape ba [| 2; 3 |] in
  eq __LOC__ (caml_ba_num_dims reshaped) 2;
  eq __LOC__ (caml_ba_dim reshaped 0) 2;
  eq __LOC__ (caml_ba_dim reshaped 1) 3;
  (* data is shared *)
  eq __LOC__ (caml_ba_get_2 reshaped 0 0) 0.0;
  eq __LOC__ (caml_ba_get_2 reshaped 0 2) 2.0;
  eq __LOC__ (caml_ba_get_2 reshaped 1 0) 3.0;
  ()

(* === 2D access C layout === *)
let () =
  let ba = caml_ba_create int_kind c_layout [| 3; 4 |] in
  caml_ba_set_2 ba 0 0 1;
  caml_ba_set_2 ba 1 2 42;
  caml_ba_set_2 ba 2 3 99;
  eq __LOC__ (caml_ba_get_2 ba 0 0) 1;
  eq __LOC__ (caml_ba_get_2 ba 1 2) 42;
  eq __LOC__ (caml_ba_get_2 ba 2 3) 99;
  (* bounds check *)
  throw __LOC__ (fun () -> ignore (caml_ba_get_2 ba 3 0));
  throw __LOC__ (fun () -> ignore (caml_ba_get_2 ba 0 4));
  ()

(* === 2D access Fortran layout === *)
let () =
  let ba = caml_ba_create int_kind fortran_layout [| 3; 4 |] in
  caml_ba_set_2 ba 1 1 1;
  caml_ba_set_2 ba 2 3 42;
  caml_ba_set_2 ba 3 4 99;
  eq __LOC__ (caml_ba_get_2 ba 1 1) 1;
  eq __LOC__ (caml_ba_get_2 ba 2 3) 42;
  eq __LOC__ (caml_ba_get_2 ba 3 4) 99;
  ()

(* === 3D access C layout === *)
let () =
  let ba = caml_ba_create int_kind c_layout [| 2; 3; 4 |] in
  caml_ba_set_3 ba 0 0 0 1;
  caml_ba_set_3 ba 1 2 3 99;
  eq __LOC__ (caml_ba_get_3 ba 0 0 0) 1;
  eq __LOC__ (caml_ba_get_3 ba 1 2 3) 99;
  ()

(* === generic get/set === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 3; 4 |] in
  caml_ba_set_generic ba [| 1; 2 |] 42.0;
  eq __LOC__ (caml_ba_get_generic ba [| 1; 2 |]) 42.0;
  ()

(* === change_layout === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 2; 3 |] in
  caml_ba_set_2 ba 0 0 1.0;
  caml_ba_set_2 ba 0 1 2.0;
  caml_ba_set_2 ba 1 0 4.0;
  let ba2 = caml_ba_change_layout ba fortran_layout in
  eq __LOC__ (caml_ba_layout ba2) fortran_layout;
  (* dims are reversed *)
  eq __LOC__ (caml_ba_dim ba2 0) 3;
  eq __LOC__ (caml_ba_dim ba2 1) 2;
  ()

(* === slice (C layout, 2D -> 1D) === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 3; 4 |] in
  (* Fill with row*10 + col *)
  for r = 0 to 2 do
    for c = 0 to 3 do
      caml_ba_set_2 ba r c (Float.of_int (r * 10 + c))
    done
  done;
  let row1 = caml_ba_slice ba [| 1 |] in
  eq __LOC__ (caml_ba_num_dims row1) 1;
  eq __LOC__ (caml_ba_dim_1 row1) 4;
  eq __LOC__ (caml_ba_get_1 row1 0) 10.0;
  eq __LOC__ (caml_ba_get_1 row1 3) 13.0;
  ()

(* === negative dimension check === *)
let () =
  throw __LOC__ (fun () -> ignore (caml_ba_create float64_kind c_layout [| -1 |]));
  ()

(* === zero-dimensional array === *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| |] in
  eq __LOC__ (caml_ba_num_dims ba) 0;
  caml_ba_set_generic ba [| |] 42.0;
  eq __LOC__ (caml_ba_get_generic ba [| |]) 42.0;
  ()

(* === C-external caml_ba_get/set/dim primitives ===
   These externals are dispatched through lam_dispatch_primitive.ml
   to the Caml_bigarray runtime module *)
external ba_get_1 : 'a -> int -> 'b = "caml_ba_get_1"
external ba_set_1 : 'a -> int -> 'b -> unit = "caml_ba_set_1"
external ba_unsafe_get_1 : 'a -> int -> 'b = "caml_ba_get_1"
external ba_unsafe_set_1 : 'a -> int -> 'b -> unit = "caml_ba_set_1"
external ba_dim_1 : 'a -> int = "caml_ba_dim_1"
external ba_get_2 : 'a -> int -> int -> 'b = "caml_ba_get_2"
external ba_set_2 : 'a -> int -> int -> 'b -> unit = "caml_ba_set_2"
external ba_dim_2 : 'a -> int = "caml_ba_dim_2"
external ba_get_3 : 'a -> int -> int -> int -> 'b = "caml_ba_get_3"
external ba_set_3 : 'a -> int -> int -> int -> 'b -> unit = "caml_ba_set_3"
external ba_dim_3 : 'a -> int = "caml_ba_dim_3"

(* Test caml_ba_get_1 / caml_ba_set_1 (1D) *)
let () =
  let ba = caml_ba_create float64_kind c_layout [| 5 |] in
  ba_set_1 ba 0 10.0;
  ba_set_1 ba 4 40.0;
  eq __LOC__ (ba_get_1 ba 0) 10.0;
  eq __LOC__ (ba_get_1 ba 4) 40.0;
  eq __LOC__ (ba_dim_1 ba) 5;
  (* unsafe variants *)
  ba_unsafe_set_1 ba 2 20.0;
  eq __LOC__ (ba_unsafe_get_1 ba 2) 20.0;
  ()

(* Test caml_ba_get_2 / caml_ba_set_2 (2D) *)
let () =
  let ba = caml_ba_create int_kind c_layout [| 3; 4 |] in
  ba_set_2 ba 1 2 42;
  eq __LOC__ (ba_get_2 ba 1 2) 42;
  eq __LOC__ (ba_dim_1 ba) 3;
  eq __LOC__ (ba_dim_2 ba) 4;
  ()

(* Test caml_ba_get_3 / caml_ba_set_3 (3D) *)
let () =
  let ba = caml_ba_create int_kind c_layout [| 2; 3; 4 |] in
  ba_set_3 ba 1 2 3 99;
  eq __LOC__ (ba_get_3 ba 1 2 3) 99;
  eq __LOC__ (ba_dim_3 ba) 4;
  ()

(* Test Fortran layout with compiler primitives *)
let () =
  let ba = caml_ba_create float64_kind fortran_layout [| 5 |] in
  ba_set_1 ba 1 100.0;
  ba_set_1 ba 5 500.0;
  eq __LOC__ (ba_get_1 ba 1) 100.0;
  eq __LOC__ (ba_get_1 ba 5) 500.0;
  (* bounds check still works *)
  throw __LOC__ (fun () -> ignore (ba_get_1 ba 0));
  throw __LOC__ (fun () -> ignore (ba_get_1 ba 6));
  ()

(* === Bigstring (multi-byte load/set) primitives === *)
external bigstring_get16 : 'a -> int -> int = "caml_bigstring_get16"
external bigstring_set16 : 'a -> int -> int -> unit = "caml_bigstring_set16"
external bigstring_get32 : 'a -> int -> int32 = "caml_bigstring_get32"
external bigstring_set32 : 'a -> int -> int32 -> unit = "caml_bigstring_set32"
external bigstring_blit_ba_to_bytes : 'a -> int -> bytes -> int -> int -> unit
  = "caml_bigstring_blit_ba_to_bytes"
external bigstring_blit_bytes_to_ba : bytes -> int -> 'a -> int -> int -> unit
  = "caml_bigstring_blit_bytes_to_ba"
external bigstring_blit_ba_to_ba : 'a -> int -> 'a -> int -> int -> unit
  = "caml_bigstring_blit_ba_to_ba"

(* Test 16-bit load/set on a uint8 bigarray *)
let () =
  let ba = caml_ba_create int8_unsigned_kind c_layout [| 10 |] in
  bigstring_set16 ba 0 0x0102;
  eq __LOC__ (bigstring_get16 ba 0) 0x0102;
  (* Little-endian: byte 0 = 0x02, byte 1 = 0x01 *)
  eq __LOC__ (caml_ba_get_1 ba 0) 0x02;
  eq __LOC__ (caml_ba_get_1 ba 1) 0x01;
  ()

(* Test 32-bit load/set *)
let () =
  let ba = caml_ba_create int8_unsigned_kind c_layout [| 10 |] in
  bigstring_set32 ba 0 0x04030201l;
  eq __LOC__ (bigstring_get32 ba 0) 0x04030201l;
  (* Little-endian byte order *)
  eq __LOC__ (caml_ba_get_1 ba 0) 0x01;
  eq __LOC__ (caml_ba_get_1 ba 1) 0x02;
  eq __LOC__ (caml_ba_get_1 ba 2) 0x03;
  eq __LOC__ (caml_ba_get_1 ba 3) 0x04;
  ()

(* Test blit ba -> bytes *)
let () =
  let ba = caml_ba_create int8_unsigned_kind c_layout [| 5 |] in
  for i = 0 to 4 do caml_ba_set_1 ba i (i + 65) done;  (* A B C D E *)
  let buf = Bytes.create 5 in
  bigstring_blit_ba_to_bytes ba 0 buf 0 5;
  eq __LOC__ (Bytes.get buf 0) 'A';
  eq __LOC__ (Bytes.get buf 4) 'E';
  ()

(* Test blit bytes -> ba *)
let () =
  let ba = caml_ba_create int8_unsigned_kind c_layout [| 5 |] in
  let buf = Bytes.of_string "Hello" in
  bigstring_blit_bytes_to_ba buf 0 ba 0 5;
  eq __LOC__ (caml_ba_get_1 ba 0) (Char.code 'H');
  eq __LOC__ (caml_ba_get_1 ba 4) (Char.code 'o');
  ()

(* Test blit ba -> ba *)
let () =
  let src = caml_ba_create int8_unsigned_kind c_layout [| 5 |] in
  let dst = caml_ba_create int8_unsigned_kind c_layout [| 5 |] in
  for i = 0 to 4 do caml_ba_set_1 src i (i * 10) done;
  bigstring_blit_ba_to_ba src 1 dst 0 3;
  eq __LOC__ (caml_ba_get_1 dst 0) 10;
  eq __LOC__ (caml_ba_get_1 dst 1) 20;
  eq __LOC__ (caml_ba_get_1 dst 2) 30;
  ()

let () = Mt.from_pair_suites __MODULE__ !suites
