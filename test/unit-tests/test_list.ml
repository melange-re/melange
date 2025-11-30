let test_concat_map () =
  Alcotest.(check (list int))
    __LOC__
    (List.concat_map ~f:(fun x -> [ x; x ]) [ 1; 2 ])
    [ 1; 1; 2; 2 ];
  Alcotest.(check (list int))
    __LOC__
    (List.concat_map ~f:(fun x -> [ succ x ]) [])
    [];
  Alcotest.(check (list int))
    __LOC__
    (List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1 ])
    [ 1; 2 ];
  Alcotest.(check (list int))
    __LOC__
    (List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1; 2 ])
    [ 1; 2; 2; 3 ];
  Alcotest.(check (list int))
    __LOC__
    (List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1; 2; 3 ])
    [ 1; 2; 2; 3; 3; 4 ]

let test_stable_group () =
  Alcotest.(check (list (list int)))
    __LOC__
    (List.stable_group [ 1; 2; 3; 4; 3 ] ~equal:( = ))
    [ [ 1 ]; [ 2 ]; [ 4 ]; [ 3; 3 ] ]

let test_map_last () =
  let f b _v = if b then 1 else 0 in
  Alcotest.(check (list int)) __LOC__ (List.map_last [] ~f) [];
  Alcotest.(check (list int)) __LOC__ (List.map_last [ 0 ] ~f) [ 1 ];
  Alcotest.(check (list int)) __LOC__ (List.map_last [ 0; 0 ] ~f) [ 0; 1 ];
  Alcotest.(check (list int)) __LOC__ (List.map_last [ 0; 0; 0 ] ~f) [ 0; 0; 1 ];
  Alcotest.(check (list int))
    __LOC__
    (List.map_last [ 0; 0; 0; 0 ] ~f)
    [ 0; 0; 0; 1 ];
  Alcotest.(check (list int))
    __LOC__
    (List.map_last [ 0; 0; 0; 0; 0 ] ~f)
    [ 0; 0; 0; 0; 1 ];
  Alcotest.(check (list int))
    __LOC__
    (List.map_last [ 0; 0; 0; 0; 0; 0 ] ~f)
    [ 0; 0; 0; 0; 0; 1 ];
  Alcotest.(check (list int))
    __LOC__
    (List.map_last [ 0; 0; 0; 0; 0; 0; 0 ] ~f)
    [ 0; 0; 0; 0; 0; 0; 1 ]

let test_map () =
  Alcotest.(check (list string))
    __LOC__
    (List.map ~f:(fun x -> string_of_int x) [ 0; 1; 2 ] @ [ "1"; "2"; "3" ])
    [ "0"; "1"; "2"; "1"; "2"; "3" ]

let test_split_at () =
  let a, b = List.split_at [ 1; 2; 3; 4; 5; 6 ] 3 in
  Alcotest.(check (pair (list int) (list int)))
    __LOC__ (a, b)
    ([ 1; 2; 3 ], [ 4; 5; 6 ]);
  Alcotest.(check (pair (list int) (list int)))
    __LOC__ (List.split_at [ 1 ] 1) ([ 1 ], []);
  Alcotest.(check (pair (list int) (list int)))
    __LOC__
    (List.split_at [ 1; 2; 3 ] 2)
    ([ 1; 2 ], [ 3 ])

let test_split_at_last () =
  Alcotest.(check (pair (list int) int))
    __LOC__
    (List.split_at_last [ 1; 2; 3 ])
    ([ 1; 2 ], 3);
  Alcotest.(check (pair (list int) int))
    __LOC__
    (List.split_at_last [ 1; 2; 3; 4; 5; 6; 7; 8 ])
    ([ 1; 2; 3; 4; 5; 6; 7 ], 8);
  Alcotest.(check (pair (list int) int))
    __LOC__
    (List.split_at_last [ 1; 2; 3; 4; 5; 6; 7 ])
    ([ 1; 2; 3; 4; 5; 6 ], 7)

let test_length_larger_than_n () =
  Alcotest.(check bool)
    __LOC__ true
    (List.length_larger_than_n [ 1; 2 ] [ 1 ] 1);
  Alcotest.(check bool)
    __LOC__ true
    (List.length_larger_than_n [ 1; 2 ] [ 1; 2 ] 0);
  Alcotest.(check bool) __LOC__ true (List.length_larger_than_n [ 1; 2 ] [] 2)

let test_length_ge () =
  Alcotest.(check bool) __LOC__ true (List.length_ge [ 1; 2; 3 ] 3);
  Alcotest.(check bool) __LOC__ true (List.length_ge [] 0);
  Alcotest.(check bool) __LOC__ true (not (List.length_ge [] 1))

let suite =
  [
    ("concat_map", `Quick, test_concat_map);
    ("stable_group", `Quick, test_stable_group);
    ("map_last", `Quick, test_map_last);
    ("map", `Quick, test_map);
    ("split_at", `Quick, test_split_at);
    ("split_at_last", `Quick, test_split_at_last);
    ("length_larger_than_n", `Quick, test_length_larger_than_n);
    ("length_ge", `Quick, test_length_ge);
  ]
