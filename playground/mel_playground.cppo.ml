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

open Melstd
open Melangelib
open Melange_compiler_libs
module Js = Jsoo_runtime.Js
module Melange_OCaml_version = Ast_io.Melange_ast_version

module Melange_ast = struct
  external to_ppxlib :
    Parsetree.structure -> Melange_OCaml_version.Ast.Parsetree.structure
    = "%identity"

  external from_ppxlib :
    Melange_OCaml_version.Ast.Parsetree.structure -> Parsetree.structure
    = "%identity"
end

let warnings_collected : Location.report list ref = ref []

module From_ppxlib =
  Ppxlib_ast.Convert (Ppxlib_ast.Selected_ast) (Melange_OCaml_version)


#if OCAML_VERSION >= (5,3,0)
module Printtyp = Out_type
#else
module Format_doc = Format
#endif

(* Collects the type information from the typed_tree, so we can use that data
   to display types on hover etc. *)
let collect_type_hints =
  let module Printer = struct
    let print_expr typ =
      Printtyp.reset ();
      Format_doc.asprintf "%a" !Oprint.out_type (Printtyp.tree_of_typexp Type typ)

    let print_pattern pat =
      Printtyp.reset ();
      Format_doc.asprintf "%a" !Oprint.out_type
        (Printtyp.tree_of_typexp Type pat.Typedtree.pat_type)

    let print_decl ~recStatus name decl =
      Printtyp.reset ();
      Format_doc.asprintf "%a" !Oprint.out_sig_item
        (Printtyp.tree_of_type_declaration (Ident.create_local name) decl
           recStatus)
  end in
  fun (structure, _) ->
    let open Typedtree in
    let create_type_hint_obj loc kind hint =
      let open Location in
      let _, startline, startcol = Location.get_pos_info loc.loc_start in
      let _, endline, endcol = Location.get_pos_info loc.loc_end in
      Js.obj
        [|
          ( "start",
            Js.obj
              [|
                ("line", startline |> float_of_int |> Js.number_of_float);
                ("col", startcol |> float_of_int |> Js.number_of_float);
              |] );
          ( "end",
            Js.obj
              [|
                ("line", endline |> float_of_int |> Js.number_of_float);
                ("col", endcol |> float_of_int |> Js.number_of_float);
              |] );
          ("kind", Js.string kind);
          ("hint", Js.string hint);
        |]
    in
    let acc = ref [] in
    let cur_rec_status = ref None in
    let open Tast_iterator in
    let expr_iter iter exp =
      let hint = Printer.print_expr exp.exp_type in
      let obj = create_type_hint_obj exp.exp_loc "expression" hint in
      acc := obj :: !acc;
      Tast_iterator.default_iterator.expr iter exp
    and value_binding_iter iter binding =
      let hint = Printer.print_expr binding.vb_expr.exp_type in
      let obj = create_type_hint_obj binding.vb_loc "binding" hint in
      acc := obj :: !acc;
      Tast_iterator.default_iterator.value_binding iter binding
    and core_type_iter iter ct =
      let hint = Printer.print_expr ct.ctyp_type in
      let obj = create_type_hint_obj ct.ctyp_loc "core_type" hint in
      acc := obj :: !acc;
      Tast_iterator.default_iterator.typ iter ct
    and pattern_iter iter pat =
      let hint = Printer.print_pattern pat in
      let obj = create_type_hint_obj pat.pat_loc "pattern_type" hint in
      acc := obj :: !acc;
      Tast_iterator.default_iterator.pat iter pat
    and type_declarations_iter iter ((rec_flag, _) as td) =
      let status =
        match rec_flag with
        | Asttypes.Nonrecursive -> Types.Trec_not
        | Recursive -> Trec_first
      in
      cur_rec_status := Some status;
      Tast_iterator.default_iterator.type_declarations iter td
    and type_declaration_iter iter tdecl =
      (match !cur_rec_status with
      | Some recStatus -> (
          let hint =
            Printer.print_decl ~recStatus tdecl.typ_name.Asttypes.txt
              tdecl.typ_type
          in
          let obj =
            create_type_hint_obj tdecl.typ_loc "type_declaration" hint
          in
          acc := obj :: !acc;
          match recStatus with
          | Trec_not | Trec_first -> cur_rec_status := Some Trec_next
          | _ -> ())
      | None -> ());
      Tast_iterator.default_iterator.type_declaration iter tdecl
    in
    let iterator =
      {
        Tast_iterator.default_iterator with
        expr = expr_iter;
        value_binding = value_binding_iter;
        typ = core_type_iter;
        pat = pattern_iter;
        type_declarations = type_declarations_iter;
        type_declaration = type_declaration_iter;
      }
    in
    iterator.structure iterator structure;
    Js.array (!acc |> Array.of_list)

