open Bigarray

let print_int_array a n =
  for i = 0 to n - 1 do
    if i > 0 then print_char ' ';
    print_int (Array1.get a i)
  done;
  print_newline ()

let () =
  (* int8_unsigned *)
  let a = Array1.create int8_unsigned c_layout 4 in
  Array1.set a 0 0; Array1.set a 1 127; Array1.set a 2 255; Array1.set a 3 42;
  print_string "uint8: "; print_int_array a 4;

  (* int8_signed *)
  let b = Array1.create int8_signed c_layout 3 in
  Array1.set b 0 (-128); Array1.set b 1 127; Array1.set b 2 0;
  print_string "int8: "; print_int_array b 3;

  (* int16_unsigned *)
  let c = Array1.create int16_unsigned c_layout 3 in
  Array1.set c 0 0; Array1.set c 1 65535; Array1.set c 2 1000;
  print_string "uint16: "; print_int_array c 3;

  (* int16_signed *)
  let d = Array1.create int16_signed c_layout 3 in
  Array1.set d 0 (-32768); Array1.set d 1 32767; Array1.set d 2 0;
  print_string "int16: "; print_int_array d 3
