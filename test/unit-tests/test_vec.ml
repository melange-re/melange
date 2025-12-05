let v = Vec_int.init 10 ~f:(fun i -> i)

let vec =
  let dump_vec fmt vec =
    Format.fprintf fmt "%a"
      (Format.pp_print_list
         ~pp_sep:(fun fmt () -> Format.pp_print_string fmt "; ")
         Format.pp_print_int)
      (Vec_int.to_list vec)
  in
  Alcotest.testable dump_vec (fun a b ->
      (Vec_int.equal ~f:(fun (x : int) y -> x = y)) a b)

let inplace_filter () =
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |]);
  ignore @@ Vec_int.push v 32;
  let capacity = Vec_int.capacity v in
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 32 |]);
  Vec_int.inplace_filter ~f:(fun x -> x mod 2 = 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 0; 2; 4; 6; 8; 32 |]);
  Vec_int.inplace_filter ~f:(fun x -> x mod 3 = 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 0; 6 |]);
  Vec_int.inplace_filter ~f:(fun x -> x mod 3 <> 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [||]);
  Alcotest.(check int) "capacity" capacity (Vec_int.capacity v);
  Vec_int.compact v;
  Alcotest.(check int) "capacity" 0 (Vec_int.capacity v)

let inplace_filter_from () =
  let v = Vec_int.of_array (Array.init 10 ~f:(fun i -> i)) in
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |]);
  Vec_int.push v 96;
  Vec_int.inplace_filter_from ~from:2 ~f:(fun x -> x mod 2 = 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 0; 1; 2; 4; 6; 8; 96 |]);
  Vec_int.inplace_filter_from ~from:2 ~f:(fun x -> x mod 3 = 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 0; 1; 6; 96 |]);
  Vec_int.inplace_filter ~f:(fun x -> x mod 3 <> 0) v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 1 |]);
  Vec_int.compact v;
  Alcotest.(check int) "capacity" 1 (Vec_int.capacity v)

let test_map () =
  let v = Vec_int.of_array (Array.init 1000 ~f:(fun i -> i)) in
  Alcotest.(check vec)
    __LOC__ (Vec_int.map ~f:succ v)
    (Vec_int.of_array (Array.init 1000 ~f:succ));
  Alcotest.(check bool) __LOC__ true (Vec_int.exists ~f:(fun x -> x >= 999) v);
  Alcotest.(check bool)
    __LOC__ true
    (not (Vec_int.exists ~f:(fun x -> x > 1000) v));
  Alcotest.(check int) "last" 999 (Vec_int.last v)

let test_elements () =
  let count = 1000 in
  let init_array = Array.init count ~f:(fun i -> i) in
  let u = Vec_int.of_array init_array in
  let v =
    Vec_int.inplace_filter_with
      ~f:(fun x -> x mod 2 = 0)
      ~cb_no:Int.Set.add ~init:Int.Set.empty u
  in
  let even, odd =
    init_array |> Array.to_list |> List.partition ~f:(fun x -> x mod 2 = 0)
  in
  Alcotest.(check (list int)) "odd" odd (Int.Set.elements v);
  Alcotest.(check vec) "even" u (Vec_int.of_array (Array.of_list even))

let test_filter () =
  let v = Vec_int.of_array [| 1; 2; 3; 4; 5; 6 |] in
  Alcotest.(check vec)
    __LOC__
    (Vec_int.filter v ~f:(fun x -> x mod 3 = 0))
    (Vec_int.of_array [| 3; 6 |]);
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 1; 2; 3; 4; 5; 6 |]);
  Vec_int.pop v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 1; 2; 3; 4; 5 |]);
  let count = ref 0 in
  let len = Vec_int.length v in
  while not (Vec_int.is_empty v) do
    Vec_int.pop v;
    incr count
  done;
  Alcotest.(check int) "len" !count len

let test_delete () =
  let count = 100 in
  let v = Vec_int.of_array (Array.init count ~f:(fun i -> i)) in
  Alcotest.(check bool)
    __LOC__ true
    (try
       Vec_int.delete v count;
       false
     with _ -> true);
  for i = count - 1 downto 10 do
    Vec_int.delete v i
  done;
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |])

