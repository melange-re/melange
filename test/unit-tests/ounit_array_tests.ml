open Melstd

let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal

let printer_int_array xs =
  String.concat ~sep:"," (List.map ~f:string_of_int @@ Array.to_list xs)

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           let ( =~ ) = OUnit.assert_equal ~printer:printer_int_array in
           let k x y = Array.of_list_map y x in
           k succ [] =~ [||];
           k succ [ 1 ] =~ [| 2 |];
           k succ [ 1; 2; 3 ] =~ [| 2; 3; 4 |];
           k succ [ 1; 2; 3; 4 ] =~ [| 2; 3; 4; 5 |];
           k succ [ 1; 2; 3; 4; 5 ] =~ [| 2; 3; 4; 5; 6 |];
           k succ [ 1; 2; 3; 4; 5; 6 ] =~ [| 2; 3; 4; 5; 6; 7 |];
           k succ [ 1; 2; 3; 4; 5; 6; 7 ] =~ [| 2; 3; 4; 5; 6; 7; 8 |] );
       ]
