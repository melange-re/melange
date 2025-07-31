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
module External_arg_spec = Melange_ffi.External_arg_spec

type st = { get : (bool * bool) option; set : [ `Get | `No_get ] option }

let assert_bool_lit (e : expression) =
  match e.pexp_desc with
  | Pexp_construct ({ txt = Lident "true"; _ }, None) -> true
  | Pexp_construct ({ txt = Lident "false"; _ }, None) -> false
  | _ ->
      Location.raise_errorf ~loc:e.pexp_loc
        "expected this expression to be a boolean literal (`true` or `false`)"

let process_method_attributes_rev attrs =
  let exception Local of Location.t * string in
  try
    let ret =
      List.fold_left
        ~f:(fun
            (st, acc)
            ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr)
          ->
          match txt with
          | "mel.get" ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local (loc, s))
                | Ok config ->
                    List.fold_left
                      ~f:(fun (null, undefined) ({ txt; loc }, opt_expr) ->
                        match txt with
                        | "null" ->
                            ( (match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e),
                              undefined )
                        | "undefined" ->
                            ( null,
                              match opt_expr with
                              | None -> true
                              | Some e -> assert_bool_lit e )
                        | "nullable" -> (
                            match opt_expr with
                            | None -> (true, true)
                            | Some e ->
                                let v = assert_bool_lit e in
                                (v, v))
                        | _ -> Error.err ~loc Unsupported_predicates)
                      ~init:(false, false) config
              in
              ({ st with get = Some result }, acc)
          | "mel.set" ->
              let result =
                match Ast_payload.ident_or_record_as_config payload with
                | Error s -> raise (Local (loc, s))
                | Ok config ->
                    List.fold_left
                      ~f:(fun _st ({ txt; loc }, opt_expr) ->
                        (*FIXME*)
                        if txt = "no_get" then
                          match opt_expr with
                          | None -> `No_get
                          | Some e ->
                              if assert_bool_lit e then `No_get else `Get
                        else Error.err ~loc Unsupported_predicates)
                      ~init:`Get config
              in
              (* properties -- void
                    [@@set{only}] *)
              ({ st with set = Some result }, acc)
          | _ -> (st, attr :: acc))
        ~init:({ get = None; set = None }, [])
        attrs
    in
    Ok ret
  with Local (loc, s) -> Error (loc, s)

module Kind = struct
  type t =
    | Nothing
    | Meth_callback of attribute
    | Uncurry of attribute
    | Method of attribute
end

let process_attributes_rev attrs : Kind.t * attribute list =
  List.fold_left ~init:(Kind.Nothing, []) attrs
    ~f:(fun (st, acc) ({ attr_name = { txt; loc }; _ } as attr) ->
      match (txt, st) with
      | "u", (Kind.Nothing | Uncurry _) ->
          (Uncurry attr, acc) (* TODO: warn unused/duplicated attribute *)
      | "mel.this", (Nothing | Meth_callback _) -> (Meth_callback attr, acc)
      | "mel.meth", (Nothing | Method _) -> (Method attr, acc)
      | ("u" | "mel.this"), _ -> Error.err ~loc Conflict_u_mel_this_mel_meth
      | _, _ -> (st, attr :: acc))

let process_pexp_fun_attributes_rev attrs =
  List.fold_left
    ~f:(fun (st, acc) ({ attr_name = { txt; loc = _ }; _ } as attr) ->
      match txt with "mel.open" -> (true, acc) | _ -> (st, attr :: acc))
    ~init:(false, []) attrs

let process_uncurried attrs =
  List.fold_left
    ~f:(fun (st, acc) ({ attr_name = { txt; _ }; _ } as attr) ->
      match (txt, st) with "u", _ -> (true, acc) | _, _ -> (st, attr :: acc))
    ~init:(false, []) attrs

let is_uncurried attr =
  match attr with
  | { attr_name = { Location.txt = "u"; _ }; _ } -> true
  | _ -> false

let attr name payload =
  {
    attr_name = { txt = name; loc = Location.none };
    attr_payload = PStr payload;
    attr_loc = Location.none;
  }

let mel_get = attr "mel.get" []
let mel_get_index = attr "mel.get_index" []
let mel_set = attr "mel.set" []

let mel_get_arity =
  attr "internal.arity"
    [
      Ast_builder.Default.pstr_eval ~loc:Location.none
        (Ast_builder.Default.pexp_constant ~loc:Location.none
           (Pconst_integer ("1", None)))
        [];
    ]

let internal_expansive = attr "internal.expansive" []

let mel_return_undefined =
  attr "mel.return"
    [
      Ast_builder.Default.pstr_eval ~loc:Location.none
        (Ast_builder.Default.pexp_ident ~loc:Location.none
           { txt = Lident "undefined_to_opt"; loc = Location.none })
        [];
    ]

