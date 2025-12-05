let test1 () =
  let set = Hash_set_ident_mask.create 0 in
  let a, b, _, _ =
    ( Ident.create_local "a",
      Ident.create_local "b",
      Ident.create_local "c",
      Ident.create_local "d" )
  in
  Hash_set_ident_mask.add_unmask set a;
  Hash_set_ident_mask.add_unmask set a;
  Hash_set_ident_mask.add_unmask set b;
  Alcotest.(check bool)
    __LOC__ true
    (not @@ Hash_set_ident_mask.mask_and_check_all_hit set a);
  Alcotest.(check bool)
    __LOC__ true
    (Hash_set_ident_mask.mask_and_check_all_hit set b);
  Hash_set_ident_mask.iter_and_unmask set ~f:(fun id mask ->
      if Ident.name id = "a" then Alcotest.(check bool) __LOC__ true mask
      else if Ident.name id = "b" then Alcotest.(check bool) __LOC__ true mask
      else ());
  Alcotest.(check bool)
    __LOC__ true
    (not @@ Hash_set_ident_mask.mask_and_check_all_hit set a);
  Alcotest.(check bool)
    __LOC__ true
    (Hash_set_ident_mask.mask_and_check_all_hit set b)

let test2 () =
  let len = 1000 in
  let idents =
    Array.init len ~f:(fun i -> Ident.create_local (string_of_int i))
  in
  let set = Hash_set_ident_mask.create 0 in
  Array.iter ~f:(fun i -> Hash_set_ident_mask.add_unmask set i) idents;
  for i = 0 to len - 2 do
    Alcotest.(check bool)
      __LOC__ true
      (not @@ Hash_set_ident_mask.mask_and_check_all_hit set idents.(i))
  done;
  for i = 0 to len - 2 do
    Alcotest.(check bool)
      __LOC__ true
      (not @@ Hash_set_ident_mask.mask_and_check_all_hit set idents.(i))
  done;
  Alcotest.(check bool)
    __LOC__ true
    (Hash_set_ident_mask.mask_and_check_all_hit set idents.(len - 1));
  Hash_set_ident_mask.iter_and_unmask set ~f:(fun _ _ -> ());
  for i = 0 to len - 2 do
    Alcotest.(check bool)
      __LOC__ true
      (not @@ Hash_set_ident_mask.mask_and_check_all_hit set idents.(i))
  done;
  for i = 0 to len - 2 do
    Alcotest.(check bool)
      __LOC__ true
      (not @@ Hash_set_ident_mask.mask_and_check_all_hit set idents.(i))
  done;
  Alcotest.(check bool)
    __LOC__ true
    (Hash_set_ident_mask.mask_and_check_all_hit set idents.(len - 1))

let suite = [ ("test1", `Quick, test1); ("test2", `Quick, test2) ]
