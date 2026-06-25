open Bigarray

let () =
  let a = Genarray.create float64 c_layout [| 2; 3; 4; 5 |] in
  Genarray.set a [| 1; 2; 3; 4 |] 42.0;
  Printf.printf "num_dims: %d\n" (Genarray.num_dims a);
  let d = Genarray.dims a in
  Printf.printf "dims:";
  Array.iter (fun x -> Printf.printf " %d" x) d;
  print_newline ();
  Printf.printf "a[1][2][3][4] = %g\n" (Genarray.get a [| 1; 2; 3; 4 |])