let iter_process_mel_as_cst =
  let rec inner attrs (st : External_arg_spec.Arg_cst.t option) =
    match attrs with
    | ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) :: rest
      -> (
        match txt with
        | "mel.as" -> (
            match st with
            | Some _ -> Error.err ~loc Duplicated_mel_as
            | None -> (
                Mel_ast_invariant.mark_used_mel_attribute attr;
                match Ast_payload.is_single_int payload with
                | Some v -> inner rest (Some (Int v))
                | None -> (
                    match payload with
                    | PStr
                        [
                          {
                            pstr_desc =
                              Pstr_eval
                                ( {
                                    pexp_desc =
                                      Pexp_constant
                                        (Pconst_string
                                           (s, _, ((None | Some "json") as dec)));
                                    pexp_loc;
                                    _;
                                  },
                                  _ );
                            _;
                          };
                        ] -> (
                        match dec with
                        | None ->
                            inner rest (Some (External_arg_spec.Arg_cst.Str s))
                        | Some _ ->
                            (match
                               Melange_ffi.Classify_function.classify
                                 ~check:
                                   ( pexp_loc,
                                     Melange_ffi.Flow_ast_utils.flow_deli_offset
                                       dec )
                                 s
                             with
                            | Js_literal _ -> ()
                            | _ ->
                                Location.raise_errorf ~loc:pexp_loc
                                  "`[@mel.as {json| ... |json}]' only supports \
                                   JavaScript literals");
                            inner rest (Some (Js_literal s)))
                    | _ -> Error.err ~loc Expect_int_or_string_or_json_literal))
            )
        | _ -> inner rest st)
    | [] -> st
  in
  fun (attrs : attributes) -> inner attrs None

module Param_modifier = struct
  type kind =
    | Nothing
    | Spread
    | Uncurry of int option (* uncurry arity *)
    | Unwrap
    | Ignore
    | String
    | Int

  type t = { kind : kind; loc : Location.t }
end

(* duplicated @uncurry @string not allowed,
   it is worse in @uncurry since it will introduce
   inconsistency in arity.

  Supported external param type modifiers:
    - [@mel.unwrap] -> [ `A of int ] becomes `foo(42)`
    - [@mel.uncurry] -> uncurries callbacks in externals
    - [@mel.ignore] -> useful to combine with GADTs, e.g.
      ('a kind [@mel.ignore ] -> 'a -> 'a)
    - [@mel.spread] -> [ `A of int ] -> unit becomes `foo("a", 42)` -- supports
      `@mel.as` -- previously [@mel.string]
*)
let iter_process_mel_param_modifier =
  let assign ({ attr_name = { loc; _ }; _ } as attr) st v =
    match st with
    | Param_modifier.Nothing ->
        Mel_ast_invariant.mark_used_mel_attribute attr;
        { Param_modifier.kind = v; loc }
    | _ -> Error.err ~loc Conflict_attributes
  in
  let rec inner attrs { Param_modifier.kind = st; loc } =
    match attrs with
    | ({ attr_name = { txt; loc = _ }; attr_payload = payload; _ } as attr)
      :: rest ->
        let st' =
          match txt with
          | "mel.spread" -> assign attr st Spread
          | "mel.string" -> assign attr st String
          | "mel.int" -> assign attr st Int
          | "mel.ignore" -> assign attr st Ignore
          | "mel.unwrap" -> assign attr st Unwrap
          | "mel.uncurry" ->
              assign attr st (Uncurry (Ast_payload.is_single_int payload))
          | _ -> { kind = st; loc }
        in
        inner rest st'
    | [] -> { Param_modifier.kind = st; loc }
  in
  fun attrs ->
    inner attrs { Param_modifier.kind = Nothing; loc = Location.none }

let iter_process_mel_string_as =
  let rec inner attrs st =
    match attrs with
    | ({ attr_name = { txt; loc }; attr_payload = payload; _ } as attr) :: rest
      -> (
        match txt with
        | "mel.as" -> (
            match st with
            | None -> (
                match Ast_payload.is_single_string payload with
                | None -> Error.err ~loc Expect_string_literal
                | Some (v, _dec) ->
                    Mel_ast_invariant.mark_used_mel_attribute attr;
                    inner rest (Some v))
            | Some _ -> Error.err ~loc Duplicated_mel_as)
        | _ -> inner rest st)
    | [] -> st
  in
  fun attrs -> inner attrs None

let first_char_special (x : string) =
  match x with
  | "" -> false
  | _ -> (
      match String.unsafe_get x 0 with
      | '#' | '?' | '%' -> true
      | _ ->
          (* XXX(anmonteiro): Upstream considers "builtin" attributes ones that
             start with `?`. We keep the original terminology of `caml_` (and,
             incidentally, `nativeint_`). *)
          String.starts_with x ~prefix:"caml_"
          || String.starts_with x ~prefix:"nativeint_")

