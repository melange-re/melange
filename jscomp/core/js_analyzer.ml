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

let same_vident (x : J.vident) (y : J.vident) =
  match (x, y) with
  | Id x0, Id y0 -> Ident.same x0 y0
  | Qualified (x, str_opt0), Qualified (y, str_opt1) ->
      let same_kind (x : Js_op.kind) (y : Js_op.kind) =
        match (x, y) with
        | Ml, Ml | Runtime, Runtime -> true
        | External { name = u; _ }, External { name = v; _ } ->
            u = v (* not comparing Default since we will do it later *)
        | _, _ -> false
      in
      Ident.same x.id y.id && same_kind x.kind y.kind
      && Option.equal String.equal str_opt0 str_opt1
  | Id _, Qualified _ | Qualified _, Id _ -> false

type idents_stats = {
  mutable used_idents : Ident.Set.t;
  mutable defined_idents : Ident.Set.t;
}

let add_defined_idents (x : idents_stats) ident =
  x.defined_idents <- Ident.Set.add x.defined_idents ident

(* Assume that functions already calculated closure correctly
   Maybe in the future, we should add a dirty flag, to mark the calcuated
   closure is correct or not

   Note such shaking is done in the toplevel, so that it requires us to
   flatten the statement first
*)
let super = Js_record_iter.super

let free_variables (stats : idents_stats) =
  {
    super with
    variable_declaration =
      (fun self st ->
        add_defined_idents stats st.ident;
        match st.value with None -> () | Some v -> self.expression self v);
    ident =
      (fun _ id ->
        if not (Ident.Set.mem stats.defined_idents id) then
          stats.used_idents <- Ident.Set.add stats.used_idents id);
    expression =
      (fun self exp ->
        match exp.expression_desc with
        | Fun { env; _ }
        (* a optimization to avoid walking into function again
            if it's already comuted
        *)
          ->
            stats.used_idents <-
              Ident.Set.union (Js_fun_env.get_unbounded env) stats.used_idents
        | _ -> super.expression self exp);
  }

let init = { used_idents = Ident.Set.empty; defined_idents = Ident.Set.empty }
let obj = free_variables init

let clean_up init =
  init.used_idents <- Ident.Set.empty;
  init.defined_idents <- Ident.Set.empty

let free_variables_of_statement st =
  clean_up init;
  obj.statement obj st;
  Ident.Set.diff init.used_idents init.defined_idents

let free_variables_of_expression st =
  clean_up init;
  obj.expression obj st;
  Ident.Set.diff init.used_idents init.defined_idents

let rec no_side_effect_expression_desc (x : J.expression_desc) =
  match x with
  | Undefined | Null | Bool _ | Var _ | Unicode _ | Module _ -> true
  | Fun _ -> true
  | Number _ -> true (* Can be refined later *)
  | Static_index
      { expr = obj; field = (_name : string); pos = (_pos : int32 option) } ->
      no_side_effect obj
  | String_index { expr = a; index = b } | Array_index { expr = a; index = b }
    ->
      no_side_effect a && no_side_effect b
  | Is_null_or_undefined b -> no_side_effect b
  | Str _ -> true
  | Array { items = xs; mutable_flag = _mutable_flag }
  | Caml_block { fields = xs; mutable_flag = _mutable_flag; _ } ->
      (* create [immutable] block,
          does not really mean that this opreation itself is [pure].

          the block is mutable does not mean this operation is non-pure
      *)
      List.for_all ~f:no_side_effect xs
  | Optional_block (x, _) -> no_side_effect x
  | Object kvs -> List.for_all ~f:(fun (_, x) -> no_side_effect x) kvs
  | String_append { prefix = a; suffix = b } | Seq (a, b) ->
      no_side_effect a && no_side_effect b
  | Length { expr = e; _ }
  | Char_of_int e
  | Char_to_int e
  | Caml_block_tag { expr = e; _ }
  | Typeof e ->
      no_side_effect e
  | Bin { op; expr1 = a; expr2 = b } ->
      op <> Eq && no_side_effect a && no_side_effect b
  | Js_not _ | Cond _ | FlatCall _ | Call _ | New _ | Raw_js_code _
  (* | Caml_block_set_tag _  *)
  (* actually true? *) ->
      false

and no_side_effect (x : J.expression) =
  no_side_effect_expression_desc x.expression_desc

let no_side_effect_expression (x : J.expression) = no_side_effect x
let super = Js_record_iter.super

let no_side_effect_obj =
  {
    super with
    statement =
      (fun self s ->
        match s.statement_desc with
        | Throw _ | Debugger | Variable _ | Continue -> raise_notrace Not_found
        | Exp e -> self.expression self e
        | Int_switch _ | String_switch _ | ForRange _ | If _ | While _ | Block _
        | Return _ | Try _ ->
            super.statement self s);
    expression =
      (fun _ s ->
        if not (no_side_effect_expression s) then raise_notrace Not_found);
  }

let no_side_effect_statement st =
  try
    no_side_effect_obj.statement no_side_effect_obj st;
    true
  with _ -> false

