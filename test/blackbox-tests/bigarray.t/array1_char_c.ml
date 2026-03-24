open Bigarray

let () =
  let a = Array1.create char c_layout 5 in
  Array1.set a 0 'H';
  Array1.set a 1 'e';
  Array1.set a 2 'l';
  Array1.set a 3 'l';
  Array1.set a 4 'o';
  for i = 0 to 4 do
    print_char (Array1.get a i)
  done;
  print_newline ();
  Printf.printf "size_in_bytes: %d\n" (Array1.size_in_bytes a)
