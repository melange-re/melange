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
module S = Js_stmt_make

type meta_info = Info of J.ident_info | Recursive

let super = Js_record_iter.super

let mark_dead_code (js : J.program) : J.program =
  let ident_use_stats : meta_info Ident.Hashtbl.t = Ident.Hashtbl.create 17 in
  let mark_dead =
    {
      super with
      ident =
        (fun _ ident ->
          match Ident.Hashtbl.find ident_use_stats ident with
          | exception Not_found ->
              (* First time *)
              Ident.Hashtbl.add ident_use_stats ~key:ident ~data:Recursive
          (* recursive identifiers *)
          | Recursive -> ()
          | Info x -> Js_op.update_used_stats x Used);
      variable_declaration =
        (fun self vd ->
          match vd.ident_info.used_stats with
          | Dead_pure -> ()
          | Dead_non_pure -> (
              match vd.value with
              | None -> ()
              | Some x -> self.expression self x)
          | _ -> (
              let ({ ident; ident_info; value; _ } : J.variable_declaration) =
                vd
              in
              let pure =
                match value with
                | None -> true
                | Some x ->
                    self.expression self x;
                    Js_analyzer.no_side_effect_expression x
              in
              let () =
                if Ident.Set.mem ident js.export_set then
                  Js_op.update_used_stats ident_info Exported
              in
              match Ident.Hashtbl.find ident_use_stats ident with
              | Recursive ->
                  Js_op.update_used_stats ident_info Used;
                  Ident.Hashtbl.replace ident_use_stats ~key:ident
                    ~data:(Info ident_info)
              | Info _ ->
                  (* check [camlinternlFormat,box_type] inlined twice
                      FIXME: seems we have redeclared identifiers
                  *)
                  ()
              (* assert false *)
              | exception Not_found ->
                  (* First time *)
                  Ident.Hashtbl.add ident_use_stats ~key:ident
                    ~data:(Info ident_info);
                  Js_op.update_used_stats ident_info
                    (if pure then Scanning_pure else Scanning_non_pure)));
    }
  in
  mark_dead.program mark_dead js;
  Ident.Hashtbl.iter ident_use_stats
    ~f:(fun ~key:_id ~data:(info : meta_info) ->
      match info with
      | Info ({ used_stats = Scanning_pure } as info) ->
          Js_op.update_used_stats info Dead_pure
      | Info ({ used_stats = Scanning_non_pure } as info) ->
          Js_op.update_used_stats info Dead_non_pure
      | _ -> ());
  js

(*
   when we do optmizations, we might need track it will break invariant
   of other optimizations, especially for [mutable] meta data,
   for example, this pass will break [closure] information,
   it should be done before closure pass (even it does not use closure information)

   Take away, it is really hard to change the code while collecting some information..
   we should always collect info in a single pass

   Note that, we should avoid reuse object, i.e,
   {[
     let v =
       object
       end
   ]}
   Since user may use `bsc.exe -c xx.ml xy.ml xz.ml` and we need clean up state
 *)

(* we can do here, however, we should
    be careful that it can only be done
    when it's accessed once and the array is not escaped,
    otherwise, we redo the computation,
    or even better, we re-order

    {[
      var match = [/* tuple */0,Pervasives.string_of_int(f(1,2,3)),f3(2),arr];

          var a = match[1];

            var b = match[2];

    ]}

    --->

    {[
      var match$1 = Pervasives.string_of_int(f(1,2,3));
          var match$2 = f3(2);
              var match = [/* tuple */0,match$1,match$2,arr];
                  var a = match$1;
                    var b = match$2;
                      var arr = arr;
    ]}

    -->
    since match$1 (after match is eliminated) is only called once
    {[
      var a = Pervasives.string_of_int(f(1,2,3));
      var b = f3(2);
      var arr = arr;
    ]}
*)

let super = Js_record_map.super

type block_fields = {
  fields : J.expression list;
  mutable fields_array : J.expression array option;
  mutable hits : int;
}

type substitution = block_fields Ident.Hashtbl.t

let add_substitue substitution (ident : Ident.t) (e : J.expression) =
  match e.expression_desc with
  | Caml_block { fields; mutable_flag = Immutable; _ } ->
      Ident.Hashtbl.replace substitution ~key:ident
        ~data:{ fields; fields_array = None; hits = 0 }
  | _ -> Ident.Hashtbl.remove substitution ident

