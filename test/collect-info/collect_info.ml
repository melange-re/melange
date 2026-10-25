let rounds = 20

let collect_repeatedly meta lambda =
  for _ = 1 to rounds do
    Lam_pass_collect.collect_info meta lambda
  done

let make_function params =
  Lam.function_ ~attr:Lambda.default_function_attribute
    ~arity:(List.length params) ~params
    ~body:(Lam.var (List.hd params))

let fresh_meta () =
  Lam_stats.make ~export_idents:[] ~export_ident_sets:Ident.Set.empty

let anonymous () =
  let meta = fresh_meta () in
  let params = Stdlib.List.init 64 (fun _ -> Ident.create_local "arg") in
  collect_repeatedly meta (make_function params);
  (* Recollecting a function should retain only its current metadata. *)
  Alcotest.(check int)
    "parameter entries" 64
    (Ident.Hashtbl.length meta.ident_tbl)

let bound () =
  let meta = fresh_meta () in
  let fn = Ident.create_local "fn" in
  let arg = Ident.create_local "arg" in
  let lambda = Lam.let_ Strict fn (make_function [ arg ]) (Lam.var fn) in
  collect_repeatedly meta lambda;
  Alcotest.(check int)
    "parameter bindings" 1
    (List.length (Ident.Hashtbl.find_all meta.ident_tbl arg));
  Alcotest.(check int)
    "function bindings" 1
    (List.length (Ident.Hashtbl.find_all meta.ident_tbl fn));
  let second = Ident.create_local "second" in
  Lam_pass_collect.collect_info meta
    (Lam.let_ Strict fn (make_function [ arg; second ]) (Lam.var fn));
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
