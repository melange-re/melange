(* Copyright (C) 2019 - Present Hongbo Zhang, Authors of ReScript
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

open! Ext

let bsbuild_cache = Literals.bsbuild_cache


let nl buf =
  Ext_buffer.add_char buf '\n'



(* IDEAS:
  Pros:
    - could be even shortened to a single byte
  Cons:
    - decode would allocate
    - code too verbose
    - not readable
 *)

let make_encoding length buf : Ext_buffer.t -> int -> unit =
  let max_range = length lsl 1 + 1 in
  if max_range <= 0xff then begin
    Ext_buffer.add_char buf '1';
    Ext_buffer.add_int_1
  end
  else if max_range <= 0xff_ff then begin
    Ext_buffer.add_char buf '2';
    Ext_buffer.add_int_2
  end
  else if length <= 0x7f_ff_ff then begin
    Ext_buffer.add_char buf '3';
    Ext_buffer.add_int_3
  end
  else if length <= 0x7f_ff_ff_ff then begin
    Ext_buffer.add_char buf '4';
    Ext_buffer.add_int_4
  end else assert false

(* Make sure [tmp_buf1] and [tmp_buf2] is cleared ,
  they are only used to control the order.
  Strictly speaking, [tmp_buf1] is not needed
*)
let encode_single (db : Bsb_db.map) (buf : Ext_buffer.t) =
  (* module name section *)
  let len = Map_string.cardinal db in
  if len = 0 then begin
    Ext_buffer.add_string_char buf (string_of_int len) '\n';
  end else begin
    let mapping = Hash_string.create 50 in
    (* Pre-processing step because the DB must be sorted with
       `Ext_string.compare`, which is not equal to String.compare (the former
       sorts based the length of the string). *)
    let modules = Map_string.fold db Map_string.empty (fun name {dir; case} acc ->
        match dir with
        | Same dir -> Map_string.add acc name (dir, case)
        | Different { impl; intf } ->
          let acc = Map_string.add acc (name ^ Literals.suffix_impl) (impl, case) in
          Map_string.add acc (name ^ Literals.suffix_intf) (intf, case))
    in
    Ext_buffer.add_string_char buf (string_of_int (Map_string.cardinal modules)) '\n';
    Map_string.iter modules (fun name (dir, _) ->
      Ext_buffer.add_string_char buf name '\n';
      if not (Hash_string.mem mapping dir) then
        Hash_string.add mapping dir (Hash_string.length mapping));
    let length = Hash_string.length mapping in
    let rev_mapping = Array.make length "" in
    Hash_string.iter mapping (fun k i -> Array.unsafe_set rev_mapping i k);
    (* directory name section *)
    Ext_array.iter rev_mapping (fun s -> Ext_buffer.add_string_char buf s '\t');
    nl buf; (* module name info section *)
    let len_encoding = make_encoding length buf in
    Map_string.iter modules (fun _ (dir, case) ->
      len_encoding buf
        (Hash_string.find_exn  mapping dir  lsl 1 + (Obj.magic (case : bool) : int)));
    nl buf
  end

let encode (dbs : Bsb_db.t) buf =
  encode_single dbs.lib buf;
  encode_single dbs.dev buf


(*  shall we avoid writing such file (checking the digest)?
  It is expensive to start scanning the whole code base,
  we should we avoid it in the first place, if we do start scanning,
  this operation seems affordable
 *)
let write_build_cache ~proj_dir (bs_files : Bsb_db.t)  : unit =
  let lib_artifacts_dir = Bsb_config.lib_bs in
  let oc = open_out_bin Ext_path.(proj_dir // lib_artifacts_dir // bsbuild_cache) in
  let buf = Ext_buffer.create 100_000 in
  encode bs_files buf;
  Ext_buffer.output_buffer oc buf;
  close_out oc
