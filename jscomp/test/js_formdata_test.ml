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

let form_data_append () =
  let fd = Js.FormData.make () in
  Js.FormData.append ~name:"a" ~value:(`String "foo") fd;
  Js.FormData.append ~name:"b" ~value:(`String "bar") fd;
  Mt.Eq ((Js.FormData.get ~name:"a" fd |> Option.get |> Obj.magic), "foo")
;;

let form_data_not_found () =
  let fd = Js.FormData.make () in
  Mt.Eq (Js.FormData.get fd ~name:"doesn't exist", None)
;;

let form_data_append_blob () =
  let fd = Js.FormData.make () in
  let blob = Js.Blob.make (Js.Array.values [|"hello"|]) () in
  Js.FormData.appendBlob ~name:"b" ~value:(`Blob blob) ~filename:"foo.txt" fd;
  let got_blob: Js.Blob.t =
    Js.FormData.get ~name:"b" fd |> Option.get |> Obj.magic
  in
  Js.Blob.text got_blob |> Js.Promise.then_ (fun x ->
    Js.Promise.resolve (Mt.Eq (x, "hello"))
  )
;;

let form_data_append_file () =
  let fd = Js.FormData.make () in
  let file = Js.File.make (Js.Array.values [|"hello"|]) ~filename:"foo.txt" () in
  Js.FormData.appendBlob ~name:"b" ~value:(`File file) ~filename:"foo.txt" fd;
  let got_file: Js.Blob.t =
    Js.FormData.get ~name:"b" fd |> Option.get |> Obj.magic
  in
  Js.Blob.text got_file |> Js.Promise.then_ (fun x ->
    Js.Promise.resolve (Mt.Eq (x, "hello"))
  )
;;

;; Mt.from_pair_suites __MODULE__ [
    "append", form_data_append;
    "not found", form_data_not_found
]

;;

Mt.from_promise_suites __MODULE__
  [
    ("append blob", form_data_append_blob ());
    ("append file", form_data_append_file ());
  ]

