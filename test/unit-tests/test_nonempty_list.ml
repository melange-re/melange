let nonempty = Nonempty_list.of_list_exn

let check_int_list message expected actual =
  Alcotest.(check (list int)) message expected actual

let check_nonempty_int message expected actual =
  check_int_list message expected (Nonempty_list.to_list actual)

let test_map () =
  let visited = ref [] in
  let result =
    Nonempty_list.map
      (nonempty [ 1; 2; 3 ])
      ~f:(fun x ->
        visited := x :: !visited;
        x * 2)
  in
  check_nonempty_int "values" [ 2; 4; 6 ] result;
  check_int_list "callback order" [ 1; 2; 3 ] (List.rev !visited);
  check_nonempty_int "singleton" [ 8 ]
    (Nonempty_list.map (nonempty [ 4 ]) ~f:(fun x -> x * 2))

let test_iter () =
  let visited = ref [] in
  Nonempty_list.iter
    (nonempty [ 1; 2; 3 ])
    ~f:(fun x -> visited := x :: !visited);
  check_int_list "callback order" [ 1; 2; 3 ] (List.rev !visited);
  visited := [];
  Nonempty_list.iter (nonempty [ 4 ]) ~f:(fun x -> visited := x :: !visited);
  check_int_list "singleton" [ 4 ] (List.rev !visited)

let test_to_list_rev_map () =
  let visited = ref [] in
  let result =
    Nonempty_list.to_list_rev_map
      (nonempty [ 1; 2; 3 ])
      ~f:(fun x ->
        visited := x :: !visited;
        x * 2)
  in
  check_int_list "values" [ 6; 4; 2 ] result;
  check_int_list "callback order" [ 1; 2; 3 ] (List.rev !visited);
  check_int_list "singleton" [ 8 ]
    (Nonempty_list.to_list_rev_map (nonempty [ 4 ]) ~f:(fun x -> x * 2))

let test_mapi () =
  let visited = ref [] in
  let result =
    Nonempty_list.mapi
      (nonempty [ 1; 2; 3 ])
      ~f:(fun i x ->
        visited := (i, x) :: !visited;
        (i * 10) + x)
  in
  check_nonempty_int "values" [ 1; 12; 23 ] result;
  Alcotest.(check (list (pair int int)))
    "callback order"
    [ (0, 1); (1, 2); (2, 3) ]
    (List.rev !visited);
  check_nonempty_int "singleton" [ 4 ]
    (Nonempty_list.mapi (nonempty [ 4 ]) ~f:(fun i x -> i + x))

let test_map_last () =
  let visited = ref [] in
  let result =
    Nonempty_list.map_last
      (nonempty [ 1; 2; 3 ])
      ~f:(fun is_last x ->
        visited := (is_last, x) :: !visited;
        if is_last then x * 10 else x)
  in
  check_nonempty_int "values" [ 1; 2; 30 ] result;
  Alcotest.(check (list (pair bool int)))
    "callback order"
    [ (false, 1); (false, 2); (true, 3) ]
    (List.rev !visited);
  visited := [];
  let result =
    Nonempty_list.map_last (nonempty [ 4 ]) ~f:(fun is_last x ->
        visited := (is_last, x) :: !visited;
        if is_last then x * 10 else x)
  in
  check_nonempty_int "singleton value" [ 40 ] result;
  Alcotest.(check (list (pair bool int)))
    "singleton callback"
    [ (true, 4) ]
    (List.rev !visited)

let suite =
  [
    ("map", `Quick, test_map);
    ("iter", `Quick, test_iter);
    ("to_list_rev_map", `Quick, test_to_list_rev_map);
    ("mapi", `Quick, test_mapi);
    ("map_last", `Quick, test_map_last);
  ]
