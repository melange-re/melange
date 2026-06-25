open Bigarray

let () =
  let a = Array1.create float64 c_layout 5 in
  for i = 0 to 4 do Array1.set a i (Float.of_int (i * 10)) done;
  for i = 0 to 4 do
    if i > 0 then print_char ' ';
    print_float (Array1.get a i)
  done;
  print_newline ();
  (* init *)
  let b = Array1.init float64 c_layout 4 (fun i -> Float.of_int (i * i)) in
  for i = 0 to 3 do
    if i > 0 then print_char ' ';
    print_float (Array1.get b i)
  done;
  print_newline ();
  (* of_array *)
  let c = Array1.of_array float64 c_layout [| 10.; 20.; 30. |] in
  for i = 0 to 2 do
    if i > 0 then print_char ' ';
    print_float (Array1.get c i)
  done;
  print_newline ();
  Printf.printf "dim: %d\n" (Array1.dim a);
  Printf.printf "size_in_bytes: %d\n" (Array1.size_in_bytes a)
