let invalid_arg_message f =
  match f () with
  | _ -> None
  | exception Invalid_argument msg -> Some msg

let of_list = Dynarray.of_list

let cases =
  [
    ( "Dynarray.set: index 0 out of bounds (empty dynarray)",
      fun () -> Dynarray.set (Dynarray.create ()) 0 1 );
    ( "Dynarray.set: index 5 out of bounds (0..1)",
      fun () -> Dynarray.set (of_list [ 1; 2 ]) 5 0 );
    ( "Dynarray.get: index 3 out of bounds (0..1)",
      fun () ->
        let a = of_list [ 1; 2 ] in
        Dynarray.set_capacity a 8;
        ignore (Dynarray.get a 3) );
    ( "Dynarray.make: negative length -1 requested",
      fun () -> ignore (Dynarray.make (-1) 0) );
    ( "Dynarray.init: negative length -2147483648 requested",
      fun () -> ignore (Dynarray.init min_int Fun.id) );
    ( "Dynarray.truncate: negative length -3 requested",
      fun () -> Dynarray.truncate (of_list [ 1 ]) (-3) );
    ( "Dynarray.ensure_capacity: negative capacity -1 requested",
      fun () -> Dynarray.ensure_capacity (of_list [ 1 ]) (-1) );
    ( "Dynarray.set_capacity: negative capacity -4 requested",
      fun () -> Dynarray.set_capacity (of_list [ 1 ]) (-4) );
    ( "Dynarray.ensure_capacity: cannot grow to requested length 3000000000 \
       (max_array_length is 2147483647)",
      fun () -> Dynarray.ensure_capacity (of_list [ 1 ]) (Obj.magic 3e9) );
    ( "Dynarray.get_last: empty array",
      fun () -> ignore (Dynarray.get_last (Dynarray.create ())) );
    ( "Dynarray.exists2: array length mismatch: 1 <> 2",
      fun () -> ignore (Dynarray.exists2 ( = ) (of_list [ 1 ]) (of_list [ 1; 2 ]))
    );
    ( "Dynarray.for_all2: array length mismatch: 2 <> 0",
      fun () ->
        ignore (Dynarray.for_all2 ( = ) (of_list [ 1; 2 ]) (Dynarray.create ()))
    );
    ( "Dynarray.stable_sort_sub: subarray (1..3) out of bounds (0..1)",
      fun () -> Dynarray.stable_sort_sub compare (of_list [ 2; 1 ]) ~pos:1 ~len:3
    );
    ( "Dynarray.stable_sort_sub: subarray (-1..-1) out of bounds (0..-1)",
      fun () ->
        Dynarray.stable_sort_sub compare (Dynarray.create ()) ~pos:(-1) ~len:1 );
    ( "Dynarray.blit: invalid blit length (-1)",
      fun () ->
        let a = of_list [ 1; 2; 3 ] in
        Dynarray.blit ~src:a ~src_pos:0 ~dst:a ~dst_pos:0 ~len:(-1) );
    ( "Dynarray.blit: invalid source region (2..4) in source dynarray of \
       length 3",
      fun () ->
        let a = of_list [ 1; 2; 3 ] in
        Dynarray.blit ~src:a ~src_pos:2 ~dst:a ~dst_pos:0 ~len:2 );
    ( "Dynarray.blit: invalid target region (4..5) in target dynarray of \
       length 3",
      fun () ->
        let a = of_list [ 1; 2; 3 ] in
        Dynarray.blit ~src:a ~src_pos:0 ~dst:a ~dst_pos:4 ~len:1 );
    ( "Dynarray.iter: a length change from 2 to 3 occurred during iteration",
      fun () ->
        let a = of_list [ 1; 2 ] in
        let added = ref false in
        Dynarray.iter
          (fun x ->
            if not !added then (
              added := true;
              Dynarray.add_last a x))
          a );
  ]

let () =
  Mt.from_pair_suites __MODULE__
    (List.map
       (fun (expected, f) ->
         (expected, fun () -> Mt.Eq (Some expected, invalid_arg_message f)))
       cases)
