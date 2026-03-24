(* Tests for stdlib Bigarray module integration.
   These tests verify that the stdlib Bigarray module works correctly
   when used through the standard OCaml API (Bigarray.Array1.create etc.) *)

let suites : Mt.pair_suites ref = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y
let ok loc x = Mt.bool_suites ~test_id ~suites loc x

(* Test Array1 create/get/set via stdlib module *)
let () =
  let open Bigarray in
  let a = Array1.create float64 c_layout 5 in
  for i = 0 to 4 do Array1.set a i (Float.of_int (i * 10)) done;
  eq __LOC__ (Array1.get a 0) 0.0;
  eq __LOC__ (Array1.get a 3) 30.0;
  eq __LOC__ (Array1.dim a) 5

(* Test Array1 with int32 kind *)
let () =
  let open Bigarray in
  let a = Array1.create int32 c_layout 3 in
  Array1.set a 0 42l;
  Array1.set a 1 100l;
  Array1.set a 2 (-1l);
  eq __LOC__ (Array1.get a 0) 42l;
  eq __LOC__ (Array1.get a 1) 100l;
  eq __LOC__ (Array1.get a 2) (-1l)

(* Test Array1 with char kind *)
let () =
  let open Bigarray in
  let a = Array1.create char c_layout 3 in
  Array1.set a 0 'A';
  Array1.set a 1 'B';
  Array1.set a 2 'C';
  eq __LOC__ (Array1.get a 0) 'A';
  eq __LOC__ (Array1.get a 2) 'C'

(* Test Array1 Fortran layout *)
let () =
  let open Bigarray in
  let a = Array1.create float64 fortran_layout 3 in
  Array1.set a 1 10.0;
  Array1.set a 2 20.0;
  Array1.set a 3 30.0;
  eq __LOC__ (Array1.get a 1) 10.0;
  eq __LOC__ (Array1.get a 3) 30.0

(* Test Array1.init *)
let () =
  let open Bigarray in
  let a = Array1.init float64 c_layout 5 (fun i -> Float.of_int (i * i)) in
  eq __LOC__ (Array1.get a 0) 0.0;
  eq __LOC__ (Array1.get a 3) 9.0;
  eq __LOC__ (Array1.get a 4) 16.0

(* Test Array1.of_array *)
let () =
  let open Bigarray in
  let a = Array1.of_array float64 c_layout [| 1.0; 2.0; 3.0; 4.0; 5.0 |] in
  eq __LOC__ (Array1.get a 0) 1.0;
  eq __LOC__ (Array1.get a 4) 5.0;
  eq __LOC__ (Array1.dim a) 5

(* Test Array2 create/get/set *)
let () =
  let open Bigarray in
  let a = Array2.create float64 c_layout 3 4 in
  Array2.set a 1 2 42.0;
  eq __LOC__ (Array2.get a 1 2) 42.0;
  eq __LOC__ (Array2.dim1 a) 3;
  eq __LOC__ (Array2.dim2 a) 4

(* Test Array2.init *)
let () =
  let open Bigarray in
  let a = Array2.init float64 c_layout 2 3 (fun i j -> Float.of_int (i * 10 + j)) in
  eq __LOC__ (Array2.get a 0 0) 0.0;
  eq __LOC__ (Array2.get a 1 2) 12.0

(* Test Array3 create/get/set *)
let () =
  let open Bigarray in
  let a = Array3.create float64 c_layout 2 3 4 in
  Array3.set a 1 2 3 99.0;
  eq __LOC__ (Array3.get a 1 2 3) 99.0;
  eq __LOC__ (Array3.dim1 a) 2;
  eq __LOC__ (Array3.dim2 a) 3;
  eq __LOC__ (Array3.dim3 a) 4

(* Test Genarray *)
let () =
  let open Bigarray in
  let a = Genarray.create float64 c_layout [| 3; 4 |] in
  Genarray.set a [| 1; 2 |] 42.0;
  eq __LOC__ (Genarray.get a [| 1; 2 |]) 42.0;
  eq __LOC__ (Genarray.num_dims a) 2;
  eq __LOC__ (Genarray.nth_dim a 0) 3;
  eq __LOC__ (Genarray.nth_dim a 1) 4

(* Test Array0 *)
let () =
  let open Bigarray in
  let a = Array0.create float64 c_layout in
  Array0.set a 42.0;
  eq __LOC__ (Array0.get a) 42.0

(* Test Array0.of_value *)
let () =
  let open Bigarray in
  let a = Array0.of_value float64 c_layout 99.0 in
  eq __LOC__ (Array0.get a) 99.0

