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

open Ppxlib

type attr = Parsetree.attribute
type t = attr list
type ('a, 'b) st = { get : 'a option; set : 'b option }

let assert_bool_lit (e : Parsetree.expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true" }, None) -> true
  | Pexp_construct ({ txt = Lident "false" }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "expect `true` or `false` in this field"

let process_method_attributes_rev (attrs : t) =
  let exception Local of string in
  try
    let ret =
      Ext_list.fold_left attrs
        ({ get = None; set = None }, [])
        (fun (st, acc)
             ({ attr_name = { txt; _ }; attr_payload = payload } as attr) ->
          match txt with
          | "bs.get" | "get" (* @bs.get{null; undefined}*) ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local s)
                | Ok config ->
                    Ext_list.fold_left config (false, false)
                      (fun (null, undefined) ({ txt; loc }, opt_expr) ->
                        match txt with
                        | "null" ->
                            ( (match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e),
                              undefined )
                        | "undefined" -> (
                            ( null,
                              match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e ))
                        | "nullable" -> (
                            match opt_expr with
                            | None -> (true, true)
                            | Some e ->
                                let v = assert_bool_lit e in
                                (v, v))
                        | _ -> Bs_syntaxerr.err loc Unsupported_predicates)
              in

              ({ st with get = Some result }, acc)
          | "bs.set" | "set" ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local s)
                | Ok config ->
                    Ext_list.fold_left config `Get
                      (fun _st ({ txt; loc }, opt_expr) ->
                        (*FIXME*)
                        if txt = "no_get" then
                          match opt_expr with
                          | None -> `No_get
                          | Some e ->
                              if assert_bool_lit e then `No_get else `Get
                        else Bs_syntaxerr.err loc Unsupported_predicates)
              in
              (* properties -- void
                    [@@set{only}]
              *)
              ({ st with set = Some result }, acc)
          | _ -> (st, attr :: acc))
    in
    Ok ret
  with Local s -> Error s

type attr_kind =
  | Nothing
  | Meth_callback of attr
  | Uncurry of attr
  | Method of attr

let process_attributes_rev (attrs : t) : attr_kind * t =
  Ext_list.fold_left attrs (Nothing, [])
    (fun (st, acc) ({ attr_name = { txt; loc }; _ } as attr) ->
      match (txt, st) with
      | "bs", (Nothing | Uncurry _) ->
          (Uncurry attr, acc) (* TODO: warn unused/duplicated attribute *)
      | ("bs.this" | "this"), (Nothing | Meth_callback _) ->
          (Meth_callback attr, acc)
      | ("bs.meth" | "meth"), (Nothing | Method _) -> (Method attr, acc)
      | ("bs" | "bs.this" | "this"), _ ->
          Bs_syntaxerr.err loc Conflict_bs_bs_this_bs_meth
      | _, _ -> (st, attr :: acc))

let process_bs (attrs : t) =
  Ext_list.fold_left attrs (false, [])
    (fun (st, acc) ({ attr_name = { txt; loc = _ }; _ } as attr) ->
      match (txt, st) with "bs", _ -> (true, acc) | _, _ -> (st, attr :: acc))

let is_bs (attr : attr) =
  match attr with
  | { attr_name = { Location.txt = "bs"; _ }; _ } -> true
  | _ -> false

let bs_get : attr =
  {
    attr_name = { txt = "bs.get"; loc = Location.none };
    attr_payload = Parsetree.PStr [];
    attr_loc = Location.none;
  }

let bs_get_index : attr =
  {
    attr_name = { txt = "bs.get_index"; loc = Location.none };
    attr_payload = Parsetree.PStr [];
    attr_loc = Location.none;
  }

let bs_get_arity : attr =
  {
    attr_name = { txt = "internal.arity"; loc = Location.none };
    attr_payload =
      PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ( {
                    pexp_loc = Location.none;
                    pexp_loc_stack = [];
                    pexp_attributes = [];
                    pexp_desc =
                      Pexp_constant (Pconst_integer (string_of_int 1, None));
                  },
                  [] );
            pstr_loc = Location.none;
          };
        ];
    attr_loc = Location.none;
  }

