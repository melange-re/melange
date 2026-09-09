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

let suite = [ ("map", `Quick, test_map) ]
