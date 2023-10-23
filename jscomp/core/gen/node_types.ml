(*
function getTypeDefs(parseOutput) {
  var rootNode = parseOutput.rootNode;
  var compilationUnit = nodeToObject(rootNode);
  var type_definitions = compilationUnit.children;

  // filter toplevel types has item_attribute
  var has_deriving_type_definitions =
      type_definitions.filter((type_defintion) => {
        // var children = type_defintion.children;
        var last = type_defintion.lastChild.lastChild;
        return last.type === "item_attribute";
      });
  var typedefs = has_deriving_type_definitions.map((type_definition) => {
    var excludes = new Set(extractExcludes(type_definition));
    var all = new Set(type_definition.children.map((x) => x.mainText));
    return {
      names : {all, excludes},
      types : type_definition.children.map((x) => {
        var children = x.children;
        // var len = children.length;
        return {
          name : children[0].text, // we ask no type parameter redefined
          def : children[1],       // there maybe trailing attributes
          // params: children.slice(0, len - 2),
        };
      }),
    };
  });
  // .reduce((x, y) => x.concat(y));
  console.log("typedeefs: ", typedefs[0].types.map(x => x.name));
  return typedefs;
}
*)
[@@@ocaml.warning "-26"]

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
