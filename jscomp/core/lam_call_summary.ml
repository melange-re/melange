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

let primitive_is_relocatable = function
  | Lam_primitive.Pccall ccall -> Lam_ccall.is_relocatable ccall
  | primitive -> Lam_primitive.is_relocatable primitive

let is_relocatable = function
  | Unknown -> true
  | Direct_primitive primitive -> primitive_is_relocatable primitive
  | Direct_external { relocatable; _ } -> relocatable

let params_match_args (params : Ident.t list) (args : Lam.t list) =
  List.same_length params args
  && List.for_all2 params args ~f:(fun param arg ->
      match arg with
      | Lam.Lvar ident | Lam.Lmutvar ident -> Ident.same param ident
      | _ -> false)

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
  match body with
  | Lam.Lprim { primitive; args; _ } when params_match_args params args ->
      Direct_primitive primitive
  | Lam.Lapply
      {
        ap_func =
          Lprim
            {
              primitive = Pfield (_, Fld_module { name });
              args = [ Lglobal_module { id; dynamic_import } ];
              _;
            };
        ap_args;
        _;
      }
    when params_match_args params ap_args ->
      let arity = Lam_arity.info [ List.length params ] false in
      find_external ~dynamic_import id name ~arity:(Some arity)
  | Lam.Lapply { ap_func; ap_args; _ } when params_match_args params ap_args
    -> (
      match of_lambda ~find_ident ~find_external ap_func with
      | (Direct_primitive _ | Direct_external _) as summary -> summary
      | Unknown -> Unknown)
  | _ -> Unknown
