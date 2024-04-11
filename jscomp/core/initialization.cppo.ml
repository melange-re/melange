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

module Global = struct
  let run () =
    Translcore.wrap_single_field_record :=
      Transl_single_field_record.wrap_single_field_record;
    Translmod.eval_rec_bindings := Compile_rec_module.eval_rec_bindings;
    Translmod.mangle_ident := Compile_rec_module.mangle_ident;
    Typemod.should_hide := Typemod_hide.should_hide;
    Matching.make_test_sequence_variant_constant :=
      Polyvar_pattern_match.make_test_sequence_variant_constant;
    Matching.call_switcher_variant_constant :=
      Polyvar_pattern_match.call_switcher_variant_constant;
    Matching.call_switcher_variant_constr :=
      Polyvar_pattern_match.call_switcher_variant_constr;
    Clflags.no_std_include := true (* `-nostdlib` *);
    ignore @@ Warnings.parse_options false Melc_warnings.defaults_w;
    ignore @@ Warnings.parse_options true Melc_warnings.defaults_warn_error;
    Clflags.locations := false;
    Clflags.compile_only := true;
    Config.unsafe_empty_array := false;
    Config.bs_only := true;
    Clflags.color := Some Always;
    (* default true
       otherwise [bsc -I sc src/hello.ml ] will include current directory to search path
    *)
    Clflags.debug := true;
    Bs_clflags.record_event_when_debug := false;
    Clflags.binary_annotations := true;
    Clflags.strict_sequence := true;
    Clflags.strict_formats := true;
    (* Turn on [-no-alias-deps] by default -- double check *)
    Builtin_attributes.check_bs_attributes_inclusion :=
      Record_attributes_check.check_mel_attributes_inclusion;
    Builtin_attributes.check_duplicated_labels :=
      Record_attributes_check.check_duplicated_labels;
    Lambda.fld_record := Record_attributes_check.fld_record;
    Lambda.fld_record_set := Record_attributes_check.fld_record_set;
    Lambda.fld_record_inline := Record_attributes_check.fld_record_inline;
    Lambda.fld_record_inline_set :=
      Record_attributes_check.fld_record_inline_set;
    Lambda.fld_record_extension := Record_attributes_check.fld_record_extension;
    Lambda.fld_record_extension_set :=
      Record_attributes_check.fld_record_extension_set;
    Lambda.blk_record := Record_attributes_check.blk_record;
    Lambda.blk_record_inlined := Record_attributes_check.blk_record_inlined;
    Lambda.blk_record_ext := Record_attributes_check.blk_record_ext;
    Matching.names_from_construct_pattern :=
      Matching_polyfill.names_from_construct_pattern;
#if OCAML_VERSION >= (5,2,0)
    Value_rec_compiler.compile_letrec := Compile_letrec.compile_letrec
#endif
  ;;

  let () = at_exit (fun _ -> Format.pp_print_flush Format.err_formatter ())
end

module Perfile = struct
  let init_path () =
    let dirs = !Clflags.include_dirs in
    let exp_dirs =
      List.map ~f:(Misc.expand_directory Config.standard_library) dirs
    in
    Load_path.reset ();
    let exp_dirs = List.rev_append exp_dirs (Js_config.std_include_dirs ()) in
    List.iter
#if OCAML_VERSION >= (5,2,0)
      ~f:(Load_path.add_dir ~hidden:false)
#else
      ~f:(Load_path.add_dir)
#endif
      exp_dirs;
    let
#if OCAML_VERSION >= (5,2,0)
      { Load_path.visible; hidden }
#else
      visible
#endif
     = Load_path.get_paths ()
    in
    Log.info ~loc:(Loc.of_pos __POS__)
      (Pp.concat ~sep:Pp.space
         [
           Pp.text "Compiler include dirs:";
           Pp.enumerate visible ~f:Pp.text;
#if OCAML_VERSION >= (5,2,0)
      Pp.enumerate hidden ~f:Pp.text;
#endif
         ]);
    Env.reset_cache ()

  (* Return the initial environment in which compilation proceeds. *)

  (* Note: do not do init_path() in initial_env, this breaks
     toplevel initialization (PR#1775) *)

  let initial_env () =
    Ident.reinit ();
    Types.Uid.reinit ();
    let initially_opened_module =
      if !Clflags.nopervasives then None else Some "Stdlib"
    in
    Typemod.initial_env
      ~loc:(Location.in_file "command line")
      ~initially_opened_module
#if OCAML_VERSION < (5,0,0)
      ~safe_string:true
#endif
      ~open_implicit_modules:(List.rev !Clflags.open_modules)
end

(* ATTENTION: lazy to wait [Config.load_path] populated *)
let find_in_path_exn file =
#if OCAML_VERSION >= (5,2,0)
  Misc.find_in_path_normalized (Load_path.get_paths ()).visible
#else
  Misc.find_in_path_uncap (Load_path.get_paths ())
#endif
  file
