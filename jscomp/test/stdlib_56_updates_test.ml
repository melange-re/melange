let eq expected actual = assert (expected = actual)

module Collision_table = Hashtbl.Make (struct
  type t = int
  let equal = Int.equal
  let hash _ = 0
end)

let () =
  Mt.from_suites __MODULE__
    [
      ( "string slicing handles nonpositive integer endpoints",
        fun () ->
          List.iter
            (fun n ->
              eq "" (String.take_first n "ab");
              eq "" (String.take_last n "ab");
              eq "ab" (String.drop_last n "ab");
              eq "" (StringLabels.take_first n "ab");
              eq "" (StringLabels.take_last n "ab");
              eq "ab" (StringLabels.drop_last n "ab"))
            [ min_int; min_int + 1; -1; 0 ] );
      ( "hashtable filtering stays consistent when callbacks raise",
        fun () ->
          let module H = Collision_table in
          let bindings h = List.sort compare (List.of_seq (H.to_seq h)) in
          let h = H.create 16 in
          List.iter (fun k -> H.add h k k) [ 0; 1; 2 ];
          for _ = 1 to 4 do
            (try
               H.filter_map_inplace
                 (fun k _ -> if k = 2 then None else raise Exit) h;
               assert false
             with Exit -> ());
            eq 2 (H.length h);
            eq [ (0, 0); (1, 1) ] (bindings h)
          done;
          let h = H.create 16 in
          List.iter (fun k -> H.add h k k) [ 3; 2; 1 ];
          (try
             H.filter_map_inplace
               (fun k _ ->
                 match k with
                 | 1 -> Some 10
                 | 2 -> None
                 | _ -> raise Exit) h;
             assert false
           with Exit -> ());
          eq 2 (H.length h);
          eq [ (1, 10); (3, 3) ] (bindings h) );
      ( "scanf respects field widths in escaped strings",
        fun () ->
          let fails f =
            assert (
              match f () with
              | _ -> false
              | exception Scanf.Scan_failure _ -> true)
          in
          eq "\123" (Scanf.sscanf {|"\123"|} "%6S" Fun.id);
          eq "A" (Scanf.sscanf {|"\x41"|} "%6S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\123abc"|} "%3S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\123"|} "%5S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\x41"|} "%4S" Fun.id);
          eq 'a' (Scanf.sscanf "'a'" "%C" Fun.id);
          eq 'A' (Scanf.sscanf {|'\x41'|} "%C" Fun.id) );
      ( "scanf stops at exhausted field widths",
        fun () ->
          let fails f =
            assert (
              match f () with
              | _ -> false
              | exception Scanf.Scan_failure _ -> true)
          in
          eq 1 (Scanf.sscanf "+1234" "%2d" Fun.id);
          eq (-1) (Scanf.sscanf "-1234" "%2i" Fun.id);
          eq 0.1 (Scanf.sscanf "1e-1" "%4f" Fun.id);
          eq 0 (Scanf.sscanf "0123" "%1i" Fun.id);
          fails (fun () -> Scanf.sscanf "+1234" "%0d" Fun.id);
          fails (fun () -> Scanf.sscanf "-1234" "%0i" Fun.id);
          fails (fun () -> Scanf.sscanf "-1.5" "%0f" Fun.id);
          fails (fun () -> Scanf.sscanf "1e-1" "%2f" Fun.id);
          fails (fun () -> Scanf.sscanf "0123" "%0i" Fun.id);
          fails (fun () -> Scanf.sscanf {|"abc"|} "%0S" Fun.id) ) ]
