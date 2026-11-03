open Melangelib

let check_bindings label expected bindings =
  Alcotest.(check (list string))
    label
    (String.Set.elements (String.Set.of_list expected))
    (String.Set.elements bindings)

let declarations =
  [
    ( "declarations",
      {|function helper(arg) { var hidden; }
        var variable;
        let lexical;
        const constant = 1;
        class Constructor { method(arg) { var hidden; } }|},
      [ "helper"; "variable"; "lexical"; "constant"; "Constructor" ] );
    ( "destructuring",
      {|const {Math: renamed, shorthand, nested: {value}, ...rest} = object;
        let [first, , {key: second}, ...tail] = array;|},
      [ "renamed"; "shorthand"; "value"; "rest"; "first"; "second"; "tail" ] );
    ( "hoisted declarations",
      {|if (true) { var conditional; let blockLocal; }
        for (let item of []) { var loop; }
        for (var index = 0; index < 1; index++) {}
        switch (0) { case 0: var switched; let lexical; }
        try { var tried; } catch (error) { var caught; }
        finally { var finalized; }|},
      [
        "conditional";
        "loop";
        "index";
        "switched";
        "tried";
        "caught";
        "finalized";
      ] );
    ( "nested scopes",
      {|function outer(Math) { var parseInt; }
        const arrow = (Promise) => { var inner; };
        { let Math; const parseInt = 0; function blockFunction() {} }
        for (let Array of []) {}
        try {} catch (JSON) {}
        class Outer { static { var inner; } }|},
      [ "outer"; "arrow"; "Outer" ] );
    ( "imports",
      {|import {isAbsolute as localImport, join} from "node:path";
        import localDefault from "node:path";
        import * as localNamespace from "node:path";
        import "node:fs";|},
      [ "localImport"; "join"; "localDefault"; "localNamespace" ] );
    ( "references are not bindings",
      {|Math.abs(value); ({key: assigned} = object);|},
      [] );
    ("duplicate declarations", "var value; var value;", [ "value" ]);
  ]

let test_classification () =
  List.iter [ ""; "// comment"; "/* comment */" ] ~f:(fun code ->
      let kind, bindings =
        Melange_ffi.Classify_function.classify_stmt ~loc:Location.none code
      in
      Alcotest.(check bool)
        code true
        (kind = Melange_ffi.Js_raw_info.Js_stmt_comment);
      check_bindings code [] bindings)

let test_environment () =
  Lam_compile_env.reset ();
  Lam_compile_env.register_local_js_bindings
    (String.Set.of_list [ "helper"; "shared" ]);
  Lam_compile_env.register_local_js_bindings
    (String.Set.of_list [ "shared"; "later" ]);
  Lam_compile_env.register_local_js_binding (Ident.create_local "value'");
  check_bindings "accumulated names"
    [ "helper"; "shared"; "later"; "value$p" ]
    (Lam_compile_env.get_local_js_bindings ());
  Lam_compile_env.reset ();
  check_bindings "reset" [] (Lam_compile_env.get_local_js_bindings ())

let collect lambda =
  Lam_compile_env.reset ();
  ignore (Lam_convert.convert Ident.Set.empty lambda);
  let bindings = Lam_compile_env.get_local_js_bindings () in
  Lam_compile_env.reset ();
  bindings

let test_raw_conversion () =
  let raw code =
    Lambda.Lprim
      ( Pccall (Primitive.simple ~name:"#raw_stmt" ~arity:1 ~alloc:true),
        [ Lconst (Const_immstring (code, None)) ],
        Debuginfo.Scoped_location.Loc_unknown )
  in
  let id = Ident.create_local "localExpr" in
  let lambda =
    Lambda.Llet
      ( Strict,
        Pgenval,
        id,
        Lambda.lambda_unit,
        Lsequence
          ( raw "function helper() {}",
            Lsequence (raw "const later = 1;", Lvar id) ) )
  in
  check_bindings "conversion"
    [ "localExpr"; "helper"; "later" ]
    (collect lambda);
  check_bindings "next compilation" [] (collect Lambda.lambda_unit)

let test_ocaml_bindings () =
  let id = Ident.create_local in
  let argument = id "argument" in
  let recursive = id "recursive" in
  let mutable_value = id "mutableValue" in
  let counter = id "counter" in
  let caught = id "caught" in
  let captured = id "captured" in
  let function_ =
    Lambda.lfunction' ~kind:Curried
      ~params:[ (argument, Pgenval) ]
      ~return:Pgenval ~body:(Lvar argument)
      ~attr:Lambda.default_function_attribute
      ~loc:Debuginfo.Scoped_location.Loc_unknown
  in
  let unit = Lambda.lambda_unit in
  let expressions =
    [
      Lambda.Lfunction function_;
      Lletrec ([ { Lambda.id = recursive; def = function_ } ], Lvar recursive);
      Lmutlet (Pgenval, mutable_value, unit, Lmutvar mutable_value);
      Lfor (counter, unit, unit, Upto, Lvar counter);
      Ltrywith (unit, caught, Lvar caught);
      Lstaticcatch (unit, (0, [ (captured, Pgenval) ]), Lvar captured);
    ]
  in
  let lambda =
    List.fold_right expressions ~init:unit ~f:(fun expr body ->
        Lambda.Lsequence (expr, body))
  in
  check_bindings "OCaml bindings"
    [ "argument"; "recursive"; "mutableValue"; "counter"; "caught"; "captured" ]
    (collect lambda)

let suite =
  List.map declarations ~f:(fun (name, code, expected) ->
      ( name,
        `Quick,
        fun () ->
          let kind, bindings =
            Melange_ffi.Classify_function.classify_stmt ~loc:Location.none code
          in
          Alcotest.(check bool)
            name true
            (kind = Melange_ffi.Js_raw_info.Js_stmt_unknown);
          check_bindings name expected bindings ))
  @ [
      ("classification", `Quick, test_classification);
      ("environment", `Quick, test_environment);
      ("raw conversion", `Quick, test_raw_conversion);
      ("OCaml bindings", `Quick, test_ocaml_bindings);
    ]