let first_marshal_char (x : string) = x <> "" && String.unsafe_get x 0 = '\132'

let prims_to_be_encoded (attrs : string list) =
  match attrs with
  | [] -> assert false (* normal val declaration *)
  | x :: _ when first_char_special x -> false
  | _ :: x :: _ when first_marshal_char x -> false
  | _ -> true

let partition_by_mel_ffi_attribute =
  let rec inner attrs acc st =
    match attrs with
    | ({ attr_name = { txt = "mel.internal.ffi"; loc }; attr_payload; _ } as x)
      :: rest -> (
        match st with
        | None -> (
            match attr_payload with
            | PStr
                [
                  {
                    pstr_desc =
                      Pstr_eval ({ pexp_desc = Pexp_constant const; _ }, _);
                    _;
                  };
                ] -> (
                match const with
                | Pconst_string (s, _, _) -> inner rest acc (Some s)
                | _ -> inner rest (x :: acc) st)
            | _ ->
                Location.raise_errorf ~loc
                  "`[@mel.internal.ffi \"..\"]' annotation must be a string")
        | Some _ ->
            Location.raise_errorf ~loc
              "Duplicate `[@mel.internal.ffi \"..\"]' annotation")
    | x :: xs -> inner xs (x :: acc) st
    | [] -> (st, List.rev acc)
  in
  fun attrs -> inner attrs [] None

(**

   [@@inline]
   let a = 3

   [@@inline]
   let a : 3

   They are not considered externals, they are part of the language
*)
let rs_externals attrs pval_prim =
  match pval_prim with
  | [] ->
      (* This is  val *)
      false
  | _ :: _ -> (
      let mel_ffi, attrs = partition_by_mel_ffi_attribute attrs in
      match mel_ffi with
      | Some _ -> false
      | None -> (
          match attrs with
          | [] -> prims_to_be_encoded pval_prim
          | _ :: _ ->
              Melange_ffi.External_ffi_attributes.has_mel_attributes
                (List.map ~f:(fun { attr_name = { txt; _ }; _ } -> txt) attrs)
              || prims_to_be_encoded pval_prim))

let iter_process_mel_int_as =
  let rec inner attrs acc =
    match attrs with
    | ({ attr_name = { txt = "mel.as"; loc }; attr_payload = payload; _ } as
       attr)
      :: rest -> (
        match acc with
        | None -> (
            match Ast_payload.is_single_int payload with
            | None -> Error.err ~loc Expect_int_literal
            | Some _ as v ->
                Mel_ast_invariant.mark_used_mel_attribute attr;
                inner rest v)
        | Some _ -> Error.err ~loc Duplicated_mel_as)
    | _ :: rest -> inner rest acc
    | [] -> acc
  in
  fun attrs -> inner attrs None

let has_mel_optional attrs : bool =
  List.exists
    ~f:(fun ({ attr_name = { txt; loc = _ }; _ } as attr) ->
      match txt with
      | "mel.optional" ->
          Mel_ast_invariant.mark_used_mel_attribute attr;
          true
      | _ -> false)
    attrs

let has_inline_payload attrs =
  List.find_opt
    ~f:(fun { attr_name = { txt; loc = _ }; _ } -> txt = "mel.inline")
    attrs

let has_mel_as_payload attrs =
  List.fold_left
    ~f:(fun (attrs, found) attr ->
      match attr.attr_name.txt with
      | "mel.as" -> (
          match found with
          | Some _ ->
              Location.raise_errorf ~loc:attr.attr_loc
                "Duplicate `%@mel.as' attribute found"
          | None -> (attrs, Some attr))
      | _ -> (attr :: attrs, found))
    ~init:([], None) attrs

let ocaml_warning w =
  attr "ocaml.warning"
    [
      Ast_builder.Default.pstr_eval ~loc:Location.none
        (Ast_builder.Default.pexp_constant ~loc:Location.none
           (Pconst_string (w, Location.none, None)))
        [];
    ]

(* We disable warning 61 in Melange externals since they're substantially
   different from OCaml externals. This warning doesn't make sense for a JS
   runtime *)
let unboxable_type_in_prim_decl = ocaml_warning "-unboxable-type-in-prim-decl"
let ignored_extra_argument = ocaml_warning "-ignored-extra-argument"
let unused_type_declaration = ocaml_warning "-unused-type-declaration"

let mel_ffi =
 fun (t : Melange_ffi.External_ffi_types.t) ->
  attr "mel.internal.ffi"
    [
      Ast_builder.Default.pstr_eval ~loc:Location.none
        (Ast_builder.Default.pexp_constant ~loc:Location.none
           (Pconst_string
              (Melange_ffi.External_ffi_types.to_string t, Location.none, None)))
        [];
    ]
