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

module L = struct
  let js_type_number = "number"
  let js_type_string = "string"
  let js_type_object = "object"
  let js_type_boolean = "boolean"
  let create = "create" (* {!Caml_exceptions.create}*)
  let imul = "imul" (* signed int32 mul *)
  let resolve = "resolve"
  let hd = "hd"
  let tl = "tl"
  let pure = "@__PURE__"
end

let no_side_effect = Js_analyzer.no_side_effect_expression

type t = J.expression

let make_expression ?loc ?comment desc =
  J.{ expression_desc = desc; comment; loc }

(*
  [remove_pure_sub_exp x]
  Remove pure part of the expression (minor optimization)
  and keep the non-pure part while preserve the semantics
  (modulo return value)
  It will return None if  [x] is pure
 *)
let rec remove_pure_sub_exp (x : t) : t option =
  match x.expression_desc with
  | Var _ | Str _ | Unicode _ | Number _ -> None (* Can be refined later *)
  | Array_index (a, b) ->
      if is_pure_sub_exp a && is_pure_sub_exp b then None else Some x
  | Array (xs, _mutable_flag) ->
      if List.for_all ~f:is_pure_sub_exp xs then None else Some x
  | Seq (a, b) -> (
      match (remove_pure_sub_exp a, remove_pure_sub_exp b) with
      | None, None -> None
      | Some u, Some v -> Some { x with expression_desc = Seq (u, v) }
      (* may still have some simplification*)
      | None, (Some _ as v) -> v
      | (Some _ as u), None -> u)
  | _ -> Some x

and is_pure_sub_exp (x : t) = remove_pure_sub_exp x = None

(* let mk ?loc ?comment exp : t =
   {expression_desc = exp ; comment  } *)

let var ?loc ?comment id : t = make_expression ?loc ?comment (Var (Id id))

(* only used in property access,
    Invariant: it should not call an external module .. *)

let js_global ?loc ?comment (v : string) = var ?loc ?comment (Ident.create_js v)
let undefined : t = make_expression Undefined
let nil : t = make_expression Null

let call ?loc ?comment ~info e0 args : t =
  make_expression ?loc ?comment (Call (e0, args, info))

(* TODO: optimization when es is known at compile time
    to be an array
*)
let flat_call ?loc ?comment e0 es : t =
  make_expression ?loc ?comment (FlatCall (e0, es))

let runtime_var_dot ?loc ?comment (x : string) (e1 : string) : J.expression =
  make_expression ?loc ?comment
    (Var
       (Qualified ({ id = Ident.create_persistent x; kind = Runtime }, Some e1)))

let ml_var_dot ?loc ?comment (id : Ident.t) e : J.expression =
  make_expression ?loc ?comment (Var (Qualified ({ id; kind = Ml }, Some e)))

(**
   module as a value
   {[
     var http = require("http")
   ]}
*)
let external_var_field ?loc ?comment ~external_name:name (id : Ident.t) ~field
    ~default : t =
  make_expression ?loc ?comment
    (Var (Qualified ({ id; kind = External { name; default } }, Some field)))

let external_var ?loc ?comment ~external_name (id : Ident.t) : t =
  make_expression ?loc ?comment
    (Var
       (Qualified
          ( { id; kind = External { name = external_name; default = false } },
            None )))

let ml_module_as_var ?loc ?comment (id : Ident.t) : t =
  make_expression ?loc ?comment (Var (Qualified ({ id; kind = Ml }, None)))

(* Static_index .....................*)
let runtime_call module_name fn_name args =
  call ~info:Js_call_info.builtin_runtime_call
    (runtime_var_dot module_name fn_name)
    args

let pure_runtime_call module_name fn_name args =
  call ~comment:L.pure ~info:Js_call_info.builtin_runtime_call
    (runtime_var_dot module_name fn_name)
    args

let runtime_ref module_name fn_name = runtime_var_dot module_name fn_name

let str ?(pure = true) ?loc ?comment s : t =
  make_expression ?loc ?comment (Str (pure, s))

let unicode ?loc ?comment s : t = make_expression ?loc ?comment (Unicode s)

let raw_js_code ?loc ?comment info s : t =
  make_expression ?loc ?comment
    (Raw_js_code
       {
         code =
           (* FIXME: save one allocation
              trim can not be done before syntax checking
              otherwise location is incorrect *)
           String.trim s;
         code_info = info;
       })

let array ?loc ?comment mt es : t =
  make_expression ?loc ?comment (Array (es, mt))

let some_comment = None

let optional_block e : J.expression =
  make_expression ?comment:some_comment (Optional_block (e, false))

let optional_not_nest_block e : J.expression =
  make_expression (Optional_block (e, true))

(* used in normal property
    like [e.length], no dependency introduced
*)
let dot ?loc ?comment (e0 : t) (e1 : string) : t =
  make_expression ?loc ?comment (Static_index (e0, e1, None))

let module_access (e : t) (name : string) (pos : int32) =
  let name = Ident.convert name in
  match e.expression_desc with
  | Caml_block (l, _, _, _) when no_side_effect e -> (
      match List.nth_opt l (Int32.to_int pos) with
      | Some x -> x
      | None -> make_expression (Static_index (e, name, Some pos)))
  | _ -> make_expression (Static_index (e, name, Some pos))

let make_block ?loc ?comment (tag : t) (tag_info : J.tag_info) (es : t list)
    (mutable_flag : J.mutable_flag) : t =
  make_expression ?loc ?comment (Caml_block (es, mutable_flag, tag, tag_info))

(* ATTENTION: this is relevant to how we encode string, boolean *)
let typeof ?loc ?comment (e : t) : t =
  match e.expression_desc with
  | Number _ | Length _ -> str ?comment L.js_type_number
  | Str _ | Unicode _ -> str ?comment L.js_type_string
  | Array _ -> str ?comment L.js_type_object
  | Bool _ -> str ?comment L.js_type_boolean
  | _ -> make_expression ?loc ?comment (Typeof e)

let new_ ?loc ?comment e0 args : t =
  make_expression ?loc ?comment (New (e0, Some args))

let unit : t = make_expression Undefined

(* let math ?loc ?comment v args  : t =
   make_expression ?loc ?comment (Math(v,args)) *)

(* we can do constant folding here, but need to make sure the result is consistent
   {[
     let f x = string_of_int x
     ;; f 3
   ]}
   {[
     string_of_int 3
   ]}
   Used in [string_of_int] and format "%d"
   TODO: optimize
*)

