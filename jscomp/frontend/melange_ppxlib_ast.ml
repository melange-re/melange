module Convert = Ppxlib_ast.Select_ast (Ppxlib_ast__.Versions.OCaml_414)

module Of_ppxlib = struct
  include Convert.To_ocaml

  let copy_structure ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure =
      copy_structure ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.structure)

  let copy_signature ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.signature =
      copy_signature ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.signature)

  let copy_toplevel_phrase ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.toplevel_phrase
        =
      copy_toplevel_phrase ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.toplevel_phrase)

  let copy_core_type ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.core_type =
      copy_core_type ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.core_type)

  let copy_expression ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.expression =
      copy_expression ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.expression)

  let copy_pattern ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.pattern =
      copy_pattern ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.pattern)

  let copy_case ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.case =
      copy_case ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.case)

  let copy_type_declaration ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.type_declaration
        =
      copy_type_declaration ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.type_declaration)

  let copy_type_extension ast =
    let ast_414 : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.type_extension =
      copy_type_extension ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.type_extension)

  let copy_extension_constructor ast =
    let ast_414 :
        Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.extension_constructor =
      copy_extension_constructor ast
    in
    (Obj.magic ast_414 : Melange_compiler_libs.Parsetree.extension_constructor)

  let copy_payload (payload : Ppxlib.Parsetree.payload) :
      Melange_compiler_libs.Parsetree.payload =
    match payload with
    | PStr structure -> PStr (copy_structure structure)
    | PSig signature -> PSig (copy_signature signature)
    | PTyp core_type -> PTyp (copy_core_type core_type)
    | PPat (pattern, expression) ->
        PPat (copy_pattern pattern, Option.map copy_expression expression)
end

module To_ppxlib = struct
  include Convert.Of_ocaml

  let copy_structure (ast : Melange_compiler_libs.Parsetree.structure) =
    let ast_414 =
      copy_structure
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure)
    in
    (ast_414 : Ppxlib.structure)

  let copy_signature (ast : Melange_compiler_libs.Parsetree.signature) =
    let ast_414 =
      copy_signature
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.signature)
    in
    ast_414

  let copy_toplevel_phrase
      (ast : Melange_compiler_libs.Parsetree.toplevel_phrase) =
    let ast_414 =
      copy_toplevel_phrase
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.toplevel_phrase)
    in
    ast_414

  let copy_core_type (ast : Melange_compiler_libs.Parsetree.core_type) =
    let ast_414 =
      copy_core_type
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.core_type)
    in
    ast_414

  let copy_expression (ast : Melange_compiler_libs.Parsetree.expression) =
    let ast_414 =
      copy_expression
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.expression)
    in
    ast_414

  let copy_pattern (ast : Melange_compiler_libs.Parsetree.pattern) =
    let ast_414 =
      copy_pattern
        (Obj.magic ast : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.pattern)
    in
    ast_414

  let copy_case (ast : Melange_compiler_libs.Parsetree.case) =
    let ast_414 =
      copy_case
        (Obj.magic ast : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.case)
    in
    ast_414

  let copy_type_declaration
      (ast : Melange_compiler_libs.Parsetree.type_declaration) =
    let ast_414 =
      copy_type_declaration
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.type_declaration)
    in
    ast_414

  let copy_type_extension (ast : Melange_compiler_libs.Parsetree.type_extension)
      =
    let ast_414 =
      copy_type_extension
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.type_extension)
    in
    ast_414

  let copy_extension_constructor
      (ast : Melange_compiler_libs.Parsetree.extension_constructor) =
    let ast_414 =
      copy_extension_constructor
        (Obj.magic ast
          : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.extension_constructor)
    in
    ast_414

  let copy_payload (payload : Melange_compiler_libs.Parsetree.payload) :
      Ppxlib.Parsetree.payload =
    match payload with
    | PStr structure -> PStr (copy_structure structure)
    | PSig signature -> PSig (copy_signature signature)
    | PTyp core_type -> PTyp (copy_core_type core_type)
    | PPat (pattern, expression) ->
        PPat (copy_pattern pattern, Option.map copy_expression expression)
end
