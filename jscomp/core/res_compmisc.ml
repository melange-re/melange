(* Copyright (C) 2015-2020 Hongbo Zhang, Authors of ReScript
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

let init_path () =
  let dirs = !Clflags.include_dirs in
  let exp_dirs =
    List.map (Misc.expand_directory Config.standard_library) dirs
  in
  Load_path.reset ();
  List.iter Load_path.add_dir
    (List.rev (Lazy.force Js_config.stdlib_path :: exp_dirs));
  Env.reset_cache ()

(* Return the initial environment in which compilation proceeds. *)

(* Note: do not do init_path() in initial_env, this breaks
   toplevel initialization (PR#1775) *)

let[@ocaml.warning "-3"] open_implicit_module m env =
  let lid =
    { Asttypes.loc = Location.in_file "command line"; txt = Longident.parse m }
  in
  snd
    (!Typeclass.type_open_descr env
       {
         popen_expr = lid;
         popen_override = Override;
         popen_loc = lid.loc;
         popen_attributes = [];
       })

let initial_env () =
  Ident.reinit ();
  let initial = Env.initial_safe_string in
  let env =
    if !Clflags.nopervasives then initial
    else open_implicit_module "Stdlib" initial
  in
  List.fold_left
    (fun env m -> open_implicit_module m env)
    env
    (List.rev !Clflags.open_modules)
