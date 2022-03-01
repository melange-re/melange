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

(*
let to_file filename v =
  let chan = open_out_bin filename in
  Marshal.to_channel chan v  [];
  close_out chan

(** [bin] mode for WIN support *)
let from_file filename =
  let chan = open_in_bin filename in
  let v = Marshal.from_channel chan in
  close_in chan;
  v  *)

external from_bytes_unsafe : bytes -> int -> 'a = "caml_input_value_from_bytes"

let from_string_uncheck (s : string) =
  let s = Bytes.unsafe_of_string s in
  from_bytes_unsafe s 0
