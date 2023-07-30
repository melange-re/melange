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

open Melange_mini_stdlib

let stdin = Caml_undefined_extern.empty
(* let stderr = Caml_undefined_extern.empty *)

open struct
  module Js = Js_internal
end

type out_channel  = {
  mutable buffer :  string;
  output :   (out_channel  -> string -> unit [@u])
}

let stdout = {
  buffer = "";
  output = (fun [@u] _ s ->
      let module String = Caml_string_extern in
      let v =Caml_string_extern.length s - 1 in
      if [%mel.raw{| (typeof process !== "undefined") && process.stdout && process.stdout.write|}] then
        ([%mel.raw{| process.stdout.write |} ] : string -> unit [@u]) s [@u]
      else
      if s.[v] = '\n' then
        Js_internal.log (Caml_string_extern.slice s 0 v)
      else Js_internal.log s)
}

let stderr = {
  buffer = "";
  output = fun [@u] _ s ->
    let module String = Caml_string_extern in
    let v =Caml_string_extern.length s - 1 in
    if s.[v] = '\n' then
      Js_internal.log (Caml_string_extern.slice s 0 v) (* TODO: change to Js_internal.error*)
    else Js_internal.log s
}

#if false
type in_channel

let caml_ml_open_descriptor_in (i : int) : in_channel =
  raise (Failure "caml_ml_open_descriptor_in not implemented")
let caml_ml_open_descriptor_out (i : int)  : out_channel =
  raise (Failure "caml_ml_open_descriptor_out not implemented")
let caml_ml_input (ic : in_channel) (bytes : bytes) offset len : int =
  raise (Failure  "caml_ml_input ic not implemented")
let caml_ml_input_char (ic : in_channel) : char =
  raise  (Failure "caml_ml_input_char not implemnted")

#endif

(*TODO: we need flush all buffers in the end *)
let caml_ml_flush (oc : out_channel)  : unit =
  if oc.buffer  <> "" then
    begin
      oc.output oc oc.buffer [@u];
      oc.buffer <- ""
    end

(*
let node_std_output  : string -> bool =
  [%raw{|function(s){ return (typeof process !== "undefined") && process.stdout && (process.stdout.write(s), true);}
|}]
*)

(** note we need provide both [bytes] and [string] version
*)
let caml_ml_output (oc : out_channel) (str : string) offset len  =
  let str =
    if offset = 0 && len =Caml_string_extern.length str then str
    else Caml_string_extern.slice str offset len in
  if [%raw{| (typeof process !== "undefined") && process.stdout && process.stdout.write |}] &&
     oc == stdout then
    ([%raw{| process.stdout.write |}] : string -> unit [@u] ) str [@u]

  else
    begin

      let id = Caml_string_extern.lastIndexOf str "\n" in
      if id < 0 then
        oc.buffer <- oc.buffer ^ str
      else
        begin
          oc.buffer <- oc.buffer ^ Caml_string_extern.slice str 0 (id +1);
          caml_ml_flush oc;
          oc.buffer <- oc.buffer ^ Caml_string_extern.slice_rest str (id + 1)
        end
    end

let caml_ml_output_char (oc : out_channel)  (char : char) : unit =
  caml_ml_output oc (Caml_string_extern.of_char char) 0 1


let caml_ml_out_channels_list () : out_channel list  =
  [stdout; stderr]
