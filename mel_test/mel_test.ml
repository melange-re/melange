module Int_array = Vec.Make (struct
  type t = int

  let null = 0
end)

let ( >::: ) = OUnit.(( >::: ))
let suites = __FILE__ >::: [ Ounit_bsb_pkg_tests.suites ]
let _ = OUnit.run_test_tt_main suites
