module Id = Melstd.Ident

let javascript_globals () =
  let null = Id.create_js "null" in
  let undefined = Id.create_js "undefined" in
  Alcotest.(check bool) "different globals" false (Id.same null undefined);
  Alcotest.(check bool)
    "different globals reversed" false (Id.same undefined null);
  Alcotest.(check bool)
    "same global name" true
    (Id.same null (Id.create_js "null"))

let namespaces () =
  let js = Id.create_js "Module" in
  let persistent = Id.create_persistent "Module" in
  let local = Id.create_local "Module" in
  List.iter
    ~f:(fun id ->
      Alcotest.(check bool)
        "JavaScript and OCaml identifiers" false (Id.same js id);
      Alcotest.(check bool)
        "OCaml and JavaScript identifiers" false (Id.same id js))
    [ persistent; local ]

let ocaml_identifiers () =
  let local = Id.create_local "value" in
  Alcotest.(check bool) "same local" true (Id.same local local);
  Alcotest.(check bool)
    "distinct locals with the same name" false
    (Id.same local (Id.create_local "value"));
  Alcotest.(check bool) "renamed local" false (Id.same local (Id.rename local));
  Alcotest.(check bool)
    "same persistent name" true
    (Id.same (Id.create_persistent "Module") (Id.create_persistent "Module"));
  Alcotest.(check bool)
    "distinct persistent names" false
    (Id.same (Id.create_persistent "Module") (Id.create_persistent "Other"))

let suite =
  [
    ("JavaScript globals", `Quick, javascript_globals);
    ("identifier namespaces", `Quick, namespaces);
    ("OCaml identifiers", `Quick, ocaml_identifiers);
  ]
