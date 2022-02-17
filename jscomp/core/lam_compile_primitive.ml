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








module E = Js_exp_make

(* If it is the return value, since it is a side-effect call,
   we return unit, otherwise just return it
*)
let ensure_value_unit (st : Lam_compile_context.continuation) e : E.t =
  match st with
  | EffectCall (Maybe_tail_is_return _ ) | NeedValue (Maybe_tail_is_return _)
  | Assign _ | Declare _ | NeedValue _  -> E.seq e E.unit
  | EffectCall Not_tail -> e
(* NeedValue should return a meaningful expression*)

let translate  loc
    (cxt : Lam_compile_context.t)
    (prim : Lam_primitive.t)
    (args : J.expression list) : J.expression =
  match prim with
  | Pis_not_none ->
      Js_of_lam_option.is_not_none (Ext_list.singleton_exn args)
  | Pcreate_extension s
    ->
    E.make_exception s
  | Pwrap_exn ->
    E.runtime_call Js_runtime_modules.caml_js_exceptions "internalToOCamlException" args
  | Praw_js_code {code; code_info} ->
    E.raw_js_code code_info code
    (* FIXME: save one allocation
       trim can not be done before syntax checking
       otherwise location is incorrect
    *)
  | Pjs_runtime_apply ->
    (match args with
     | [f ;  args] ->
       E.flat_call f args
     | _ -> assert false)
  | Pjs_apply ->
    (match args with
     | fn :: rest ->
       E.call ~info:{arity=Full; call_info =  Call_na} fn rest
     | _ -> assert false)
  | Pnull_to_opt ->
    (match args with
     | [e] ->
       (match e.expression_desc with
        | Var _ | Undefined | Null ->
          Js_of_lam_option.null_to_opt e
        | _ ->
          E.runtime_call Js_runtime_modules.option
            "null_to_opt" args)
     | _ -> assert false )

  | Pundefined_to_opt ->
    (match args with
     | [e] ->
       (match e.expression_desc with
        | Var _ | Undefined | Null ->
          Js_of_lam_option.undef_to_opt e
        | _ ->
          E.runtime_call Js_runtime_modules.option
            "undefined_to_opt" args )
     | _ -> assert false )

  | Pnull_undefined_to_opt ->
    begin match args with
      | [e] ->
        begin match e.expression_desc with
          | Var _ | Undefined | Null   ->
            Js_of_lam_option.null_undef_to_opt e
          | _ ->
            E.runtime_call
              Js_runtime_modules.option
              "nullable_to_opt" args
        end
      | _ -> assert false
    end
  | Pjs_function_length ->
    E.function_length (Ext_list.singleton_exn args)
  | Pcaml_obj_length ->
    E.obj_length (Ext_list.singleton_exn args)
  | Pis_null ->
    E.is_null (Ext_list.singleton_exn args)
  | Pis_undefined ->
    E.is_undef (Ext_list.singleton_exn args)
  | Pis_null_undefined ->
    E.is_null_undefined (Ext_list.singleton_exn args)
  | Pjs_typeof ->
    E.typeof (Ext_list.singleton_exn args)

  | Pjs_unsafe_downgrade _
  | Pdebugger
  | Pvoid_run
  | Pfull_apply
  | Pjs_fn_make _
    -> assert false (* already handled by {!Lam_compile} *)
  | Pjs_fn_method -> assert false
  | Pstringadd ->
    begin match args with
      | [a;b] ->
        E.string_append a b
      | _ -> assert false
    end
  | Pinit_mod ->
    E.runtime_call Js_runtime_modules.module_ "init_mod" args
  | Pupdate_mod ->
    E.runtime_call Js_runtime_modules.module_ "update_mod" args
  | Psome ->
    let arg = Ext_list.singleton_exn args in
    (match arg.expression_desc with
     | Null
     | Object _
     | Number _
     | Caml_block _
     | Array _
     | Str _
       ->
       (* This makes sense when type info
          is not available at the definition
          site, and inline recovered it
       *)
       E.optional_not_nest_block arg
     | _ -> E.optional_block arg)
  | Psome_not_nest ->
    E.optional_not_nest_block (Ext_list.singleton_exn args)
  | Pmakeblock(tag, tag_info, mutable_flag ) ->  (* RUNTIME *)
    Js_of_lam_block.make_block
      (Js_op_util.of_lam_mutable_flag mutable_flag)
      tag_info (E.small_int tag) args
  | Pval_from_option ->
    Js_of_lam_option.val_from_option (Ext_list.singleton_exn args)
  | Pval_from_option_not_nest ->
    Ext_list.singleton_exn args
  | Pfield (i, fld_info) ->
    Js_of_lam_block.field fld_info (Ext_list.singleton_exn args) (Int32.of_int i)
    (* Invariant depends on runtime *)
   | Pfield_computed ->
    (match args with
    | [self; index] ->
      Js_of_lam_block.field_by_exp self  index
    | _ -> assert false
    )
  (** Negate boxed int *)

  | Pnegint
    ->
      (* #977 *)
      E.int32_minus (E.zero_int_literal)  (Ext_list.singleton_exn args)
  | Pnegint64
    ->
    Js_long.neg args


  | Pnegfloat
    ->
      E.float_minus (E.zero_float_lit) (Ext_list.singleton_exn args)
  (** Negate boxed int end*)
  (* Int addition and subtraction *)
  | Paddint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_add  e1  e2
      | _ -> assert false
    end
  | Paddint64
    ->
    Js_long.add args


  | Paddfloat
    ->
    begin match args with
      | [e1;e2] ->
        E.float_add  e1  e2
      | _ -> assert false
    end
  | Psubint
    ->
    begin match args with
      | [e1; e2] ->
        E.int32_minus e1 e2
      | _ -> assert false
    end
  | Psubint64
    ->
    Js_long.sub args
  | Psubfloat
    ->
    begin match args with
      | [e1;e2] ->
        E.float_minus   e1  e2
      | _ -> assert false
    end
  | Pmulint
    ->
    begin match args with
      | [e1; e2]  ->
        E.int32_mul  e1  e2
      | _ -> assert false
    end
  | Pmulint64
    ->
    Js_long.mul args
  | Pmulfloat
    ->
    begin match args with
      | [e1; e2]  ->
        E.float_mul  e1  e2
      | _ -> assert false
    end
  | Pdivfloat ->
    begin match args with
      | [e1;e2] -> E.float_div  e1  e2
      | _ -> assert false
    end
  | Pdivint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_div ~checked:(!Js_config.check_div_by_zero) e1 e2
      | _ -> assert false
    end

  | Pdivint64
    -> Js_long.div args
  | Pmodint
    ->
    begin match args with
      | [e1; e2] ->
        E.int32_mod   ~checked:(!Js_config.check_div_by_zero) e1  e2
      | _ -> assert false
    end
  | Pmodint64
    -> Js_long.mod_ args
  | Plslint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_lsl e1  e2
      | _ -> assert false
    end
  | Plslint64
    -> Js_long.lsl_ args
  | Plsrint
    ->
    begin match args with
      | [e1; {J.expression_desc = Number (Int {i=0l; _}|Uint 0l ); _}]
        ->
        e1
      | [e1; e2] ->
        E.to_int32 @@ E.int32_lsr   e1  e2
      | _ -> assert false
    end
  | Plsrint64
    -> Js_long.lsr_ args
  | Pasrint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_asr  e1  e2
      | _ -> assert false
    end
  | Pasrint64
    -> Js_long.asr_ args
  | Pandint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_band  e1  e2
      | _ -> assert false
    end
  | Pandint64
    -> Js_long.and_ args
  | Porint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_bor  e1  e2
      | _ -> assert false
    end
  | Porint64
    -> Js_long.or_ args
  | Pxorint
    ->
    begin match args with
      | [e1;e2] ->
        E.int32_bxor  e1  e2
      | _ -> assert false
    end
  | Pxorint64
    ->
    Js_long.xor args
  | Pjscomp cmp ->
    begin match args with
      | [l;r] -> E.js_comp cmp l r
      | _ -> assert false
    end

  | Pfloatcomp cmp ->
    (match args with
     | [e1;e2] -> E.float_comp cmp e1 e2
     | _ -> assert false )

  | Pintcomp cmp
    ->
    (* Global Builtin Exception is an int, like
       [Not_found] or [Invalid_argument] ?
    *)
    (match args with
     | [e1;e2] -> E.int_comp cmp e1 e2
     | _ -> assert false )
  (* List --> stamp = 0
     Assert_false --> stamp = 26
  *)
  | Pint64comp cmp
    -> Js_long.comp cmp args


  | Pintoffloat ->
    begin
      match args with
      | [e] -> E.to_int32 e
      | _ -> assert false
    end
  | Pint64ofint
    -> Js_long.of_int32 args
  | Pfloatofint
    -> Ext_list.singleton_exn args
  | Pintofint64
    -> Js_long.to_int32 args
  | Pnot ->
    E.not  (Ext_list.singleton_exn args)
  | Poffsetint n ->
    E.offset (Ext_list.singleton_exn args) n
  | Poffsetref n ->
    let v = Js_of_lam_block.field Lambda.ref_field_info (Ext_list.singleton_exn args) 0l in
    E.seq (E.assign  v (E.offset v n)) E.unit
  | Psequand -> (* TODO: rhs is possibly a tail call *)
    begin match args with
      | [e1;e2] ->
        E.and_   e1  e2
      | _ -> assert false
    end
  | Psequor -> (* TODO: rhs is possibly a tail call *)
    begin match args with
      | [e1;e2] ->
        E.or_  e1  e2
      | _ -> assert false
    end
  | Pisout off ->
    begin match args with
      (* predicate: [x > range  or x < 0 ]
         can be simplified if x is positive , x > range
         if x is negative, fine, its uint is for sure larger than range,
         the output is not readable, we might change it back.

         Note that if range is small like [1], then the negative of
         it can be more precise (given integer)
         a normal case of the compiler is  that it will do a shift
         in the first step [ (x - 1) > 1 or ( x - 1 ) < 0 ]
      *)
      | [range; e] -> E.is_out (E.offset e off) range
      | _ -> assert false
    end
  | Pbytes_of_string ->
      (* TODO: write a js primitive  - or is it necessary ?
         if we have byte_get/string_get
         still necessary, since you can set it now.
      *)
    Js_of_lam_string.bytes_of_string (Ext_list.singleton_exn args)
  | Pbytes_to_string  ->
    Js_of_lam_string.bytes_to_string (Ext_list.singleton_exn args)
  | Pstringlength ->
    E.string_length (Ext_list.singleton_exn args)
  | Pbyteslength  ->
    E.bytes_length (Ext_list.singleton_exn args)
  (* This should only be Pbyteset(u|s), which in js, is an int array
     Bytes is an int array in javascript
  *)
  | Pbytessetu
    ->
    (match args with
     | [e;e0;e1] -> ensure_value_unit cxt.continuation
                      (Js_of_lam_string.set_byte e e0 e1)
     | _ -> assert false)
  | Pbytessets ->
    E.runtime_call Js_runtime_modules.bytes "set" args
  | Pbytesrefu ->
    (match args with
     | [e;e1] -> Js_of_lam_string.ref_byte e e1
     | _ -> assert false)
  | Pbytesrefs ->
    E.runtime_call Js_runtime_modules.bytes "get" args
  | Pstringrefs ->
    E.runtime_call Js_runtime_modules.string "get" args

  (* For bytes and string, they both return [int] in ocaml
      we need tell Pbyteref from Pstringref
      1. Pbyteref -> a[i]
      2. Pstringref -> a.charCodeAt (a[i] is wrong)
  *)
  | Pstringrefu  ->
    begin match args with
      | [e;e1] -> Js_of_lam_string.ref_string e e1
      | _ -> assert false
    end
  (** only when Lapply -> expand = true*)
  | Praise  -> assert false (* handled before here *)
  (* Runtime encoding relevant *)
  | Parraylength ->
    E.array_length (Ext_list.singleton_exn args)
  | Psetfield (i, field_info) ->
    (match args with
     | [e0;e1] ->  (** RUNTIME *)
       ensure_value_unit cxt.continuation
         (Js_of_lam_block.set_field field_info e0 (Int32.of_int i) e1)
     (*TODO: get rid of [E.unit ()]*)
     | _ -> assert false)
  | Psetfield_computed ->
    (match args with
    | [self; index; value] ->
      ensure_value_unit cxt.continuation
        (Js_of_lam_block.set_field_by_exp self index value)
    | _ -> assert false
    )
  | Parrayrefu ->
    (match args with
     | [e;e1] -> Js_of_lam_array.ref_array e e1 (* Todo: Constant Folding *)
     | _ -> assert false)
  | Parrayrefs ->
    E.runtime_call Js_runtime_modules.array "get" args
  | Parraysets  ->
    E.runtime_call Js_runtime_modules.array "set" args
  | Pmakearray  ->
    Js_of_lam_array.make_array Mutable  args
  | Parraysetu  ->
      (match args with (* wrong*)
      | [e;e0;e1] -> ensure_value_unit cxt.continuation (Js_of_lam_array.set_array  e e0 e1)
      | _ -> assert false)
  | Pccall prim ->
    Lam_dispatch_primitive.translate loc prim.prim_name  args
  (* Lam_compile_external_call.translate loc cxt prim args *)
  (* Test if the argument is a block or an immediate integer *)
  | Pjs_object_create _
    ->
    assert false

  | Pjs_call {arg_types; ffi} ->
    Lam_compile_external_call.translate_ffi
       cxt arg_types ffi args
  (** FIXME, this can be removed later *)
  | Pisint ->
    E.is_type_number (Ext_list.singleton_exn args)
  | Pis_poly_var_const ->
    E.is_type_string (Ext_list.singleton_exn args)
  | Pctconst ct ->
    (match ct with
     | Big_endian -> E.bool Sys.big_endian
     | Ostype ->
      (E.runtime_call Js_runtime_modules.sys "os_type" args)
     | Ostype_unix ->
       E.string_equal
       (E.runtime_call Js_runtime_modules.sys "os_type" args)
         (E.str "Unix")
     | Ostype_win32 ->
       E.string_equal
         (E.runtime_call Js_runtime_modules.sys "os_type" args)
         (E.str "Win32")
     (* | Max_wosize ->
      (* max_array_length*)
       E.int 2147483647l (* 2 ^ 31 - 1 *)  *)
        (* 4_294_967_295l  not representable*)
        (* 2 ^ 32 - 1*)
     | Backend_type  ->
      E.make_block
        E.zero_int_literal
        (Blk_constructor {name = "Other"; num_nonconst = 1})
        [E.str "BS"] Immutable
     )
  | Pduprecord (Record_regular| Record_extension| Record_inlined _ ) ->
      Lam_dispatch_primitive.translate loc "caml_obj_dup" args
  | Pbigarrayref (unsafe, dimension, kind, layout)
    -> 
    (* can be refined to 
        [caml_bigarray_float32_c_get_1]
        note that kind can be [generic]
        and layout can be [unknown],
        dimension is always available
    *)
    begin match dimension, kind, layout, unsafe with 
      | 1,  ( Pbigarray_float32 | Pbigarray_float64
            | Pbigarray_sint8 | Pbigarray_uint8
            | Pbigarray_sint16 | Pbigarray_uint16
            | Pbigarray_int32 | Pbigarray_int64
            | Pbigarray_caml_int | Pbigarray_native_int
            | Pbigarray_complex32 | Pbigarray_complex64), Pbigarray_c_layout, _
        -> 
        begin match args with
          | [_x;_indx] -> E.runtime_call Js_runtime_modules.bigarray
              ("caml_ba_get_" ^ string_of_int dimension ) args
          | _ -> assert false
        end
      | _, _, _ ,_ -> 
        E.runtime_call Js_runtime_modules.bigarray
          ("caml_ba_get_" ^ string_of_int dimension ) args
    end
  | Pbigarrayset (unsafe, dimension, kind, layout)
    -> 
    begin match dimension, kind, layout, unsafe with 
      | 1,  ( Pbigarray_float32 | Pbigarray_float64
            | Pbigarray_sint8 | Pbigarray_uint8
            | Pbigarray_sint16 | Pbigarray_uint16
            | Pbigarray_int32 | Pbigarray_int64
            | Pbigarray_caml_int | Pbigarray_native_int
            | Pbigarray_complex32 | Pbigarray_complex64), Pbigarray_c_layout, _
        -> 
        begin match args with 
          | [_x; _index; _value] -> 
            E.runtime_call Js_runtime_modules.bigarray 
              ("caml_ba_set_" ^ string_of_int dimension) args          
          | _ -> assert false
        end

      | _ , _, _,_ 
        -> 
          E.runtime_call Js_runtime_modules.bigarray 
            ("caml_ba_set_" ^ string_of_int dimension) args
    end

  | Pbigarraydim i
    -> 
      E.runtime_call Js_runtime_modules.bigarray 
        ("caml_ba_dim_" ^ string_of_int i) args     
  | Plazyforce
    (* FIXME: we don't inline lazy force or at least
      let buckle handle it
    *)
  (*   let parm = Ident.create "prim" in
       Lfunction(Curried, [parm],
                 Matching.inline_lazy_force (Lvar parm) Location.none)
   It is inlined, this should not appear here *)


    ->
    (*we dont use [throw] here, since [throw] is an statement  *)
    let s = Lam_print.primitive_to_string prim in
    Bs_warnings.warn_missing_primitive loc  s;
    E.resolve_and_apply s args


