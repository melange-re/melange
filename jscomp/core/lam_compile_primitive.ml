(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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
module E = Js_exp_make

(* If it is the return value, since it is a side-effect call, we return unit,
   otherwise just return it *)
let ensure_value_unit (st : Lam_compile_context.continuation) e : E.t =
  match st with
  | EffectCall (Maybe_tail_is_return _)
  | NeedValue (Maybe_tail_is_return _)
  | Assign _ | Declare _ | NeedValue _ ->
      E.seq e E.unit
  | EffectCall Not_tail -> e
(* NeedValue should return a meaningful expression*)

let module_of_expression = function
  | J.Var (J.Qualified (module_id, value)) -> [ (module_id, value) ]
  | _ -> []

(*
let get_module_system () =
  let package_info = Js_packages_state.get_packages_info () in
  let module_system =
    if Js_packages_info.is_empty package_info && !Js_config.js_stdout then
      [ Module_system.CommonJS ]
    else
      Js_packages_info.map package_info (fun { module_system } -> module_system)
  in
  match module_system with [ module_system ] -> module_system | _ -> CommonJS
 *)

let import_of_path path =
  E.call
    ~info:{ arity = Full; call_info = Call_na }
    (E.js_global "import")
    [ E.str path ]

let wrap_then import value =
  let arg = Ident.create "m" in
  E.call
    ~info:{ arity = Full; call_info = Call_na }
    (E.dot import "then")
    [
      E.ocaml_fun ~return_unit:false
        (* ~oneUnitArg:false *) [ arg ]
        [
          {
            statement_desc = J.Return (E.dot (E.var arg) value);
            comment = None;
          };
        ];
    ]

let translate loc (cxt : Lam_compile_context.t) (prim : Lam_primitive.t)
    (args : J.expression list) : J.expression =
  match prim with
  | Pis_not_none -> Js_of_lam_option.is_not_none (List.hd args)
  | Pcreate_extension s -> E.make_exception s
  | Pwrap_exn ->
      E.runtime_call ~module_name:Js_runtime_modules.caml_js_exceptions
        ~fn_name:"internalToOCamlException" args
  | Praw_js_code { code; code_info } -> E.raw_js_code code_info code
  | Pjs_runtime_apply -> (
      match args with [ f; args ] -> E.flat_call f args | _ -> assert false)
  | Pjs_apply -> (
      match args with
      | fn :: rest -> E.call ~info:{ arity = Full; call_info = Call_na } fn rest
      | _ -> assert false)
  | Pnull_to_opt -> (
      match args with
      | [ e ] -> (
          match e.expression_desc with
          | Var _ | Undefined | Null -> Js_of_lam_option.null_to_opt e
          | _ ->
              E.runtime_call ~module_name:Js_runtime_modules.option
                ~fn_name:"null_to_opt" args)
      | _ -> assert false)
  | Pundefined_to_opt -> (
      match args with
      | [ e ] -> (
          match e.expression_desc with
          | Var _ | Undefined | Null -> Js_of_lam_option.undef_to_opt e
          | _ ->
              E.runtime_call ~module_name:Js_runtime_modules.option
                ~fn_name:"undefined_to_opt" args)
      | _ -> assert false)
  | Pnull_undefined_to_opt -> (
      match args with
      | [ e ] -> (
          match e.expression_desc with
          | Var _ | Undefined | Null -> Js_of_lam_option.null_undef_to_opt e
          | _ ->
              E.runtime_call ~module_name:Js_runtime_modules.option
                ~fn_name:"nullable_to_opt" args)
      | _ -> assert false)
  (* Compile #import: The module argument for dynamic import is represented as a path,
     and the module value is expressed through wrapping it with promise.then *)
  | Pimport -> (
      match args with
      | [ e ] -> (
          let output_dir = Filename.dirname cxt.output_prefix in

          Format.eprintf "x: %s@." (Js_dump.string_of_expression e);

          let module_id, module_value =
            match module_of_expression e.expression_desc with
            | [ module_ ] -> module_
            | _ ->
                Location.raise_errorf ~loc
                  "Invalid argument: Dynamic import requires a module or \
                   module value that is a file as argument. Passing a value or \
                   local module is not allowed."
          in

          let path =
            let output_info =
              Js_packages_info.assemble_output_info cxt.package_info
              (* TODO(anmonteiro): this might not be taking the right module
                 system into account at this stage *)
              |> (fun x ->
                   Format.eprintf "xx: %d@." (List.length x);
                   x)
              |> List.hd
            in
            Js_name_of_module_id.string_of_module_id
              ~package_info:cxt.package_info ~output_info ~output_dir
              { module_id with J.dynamic_import = true }
          in

          match module_value with
          | Some value -> wrap_then (import_of_path path) value
          | None -> import_of_path path)
      | [] | _ ->
          Location.raise_errorf ~loc
            "Invalid argument: Dynamic import must take a single module or \
             module value as its argument.")
  | Pjs_function_length -> E.function_length (List.hd args)
  | Pcaml_obj_length -> E.obj_length (List.hd args)
  | Pis_null -> E.is_null (List.hd args)
  | Pis_undefined -> E.is_undef (List.hd args)
  | Pis_null_undefined -> E.is_null_undefined (List.hd args)
  | Pjs_typeof -> E.typeof (List.hd args)
  | Pjs_unsafe_downgrade _ | Pdebugger | Pvoid_run | Pfull_apply | Pjs_fn_make _
    ->
      assert false (* already handled by {!Lam_compile} *)
  | Pjs_fn_method -> assert false
  | Pstringadd -> (
      match args with [ a; b ] -> E.string_append a b | _ -> assert false)
  | Pinit_mod ->
      E.runtime_call ~module_name:Js_runtime_modules.module_ ~fn_name:"init_mod"
        args
  | Pupdate_mod ->
      E.runtime_call ~module_name:Js_runtime_modules.module_
        ~fn_name:"update_mod" args
  | Psome -> (
      let arg = List.hd args in
      match arg.expression_desc with
      | Null | Object _ | Number _ | Caml_block _ | Array _ | Str _ ->
          (* This makes sense when type info
             is not available at the definition
             site, and inline recovered it
          *)
          E.optional_not_nest_block arg
      | _ -> E.optional_block arg)
  | Psome_not_nest -> E.optional_not_nest_block (List.hd args)
  | Pmakeblock (tag, tag_info, mutable_flag) ->
      (* RUNTIME *)
      Js_of_lam_block.make_block
        (Js_op_util.of_lam_mutable_flag mutable_flag)
        tag_info (E.small_int tag) args
  | Pval_from_option -> Js_of_lam_option.val_from_option (List.hd args)
  | Pval_from_option_not_nest -> List.hd args
  | Pfield (i, fld_info) ->
      Js_of_lam_block.field fld_info (List.hd args) (Int32.of_int i)
  (* Invariant depends on runtime *)
  | Pfield_computed -> (
      match args with
      | [ self; index ] -> Js_of_lam_block.field_by_exp self index
      | _ -> assert false (* Negate boxed int *))
  | Pnegint ->
      (* #977 *)
      E.int32_minus E.zero_int_literal (List.hd args)
  | Pnegint64 -> Js_long.neg args
  | Pnegfloat -> E.float_minus E.zero_float_lit (List.hd args)
  (* Negate boxed int end*)
  (* Int addition and subtraction *)
  | Paddint -> (
      match args with [ e1; e2 ] -> E.int32_add e1 e2 | _ -> assert false)
  | Paddint64 -> Js_long.add args
  | Paddfloat -> (
      match args with [ e1; e2 ] -> E.float_add e1 e2 | _ -> assert false)
  | Psubint -> (
      match args with [ e1; e2 ] -> E.int32_minus e1 e2 | _ -> assert false)
  | Psubint64 -> Js_long.sub args
  | Psubfloat -> (
      match args with [ e1; e2 ] -> E.float_minus e1 e2 | _ -> assert false)
  | Pmulint -> (
      match args with [ e1; e2 ] -> E.int32_mul e1 e2 | _ -> assert false)
  | Pmulint64 -> Js_long.mul args
  | Pmulfloat -> (
      match args with [ e1; e2 ] -> E.float_mul e1 e2 | _ -> assert false)
  | Pdivfloat -> (
      match args with [ e1; e2 ] -> E.float_div e1 e2 | _ -> assert false)
  | Pdivint -> (
      match args with
      | [ e1; e2 ] -> E.int32_div ~checked:!Js_config.check_div_by_zero e1 e2
      | _ -> assert false)
  | Pdivint64 -> Js_long.div args
  | Pmodint -> (
      match args with
      | [ e1; e2 ] -> E.int32_mod ~checked:!Js_config.check_div_by_zero e1 e2
      | _ -> assert false)
  | Pmodint64 -> Js_long.mod_ args
  | Plslint -> (
      match args with [ e1; e2 ] -> E.int32_lsl e1 e2 | _ -> assert false)
  | Plslint64 -> Js_long.lsl_ args
  | Plsrint -> (
      match args with
      | [ e1; { J.expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ } ]
        ->
          e1
      | [ e1; e2 ] -> E.to_int32 @@ E.int32_lsr e1 e2
      | _ -> assert false)
  | Plsrint64 -> Js_long.lsr_ args
  | Pasrint -> (
      match args with [ e1; e2 ] -> E.int32_asr e1 e2 | _ -> assert false)
  | Pasrint64 -> Js_long.asr_ args
  | Pandint -> (
      match args with [ e1; e2 ] -> E.int32_band e1 e2 | _ -> assert false)
  | Pandint64 -> Js_long.and_ args
  | Porint -> (
      match args with [ e1; e2 ] -> E.int32_bor e1 e2 | _ -> assert false)
  | Porint64 -> Js_long.or_ args
  | Pxorint -> (
      match args with [ e1; e2 ] -> E.int32_bxor e1 e2 | _ -> assert false)
  | Pxorint64 -> Js_long.xor args
  | Pjscomp cmp -> (
      match args with [ l; r ] -> E.js_comp cmp l r | _ -> assert false)
  | Pfloatcomp cmp -> (
      match args with [ e1; e2 ] -> E.float_comp cmp e1 e2 | _ -> assert false)
  | Pintcomp cmp -> (
      (* Global Builtin Exception is an int, like
         [Not_found] or [Invalid_argument] ?
      *)
      match args with [ e1; e2 ] -> E.int_comp cmp e1 e2 | _ -> assert false)
  (* List --> stamp = 0
     Assert_false --> stamp = 26
  *)
  | Pint64comp cmp -> Js_long.comp cmp args
  | Pintoffloat -> (
      match args with [ e ] -> E.to_int32 e | _ -> assert false)
  | Pint64ofint -> Js_long.of_int32 args
  | Pfloatofint -> List.hd args
  | Pintofint64 -> Js_long.to_int32 args
  | Pnot -> E.not (List.hd args)
  | Poffsetint n -> E.offset (List.hd args) n
  | Poffsetref n ->
      let v = Js_of_lam_block.field Lambda.ref_field_info (List.hd args) 0l in
      E.seq (E.assign v (E.offset v n)) E.unit
  | Psequand -> (
      (* TODO: rhs is possibly a tail call *)
      match args with [ e1; e2 ] -> E.and_ e1 e2 | _ -> assert false)
  | Psequor -> (
      (* TODO: rhs is possibly a tail call *)
      match args with [ e1; e2 ] -> E.or_ e1 e2 | _ -> assert false)
  | Pisout off -> (
      match args with
      (* predicate: [x > range  or x < 0 ]
         can be simplified if x is positive , x > range
         if x is negative, fine, its uint is for sure larger than range,
         the output is not readable, we might change it back.

         Note that if range is small like [1], then the negative of
         it can be more precise (given integer)
         a normal case of the compiler is  that it will do a shift
         in the first step [ (x - 1) > 1 or ( x - 1 ) < 0 ]
      *)
      | [ range; e ] -> E.is_out (E.offset e off) range
      | _ -> assert false)
  | Pbytes_of_string ->
      (* TODO: write a js primitive  - or is it necessary ?
         if we have byte_get/string_get
         still necessary, since you can set it now.
      *)
      Js_of_lam_string.bytes_of_string (List.hd args)
  | Pbytes_to_string -> Js_of_lam_string.bytes_to_string (List.hd args)
  | Pstringlength -> E.string_length (List.hd args)
  | Pbyteslength -> E.bytes_length (List.hd args)
  (* This should only be Pbyteset(u|s), which in js, is an int array
     Bytes is an int array in javascript
  *)
  | Pbytessetu -> (
      match args with
      | [ e; e0; e1 ] ->
          ensure_value_unit cxt.continuation (Js_of_lam_string.set_byte e e0 e1)
      | _ -> assert false)
  | Pbytessets ->
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:"set" args
  | Pbytesrefu -> (
      match args with
      | [ e; e1 ] -> Js_of_lam_string.ref_byte e e1
      | _ -> assert false)
  | Pbytesrefs ->
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:"get" args
  | Pstring_load_16 unsafe ->
      let fn = if unsafe then "get16u" else "get16" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pstring_load_32 unsafe ->
      let fn = if unsafe then "get32u" else "get32" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pstring_load_64 unsafe ->
      let fn = if unsafe then "get64u" else "get64" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_load_16 unsafe ->
      let fn = if unsafe then "get16u" else "get16" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_load_32 unsafe ->
      let fn = if unsafe then "get32u" else "get32" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_load_64 unsafe ->
      let fn = if unsafe then "get64u" else "get64" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_set_16 unsafe ->
      let fn = if unsafe then "set16u" else "set16" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_set_32 unsafe ->
      let fn = if unsafe then "set32u" else "set32" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pbytes_set_64 unsafe ->
      let fn = if unsafe then "set64u" else "set64" in
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:fn args
  | Pstringrefs ->
      E.runtime_call ~module_name:Js_runtime_modules.string ~fn_name:"get" args
  (* For bytes and string, they both return [int] in ocaml
      we need tell Pbyteref from Pstringref
      1. Pbyteref -> a[i]
      2. Pstringref -> a.charCodeAt (a[i] is wrong)
  *)
  | Pstringrefu -> (
      match args with
      | [ e; e1 ] -> Js_of_lam_string.ref_string e e1
      | _ -> assert false)
  (* only when Lapply -> expand = true*)
  | Praise -> assert false (* handled before here *)
  (* Runtime encoding relevant *)
  | Parraylength -> E.array_length (List.hd args)
  | Psetfield (i, field_info) -> (
      match args with
      | [ e0; e1 ] ->
          (* RUNTIME *)
          ensure_value_unit cxt.continuation
            (Js_of_lam_block.set_field field_info e0 (Int32.of_int i) e1)
      (*TODO: get rid of [E.unit ()]*)
      | _ -> assert false)
  | Psetfield_computed -> (
      match args with
      | [ self; index; value ] ->
          ensure_value_unit cxt.continuation
            (Js_of_lam_block.set_field_by_exp self index value)
      | _ -> assert false)
  | Parrayrefu -> (
      match args with
      | [ e; e1 ] -> Js_of_lam_array.ref_array e e1 (* Todo: Constant Folding *)
      | _ -> assert false)
  | Parrayrefs ->
      E.runtime_call ~module_name:Js_runtime_modules.array ~fn_name:"get" args
  | Parraysets ->
      E.runtime_call ~module_name:Js_runtime_modules.array ~fn_name:"set" args
  | Pmakearray -> Js_of_lam_array.make_array Mutable args
  | Parraysetu -> (
      match args with
      (* wrong*)
      | [ e; e0; e1 ] ->
          ensure_value_unit cxt.continuation (Js_of_lam_array.set_array e e0 e1)
      | _ -> assert false)
  | Pccall prim -> Lam_dispatch_primitive.translate loc prim.prim_name args
  (* Lam_compile_external_call.translate loc cxt prim args *)
  (* Test if the argument is a block or an immediate integer *)
  | Pjs_object_create _ -> assert false
  | Pjs_call { arg_types; ffi; _ } ->
      Lam_compile_external_call.translate_ffi cxt arg_types ffi args
  (* FIXME, this can be removed later *)
  | Pisint -> E.is_type_number (List.hd args)
  | Pis_poly_var_const -> E.is_type_string (List.hd args)
  | Pctconst ct -> (
      match ct with
      | Big_endian -> E.bool Sys.big_endian
      | Ostype ->
          E.runtime_call ~module_name:Js_runtime_modules.sys ~fn_name:"os_type"
            args
      | Ostype_unix ->
          E.string_equal
            (E.runtime_call ~module_name:Js_runtime_modules.sys
               ~fn_name:"os_type" args)
            (E.str "Unix")
      | Ostype_win32 ->
          E.string_equal
            (E.runtime_call ~module_name:Js_runtime_modules.sys
               ~fn_name:"os_type" args)
            (E.str "Win32")
          (* | Max_wosize ->
             (* max_array_length*)
              E.int 2147483647l (* 2 ^ 31 - 1 *) *)
          (* 4_294_967_295l  not representable*)
          (* 2 ^ 32 - 1*)
      | Backend_type ->
          E.make_block E.zero_int_literal
            (Blk_constructor
               { name = "Other"; num_nonconst = 1; attributes = [] })
            [ E.str "Melange" ]
            Immutable)
  | Pbswap16 ->
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:"bswap16"
        args
  | Pbbswap Pnativeint -> assert false
  | Pbbswap Pint32 ->
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:"bswap32"
        args
  | Pbbswap Pint64 ->
      E.runtime_call ~module_name:Js_runtime_modules.bytes ~fn_name:"bswap64"
        args
  | Pduprecord (Record_regular | Record_extension | Record_inlined _) ->
      Lam_dispatch_primitive.translate loc "caml_obj_dup" args
  | Plazyforce
  (* FIXME: we don't inline lazy force or at least
     let buckle handle it
  *)
  (* let parm = Ident.create "prim" in
         Lfunction(Curried, [parm],
                   Matching.inline_lazy_force (Lvar parm) Location.none)
     It is inlined, this should not appear here *) ->
      (*we dont use [throw] here, since [throw] is an statement  *)
      let s = Lam_print.primitive_to_string prim in
      Location.prerr_warning loc (Mel_unimplemented_primitive s);
      E.resolve_and_apply s args
