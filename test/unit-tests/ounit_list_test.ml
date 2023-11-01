open Melstd

let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal

let printer_int_list xs =
  Format.asprintf "%a"
    (Format.pp_print_list Format.pp_print_int ~pp_sep:Format.pp_print_space)
    xs

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           OUnit.assert_equal
             (List.concat_map ~f:(fun x -> [ x; x ]) [ 1; 2 ])
             [ 1; 1; 2; 2 ] );
         ( __LOC__ >:: fun _ ->
           let ( =~ ) = OUnit.assert_equal ~printer:printer_int_list in
           List.concat_map ~f:(fun x -> [ succ x ]) [] =~ [];
           List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1 ] =~ [ 1; 2 ];
           List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1; 2 ]
           =~ [ 1; 2; 2; 3 ];
           List.concat_map ~f:(fun x -> [ x; succ x ]) [ 1; 2; 3 ]
           =~ [ 1; 2; 2; 3; 3; 4 ] );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_equal
             (List.stable_group [ 1; 2; 3; 4; 3 ] ( = ))
             [ [ 1 ]; [ 2 ]; [ 4 ]; [ 3; 3 ] ] );
         ( __LOC__ >:: fun _ ->
           let ( =~ ) = OUnit.assert_equal ~printer:printer_int_list in
           let f b _v = if b then 1 else 0 in
           List.map_last [] f =~ [];
           List.map_last [ 0 ] f =~ [ 1 ];
           List.map_last [ 0; 0 ] f =~ [ 0; 1 ];
           List.map_last [ 0; 0; 0 ] f =~ [ 0; 0; 1 ];
           List.map_last [ 0; 0; 0; 0 ] f =~ [ 0; 0; 0; 1 ];
           List.map_last [ 0; 0; 0; 0; 0 ] f =~ [ 0; 0; 0; 0; 1 ];
           List.map_last [ 0; 0; 0; 0; 0; 0 ] f =~ [ 0; 0; 0; 0; 0; 1 ];
           List.map_last [ 0; 0; 0; 0; 0; 0; 0 ] f =~ [ 0; 0; 0; 0; 0; 0; 1 ] );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_equal
             (List.map ~f:(fun x -> string_of_int x) [ 0; 1; 2 ]
             @ [ "1"; "2"; "3" ])
             [ "0"; "1"; "2"; "1"; "2"; "3" ] );
         ( __LOC__ >:: fun _ ->
           let a, b = List.split_at [ 1; 2; 3; 4; 5; 6 ] 3 in
           OUnit.assert_equal (a, b) ([ 1; 2; 3 ], [ 4; 5; 6 ]);
           OUnit.assert_equal (List.split_at [ 1 ] 1) ([ 1 ], []);
           OUnit.assert_equal (List.split_at [ 1; 2; 3 ] 2) ([ 1; 2 ], [ 3 ]) );
         ( __LOC__ >:: fun _ ->
           let printer (a, b) =
             Format.asprintf "([%a],%d)"
               (Format.pp_print_list Format.pp_print_int)
               a b
           in
           let ( =~ ) = OUnit.assert_equal ~printer in
           List.split_at_last [ 1; 2; 3 ] =~ ([ 1; 2 ], 3);
           List.split_at_last [ 1; 2; 3; 4; 5; 6; 7; 8 ]
           =~ ([ 1; 2; 3; 4; 5; 6; 7 ], 8);
           List.split_at_last [ 1; 2; 3; 4; 5; 6; 7 ]
           =~ ([ 1; 2; 3; 4; 5; 6 ], 7) );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_bool __LOC__
             (List.length_larger_than_n [ 1; 2 ] [ 1 ] 1);
           OUnit.assert_bool __LOC__
             (List.length_larger_than_n [ 1; 2 ] [ 1; 2 ] 0);
           OUnit.assert_bool __LOC__ (List.length_larger_than_n [ 1; 2 ] [] 2)
         );
         ( __LOC__ >:: fun _ ->
           OUnit.assert_bool __LOC__ (List.length_ge [ 1; 2; 3 ] 3);
           OUnit.assert_bool __LOC__ (List.length_ge [] 0);
           OUnit.assert_bool __LOC__ (not (List.length_ge [] 1)) );
       ]