let ocaml_fun ?loc ?comment ?immutable_mask ~return_unit params block : t =
  let len = List.length params in
  make_expression ?loc ?comment
    (Fun (false, params, block, Js_fun_env.make ?immutable_mask len, return_unit))

let method_ ?loc ?comment ?immutable_mask ~return_unit params block : t =
  let len = List.length params in
  make_expression ?loc ?comment
    (Fun (true, params, block, Js_fun_env.make ?immutable_mask len, return_unit))

(** ATTENTION: This is coupuled with {!Caml_obj.caml_update_dummy} *)
let dummy_obj ?loc ?comment (info : Lam.Tag_info.t) : t =
  (* TODO:
     for record it is [{}]
     for other it is [[]]
  *)
  match info with
  | Blk_record _ | Blk_module _ | Blk_constructor _ | Blk_record_inlined _
  | Blk_poly_var | Blk_extension | Blk_record_ext _ ->
      make_expression ?loc ?comment (Object [])
  | Blk_tuple | Blk_array | Blk_na _ | Blk_class | Blk_module_export ->
      make_expression ?loc ?comment (Array ([], Mutable))

(* TODO: complete
    pure ...
*)
let rec seq ?loc ?comment (e0 : t) (e1 : t) : t =
  match (e0.expression_desc, e1.expression_desc) with
  | ( ( Seq (a, { expression_desc = Number _ | Undefined; _ })
      | Seq ({ expression_desc = Number _ | Undefined; _ }, a) ),
      _ ) ->
      seq ?comment a e1
  | _, Seq ({ expression_desc = Number _ | Undefined; _ }, a) ->
      (* Return value could not be changed*)
      seq ?comment e0 a
  | _, Seq (a, ({ expression_desc = Number _ | Undefined; _ } as v)) ->
      (* Return value could not be changed*)
      seq ?comment (seq e0 a) v
  | (Number _ | Var _ | Undefined), _ -> e1
  | _ -> make_expression ?loc ?comment (Seq (e0, e1))

let fuse_to_seq x xs = if xs = [] then x else List.fold_left ~f:seq ~init:x xs

(* let empty_string_literal : t =
   make_expression (Str (true,"")) *)

let zero_int_literal : t = make_expression (Number (Int { i = 0l; c = None }))
let one_int_literal : t = make_expression (Number (Int { i = 1l; c = None }))
let two_int_literal : t = make_expression (Number (Int { i = 2l; c = None }))
let three_int_literal : t = make_expression (Number (Int { i = 3l; c = None }))
let four_int_literal : t = make_expression (Number (Int { i = 4l; c = None }))
let five_int_literal : t = make_expression (Number (Int { i = 5l; c = None }))
let six_int_literal : t = make_expression (Number (Int { i = 6l; c = None }))
let seven_int_literal : t = make_expression (Number (Int { i = 7l; c = None }))
let eight_int_literal : t = make_expression (Number (Int { i = 8l; c = None }))
let nine_int_literal : t = make_expression (Number (Int { i = 9l; c = None }))

let obj_int_tag_literal : t =
  make_expression (Number (Int { i = 248l; c = None }))

let int ?loc ?comment ?c i : t =
  make_expression ?loc ?comment (Number (Int { i; c }))

let small_int i : t =
  match i with
  | 0 -> zero_int_literal
  | 1 -> one_int_literal
  | 2 -> two_int_literal
  | 3 -> three_int_literal
  | 4 -> four_int_literal
  | 5 -> five_int_literal
  | 6 -> six_int_literal
  | 7 -> seven_int_literal
  | 8 -> eight_int_literal
  | 9 -> nine_int_literal
  | 248 -> obj_int_tag_literal
  | i -> int (Int32.of_int i)

