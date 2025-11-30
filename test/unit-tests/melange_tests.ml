let () =
  Alcotest.run "Melange unit tests"
    [
      ("array", Test_array.suite);
      ("ident mask", Test_ident_mask.suite);
      ("vec", Test_vec.suite);
      ("path", Test_path.suite);
      ("list", Test_list.suite);
      ("string", Test_string.suite);
      ("filename", Test_filename.suite);
      ("modulename", Test_modulename.suite);
      ("unicode", Test_unicode.suite);
      ("scc", Test_scc.suite);
    ]