(* TODO: generate [fold2]
   This make sense, for example:
   {[
     let string_of_formatting_gen : type a b c d e f .
       (a, b, c, d, e, f) formatting_gen -> string =
       fun formatting_gen -> match formatting_gen with
         | Open_tag (Format (_, str)) -> str
         | Open_box (Format (_, str)) -> str

   ]}
*)
let rec eq_expression ({ expression_desc = x0; _ } : J.expression)
    ({ expression_desc = y0; _ } : J.expression) =
  match x0 with
  | Null -> y0 = Null
  | Undefined -> y0 = Undefined
  | Number (Int { i; _ }) -> (
      match y0 with Number (Int { i = j; _ }) -> i = j | _ -> false)
  | Number (Float _) ->
      false
      (* begin match y0 with
           | Number (Float j) ->
             false (* conservative *)
           | _ -> false
         end *)
  | String_index { expr = a0; index = a1 } -> (
      match y0 with
      | String_index { expr = b0; index = b1 } ->
          eq_expression a0 b0 && eq_expression a1 b1
      | _ -> false)
  | Array_index { expr = a0; index = a1 } -> (
      match y0 with
      | Array_index { expr = b0; index = b1 } ->
          eq_expression a0 b0 && eq_expression a1 b1
      | _ -> false)
  | Call { expr = a0; args = args00; _ } -> (
      match y0 with
      | Call { expr = b0; args = args10; _ } ->
          eq_expression a0 b0 && eq_expression_list args00 args10
      | _ -> false)
  | Var x -> ( match y0 with Var y -> same_vident x y | _ -> false)
  | Bin { op = op0; expr1 = a0; expr2 = b0 } -> (
      match y0 with
      | Bin { op = op1; expr1 = a1; expr2 = b1 } ->
          op0 = op1 && eq_expression a0 a1 && eq_expression b0 b1
      | _ -> false)
  | Str a0 -> ( match y0 with Str a1 -> a0 = a1 | _ -> false)
  | Unicode s0 -> ( match y0 with Unicode s1 -> s0 = s1 | _ -> false)
  | Module { id = id0; dynamic_import = d0; _ } -> (
      match y0 with
      | Module { id = id1; dynamic_import = d1; _ } ->
          Ident.same id0 id1 && d0 = d1
      | _ -> false)
  | Static_index { expr = e0; field = p0; pos = off0 } -> (
      match y0 with
      | Static_index { expr = e1; field = p1; pos = off1 } ->
          p0 = p1 && eq_expression e0 e1 && off0 = off1 (* could be relaxed *)
      | _ -> false)
  | Seq (a0, b0) -> (
      match y0 with
      | Seq (a1, b1) -> eq_expression a0 a1 && eq_expression b0 b1
      | _ -> false)
  | Bool a0 -> ( match y0 with Bool b0 -> a0 = b0 | _ -> false)
  | Optional_block (a0, b0) -> (
      match y0 with
      | Optional_block (a1, b1) -> b0 = b1 && eq_expression a0 a1
      | _ -> false)
  | Caml_block { fields = ls0; mutable_flag = flag0; tag = tag0; _ } -> (
      match y0 with
      | Caml_block { fields = ls1; mutable_flag = flag1; tag = tag1; _ } ->
          eq_expression_list ls0 ls1 && flag0 = flag1 && eq_expression tag0 tag1
      | _ -> false)
  | Length _ | Char_of_int _ | Char_to_int _ | Is_null_or_undefined _
  | String_append _ | Typeof _ | Js_not _ | Cond _ | FlatCall _ | New _ | Fun _
  | Raw_js_code _ | Array _ | Caml_block_tag _ | Object _
  | Number (Uint _) ->
      false

and eq_expression_list xs ys = List.for_all2_no_exn xs ys ~f:eq_expression

and eq_block (xs : J.block) (ys : J.block) =
  List.for_all2_no_exn xs ys ~f:eq_statement

and eq_statement ({ statement_desc = x0; _ } : J.statement)
    ({ statement_desc = y0; _ } : J.statement) =
  match x0 with
  | Exp a -> ( match y0 with Exp b -> eq_expression a b | _ -> false)
  | Return a -> ( match y0 with Return b -> eq_expression a b | _ -> false)
  | Debugger -> y0 = Debugger
  | Block xs0 -> ( match y0 with Block ys0 -> eq_block xs0 ys0 | _ -> false)
  | Variable _ | If _ | While _ | ForRange _ | Continue | Int_switch _
  | String_switch _ | Throw _ | Try _ ->
      false

let rev_flatten_seq (x : J.expression) =
  let rec aux acc (x : J.expression) : J.block =
    match x.expression_desc with
    | Seq (a, b) -> aux (aux acc a) b
    | _ -> { statement_desc = Exp x; comment = None } :: acc
  in
  aux [] x

(* TODO: optimization,
    counter the number to know if needed do a loop gain instead of doing a diff
*)

let rev_toplevel_flatten block =
  let rec aux acc (xs : J.block) : J.block =
    match xs with
    | [] -> acc
    | {
        statement_desc =
          Variable
            ( { ident_info = { used_stats = Dead_pure }; _ }
            | { ident_info = { used_stats = Dead_non_pure }; value = None; _ }
              );
        _;
      }
      :: xs ->
        aux acc xs
    | { statement_desc = Block b; _ } :: xs -> aux (aux acc b) xs
    | x :: xs -> aux (x :: acc) xs
  in
  aux [] block

(* let rec is_constant (x : J.expression)  =
   match x.expression_desc with
   | Array_index (a,b) -> is_constant a && is_constant b
   | Str (b,_) -> b
   | Number _ -> true (* Can be refined later *)
   | Array (xs,_mutable_flag)  -> Ext_list.for_all xs  is_constant
   | Caml_block(xs, Immutable, tag, _)
     -> Ext_list.for_all xs is_constant && is_constant tag
   | Bin (_op, a, b) ->
     is_constant a && is_constant b
   | _ -> false *)

let rec is_okay_to_duplicate (e : J.expression) =
  match e.expression_desc with
  | Var _ | Bool _ | Str _ | Unicode _ | Number _ -> true
  | Static_index { expr = e; _ } -> is_okay_to_duplicate e
  | _ -> false