let array_index ?loc ?comment (e0 : t) (e1 : t) : t =
  match (e0.expression_desc, e1.expression_desc) with
  | Array (l, _), Number (Int { i; _ })
  (* Float i -- should not appear here *)
    when no_side_effect e0 -> (
      match List.nth_opt l (Int32.to_int i) with
      | None -> make_expression ?loc ?comment (Array_index (e0, e1))
      | Some x -> x (* FIX #3084*))
  | _ -> make_expression ?loc ?comment (Array_index (e0, e1))

let array_index_by_int ?loc ?comment (e : t) (pos : int32) : t =
  match e.expression_desc with
  | Array (l, _) (* Float i -- should not appear here *)
  | Caml_block (l, _, _, _)
    when no_side_effect e -> (
      match List.nth_opt l (Int32.to_int pos) with
      | Some x -> x
      | None -> make_expression ?loc (Array_index (e, int ?comment pos)))
  | _ -> make_expression ?loc (Array_index (e, int ?comment pos))

let record_access (e : t) (name : string) (pos : int32) =
  match e.expression_desc with
  | Array (l, _) (* Float i -- should not appear here *)
  | Caml_block (l, _, _, _)
    when no_side_effect e -> (
      match List.nth_opt l (Int32.to_int pos) with
      | Some x -> x
      | None -> make_expression (Static_index (e, name, Some pos)))
  | _ -> make_expression (Static_index (e, name, Some pos))

(* The same as {!record_access} except tag*)
let inline_record_access = record_access
let noncons_pos pos = "_" ^ Int32.to_string pos

let cons_pos pos =
  match pos with 0l -> L.hd | 1l -> L.tl | _ -> noncons_pos pos

let variant_pos ~constr pos =
  match Js_op_util.is_cons constr with
  | true -> cons_pos pos
  | false -> noncons_pos pos

let variant_access (e : t) (pos : int32) =
  inline_record_access e (noncons_pos pos) pos

let cons_access (e : t) (pos : int32) =
  inline_record_access e (cons_pos pos) pos

let poly_var_tag_access (e : t) =
  match e.expression_desc with
  | Caml_block (l, _, _, _) when no_side_effect e -> (
      match l with x :: _ -> x | [] -> assert false)
  | _ -> make_expression (Static_index (e, Js_dump_lit.polyvar_hash, Some 0l))

let poly_var_value_access (e : t) =
  match e.expression_desc with
  | Caml_block (l, _, _, _) when no_side_effect e -> (
      match l with _ :: v :: _ -> v | _ -> assert false)
  | _ -> make_expression (Static_index (e, Js_dump_lit.polyvar_value, Some 1l))

let extension_access (e : t) ?name (pos : int32) : t =
  match e.expression_desc with
  | Array (l, _) (* Float i -- should not appear here *)
  | Caml_block (l, _, _, _)
    when no_side_effect e -> (
      match List.nth_opt l (Int32.to_int pos) with
      | Some x -> x
      | None ->
          let name =
            match name with Some n -> n | None -> "_" ^ Int32.to_string pos
          in
          make_expression (Static_index (e, name, Some pos)))
  | _ ->
      let name =
        match name with Some n -> n | None -> "_" ^ Int32.to_string pos
      in
      make_expression (Static_index (e, name, Some pos))

let string_index ?loc ?comment (e0 : t) (e1 : t) : t =
  match (e0.expression_desc, e1.expression_desc) with
  | Str (_, s), Number (Int { i; _ }) ->
      (* Don't optimize {j||j} *)
      let i = Int32.to_int i in
      if i >= 0 && i < String.length s then
        (* TODO: check exception when i is out of range..
           RangeError?
        *)
        str (String.make 1 s.[i])
      else make_expression ?loc ?comment (String_index (e0, e1))
  | _ -> make_expression ?loc ?comment (String_index (e0, e1))

let assign ?loc ?comment e0 e1 : t =
  make_expression ?loc ?comment (Bin (Eq, e0, e1))

let assign_by_exp (e : t) index value : t =
  match e.expression_desc with
  | Array _
  (*
     Temporary block -- address not held
     Optimize cases like this which is really
     rare {[
      (ref x) :=  3
     ]}
      *)
  | Caml_block _
    when no_side_effect e && no_side_effect index ->
      value
  | _ -> assign (make_expression (Array_index (e, index))) value

let assign_by_int ?loc ?comment e0 (index : int32) value =
  assign_by_exp e0 (int ?loc ?comment index) value

let record_assign (e : t) (pos : int32) (name : string) (value : t) =
  match e.expression_desc with
  | Array _
  (*
     Temporary block -- address not held
     Optimize cases like this which is really
     rare {[
      (ref x) :=  3
     ]}
      *)
  | Caml_block _
    when no_side_effect e ->
      value
  | _ -> assign (make_expression (Static_index (e, name, Some pos))) value

let extension_assign (e : t) (pos : int32) name (value : t) =
  match e.expression_desc with
  | Array _
  (*
           Temporary block -- address not held
           Optimize cases like this which is really
           rare {[
                  (ref x) :=  3
                ]}
             *)
  | Caml_block _
    when no_side_effect e ->
      value
  | _ -> assign (make_expression (Static_index (e, name, Some pos))) value

(* This is a property access not external module *)

let array_length ?loc ?comment (e : t) : t =
  match e.expression_desc with
  (* TODO: use array instead? *)
  | (Array (l, _) | Caml_block (l, _, _, _)) when no_side_effect e ->
      int ?comment (Int32.of_int (List.length l))
  | _ -> make_expression ?loc ?comment (Length (e, Array))

let string_length ?loc ?comment (e : t) : t =
  match e.expression_desc with
  | Str (_, v) -> int ?comment (Int32.of_int (String.length v))
  (* No optimization for {j||j}*)
  | _ -> make_expression ?loc ?comment (Length (e, String))

(* TODO: use [Buffer] instead? *)
let bytes_length ?loc ?comment (e : t) : t =
  match e.expression_desc with
  | Array (l, _) -> int ?comment (Int32.of_int (List.length l))
  | _ -> make_expression ?loc ?comment (Length (e, Bytes))

let function_length ?loc ?comment (e : t) : t =
  match e.expression_desc with
  | Fun (b, params, _, _, _) ->
      let params_length = List.length params in
      int ?comment
        (Int32.of_int (if b then params_length - 1 else params_length))
  | _ -> make_expression ?loc ?comment (Length (e, Function))

(** no dependency introduced *)
(* let js_global_dot ?loc ?comment (x : string)  (e1 : string) : t =
     { expression_desc = Static_index (js_global x,  e1,None); comment}

   let char_of_int ?loc ?comment (v : t) : t =
     match v.expression_desc with
     | Number (Int {i; _}) ->
       str  (String.make 1(Char.chr (Int32.to_int i)))
     | Char_to_int v -> v
     | _ ->  make_expression ?loc ?comment (Char_of_int v) *)

let char_to_int ?loc ?comment (v : t) : t =
  match v.expression_desc with
  | Str (_, x) ->
      (* No optimization for .. *)
      assert (String.length x = 1);
      int ~comment:(Printf.sprintf "%S" x) (Int32.of_int @@ Char.code x.[0])
  | Char_of_int v -> v
  | _ -> make_expression ?loc ?comment (Char_to_int v)

let rec string_append ?loc ?comment (e : t) (el : t) : t =
  match (e.expression_desc, el.expression_desc) with
  | Str (_, a), String_append ({ expression_desc = Str (_, b); _ }, c) ->
      string_append ?comment (str (a ^ b)) c
  | String_append (c, { expression_desc = Str (_, b); _ }), Str (_, a) ->
      string_append ?comment c (str (b ^ a))
  | ( String_append (a, { expression_desc = Str (_, b); _ }),
      String_append ({ expression_desc = Str (_, c); _ }, d) ) ->
      string_append ?comment (string_append a (str (b ^ c))) d
  | Str (_, a), Str (_, b) -> str ?comment (a ^ b)
  | _, _ -> make_expression ?loc ?comment (String_append (e, el))

let obj ?loc ?comment properties : t =
  make_expression ?loc ?comment (Object properties)

(* currently only in method call, no dependency introduced
*)

(* Static_index .....................*)

(* var (Jident.create_js "true") *)
let true_ : t = make_expression (Bool true)
let false_ : t = make_expression (Bool false)
let bool v = if v then true_ else false_

(** Arith operators *)
(* Static_index .....................**)

let float ?loc ?comment f : t =
  make_expression ?loc ?comment (Number (Float { f }))

let zero_float_lit : t = make_expression (Number (Float { f = "0." }))

let float_mod ?loc ?comment e1 e2 : J.expression =
  make_expression ?loc ?comment (Bin (Mod, e1, e2))

let str_equal (str0 : J.expression_desc) (str1 : J.expression_desc) =
  match (str0, str1) with
  | Str (_, txt0), Str (_, txt1) | Unicode txt0, Unicode txt1 ->
      if String.equal txt0 txt1 then Some true
      else if
        Melange_ffi.Utf8_string.simple_comparison txt0
        && Melange_ffi.Utf8_string.simple_comparison txt1
      then Some false
      else None
  | Str _, Unicode _ | Unicode _, Str _ -> None
  | _ -> None

let rec triple_equal ?loc ?comment (e0 : t) (e1 : t) : t =
  match (e0.expression_desc, e1.expression_desc) with
  | ( (Null | Undefined),
      ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ) )
    when no_side_effect e1 ->
      false_ (* TODO: rename it as [caml_false] *)
  | ( ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ),
      (Null | Undefined) )
    when no_side_effect e0 ->
      false_
  | Char_to_int a, Char_to_int b -> triple_equal ?comment a b
  | Char_to_int a, Number (Int { i = _; c = Some v })
  | Number (Int { i = _; c = Some v }), Char_to_int a ->
      triple_equal ?comment a (str (String.make 1 v))
  | Unicode x, Unicode y -> bool (String.equal x y)
  | Number (Int { i = i0; _ }), Number (Int { i = i1; _ }) -> bool (i0 = i1)
  | Char_of_int a, Char_of_int b | Optional_block (a, _), Optional_block (b, _)
    ->
      triple_equal ?comment a b
  | Undefined, Optional_block _
  | Optional_block _, Undefined
  | Null, Undefined
  | Undefined, Null ->
      false_
  | Null, Null | Undefined, Undefined -> true_
  | _ -> make_expression ?loc ?comment (Bin (EqEqEq, e0, e1))

let bin ?loc ?comment (op : J.binop) (e0 : t) (e1 : t) : t =
  match (op, e0.expression_desc, e1.expression_desc) with
  | EqEqEq, _, _ -> triple_equal ?comment e0 e1
  | Ge, Length (e, _), Number (Int { i = 0l; _ }) when no_side_effect e ->
      true_ (* x.length >=0 | [x] is pure  -> true*)
  | Gt, Length (_, _), Number (Int { i = 0l; _ }) ->
      (* [e] is kept so no side effect check needed *)
      make_expression ?loc ?comment (Bin (NotEqEq, e0, e1))
  | _ -> make_expression ?loc ?comment (Bin (op, e0, e1))

(* TODO: Constant folding, Google Closure will do that?,
   Even if Google Clsoure can do that, we will see how it interact with other
   optimizations
   We wrap all boolean functions here, since OCaml boolean is a
   bit different from Javascript, so that we can change it in the future

   {[ a && (b && c) === (a && b ) && c ]}
     is not used: benefit is not clear
     | Int_of_boolean e10, Bin(And, {expression_desc = Int_of_boolean e20 }, e3)
      ->
      and_ ?comment
        { e1 with expression_desc
                  =
                    J.Int_of_boolean make_expression (Bin (And, e10,e20))
        }
        e3
   Note that
   {[ "" && 3 ]}
     return  "" instead of false, so [e1] is indeed useful
   optimization if [e1 = e2], then and_ e1 e2 -> e2
     be careful for side effect
*)

let and_ ?loc ?comment (e1 : t) (e2 : t) : t =
  match (e1.expression_desc, e2.expression_desc) with
  | Var i, Var j when Js_op_util.same_vident i j -> e1
  | Var i, Bin (And, { expression_desc = Var j; _ }, _)
    when Js_op_util.same_vident i j ->
      e2
  | Var i, Bin (And, l, ({ expression_desc = Var j; _ } as r))
    when Js_op_util.same_vident i j ->
      { e2 with expression_desc = Bin (And, r, l) }
  | ( Bin
        ( NotEqEq,
          { expression_desc = Var i; _ },
          { expression_desc = Undefined; _ } ),
      Bin
        ( EqEqEq,
          { expression_desc = Var j; _ },
          { expression_desc = Str _ | Number _ | Unicode _; _ } ) )
    when Js_op_util.same_vident i j ->
      e2
  | _, _ -> make_expression ?loc ?comment (Bin (And, e1, e2))

let or_ ?loc ?comment (e1 : t) (e2 : t) =
  match (e1.expression_desc, e2.expression_desc) with
  | Var i, Var j when Js_op_util.same_vident i j -> e1
  | Var i, Bin (Or, { expression_desc = Var j; _ }, _)
    when Js_op_util.same_vident i j ->
      e2
  | Var i, Bin (Or, l, ({ expression_desc = Var j; _ } as r))
    when Js_op_util.same_vident i j ->
      { e2 with expression_desc = Bin (Or, r, l) }
  | _, _ -> make_expression ?loc ?comment (Bin (Or, e1, e2))

(* return a value of type boolean *)
(* TODO:
     when comparison with Int
     it is right that !(x > 3 ) -> x <= 3 *)
let not (e : t) : t =
  match e.expression_desc with
  | Number (Int { i; _ }) -> bool (i = 0l)
  | Js_not e -> e
  | Bool b -> if b then false_ else true_
  | Bin (EqEqEq, e0, e1) -> { e with expression_desc = Bin (NotEqEq, e0, e1) }
  | Bin (NotEqEq, e0, e1) -> { e with expression_desc = Bin (EqEqEq, e0, e1) }
  | Bin (Lt, a, b) -> { e with expression_desc = Bin (Ge, a, b) }
  | Bin (Ge, a, b) -> { e with expression_desc = Bin (Lt, a, b) }
  | Bin (Le, a, b) -> { e with expression_desc = Bin (Gt, a, b) }
  | Bin (Gt, a, b) -> { e with expression_desc = Bin (Le, a, b) }
  | _ -> make_expression (Js_not e)

let not_empty_branch (x : t) =
  match x.expression_desc with
  | Number (Int { i = 0l; _ }) | Undefined -> false
  | _ -> true

let rec econd ?loc ?comment (pred : t) (ifso : t) (ifnot : t) : t =
  match (pred.expression_desc, ifso.expression_desc, ifnot.expression_desc) with
  | Bool false, _, _ -> ifnot
  | Number (Int { i = 0l; _ }), _, _ -> ifnot
  | (Number _ | Array _ | Caml_block _), _, _ when no_side_effect pred ->
      ifso (* a block can not be false in OCAML, CF - relies on flow inference*)
  | Bool true, _, _ -> ifso
  | _, Cond (pred1, ifso1, ifnot1), _
    when Js_analyzer.eq_expression ifnot1 ifnot ->
      (* {[
           if b then (if p1 then branch_code0 else branch_code1)
           else branch_code1
         ]}
         is equivalent to
         {[
           if b && p1 then branch_code0 else branch_code1
         ]}
      *)
      econd (and_ pred pred1) ifso1 ifnot
  | _, Cond (pred1, ifso1, ifnot1), _ when Js_analyzer.eq_expression ifso1 ifnot
    ->
      econd (and_ pred (not pred1)) ifnot1 ifnot
  | _, _, Cond (pred1, ifso1, ifnot1) when Js_analyzer.eq_expression ifso ifso1
    ->
      econd (or_ pred pred1) ifso ifnot1
  | _, _, Cond (pred1, ifso1, ifnot1) when Js_analyzer.eq_expression ifso ifnot1
    ->
      econd (or_ pred (not pred1)) ifso ifso1
  | Js_not e, _, _ when not_empty_branch ifnot -> econd ?comment e ifnot ifso
  | ( _,
      Seq (a, { expression_desc = Undefined; _ }),
      Seq (b, { expression_desc = Undefined; _ }) ) ->
      seq (econd ?comment pred a b) undefined
  | _ ->
      if Js_analyzer.eq_expression ifso ifnot then
        if no_side_effect pred then ifso else seq ?comment pred ifso
      else make_expression ?loc ?comment (Cond (pred, ifso, ifnot))

let rec float_equal ?loc ?comment (e0 : t) (e1 : t) : t =
  match (e0.expression_desc, e1.expression_desc) with
  | Number (Int { i = i0; _ }), Number (Int { i = i1; _ }) -> bool (i0 = i1)
  | Undefined, Undefined -> true_
  (* | (Bin(Bor,
          {expression_desc = Number(Int {i = 0l; _})},
          ({expression_desc = Caml_block_tag _; _} as a ))
     |
       Bin(Bor,
           ({expression_desc = Caml_block_tag _; _} as a),
           {expression_desc = Number (Int {i = 0l; _})})),
     Number (Int {i = 0l;}) when e1.comment = None
     ->  (** (x.tag | 0) === 0  *)
     not  a *)
  | ( ( Bin
          ( Bor,
            { expression_desc = Number (Int { i = 0l; _ }); _ },
            ({ expression_desc = Caml_block_tag _; _ } as a) )
      | Bin
          ( Bor,
            ({ expression_desc = Caml_block_tag _; _ } as a),
            { expression_desc = Number (Int { i = 0l; _ }); _ } ) ),
      Number _ ) ->
      (* for sure [i <> 0 ]*)
      (* since a is integer, if we guarantee there is no overflow
         of a
         then [a | 0] is a nop unless a is undefined
         (which is applicable when applied to tag),
         obviously tag can not be overflowed.
         if a is undefined, then [ a|0===0 ] is true
         while [a === 0 ] is not true
         [a|0 === non_zero] is false and [a===non_zero] is false
         so we can not eliminate when the tag is zero
      *)
      float_equal ?comment a e1
  | Number (Float { f = f0; _ }), Number (Float { f = f1 }) when f0 = f1 ->
      true_
  | Char_to_int a, Char_to_int b -> float_equal ?comment a b
  | Char_to_int a, Number (Int { i = _; c = Some v })
  | Number (Int { i = _; c = Some v }), Char_to_int a ->
      float_equal ?comment a (str (String.make 1 v))
  | Char_of_int a, Char_of_int b -> float_equal ?comment a b
  | _ -> make_expression ?loc ?comment (Bin (EqEqEq, e0, e1))

let int_equal = float_equal

let string_equal ?loc ?comment (e0 : t) (e1 : t) : t =
  match str_equal e0.expression_desc e1.expression_desc with
  | Some b -> bool b
  | None -> make_expression ?loc ?comment (Bin (EqEqEq, e0, e1))

let is_type_number ?loc ?comment (e : t) : t =
  string_equal ?loc ?comment (typeof e) (str "number")

let is_type_string ?loc ?comment (e : t) : t =
  string_equal ?loc ?comment (typeof e) (str "string")

(* we are calling [Caml_primitive.primitive_name], since it's under our
   control, we should make it follow the javascript name convention, and
   call plain [dot]
*)

let tag ?loc ?comment e : t =
  make_expression
    (Bin
       (Bor, make_expression ?loc ?comment (Caml_block_tag e), zero_int_literal))

(* according to the compiler, [Btype.hash_variant],
   it's reduced to 31 bits for hash
*)
(* FIXME: unused meth_name *)
let public_method_call _meth_name obj label cache args =
  let len = List.length args in
  (* econd (int_equal (tag obj ) obj_int_tag_literal) *)
  if len <= 7 then
    runtime_call Js_runtime_modules.caml_oo_curry
      ("js" ^ string_of_int (len + 1))
      (label :: int cache :: obj :: args)
  else
    runtime_call Js_runtime_modules.caml_oo_curry "js"
      [ label; int cache; obj; array NA (obj :: args) ]

(* TODO: handle arbitrary length of args ..
   we can reduce part of the overhead by using
   `__js` -- a easy ppx {{ x ##.hh }}
   the downside is that no way to swap ocaml/js implementation
   for object part, also need encode arity..
   how about x#|getElementById|2|
*)

(* Note that [lsr] or [bor] are js semantics *)
let rec int32_bor ?loc ?comment (e1 : J.expression) (e2 : J.expression) :
    J.expression =
  match (e1.expression_desc, e2.expression_desc) with
  | Number (Int { i = i1; _ } | Uint i1), Number (Int { i = i2; _ }) ->
      int ?comment (Int32.logor i1 i2)
  | ( _,
      Bin
        (Lsr, e2, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ })
    ) ->
      int32_bor e1 e2
  | ( Bin
        (Lsr, e1, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }),
      _ ) ->
      int32_bor e1 e2
  | ( Bin (Lsr, _, { expression_desc = Number (Int { i; _ } | Uint i); _ }),
      Number (Int { i = 0l; _ } | Uint 0l) )
    when i > 0l ->
      (* a >>> 3 | 0 -> a >>> 3 *)
      e1
  | ( Bin
        (Bor, e1, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }),
      Number (Int { i = 0l; _ } | Uint 0l) ) ->
      int32_bor e1 e2
  | _ -> make_expression ?loc ?comment (Bin (Bor, e1, e2))

