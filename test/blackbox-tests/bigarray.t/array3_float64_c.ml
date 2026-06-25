open Bigarray

let () =
  let a = Array3.create float64 c_layout 2 3 4 in
  for i = 0 to 1 do
    for j = 0 to 2 do
      for k = 0 to 3 do
        Array3.set a i j k (Float.of_int (i * 100 + j * 10 + k))
      done
    done
  done;
  Printf.printf "dims: %d x %d x %d\n"
    (Array3.dim1 a) (Array3.dim2 a) (Array3.dim3 a);
  Printf.printf "a[0][1][2] = %g\n" (Array3.get a 0 1 2);
  Printf.printf "a[1][2][3] = %g\n" (Array3.get a 1 2 3);
  Printf.printf "size_in_bytes: %d\n" (Array3.size_in_bytes a)
