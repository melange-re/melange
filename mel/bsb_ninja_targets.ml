(* Copyright (C) 2015 - 2016 Bloomberg Finance L.P.
 * Copyright (C) 2017 - Hongbo Zhang, Authors of ReScript
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

let enabled_if = Format.asprintf "(enabled_if %%{bin-available:melc})"
let dune_header = ";;;;{BSB GENERATED: NO EDIT"
let dune_trailer = ";;;;BSB GENERATED: NO EDIT}"
let dune_trailer_length = String.length dune_trailer

(** [new_content] should start end finish with newline *)
let revise_dune dune new_content =
  if Sys.file_exists dune then
    let s = Ext_io.load_file dune in
    let header = Ext_string.find s ~sub:dune_header in
    let tail = Ext_string.find s ~sub:dune_trailer in
    if header < 0 && tail < 0 then (
      (* locked region not added yet *)
      let ochan = open_out_bin dune in
      output_string ochan s;
      output_string ochan "\n";
      output_string ochan dune_header;
      Buffer.output_buffer ochan new_content;
      output_string ochan dune_trailer;
      output_string ochan "\n";
      close_out ochan)
    else if header >= 0 && tail >= 0 then (
      (* there is one, hit it everytime,
         should be fixed point
      *)
      let ochan = open_out_bin dune in
      output_string ochan (String.sub s 0 header);
      output_string ochan dune_header;
      Buffer.output_buffer ochan new_content;
      output_string ochan dune_trailer;
      output_string ochan (Ext_string.tail_from s (tail + dune_trailer_length));
      close_out ochan)
    else
      failwith
        "the dune file is corrupted, locked region by bsb is not consistent "
  else
    let ochan = open_out_bin dune in
    output_string ochan dune_header;
    Buffer.output_buffer ochan new_content;
    output_string ochan dune_trailer;
    output_string ochan "\n";
    close_out ochan

let output_alias ?action oc ~name ~deps =
  (match action with
  | Some action ->
      output_string oc "\n(rule (alias ";
      output_string oc name;
      output_string oc ")\n (action ";
      output_string oc action
  | None ->
      output_string oc "\n(alias (name ";
      output_string oc name);
  output_string oc ")";
  if deps <> [] then (
    output_string oc "(deps ";
    Ext_list.iter deps (fun x ->
        output_string oc Ext_string.single_space;
        output_string oc (Filename.basename x));
    output_string oc ")");
  output_char oc '\n';
  output_string oc enabled_if;
  output_string oc ")"

let output_build ?(implicit_deps = []) ?(rel_deps = []) ?(bs_dependencies = [])
    ?alias ?(implicit_outputs = []) ?(js_outputs = []) ~outputs ~inputs
    ~(rule : Mel_rule.fn) oc =
  let just_js_outputs = List.map fst js_outputs in
  output_string oc "(rule\n(targets ";
  Ext_list.iter outputs (fun s ->
      output_string oc Ext_string.single_space;
      output_string oc (Filename.basename s));
  if implicit_outputs <> [] || js_outputs <> [] then
    Ext_list.iter (implicit_outputs @ just_js_outputs) (fun s ->
        output_string oc Ext_string.single_space;
        output_string oc (Filename.basename s));
  output_string oc ")\n ";
  Option.iter
    (fun alias ->
      output_string oc "(alias ";
      output_string oc alias;
      output_string oc ")\n ")
    alias;
  let in_source_outputs =
    List.filter_map
      (fun (js, in_source) -> if in_source then Some js else None)
      js_outputs
  in
  if in_source_outputs <> [] then (
    output_string oc "(mode (promote (until-clean) (only";
    Ext_list.iter in_source_outputs (fun s ->
        output_string oc Ext_string.single_space;
        output_string oc (Filename.basename s));
    output_string oc ")))");
  output_string oc "(deps (:inputs ";
  Ext_list.iter inputs (fun s ->
      output_string oc Ext_string.single_space;
      output_string oc s);
  output_string oc ") ";
  if implicit_deps <> [] then
    Ext_list.iter implicit_deps (fun s ->
        output_string oc Ext_string.single_space;
        output_string oc s);
  Ext_list.iter rel_deps (fun s ->
      output_string oc Ext_string.single_space;
      output_string oc s);
  if bs_dependencies <> [] then
    Ext_list.iter bs_dependencies (fun dir ->
        output_string oc "(alias ";
        output_string oc dir;
        output_string oc ")");
  output_string oc ")";
  output_string oc "\n";
  rule
    ~target:
      (String.concat Ext_string.single_space
         (Ext_list.map outputs Filename.basename))
    oc;
  output_char oc '\n';
  output_string oc enabled_if;
  output_string oc " )\n "
