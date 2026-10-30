let make_function params =
  Lam.function_ ~attr:Lambda.default_function_attribute
    ~arity:(List.length params) ~params
    ~body:(Lam.var (List.hd params))

let collect_twice lambda =
  let meta =
    Lam_stats.make ~export_idents:[] ~export_ident_sets:Ident.Set.empty
  in
  Lam_pass_collect.collect_info meta lambda;
  Lam_pass_collect.collect_info meta lambda;
  meta

let anonymous () =
  let arg = Ident.create_local "arg" in
  let meta = collect_twice (make_function [ arg ]) in
  Alcotest.(check int)
    "parameter entries" 2
    (Ident.Hashtbl.length meta.ident_tbl)

let bound () =
  let fn = Ident.create_local "fn" and arg = Ident.create_local "arg" in
  let collect params = Lam.let_ Strict fn (make_function params) (Lam.var fn) in
  let meta = collect_twice (collect [ arg ]) in
  Stdlib.List.iter
    (fun id ->
      Alcotest.(check int)
        "repeated binding" 2
        (List.length (Ident.Hashtbl.find_all meta.ident_tbl id)))
    [ arg; fn ];
  Lam_pass_collect.collect_info meta
    (collect [ arg; Ident.create_local "second" ]);
  match Ident.Hashtbl.find meta.ident_tbl fn with
  | FunctionId { arity; _ } ->
      Alcotest.(check (option int))
        "metadata is refreshed" (Some 2)
        (Lam_arity.get_first_arity arity)
  | _ -> Alcotest.fail "missing function metadata"

let () =
  Alcotest.run "Repeated Lambda metadata collection"
    [
      ("entries", [ ("anonymous", `Quick, anonymous); ("bound", `Quick, bound) ]);
    ]
