open Bigarray

let () =
  let a = Array1.create float64 fortran_layout 5 in
  for i = 1 to 5 do Array1.set a i (Float.of_int (i * 100)) done;
  for i = 1 to 5 do
    if i > 1 then print_char ' ';
    print_float (Array1.get a i)
  done;
  print_newline ();
  (* init with fortran layout *)
  let b = Array1.init float64 fortran_layout 3 (fun i -> Float.of_int (i * 10)) in
  for i = 1 to 3 do
    if i > 1 then print_char ' ';
    print_float (Array1.get b i)
  done;
  print_newline ();
  Printf.printf "dim: %d\n" (Array1.dim a)
