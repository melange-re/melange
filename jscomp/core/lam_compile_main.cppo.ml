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

let compile_group
  ~package_info
  output_prefix
  (meta : Lam_stats.t)
  (x : Lam_group.t) : Js_output.t =
  match x with
  (*
        We need

        2. [E.builtin_dot] for javascript builtin
        3. [E.mldot]
     *)
  (* ATTENTION: check {!Lam_compile_global} for consistency  *)
  (* Special handling for values in [Pervasives] *)
  (*
         we delegate [stdout, stderr, and stdin] into [caml_io] module,
         the motivation is to help dead code eliminatiion, it's helpful
         to make those parts pure (not a function call), then it can be removed
         if unused
      *)

  (* QUICK hack to make hello world example nicer,
     Note the arity of [print_endline] is already analyzed before,
     so it should be safe
  *)

  | Single (kind, id, lam) ->
    (* let lam = Optimizer.simplify_lets [] lam in  *)
    (* can not apply again, it's wrong USE it with care*)
    (* ([Js_stmt_make.comment (Gen_of_env.query_type id  env )], None)  ++ *)
    Lam_compile.compile_lambda { continuation = Declare (kind, id);
                                 jmp_table = Lam_compile_context.empty_handler_map;
                                 package_info;
                                 output_prefix;
                                 meta
                               } lam

  | Recursive id_lams   ->
    Lam_compile.compile_recursive_lets
      { continuation = EffectCall Not_tail;
        jmp_table = Lam_compile_context.empty_handler_map;
        package_info;
        output_prefix;
        meta
      }
      id_lams
  | Nop lam -> (* TODO: Side effect callls, log and see statistics *)
    Lam_compile.compile_lambda {continuation = EffectCall Not_tail;
                                jmp_table = Lam_compile_context.empty_handler_map;
                                package_info;
                                output_prefix;
                                meta
                               } lam

;;

(* Also need analyze its depenency is pure or not *)
let no_side_effects (rest : Lam_group.t list) : string option =
  List.find_map ~f:(function
    | Lam_group.Single(kind,id,body) ->
      begin
        match kind with
        | Strict | Variable ->
          if not @@ Lam_analysis.no_side_effects body
          then Some  (Printf.sprintf "%s" (Ident.name id))
          else None
        | _ -> None
      end
    | Recursive bindings ->
      List.find_map ~f:(fun (id,lam) ->
        if not @@ Lam_analysis.no_side_effects lam
        then Some (Printf.sprintf "%s" (Ident.name id) )
        else None)
        bindings
    | Nop lam ->
      if not @@ Lam_analysis.no_side_effects lam
      then
        (*  (Lam_util.string_of_lambda lam) *)
        Some ""
      else None (* TODO :*))
    rest


let _d  = fun  s lam ->
#ifndef BS_RELEASE_BUILD
  Lam_dump.dump s lam;
  let loc = Loc.of_pos __POS__ in
  Log.warn ~loc (Pp.textf "START CHECKING PASS %s" s);
  ignore @@ Lam_check.check !Location.input_name lam;
  Log.warn ~loc (Pp.textf "FINISH CHECKING PASS %s" s);
#endif
  lam

let _j = Js_pass_debug.dump

(* Actually simplify_lets is kind of global optimization since it requires you to know whether
    it's used or not
*)
let compile
    ~package_info
    (output_prefix : string)
    (lam : Lambda.lambda)   =
  let export_idents = Translmod.get_export_identifiers() in
  let export_ident_sets = Ident.Set.of_list export_idents in
  (* To make toplevel happy - reentrant for js-demo *)
  let () =
#ifndef BS_RELEASE_BUILD
    List.iter
      ~f:(fun id ->
        Log.warn
          ~loc:(Loc.of_pos __POS__)
          (Pp.textf "export idents: %s/%d"  (Ident.name id) (Ident.stamp id)))
      export_idents ;
#endif
    Lam_compile_env.reset () ;
  in
  let lam, may_required_modules = Lam_convert.convert export_ident_sets lam in


  let lam = _d "initial"  lam in
  let lam  = Lam_pass_deep_flatten.deep_flatten lam in
  let lam = _d  "flatten0" lam in
  let meta  : Lam_stats.t =
    Lam_stats.make
      ~export_idents
      ~export_ident_sets in
  let () = Lam_pass_collect.collect_info meta lam in
  let lam =
    let lam =
      lam
      |> _d "flatten1"
      |>  Lam_pass_exits.simplify_exits
      |> _d "simplyf_exits"
      |> (fun lam -> Lam_pass_collect.collect_info meta lam;
#ifndef BS_RELEASE_BUILD
      let () =
        Log.warn ~loc:(Loc.of_pos __POS__)
          (Pp.concat
            [ (Pp.verbatim "Before simplify_alias: ")
            ; Lam_stats.print meta
            ; Pp.newline])
      in
#endif
      lam)
      |>  Lam_pass_remove_alias.simplify_alias  meta
      |> _d "simplify_alias"
      |> Lam_pass_deep_flatten.deep_flatten
      |> _d  "flatten2"
    in  (* Inling happens*)

    let ()  = Lam_pass_collect.collect_info meta lam in
    let lam = Lam_pass_remove_alias.simplify_alias meta lam  in
    let lam = Lam_pass_deep_flatten.deep_flatten lam in
    let ()  = Lam_pass_collect.collect_info meta lam in
    let lam =
      lam
      |> _d "alpha_before"
      |> Lam_pass_alpha_conversion.alpha_conversion meta
      |> _d "alpha_after"
      |> Lam_pass_exits.simplify_exits in
    let () = Lam_pass_collect.collect_info meta lam in


    lam
    |> _d "simplify_alias_before"
    |>  Lam_pass_remove_alias.simplify_alias meta
    |> _d "alpha_conversion"
    |>  Lam_pass_alpha_conversion.alpha_conversion meta
    |> _d  "before-simplify_lets"
    (* we should investigate a better way to put different passes : )*)
    |> Lam_pass_lets_dce.simplify_lets

    |> _d "before-simplify-exits"
    (* |> (fun lam -> Lam_pass_collect.collect_info meta lam
       ; Lam_pass_remove_alias.simplify_alias meta lam) *)
    |> Lam_pass_exits.simplify_exits
    |> _d "simplify_lets"