let melange_ppx =
  let module To_ppxlib =
    Ppxlib_ast.Convert (Melange_OCaml_version) (Ppxlib_ast.Selected_ast)
  in
  fun ast ->
    let ppxlib_ast : Ppxlib_ast.Parsetree.structure =
      (* Copy to ppxlib version *)
      To_ppxlib.copy_structure ast
    in
    let melange_converted_ast =
      From_ppxlib.copy_structure (Ppxlib.Driver.map_structure ppxlib_ast)
    in
    Melange_ast.from_ppxlib melange_converted_ast

let compile =
  let error_of_exn e =
    match Location.error_of_exn e with
    | Some (`Ok e) -> Some e
    | Some `Already_displayed -> None
    | None -> (
        match Ocaml_common.Location.error_of_exn e with
        | Some (`Ok e) -> Some e
        | Some `Already_displayed | None -> None)
  in
  fun ~(impl : Lexing.lexbuf -> Melange_OCaml_version.Ast.Parsetree.structure)
      str ->
    let modulename = "Test" in
    (* let env = !Toploop.toplevel_env in *)
    (* let modulename = module_of_filename ppf sourcefile outputprefix in *)
    (* Env.set_unit_name modulename; *)
    Lam_compile_env.reset ();
    Env.reset_cache ();
    let env = Initialization.Perfile.initial_env () in
    (* Question ?? *)
    (* let finalenv = ref Env.empty in *)
    let types_signature = ref [] in
    warnings_collected := [];
    try
      let lexbuf = Toolchain.feed_string_with_newline str in
      Ocaml_common.Location.input_lexbuf := Some lexbuf;
      Location.input_lexbuf := Some lexbuf;
      let ast =
        lexbuf
        |> impl
        |> melange_ppx
        |> Builtin_ast_mapper.rewrite_structure
      in
      let typed_tree =
        let { Typedtree.structure; coercion; shape = _; signature } =
#if OCAML_VERSION >= (5,3,0)
          let unit_info = Unit_info.make ~source_file:modulename Unit_info.Impl modulename in
          Typemod.type_implementation unit_info env ast
#elif OCAML_VERSION >= (5,2,0)
          let unit_info = Unit_info.make ~source_file:modulename modulename in
          Typemod.type_implementation unit_info env ast
#else
          Typemod.type_implementation modulename modulename modulename env ast
#endif
        in
        (* finalenv := c ; *)
        types_signature := signature;
        (structure, coercion)
      in
      typed_tree |> Translmod.transl_implementation modulename
      |> (* Printlambda.lambda ppf *) fun { Lambda.code = lam; _ } ->
      let v =
        let buffer = Buffer.create 1000 in
        let () =
          Js_dump_program.pp_deps_program ~output_prefix:""
            ~package_info:Js_packages_info.empty
            ~output_info:
              {
                Js_packages_info.module_system = ESM;
                suffix = Js_suffix.default;
              }
            (Js_pp.from_buffer buffer)
            (Lam_compile_main.compile
            ~package_info:Js_packages_info.empty
            "" lam)
        in
        Buffer.contents buffer
      in
      let type_hints = collect_type_hints typed_tree in
      Js.obj
        [|
          ("js_code", Js.string v);
          ( "warnings",
            List.rev_map ~f:Toolchain.warning_error_to_js !warnings_collected
            |> Array.of_list |> Js.array );
          ("type_hints", type_hints);
        |]
      (* Format.fprintf output_ppf {| { "js_code" : %S }|} v ) *)
    with e -> (
      match error_of_exn e with
      | Some error -> Toolchain.warning_error_to_js error
      | None -> (
          let default =
            lazy
              (Js.obj
                 [|
                   ("js_warning_error_msg", Js.string (Printexc.to_string e));
                 |])
          in
          match e with
          | Warnings.Errors -> (
              let warnings = !warnings_collected in
              match warnings with
              | [] -> Lazy.force default
              | warnings ->
                  let type_ = "warning_errors" in
                  let jsErrors =
                    List.rev_map ~f:Toolchain.warning_error_to_js warnings
                    |> Array.of_list
                  in
                  Js.obj
                    [|
                      ("warning_errors", Js.array jsErrors);
                      ("type", Js.string type_);
                    |])
          | _ -> Lazy.force default))

let () =
  (* We need to overload the original warning printer to capture the warnings
     and not let them go through default printer (which will end up in browser
     console) *)
  let playground_warning_reporter, playground_alert_reporter =
    let playground_reporter ~f ~mk (loc : Location.t) w : Location.report option
        =
      match f w with
      | `Inactive -> None
      | `Active { Warnings.id; message; is_error; sub_locs } ->
          let _msg_of_str str ppf = Format.pp_print_string ppf str in
          let kind = mk ~is_error id in
          let main = {
            Location.loc
            ; txt =
#if OCAML_VERSION >= (5,4,0)
              message
#elif OCAML_VERSION >= (5,3,0)
              Format_doc.Doc.msg "%s" message
#else
              _msg_of_str message
#endif
          }
          in
          let sub =
            List.map
              ~f:(fun (loc, sub_message) ->
                { Location.loc
                ; txt =
#if OCAML_VERSION >= (5,4,0)
              sub_message
#elif OCAML_VERSION >= (5,3,0)
              Format_doc.Doc.msg "%s" sub_message
#else
              _msg_of_str sub_message
#endif
              })
              sub_locs
          in
          warnings_collected :=
            { Location.kind; main; sub;
#if OCAML_VERSION >= (5,3,0)
              footnote = None
#endif

                } :: !warnings_collected;
          None
    in
    let playground_warning_reporter =
      let mk ~is_error id =
        if is_error then Location.Report_warning_as_error id
        else Report_warning id
      in
      playground_reporter ~f:Warnings.report ~mk
    and playground_alert_reporter =
      let mk ~is_error id =
        if is_error then Location.Report_alert_as_error id else Report_alert id
      in
      playground_reporter ~f:Warnings.report_alert ~mk
    in

    (playground_warning_reporter, playground_alert_reporter)
  in

  let load_cmi
#if OCAML_VERSION >= (5,2,0)
  ~allow_hidden:_
#endif
  ~unit_name : Persistent_env.Persistent_signature.t option =
    match
      Initialization.find_in_path_exn
        (Artifact_extension.append_extension unit_name Cmi)
    with
    | filename ->
      Some
        { filename
        ; cmi = Cmi_format.read_cmi filename
#if OCAML_VERSION >= (5,2,0)
        ; visibility = Visible
#endif
        }
    | exception Not_found -> None
  in

  Initialization.Global.run ();
  Persistent_env.Persistent_signature.load := load_cmi;

  Clflags.binary_annotations := false;
  Clflags.color := None;
  Location.warning_reporter := playground_warning_reporter;
  Ocaml_common.Location.alert_reporter := playground_alert_reporter;
  Location.alert_reporter := playground_alert_reporter;
  (* To add a directory to the load path *)
  Load_path.add_dir
#if OCAML_VERSION >= (5,2,0)
    ~hidden:false
#endif
    "/static"

let () =
  Js.set
    (Js.pure_js_expr "globalThis")
    (Js.string "ocaml")
    (Js.obj
       [|
         ( "compileML",
           Js.wrap_meth_callback (fun _ code ->
               compile
                 ~impl:(fun
                     buf : Melange_OCaml_version.Ast.Parsetree.structure ->
                   Melange_ast.to_ppxlib (Parse.implementation buf))
                 (Js.to_string code)) );
         ( "compileRE",
           Js.wrap_meth_callback (fun _ code ->
               compile
                 ~impl:(fun
                     buf : Melange_OCaml_version.Ast.Parsetree.structure ->
                   From_ppxlib.copy_structure
                     (Reason_toolchain.RE.implementation buf))
                 (Js.to_string code)) );
         ("version", Js.string Melange_version.version);
         ( "parseRE",
           Js.wrap_meth_callback (fun _ re_string ->
               Toolchain.parseRE re_string) );
         ( "parseML",
           Js.wrap_meth_callback (fun _ ocaml_string ->
               Toolchain.parseML ocaml_string) );
         ( "printRE",
           Js.wrap_meth_callback (fun _ reason_ast_and_comments ->
               Toolchain.printRE reason_ast_and_comments) );
         ( "printML",
           Js.wrap_meth_callback (fun _ ocaml_ast_and_comments ->
               Toolchain.printML ocaml_ast_and_comments) );
       |])