(* Arithmatic operations
   TODO: distinguish between int and float
   TODO: Note that we have to use Int64 to avoid integer overflow, this is fine
   since Js only have .

   like code below
   {[
     MAX_INT_VALUE - (MAX_INT_VALUE - 100) + 20
   ]}

   {[
     MAX_INT_VALUE - x + 30
   ]}

   check: Re-association: avoid integer overflow
*)
let to_int32 ?loc ?comment (e : J.expression) : J.expression =
  int32_bor ?loc ?comment e zero_int_literal
(* TODO: if we already know the input is int32, [x|0] can be reduced into [x] *)

let uint32 ?loc ?comment n : J.expression =
  make_expression ?loc ?comment (Number (Uint n))

let string_comp (cmp : J.binop) ?loc ?comment (e0 : t) (e1 : t) =
  match (cmp, str_equal e0.expression_desc e1.expression_desc) with
  | EqEqEq, Some b -> bool b
  | NotEqEq, Some b -> bool (b = false)
  | _ -> bin ?loc ?comment cmp e0 e1

let obj_length ?loc ?comment e : t =
  to_int32 ?loc (make_expression ?loc ?comment (Length (e, Caml_block)))

let compare_int_aux (cmp : Lam_compat.integer_comparison) (l : int) r =
  match cmp with
  | Ceq -> l = r
  | Cne -> l <> r
  | Clt -> l < r
  | Cgt -> l > r
  | Cle -> l <= r
  | Cge -> l >= r

