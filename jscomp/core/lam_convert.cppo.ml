(* Copyright (C) 2018 - Hongbo Zhang, Authors of ReScript
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

open Import

let lam_extension_id =
  let lam_caml_id : Lam_primitive.t =
    let caml_id_field_info : Lambda.field_dbg_info =
      Fld_record { name = Js_dump_lit.exception_id; mutable_flag = Immutable }
    in
    Pfield (0, caml_id_field_info)
  in
  fun loc (head : Lam.t) ->
    Lam.prim ~primitive:lam_caml_id ~args:[ head ] loc

let lazy_block_info : Lam.Tag_info.t =
  let lazy_done = "LAZY_DONE" and lazy_val = "VAL" in
  Blk_record [| lazy_done; lazy_val |]

let unbox_extension info (args : Lam.t list) mutable_flag loc =
  Lam.prim ~primitive:(Pmakeblock (0, info, mutable_flag)) ~args loc

(* A conservative approach to avoid packing exceptions
    for lambda expression like {[
      try { ... }catch(id){body}
    ]}
    we approximate that if [id] is destructed or not.
    If it is destructed, we need pack it in case it is JS exception.
    The packing is called Js.Exn.internalTOOCamlException, which is a nop for OCaml exception,
    but will wrap as (Error e) when it is an JS exception.

    {[
      try .. with
      | A (x,y) ->
      | Js.Error ..
    ]}

    Without such wrapping, the code above would raise

    Note it is not guaranteed that exception raised(or re-raised) is a structured
    ocaml exception but it is guaranteed that if such exception is processed it would
    still be an ocaml exception.
    for example {[
      match x with
      | exception e -> raise e
    ]}
    it will re-raise an exception as it is (we are not packing it anywhere)

    It is hard to judge an exception is destructed or escaped, any potential
    alias(or if it is passed as an argument) would cause it to be leaked
*)
let exception_id_destructed (l : Lam.t) (fv : Ident.t) : bool =
  let rec hit_opt (x : _ option) =
    match x with None -> false | Some a -> hit a
  and hit_list_snd : 'a. ('a * _) list -> bool =
   fun x -> List.exists ~f:(fun (_, x) -> hit x) x
  and hit_list xs = List.exists ~f:hit xs
  and hit (l : Lam.t) =
    match l with
    (* | Lprim {primitive = Pintcomp _ ;
              args = ([x;y ])  } ->
       begin match x,y with
         | Lvar _, Lvar _ -> false
         | Lvar _, _ -> hit y
         | _, Lvar _ -> hit x
         | _, _  -> hit x || hit y
       end *)
    (* FIXME: this can be uncovered after we do the unboxing *)
    | Lprim { primitive = Praise; args = [ Lvar _ ]; _ } -> false
    | Lprim { primitive = _; args; _ } -> hit_list args
    | Lvar id | Lmutvar id -> Ident.same id fv
    | Lassign (id, e) -> Ident.same id fv || hit e
    | Lstaticcatch (e1, (_, _vars), e2) -> hit e1 || hit e2
    | Ltrywith (e1, _exn, e2) -> hit e1 || hit e2
    | Lfunction { body; params = _; _ } -> hit body
    | Llet (_, _id, arg, body) | Lmutlet (_id, arg, body) -> hit arg || hit body
    | Lletrec (decl, body) -> hit body || hit_list_snd decl
    | Lfor (_v, e1, e2, _dir, e3) -> hit e1 || hit e2 || hit e3
    | Lconst _ -> false
    | Lapply { ap_func; ap_args; _ } -> hit ap_func || hit_list ap_args
    | Lglobal_module _ (* global persistent module, play safe *) -> false
    | Lswitch (arg, sw) ->
        hit arg || hit_list_snd sw.sw_consts || hit_list_snd sw.sw_blocks
        || hit_opt sw.sw_failaction
    | Lstringswitch (arg, cases, default) ->
        hit arg || hit_list_snd cases || hit_opt default
    | Lstaticraise (_, args) -> hit_list args
    | Lifthenelse (e1, e2, e3) -> hit e1 || hit e2 || hit e3
    | Lsequence (e1, e2) -> hit e1 || hit e2
    | Lwhile (e1, e2) -> hit e1 || hit e2
    | Lsend (_k, met, obj, args, _) -> hit met || hit obj || hit_list args
    | Lifused (_v, e) -> hit e
  in
  hit l

let abs_int x = if x < 0 then -x else x
let no_over_flow x = abs_int x < 0x1fff_ffff
let no_over_flow_int32 x = Int32.abs x < 0x1fff_ffffl

let lam_is_var (x : Lam.t) (y : Ident.t) =
  match x with Lvar y2 | Lmutvar y2 -> Ident.same y2 y | _ -> false

(* Make sure no int range overflow happens
    also we only check [int]
*)
let happens_to_be_diff (sw_consts : (int * Lam.t) list) : int32 option =
  match sw_consts with
  | (a, Lconst (Const_int { i = a0; comment = _ }))
    :: (b, Lconst (Const_int { i = b0; comment = _ }))
    :: rest
    when no_over_flow a && no_over_flow_int32 a0 && no_over_flow b
         && no_over_flow_int32 b0 ->
      let a = Int32.of_int a in
      let b = Int32.of_int b in
      let diff = Int32.sub a0 a in
      if Int32.sub b0 b = diff then
        if
          List.for_all
            ~f:(fun (x, lam) ->
              match lam with
              | Lam.Lconst (Const_int { i = x0; comment = _ })
                when no_over_flow_int32 x0 && no_over_flow x ->
                  let x = Int32.of_int x in
                  Int32.sub x0 x = diff
              | _ -> false)
            rest
        then Some diff
        else None
      else None
  | _ -> None

