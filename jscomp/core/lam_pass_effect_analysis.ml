open Import

type mode =
  | Conservative
  | Optimistic

type binding_info = {
  direct_effect : bool;
  unknown_call : bool;
  local_calls : Ident.Set.t;
}

let empty_info =
  {
    direct_effect = false;
    unknown_call = false;
    local_calls = Ident.Set.empty;
  }

let is_effect_primitive = function
  | Lam_primitive.Pccall
      { prim_name = "caml_perform" | "caml_perform_tail" } ->
      true
  | _ -> false

let mode_to_string = function
  | Conservative -> "conservative"
  | Optimistic -> "optimistic"

let mode_from_env () =
  match Sys.getenv "MELANGE_EFFECT_ANALYSIS_MODE" with
  | "optimistic" -> Optimistic
  | "conservative" -> Conservative
  | _ -> Optimistic
  | exception Not_found -> Optimistic

let add_call_if_local local_ids local_calls = function
  | Lam.Lvar id | Lmutvar id when Ident.Set.mem id local_ids ->
      Ident.Set.add id local_calls
  | _ -> local_calls

type call_classification =
  | Known_pure
  | Known_effectful
  | Unknown

let classify_module_field_call (ap_func : Lam.t) =
  match ap_func with
  | Lprim
      {
        primitive = Pfield (field_index, _);
        args = [ Lglobal_module { id; dynamic_import } ];
        loc = _;
      } -> (
      match
        Lam_compile_env.query_external_field_effect ~dynamic_import id field_index
      with
      | Some true -> Known_effectful
      | Some false -> Known_pure
      | None -> Unknown)
  | _ -> Unknown

let merge_info left right =
  {
    direct_effect = left.direct_effect || right.direct_effect;
    unknown_call = left.unknown_call || right.unknown_call;
    local_calls = Ident.Set.union left.local_calls right.local_calls;
  }

let unknown_calls_are_effectful = function
  | Conservative -> true
  | Optimistic -> false