let int32_unsigned_to_int n =
  (* works only on 64 bit platform *)
  let i = Int32.to_int n in
  if i < 0 then i + 0x1_0000_0000 else i

let rec int_comp (cmp : Lam_compat.integer_comparison) ?loc ?comment (e0 : t)
    (e1 : t) =
  match (cmp, e0.expression_desc, e1.expression_desc) with
  | _, Number ((Int _ | Uint _) as l), Number ((Int _ | Uint _) as r) ->
      let l =
        match l with
        | Uint l -> int32_unsigned_to_int l
        | Int { i = l; _ } -> Int32.to_int l
        | _ -> assert false
      in
      let r =
        match r with
        | Uint l -> int32_unsigned_to_int l
        | Int { i = l; _ } -> Int32.to_int l
        | _ -> assert false
      in
      bool (compare_int_aux cmp l r)
  | ( _,
      Call
        ( {
            expression_desc =
              Var (Qualified ({ kind = Runtime; _ }, Some "caml_int_compare"));
            _;
          },
          [ l; r ],
          _ ),
      Number (Int { i = 0l; _ }) ) ->
      int_comp cmp l r (* = 0 > 0 < 0 *)
  | ( Ceq,
      Call
        ( ({
             expression_desc =
               Var
                 (Qualified
                    (({ id = _; kind = Runtime } as iid), Some "caml_compare"));
             _;
           } as fn),
          ([ _; _ ] as args),
          call_info ),
      Number (Int { i = 0l; _ }) ) ->
      {
        e0 with
        expression_desc =
          Call
            ( {
                fn with
                expression_desc = Var (Qualified (iid, Some "caml_equal"));
              },
              args,
              call_info );
      }
  | Ceq, Optional_block _, Undefined | Ceq, Undefined, Optional_block _ ->
      false_
  | Ceq, _, _ -> int_equal e0 e1
  | Cne, Optional_block _, Undefined
  | Cne, Undefined, Optional_block _
  | Cne, Caml_block _, Number _
  | Cne, Number _, Caml_block _ ->
      true_
  | _ -> bin ?loc ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1

