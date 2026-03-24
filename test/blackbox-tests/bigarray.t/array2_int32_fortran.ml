open Bigarray

let () =
  let a = Array2.create int32 fortran_layout 2 3 in
  for i = 1 to 2 do
    for j = 1 to 3 do
      Array2.set a i j (Int32.of_int (i * 10 + j))
    done
  done;
  for i = 1 to 2 do
    for j = 1 to 3 do
      if j > 1 then print_char ' ';
      print_string (Int32.to_string (Array2.get a i j))
    done;
    print_newline ()
  done;
  Printf.printf "dims: %d x %d\n" (Array2.dim1 a) (Array2.dim2 a)
