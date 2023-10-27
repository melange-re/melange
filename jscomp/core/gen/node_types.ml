let extract_excludes ptype_attributes =
  match
    List.find
      ~f:(fun { Parsetree.attr_name; _ } -> attr_name.txt = "deriving")
      ptype_attributes
  with
  | {
   Parsetree.attr_payload =
     PStr
       [
         {
           pstr_desc =
             Pstr_eval
               ( {
                   pexp_desc =
                     Pexp_record
                       ( [
                           ( { txt = Lident "excludes"; _ },
                             { pexp_desc = Pexp_array labels; _ } );
                         ],
                         _ );
                   _;
                 },
                 _ );
           _;
         };
       ];
   _;
  } ->
      List.map
        ~f:(fun { Parsetree.pexp_desc; _ } ->
          match pexp_desc with
          | Pexp_ident { txt = Lident s; _ } -> s
          | _ -> assert false)
        labels
  | _ -> []

module StringSet = Set.Make (String)

type names = { all : StringSet.t; excludes : StringSet.t }
type t = { names : names; type_declarations : Parsetree.type_declaration list }

let isSupported (def : Longident.t) names =
  match def with
  | Lident def ->
      let { all = allNames; excludes } = names in
      let basic = def in
      if StringSet.mem basic allNames then
        if StringSet.mem basic excludes then `exclude basic else `yes basic
      else `no
  | _ -> `no

let get_type_defs (ast : Parsetree.signature) =
  let types_with_deriving_definitions, deriving_attrs =
    List.filter_map
      ~f:(fun { Parsetree.psig_desc; _ } ->
        match psig_desc with
        | Psig_type (_, tdcls) -> (
            match List.rev tdcls with
            | [] -> None
            | { ptype_attributes = []; _ } :: _ -> None
            | ({ ptype_attributes = _ :: _; _ } as tdcl) :: _ ->
                Some (tdcls, tdcl.ptype_attributes))
        | _ -> None)
      ast
    |> List.hd
  in
  let typedefs =
    let excludes = extract_excludes deriving_attrs |> StringSet.of_list in
    let all =
      List.map
        ~f:(fun { Parsetree.ptype_name; _ } -> ptype_name.txt)
        types_with_deriving_definitions
      |> StringSet.of_list
    in
    {
      names = { all; excludes };
      type_declarations = types_with_deriving_definitions;
    }
  in
  typedefs

let loc = Location.none

type ob = {
  eta : Ast.expression;
  beta : string -> Ast.expression;
  meth : Ast.expression option;
}

let skip_obj =
  let skip = Ast_helper.Exp.ident { txt = Lident "unknown"; loc } in
  {
    eta = skip;
    beta =
      (fun x ->
        let x = Ast_helper.Exp.ident { txt = Lident x; loc } in
        [%expr [%e skip] [%e x]]);
    meth = None;
  }