let bool_comp (cmp : Lam_compat.integer_comparison) ?loc ?comment (e0 : t)
    (e1 : t) =
  match (e0, e1) with
  | { expression_desc = Bool l; _ }, { expression_desc = Bool r; _ } ->
      bool
        (match cmp with
        | Ceq -> l = r
        | Cne -> l <> r
        | Clt -> l < r
        | Cgt -> l > r
        | Cle -> l <= r
        | Cge -> l >= r)
  | { expression_desc = Bool true; _ }, rest
  | rest, { expression_desc = Bool false; _ } -> (
      match cmp with
      | Clt -> seq rest false_
      | Cge -> seq rest true_
      | Cle | Cgt | Ceq | Cne ->
          bin ?loc ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1)
  | rest, { expression_desc = Bool true; _ }
  | { expression_desc = Bool false; _ }, rest -> (
      match cmp with
      | Cle -> seq rest true_
      | Cgt -> seq rest false_
      | Clt | Cge | Ceq | Cne ->
          bin ?loc ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1)
  | _, _ -> bin ?loc ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1

let float_comp cmp ?loc ?comment e0 e1 =
  bin ?loc ?comment (Lam_compile_util.jsop_of_float_comp cmp) e0 e1

let js_comp cmp ?loc ?comment e0 e1 =
  bin ?loc ?comment (Lam_compile_util.jsop_of_comp cmp) e0 e1

let rec int32_lsr ?loc ?comment (e1 : J.expression) (e2 : J.expression) :
    J.expression =
  let aux i1 i = uint32 (Int32.shift_right_logical i1 i) in
  match (e1.expression_desc, e2.expression_desc) with
  | Number (Int { i = i1; _ } | Uint i1), Number (Int { i = i2; _ } | Uint i2)
    ->
      aux i1 (Int32.to_int i2)
  | Bin (Lsr, _, _), Number (Int { i = 0l; _ } | Uint 0l) ->
      e1 (* TODO: more opportunities here *)
  | ( Bin
        (Bor, e1, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }),
      Number (Int { i = 0l; _ } | Uint 0l) ) ->
      int32_lsr ?comment e1 e2
  | _, _ -> make_expression ?loc ?comment (Bin (Lsr, e1, e2) (* uint32 *))

let to_uint32 ?loc ?comment (e : J.expression) : J.expression =
  int32_lsr ?loc ?comment e zero_int_literal