(* type required_modules = Lam_module_ident.Hash_set.t *)

(* drop Lseq (List! ) etc
   see #3852, we drop all these required global modules
   but added it back based on our own module analysis
*)
let rec drop_global_marker (lam : Lam.t) =
  match lam with
  | Lsequence (Lglobal_module _, rest) -> drop_global_marker rest
  | _ -> lam

let unit = Lam.unit

let convert_record_repr (x : Types.record_representation) :
    Lam_primitive.record_representation =
  match x with
  | Record_regular | Record_float -> Record_regular
  | Record_extension _ -> Record_extension
  | Record_unboxed _ ->
      assert false (* see patches in {!Typedecl.get_unboxed_from_attributes}*)
  | Record_inlined { tag; name; num_nonconsts } ->
      Record_inlined { tag; name; num_nonconsts }

let lam_prim ~primitive:(p : Lambda.primitive) ~args loc : Lam.t =
  match p with
  | Pint_as_pointer
  (* | Pidentity -> List.singleton_exn args *)
  | Pccall _ ->
      assert false
  | Pbytes_to_string (* handled very early *) ->
      Lam.prim ~primitive:Pbytes_to_string ~args loc
  | Pbytes_of_string -> Lam.prim ~primitive:Pbytes_of_string ~args loc
  | Pignore ->
      (* Pignore means return unit, it is not an nop *)
      Lam.seq (List.hd args) unit
  | Pcompare_ints ->
      Lam.prim ~primitive:(Pccall { prim_name = "caml_int_compare" }) ~args loc
  | Pcompare_floats ->
      Lam.prim ~primitive:(Pccall { prim_name = "caml_float_compare" }) ~args loc
  | Pcompare_bints Pnativeint -> assert false
  | Pcompare_bints Pint32 ->
      Lam.prim ~primitive:(Pccall { prim_name = "caml_int32_compare" }) ~args loc
  | Pcompare_bints Pint64 ->
      Lam.prim ~primitive:(Pccall { prim_name = "caml_int64_compare" }) ~args loc
  | Pgetglobal _ -> assert false
  | Psetglobal _ ->
      (* we discard [Psetglobal] in the beginning*)
      drop_global_marker (List.hd args)
  (* prim ~primitive:(Psetglobal id) ~args loc *)
  | Pmakeblock (tag, info, mutable_flag, _block_shape) -> (
      match info with
      | Blk_some_not_nested -> Lam.prim ~primitive:Psome_not_nest ~args loc
      | Blk_some -> Lam.prim ~primitive:Psome ~args loc
      | Blk_constructor { name; num_nonconst; attributes } ->
          let info : Lam.Tag_info.t =
            Blk_constructor { name; num_nonconst; attributes }
          in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_tuple ->
          let info : Lam.Tag_info.t = Blk_tuple in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_extension ->
          let info : Lam.Tag_info.t = Blk_extension in
          unbox_extension info args mutable_flag loc
      | Blk_record_ext s ->
          let info : Lam.Tag_info.t = Blk_record_ext s in
          unbox_extension info args mutable_flag loc
      | Blk_extension_slot -> (
          match args with
          | [ Lconst (Const_string { s = name; _ }) ] ->
              Lam.prim ~primitive:(Pcreate_extension name) ~args:[] loc
          | _ -> assert false)
      | Blk_class ->
          let info : Lam.Tag_info.t = Blk_class in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_array ->
          let info : Lam.Tag_info.t = Blk_array in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_record s ->
          let info : Lam.Tag_info.t = Blk_record s in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_record_inlined { name; fields; num_nonconst } ->
          let info : Lam.Tag_info.t =
            Blk_record_inlined { name; fields; num_nonconst }
          in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_module s ->
          let info : Lam.Tag_info.t = Blk_module s in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_module_export _ ->
          let info : Lam.Tag_info.t = Blk_module_export in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc
      | Blk_poly_var s -> (
          match args with
          | [ _; value ] ->
              let info : Lam.Tag_info.t = Blk_poly_var in
              Lam.prim
                ~primitive:(Pmakeblock (tag, info, mutable_flag))
                ~args:
                  [
                    Lam.const
                      (Const_string { s; unicode = false; comment = None });
                    value;
                  ]
                loc
          | _ -> assert false)
      | Blk_lazy_general -> (
          match args with
          | [ ((Lvar _ | Lmutvar _ | Lconst _ | Lfunction _) as result) ] ->
              let args = [ Lam.const Const_js_true; result ] in
              Lam.prim
                ~primitive:(Pmakeblock (tag, lazy_block_info, Mutable))
                ~args loc
          | [ computation ] ->
              let args =
                [
                  Lam.const Const_js_false;
                  (* FIXME: arity 0 does not get proper supported*)
                  Lam.function_ ~arity:0 ~params:[] ~body:computation
                    ~attr:Lambda.default_function_attribute;
                ]
              in
              Lam.prim
                ~primitive:(Pmakeblock (tag, lazy_block_info, Mutable))
                ~args loc
          | _ -> assert false)
      | Blk_na s ->
          let info : Lam.Tag_info.t = Blk_na s in
          Lam.prim ~primitive:(Pmakeblock (tag, info, mutable_flag)) ~args loc)
#if OCAML_VERSION >= (5, 1, 0)
  | Pfield (id, _ptr, _mut, info) ->
#else
  | Pfield (id, info) ->