let rec analyze_lambda ~(mode : mode) (local_ids : Ident.Set.t) (lam : Lam.t) :
    binding_info =
  match lam with
  | Lvar _ | Lmutvar _ | Lconst _ | Lglobal_module _ -> empty_info
  | Lfunction { body; _ } -> analyze_lambda ~mode local_ids body
  | Lapply { ap_func; ap_args; _ } ->
      let fn_info = analyze_lambda ~mode local_ids ap_func in
      let args_info = analyze_lambdas ~mode local_ids ap_args in
      let local_calls = add_call_if_local local_ids fn_info.local_calls ap_func in
      let call_classification =
        match ap_func with
        | Lvar id | Lmutvar id when Ident.Set.mem id local_ids -> Known_pure
        | Lvar _ | Lmutvar _ -> Unknown
        | _ -> classify_module_field_call ap_func
      in
      let unknown_call =
        fn_info.unknown_call
        ||
        match call_classification with
        | Known_pure -> false
        | Known_effectful -> false
        | Unknown -> unknown_calls_are_effectful mode
      in
      {
        direct_effect =
          fn_info.direct_effect
          || args_info.direct_effect
          ||
          (match call_classification with
          | Known_effectful -> true
          | Known_pure | Unknown -> false);
        unknown_call =
          (unknown_call && unknown_calls_are_effectful mode)
          || args_info.unknown_call;
        local_calls = Ident.Set.union local_calls args_info.local_calls;
      }
  | Llet (_, _, arg, body) | Lmutlet (_, arg, body) ->
      merge_info
        (analyze_lambda ~mode local_ids arg)
        (analyze_lambda ~mode local_ids body)
  | Lletrec (bindings, body) ->
      merge_info
        (analyze_lambdas ~mode local_ids (List.map ~f:snd bindings))
        (analyze_lambda ~mode local_ids body)
  | Lprim { primitive; args; _ } ->
      let args_info = analyze_lambdas ~mode local_ids args in
      {
        direct_effect = is_effect_primitive primitive || args_info.direct_effect;
        unknown_call = args_info.unknown_call;
        local_calls = args_info.local_calls;
      }
  | Lswitch
      ( arg,
        { sw_consts; sw_blocks; sw_failaction; sw_consts_full = _; sw_blocks_full = _; sw_names = _ }
      ) ->
      let info =
        merge_info
          (analyze_lambda ~mode local_ids arg)
          (merge_info
             (analyze_lambdas ~mode local_ids (List.map ~f:snd sw_consts))
             (analyze_lambdas ~mode local_ids (List.map ~f:snd sw_blocks)))
      in
      (match sw_failaction with
      | None -> info
      | Some lam -> merge_info info (analyze_lambda ~mode local_ids lam))
  | Lstringswitch (arg, cases, default) ->
      let info =
        merge_info
          (analyze_lambda ~mode local_ids arg)
          (analyze_lambdas ~mode local_ids (List.map ~f:snd cases))
      in
      (match default with
      | None -> info
      | Some lam -> merge_info info (analyze_lambda ~mode local_ids lam))
  | Lstaticraise (_, args) -> analyze_lambdas ~mode local_ids args
  | Lstaticcatch (body, (_, _), handler) ->
      merge_info
        (analyze_lambda ~mode local_ids body)
        (analyze_lambda ~mode local_ids handler)
  | Ltrywith (body, _, handler) ->
      merge_info
        (analyze_lambda ~mode local_ids body)
        (analyze_lambda ~mode local_ids handler)
  | Lifthenelse (pred, ifso, ifnot) ->
      merge_info
        (analyze_lambda ~mode local_ids pred)
        (merge_info
           (analyze_lambda ~mode local_ids ifso)
           (analyze_lambda ~mode local_ids ifnot))
  | Lsequence (left, right) ->
      merge_info
        (analyze_lambda ~mode local_ids left)
        (analyze_lambda ~mode local_ids right)
  | Lwhile (pred, body) ->
      merge_info
        (analyze_lambda ~mode local_ids pred)
        (analyze_lambda ~mode local_ids body)
  | Lfor (_, from_, to_, _, body) ->
      merge_info
        (analyze_lambda ~mode local_ids from_)
        (merge_info
           (analyze_lambda ~mode local_ids to_)
           (analyze_lambda ~mode local_ids body))
  | Lassign (_, rhs) -> analyze_lambda ~mode local_ids rhs
  | Lsend (_, meth, obj, args, _) ->
      let info =
        merge_info
          (analyze_lambda ~mode local_ids meth)
          (merge_info
             (analyze_lambda ~mode local_ids obj)
             (analyze_lambdas ~mode local_ids args))
      in
      {
        info with
        unknown_call = info.unknown_call || unknown_calls_are_effectful mode;
      }
  | Lifused (_, body) -> analyze_lambda ~mode local_ids body

and analyze_lambdas ~mode local_ids lams =
  List.fold_left lams ~init:empty_info ~f:(fun acc lam ->
      merge_info acc (analyze_lambda ~mode local_ids lam))

let binding_ids groups =
  List.fold_left groups ~init:Ident.Set.empty ~f:(fun acc group ->
      match group with
      | Lam_group.Single (_, id, _) -> Ident.Set.add id acc
      | Recursive bindings ->
          List.fold_left bindings ~init:acc ~f:(fun acc (id, _) ->
              Ident.Set.add id acc)
      | Nop _ -> acc)

let binding_infos ~mode groups local_ids =
  let infos = Ident.Hashtbl.create 32 in
  let add id lam =
    Ident.Hashtbl.replace infos ~key:id ~data:(analyze_lambda ~mode local_ids lam)
  in
  List.iter groups ~f:(function
    | Lam_group.Single (_, id, lam) -> add id lam
    | Recursive bindings -> List.iter bindings ~f:(fun (id, lam) -> add id lam)
    | Nop _ -> ());
  infos

let effectful_bindings ~mode groups =
  let local_ids = binding_ids groups in
  let infos = binding_infos ~mode groups local_ids in
  let rec loop effectful =
    let next =
      Ident.Hashtbl.fold infos ~init:effectful ~f:(fun ~key:id ~data:info acc ->
          if Ident.Set.mem id acc then acc
          else
            let called_effectful =
              Ident.Set.exists info.local_calls ~f:(fun dep ->
                  Ident.Set.mem dep acc)
            in
            if info.direct_effect || info.unknown_call || called_effectful then
              Ident.Set.add id acc
            else acc)
    in
    if Ident.Set.equal next effectful then effectful else loop next
  in
  loop Ident.Set.empty
