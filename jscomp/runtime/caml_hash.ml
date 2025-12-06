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
[@@@mel.config { flags = [| "-mel-noassertfalse" |] }]

type 'a cell = { content : 'a; mutable next : 'a cell option }

and 'a t = {
  mutable length : int;
  mutable first : 'a cell option;
  mutable last : 'a cell option;
}

let create_queue () = { length = 0; first = None; last = None }

(* Added to tail *)
let push_back (q : 'a t) (v : 'a) =
  let cell = Some { content = v; next = None } in
  match q.last with
  | None ->
      q.length <- 1;
      q.first <- cell;
      q.last <- cell
  | Some last ->
      q.length <- q.length + 1;
      last.next <- cell;
      q.last <- cell

let is_empty_queue q = q.length = 0

(* pop from front *)

let unsafe_pop (q : 'a t) =
  match q.first with
  | None -> assert false
  | Some cell ->
      let next = cell.next in
      (match next with
      | None ->
          q.length <- 0;
          q.first <- None;
          q.last <- None
      | Some _ ->
          q.length <- q.length - 1;
          q.first <- next);
      cell.content

let caml_hash_mix_int = Caml_hash_primitive.caml_hash_mix_int
let caml_hash_final_mix = Caml_hash_primitive.caml_hash_final_mix
let caml_hash_mix_string = Caml_hash_primitive.caml_hash_mix_string

let caml_hash (count : int) _limit (seed : int) (obj : Obj.t) : int =
  let hash = ref seed in
  match Js.typeof obj with
  | "number" ->
      let u = Caml_nativeint_extern.of_float (Obj.magic obj) in
      hash.contents <- caml_hash_mix_int hash.contents (u + u + 1);
      caml_hash_final_mix hash.contents
  | "string" ->
      hash.contents <-
        caml_hash_mix_string hash.contents (Obj.magic obj : string);
      caml_hash_final_mix hash.contents
  | _ ->
      (* TODO: hash [null] [undefined] as well *)
      let queue = create_queue () in
      let num = ref count in
      let () =
        push_back queue obj;
        num.contents <- num.contents - 1
      in
      while (not (is_empty_queue queue)) && num.contents > 0 do
        let obj = unsafe_pop queue in
        match Js.typeof obj with
        | "number" ->
            let u = Caml_nativeint_extern.of_float (Obj.magic obj) in
            hash.contents <- caml_hash_mix_int hash.contents (u + u + 1);
            num.contents <- num.contents - 1
        | "string" ->
            hash.contents <-
              caml_hash_mix_string hash.contents (Obj.magic obj : string);
            num.contents <- num.contents - 1
        | "boolean" ->
            let u =
              match (Obj.magic obj : bool) with false -> 0 | true -> 1
            in
            hash.contents <- caml_hash_mix_int hash.contents (u + u + 1);
            num.contents <- num.contents - 1
        | "undefined" | "symbol" | "function" -> ()
        | _ ->
            let size = Obj.size obj in
            if size <> 0 then
              let obj_tag = Obj.tag obj in
              let tag = (size lsl 10) lor obj_tag in
              if obj_tag = 248 (* Obj.object_tag*) then
                hash.contents <-
                  caml_hash_mix_int hash.contents
                    (Obj.obj (Obj.field obj 1) : int)
              else (
                hash.contents <- caml_hash_mix_int hash.contents tag;
                let block =
                  let v = size - 1 in
                  if v < num.contents then v else num.contents
                in
                for i = 0 to block do
                  push_back queue (Obj.field obj i)
                done)
            else
              let size : int =
                ([%raw
                   {|function(obj,cb){
            var size = 0
            for(var k in obj){
              cb(obj[k])
              ++ size
            }
            return size
          }|}]
               obj (fun[@u] v -> push_back queue v)
            [@u])
          in
          hash.contents <- caml_hash_mix_int hash.contents ((size lsl 10) lor 0)
      (*tag*)
    done;
    caml_hash_final_mix hash.contents

let caml_string_hash (seed : int) (s : string) : int =
  let h = caml_hash_mix_string seed s in
  let h = caml_hash_final_mix h in
  h land 0x3FFFFFFF