#endif
      Lam.prim ~primitive:(Pfield (id, info)) ~args loc
  | Psetfield (id, _, _initialization_or_assignment, info) ->
      Lam.prim ~primitive:(Psetfield (id, info)) ~args loc
  | Psetfloatfield _ | Pfloatfield _ -> assert false
  | Pduprecord (repr, _) ->
      Lam.prim ~primitive:(Pduprecord (convert_record_repr repr)) ~args loc
  | Praise _ -> Lam.prim ~primitive:Praise ~args loc
  | Psequand -> Lam.prim ~primitive:Psequand ~args loc
  | Psequor -> Lam.prim ~primitive:Psequor ~args loc
  | Pnot -> Lam.prim ~primitive:Pnot ~args loc
  | Pnegint -> Lam.prim ~primitive:Pnegint ~args loc
  | Paddint -> Lam.prim ~primitive:Paddint ~args loc
  | Psubint -> Lam.prim ~primitive:Psubint ~args loc
  | Pmulint -> Lam.prim ~primitive:Pmulint ~args loc
  | Pdivint _is_safe (*FIXME*) -> Lam.prim ~primitive:Pdivint ~args loc
  | Pmodint _is_safe (*FIXME*) -> Lam.prim ~primitive:Pmodint ~args loc
  | Pandint -> Lam.prim ~primitive:Pandint ~args loc
  | Porint -> Lam.prim ~primitive:Porint ~args loc
  | Pxorint -> Lam.prim ~primitive:Pxorint ~args loc
  | Plslint -> Lam.prim ~primitive:Plslint ~args loc
  | Plsrint -> Lam.prim ~primitive:Plsrint ~args loc
  | Pasrint -> Lam.prim ~primitive:Pasrint ~args loc
  | Pstringlength -> Lam.prim ~primitive:Pstringlength ~args loc
  | Pstringrefu -> Lam.prim ~primitive:Pstringrefu ~args loc
  | Pabsfloat -> assert false
  | Pstringrefs -> Lam.prim ~primitive:Pstringrefs ~args loc
  | Pbyteslength -> Lam.prim ~primitive:Pbyteslength ~args loc
  | Pbytesrefu -> Lam.prim ~primitive:Pbytesrefu ~args loc
  | Pbytessetu -> Lam.prim ~primitive:Pbytessetu ~args loc
  | Pbytesrefs -> Lam.prim ~primitive:Pbytesrefs ~args loc
  | Pbytessets -> Lam.prim ~primitive:Pbytessets ~args loc
  | Pisint -> Lam.prim ~primitive:Pisint ~args loc
  | Pisout -> (
      match args with
      | [ range; Lprim { primitive = Poffsetint i; args = [ x ]; _ } ] ->
          Lam.prim ~primitive:(Pisout i) ~args:[ range; x ] loc
      | _ -> Lam.prim ~primitive:(Pisout 0) ~args loc)
  | Pintoffloat -> Lam.prim ~primitive:Pintoffloat ~args loc
  | Pfloatofint -> Lam.prim ~primitive:Pfloatofint ~args loc
  | Pnegfloat -> Lam.prim ~primitive:Pnegfloat ~args loc
  | Paddfloat -> Lam.prim ~primitive:Paddfloat ~args loc
  | Psubfloat -> Lam.prim ~primitive:Psubfloat ~args loc
  | Pmulfloat -> Lam.prim ~primitive:Pmulfloat ~args loc
  | Pdivfloat -> Lam.prim ~primitive:Pdivfloat ~args loc
  | Pintcomp x -> Lam.prim ~primitive:(Pintcomp x) ~args loc
  | Poffsetint x -> Lam.prim ~primitive:(Poffsetint x) ~args loc
  | Poffsetref x -> Lam.prim ~primitive:(Poffsetref x) ~args loc
  | Pfloatcomp x -> Lam.prim ~primitive:(Pfloatcomp x) ~args loc
  | Pmakearray (_, _mutable_flag) (*FIXME*) ->
      Lam.prim ~primitive:Pmakearray ~args loc
  | Parraylength _ -> Lam.prim ~primitive:Parraylength ~args loc
  | Parrayrefu _ -> Lam.prim ~primitive:Parrayrefu ~args loc
  | Parraysetu _ -> Lam.prim ~primitive:Parraysetu ~args loc
  | Parrayrefs _ -> Lam.prim ~primitive:Parrayrefs ~args loc
  | Parraysets _ -> Lam.prim ~primitive:Parraysets ~args loc
  | Pbintofint x -> (
      match x with
      | Pint32 | Pnativeint -> List.hd args
      | Pint64 -> Lam.prim ~primitive:Pint64ofint ~args loc)
  | Pintofbint x -> (
      match x with
      | Pint32 | Pnativeint -> List.hd args
      | Pint64 -> Lam.prim ~primitive:Pintofint64 ~args loc)
  | Pnegbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pnegint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pnegint64 ~args loc)
  | Paddbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Paddint ~args loc
      | Pint64 -> Lam.prim ~primitive:Paddint64 ~args loc)
  | Psubbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Psubint ~args loc
      | Pint64 -> Lam.prim ~primitive:Psubint64 ~args loc)
  | Pmulbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pmulint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pmulint64 ~args loc)
  | Pdivbint { size = x; is_safe = _ } (*FIXME*) -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pdivint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pdivint64 ~args loc)
  | Pmodbint { size = x; is_safe = _ } (*FIXME*) -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pmodint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pmodint64 ~args loc)
  | Pandbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pandint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pandint64 ~args loc)
  | Porbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Porint ~args loc
      | Pint64 -> Lam.prim ~primitive:Porint64 ~args loc)
  | Pxorbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pxorint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pxorint64 ~args loc)
  | Plslbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Plslint ~args loc
      | Pint64 -> Lam.prim ~primitive:Plslint64 ~args loc)
  | Plsrbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Plsrint ~args loc
      | Pint64 -> Lam.prim ~primitive:Plsrint64 ~args loc)
  | Pasrbint x -> (
      match x with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:Pasrint ~args loc
      | Pint64 -> Lam.prim ~primitive:Pasrint64 ~args loc)
  | Pbigarraydim _ | Pbigstring_load_16 _ | Pbigstring_load_32 _
  | Pbigstring_load_64 _ | Pbigstring_set_16 _ | Pbigstring_set_32 _
  | Pbigstring_set_64 _ ->
      Location.raise_errorf ~loc "unsupported primitive"
  | Pbytes_load_16 b -> Lam.prim ~primitive:(Pbytes_load_16 b) ~args loc
  | Pbytes_load_32 b -> Lam.prim ~primitive:(Pbytes_load_32 b) ~args loc
  | Pbytes_load_64 b -> Lam.prim ~primitive:(Pbytes_load_64 b) ~args loc
  | Pbytes_set_16 b -> Lam.prim ~primitive:(Pbytes_set_16 b) ~args loc
  | Pbytes_set_32 b -> Lam.prim ~primitive:(Pbytes_set_32 b) ~args loc
  | Pbytes_set_64 b -> Lam.prim ~primitive:(Pbytes_set_64 b) ~args loc
  | Pstring_load_16 b -> Lam.prim ~primitive:(Pstring_load_16 b) ~args loc
  | Pstring_load_32 b -> Lam.prim ~primitive:(Pstring_load_32 b) ~args loc
  | Pstring_load_64 b -> Lam.prim ~primitive:(Pstring_load_64 b) ~args loc
  | Pbigarrayref _ | Pbigarrayset _ ->
      Location.raise_errorf ~loc "unsupported primitive"
  | Pctconst x -> (
      match x with
      | Word_size | Int_size ->
          Lam.const (Const_int { i = 32l; comment = None })
      | Max_wosize ->
          Lam.const (Const_int { i = 2147483647l; comment = Some "Max_wosize" })
      | Big_endian -> Lam.prim ~primitive:(Pctconst Big_endian) ~args loc
      | Ostype_unix -> Lam.prim ~primitive:(Pctconst Ostype_unix) ~args loc
      | Ostype_win32 -> Lam.prim ~primitive:(Pctconst Ostype_win32) ~args loc
      | Ostype_cygwin -> Lam.false_
      | Backend_type -> Lam.prim ~primitive:(Pctconst Backend_type) ~args loc)
  | Pcvtbint (a, b) -> (
      match (a, b) with
      | (Pnativeint | Pint32), (Pnativeint | Pint32) | Pint64, Pint64 ->
          List.hd args
      | Pint64, (Pnativeint | Pint32) -> Lam.prim ~primitive:Pintofint64 ~args loc
      | (Pnativeint | Pint32), Pint64 -> Lam.prim ~primitive:Pint64ofint ~args loc)
  | Pbintcomp (a, b) -> (
      match a with
      | Pnativeint | Pint32 -> Lam.prim ~primitive:(Pintcomp b) ~args loc
      | Pint64 -> Lam.prim ~primitive:(Pint64comp b) ~args loc)
  | Pfield_computed -> Lam.prim ~primitive:Pfield_computed ~args loc
  | Popaque -> List.hd args
  | Psetfield_computed _ -> Lam.prim ~primitive:Psetfield_computed ~args loc
  | Pbbswap i -> Lam.prim ~primitive:(Pbbswap i) ~args loc
  | Pbswap16 -> Lam.prim ~primitive:Pbswap16 ~args loc
  | Pduparray _ -> assert false
