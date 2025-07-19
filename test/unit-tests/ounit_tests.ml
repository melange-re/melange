open Melstd

module Int_array = Vec.Make (struct
  type t = int

  let null = 0
end)

let ( >::: ) = OUnit.( >::: )

let suites =
  __FILE__
  >::: [
         Ounit_vec_test.suites;
         Ounit_path_tests.suites;
         Ounit_array_tests.suites;
         Ounit_scc_tests.suites;
         Ounit_list_test.suites;
         Ounit_hash_set_tests.suites;
         Ounit_bal_tree_tests.suites;
         Ounit_map_tests.suites;
         Ounit_hashtbl_tests.suites;
         Ounit_string_tests.suites;
         Ounit_int_vec_tests.suites;
         Ounit_ident_mask_tests.suites;
         Ounit_unicode_tests.suites;
       ]

let _ = OUnit.run_test_tt_main suites
