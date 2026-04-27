open Bigarray

let () =
  let a = Array2.create float64 c_layout 3 4 in
  for i = 0 to 2 do
    for j = 0 to 3 do
      Array2.set a i j (Float.of_int (i * 10 + j))
    done
  done;
  for i = 0 to 2 do
    for j = 0 to 3 do
      if j > 0 then print_char ' ';
      Printf.printf "%g" (Array2.get a i j)
    done;
    print_newline ()
  done;
  Printf.printf "dims: %d x %d\n" (Array2.dim1 a) (Array2.dim2 a);
  Printf.printf "size_in_bytes: %d\n" (Array2.size_in_bytes a);

  (* slice_left gives a row view *)
  let row1 = Array2.slice_left a 1 in
  print_string "row1: ";
  for j = 0 to 3 do
    if j > 0 then print_char ' ';
    Printf.printf "%g" (Array1.get row1 j)
  done;
  print_newline ()
