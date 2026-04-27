open Bigarray

let () =
  let a = Array1.create float32 c_layout 3 in
  Array1.set a 0 1.5;
  Array1.set a 1 (-2.25);
  Array1.set a 2 0.0;
  for i = 0 to 2 do
    if i > 0 then print_char ' ';
    print_float (Array1.get a i)
  done;
  print_newline ();
  Printf.printf "size_in_bytes: %d\n" (Array1.size_in_bytes a)
