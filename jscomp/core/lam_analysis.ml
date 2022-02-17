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


(**used in effect analysis, it is sound but not-complete *)
let not_zero_constant ( x : Lam_constant.t) =
  match x with
  | Const_int {i }  -> i <> 0l
  | Const_int64 i  -> i <> 0L
  | _ -> false


let rec no_side_effects (lam : Lam.t) : bool =
  match lam with
  | Lvar _
  | Lconst _
  | Lfunction _ -> true
  | Lglobal_module _ -> true
    (* we record side effect in the global level,
      this expression itself is side effect free
    *)
  | Lprim {primitive;  args; _} ->
    Ext_list.for_all args  no_side_effects &&
    (
      match primitive with
      | Pccall {prim_name } ->
        begin
          match prim_name,args with
          | ("caml_register_named_value"
            (* register to c runtime does not make sense  in ocaml *)
            | "caml_int64_float_of_bits"
             (* more safe to check if arguments are constant *)
            (* non-observable side effect *)
            | "caml_sys_get_config"
            | "caml_sys_argv" (* should be fine *)
            | "caml_sys_executable_name"
            | "caml_string_repeat"
            | "caml_make_vect"
            | "caml_create_bytes"
            | "caml_obj_dup"
            | "caml_array_dup"

            | "nativeint_add"
            | "nativeint_div"
            | "nativeint_mod"
            | "nativeint_lsr"
            | "nativeint_mul"

            ), _  -> true
          | "caml_ml_open_descriptor_in", [Lconst (  (Const_int {i = 0l}))] -> true
          | "caml_ml_open_descriptor_out",
            [Lconst (  (Const_int {i = 1l|2l})) ]
            -> true
          (* we can not mark it pure
             only when we guarantee this exception is caught...
           *)
          | _ , _-> false
        end
      | Pmodint
      | Pdivint
      | Pdivint64
      | Pmodint64
        -> begin match args with
          | [_ ; Lconst cst ] -> not_zero_constant cst
          | _ -> false
        end

      | Pcreate_extension _
      | Pjs_typeof
      | Pis_null
      | Pis_not_none
      | Psome
      | Psome_not_nest
      | Pis_undefined
      | Pis_null_undefined
      | Pnull_to_opt
      | Pundefined_to_opt
      | Pnull_undefined_to_opt
      | Pjs_fn_make _
      | Pjs_object_create _
        (** TODO: check *)
      | Pbytes_to_string
      | Pbytes_of_string
      | Pmakeblock _  (* whether it's mutable or not *)
      | Pfield _
      | Pfield_computed
      | Pval_from_option
      | Pval_from_option_not_nest
        (* NOP The compiler already [t option] is the same as t *)
      | Pduprecord _
      (* Boolean operations *)
      | Psequand | Psequor | Pnot
      (* Integer operations *)
      | Pnegint | Paddint | Psubint | Pmulint

      | Pandint | Porint | Pxorint
      | Plslint | Plsrint | Pasrint
      | Pintcomp _
      (* Float operations *)
      | Pintoffloat | Pfloatofint
      | Pnegfloat
      (* | Pabsfloat *)
      | Paddfloat | Psubfloat | Pmulfloat
      | Pdivfloat
      | Pfloatcomp _
      | Pjscomp _
      (* String operations *)
      | Pstringlength
      | Pstringrefu
      | Pstringrefs
      | Pbyteslength
      | Pbytesrefu
      | Pbytesrefs
      | Pmakearray
      | Parraylength
      | Parrayrefu
      | Parrayrefs
      (* Test if the argument is a block or an immediate integer *)
      | Pisint
      | Pis_poly_var_const
      (* Test if the (integer) argument is outside an interval *)
      | Pisout _
      | Pint64ofint
      | Pintofint64
      | Pnegint64
      | Paddint64
      | Psubint64
      | Pmulint64
      | Pandint64
      | Porint64
      | Pxorint64
      | Plslint64
      | Plsrint64
      | Pasrint64
      | Pint64comp _
      (* Operations on big arrays: (unsafe, #dimensions, kind, layout) *)
      | Pbigarrayref _ (* TODO it may raise an exception....*)
      (* Compile time constants *)
      | Pctconst _
      (* Integer to external pointer *)

      | Poffsetint _
      | Pstringadd
      | Pjs_function_length
      | Pcaml_obj_length
      | Pwrap_exn
      | Praw_js_code {code_info = Exp (Js_function _ | Js_literal _) | Stmt Js_stmt_comment}
        -> true
      | Pjs_apply
      | Pjs_runtime_apply
      | Pjs_call _
      | Pinit_mod
      | Pupdate_mod
      | Pjs_unsafe_downgrade _
      | Pdebugger
      | Pvoid_run
      | Pfull_apply
      | Pjs_fn_method
      (* TODO *)
      | Praw_js_code _
      | Pbytessetu
      | Pbytessets
      (* Operations on boxed integers (Nativeint.t, Int32.t, Int64.t) *)
      | Pbigarrayset _
      (* size of the nth dimension of a big array *)
      | Pbigarraydim _ 
      | Parraysets
      (* byte swap *)
      | Parraysetu
      | Poffsetref _
      | Praise
      | Plazyforce
      | Psetfield _
      | Psetfield_computed
        -> false
    )
  | Llet (_,_, arg,body) -> no_side_effects arg && no_side_effects body
  | Lswitch (_,_) -> false
  | Lstringswitch (_,_,_) -> false
  | Lstaticraise _ -> false
  | Lstaticcatch _ -> false
  (** It would be nice that we can also analysis some small functions
      for example [String.contains],
      [Format.make_queue_elem]
  *)
  | Ltrywith (body,_exn,handler)
    -> no_side_effects body && no_side_effects handler

  | Lifthenelse  (a,b,c) ->
    no_side_effects a && no_side_effects b && no_side_effects c
  | Lsequence (a,b) -> no_side_effects a && no_side_effects b
  | Lletrec (bindings, body) ->
    Ext_list.for_all_snd bindings no_side_effects && no_side_effects body
  | Lwhile _ -> false (* conservative here, non-terminating loop does have side effect *)
  | Lfor _ -> false
  | Lassign _ -> false (* actually it depends ... *)
  | Lsend _ -> false
  | Lapply {
      ap_func = Lprim {primitive = Pfield (_, Fld_module {name = "from_fun"})};
     ap_args = [arg]}
        -> no_side_effects arg
  | Lapply _ -> false (* we need purity analysis .. *)



(*
    Estimate the size of lambda for better inlining
    threshold is 1000 - so that we
 *)
exception Too_big_to_inline

let really_big () = raise_notrace Too_big_to_inline

(* let big_lambda = 1000 *)

let rec size (lam : Lam.t) =
  try
    match lam with
    | Lvar _ ->  1
    | Lconst c -> size_constant c
    | Llet(_, _, l1, l2) -> 1 + size l1 + size l2
    | Lletrec _ -> really_big ()
    | Lprim{primitive = Pfield (_, Fld_module _);
            args =  [ Lglobal_module _ | Lvar _ ]
           ;  _}
      -> 1
    | Lprim {primitive = Praise | Pis_not_none ; args =  [l ];  _}
      -> size l
    | Lglobal_module _ -> 1
    | Lprim {primitive =
        Praw_js_code _
      } -> really_big ()
    | Lprim {args = ll; _} -> size_lams 1 ll

    (** complicated
        1. inline this function
        2. ...
        exports.Make=
        function(funarg)
        {var $$let=Make(funarg);
        return [0, $$let[5],... $$let[16]]}
     *)
    | Lapply{ ap_func;
             ap_args; _} -> size_lams (size ap_func) ap_args
    (* | Lfunction(_, params, l) -> really_big () *)
    | Lfunction {body} -> size body
    | Lswitch _ -> really_big ()
    | Lstringswitch(_,_,_) -> really_big ()
    | Lstaticraise (_i,ls) ->
        Ext_list.fold_left ls 1 (fun acc x -> size x + acc)
    | Lstaticcatch _ -> really_big ()
    | Ltrywith _ -> really_big ()
    | Lifthenelse(l1, l2, l3) -> 1 + size  l1 + size  l2 +  size  l3
    | Lsequence(l1, l2) -> size  l1  +  size  l2
    | Lwhile _ -> really_big ()
    | Lfor _ -> really_big ()
    | Lassign (_,v) -> 1 + size v  (* This is side effectful,  be careful *)
    | Lsend _  ->  really_big ()

  with Too_big_to_inline ->  1000
and size_constant x =
  match x with
  | Const_int _ | Const_char _

  | Const_float _  | Const_int64 _
  | Const_pointer _
  | Const_js_null | Const_js_undefined | Const_module_alias
  | Const_js_true | Const_js_false
    -> 1
  | Const_unicode _  (* TODO: this seems to be not good heurisitives*)
  | Const_string _ ->  1
  | Const_some s -> size_constant s
  | Const_block (_, _, str)
    ->  Ext_list.fold_left str 0 (fun acc x -> acc + size_constant x )
  | Const_float_array xs  -> List.length xs

and size_lams acc (lams : Lam.t list) =
  Ext_list.fold_left lams acc (fun acc l -> acc  + size l )
let args_all_const (args : Lam.t list) =
  Ext_list.for_all args (fun x -> match x with Lconst _ -> true | _ -> false)

let exit_inline_size = 7
let small_inline_size = 5

(** destruct pattern will work better
    if it is closed lambda, otherwise
    you can not do full evaluation

    We still should avoid inline too big code,

    ideally we should also evaluate its size after inlining,
    since after partial evaluation, it might still be *very big*
*)
let destruct_pattern (body : Lam.t) params args =
  let rec aux v params args =
    match params, args with
    | x::xs, b::bs ->
      if Ident.same x v then Some b
      else aux v xs bs
    | [] , _ -> None
    | _::_, [] -> assert false
  in
  match body with
  | Lswitch (Lvar v , switch)
    ->
    begin match aux v params args with
      | Some (Lam.Lconst _ as lam) ->
        size (Lam.switch lam switch) < small_inline_size
      | Some _ | None -> false
    end
  | Lifthenelse(Lvar v, then_, else_)
    -> (* -FIXME *)
    begin match aux v params args with
      | Some (Lconst _ as lam) ->
        size (Lam.if_ lam then_ else_) < small_inline_size
      | Some _ | None -> false
    end
  | _ -> false

(** Hints to inlining *)
let ok_to_inline_fun_when_app
  (m : Lam.lfunction)
  (args : Lam.t list) =
  match m.attr.inline with
  | Always_inline -> true
  | Never_inline -> false
  | Default_inline ->
    match m with
    | {body; params} ->
    let s = size body in
    s < small_inline_size ||
    (destruct_pattern body params args) ||
    (args_all_const args &&
     (s < 10 && no_side_effects body ))







(* TODO:  We can relax this a bit later,
    but decide whether to inline it later in the call site
 *)
let safe_to_inline (lam : Lam.t) =
  match lam with
  | Lfunction _ ->  true
  | Lconst
    (Const_pointer _
    |Const_int {comment = Pt_constructor _}
    | Const_js_true
    | Const_js_false
    | Const_js_undefined
    ) -> true
  | _ -> false
