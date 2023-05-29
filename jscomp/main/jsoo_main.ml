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

module Js = Jsoo_common.Js
open Melange_compiler_libs

(** *)

(*
 Error:
     *  {
     *    row: 12,
     *    column: 2, //can be undefined
     *    text: "Missing argument",
     *    type: "error" // or "warning" or "info"
     *  }
*)
let () =
  Bs_conditional_initial.setup_env ();
  Clflags.binary_annotations := false

let error_of_exn e =
  match Location.error_of_exn e with
  | Some (`Ok e) -> Some e
  | Some `Already_displayed | None -> None

let compile impl str : Js.Unsafe.obj =
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
  try
    (* default *)
    let ast = impl (Lexing.from_string str) in
    let ast = Melange_ppx_lib.Ppx_entry.rewrite_implementation ast in
    let typed_tree =
      let { Typedtree.structure; coercion; shape = _; signature }, _finalenv =
        Typemod.type_implementation_more modulename modulename modulename env
          ast
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
        ~output_info:{ Js_packages_info.module_system = NodeJS; suffix = Js }
        (Ext_pp.from_buffer buffer)
        (Lam_compile_main.compile "" lam)
    in
    let v = Buffer.contents buffer in
    Js.Unsafe.(obj [| ("js_code", inject @@ Js.string v) |])
    (* Format.fprintf output_ppf {| { "js_code" : %S }|} v ) *)
  with e -> (
    match error_of_exn e with
    | Some error -> Jsoo_common.mk_js_error error
    | None ->
        Js.Unsafe.(
          obj [| ("js_error_msg", inject @@ Js.string (Printexc.to_string e)) |]))

let export (field : string) v = Js.Unsafe.set Js.Unsafe.global field v

(* To add a directory to the load path *)

let () = Load_path.add_dir "/static"

let make_compiler name impl =
  export name
    Js.Unsafe.(
      obj
        [|
          ( "compile",
            inject
            @@ Js.wrap_meth_callback (fun _ code ->
                   compile impl (Js.to_string code)) );
          ("version", Js.Unsafe.inject (Js.string Melange_version.version));
        |])

let () = make_compiler "ocaml" Parse.implementation
