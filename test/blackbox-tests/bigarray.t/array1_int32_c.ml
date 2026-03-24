open Bigarray

let () =
  let a = Array1.create int32 c_layout 4 in
  Array1.set a 0 42l;
  Array1.set a 1 (-1l);
  Array1.set a 2 0l;
  Array1.set a 3 2147483647l;
  for i = 0 to 3 do
    if i > 0 then print_char ' ';
    print_string (Int32.to_string (Array1.get a i))
  done;
  print_newline ();
  Printf.printf "size_in_bytes: %d\n" (Array1.size_in_bytes a)