let test_sub () =
  let v = Vec_int.make 5 in
  Alcotest.(check bool)
    __LOC__ true
    (try
       ignore @@ Vec_int.sub v ~off:0 ~len:2;
       false
     with Invalid_argument _ -> true);
  Vec_int.push v 1;
  Alcotest.(check bool)
    __LOC__ true
    (try
       ignore @@ Vec_int.sub v ~off:0 ~len:2;
       false
     with Invalid_argument _ -> true);
  Vec_int.push v 2;
  Alcotest.(check vec)
    __LOC__
    (Vec_int.sub v ~off:0 ~len:2)
    (Vec_int.of_array [| 1; 2 |])

let test_reserve () =
  let v = Vec_int.empty () in
  Vec_int.reserve v 1000;
  for i = 0 to 900 do
    Vec_int.push v i
  done;
  Alcotest.(check int) "len" 901 (Vec_int.length v);
  Alcotest.(check int) "capacity" 1000 (Vec_int.capacity v)

let test_capacity () =
  let v = Vec_int.of_array [| 3 |] in
  Vec_int.reserve v 10;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 3 |]);
  Vec_int.push v 1;
  Vec_int.push v 2;
  Vec_int.push v 5;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 3; 1; 2; 5 |]);
  Alcotest.(check int) "capacity" 10 (Vec_int.capacity v);
  for i = 0 to 5 do
    Vec_int.push v i
  done;
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 3; 1; 2; 5; 0; 1; 2; 3; 4; 5 |]);
  Vec_int.push v 100;
  Alcotest.(check vec)
    __LOC__ v
    (Vec_int.of_array [| 3; 1; 2; 5; 0; 1; 2; 3; 4; 5; 100 |]);
  Alcotest.(check int) "capacity" 20 (Vec_int.capacity v)

let test_empty () =
  let empty = Vec_int.empty () in
  Vec_int.push empty 3;
  Alcotest.(check vec) __LOC__ empty (Vec_int.of_array [| 3 |])

let test_of_list () =
  let lst = [ 1; 2; 3; 4 ] in
  let v = Vec_int.of_list lst in
  Alcotest.(check (list int))
    "list"
    (Vec_int.map_into_list ~f:(fun x -> x + 1) v)
    (List.map ~f:(fun x -> x + 1) lst)

let test_reverse_in_place () =
  let v = Vec_int.make 4 in
  Vec_int.push v 1;
  Vec_int.push v 2;
  Vec_int.reverse_in_place v;
  Alcotest.(check vec) __LOC__ v (Vec_int.of_array [| 2; 1 |])

let test_mem () =
  Alcotest.(check bool)
    __LOC__ true
    (Vec_int.mem 3 (Vec_int.of_list [ 1; 2; 3 ]));
  Alcotest.(check bool)
    __LOC__ true
    (not @@ Vec_int.mem 0 (Vec_int.of_list [ 1; 2 ]));

  let v = Vec_int.make 100 in
  Alcotest.(check bool) __LOC__ true (not @@ Vec_int.mem 0 v);
  Vec_int.push v 0;
  Alcotest.(check bool) __LOC__ true (Vec_int.mem 0 v)

let test_push () =
  let u = Vec_int.make 100 in
  Vec_int.push u 1;
  Alcotest.(check bool) __LOC__ true (not @@ Vec_int.mem 0 u);
  Vec_int.push u 0;
  Alcotest.(check bool) __LOC__ true (Vec_int.mem 0 u)

let suite =
  [
    (* idea
            [%loc "inplace filter" ] --> __LOC__ ^ "inplace filter"
            or "inplace filter" [@bs.loc]
         *)
    ("inplace_filter ", `Quick, inplace_filter);
    ("inplace_filter_from ", `Quick, inplace_filter_from);
    ("map ", `Quick, test_map);
    ("elements", `Quick, test_elements);
    ("filter", `Quick, test_filter);
    ("delete", `Quick, test_delete);
    ("sub", `Quick, test_sub);
    ("reserve", `Quick, test_reserve);
    ("capacity", `Quick, test_capacity);
    ("empty", `Quick, test_empty);
    ("of_list", `Quick, test_of_list);
    ("reverse_in_place", `Quick, test_reverse_in_place);
    ("mem", `Quick, test_mem);
    ("push", `Quick, test_push);
  ]