#if OCAML_VERSION >= (5, 1, 0)
  | Prunstack | Pperform | Presume | Preperform | Patomic_exchange | Patomic_cas
  | Patomic_fetch_add | Pdls_get | Patomic_load _ ->
      Location.raise_errorf ~loc
        "OCaml 5 multicore primitives (Effect, Condition, Semaphore) are not \
         currently supported in Melange"
#endif

(* Does not exist since we compile array in js backend unlike native backend *)

let may_depend = Lam_module_ident.Hash_set.add

let rec rename_optional_parameters map params (body : Lam.t) =
  match body with
  | Llet
      ( k,
        id,
        Lifthenelse
          ( Lprim { primitive = p; args = [ Lvar opt ]; loc = p_loc },
            Llet
              ( _,
                sth,
                Lprim { primitive = p1; args = [ Lvar opt2 ]; loc = x_loc },
                Lvar sth2 ),
            f ),
        rest )
    when Ident.name sth = "*sth*"
         && Ident.name sth2 = "*sth*"
         && Ident.name opt = "*opt*"
         && Ident.name opt2 = "*opt*"
         && Ident.same opt opt2 && List.mem opt ~set:params ->
      let map, rest = rename_optional_parameters map params rest in
      let new_id = Ident.create_local (Ident.name id ^ "Opt") in
      ( Ident.Map.add map opt new_id,
        Lam.let_ k id
          (Lam.if_
             (Lam.prim ~primitive:p ~args:[ Lam.var new_id ] p_loc)
             (Lam.prim ~primitive:p1 ~args:[ Lam.var new_id ] x_loc)
             f)
          rest )
  | Llet
      ( k,
        id,
        Lifthenelse
          ( Lprim { primitive = p; args = [ Lvar opt ]; loc = p_loc },
            Lprim { primitive = p1; args = [ Lvar opt2 ]; loc = x_loc },
            f ),
        rest )
    when Ident.name opt = "*opt*"
         && Ident.name opt2 = "*opt*"
         && Ident.same opt opt2 && List.mem opt ~set:params ->
      let map, rest = rename_optional_parameters map params rest in
      let new_id = Ident.create_local (Ident.name id ^ "Opt") in
      ( Ident.Map.add map opt new_id,
        Lam.let_ k id
          (Lam.if_
             (Lam.prim ~primitive:p ~args:[ Lam.var new_id ] p_loc)
             (Lam.prim ~primitive:p1 ~args:[ Lam.var new_id ] x_loc)
             f)
          rest )
  | Lmutlet
      ( id,
        Lifthenelse
          ( Lprim { primitive = p; args = [ Lvar opt ]; loc = p_loc },
            Lprim { primitive = p1; args = [ Lvar opt2 ]; loc = x_loc },
            f ),
        rest )
    when Ident.name opt = "*opt*"
         && Ident.name opt2 = "*opt*"
         && Ident.same opt opt2 && List.mem opt ~set:params ->
      let map, rest = rename_optional_parameters map params rest in
      let new_id = Ident.create_local (Ident.name id ^ "Opt") in
      ( Ident.Map.add map opt new_id,
        Lam.mutlet id
          (Lam.if_
             (Lam.prim ~primitive:p ~args:[ Lam.var new_id ] p_loc)
             (Lam.prim ~primitive:p1 ~args:[ Lam.var new_id ] x_loc)
             f)
          rest )
  | _ -> (map, body)

