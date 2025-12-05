let test_array () =
  let k f y = Array.of_list_map y ~f in
  Alcotest.(check (array int)) "empty" (k succ []) [||];
  Alcotest.(check (array int)) "1 el" (k succ [ 1 ]) [| 2 |];
  Alcotest.(check (array int)) "2 el" (k succ [ 1; 2; 3 ]) [| 2; 3; 4 |];
  Alcotest.(check (array int)) "3 el" (k succ [ 1; 2; 3; 4 ]) [| 2; 3; 4; 5 |];
  Alcotest.(check (array int))
    "4 el"
    (k succ [ 1; 2; 3; 4; 5 ])
    [| 2; 3; 4; 5; 6 |];
  Alcotest.(check (array int))
    "5 el"
    (k succ [ 1; 2; 3; 4; 5; 6 ])
    [| 2; 3; 4; 5; 6; 7 |];
  Alcotest.(check (array int))
    "6 el"
    (k succ [ 1; 2; 3; 4; 5; 6; 7 ])
    [| 2; 3; 4; 5; 6; 7; 8 |]

let suite = [ ("array tests", `Quick, test_array) ]
