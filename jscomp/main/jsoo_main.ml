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

open Melange_compiler_libs
module Js = Jsoo_common.Js

let warnings_collected : Location.report list ref = ref []

(* We need to overload the original warning printer to capture the warnings
   and not let them go through default printer (which will end up in browser
   console) *)
let playground_warning_reporter (loc : Location.t) w : Location.report option =
  let mk ~is_error id =
    if is_error then Location.Report_warning_as_error id else Report_warning id
  in
  match Warnings.report w with
  | `Inactive -> None
  | `Active { Warnings.id; message; is_error; sub_locs } ->
      let msg_of_str str ppf = Format.pp_print_string ppf str in
      let kind = mk ~is_error id in
      let main = { Location.loc; txt = msg_of_str message } in
      let sub =
        List.map
          (fun (loc, sub_message) ->
            { Location.loc; txt = msg_of_str sub_message })
          sub_locs
      in
      warnings_collected := { Location.kind; main; sub } :: !warnings_collected;
      None

let error_of_exn e =
  match Location.error_of_exn e with
  | Some (`Ok e) -> Some e
  | Some `Already_displayed -> None
  | None -> (
      match Ocaml_common.Location.error_of_exn e with
      | Some (`Ok e) -> Some e
      | Some `Already_displayed | None -> None)

module Melange_ast = struct
  external to_ppxlib :
    Melange_compiler_libs.Parsetree.structure ->
    Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure = "%identity"
end

module From_ppxlib =
  Ppxlib_ast.Convert (Ppxlib_ast.Selected_ast) (Ppxlib_ast__.Versions.OCaml_414)

module To_ppxlib =
  Ppxlib_ast.Convert (Ppxlib_ast__.Versions.OCaml_414) (Ppxlib_ast.Selected_ast)

let compile
    ~(impl :
       Lexing.lexbuf -> Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure)
    str : Js.t =
  let modulename = "Test" in
  (* let env = !Toploop.toplevel_env in *)
  (* Res_compmisc.init_path false; *)
  (* let modulename = module_of_filename ppf sourcefile outputprefix in *)
  (* Env.set_unit_name modulename; *)
  Lam_compile_env.reset ();
  let env = Res_compmisc.initial_env () in
  (* Question ?? *)
  (* let finalenv = ref Env.empty in *)
  let types_signature = ref [] in
  warnings_collected := [];
  try
    (* default *)
    let ast = impl (Lexing.from_string str) in
    let ast =
      let ppxlib_ast : Ppxlib_ast.Parsetree.structure =
        (* Copy to ppxlib version *)
        To_ppxlib.copy_structure
          (Obj.magic ast
            : Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure)
      in
      let melange_converted_ast =
        From_ppxlib.copy_structure (Ppxlib.Driver.map_structure ppxlib_ast)
      in
      (Obj.magic melange_converted_ast
        : Melange_compiler_libs.Parsetree.structure)
    in
    let typed_tree =
      let { Typedtree.structure; coercion; shape = _; signature } =
        Typemod.type_implementation modulename modulename modulename env ast
      in
      (* finalenv := c ; *)
      types_signature := signature;
      (structure, coercion)
    in
    typed_tree |> Translmod.transl_implementation modulename
    |> (* Printlambda.lambda ppf *) fun { Lambda.code = lam; _ } ->
    let buffer = Buffer.create 1000 in
    let () =
      Js_dump_program.pp_deps_program ~output_prefix:""
        ~package_info:Js_packages_info.empty
        ~output_info:
          {
            Js_packages_info.module_system = Es6;
            suffix = Ext_js_suffix.default;
          }
        (Ext_pp.from_buffer buffer)
        (Lam_compile_main.compile "" lam)
    in
    let v = Buffer.contents buffer in
    Js.(obj [| ("js_code", Js.string v) |])
    (* Format.fprintf output_ppf {| { "js_code" : %S }|} v ) *)
  with e -> (
    match error_of_exn e with
    | Some error -> Jsoo_common.mk_js_error error
    | None -> (
        let default =
          lazy Js.(obj [| ("js_error_msg", Js.string (Printexc.to_string e)) |])
        in
        match e with
        | Warnings.Errors -> (
            let warnings = !warnings_collected in
            match warnings with
            | [] -> Lazy.force default
            | warnings ->
                let type_ = "warning_errors" in
                let jsErrors =
                  List.rev_map Jsoo_common.mk_js_error warnings |> Array.of_list
                in
                Js.obj
                  [|
                    ("warning_errors", Js.array jsErrors);
                    ("type", Js.string type_);
                  |])
        | _ -> Lazy.force default))

let export (field : Js.t) v = Js.set (Js.pure_js_expr "globalThis") field v

let () =
  Bs_conditional_initial.setup_env ();
  Clflags.binary_annotations := false;
  Clflags.color := None;
  Location.warning_reporter := playground_warning_reporter;
  (* To add a directory to the load path *)
  Load_path.add_dir "/static"

let () =
  export (Js.string "ocaml")
    (Js.obj
       [|
         ( "compileML",
           Js.wrap_meth_callback (fun _ code ->
               compile
                 ~impl:
                   (fun buf :
                        Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure ->
                   Melange_ast.to_ppxlib
                     (Melange_compiler_libs.Parse.implementation buf))
                 (Js.to_string code)) );
         ( "compileRE",
           Js.wrap_meth_callback (fun _ code ->
               compile
                 ~impl:
                   (fun buf :
                        Ppxlib_ast__.Versions.OCaml_414.Ast.Parsetree.structure ->
                   From_ppxlib.copy_structure
                     (Reason_toolchain.RE.implementation buf))
                 (Js.to_string code)) );
         ("version", Js.string Melange_version.version);
         ( "parseRE",
           Js.wrap_meth_callback (fun _ re_string ->
               Jsoo_common.Reason.parseRE re_string) );
         ( "parseML",
           Js.wrap_meth_callback (fun _ ocaml_string ->
               Jsoo_common.Reason.parseML ocaml_string) );
         ( "printRE",
           Js.wrap_meth_callback (fun _ reason_ast_and_comments ->
               Jsoo_common.Reason.printRE reason_ast_and_comments) );
         ( "printML",
           Js.wrap_meth_callback (fun _ ocaml_ast_and_comments ->
               Jsoo_common.Reason.printML ocaml_ast_and_comments) );
       |])
