(* ReScript compiler
 * Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * http://www.ocsigen.org/js_of_ocaml/
 * Copyright (C) 2010 Jérôme Vouillon
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)
(* Authors: Jérôme Vouillon, Hongbo Zhang  *)

open Import

(*
  http://stackoverflow.com/questions/2846283/what-are-the-rules-for-javascripts-automatic-semicolon-insertion-asi
  ASI catch up
   {[
     a=b
       ++c
       ---
       a=b ++c
     ====================
     a ++
     ---
     a
     ++
     ====================
     a --
     ---
     a
     --
     ====================
     (continue/break/return/throw) a
     ---
     (continue/break/return/throw)
       a
     ====================
   ]}

*)

let name_symbol = Js_op.Symbol_name

module E = Js_exp_make
module S = Js_stmt_make
module L = Js_dump_lit

(* There modules are dynamically inserted in the last stage
   {Caml_curry}
   {Caml_option}

   They can appear anywhere so even if you have a module
   {
     let module Caml_block = ...

     (* Later would insert the use of Caml_block here which should
       point tto the runtime module
     *)
   }
   There are no sane way to easy detect it ahead of time, we should be
   conservative here.
   (our call Js_fun_env.get_unbounded env) is not precise
*)

type cxt = {
  scope : Js_pp.Scope.t;
  pp : Js_pp.t;
  output_dir : string;
  package_info : Js_packages_info.t;
  output_info : Js_packages_info.output_info;
}

let from_pp ~output_dir ~package_info ~output_info pp =
  { scope = Js_pp.Scope.empty; pp; output_dir; package_info; output_info }

let from_buffer ~output_dir ~package_info ~output_info buf =
  from_pp ~output_dir ~package_info ~output_info (Js_pp.from_buffer buf)

let update_scope cxt scope = { cxt with scope }
let ident cxt id = update_scope cxt (Js_pp.Scope.ident cxt.scope cxt.pp id)
let string cxt s = Js_pp.string cxt.pp s
let group cxt = Js_pp.group cxt.pp
let newline cxt = Js_pp.newline cxt.pp
let paren_group cxt = Js_pp.paren_group cxt.pp
let paren_vgroup cxt = Js_pp.paren_vgroup cxt.pp
let vgroup cxt = Js_pp.vgroup cxt.pp
let space cxt = Js_pp.space cxt.pp
let cond_paren_group cxt = Js_pp.cond_paren_group cxt.pp
let paren cxt = Js_pp.paren cxt.pp
let brace_vgroup cxt = Js_pp.brace_vgroup cxt.pp
let bracket_group cxt = Js_pp.bracket_group cxt.pp
let bracket_vgroup cxt = Js_pp.bracket_vgroup cxt.pp

let merge_scope cxt l =
  let scope = Js_pp.Scope.merge cxt.scope l in
  { cxt with scope }

let sub_scope cxt l = update_scope cxt (Js_pp.Scope.sub_scope cxt.scope l)

let str_of_ident cxt id =
  let str, scope = Js_pp.Scope.str_of_ident cxt.scope id in
  (str, update_scope cxt scope)

let at_least_two_lines cxt = Js_pp.at_least_two_lines cxt.pp
let flush cxt () = Js_pp.flush cxt.pp ()

module Curry_gen = struct
  let pp_curry_dot cxt =
    string cxt Js_runtime_modules.curry;
    string cxt L.dot

  let pp_optimize_curry cxt (len : int) =
    pp_curry_dot cxt;
    string cxt "__";
    string cxt (Printf.sprintf "%d" len)

  let pp_app_any cxt =
    pp_curry_dot cxt;
    string cxt "app"

  let pp_app cxt (len : int) =
    pp_curry_dot cxt;
    string cxt "_";
    string cxt (Printf.sprintf "%d" len)
end

let return_indent = String.length L.return / Js_pp.indent_length
let throw_indent = String.length L.throw / Js_pp.indent_length
let semi cxt = string cxt L.semi
let comma cxt = string cxt L.comma

let new_error name cause =
  E.new_
    (E.runtime_var_dot Js_runtime_modules.caml_js_exceptions
       Js_dump_lit.melange_error)
    [ name; cause ]

let exn_block_as_obj ~(stack : bool) (el : J.expression list) (ext : J.tag_info)
    : J.expression =
  let field_name =
    match ext with
    | Blk_extension -> (
        fun i -> match i with 0 -> L.exception_id | i -> "_" ^ string_of_int i)
    | Blk_record_ext ss -> (
        fun i -> match i with 0 -> L.exception_id | i -> ss.(i - 1))
    | _ -> assert false
  in
  let cause =
    {
      J.expression_desc =
        Object (List.mapi ~f:(fun i e -> (Js_op.Lit (field_name i), e)) el);
      comment = None;
      loc = None;
    }
  in
  if stack then new_error (List.hd el) cause else cause

let exn_ref_as_obj cause : J.expression =
  new_error (E.record_access cause Js_dump_lit.exception_id 0l) cause

let rec iter_lst cxt ls element inter =
  match ls with
  | [] -> cxt
  | [ e ] -> element cxt e
  | e :: r ->
      let acxt = element cxt e in
      inter cxt;
      iter_lst acxt r element inter

let raw_snippet_exp_simple_enough (s : string) =
  String.for_all
    ~f:(function 'a' .. 'z' | 'A' .. 'Z' | '_' | '.' -> true | _ -> false)
    s
