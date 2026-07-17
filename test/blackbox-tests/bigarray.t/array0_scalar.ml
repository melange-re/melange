open Bigarray

let () =
  let a = Array0.of_value float64 c_layout 3.14 in
  Printf.printf "value: %g\n" (Array0.get a);
  Array0.set a 2.72;
  Printf.printf "after set: %g\n" (Array0.get a)
