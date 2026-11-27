let check src_pos dst_pos len =
  let src = Dynarray.of_list [ 1; 2; 3 ] in
  let dst = Dynarray.of_list [ 4; 5; 6 ] in
  assert (
    match Dynarray.blit ~src ~src_pos ~dst ~dst_pos ~len with
    | () -> false
    | exception Invalid_argument _ -> true);
  assert (Dynarray.length dst = 3);
  assert (Dynarray.to_list dst = [ 4; 5; 6 ])

let () =
  Mt.from_suites __MODULE__
    [
      ( "source position overflow leaves the destination unchanged",
        fun () -> check max_int 3 1 );
      ( "target position overflow leaves the destination unchanged",
        fun () -> check 0 max_int 1 );
      ( "source length overflow leaves the destination unchanged",
        fun () -> check 1 3 max_int );
    ]