(* Parentheses are required when the expression
   starts syntactically with "{" or "function"
   TODO:  be more conservative, since Google Closure will handle
   the precedence correctly, we also need people read the code..
   Here we force parens for some alien operators

   If we move assign into a statement, will be less?
   TODO: construct a test case that do need parenthesisze for expression
   IIE does not apply (will be inlined?)
*)

(* e = function(x){...}(x);  is good
*)
let exp_need_paren (e : J.expression) =
  match e.expression_desc with
  (* | Caml_uninitialized_obj _  *)
  | Call { expr = { expression_desc = Fun _ | Raw_js_code _; _ }; _ } -> true
  | Raw_js_code { code_info = Exp _; _ }
  | Fun _
  | Caml_block
      {
        tag_info =
          ( Blk_record _ | Blk_module _ | Blk_poly_var | Blk_extension
          | Blk_record_ext _ | Blk_record_inlined _ | Blk_constructor _ );
        _;
      }
  | Object _ ->
      true
  | Raw_js_code { code_info = Stmt _; _ }
  | Length _ | Call _ | Caml_block_tag _ | Seq _ | Static_index _ | Cond _
  | Bin _ | Is_null_or_undefined _ | String_index _ | Array_index _
  | String_append _ | Char_of_int _ | Char_to_int _ | Var _ | Undefined | Null
  | Str _ | Unicode _ | Module _ | Array _ | Optional_block _ | Caml_block _
  | FlatCall _ | Typeof _ | Number _ | Js_not _ | Bool _ | New _ ->
      false

(* Print as underscore for unused vars, may not be
    needed in the future *)
(* let ipp_ident cxt id (un_used : bool) =
   Js_pp.Scope.ident cxt (
     if un_used then
       Ident.make_unused ()
     else
       id) *)

let pp_var_assign cxt id =
  string cxt L.let_;
  space cxt;
  let acxt = ident cxt id in
  space cxt;
  string cxt L.eq;
  space cxt;
  acxt

let pp_const_assign cxt id =
  string cxt L.const;
  space cxt;
  let acxt = ident cxt id in
  space cxt;
  string cxt L.eq;
  space cxt;
  acxt

let pp_var_assign_this cxt id =
  let cxt = pp_var_assign cxt id in
  string cxt L.this;
  semi cxt;
  newline cxt;
  cxt

let pp_var_declare cxt id =
  string cxt L.let_;
  space cxt;
  let acxt = ident cxt id in
  semi cxt;
  acxt

let pp_direction cxt (direction : J.for_direction) =
  match direction with
  | Up | Upto -> string cxt L.plus_plus
  | Downto -> string cxt L.minus_minus

let return_sp cxt =
  string cxt L.return;
  space cxt

let bool cxt b = string cxt (if b then L.true_ else L.false_)

let comma_sp cxt =
  comma cxt;
  space cxt

let comma_nl cxt =
  comma cxt;
  newline cxt

(* let drop_comment (x : J.expression) =
   if x.comment = None then x
   else {x with comment = None} *)

let debugger_nl cxt =
  newline cxt;
  string cxt L.debugger;
  semi cxt;
  newline cxt

let break_nl cxt =
  string cxt L.break;
  space cxt;
  semi cxt;
  newline cxt

let continue cxt s =
  string cxt L.continue;
  space cxt;
  string cxt s;
  semi cxt

let formal_parameter_list cxt l = iter_lst cxt l ident comma_sp
(* IdentMap *)
(*
f/122 -->
  f/122 is in the map
  if in, use the old mapping
  else
    check  f,
     if in last bumped id
     else
        use "f", register it

  check "f"
         if not , use "f", register stamp -> 0
         else
           check stamp
             if in  use it
             else check last bumped id, increase it and register
*)

(*
   Turn [function f (x,y) { return a (x,y)} ] into [Curry.__2(a)],
   The idea is that [Curry.__2] will guess the arity of [a], if it does
   hit, then there is no cost when passed
*)

let is_var (b : J.expression) a =
  match b.expression_desc with Var (Id i) -> Ident.same i a | _ -> false

type fn_exp_state =
  | Is_return (* for sure no name *)
  | Name_top of Ident.t
  | Name_non_top of Ident.t
  | No_name of { single_arg : bool }
(* true means for sure, false -- not sure *)

let default_fn_exp_state = No_name { single_arg = false }

let block_has_all_int_fields =
  let exception Local of bool in
  fun fields ->
    let len = Array.length fields in
    let r = ref true in
    try
      for i = 0 to len - 1 do
        let k_eq_v = string_of_int i = Array.unsafe_get fields i in
        r := !r && k_eq_v;
        if not !r then raise (Local false)
      done;
      !r
    with Local r -> r

let pp_assign ~(property : Lam_group.let_kind) cxt name =
  match property with
  | Variable -> pp_var_assign cxt name
  | Strict | Alias | StrictOpt -> pp_const_assign cxt name

(* TODO: refactoring
   Note that {!pp_function} could print both statement and expression when [No_name] is given
*)
let rec try_optimize_curry cxt len function_id =
  Curry_gen.pp_optimize_curry cxt len;
  paren_group cxt 1 (fun _ -> expression ~level:1 cxt function_id)

