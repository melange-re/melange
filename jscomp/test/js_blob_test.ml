(* Copyright (C) 2024- Authors of Melange
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

let make_with_options () =
  let blob =
    Js.Blob.make
      (Js.Array.values [|"hello"|])
      ~options:(Js.Blob.options ~type_:"application/json" ())
      ()
  in
  Mt.Eq (Js.Blob.type_ blob, "application/json")
;;

let blob_bytes =
  let module TextDecoder = struct
    type t
    external make : string -> t = "TextDecoder" [@@mel.new]
    external decode : t -> Js.uint8Array -> string = "decode" [@@mel.send]
    let make_utf8 () = make "utf-8"
  end
  in
  let decodeUint8Array: Js.uint8Array -> string = fun b ->
    let decoder = TextDecoder.make_utf8 () in
    TextDecoder.decode decoder b
  in
  fun () ->
    let file =
      Js.File.make
        (Js.Array.values [|"hello"|])
        ~filename:"foo.txt"
        ()
    in
    Js.File.bytes file
    |> Js.Promise.then_ (fun b ->
        Js.Promise.resolve (Mt.Eq (decodeUint8Array b, "hello")))

;;

Mt.from_pair_suites __MODULE__ [
    "make with options", make_with_options;
] ;;

Mt.from_promise_suites __MODULE__
  [
    ("blob bytes", blob_bytes ());
  ]

