open Import
open Types

(* Public names must be checked before Scope assigns private local suffixes.
   Importers derive property names from signatures and cannot use those suffixes. *)
let name ~top name =
  if top && String.equal name "default" then name else Ident.convert name

let check_names ~top entries =
  let seen = String.Hashtbl.create 16 in
  List.iter entries ~f:(fun (source_name, kind, loc) ->
      let exported = name ~top source_name in
      match String.Hashtbl.find_opt seen exported with
      | None -> String.Hashtbl.add seen ~key:exported ~data:(source_name, kind)
      | Some (previous_name, previous_kind) ->
          Location.raise_errorf ~loc
            "JavaScript export name %S is shared by %s `%s` and %s `%s`"
            exported previous_kind previous_name kind source_name)

let module_fields fields =
  check_names ~top:false
    (List.map fields ~f:(fun field -> (field, "binding", Location.none)))

let rec check_signature checked ~top env (sg : Types.signature) =
  let entries =
    List.filter_map sg ~f:(function
      | Sig_value (_, { val_kind = Val_prim _; _ }, _) -> None
      | Sig_value (id, value, Exported) ->
          Some (Ident.name id, "value", value.val_loc)
      | Sig_typext (id, extension, _, Exported) ->
          Some (Ident.name id, "extension constructor", extension.ext_loc)
      | Sig_module (id, Mp_present, declaration, _, Exported) ->
          Some (Ident.name id, "module", declaration.md_loc)
      | Sig_class (id, declaration, _, Exported) ->
          Some (Ident.name id, "class", declaration.cty_loc)
      | _ -> None)
  in
  check_names ~top entries;
  let env = Env.add_signature sg env in
  List.iter sg ~f:(function
    | Sig_module (_, _, declaration, _, Exported) ->
        module_type checked env declaration.md_type
    | Sig_modtype (_, { mtd_type = Some mty; _ }, Exported) ->
        module_type checked env mty
    | _ -> ())

and module_type checked env mty =
  match mty with
  | Mty_ident path -> (
      match Env.find_modtype_expansion_lazy path env with
      | exception Not_found -> ()
      | expansion ->
          let previous =
            Option.value (Path.Map.find_opt path !checked) ~default:[]
          in
          (* Keep the environment's expansion identity as well as its path:
             a functor parameter can bind the same path to another module type.
             Forcing an expansion copies it, so memoize before forcing. *)
          if not (List.exists previous ~f:(fun old -> old == expansion)) then (
            checked := Path.Map.add path (expansion :: previous) !checked;
            module_type checked env (Subst.Lazy.force_modtype expansion)))
  | Mty_signature sg -> check_signature checked ~top:false env sg
  | Mty_functor (parameter, result) ->
      let env =
        match parameter with
        | Unit -> env
        | Named (id, mty) -> (
            module_type checked env mty;
            match id with
            | None -> env
            | Some id -> Env.add_module id Mp_present mty env)
      in
      module_type checked env result
  | Mty_alias _ -> ()

let signature ~top env sg = check_signature (ref Path.Map.empty) ~top env sg