(* TODO:
   we can apply a more general optimization here,
   do some algebraic rewerite rules to rewrite [triple_equal]
*)
let rec is_out ?comment (e : t) (range : t) : t =
  match (range.expression_desc, e.expression_desc) with
  | Number (Int { i = 1l; _ }), Var _ ->
      not
        (or_ (triple_equal e zero_int_literal) (triple_equal e one_int_literal))
  | ( Number (Int { i = 1l; _ }),
      ( Bin
          ( Plus,
            { expression_desc = Number (Int { i; _ }); _ },
            ({ expression_desc = Var _; _ } as x) )
      | Bin
          ( Plus,
            ({ expression_desc = Var _; _ } as x),
            { expression_desc = Number (Int { i; _ }); _ } ) ) ) ->
      not
        (or_
           (triple_equal x (int (Int32.neg i)))
           (triple_equal x (int (Int32.sub Int32.one i))))
  | ( Number (Int { i = 1l; _ }),
      Bin
        ( Minus,
          ({ expression_desc = Var _; _ } as x),
          { expression_desc = Number (Int { i; _ }); _ } ) ) ->
      not (or_ (triple_equal x (int (Int32.add i 1l))) (triple_equal x (int i)))
  (* (x - i >>> 0 ) > k *)
  | ( Number (Int { i = k; _ }),
      Bin
        ( Minus,
          ({ expression_desc = Var _; _ } as x),
          { expression_desc = Number (Int { i; _ }); _ } ) ) ->
      or_ (int_comp Cgt x (int (Int32.add i k))) (int_comp Clt x (int i))
  | Number (Int { i = k; _ }), Var _ ->
      (* Note that js support [ 1 < x < 3],
         we can optimize it into [ not ( 0<= x <=  k)]
      *)
      or_ (int_comp Cgt e (int k)) (int_comp Clt e zero_int_literal)
  | ( _,
      Bin
        ( Bor,
          ({
             expression_desc =
               ( Bin
                   ( (Plus | Minus),
                     { expression_desc = Number (Int { i = _; _ }); _ },
                     { expression_desc = Var _; _ } )
               | Bin
                   ( (Plus | Minus),
                     { expression_desc = Var _; _ },
                     { expression_desc = Number (Int { i = _; _ }); _ } ) );
             _;
           } as e),
          { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ } ) ) ->
      (* TODO: check correctness *)
      is_out ?comment e range
  | _, _ -> int_comp ?comment Cgt (to_uint32 e) range

let rec float_add ?loc ?comment (e1 : t) (e2 : t) =
  match (e1.expression_desc, e2.expression_desc) with
  | Number (Int { i; _ }), Number (Int { i = j; _ }) ->
      int ?comment (Int32.add i j)
  | _, Number (Int { i = j; c }) when j < 0l ->
      float_minus ?comment e1
        { e2 with expression_desc = Number (Int { i = Int32.neg j; c }) }
  | ( Bin (Plus, a1, { expression_desc = Number (Int { i = k; _ }); _ }),
      Number (Int { i = j; _ }) ) ->
      make_expression ?loc ?comment (Bin (Plus, a1, int (Int32.add k j)))
  (* bin ?loc ?comment Plus a1 (int (k + j)) *)
  (* TODO remove commented code  ?? *)
  (* | Bin(Plus, a0 , ({expression_desc = Number (Int a1)}  )), *)
  (*     Bin(Plus, b0 , ({expression_desc = Number (Int b1)}  )) *)
  (*   ->  *)
  (*   bin ?loc ?comment Plus a1 (int (a1 + b1)) *)

  (* | _, Bin(Plus,  b0, ({expression_desc = Number _}  as v)) *)
  (*   -> *)
  (*     bin ?loc ?comment Plus (bin ?comment Plus e1 b0) v *)
  (* | Bin(Plus, a1 , ({expression_desc = Number _}  as v)), _ *)
  (* | Bin(Plus, ({expression_desc = Number _}  as v),a1), _ *)
  (*   ->  *)
  (*     bin ?loc ?comment Plus (bin ?comment Plus a1 e2 ) v  *)
  (* | Number _, _ *)
  (*   ->  *)
  (*     bin ?loc ?comment Plus  e2 e1 *)
  | _ -> make_expression ?loc ?comment (Bin (Plus, e1, e2))

(* bin ?loc ?comment Plus e1 e2 *)
(* associative is error prone due to overflow *)
and float_minus ?loc ?comment (e1 : t) (e2 : t) : t =
  match (e1.expression_desc, e2.expression_desc) with
  | Number (Int { i; _ }), Number (Int { i = j; _ }) ->
      int ?comment (Int32.sub i j)
  | _ -> make_expression ?loc ?comment (Bin (Minus, e1, e2))
(* bin ?loc ?comment Minus e1 e2 *)

let unchecked_int32_add ?loc ?comment e1 e2 = float_add ?loc ?comment e1 e2
let int32_add ?loc ?comment e1 e2 = to_int32 ?loc (float_add ?comment e1 e2)

let offset e1 (offset : int) =
  if offset = 0 then e1 else int32_add e1 (small_int offset)

let int32_minus ?loc ?comment e1 e2 : J.expression =
  to_int32 ?loc (float_minus ?comment e1 e2)

let unchecked_int32_minus ?loc ?comment e1 e2 : J.expression =
  float_minus ?loc ?comment e1 e2

let float_div ?loc ?comment e1 e2 = bin ?loc ?comment Div e1 e2
let float_notequal ?loc ?comment e1 e2 = bin ?loc ?comment NotEqEq e1 e2

let int32_asr ?loc ?comment e1 e2 : J.expression =
  make_expression ?loc ?comment (Bin (Asr, e1, e2))

(** Division by zero is undefined behavior*)
let int32_div ~checked ?loc ?comment (e1 : t) (e2 : t) : t =
  match (e1.expression_desc, e2.expression_desc) with
  | Length _, Number (Int { i = 2l; _ } | Uint 2l) ->
      int32_asr ?loc e1 one_int_literal
  | e1_desc, Number (Int { i = i1; _ }) when i1 <> 0l -> (
      match e1_desc with
      | Number (Int { i = i0; _ }) -> int ?loc (Int32.div i0 i1)
      | _ -> to_int32 ?loc (float_div ?comment e1 e2))
  | _, _ ->
      if checked then runtime_call Js_runtime_modules.int32 "div" [ e1; e2 ]
      else to_int32 ?loc (float_div ?comment e1 e2)

