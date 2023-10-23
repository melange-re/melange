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

let get_type_defs (ast : Parsetree.structure) =
  let types_with_deriving_definitions, deriving_attrs =
    List.filter_map
      ~f:(fun { Parsetree.pstr_desc; _ } ->
        match pstr_desc with
        | Pstr_type (_, tdcls) -> (
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