#ifndef BS_RELEASE_BUILD
    |> (fun lam ->
         Log.warn
           ~loc:(Loc.of_pos __POS__)
           (Pp.concat
             [ Pp.verbatim "Before coercion:"
             ; Lam_stats.print meta
             ; Pp.newline
             ]);
         Lam_check.check !Location.input_name lam)
#endif
  in

  let ({Lam_coercion.groups = groups ; _} as coerced_input , meta) =
    Lam_coercion.coerce_and_group_big_lambda  meta lam
  in

#ifndef BS_RELEASE_BUILD
let () =
  Log.warn ~loc:(Loc.of_pos __POS__)
    (Pp.concat
      [ Pp.verbatim "After coercion: "
      ; Lam_stats.print meta
      ; Pp.newline
      ]);
  if !Js_config.diagnose then
    let f =
      Filename.new_extension !Location.input_name  ".lambda" in
      let chan = open_out_bin f in
      Fun.protect
        ~finally:(fun () -> close_out chan)
        (fun () ->
          let fmt = Format.formatter_of_out_channel chan in
          Format.pp_print_list ~pp_sep:Format.pp_print_newline
            Lam_group.pp_group fmt (coerced_input.groups);
          Format.pp_print_flush fmt ())

in
#endif
let maybe_pure = no_side_effects groups in
#ifndef BS_RELEASE_BUILD
let () =
  Log.warn ~loc:(Loc.of_pos __POS__)
    (Pp.textf "[TIME:] Pre-compile: %f" (Sys.time () *. 1000.))
in
#endif
let body  =
  groups
  |> List.map ~f:(fun group -> compile_group ~package_info output_prefix meta group)
  |> Js_output.concat
  |> Js_output.output_as_block
