#if OCAML_VERSION >= (5, 6, 0)

external check_array_bound : 'a array -> int -> unit = "%check_array_bound"

let suites = Mt.[
  "check_array_bound_valid", (fun () ->
    check_array_bound [|0; 1|] 1;
    Eq ((), ()));
  "check_array_bound_negative", (fun () ->
    ThrowAny (fun () -> check_array_bound [|0; 1|] (-1)));
  "check_array_bound_length", (fun () ->
    ThrowAny (fun () -> check_array_bound [|0; 1|] 2));
]

let () = Mt.from_pair_suites __MODULE__ suites

#endif