let nat_of_string_exn =
  let rec int_of_string_aux s acc off len =
    if off >= len then acc
    else
      let d = Char.code (String.unsafe_get s off) - 48 in
      if d >= 0 && d <= 9 then
        int_of_string_aux s ((10 * acc) + d) (off + 1) len
      else -1 (* error *)
  in
  fun s ->
    let acc = int_of_string_aux s 0 0 (String.length s) in
    if acc < 0 then invalid_arg s else acc

let convert (exports : Ident.Set.t) (lam : Lambda.lambda) :
    Lam.t * Lam_module_ident.Hash_set.t =
  let alias_tbl = Ident.Hash.create 64 in
  let exit_map = Hash_int.create 0 in
  let may_depends = Lam_module_ident.Hash_set.create 0 in

  let rec convert_ccall (a_prim : Primitive.description)
      (args : Lambda.lambda list) loc ~dynamic_import : Lam.t =
    let prim_name = a_prim.prim_name in
    let prim_name_len = String.length prim_name in
    match
      Melange_ffi.External_ffi_types.from_string a_prim.prim_native_name
    with
    | Ffi_normal ->
        if prim_name_len > 0 && String.unsafe_get prim_name 0 = '#' then
          convert_js_primitive a_prim args loc
        else
          let args = List.map ~f:convert_aux args in
          Lam.prim ~primitive:(Pccall { prim_name }) ~args loc
    | Ffi_obj_create labels ->
        let args = List.map ~f:convert_aux args in
        Lam.prim ~primitive:(Pjs_object_create labels) ~args loc
    | Ffi_mel (arg_types, result_type, ffi) ->
        let arg_types =
          match arg_types with
          | Params ls -> ls
          | Param_number i ->
              List.init ~len:i ~f:(fun _ -> Melange_ffi.External_arg_spec.dummy)
        in
        let args = List.map ~f:convert_aux args in
        Lam_ffi.handle_mel_non_obj_ffi
          arg_types
          result_type
          ffi
          args
          loc
          prim_name
          ~dynamic_import
    | Ffi_inline_const i -> Lam.const i
  and convert_js_primitive (p : Primitive.description)
      (args : Lambda.lambda list) loc =
    let s = p.prim_name in
    match () with
    | _ when s = "#is_not_none" ->
        let args = List.map ~f:convert_aux args in
        Lam.prim ~primitive:Pis_not_none ~args loc
    | _ when s = "#val_from_unnest_option" ->
        let args = List.map ~f:convert_aux args in
        let v = List.hd args in
        Lam.prim ~primitive:Pval_from_option_not_nest ~args:[ v ] loc
    | _ when s = "#val_from_option" ->
        let args = List.map ~f:convert_aux args in
        Lam.prim ~primitive:Pval_from_option ~args loc
    | _ when s = "#is_poly_var_const" ->
        let args = List.map ~f:convert_aux args in
        Lam.prim ~primitive:Pis_poly_var_const ~args loc
    | _ when s = "#raw_expr" -> (
        let args = List.map ~f:convert_aux args in
        match args with
        | [ Lconst (Const_string { s = code; _ }) ] ->
            (* js parsing here *)
            let kind = Melange_ffi.Classify_function.classify code in
            Lam.prim
              ~primitive:(Praw_js_code { code; code_info = Exp kind })
              ~args:[] loc
        | _ -> assert false)
    | _ when s = "#raw_stmt" -> (
        let args = List.map ~f:convert_aux args in
        match args with
        | [ Lconst (Const_string { s = code; _ }) ] ->
            let kind = Melange_ffi.Classify_function.classify_stmt code in
            Lam.prim
              ~primitive:(Praw_js_code { code; code_info = Stmt kind })
              ~args:[] loc
        | _ -> assert false)
    | _ when s = "#debugger" ->
        (* ATT: Currently, the arity is one due to PPX *)
        Lam.prim ~primitive:Pdebugger ~args:[] loc
    | _ when s = "#null" -> Lam.const Const_js_null
    | _ when s = "#os_type" ->
        Lam.prim ~primitive:(Pctconst Ostype) ~args:[ unit ] loc
    | _ when s = "#undefined" -> Lam.const Const_js_undefined
    | _ when s = "#init_mod" -> (
        let args = List.map ~f:convert_aux args in
        match args with
        | [ _loc; Lconst (Const_block (0, _, [ Const_block (0, _, []) ])) ] ->
            Lam.unit
        | _ -> Lam.prim ~primitive:Pinit_mod ~args loc)
    | _ when s = "#update_mod" -> (
        let args = List.map ~f:convert_aux args in
        match args with
        | [ Lconst (Const_block (0, _, [ Const_block (0, _, []) ])); _; _ ] ->
            Lam.unit
        | _ -> Lam.prim ~primitive:Pupdate_mod ~args loc)
    | _ when s = "#extension_slot_eq" -> (
        let args = List.map ~f:convert_aux args in
        match args with
        | [ lhs; rhs ] ->
            Lam.prim
              ~primitive:(Pccall { prim_name = "caml_string_equal" })
              ~args:[ lam_extension_id loc lhs; rhs ]
              loc
        | _ -> assert false)
    | _ ->
        let primitive : Lam_primitive.t =
          match s with
          | "#apply" -> Pjs_runtime_apply
          | "#apply1" | "#apply2" | "#apply3" | "#apply4" | "#apply5"
          | "#apply6" | "#apply7" | "#apply8" ->
              Pjs_apply
          | "#makemutablelist" ->
              Pmakeblock
                ( 0,
                  Blk_constructor
                    { name = "::"; num_nonconst = 1; attributes = [] },
                  Mutable )
          | "#undefined_to_opt" -> Pundefined_to_opt
          | "#nullable_to_opt" -> Pnull_undefined_to_opt
          | "#null_to_opt" -> Pnull_to_opt
          | "#is_nullable" -> Pis_null_undefined
          | "#import" -> Pimport
          | "#string_append" -> Pstringadd
          | "#obj_length" -> Pcaml_obj_length
          | "#function_length" -> Pjs_function_length
          | "#unsafe_lt" -> Pjscomp Clt
          | "#unsafe_gt" -> Pjscomp Cgt
          | "#unsafe_le" -> Pjscomp Cle
          | "#unsafe_ge" -> Pjscomp Cge
          | "#unsafe_eq" -> Pjscomp Ceq
          | "#unsafe_neq" -> Pjscomp Cne
          | "#typeof" -> Pjs_typeof
          | "#run" -> Pvoid_run
          | "#full_apply" -> Pfull_apply
          | "#fn_mk" -> Pjs_fn_make (nat_of_string_exn p.prim_native_name)
          | "#fn_method" -> Pjs_fn_method
          | "#unsafe_downgrade" ->
              Pjs_unsafe_downgrade { name = String.empty; loc; setter = false }
          | _ ->
              Location.raise_errorf ~loc
                "@{<error>Error:@} internal error, using unrecognized \
                 primitive %s"
                s
        in
        if primitive = Pfull_apply then
          let args = List.map ~f:convert_aux args in
          match args with
          | [ Lapply { ap_func; ap_args; _ } ] ->
              Lam.prim ~primitive ~args:(ap_func :: ap_args) loc
              (* There may be some optimization opportunities here
                 for cases like `(fun [@u] a b -> a + b ) 1 2 [@u]` *)
          | _ -> assert false
        else
          let args =
            let dynamic_import = primitive = Pimport in
            List.map ~f:(convert_aux ~dynamic_import) args
          in
          Lam.prim ~primitive ~args loc
  and convert_aux ?(dynamic_import=false) (lam : Lambda.lambda) : Lam.t =
    match lam with
    | Lvar x -> Lam.var (Ident.Hash.find_default alias_tbl x x)
    | Lmutvar x -> Lam.mutvar (Ident.Hash.find_default alias_tbl x x)
    | Lconst x -> Lam.const (Lam_constant_convert.convert_constant x)
    | Lapply { ap_func = fn; ap_args = [ arg ]; ap_loc = loc; _ } ->
        let arg = convert_aux arg in
        let fn = convert_aux fn in
        convert_possible_pipe_application fn arg loc
    | Lapply { ap_func = fn; ap_args = args; ap_loc = loc; ap_inlined; _ } ->
        (* we need do this eargly in case [aux fn] add some wrapper *)
        Lam.apply (convert_aux fn)
          (List.map ~f:convert_aux args)
          {
            ap_loc = Debuginfo.Scoped_location.to_location loc;
            ap_inlined;
            ap_status = App_na;
          }
    | Lfunction { params; body; attr; _ } ->
        let just_params = List.map ~f:fst params in
        let body = convert_aux ~dynamic_import body in
        let new_map, body =
          rename_optional_parameters Ident.Map.empty just_params body
        in
        let params =
          if Ident.Map.is_empty new_map then just_params
          else
            List.map
              ~f:(fun x -> Ident.Map.find_default new_map x x)
              just_params
        in
        Lam.function_ ~attr ~arity:(List.length params) ~params ~body
    | Llet (kind, _value_kind, id, e, body) (*FIXME*) ->
        convert_let kind id e body
    | Lmutlet (_value_kind, id, e, body) (*FIXME*) -> convert_mutlet id e body
    | Lletrec (bindings, body) ->
