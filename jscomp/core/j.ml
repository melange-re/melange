(* Copyright (C) 2015- Hongbo Zhang, Authors of ReScript
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

(* Javascript IR

    It's a subset of Javascript AST specialized for OCaml lambda backend

    Note it's not exactly the same as Javascript, the AST itself follows lexical
    convention and [Block] is just a sequence of statements, which means it does
    not introduce new scope
*)

type mutable_flag = Js_op.mutable_flag
type binop = Js_op.binop
type int_op = Js_op.int_op
type kind = Js_op.kind
type property = Js_op.property
type number = Js_op.number
type ident_info = Js_op.ident_info
type exports = Js_op.exports
type tag_info = Js_op.tag_info
type property_name = string

[@@@ocaml.warning "-duplicate-definitions"]

type ident = Ident.t
(* we override `method ident` *)

(** object literal, if key is ident, in this case, it might be renamed by
    Google Closure  optimizer,
    currently we always use quote
 *)

and module_id = { id : ident; kind : Js_op.kind; dynamic_import : bool }

and vident = Id of ident | Qualified of module_id * string option
(* Since camldot is only available for toplevel module accessors,
   we don't need print  `A.length$2`
   just print `A.length` - it's guarateed to be unique

   when the third one is None, it means the whole module

   TODO:
   invariant, when [kind] is [Runtime], then we can ignore [ident],
   since all [runtime] functions are unique, when do the
   pattern match we can ignore the first one for simplicity
   for example
   {[
     Qualified (_, Runtime, Some "caml_int_compare")
   ]}
*)

and exception_ident = ident
and for_ident = ident
and for_direction = Js_op.direction_flag
and property_map = (property_name * expression) list
and length_object = Js_op.length_object

and expression_desc =
  | Length of { expr : expression; length_object : length_object }
  | Char_of_int of expression
  | Char_to_int of expression
  | Is_null_or_undefined of expression  (** where we use a trick [== null ] *)
  | String_append of { prefix : expression; suffix : expression }
  | Bool of bool (* js true/false*)
  (* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Operator_Precedence
     [typeof] is an operator
  *)
  | Typeof of expression
  | Js_not of expression (* !v *)
  (* TODO: Add some primitives so that [js inliner] can do a better job *)
  | Seq of expression * expression
  | Cond of { pred : expression; then_ : expression; else_ : expression }
  | Bin of { op : binop; expr1 : expression; expr2 : expression }
  (* [int_op] will guarantee return [int32] bits
     https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/Bitwise_Operators *)
  (* | Int32_bin of int_op * expression * expression *)
  | FlatCall of { expr : expression; args : expression }
  (* f.apply(null,args) -- Fully applied guaranteed
     TODO: once we know args's shape --
     if it's know at compile time, we can turn it into
     f(args[0], args[1], ... )
  *)
  | Call of { expr : expression; args : expression list; info : Js_call_info.t }
  (* Analysze over J expression is hard since,
      some primitive  call is translated
      into a plain call, it's better to keep them
  *)
  | String_index of { expr : expression; index : expression }
  (* str.[i])*)
  | Array_index of { expr : expression; index : expression }
  (* arr.(i)
     Invariant:
     The second argument has to be type of [int],
     This can be constructed either in a static way [E.array_index_by_int] or a dynamic way
     [E.array_index]
  *)
  | Static_index of { expr : expression; field : string; pos : int32 option }
  (* The third argument bool indicates whether we should
     print it as
     a["idd"] -- false
     or
     a.idd  -- true
     There are several kinds of properties
     1. OCaml module dot (need to be escaped or not)
        All exported declarations have to be OCaml identifiers
     2. Javascript dot (need to be preserved/or using quote)
  *)
  | New of { expr : expression; args : expression list }
  | Var of vident
  | Fun of {
      method_ : bool;
      params : ident list;
      body : block;
      env : Js_fun_env.t;
      return_unit : bool;
    }
  (* The first parameter by default is false,
     it will be true when it's a method
     Last param represents whether the function returns unit.
  *)
  | Str of string
  (* A string is UTF-8 encoded, the string may contain
     escape sequences.
     The first argument is used to mark it is non-pure, please
     don't optimize it, since it does have side effects,
     examples like "use asm;" and our compiler may generate "error;..."
     which is better to leave it alone
     The last argument is passed from as `j` from `{j||j}`
  *)
  | Unicode of string
  (* It is escaped string, print delimited by '"'*)
  | Raw_js_code of Melange_ffi.Js_raw_info.t
  (* literally raw JS code
  *)
  | Array of { items : expression list; mutable_flag : mutable_flag }
  | Optional_block of expression * bool
  (* [true] means [identity] *)
  | Caml_block of {
      fields : expression list;
      mutable_flag : mutable_flag;
      tag : expression;
      tag_info : tag_info;
    }
  (* The third argument is [tag] , forth is [tag_info] *)
  (* | Caml_uninitialized_obj of expression * expression *)
  (* [tag] and [size] tailed  for [Obj.new_block] *)

  (* For setter, it still return the value of expression,
     we can not use
     {[
       type 'a access = Get | Set of 'a
     ]}
     in another module, since it will break our code generator
     [Caml_block_tag] can return [undefined],
     you have to use [E.tag] in a safe way
  *)
  | Caml_block_tag of { expr : expression; name : string }
  (* | Caml_block_set_tag of expression * expression *)
  (* | Caml_block_set_length of expression * expression *)
  (* It will just fetch tag, to make it safe, when creating it,
     we need apply "|0", we don't do it in the
     last step since "|0" can potentially be optimized
  *)
  | Number of number
  | Object of property_map
  | Undefined
  | Null
  | Module of module_id

