let eq expected actual = assert (expected = actual)

let invalid_argument f =
  assert (
    match f () with
    | _ -> false
    | exception Invalid_argument _ -> true)

module Int_map = Map.Make (Int)
module Int_set = Set.Make (Int)
module Min_queue = Pqueue.MakeMin (Int)
module Max_queue = Pqueue.MakeMax (Int)

let rec drain pop =
  match pop () with None -> [] | Some x -> x :: drain pop

let () =
  Mt.from_suites __MODULE__
    [ ( "array paired fold order and labels",
        fun () ->
          let a = [| 1; 2; 3 |] and b = [| 4; 5; 6 |] in
          let left acc x y = acc ^ string_of_int (x + y) in
          let right x y acc = acc ^ string_of_int (x + y) in
          eq "579" (Array.fold_left2 left "" a b);
          eq "975" (Array.fold_right2 right a b "");
          eq "579" (ArrayLabels.fold_left2 ~f:left ~init:"" a b);
          eq "975" (ArrayLabels.fold_right2 ~f:right a b ~init:"") );
      ( "array paired folds validate lengths before callbacks",
        fun () ->
          let calls = ref 0 in
          let f acc _ _ = incr calls; acc in
          eq 42 (Array.fold_left2 f 42 [||] [||]);
          eq 42 (Array.fold_right2 f [||] [||] 42);
          invalid_argument (fun () -> Array.fold_left2 f 0 [| 1 |] [||]);
          invalid_argument (fun () -> Array.fold_right2 f [||] [| 1 |] 0);
          eq 0 !calls );
      ( "list append maps preserve order and the tail",
        fun () ->
          let tail = [ 10; 20 ] in
          let f x = x + 1 in
          List.iter
            (fun n ->
              let input = List.init n Fun.id in
              eq (List.map f input @ tail) (List.append_map f input tail);
              eq (List.rev_map f input @ tail)
                (List.rev_append_map f input tail))
            [ 0; 1; 2; 3; 7 ];
          let calls = ref [] in
          let mapped =
            List.append_map
              (fun x -> calls := x :: !calls; x + 1)
              [ 1; 2; 3; 4; 5 ] tail
          in
          eq [ 5; 4; 3; 2; 1 ] !calls;
          assert (List.append_map f [] tail == tail);
          assert (List.rev_append_map f [] tail == tail);
          (match mapped with
          | _ :: _ :: _ :: _ :: _ :: rest -> assert (rest == tail)
          | _ -> assert false);
          eq [ 2; 3; 10; 20 ]
            (ListLabels.append_map ~f [ 1; 2 ] tail);
          eq [ 3; 2; 10; 20 ]
            (ListLabels.rev_append_map ~f [ 1; 2 ] tail) );
      ( "string prefix and suffix removal",
        fun () ->
          List.iter
            (fun (prefix, input, expected) ->
              eq expected (String.drop_prefix ~prefix input);
              eq expected (StringLabels.drop_prefix ~prefix input))
            [ ("", "", Some ""); ("", "abc", Some "abc");
              ("abc", "abc", Some ""); ("a", "abc", Some "bc");
              ("abcd", "abc", None); ("b", "abc", None) ];
          List.iter
            (fun (suffix, input, expected) ->
              eq expected (String.drop_suffix ~suffix input);
              eq expected (StringLabels.drop_suffix ~suffix input))
            [ ("", "", Some ""); ("", "abc", Some "abc");
              ("abc", "abc", Some ""); ("c", "abc", Some "ab");
              ("abcd", "abc", None); ("b", "abc", None) ] );
      ( "Uchar ASCII and Latin1 boundaries",
        fun () ->
          eq [ (true, true); (true, true); (false, true);
               (false, true); (false, false) ]
            (List.map
               (fun n ->
                 let u = Uchar.of_int n in
                 (Uchar.is_ascii u, Uchar.is_latin1 u))
               [ 0; 127; 128; 255; 256 ]);
          eq '\000' (Uchar.ascii_to_char Uchar.min);
          eq '\127' (Uchar.ascii_to_char (Uchar.of_int 127));
          eq '\255' (Uchar.latin1_to_char (Uchar.of_int 255));
          invalid_argument (fun () -> Uchar.ascii_to_char (Uchar.of_int 128));
          invalid_argument (fun () -> Uchar.latin1_to_char (Uchar.of_int 256)) );
      ( "option and result fallbacks are lazy",
        fun () ->
          let calls = ref 0 in
          let present = Some (ref 1) in
          let fallback () = incr calls; Some (ref 2) in
          assert (Option.try_value present fallback == present);
          eq 0 !calls;
          eq (Some (ref 2)) (Option.try_value None fallback);
          eq 1 !calls;
          eq None (Option.try_value None (fun () -> None));
          let success = Ok (ref 3) in
          let recover error = incr calls; eq "error" error; Ok (ref 4) in
          assert (Result.try_value success recover == success);
          eq 1 !calls;
          eq (Ok (ref 4)) (Result.try_value (Error "error") recover);
          eq 2 !calls;
          eq (Error "next")
            (Result.try_value (Error "error") (fun _ -> Error "next")) );
      ( "map and set singleton extraction",
        fun () ->
          eq None (Int_map.singleton_to_binding Int_map.empty);
          eq (Some (1, "one"))
            (Int_map.singleton_to_binding (Int_map.singleton 1 "one"));
          eq None
            (Int_map.singleton_to_binding
               (Int_map.of_list [ (1, "one"); (2, "two") ]));
          eq None (Int_set.singleton_to_elt Int_set.empty);
          eq (Some 1) (Int_set.singleton_to_elt (Int_set.singleton 1));
          eq None (Int_set.singleton_to_elt (Int_set.of_list [ 1; 2 ])) );
      ( "set operations preserve physical identity",
        fun () ->
          let s = Int_set.of_list [ 1; 2; 3; 4; 5 ] in
          assert (Int_set.union s s == s);
          assert (Int_set.inter s s == s);
          assert (Int_set.is_empty (Int_set.diff s s));
          let t = Int_set.of_list [ 3; 4; 6 ] in
          eq [ 1; 2; 3; 4; 5; 6 ] (Int_set.elements (Int_set.union s t));
          eq [ 3; 4 ] (Int_set.elements (Int_set.inter s t));
          eq [ 1; 2; 5 ] (Int_set.elements (Int_set.diff s t)) );
      ( "sequence ranges and repeated tails",
        fun () ->
          eq [ -2; -1; 0; 1; 2 ]
            (List.of_seq (Seq.ints_in_range ~first:(-2) ~last:2));
          eq [ 3 ] (List.of_seq (Seq.ints_in_range ~first:3 ~last:3));
          eq [] (List.of_seq (Seq.ints_in_range ~first:3 ~last:2));
          let repeated = Seq.repeat 7 in
          assert (repeated () == repeated ());
          eq [ 7; 7; 7 ] (List.of_seq (Seq.take 3 repeated));
          eq [] (List.of_seq (Seq.cycle Seq.empty));
          eq [ 1; 2; 1; 2; 1 ]
            (List.of_seq (Seq.take 5 (Seq.cycle (List.to_seq [ 1; 2 ]))));
          let calls = ref 0 in
          let fresh = Seq.forever (fun () -> incr calls; !calls) in
          eq 0 !calls;
          eq [ 1; 2; 3 ] (List.of_seq (Seq.take 3 fresh));
          eq 3 !calls );
      ( "dynarray immutable-array conversions copy",
        fun () ->
          let source = Iarray.of_list [ 1; 2 ] in
          let dynamic = Dynarray.of_iarray source in
          let snapshot = Dynarray.to_iarray dynamic in
          assert (snapshot != Dynarray.to_iarray dynamic);
          Dynarray.set dynamic 0 9;
          Dynarray.append_iarray dynamic source;
          Dynarray.append_iarray dynamic (Iarray.of_list []);
          eq [ 1; 2 ] (Iarray.to_list source);
          eq [ 1; 2 ] (Iarray.to_list snapshot);
          eq [ 9; 2; 1; 2 ] (Dynarray.to_list dynamic);
          eq [] (Dynarray.to_list (Dynarray.of_iarray (Iarray.of_list [])));
          let floats = Dynarray.of_iarray (Iarray.of_list [ 1.5; 2.5 ]) in
          let saved = Dynarray.to_iarray floats in
          Dynarray.set floats 0 3.5;
          eq [ 1.5; 2.5 ] (Iarray.to_list saved) );
      ( "priority queues copy immutable arrays",
        fun () ->
          let source = Iarray.of_list [ 3; 1; 2; 1 ] in
          let min_queue = Min_queue.of_iarray source in
          let max_queue = Max_queue.of_iarray source in
          eq [ 1; 1; 2; 3 ] (drain (fun () -> Min_queue.pop_min min_queue));
          eq [ 3; 2; 1; 1 ] (drain (fun () -> Max_queue.pop_max max_queue));
          eq [ 3; 1; 2; 1 ] (Iarray.to_list source) );
      ( "format immutable and dynamic arrays",
        fun () ->
          let pp_sep ppf () = Format.pp_print_string ppf ";" in
          let pp_iarray = Format.pp_print_iarray ~pp_sep Format.pp_print_int in
          let pp_dynarray = Format.pp_print_dynarray ~pp_sep Format.pp_print_int in
          eq "1;2;3" (Format.asprintf "%a" pp_iarray (Iarray.of_list [ 1; 2; 3 ]));
          eq "" (Format.asprintf "%a" pp_iarray (Iarray.of_list []));
          eq "1;2;3" (Format.asprintf "%a" pp_dynarray (Dynarray.of_list [ 1; 2; 3 ]));
          eq "" (Format.asprintf "%a" pp_dynarray (Dynarray.create ())) ) ]
