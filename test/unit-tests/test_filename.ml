let test_chop_all_extensions_maybe () =
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe "a.bs.js")
    "a";
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe "a.js")
    "a";
  Alcotest.(check string) __LOC__ (Filename.chop_all_extensions_maybe "a") "a";
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe "a.x.bs.js")
    "a"

let test_new_extension () =
  Alcotest.(check string)
    __LOC__
    (Filename.new_extension "a.c" ~ext:".xx")
    "a.xx";
  Alcotest.(check string)
    __LOC__
    (Filename.new_extension "abb.c" ~ext:".xx")
    "abb.xx";
  Alcotest.(check string) __LOC__ (Filename.new_extension ".c" ~ext:".xx") ".xx";
  Alcotest.(check string)
    __LOC__
    (Filename.new_extension "a/b" ~ext:".xx")
    "a/b.xx";
  Alcotest.(check string)
    __LOC__
    (Filename.new_extension "a/b." ~ext:".xx")
    "a/b.xx";
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe "a.b.x")
    "a";
  Alcotest.(check string) __LOC__ (Filename.chop_all_extensions_maybe "a.b") "a";
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe ".a.b.x")
    "";
  Alcotest.(check string)
    __LOC__
    (Filename.chop_all_extensions_maybe "abx")
    "abx"

let suite =
  [
    ("new_extension", `Quick, test_new_extension);
    ("chop_all_extensions_maybe", `Quick, test_chop_all_extensions_maybe);
  ]