and for_ident_expression = expression
(* pure*)

and finish_ident_expression = expression

(* pure *)
(* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/block
   block can be nested, specified in ES3
*)

(* Delay some units like [primitive] into JS layer ,
   benefit: better cross module inlining, and smaller IR size?
*)

(*
  [closure] captured loop mutable values in the outer loop

  check if it contains loop mutable values, happens in nested loop
  when closured, it's no longer loop mutable value.
  which means the outer loop mutable value can not peek into the inner loop
  {[
  var i = f ();
  for(var finish = 32; i < finish; ++i){
  }
  ]}
  when [for_ident_expression] is [None], [var i] has to
  be initialized outside, so

  {[
  var i = f ()
  (function (xxx){
  for(var finish = 32; i < finish; ++i)
  }(..i))
  ]}
  This happens rare it's okay

  this is because [i] has to be initialized outside, if [j]
  contains a block side effect
  TODO: create such example
*)

(* Since in OCaml,

   [for i = 0 to k end do done ]
   k is only evaluated once , to encode this invariant in JS IR,
   make sure [ident] is defined in the first b

   TODO: currently we guarantee that [bound] was only
   excecuted once, should encode this in AST level
*)

(* Can be simplified to keep the semantics of OCaml
   For (var i, e, ...){
     let  j = ...
   }

   if [i] or [j] is captured inside closure

   for (var i , e, ...){
     (function (){
     })(i)
   }
*)

(* Single return is good for ininling..
   However, when you do tail-call optmization
   you loose the expression oriented semantics
   Block is useful for implementing goto
   {[
   xx:{
   break xx;
   }
   ]}
*)
and case_clause = {
  switch_body : block;
  should_break : bool; (* true means break *)
  comment : string option;
}

and string_clause = Lambda.as_modifier * case_clause
and int_clause = int * case_clause

and statement_desc =
  | Block of block
  | Variable of variable_declaration
  (* Function declaration and Variable declaration  *)
  | Exp of expression
  | If of { pred : expression; then_ : block; else_ : block }
  | While of { cond : expression; body : block }
    (* check if it contains loop mutable values, happens in nested loop *)
  | ForRange of {
      for_ident_expr : for_ident_expression option;
      finish_expr : finish_ident_expression;
      for_ident : for_ident;
      direction : for_direction;
      body : block;
    }
  | Continue
  | Return of expression
  (* Here we need track back a bit ?, move Return to Function ...
     Then we can only have one Return, which is not good *)
  (* since in ocaml, it's expression oriented langauge, [return] in
     general has no jumps, it only happens when we do
     tailcall conversion, in that case there is a jump.
     However, currently  a single [break] is good to cover
     our compilation strategy
     Attention: we should not insert [break] arbitrarily, otherwise
     it would break the semantics
     A more robust signature would be
     {[ goto : label option ; ]}
  *)
  | Int_switch of {
      expr : expression;
      clauses : int_clause list;
      default : block option;
    }
  | String_switch of {
      expr : expression;
      clauses : string_clause list;
      default : block option;
    }
  | Throw of expression
  | Try of {
      body : block;
      catch : (exception_ident * block) option;
      finally : block option;
    }
  | Debugger

and expression = {
  expression_desc : expression_desc;
  comment : string option;
  loc : Location.t option;
}

and statement = { statement_desc : statement_desc; comment : string option }

and variable_declaration = {
  ident : ident;
  value : expression option;
  property : property;
  ident_info : ident_info;
}

(* TODO: For efficency: block should not be a list, it should be able to
   be concatenated in both ways
*)
and block = statement list
and program = { block : block; exports : exports; export_set : Ident.Set.t }

and deps_program = {
  program : program;
  modules : module_id list;
  side_effect : string option; (* None: no, Some reason  *)
  preamble : string option;
}
[@@deriving
  {
    excludes =
      [|
        deps_program;
        int_clause;
        string_clause;
        (* exception_ident; *)
        for_direction;
        expression_desc;
        statement_desc;
        for_ident_expression;
        finish_ident_expression;
        property_map;
        length_object;
        (* for_ident; *)
        case_clause;
      |];
  }]

(*
FIXME: customize for each code generator
for each code generator, we can provide a white-list
so that we can achieve the optimal
*)