let find_substitute_field substitution id i =
  let i = Int32.to_int i in
  if i < 0 then None
  else
    match Ident.Hashtbl.find_opt substitution id with
    | None -> None
    | Some block_fields -> (
        match block_fields.fields_array with
        | Some fields ->
            if i < Array.length fields then Some fields.(i) else None
        | None ->
            block_fields.hits <- block_fields.hits + 1;
            if block_fields.hits > 1 then (
              let fields = Array.of_list block_fields.fields in
              block_fields.fields_array <- Some fields;
              if i < Array.length fields then Some fields.(i) else None)
            else List.nth_opt block_fields.fields i)

let subst_map substitution =
  {
    super with
    statement =
      (fun self v ->
        match v.statement_desc with
        | Variable { ident = _; ident_info = { used_stats = Dead_pure }; _ } ->
            { v with statement_desc = Block [] }
        | Variable
            {
              ident = _;
              ident_info = { used_stats = Dead_non_pure };
              value = None;
              _;
            } ->
            { v with statement_desc = Block [] }
        | Variable
            {
              ident = _;
              ident_info = { used_stats = Dead_non_pure };
              value = Some x;
              _;
            } ->
            { v with statement_desc = Exp x }
        | Variable
            ({
               ident;
               property = Strict | StrictOpt | Alias;
               value =
                 Some
                   ({
                      expression_desc =
                        Caml_block
                          {
                            fields = _ :: _ :: _ as ls;
                            mutable_flag = Immutable;
                            tag;
                            tag_info;
                          };
                      _;
                    } as block);
               _;
             } as variable) -> (
            (* If we do this, we should prevent incorrect inlning to inline it into an array :)
                do it only when block size is larger than one
            *)
            let module_fields_array = ref None in
            let field_name i =
              match tag_info with
              | Blk_module fields ->
                  let fields =
                    match !module_fields_array with
                    | Some fields -> fields
                    | None ->
                        let fields = Array.of_list fields in
                        module_fields_array := Some fields;
                        fields
                  in
                  if i < Array.length fields then fields.(i)
                  else string_of_int i
              | Blk_record fields ->
                  if i < Array.length fields then Array.unsafe_get fields i
                  else string_of_int i
              | _ -> string_of_int i
            in
            let _, e, bindings =
              List.fold_left
                ~f:(fun (i, e, acc) (x : J.expression) ->
                  match x.expression_desc with
                  | Var _ | Number _ | Str _ | Unicode _ | J.Bool _
                  | Undefined _ ->
                      (* TODO: check the optimization *)
                      (i + 1, x :: e, acc)
                  | _ ->
                      (* tradeoff,
                          when the block is small, it does not make
                          sense too much --
                          bottomline, when the block size is one, no need to do
                          this
                      *)
                      let v' = self.expression self x in
                      let match_id =
                        Ident.create (Ident.name ident ^ "_" ^ field_name i)
                      in
                      (i + 1, E.var match_id :: e, (match_id, v') :: acc))
                ~init:(0, [], []) ls
            in
            let e =
              {
                block with
                expression_desc =
                  Caml_block
                    {
                      fields = List.rev e;
                      mutable_flag = Immutable;
                      tag;
                      tag_info;
                    };
              }
            in
            let () = add_substitue substitution ident e in
            (* let bindings =  !bindings in *)
            let original_statement =
              {
                v with
                statement_desc = Variable { variable with value = Some e };
              }
            in
            match bindings with
            | [] -> original_statement
            | _ ->
                (* self#add_substitue ident e ; *)
                S.block
                  (List.fold_left bindings ~init:[ original_statement ]
                     ~f:(fun acc (id, v) ->
                       S.define_variable ~kind:Strict id v :: acc)))
        | _ -> super.statement self v);
    expression =
      (fun self x ->
        match x.expression_desc with
        | Array_index
            {
              expr = { expression_desc = Var (Id id); _ };
              index = { expression_desc = Number (Int { i; _ }); _ };
            }
        | Static_index
            { expr = { expression_desc = Var (Id id); _ }; pos = Some i; _ }
          -> (
            (* user program can be wrong, we should not turn a runtime crash
               into compile time crash. *)
            match find_substitute_field substitution id i with
            | Some
                ({
                   expression_desc = J.Var _ | Number _ | Str _ | Undefined _;
                   _;
                 } as x) ->
                x
            | Some _ | None -> super.expression self x)
        | _ -> super.expression self x);
  }

(* Top down or bottom up ?*)
(* A pass to support nullary argument in JS
    Nullary information can be done in one pass,
    there is no need to add another pass
*)

let program (js : J.program) =
  let obj = subst_map (Ident.Hashtbl.create 32) in
  let js = obj.program obj js in
  mark_dead_code js
(* |> mark_dead_code *)
(* mark dead code twice does have effect in some cases, however, we disabled it
   since the benefit is not obvious
*)