let bs_set : attr =
  {
    attr_name = { txt = "bs.set"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let internal_expansive : attr =
  {
    attr_name = { txt = "internal.expansive"; loc = Location.none };
    attr_payload = PStr [];
    attr_loc = Location.none;
  }

let bs_return_undefined : attr =
  {
    attr_name = { txt = "bs.return"; loc = Location.none };
    attr_payload =
      PStr
        [
          {
            pstr_desc =
              Pstr_eval
                ( {
                    pexp_desc =
                      Pexp_ident
                        { txt = Lident "undefined_to_opt"; loc = Location.none };
                    pexp_loc = Location.none;
                    pexp_loc_stack = [];
                    pexp_attributes = [];
                  },
                  [] );
            pstr_loc = Location.none;
          };
        ];
    attr_loc = Location.none;
  }

let is_single_string x =
  match x with
  (* TODO also need detect empty phrase case *)
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ( { pexp_desc = Pexp_constant (Pconst_string (name, _, dec)); _ },
                _ );
          _;
        };
      ] ->
      Some (name, dec)
  | _ -> None

type derive_attr = { bs_deriving : Ast_payload.action list option } [@@unboxed]

let process_derive_type (attrs : t) : (derive_attr * t, string) result =
  let exception Local of string in
  try
    Ok
      (Ext_list.fold_left attrs
         ({ bs_deriving = None }, [])
         (fun (st, acc)
              ({ attr_name = { txt; loc }; attr_payload = payload } as attr) ->
           match txt with
           | "bs.deriving" | "deriving" -> (
               match st.bs_deriving with
               | None -> (
                   match Ast_payload.ident_or_record_as_config payload with
                   | Ok config -> ({ bs_deriving = Some config }, acc)
                   | Error stri -> raise (Local stri))
               | Some _ -> Bs_syntaxerr.err loc Duplicated_bs_deriving)
           | _ -> (st, attr :: acc)))
  with Local stri -> Error stri

let iter_process_bs_string_as (attrs : t) : string option =
  let st = ref None in
  Ext_list.iter attrs
    (fun ({ attr_name = { txt; loc }; attr_payload = payload } as attr) ->
      match txt with
      | "bs.as" | "as" ->
          if !st = None then (
            match is_single_string payload with
            | None -> Bs_syntaxerr.err loc Expect_string_literal
            | Some (v, _dec) ->
                Bs_ast_invariant.mark_used_bs_attribute
                  (Melange_ppxlib_ast.Of_ppxlib.copy_attr attr);
                st := Some v)
          else Bs_syntaxerr.err loc Duplicated_bs_as
      | _ -> ());
  !st

(* TODO also need detect empty phrase case *)
let is_single_int x : int option =
  match x with
  | PStr
      [
        {
          pstr_desc =
            Pstr_eval
              ({ pexp_desc = Pexp_constant (Pconst_integer (name, _)); _ }, _);
          _;
        };
      ] ->
      Some (int_of_string name)
  | _ -> None

let iter_process_bs_int_as (attrs : t) =
  let st = ref None in
  Ext_list.iter attrs
    (fun ({ attr_name = { txt; loc }; attr_payload = payload } as attr) ->
      match txt with
      | "bs.as" | "as" ->
          if !st = None then (
            match is_single_int payload with
            | None -> Bs_syntaxerr.err loc Expect_int_literal
            | Some _ as v ->
                Bs_ast_invariant.mark_used_bs_attribute
                  (Melange_ppxlib_ast.Of_ppxlib.copy_attr attr);
                st := v)
          else Bs_syntaxerr.err loc Duplicated_bs_as
      | _ -> ());
  !st

let has_bs_optional (attrs : t) : bool =
  Ext_list.exists attrs (fun ({ attr_name = { txt }; _ } as attr) ->
      match txt with
      | "bs.optional" | "optional" ->
          Bs_ast_invariant.mark_used_bs_attribute
            (Melange_ppxlib_ast.Of_ppxlib.copy_attr attr);
          true
      | _ -> false)
