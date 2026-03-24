open Bigarray

let () =
  (* fill *)
  let a = Array1.create float64 c_layout 4 in
  Array1.fill a 7.0;
  print_string "fill: ";
  for i = 0 to 3 do
    if i > 0 then print_char ' ';
    print_float (Array1.get a i)
  done;
  print_newline ();

  (* blit *)
  let b = Array1.create float64 c_layout 4 in
  Array1.blit a b;
  Array1.set b 0 99.0;
  print_string "blit: ";
  for i = 0 to 3 do
    if i > 0 then print_char ' ';
    print_float (Array1.get b i)
  done;
  print_newline ();

  (* sub shares storage *)
  let c = Array1.init float64 c_layout 6 (fun i -> Float.of_int i) in
  let s = Array1.sub c 2 3 in
  Printf.printf "sub dim: %d\n" (Array1.dim s);
  print_string "sub: ";
  for i = 0 to 2 do
    if i > 0 then print_char ' ';
    print_float (Array1.get s i)
  done;
  print_newline ();
  Array1.set s 0 99.0;
  Printf.printf "original[2] after mutation: %g\n" (Array1.get c 2)