and pp_function ~return_unit ~is_method cxt ~fn_state (l : Ident.t list)
    (b : J.block) (env : Js_fun_env.t) : cxt =
  match b with
  | [
   {
     statement_desc =
       Return
         {
           expression_desc =
             Call
               {
                 expr = { expression_desc = Var v; _ } as function_id;
                 args = ls;
                 info =
                   {
                     arity = (Full | NA) as arity (* see #234*);
                     (* TODO: need a case to justify it*)
                     call_info = Call_builtin_runtime | Call_ml;
                   };
               };
           _;
         };
     _;
   };
  ]
    when (* match such case:
            {[ function(x,y){ return u(x,y) } ]}
            it can be optimized in to either [u] or [Curry.__n(u)]
         *)
         (not is_method)
         && List.for_all2_no_exn ls l is_var
         &&
         match v with
         (* This check is needed to avoid some edge cases
            {[function(x){return x(x)}]}
            here the function is also called `x`
         *)
         | Id id -> not (List.exists ~f:(fun x -> Ident.same x id) l)
         | Qualified _ -> true -> (
      let optimize len ~p cxt v =
        if p then try_optimize_curry cxt len function_id else vident cxt v
      in
      let len = List.length l in
      (* length *)
      match fn_state with
      | Name_top i | Name_non_top i ->
          let cxt = pp_const_assign cxt i in
          let cxt = optimize len ~p:(arity = NA && len <= 8) cxt v in
          semi cxt;
          cxt
      | Is_return | No_name _ ->
          if fn_state = Is_return then return_sp cxt;
          optimize len ~p:(arity = NA && len <= 8) cxt v)
  | _ ->
      let set_env =
        (* identifiers will be printed following*)
        match fn_state with
        | Is_return | No_name _ -> Js_fun_env.get_unbounded env
        | Name_top id | Name_non_top id ->
            Ident.Set.add (Js_fun_env.get_unbounded env) id
      in
      (* the context will be continued after this function *)
      let outer_cxt = merge_scope cxt set_env in

      (* the context used to be printed inside this function

         when printing a function,
         only the enclosed variables and function name matters,
         if the function does not capture any variable, then the context is empty
      *)
      let inner_cxt = sub_scope outer_cxt set_env in
      let param_body () : unit =
        if is_method then (
          match l with
          | [] -> assert false
          | this :: arguments ->
              let cxt =
                paren_group cxt 1 (fun _ ->
                    formal_parameter_list inner_cxt arguments)
              in
              space cxt;
              brace_vgroup cxt 1 (fun () ->
                  let cxt =
                    if Js_fun_env.get_unused env 0 then cxt
                    else pp_var_assign_this cxt this
                  in
                  function_body ~return_unit cxt b))
        else
          let cxt =
            paren_group cxt 1 (fun _ -> formal_parameter_list inner_cxt l)
          in
          space cxt;
          brace_vgroup cxt 1 (fun _ -> function_body ~return_unit cxt b)
      in
      (match fn_state with
      | Is_return ->
          return_sp cxt;
          string cxt L.function_;
          space cxt;
          param_body ()
      | No_name { single_arg } ->
          (* see # 1692, add a paren for annoymous function for safety  *)
          cond_paren_group cxt (not single_arg) 1 (fun _ ->
              string cxt L.function_;
              space cxt;
              param_body ())
      | Name_non_top x ->
          ignore (pp_const_assign inner_cxt x : cxt);
          string cxt L.function_;
          space cxt;
          param_body ();
          semi cxt
      | Name_top x ->
          string cxt L.function_;
          space cxt;
          ignore (ident inner_cxt x : cxt);
          param_body ());
      outer_cxt

(* Assume the cond would not change the context,
    since it can be either [int] or [string]
*)
and pp_one_case_clause : 'a. _ -> (_ -> 'a -> unit) -> 'a * J.case_clause -> _ =
 fun cxt pp_cond
     (switch_case, ({ switch_body; should_break; comment } : J.case_clause)) ->
  let cxt =
    group cxt 1 (fun _ ->
        group cxt 1 (fun _ ->
            string cxt L.case;
            space cxt;
            pp_comment_option cxt comment;
            pp_cond cxt switch_case;
            (* could be integer or string *)
            space cxt;
            string cxt L.colon);
        group cxt 1 (fun _ ->
            let cxt =
              match switch_body with
              | [] -> cxt
              | _ ->
                  newline cxt;
                  statements ~top:false cxt switch_body
            in
            if should_break then (
              newline cxt;
              string cxt L.break;
              semi cxt);
            cxt))
  in
  newline cxt;
  cxt

and loop_case_clauses : 'a. _ -> (_ -> 'a -> unit) -> ('a * _) list -> _ =
 fun cxt pp_cond cases ->
  List.fold_left
    ~f:(fun acc x -> pp_one_case_clause acc pp_cond x)
    ~init:cxt cases

and vident cxt (v : J.vident) =
  match v with
  | Id v
  | Qualified ({ id = v; _ }, None)
  | Qualified ({ id = v; kind = External { default = true; _ }; _ }, _) ->
      ident cxt v
  | Qualified ({ id; kind = Ml | Runtime; _ }, Some name) ->
      let cxt = ident cxt id in
      string cxt L.dot;
      string cxt
        (if name = Js_dump_import_export.default_export then name
         else Ident.convert name);
      cxt
  | Qualified ({ id; kind = External _; _ }, Some name) ->
      let cxt = ident cxt id in
      Js_dump_property.property_access cxt.pp name;
      cxt

(* The higher the level, the more likely that inner has to add parens *)
and expression ~level:l cxt (exp : J.expression) : cxt =
  pp_comment_option cxt exp.comment;
  expression_desc cxt ~level:l exp.expression_desc

and expression_desc cxt ~(level : int) x : cxt =
  match x with
  | Null ->
      string cxt L.null;
      cxt
  | Undefined ->
      string cxt L.undefined;
      cxt
  | Var v -> vident cxt v
  | Bool b ->
      bool cxt b;
      cxt
  | Seq (e1, e2) ->
      cond_paren_group cxt (level > 0) 1 (fun () ->
          let cxt = expression ~level:0 cxt e1 in
          comma_sp cxt;
          expression ~level:0 cxt e2)
  | Fun { method_ = is_method; params = l; body = b; env; return_unit } ->
      (* TODO: dump for comments *)
      pp_function ~return_unit ~is_method cxt ~fn_state:default_fn_exp_state l b
        env
      (* TODO:
         when [e] is [Js_raw_code] with arity
         print it in a more precise way
         It seems the optimizer already did work to make sure
         {[
           Call (Raw_js_code (s, Exp i), el, {Full})
           when List.length_equal el i
         ]}
      *)
  | Call { expr = e; args = el; info } ->
      cond_paren_group cxt (level > 15) 1 (fun _ ->
          group cxt 1 (fun _ ->
              match (info, el) with
              | { arity = Full; _ }, _ | _, [] ->
                  let cxt = expression ~level:15 cxt e in
                  paren_group cxt 1 (fun _ ->
                      match el with
                      | [
                       {
                         expression_desc =
                           Fun
                             {
                               method_ = is_method;
                               params = l;
                               body = b;
                               env;
                               return_unit;
                             };
                         _;
                       };
                      ] ->
                          pp_function ~return_unit ~is_method cxt
                            ~fn_state:(No_name { single_arg = true })
                            l b env
                      | _ -> arguments cxt el)
              | _, _ ->
                  let len = List.length el in
                  if 1 <= len && len <= 8 then (
                    Curry_gen.pp_app cxt len;
                    paren_group cxt 1 (fun _ -> arguments cxt (e :: el)))
                  else (
                    Curry_gen.pp_app_any cxt;
                    paren_group cxt 1 (fun _ ->
                        arguments cxt [ e; E.array Mutable el ]))))
  | FlatCall { expr = e; args = el } ->
      group cxt 1 (fun _ ->
          let cxt = expression ~level:15 cxt e in
          string cxt L.dot;
          string cxt L.apply;
          paren_group cxt 1 (fun _ ->
              string cxt L.null;
              comma_sp cxt;
              expression ~level:1 cxt el))
  | Char_to_int e -> (
      match e.expression_desc with
      | String_index { expr = a; index = b } ->
          group cxt 1 (fun _ ->
              let cxt = expression ~level:15 cxt a in
              string cxt L.dot;
              string cxt L.char_code_at;
              paren_group cxt 1 (fun _ -> expression ~level:0 cxt b))
      | _ ->
          group cxt 1 (fun _ ->
              let cxt = expression ~level:15 cxt e in
              string cxt L.dot;
              string cxt L.char_code_at;
              string cxt "(0)";
              cxt))
  | Char_of_int e ->
      group cxt 1 (fun _ ->
          string cxt L.string_cap;
          string cxt L.dot;
          string cxt L.fromCharcode;
          paren_group cxt 1 (fun _ -> arguments cxt [ e ]))
  | Unicode s ->
      string cxt "\"";
      string cxt s;
      string cxt "\"";
      cxt
  | Str s ->
      (*TODO --
         when utf8-> it will not escape '\\' which is definitely not we want
      *)
      Js_dump_string.pp_string cxt.pp s;
      cxt
  | Module module_id ->
      let path =
        Js_name_of_module_id.string_of_module_id ~package_info:cxt.package_info
          ~output_info:cxt.output_info ~output_dir:cxt.output_dir module_id
      in
      Js_dump_string.pp_string cxt.pp path;
      cxt
  | Raw_js_code { code = s; code_info = info } -> (
      match info with
      | Exp exp_info ->
          let raw_paren =
            match exp_info with
            | Js_literal _ -> false
            | Js_function _ | Js_exp_unknown ->
                not (raw_snippet_exp_simple_enough s)
          in
          if raw_paren then string cxt L.lparen;
          string cxt s;
          if raw_paren then (
            newline cxt;
            string cxt L.rparen);
          cxt
      | Stmt stmt_info ->
          if stmt_info = Js_stmt_comment then string cxt s
          else (
            newline cxt;
            string cxt s;
            newline cxt);
          cxt)
  | Number v ->
      let s =
        match v with
        | Float { f } -> Js_number.caml_float_literal_to_js_string f
        (* attach string here for float constant folding?*)
        | Int { i; c = Some c } -> Format.asprintf "/* %C */%ld" c i
        | Int { i; c = None } ->
            Int32.to_string
              i (* check , js convention with ocaml lexical convention *)
        | Uint i -> Format.asprintf "%lu" i
      in
      let need_paren =
        if s.[0] = '-' then
          level > 13 (* Negative numbers may need to be parenthesized. *)
        else
          level = 15 (* Parenthesize as well when followed by a dot. *)
          && s.[0] <> 'I' (* Infinity *)
          && s.[0] <> 'N' (* NaN *)
      in
      let action _ = string cxt s in
      if need_paren then paren cxt action else action ();
      cxt
  | Is_null_or_undefined e ->
      cond_paren_group cxt (level > 0) 1 (fun _ ->
          let cxt = expression ~level:1 cxt e in
          space cxt;
          string cxt "==";
          space cxt;
          string cxt L.null;
          cxt)
  | Js_not e ->
      cond_paren_group cxt (level > 13) 1 (fun _ ->
          string cxt "!";
          expression ~level:13 cxt e)
  | Typeof e ->
      string cxt "typeof";
      space cxt;
      expression ~level:13 cxt e
  | Bin
      {
        op = Minus;
        expr1 =
          {
            expression_desc =
              Number ((Int { i = 0l; _ } | Float { f = "0." }) as desc);
            _;
          };
        expr2 = e;
      }
  (* TODO:
     Handle multiple cases like
     {[ 0. - x ]}
     {[ 0.00 - x ]}
     {[ 0.000 - x ]}
  *) ->
      cond_paren_group cxt (level > 13) 1 (fun _ ->
          string cxt (match desc with Float _ -> "- " | _ -> "-");
          expression ~level:13 cxt e)
  | Bin { op; expr1 = e1; expr2 = e2 } ->
      let out, lft, rght = Js_op_util.op_prec op in
      let need_paren =
        level > out || match op with Lsl | Lsr | Asr -> true | _ -> false
      in
      (* We are more conservative here, to make the generated code more readable
            to the user *)
      cond_paren_group cxt need_paren 1 (fun _ ->
          let cxt = expression ~level:lft cxt e1 in
          space cxt;
          string cxt (Js_op_util.op_str op);
          space cxt;
          expression ~level:rght cxt e2)
  | String_append { prefix = e1; suffix = e2 } ->
      let op : Js_op.binop = Plus in
      let out, lft, rght = Js_op_util.op_prec op in
      let need_paren =
        level > out || match op with Lsl | Lsr | Asr -> true | _ -> false
      in
      cond_paren_group cxt need_paren 1 (fun _ ->
          let cxt = expression ~level:lft cxt e1 in
          space cxt;
          string cxt "+";
          space cxt;
          expression ~level:rght cxt e2)
  | Array { items = el; _ } -> (
      (* TODO: simplify for singleton list *)
      match el with
      | [] | [ _ ] -> bracket_group cxt 1 (fun _ -> array_element_list cxt el)
      | _ -> bracket_vgroup cxt 1 (fun _ -> array_element_list cxt el))
  | Optional_block (e, identity) ->
      expression ~level cxt
        (if identity then e
         else
           E.runtime_call ~module_name:Js_runtime_modules.option ~fn_name:"some"
             [ e ])
  | Caml_block { fields = el; tag_info = Blk_module fields; _ } ->
      expression_desc cxt ~level
        (Object
           (List.map_combine fields el (fun x -> Js_op.Lit (Ident.convert x))))
  (*name convention of Record is slight different from modules*)
  | Caml_block { fields = el; mutable_flag; tag_info = Blk_record fields; _ } ->
      if block_has_all_int_fields fields then
        expression_desc cxt ~level (Array { items = el; mutable_flag })
      else
        expression_desc cxt ~level
          (Object (List.map_combine_array fields el (fun i -> Js_op.Lit i)))
  | Caml_block { fields = el; tag_info = Blk_poly_var; _ } -> (
      match el with
      | [ { expression_desc = Str name; _ }; value ] ->
          expression_desc cxt ~level
            (Object
               [
                 (Js_op.Lit L.polyvar_hash, E.str name);
                 (Lit L.polyvar_value, value);
               ])
      | _ -> assert false)
  | Caml_block
      { fields = el; tag_info = (Blk_extension | Blk_record_ext _) as ext; _ }
    ->
      expression cxt ~level (exn_block_as_obj ~stack:false el ext)
  | Caml_block { fields = el; tag; tag_info = Blk_record_inlined p; _ } ->
      let objs =
        let tails =
          List.map_combine_array_append p.fields el
            (if !Js_config.debug then [ (name_symbol, E.str p.name) ] else [])
            (fun i -> Js_op.Lit i)
        in
        let as_value =
          Lam_constant_convert.modifier ~name:p.name p.attributes
        in
        ( Js_op.Lit L.tag,
          {
            (match as_value.as_modifier with
            | Some modifier -> E.as_value modifier
            | None -> tag)
            with
            comment = Some as_value.name;
          } )
        :: tails
      in
      expression_desc cxt ~level (Object objs)
  | Caml_block { fields = el; tag; tag_info = Blk_constructor p; _ } ->
      let is_cons = Js_op_util.is_cons p.name in
      let objs =
        let tails =
          List.mapi
            ~f:(fun i e ->
              (Js_op.Lit (E.variant_pos ~constr:p.name (Int32.of_int i)), e))
            el
          @
          if !Js_config.debug && not is_cons then
            [ (name_symbol, E.str p.name) ]
          else []
        in
        if is_cons && p.num_nonconst = 1 then tails
        else
          let as_value =
            Lam_constant_convert.modifier ~name:p.name p.attributes
          in
          ( Js_op.Lit L.tag,
            {
              (match as_value.as_modifier with
              | Some modifier -> E.as_value modifier
              | None -> tag)
              with
              comment = Some as_value.name;
            } )
          :: tails
      in
      expression_desc cxt ~level (Object objs)
  | Caml_block { tag_info = Blk_module_export | Blk_na _; _ } -> assert false
  | Caml_block
      {
        fields = el;
        mutable_flag;
        tag_info = Blk_tuple | Blk_class | Blk_array;
        _;
      } ->
      expression_desc cxt ~level (Array { items = el; mutable_flag })
  | Caml_block_tag e ->
      group cxt 1 (fun _ ->
          let cxt = expression ~level:15 cxt e in
          string cxt L.dot;
          string cxt L.tag;
          cxt)
  | Array_index { expr = e; index = p } | String_index { expr = e; index = p }
    ->
      cond_paren_group cxt (level > 15) 1 (fun _ ->
          group cxt 1 (fun _ ->
              let cxt = expression ~level:15 cxt e in
              bracket_group cxt 1 (fun _ -> expression ~level:0 cxt p)))
  | Static_index { expr = e; field = s; _ } ->
      cond_paren_group cxt (level > 15) 1 (fun _ ->
          let cxt = expression ~level:15 cxt e in
          Js_dump_property.property_access cxt.pp s;
          (* See [ .obj_of_exports]
             maybe in the ast level we should have
             refer and export
          *)
          cxt)
  | Length { expr = e; _ } ->
      (* Todo: check parens *)
      cond_paren_group cxt (level > 15) 1 (fun _ ->
          let cxt = expression ~level:15 cxt e in
          string cxt L.dot;
          string cxt L.length;
          cxt)
  | New { expr = e; args = el } ->
      cond_paren_group cxt (level > 15) 1 (fun _ ->
          group cxt 1 (fun _ ->
              string cxt L.new_;
              space cxt;
              let cxt = expression ~level:16 cxt e in
              paren_group cxt 1 (fun _ ->
                  match el with Some el -> arguments cxt el | None -> cxt)))
  | Cond { pred = e; then_ = e1; else_ = e2 } ->
      let action () =
        let cxt = expression ~level:3 cxt e in
        space cxt;
        string cxt L.question;
        space cxt;
        (*
            [level 1] is correct, however
            to make nice indentation , force nested conditional to be parenthesized
          *)
        let cxt = group cxt 1 (fun _ -> expression ~level:3 cxt e1) in

        space cxt;
        string cxt L.colon_space;
        (* idem *)
        group cxt 1 (fun _ -> expression ~level:3 cxt e2)
      in
      if level > 2 then paren_vgroup cxt 1 action else action ()
  | Object lst ->
      (* #1946 object literal is easy to be
         interpreted as block statement
         here we avoid parens in such case
         {[
           var f = { x : 2 , y : 2}
         ]}
      *)
      cond_paren_group cxt (level > 1) 1 (fun _ ->
          if lst = [] then (
            string cxt "{}";
            cxt)
          else
            brace_vgroup cxt 1 (fun _ -> property_name_and_value_list cxt lst))

and property_name_and_value_list cxt (l : J.property_map) =
  iter_lst cxt l
    (fun cxt (pn, e) ->
      match e.expression_desc with
      | Var (Id v | Qualified ({ id = v; _ }, None)) ->
          let key = Js_dump_property.property_key pn in
          let str, cxt = str_of_ident cxt v in
          let content =
            (* if key = str then key
               else *)
            key ^ L.colon_space ^ str
          in
          string cxt content;
          cxt
      | _ ->
          let key = Js_dump_property.property_key pn in
          string cxt key;
          string cxt L.colon_space;
          expression ~level:1 cxt e)
    comma_nl

and array_element_list cxt (el : E.t list) : cxt =
  iter_lst cxt el (expression ~level:1) comma_nl

and arguments cxt (l : E.t list) : cxt =
  iter_lst cxt l (expression ~level:1) comma_sp

and variable_declaration top cxt (variable : J.variable_declaration) : cxt =
  (* TODO: print [const/var] for different backends  *)
  match variable with
  | { ident = i; value = None; ident_info; _ } ->
      if ident_info.used_stats = Dead_pure then cxt else pp_var_declare cxt i
  | {
   ident = name;
   value = Some e;
   ident_info = { used_stats; _ };
   property;
   _;
  } -> (
      match used_stats with
      | Dead_pure -> cxt
      | Dead_non_pure ->
          (* Make sure parens are added correctly *)
          statement_desc top cxt (J.Exp e)
      | _ -> (
          match e.expression_desc with
          | Fun { method_ = is_method; params; body = b; env; return_unit } ->
              pp_function ~return_unit ~is_method cxt
                ~fn_state:(if top then Name_top name else Name_non_top name)
                params b env
          | _ ->
              let cxt = pp_assign ~property cxt name in
              let cxt = expression ~level:1 cxt e in
              semi cxt;
              cxt))

and ipp_comment : 'a. cxt -> 'a -> unit = fun _cxt _comment -> ()

(* don't print a new line -- ASI
    FIXME: this still does not work in some cases...
    {[
      return /* ... */
      [... ]
    ]}
*)

and pp_comment cxt comment =
  if String.length comment > 0 then (
    string cxt "/* ";
    string cxt comment;
    string cxt " */")

and pp_comment_option cxt comment =
  match comment with None -> () | Some x -> pp_comment cxt x

(* and pp_loc_option f loc =  *)
and statement ~top cxt ({ statement_desc = s; comment; _ } : J.statement) : cxt
    =
  pp_comment_option cxt comment;
  statement_desc top cxt s

and statement_desc top cxt (s : J.statement_desc) : cxt =
  match s with
  | Block [] ->
      ipp_comment cxt L.empty_block;
      (* debugging*)
      cxt
  | Exp { expression_desc = Var _; _ } ->
      (* Does it make sense to optimize here? *)
      (* semi cxt; *)
      cxt
  | Exp e -> (
      match e.expression_desc with
      | Raw_js_code { code; code_info = Stmt Js_stmt_comment } ->
          string cxt code;
          cxt
      | Raw_js_code { code_info = Exp (Js_literal { comment }); _ } ->
          (match comment with
          (* The %raw is just a comment *)
          | Some s -> string cxt s
          | None -> ());
          cxt
      | Str _ -> cxt
      | _ ->
          let cxt =
            (if exp_need_paren e then paren_group cxt 1 else group cxt 0)
              (fun _ -> expression ~level:0 cxt e)
          in
          semi cxt;
          cxt)
  | Block b ->
      (* No braces needed here *)
      ipp_comment cxt L.start_block;
      let cxt = statements ~top cxt b in
      ipp_comment cxt L.end_block;
      cxt
  | Variable l -> variable_declaration top cxt l
  | If { pred = e; then_ = s1; else_ = s2 } -> (
      (* TODO: always brace those statements *)
      string cxt L.if_;
      space cxt;
      let cxt = paren_group cxt 1 (fun _ -> expression ~level:0 cxt e) in
      space cxt;
      let cxt = brace_block cxt s1 in
      match s2 with
      | []
      | [
          { statement_desc = Block [] | Exp { expression_desc = Var _; _ }; _ };
        ] ->
          newline cxt;
          cxt
      | [ ({ statement_desc = If _; _ } as nest) ]
      | [
          {
            statement_desc = Block [ ({ statement_desc = If _; _ } as nest) ];
            _;
          };
        ] ->
          space cxt;
          string cxt L.else_;
          space cxt;
          statement ~top:false cxt nest
      | _ :: _ as s2 ->
          space cxt;
          string cxt L.else_;
          space cxt;
          brace_block cxt s2)
  | While { label; cond = e; body = s } ->
      (*  FIXME: print scope as well *)
      (match label with
      | Some i ->
          string cxt i;
          string cxt L.colon;
          newline cxt
      | None -> ());
      let cxt =
        match e.expression_desc with
        | Number (Int { i = 1l; _ }) ->
            string cxt L.while_;
            string cxt L.lparen;
            string cxt L.true_;
            string cxt L.rparen;
            space cxt;
            cxt
        | _ ->
            string cxt L.while_;
            let cxt = paren_group cxt 1 (fun _ -> expression ~level:0 cxt e) in
            space cxt;
            cxt
      in
      let cxt = brace_block cxt s in
      semi cxt;
      cxt
  | ForRange
      {
        for_ident_expr = for_ident_expression;
        finish_expr = finish;
        for_ident = id;
        direction;
        body = s;
      } ->
      let action cxt =
        vgroup cxt 0 (fun _ ->
            let cxt =
              group cxt 0 (fun _ ->
                  (* The only place that [semi] may have semantics here *)
                  string cxt L.for_;
                  paren_group cxt 1 (fun _ ->
                      let cxt, new_id =
                        match
                          (for_ident_expression, finish.expression_desc)
                        with
                        | Some ident_expression, (Number _ | Var _) ->
                            let cxt = pp_var_assign cxt id in
                            (expression ~level:0 cxt ident_expression, None)
                        | Some ident_expression, _ ->
                            let cxt = pp_var_assign cxt id in
                            let cxt =
                              expression ~level:1 cxt ident_expression
                            in
                            space cxt;
                            comma cxt;
                            let id = Ident.create (Ident.name id ^ "_finish") in
                            let cxt = ident cxt id in
                            space cxt;
                            string cxt L.eq;
                            space cxt;
                            (expression ~level:1 cxt finish, Some id)
                        | None, (Number _ | Var _) -> (cxt, None)
                        | None, _ ->
                            let id = Ident.create (Ident.name id ^ "_finish") in
                            let cxt = pp_var_assign cxt id in
                            (expression ~level:15 cxt finish, Some id)
                      in
                      semi cxt;
                      space cxt;
                      let cxt = ident cxt id in
                      space cxt;
                      let right_prec =
                        match direction with
                        | Upto ->
                            let _, _, right = Js_op_util.op_prec Le in
                            string cxt L.le;
                            right
                        | Up ->
                            let _, _, right = Js_op_util.op_prec Lt in
                            string cxt L.lt;
                            right
                        | Downto ->
                            let _, _, right = Js_op_util.op_prec Ge in
                            string cxt L.ge;
                            right
                      in
                      space cxt;
                      let cxt =
                        expression ~level:right_prec cxt
                          (match new_id with
                          | Some i -> E.var i
                          | None -> finish)
                      in
                      semi cxt;
                      space cxt;
                      pp_direction cxt direction;
                      ident cxt id))
            in
            brace_block cxt s)
      in
      action cxt
  | Continue s ->
      continue cxt s;
      cxt (* newline cxt;  #2642 *)
  | Debugger ->
      debugger_nl cxt;
      cxt
  | Break ->
      break_nl cxt;
      cxt
  | Return e -> (
      match e.expression_desc with
      | Fun { method_ = is_method; params = l; body = b; env; return_unit } ->
          let cxt =
            pp_function ~return_unit ~is_method cxt ~fn_state:Is_return l b env
          in
          semi cxt;
          cxt
      | Undefined ->
          return_sp cxt;
          semi cxt;
          cxt
      | _ ->
          return_sp cxt;
          (* string cxt "return ";(\* ASI -- when there is a comment*\) *)
          group cxt return_indent (fun _ ->
              let cxt = expression ~level:0 cxt e in
              semi cxt;
              cxt))
  | Int_switch { expr = e; clauses = cc; default = def } ->
      string cxt L.switch;
      space cxt;
      let cxt = paren_group cxt 1 (fun _ -> expression ~level:0 cxt e) in
      space cxt;
      brace_vgroup cxt 1 (fun _ ->
          let cxt =
            loop_case_clauses cxt (fun cxt i -> string cxt (string_of_int i)) cc
          in
          match def with
          | None -> cxt
          | Some def ->
              group cxt 1 (fun _ ->
                  string cxt L.default;
                  string cxt L.colon;
                  newline cxt;
                  statements ~top:false cxt def))
  | String_switch { expr = e; clauses = cc; default = def } ->
      string cxt L.switch;
      space cxt;
      let cxt = paren_group cxt 1 (fun _ -> expression ~level:0 cxt e) in
      space cxt;
      brace_vgroup cxt 1 (fun _ ->
          let cxt =
            loop_case_clauses cxt
              (fun cxt as_value ->
                let e = E.as_value as_value in
                ignore @@ expression_desc cxt ~level:0 e.expression_desc)
              cc
          in
          match def with
          | None -> cxt
          | Some def ->
              group cxt 1 (fun _ ->
                  string cxt L.default;
                  string cxt L.colon;
                  newline cxt;
                  statements ~top:false cxt def))
  | Throw e ->
      let e =
        match e.expression_desc with
        | Caml_block
            {
              fields = el;
              tag_info = (Blk_extension | Blk_record_ext _) as ext;
              _;
            } ->
            {
              e with
              expression_desc =
                (exn_block_as_obj ~stack:true el ext).expression_desc;
            }
        | _ -> { e with expression_desc = (exn_ref_as_obj e).expression_desc }
      in
      string cxt L.throw;
      space cxt;
      group cxt throw_indent (fun _ ->
          let cxt = expression ~level:0 cxt e in
          semi cxt;
          cxt)
  (* There must be a space between the return and its
     argument. A line return would not work *)
  | Try { body = b; catch = ctch; finally = fin } ->
      vgroup cxt 0 (fun _ ->
          string cxt L.try_;
          space cxt;
          let cxt = brace_block cxt b in
          let cxt =
            match ctch with
            | None -> cxt
            | Some (i, b) ->
                newline cxt;
                string cxt "catch (";
                let cxt = ident cxt i in
                string cxt ")";
                brace_block cxt b
          in
          match fin with
          | None -> cxt
          | Some b ->
              group cxt 1 (fun _ ->
                  string cxt L.finally;
                  space cxt;
                  brace_block cxt b))

and function_body (cxt : cxt) ~return_unit (b : J.block) : unit =
  match b with
  | [] -> ()
  | [ s ] -> (
      match s.statement_desc with
      | If
          {
            pred = bool;
            then_;
            else_ =
              [
                {
                  statement_desc = Return { expression_desc = Undefined; _ };
                  _;
                };
              ];
          } ->
          ignore
            (statement ~top:false cxt
               { s with statement_desc = If { pred = bool; then_; else_ = [] } }
              : cxt)
      | Return { expression_desc = Undefined; _ } -> ()
      | Return exp when return_unit ->
          ignore (statement ~top:false cxt (S.exp exp) : cxt)
      | _ -> ignore (statement ~top:false cxt s : cxt))
  | [ s; { statement_desc = Return { expression_desc = Undefined; _ }; _ } ] ->
      ignore (statement ~top:false cxt s : cxt)
  | s :: r ->
      let cxt = statement ~top:false cxt s in
      newline cxt;
      function_body cxt r ~return_unit

and brace_block cxt b =
  (* This one is for '{' *)
  brace_vgroup cxt 1 (fun _ -> statements ~top:false cxt b)

(* main entry point *)
and statements ~top cxt b =
  iter_lst cxt b
    (fun cxt s -> statement ~top cxt s)
    (if top then at_least_two_lines else newline)

let string_of_block ~output_dir ~package_info ~output_info (block : J.block) =
  let buffer = Buffer.create 50 in
  let cxt = from_buffer ~output_dir ~package_info ~output_info buffer in
  let (_ : cxt) = statements ~top:true cxt block in
  flush cxt ();
  Buffer.contents buffer

let string_of_expression (e : J.expression) =
  let buffer = Buffer.create 50 in
  let cxt =
    from_buffer ~output_dir:"." ~package_info:Js_packages_info.empty
      ~output_info:Js_packages_info.default_output_info buffer
  in
  let (_ : cxt) = expression ~level:0 cxt e in
  flush cxt ();
  Buffer.contents buffer

let statements ~top ~scope ~output_dir ~package_info ~output_info pp b =
  (statements ~top { scope; pp; output_dir; package_info; output_info } b).scope
