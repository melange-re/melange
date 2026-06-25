open Bigarray

let () =
  let a = Array3.create float64 fortran_layout 2 3 4 in
  for i = 1 to 2 do
    for j = 1 to 3 do
      for k = 1 to 4 do
        Array3.set a i j k (Float.of_int (i * 100 + j * 10 + k))
      done
    done
  done;
  Printf.printf "a[1][2][3] = %g\n" (Array3.get a 1 2 3);
  Printf.printf "a[2][3][4] = %g\n" (Array3.get a 2 3 4)