#if OCAML_VERSION >= (5,2,0)
        let bindings =
          List.map ~f:(fun {Lambda.id; def} ->
            let lambda = match def.attr.smuggled_lambda with
              | true -> def.body
              | false -> (Lfunction def)
            in
            id, convert_aux lambda) bindings
        in
#else
        let bindings = List.map_snd bindings convert_aux in
#endif
        let body = convert_aux body in
        let lam = Lam.letrec bindings body in
        Lam_scc.scc bindings lam body
    | Lprim (Pccall a, args, loc) ->
        convert_ccall ~dynamic_import a args (Debuginfo.Scoped_location.to_location loc)
    | Lprim (Pgetglobal id, args, _) ->
        let args = List.map ~f:(convert_aux ~dynamic_import) args in
        if Ident.is_predef id then
          Lam.const
            (Const_string { s = Ident.name id; unicode = false; comment = None })
        else (
          may_depend may_depends (Lam_module_ident.of_ml ~dynamic_import id);
          assert (args = []);
          Lam.global_module ~dynamic_import id)
    | Lprim (primitive, args, loc) ->
        let args = List.map ~f:(convert_aux ~dynamic_import) args in
        lam_prim ~primitive ~args (Debuginfo.Scoped_location.to_location loc)
    | Lswitch (e, s, _loc) -> convert_switch e s
    | Lstringswitch (e, cases, default, _) ->
        Lam.stringswitch (convert_aux e)
          (List.map_snd cases convert_aux)
          (Option.map convert_aux default)
    | Lstaticraise (id, []) ->
        Lam.staticraise (Hash_int.find_default exit_map id id) []
    | Lstaticraise (id, args) ->
        Lam.staticraise id (List.map ~f:convert_aux args)
    | Lstaticcatch (b, (i, []), Lstaticraise (j, [])) ->
        (* peep-hole [i] aliased to [j] *)
        Hash_int.add exit_map i (Hash_int.find_default exit_map j j);
        convert_aux b
    | Lstaticcatch (b, (i, ids), handler) ->
        Lam.staticcatch (convert_aux b)
          (i, List.map ~f:fst ids)
          (convert_aux handler)
    | Ltrywith (b, id, handler) ->
        let body = convert_aux b in
        let handler = convert_aux handler in
        if exception_id_destructed handler id then
          let newId = Ident.create_local ("raw_" ^ Ident.name id) in
          Lam.try_ body newId
            (Lam.let_ StrictOpt id
               (Lam.prim ~primitive:Pwrap_exn ~args:[ Lam.var newId ] Location.none)
               handler)
        else Lam.try_ body id handler
    | Lifthenelse (b, then_, else_) ->
        Lam.if_ (convert_aux b)
          (convert_aux then_)
          (convert_aux else_)
    | Lsequence (a, b) -> Lam.seq (convert_aux a) (convert_aux b)
    | Lwhile (b, body) -> Lam.while_ (convert_aux b) (convert_aux body)
    | Lfor (id, from_, to_, dir, loop) ->
        Lam.for_ id (convert_aux from_) (convert_aux to_) dir (convert_aux loop)
    | Lassign (id, body) -> Lam.assign id (convert_aux body)
    | Lsend (kind, a, b, ls, outer_loc) -> (
        let a = convert_aux a in
        let b = convert_aux b in
        let ls = List.map ~f:convert_aux ls in
        (* Format.fprintf Format.err_formatter "%a@." Printlambda.lambda b ; *)
        match b with
        | Lprim { primitive = Pjs_unsafe_downgrade { loc; _ }; args; _ } -> (
            match kind with
            | Public (Some name) -> (
                let suffix =
                  Melange_ffi.External_ffi_types.Literals.setter_suffix
                in
                let setter = String.ends_with name ~suffix in
                let property =
                  if setter then
                    Lam.Methname.translate
                      (String.sub name ~pos:0
                         ~len:String.(length name - length suffix))
                  else Lam.Methname.translate name
                in
                let lam =
                  Lam.prim
                    ~primitive:
                      (Pjs_unsafe_downgrade { name = property; loc; setter })
                    ~args loc
                in
                match ls with
                | [] -> lam
                | [ arg ] ->
                    (* Since https://github.com/ocaml/ocaml/pull/10081, `b |> a` gets
                       turned into `a b` by the typechecker. So this actually means
                       `(x ## y) z` rather than `x#y z` *)
                    convert_possible_pipe_application lam arg outer_loc
                | _ -> assert false)
            | _ -> assert false)
        | b ->
            Lam.send kind a b ls
              (Debuginfo.Scoped_location.to_location outer_loc))
    | Levent (e, _ev) -> convert_aux e
    | Lifused (v, e) -> Lam.ifused v (convert_aux e)
  and convert_let (kind : Lam_compat.let_kind) id (e : Lambda.lambda) body :
      Lam.t =
    let e = convert_aux e in
    match (kind, e) with
    | Alias, Lvar u ->
        let new_u = Ident.Hash.find_default alias_tbl u u in
        Ident.Hash.add alias_tbl id new_u;
        if Ident.Set.mem exports id then
          Lam.let_ kind id (Lam.var new_u) (convert_aux body)
        else convert_aux body
    | _, _ -> (
        let new_body = convert_aux body in
        (*
            reverse engineering cases as {[
           (let (switcher/1013 =a (-1+ match/1012))
               (if (isout 2 switcher/1013) (exit 1)
                   (switch* switcher/1013
                      case int 0: 'a'
                        case int 1: 'b'
                        case int 2: 'c')))
         ]}
         To elemininate the id [switcher], we need ensure it appears only
         in two places.

         To advance this case, when [sw_failaction] is None
      *)
        match (kind, e, new_body) with
        | ( Alias,
            Lprim
              {
                primitive = Poffsetint offset;
                args = [ (Lvar _ as matcher) ];
                _;
              },
            Lswitch
              ( Lvar switcher3,
                ({
                   sw_consts_full = false;
                   sw_consts;
                   sw_blocks = [];
                   sw_blocks_full = true;
                   sw_failaction = Some ifso;
                   _;
                 } as px) ) )
          when Ident.same switcher3 id
               && (not (Lam_hit.hit_variable id ifso))
               && not
                    (List.exists
                       ~f:(fun (_, x) -> Lam_hit.hit_variable id x)
                       sw_consts) ->
            Lam.switch matcher
              {
                px with
                sw_consts =
                  List.map ~f:(fun (i, act) -> (i - offset, act)) sw_consts;
              }
        | _ -> Lam.let_ kind id e new_body)
  and convert_mutlet id (e : Lambda.lambda) body : Lam.t =
    let new_e = convert_aux e in
    let new_body = convert_aux body in
    Lam.mutlet id new_e new_body
  and convert_possible_pipe_application (f : Lam.t) (x : Lam.t) outer_loc =
    match f with
    | Lfunction
        {
          params = [ param ];
          body = Lprim { primitive; args = [ Lvar inner_arg ]; _ };
          _;
        }
      when Ident.same param inner_arg ->
        Lam.prim ~primitive ~args:[ x ]
          (Debuginfo.Scoped_location.to_location outer_loc)
    | Lapply
        {
          ap_func =
            Lfunction
              { params; body = Lprim { primitive; args = inner_args; _ }; _ };
          ap_args = args;
          _;
        }
      when List.for_all2_no_exn inner_args params lam_is_var
           && List.length_larger_than_n inner_args args 1 ->
        Lam.prim ~primitive ~args:(args @ [ x ])
          (Debuginfo.Scoped_location.to_location outer_loc)
    | Lapply { ap_func; ap_args; ap_info } ->
        Lam.apply ap_func (ap_args @ [ x ])
          {
            ap_loc = Debuginfo.Scoped_location.to_location outer_loc;
            ap_inlined = ap_info.ap_inlined;
            ap_status = App_na;
          }
    | _ ->
        Lam.apply f [ x ]
          {
            ap_loc = Debuginfo.Scoped_location.to_location outer_loc;
            ap_inlined = Default_inline;
            ap_status = App_na;
          }
  and convert_switch (e : Lambda.lambda) (s : Lambda.lambda_switch) =
    let e = convert_aux e in
    match s with
    | {
     sw_failaction = None;
     sw_blocks = [];
     sw_numblocks = 0;
     sw_consts;
     sw_numconsts;
     _;
    } -> (
        let sw_consts = List.map_snd sw_consts convert_aux in
        match happens_to_be_diff sw_consts with
        | Some 0l -> e
        | Some i ->
            Lam.prim ~primitive:Paddint
              ~args:[ e; Lam.const (Const_int { i; comment = None }) ]
              Location.none
        | None ->
            Lam.switch e
              {
                sw_failaction = None;
                sw_blocks = [];
                sw_blocks_full = true;
                sw_consts;
                sw_consts_full = List.length_ge sw_consts sw_numconsts;
                sw_names = s.sw_names;
              })
    | _ ->
        Lam.switch e
          {
            sw_consts_full = List.length_ge s.sw_consts s.sw_numconsts;
            sw_consts = List.map_snd s.sw_consts convert_aux;
            sw_blocks_full = List.length_ge s.sw_blocks s.sw_numblocks;
            sw_blocks = List.map_snd s.sw_blocks convert_aux;
            sw_failaction = Option.map convert_aux s.sw_failaction;
            sw_names = s.sw_names;
          }
  in
  (convert_aux lam, may_depends)