(* Test fill *)
let () =
  let open Bigarray in
  let a = Array1.create float64 c_layout 5 in
  Array1.fill a 42.0;
  eq __LOC__ (Array1.get a 0) 42.0;
  eq __LOC__ (Array1.get a 4) 42.0

(* Test blit *)
let () =
  let open Bigarray in
  let src = Array1.init float64 c_layout 5 (fun i -> Float.of_int i) in
  let dst = Array1.create float64 c_layout 5 in
  Array1.blit src dst;
  eq __LOC__ (Array1.get dst 0) 0.0;
  eq __LOC__ (Array1.get dst 4) 4.0

(* Test sub *)
let () =
  let open Bigarray in
  let a = Array1.init float64 c_layout 10 (fun i -> Float.of_int i) in
  let s = Array1.sub a 3 4 in
  eq __LOC__ (Array1.dim s) 4;
  eq __LOC__ (Array1.get s 0) 3.0;
  eq __LOC__ (Array1.get s 3) 6.0;
  (* sub shares storage *)
  Array1.set s 0 99.0;
  eq __LOC__ (Array1.get a 3) 99.0

(* Test change_layout *)
let () =
  let open Bigarray in
  let a = Array1.init float64 c_layout 5 (fun i -> Float.of_int i) in
  let b = Genarray.change_layout (genarray_of_array1 a) fortran_layout in
  let b1 = array1_of_genarray b in
  eq __LOC__ (Array1.get b1 1) 0.0;
  eq __LOC__ (Array1.get b1 5) 4.0

(* Test reshape *)
let () =
  let open Bigarray in
  let a = Array1.init float64 c_layout 6 (fun i -> Float.of_int i) in
  let b = reshape (genarray_of_array1 a) [| 2; 3 |] in
  let b2 = array2_of_genarray b in
  eq __LOC__ (Array2.get b2 0 0) 0.0;
  eq __LOC__ (Array2.get b2 1 2) 5.0

(* Test reshape convenience functions *)
let () =
  let open Bigarray in
  let a = Array1.init float64 c_layout 6 (fun i -> Float.of_int i) in
  let ga = genarray_of_array1 a in
  let r1 = reshape_1 ga 6 in
  let a1 = array1_of_genarray r1 in
  eq __LOC__ (Array1.get a1 0) 0.0;
  eq __LOC__ (Array1.get a1 5) 5.0

(* Test kind_size_in_bytes *)
let () =
  let open Bigarray in
  eq __LOC__ (kind_size_in_bytes float32) 4;
  eq __LOC__ (kind_size_in_bytes float64) 8;
  eq __LOC__ (kind_size_in_bytes int8_signed) 1;
  eq __LOC__ (kind_size_in_bytes int8_unsigned) 1;
  eq __LOC__ (kind_size_in_bytes int16_signed) 2;
  eq __LOC__ (kind_size_in_bytes int16_unsigned) 2;
  eq __LOC__ (kind_size_in_bytes int32) 4;
  eq __LOC__ (kind_size_in_bytes char) 1

(* Test Genarray.dims *)
let () =
  let open Bigarray in
  let a = Genarray.create float64 c_layout [| 2; 3; 4 |] in
  let d = Genarray.dims a in
  eq __LOC__ (Array.length d) 3;
  eq __LOC__ d.(0) 2;
  eq __LOC__ d.(1) 3;
  eq __LOC__ d.(2) 4

(* Test slice_left *)
let () =
  let open Bigarray in
  let a = Array2.init float64 c_layout 3 4 (fun i j -> Float.of_int (i * 10 + j)) in
  let row = Array2.slice_left a 1 in
  eq __LOC__ (Array1.dim row) 4;
  eq __LOC__ (Array1.get row 0) 10.0;
  eq __LOC__ (Array1.get row 3) 13.0

(* Test array_of_genarray validation *)
let () =
  let open Bigarray in
  let a = Array1.create float64 c_layout 5 in
  let threw = try
    let _ = array2_of_genarray (genarray_of_array1 a) in false
  with Invalid_argument _ -> true
  in
  ok __LOC__ threw

(* Test size_in_bytes *)
let () =
  let open Bigarray in
  let a = Array1.create float64 c_layout 10 in
  eq __LOC__ (Array1.size_in_bytes a) 80;
  let b = Array2.create int32 c_layout 3 4 in
  eq __LOC__ (Array2.size_in_bytes b) 48

let () = Mt.from_pair_suites __MODULE__ !suites
