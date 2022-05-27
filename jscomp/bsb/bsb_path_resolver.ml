open Ext_json_types

let ( // ) = Ext_path.combine
let cache : string Hash_string.t = Hash_string.create 0

let extract_paths_from_importmap cwd json =
  match json with
  | Obj { map } -> (
      match Map_string.find_opt map Bsb_build_schemas.workspace with
      | Some (Obj { map }) ->
          Map_string.bindings map
          |> List.iter (fun (key, value) ->
                 match value with
                 | Ext_json_types.Str { str } ->
                     Hash_string.add cache key (cwd // str)
                 | _ -> ())
      | _ -> ())
  | _ -> ()

let resolve_import_map_package package = Hash_string.find_opt cache package