(* FIXME: more precise analysis of [id], if it is not
    used, we can remove it
        only two places emit [Lifused],
        {[
          lsequence (Lifused(id, set_inst_var obj id expr)) rem
          Lifused (env2, Lprim(Parrayset Paddrarray, [Lvar self; Lvar env2; Lvar env1']))
        ]}

        Note the variable, [id], or [env2] is already defined, it can be removed if it is not
        used. This optimization seems useful, but doesnt really matter since it only hit translclass

        more details, see [translclass] and [if_used_test]
        seems to be an optimization trick for [translclass]

        | Lifused(v, l) ->
          if count_var v > 0 then simplif l else lambda_unit
*)

(*
        | Lfunction(kind,params,Lprim(prim,inner_args,inner_loc))
          when List.for_all2_no_exn (fun x y ->
          match y with
          | Lambda.Lvar y when Ident.same x y -> true
          | _ -> false
           ) params inner_args
          ->
          let rec aux outer_args params =
            match outer_args, params with
            | x::xs , _::ys ->
              x :: aux xs ys
            | [], [] -> []
            | x::xs, [] ->
            | [], y::ys
          if List.same_length inner_args args then
            aux (Lprim(prim,args,inner_loc))
          else

   {[
     (fun x y -> f x y) (computation;e) -->
     (fun y -> f (computation;e) y)
   ]}
   is wrong

   or
   {[
     (fun x y -> f x y ) ([|1;2;3|]) -->
     (fun y -> f [|1;2;3|] y)
   ]}
   is also wrong.

   It seems, we need handle [@variadic] earlier

   or
   {[
     (fun x y -> f x y) ([|1;2;3|]) -->
     let x0, x1, x2 =1,2,3 in
     (fun y -> f [|x0;x1;x2|] y)
   ]}
   But this still need us to know [@variadic] in advance


   we should not remove it immediately, since we have to be careful
      where it is used, it can be [exported], [Lvar] or [Lassign] etc
      The other common mistake is that
   {[
     let x = y (* elimiated x/y*)
     let u = x  (* eliminated u/x *)
   ]}

   however, [x] is already eliminated
   To improve the algorithm
   {[
     let x = y (* x/y *)
     let u = x (* u/y *)
   ]}
      This looks more correct, but lets be conservative here

      global module inclusion {[ include List ]}
      will cause code like {[ let include =a Lglobal_module (list)]}

      when [u] is global, it can not be bound again,
      it should always be the leaf
*)
