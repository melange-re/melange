exception E0
exception E1 of int
exception E2 of string
exception E3 of int * string * int
exception Printed of int

let () =
  Printexc.register_printer (function
    | Printed n -> Some ("Printed " ^ string_of_int n)
    | _ -> None)

let cases =
  [
    ( "File \"main.ml\", line 12, characters 3-8: Pattern matching failed",
      Match_failure ("main.ml", 12, 3) );
    ( "File \"a \\\"b\\\"\", line -1, characters -7--1: Assertion failed",
      Assert_failure ("a \\\"b\\\"", -1, -7) );
    ( "File \"\", line 0, characters 0-6: Undefined recursive module",
      Undefined_recursive_module ("", 0, 0) );
    ( "File \"x\", line 2147483647, characters 2147483647--2147483643: \
       Assertion failed",
      Assert_failure ("x", max_int, max_int) );
    ( "File \"x\", line -2147483648, characters -2147483648--2147483643: \
       Pattern matching failed",
      Match_failure ("x", min_int, min_int) );
    ("Not_found", Not_found);
    ("Failure(boom)", Failure "boom");
    ("Invalid_argument(bad)", Invalid_argument "bad");
    ("Out of memory", Out_of_memory);
    ("Stack overflow", Stack_overflow);
    ("Printexc_to_string_test.E0/1", E0);
    ("Printexc_to_string_test.E1/1(42)", E1 42);
    ("Printexc_to_string_test.E2/1(s)", E2 "s");
    ("Printexc_to_string_test.E3/1(1x-2)", E3 (1, "x", -2));
    ("Printed 5", Printed 5);
    ("Fun.Finally_raised: Failure(inner)", Fun.Finally_raised (Failure "inner"));
    ( "Fun.Finally_raised: File \"f.ml\", line 1, characters 2-8: Assertion \
       failed",
      Fun.Finally_raised (Assert_failure ("f.ml", 1, 2)) );
    ("Fun.Finally_raised: Printed 3", Fun.Finally_raised (Printed 3));
  ]

let () =
  Mt.from_pair_suites __MODULE__
    (List.map
       (fun (expected, exn) ->
         (expected, fun () -> Mt.Eq (expected, Printexc.to_string exn)))
       cases
    @ [
        ( "to_string_default ignores printers",
          fun () ->
            Mt.Eq
              ( "Printexc_to_string_test.Printed/1(3)",
                Printexc.to_string_default (Printed 3) ) );
      ])
