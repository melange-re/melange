open Import

type t =
  | Unknown
  | Direct_primitive of Lam_primitive.t
  | Direct_external of {
      dynamic_import : bool;
      id : Ident.t;
      name : string;
      arity : Lam_arity.t;
      relocatable : bool;
    }

let print fmt = function
  | Unknown -> Format.fprintf fmt "Unknown"
  | Direct_primitive primitive ->
      Format.fprintf fmt "Direct(%a)" Lam_print.primitive primitive
  | Direct_external { dynamic_import; id; name; arity = _; relocatable = _ } ->
      Format.fprintf fmt "Direct(%s%s.%s)"
        (if dynamic_import then "import " else "")
        (Ident.name id) name

let is_unknown = function
  | Unknown -> true
  | Direct_primitive _ | Direct_external _ -> false

let is_relocatable = function
  | Unknown -> true
  | Direct_primitive primitive -> Lam_primitive.is_relocatable primitive
  | Direct_external { relocatable; _ } -> relocatable

let params_matching_arity (params : Ident.t list) (args : Lam.t list) =
  let rec loop arity params args =
    match (params, args) with
    | [], [] -> Some arity
    | param :: params, (Lam.Lvar ident | Lam.Lmutvar ident) :: args
      when Ident.same param ident ->
        loop (arity + 1) params args
    | _ -> None
  in
  loop 0 params args

let rec of_lambda ~find_ident ~find_external lam =
  match lam with
  | Lam.Lvar ident | Lam.Lmutvar ident -> find_ident ident
  | Lam.Lprim
      {
        primitive = Pfield (_, Fld_module { name });
        args = [ Lam.Lglobal_module { id; dynamic_import } ];
        _;
      } ->
      find_external ~dynamic_import id name ~arity:None
  | Lam.Lfunction { params; body; _ } ->
      of_eta_wrapper ~find_ident ~find_external params body
  | _ -> Unknown

and of_eta_wrapper ~find_ident ~find_external params body =
  let matching_arity =
    match body with
    | Lam.Lprim { args; _ } -> params_matching_arity params args
    | Lam.Lapply { ap_args; _ } -> params_matching_arity params ap_args
    | _ -> None
  in
  match matching_arity with
  | None -> Unknown
  | Some matching_arity -> (
      match body with
      | Lam.Lprim { primitive; _ } -> Direct_primitive primitive
      | Lam.Lapply
          {
            ap_func =
              Lprim
                {
                  primitive = Pfield (_, Fld_module { name });
                  args = [ Lglobal_module { id; dynamic_import } ];
                  _;
                };
            _;
          } ->
          let arity = Lam_arity.info [ matching_arity ] false in
          find_external ~dynamic_import id name ~arity:(Some arity)
      | Lam.Lapply { ap_func; _ } -> (
          match of_lambda ~find_ident ~find_external ap_func with
          | (Direct_primitive _ | Direct_external _) as summary -> summary
          | Unknown -> Unknown)
      | _ -> Unknown)