in
#ifndef BS_RELEASE_BUILD
let () =
  Log.warn ~loc:(Loc.of_pos __POS__)
    (Pp.textf "[TIME:]Post-compile: %f"  (Sys.time () *. 1000.))
in
#endif
let meta_exports = meta.exports in
let export_set = Ident.Set.of_list meta_exports in
let js : J.program =
  {
    exports = meta_exports ;
    export_set;
    block = body}
in
js
|> _j "initial"
|> Js_pass_flatten.program
|> _j "flatten"
|> Js_pass_tailcall_inline.tailcall_inline
|> _j "inline_and_shake"
|> Js_pass_flatten_and_mark_dead.program
|> _j "flatten_and_mark_dead"
|> Js_pass_scope.program
|> Js_shake.shake_program
|> _j "shake"
|> ( fun (program:  J.program) ->
    let external_module_ids : Lam_module_ident.t list =
      if !Js_config.all_module_aliases then []
      else
        let hard_deps =
          Js_fold_basic.calculate_hard_dependencies program.block
        in
        Lam_compile_env.populate_required_modules may_required_modules hard_deps;
        let module_ids =
          let arr =
            Lam_module_ident.Hash_set.to_list hard_deps
            |> Array.of_list
          in
          Array.sort
            ~cmp:(fun id1 id2 ->
              String.compare (Lam_module_ident.name id1) (Lam_module_ident.name id2))
            arr;
          Array.to_list arr
        in
        module_ids
    in
    Warnings.check_fatal();
    let effect =
      Lam_stats_export.get_dependent_module_effect
        maybe_pure external_module_ids in
    let delayed_program = {
      J.program = program ;
      side_effect = effect ;
      preamble = !Js_config.preamble;
      modules = external_module_ids
    }
    in
    let case =
      Js_packages_info.module_case
        ~output_prefix
        package_info
    in
    let cmj : Js_cmj_format.t =
      Lam_stats_export.export_to_cmj
        ~case
        ~delayed_program
        meta
        effect
        coerced_input.export_map
    in
    (if not !Clflags.dont_write_files then
       Js_cmj_format.to_file (Artifact_extension.append_extension output_prefix Cmj) cmj);
    delayed_program
  )
;;

let write_to_file ~package_info ~output_info ~output_prefix lambda_output file  =
  let oc = open_out_bin file in
  Fun.protect
    ~finally:(fun () -> close_out oc)
    (fun () ->
      Js_dump_program.dump_deps_program
        ~package_info
        ~output_info
        ~output_prefix
        lambda_output
        oc)

let lambda_as_module =
  let (//) = Path.(//) in
  fun ~package_info (lambda_output : J.deps_program) (output_prefix : string) ->
    let make_basename suffix =
      (Filename.basename output_prefix) ^ (Js_suffix.to_string suffix)
    in
    match (!Js_config.js_stdout, !Clflags.output_name) with
    | (true, None) ->
      Js_dump_program.dump_deps_program
        ~package_info
        ~output_info:Js_packages_info.default_output_info
        ~output_prefix
        lambda_output stdout
    | false, None ->
      raise (Arg.Bad ("no output specified (use -o <filename>.js)"))
    | (_, Some _) ->
      (* We use `-mel-module-type` to emit a single JS file after `.cmj`
         generation. In this case, we don't want the `package_info` from the
         `.cmj`, because the suffix and paths will be different. *)
      List.iter ~f:(fun (output_info : Js_packages_info.output_info) ->
        let basename = make_basename output_info.suffix in
        let target_file = Filename.dirname output_prefix // basename in
        if not !Clflags.dont_write_files then begin
          write_to_file
            ~package_info
            ~output_info
            ~output_prefix
            lambda_output
            target_file
        end)
        (Js_packages_state.get_output_info ())

(* We can use {!Env.current_unit = "Pervasives"} to tell if it is some specific module,
   We need handle some definitions in standard libraries in a special way, most are io specific,
   includes {!Pervasives.stdin, Pervasives.stdout, Pervasives.stderr}

   However, use filename instead of {!Env.current_unit} is more honest, since
   Node.js module system is coupled with the file name
*)
