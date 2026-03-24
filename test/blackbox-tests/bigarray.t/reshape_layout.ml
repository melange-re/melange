open Bigarray

let () =
  (* reshape 1D -> 2D *)
  let a = Array1.init float64 c_layout 6 (fun i -> Float.of_int (i + 1)) in
  let b = reshape (genarray_of_array1 a) [| 2; 3 |] in
  let b2 = array2_of_genarray b in
  print_endline "reshaped 2x3:";
  for i = 0 to 1 do
    for j = 0 to 2 do
      if j > 0 then print_char ' ';
      Printf.printf "%g" (Array2.get b2 i j)
    done;
    print_newline ()
  done;

  (* change layout C -> Fortran *)
  let c = Array1.init float64 c_layout 3 (fun i -> Float.of_int (i + 1)) in
  let ga = genarray_of_array1 c in
  let d = Genarray.change_layout ga fortran_layout in
  let d1 = array1_of_genarray d in
  Printf.printf "C[0]=%g C[1]=%g C[2]=%g\n"
    (Array1.get c 0) (Array1.get c 1) (Array1.get c 2);
  Printf.printf "F[1]=%g F[2]=%g F[3]=%g\n"
    (Array1.get d1 1) (Array1.get d1 2) (Array1.get d1 3);

  (* invalid conversion *)
  (try
    let _ = array2_of_genarray (genarray_of_array1 c) in
    print_endline "ERROR: should have raised"
  with Invalid_argument msg ->
    Printf.printf "caught: %s\n" msg)
