open OpamTypes

let log ?level fmt = OpamConsole.log "FILTER" ?level fmt

let rec map_up f = function
  | FOp (l, op, r) -> f (FOp (map_up f l, op, map_up f r))
  | FAnd (l, r) -> f (FAnd (map_up f l, map_up f r))
  | FOr (l, r) -> f (FOr (map_up f l, map_up f r))
  | FNot x -> f (FNot (map_up f x))
  | FUndef x -> f (FUndef (map_up f x))
  | (FBool _ | FString _ | FIdent _ | FDefined _) as flt -> f flt

let desugar_fident ((packages, var, converter) as fident) =
  let enable = OpamVariable.of_string "enable" in
  if packages <> [] && var = enable && converter = None then
    (packages, OpamVariable.of_string "installed", Some ("enable", "disable"))
  else fident

let resolve_ident_raw ?(no_undef_expand = false) env fident =
  let open OpamStd.Option.Op in
  let packages, var, converter = desugar_fident fident in
  let bool_of_value = function
    | B b -> Some b
    | S s | L [ s ] -> (
        try Some (bool_of_string s) with Invalid_argument _ -> None)
    | L _ -> None
  in
  let resolve name =
    let var =
      match name with
      | Some n -> OpamVariable.Full.create n var
      | None -> OpamVariable.Full.self var
    in
    env var
  in
  let value_opt : variable_contents option =
    match packages with
    | [] -> env (OpamVariable.Full.global var)
    | [ name ] -> resolve name
    | names ->
        List.fold_left
          (fun acc name ->
            if acc = Some false then acc
            else
              match resolve name with
              | Some (B true) -> acc
              | v -> v >>= bool_of_value)
          (Some true) names
        >>| fun b -> B b
  in
  match (converter, no_undef_expand) with
  | Some (iftrue, iffalse), false -> (
      match value_opt >>= bool_of_value with
      | Some true -> Some (S iftrue)
      | Some false -> Some (S iffalse)
      | None -> Some (S iffalse))
  | _ -> value_opt

(* Resolves [FIdent] to string or bool, using its package and converter
   specification *)
let resolve_ident ?no_undef_expand env fident =
  let open OpamTypes in
  match resolve_ident_raw ?no_undef_expand env fident with
  | Some (B b) -> FBool b
  | Some (S s) -> FString s
  | Some (L l) -> FString (String.concat " " l)
  | None -> FUndef (FIdent fident)

let value_bool ?default =
  let open OpamTypes in
  function
  | FBool b ->
      print_endline "FBool";
      b
  | FString "true" ->
      print_endline "FString true";
      true
  | FString "false" ->
      print_endline "FString false";
      false
  | FUndef f -> (
      print_endline "FUndef";
      match default with
      | Some d -> d
      | None ->
          failwith ("Undefined boolean filter value: " ^ OpamFilter.to_string f)
      )
  | e -> (
      match default with
      | Some d -> d
      | None ->
          raise (Invalid_argument ("value_bool: " ^ OpamFilter.to_string e)))

let escape_expansions = Re.replace_string Re.(compile @@ char '%') ~by:"%%"

let escape_strings =
  map_up @@ function FString s -> FString (escape_expansions s) | flt -> flt

let value_string ?default = function
  | FBool b -> string_of_bool b
  | FString s -> s
  | FUndef f -> (
      match default with
      | Some d -> d
      | None ->
          failwith ("Undefined string filter value: " ^ OpamFilter.to_string f))
  | e -> raise (Invalid_argument ("value_string: " ^ OpamFilter.to_string e))

let logop1 cstr op = function
  | FUndef f -> FUndef (cstr f)
  | e -> (
      try FBool (op (value_bool e))
      with Invalid_argument s ->
        log "ERR: %s" s;
        FUndef (cstr e))

let logop2 cstr op absorb e f =
  match (e, f) with
  | _, FBool x when x = absorb -> FBool x
  | FBool x, _ when x = absorb -> FBool x
  | FUndef x, FUndef y | FUndef x, y | x, FUndef y -> FUndef (cstr x y)
  | f, g -> (
      try FBool (op (value_bool f) (value_bool g))
      with Invalid_argument s ->
        log "ERR: %s" s;
        FUndef (cstr f g))

let rec reduce_aux ?no_undef_expand ~default_str env =
  let open OpamTypes in
  let reduce = reduce ?no_undef_expand ~default_str env in
  function
  | FUndef x -> FUndef x
  | FBool b -> FBool b
  | FString s -> FString s
  | FIdent i -> resolve_ident ?no_undef_expand env i
  | FOp (e, relop, f) -> (
      print_endline "FOp";
      match (reduce e, reduce f) with
      | FUndef x, FUndef y -> FUndef (FOp (x, relop, y))
      | FUndef x, y -> FUndef (FOp (x, relop, escape_strings y))
      | x, FUndef y -> FUndef (FOp (escape_strings x, relop, y))
      | e, f ->
        print_endline ("value_string e " ^ (value_string e));
        print_endline ("value_string f " ^ (value_string f));
          FBool
            (OpamFormula.check_relop relop
               (OpamVersionCompare.compare (value_string e) (value_string f))))
  | FAnd (e, f) ->
      print_endline "FAND";
      logop2 (fun e f -> FAnd (e, f)) ( && ) false (reduce e) (reduce f)
  | FOr (e, f) ->
      logop2 (fun e f -> FOr (e, f)) ( || ) true (reduce e) (reduce f)
  | FNot e -> logop1 (fun e -> FNot e) not (reduce e)
  | FDefined e -> (
      match reduce e with FUndef _ -> FBool false | _ -> FBool true)

and reduce ?no_undef_expand ?(default_str = Some (fun _ -> "")) env e =
  match reduce_aux ?no_undef_expand ~default_str env e with
  | FString s -> (
      print_endline ("Fstring inn " ^ s);
      try FString (OpamFilter.expand_string ?default:default_str env s)
      with Failure _ ->
        print_endline "FAILYRE";
        FUndef (FString (OpamFilter.expand_string ~partial:true env s)))
  | e -> e

let eval_to_bool ?default env e = value_bool ?default (reduce env e)