let int32_mod ~checked ?loc ?comment e1 (e2 : t) : J.expression =
  match e2.expression_desc with
  | Number (Int { i; _ }) when i <> 0l ->
      make_expression ?loc ?comment (Bin (Mod, e1, e2))
  | _ ->
      if checked then runtime_call Js_runtime_modules.int32 "mod_" [ e1; e2 ]
      else make_expression ?loc ?comment (Bin (Mod, e1, e2))

let float_mul ?loc ?comment e1 e2 = bin ?loc ?comment Mul e1 e2

let int32_lsl ?loc ?comment (e1 : J.expression) (e2 : J.expression) :
    J.expression =
  match (e1, e2) with
  | ( { expression_desc = Number (Int { i = i0; _ } | Uint i0); _ },
      { expression_desc = Number (Int { i = i1; _ } | Uint i1); _ } ) ->
      int ?comment (Int32.shift_left i0 (Int32.to_int i1))
  | _ -> make_expression ?loc ?comment (Bin (Lsl, e1, e2))

let is_pos_pow n =
  let module M = struct
    exception E
  end in
  let rec aux c (n : Int32.t) =
    if n <= 0l then -2
    else if n = 1l then c
    else if Int32.logand n 1l = 0l then aux (c + 1) (Int32.shift_right n 1)
    else raise_notrace M.E
  in
  try aux 0 n with M.E -> -1

let int32_mul ?loc ?comment (e1 : J.expression) (e2 : J.expression) :
    J.expression =
  match (e1, e2) with
  | { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }, x
    when Js_analyzer.no_side_effect_expression x ->
      zero_int_literal
  | x, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }
    when Js_analyzer.no_side_effect_expression x ->
      zero_int_literal
  | ( { expression_desc = Number (Int { i = i0; _ }); _ },
      { expression_desc = Number (Int { i = i1; _ }); _ } ) ->
      int (Int32.mul i0 i1)
  | e, { expression_desc = Number (Int { i = i0; _ } | Uint i0); _ }
  | { expression_desc = Number (Int { i = i0; _ } | Uint i0); _ }, e ->
      let i = is_pos_pow i0 in
      if i >= 0 then int32_lsl e (small_int i)
      else
        call ?loc ?comment ~info:Js_call_info.builtin_runtime_call
          (dot (js_global "Math") L.imul)
          [ e1; e2 ]
  | _ ->
      call ?loc ?comment ~info:Js_call_info.builtin_runtime_call
        (dot (js_global "Math") L.imul)
        [ e1; e2 ]

let unchecked_int32_mul ?loc ?comment e1 e2 : J.expression =
  make_expression ?loc ?comment (Bin (Mul, e1, e2))

let rec int32_bxor ?loc ?comment (e1 : t) (e2 : t) : J.expression =
  match (e1.expression_desc, e2.expression_desc) with
  | Number (Int { i = i1; _ }), Number (Int { i = i2; _ }) ->
      int ?comment (Int32.logxor i1 i2)
  | ( _,
      Bin
        (Lsr, e2, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ })
    ) ->
      int32_bxor e1 e2
  | ( Bin
        (Lsr, e1, { expression_desc = Number (Int { i = 0l; _ } | Uint 0l); _ }),
      _ ) ->
      int32_bxor e1 e2
  | _ -> make_expression ?loc ?comment (Bin (Bxor, e1, e2))

let rec int32_band ?loc ?comment (e1 : J.expression) (e2 : J.expression) :
    J.expression =
  match e1.expression_desc with
  | Bin (Bor, a, { expression_desc = Number (Int { i = 0l; _ }); _ }) ->
      (* Note that in JS
         {[ -1 >>> 0 & 0xffffffff = -1]} is the same as
         {[ (-1 >>> 0 | 0 ) & 0xffffff ]}
      *)
      int32_band a e2
  | _ -> make_expression ?loc ?comment (Bin (Band, e1, e2))

(* let int32_bin ?loc ?comment op e1 e2 : J.expression =  *)
(*   make_expression ?loc ?comment (Int32_bin(op,e1, e2)) *)

(* TODO -- alpha conversion
    remember to add parens..
*)
let of_block ?loc ?comment ?e block : t =
  let return_unit = false in
  call ~info:Js_call_info.ml_full_call
    (make_expression ?loc ?comment
       (Fun
          ( false,
            [],
            (match e with
            | None -> block
            | Some e ->
                List.append block [ { J.statement_desc = Return e; comment } ]),
            Js_fun_env.make 0,
            return_unit )))
    []

let is_null ?loc ?comment (x : t) = triple_equal ?loc ?comment x nil
let is_undef ?loc ?comment x = triple_equal ?loc ?comment x undefined

let for_sure_js_null_undefined (x : t) =
  match x.expression_desc with Null | Undefined -> true | _ -> false

let is_null_undefined ?loc ?comment (x : t) : t =
  match x.expression_desc with
  | Null | Undefined -> true_
  | Number _ | Array _ | Caml_block _ -> false_
  | _ -> make_expression ?loc ?comment (Is_null_or_undefined x)

let eq_null_undefined_boolean ?loc ?comment (a : t) (b : t) =
  match (a.expression_desc, b.expression_desc) with
  | ( (Null | Undefined),
      ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ) ) ->
      false_
  | ( ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ),
      (Null | Undefined) ) ->
      false_
  | Null, Undefined | Undefined, Null -> false_
  | Null, Null | Undefined, Undefined -> true_
  | _ -> make_expression ?loc ?comment (Bin (EqEqEq, a, b))

let neq_null_undefined_boolean ?loc ?comment (a : t) (b : t) =
  match (a.expression_desc, b.expression_desc) with
  | ( (Null | Undefined),
      ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ) ) ->
      true_
  | ( ( Char_of_int _ | Char_to_int _ | Bool _ | Number _ | Typeof _ | Fun _
      | Array _ | Caml_block _ ),
      (Null | Undefined) ) ->
      true_
  | Null, Null | Undefined, Undefined -> false_
  | Null, Undefined | Undefined, Null -> true_
  | _ -> make_expression ?loc ?comment (Bin (NotEqEq, a, b))

(* TODO: in the future add a flag
   to set globalThis
*)
let resolve_and_apply (s : string) (args : t list) : t =
  call ~info:Js_call_info.builtin_runtime_call
    (runtime_call Js_runtime_modules.external_polyfill L.resolve [ str s ])
    args

let make_exception (s : string) =
  pure_runtime_call Js_runtime_modules.exceptions L.create [ str s ]
