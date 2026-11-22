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
      ( "dynarray sorting handles floats with spare capacity",
        fun () ->
          let a = Dynarray.of_array [| 3.; 1.; 4.; 1.; 5.; 9.; 2.; 6. |] in
          Dynarray.ensure_capacity a 32;
          Dynarray.sort Float.compare a;
          eq [| 1.; 1.; 2.; 3.; 4.; 5.; 6.; 9. |] (Dynarray.to_array a) );
      ( "scanf accepts OCaml escape sequences",
        fun () ->
          List.iter
            (fun (input, expected) -> eq expected (Scanf.unescaped input))
            [
              ({|\o101|}, "A");
              ({|\o000\o377|}, "\000\255");
              ({|a\ b|}, "a b");
              ({|\u{41}|}, "A");
              ({|\u{e9}\u{20AC}|}, "\u{e9}\u{20AC}");
              ({|\u{1F600}|}, "\u{1F600}");
              ({|\u{00041}x|}, "Ax");
              ({|\u{10FFFF}|}, "\u{10FFFF}");
              ("a\\\n \t b", "ab");
              ("a\\\r\n \t b", "ab");
            ];
          eq 'A' (Scanf.sscanf {|'\o101'|} "%C" Fun.id);
          eq ' ' (Scanf.sscanf {|'\ '|} "%C" Fun.id);
          eq ("AB", 1)
            (Scanf.sscanf {|"\u{41}\o102" 1|} "%S %d" (fun s n -> (s, n))) );
      ( "scanf rejects malformed escapes and invalid Unicode scalars",
        fun () ->
          let fails f =
            assert (
              match f () with
              | _ -> false
              | exception Scanf.Scan_failure _ -> true)
          in
          List.iter
            (fun input -> fails (fun () -> Scanf.unescaped input))
            [
              {|\o400|};
              {|\o18|};
              {|\o12|};
              {|\u41|};
              {|\u{}|};
              {|\u{1234567}|};
              {|\u{D800}|};
              {|\u{110000}|};
              {|\u{41|};
            ];
          fails (fun () -> Scanf.sscanf {|'\u{41}'|} "%C" Fun.id) );
      ( "scanf respects field widths in escaped strings",
        fun () ->
          let fails f =
            assert (
              match f () with
              | _ -> false
              | exception Scanf.Scan_failure _ -> true)
          in
          eq "\123" (Scanf.sscanf {|"\123"|} "%6S" Fun.id);
          eq "A" (Scanf.sscanf {|"\o101"|} "%7S" Fun.id);
          eq "A" (Scanf.sscanf {|"\x41"|} "%6S" Fun.id);
          eq "A" (Scanf.sscanf {|"\u{41}"|} "%8S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\123abc"|} "%3S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\123"|} "%5S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\o101"|} "%5S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\x41"|} "%4S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\u{41}"|} "%7S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\u{41}"|} "%6S" Fun.id);
          fails (fun () -> Scanf.sscanf {|"\u{41}"|} "%5S" Fun.id);
          fails (fun () ->
              Scanf.sscanf
                ({|"\u{|} ^ String.make 100 '0' ^ {|41}"|}) "%5S" Fun.id);
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
