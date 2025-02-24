(* Copyright (C) 2017 Hongbo Zhang, Authors of ReScript
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

 [@@@mel.config { flags = [|"--mel-no-cross-module-opt" |]}]
(* Internals of forcing lazy values. *)

type 'a t = 'a lazy_t

type 'a concrete = {
  mutable tag : bool [@mel.as "LAZY_DONE"] ;
  (* Invariant: name  *)
  mutable value : 'a [@mel.as "VAL"]
  (* its type is ['a] or [unit -> 'a ] *)
}

exception Undefined

external fnToVal : (unit -> 'a [@u]) -> 'a = "%identity"
external valToFn :  'a -> (unit -> 'a [@u])  = "%identity"
external castToConcrete : 'a lazy_t -> 'a concrete   = "%identity"
external of_concrete : 'a concrete -> 'a lazy_t   = "%identity"

let is_val (type a ) (l : a lazy_t) : bool =
  (castToConcrete l ).tag



let forward_with_closure (type a ) (blk : a concrete) (closure : unit -> a [@u]) : a =
  let result = closure () [@u] in
  blk.value <- result;
  blk.tag<- true;
  result


let raise_undefined =  (fun [@u] () -> raise Undefined)

(* Assume [blk] is a block with tag lazy *)
let force_lazy_block (type a ) (blk : a t) : a  =
  let blk = castToConcrete blk in
  let closure = valToFn blk.value in
  blk.value <- fnToVal raise_undefined;
  try
    forward_with_closure blk closure
  with e ->
    blk.value <- fnToVal (fun [@u] () -> raise e);
    raise e


(* Assume [blk] is a block with tag lazy *)
let force_val_lazy_block (type a ) (blk : a t) : a  =
  let blk = castToConcrete blk in
  let closure  = valToFn blk.value  in
  blk.value <-  fnToVal raise_undefined;
  forward_with_closure blk closure

(* [force] is not used, since [Lazy.force] is declared as a primitive
   whose code inlines the tag tests of its argument, except when afl
   instrumentation is turned on. *)

let force (type a ) (lzv : a lazy_t) : a =
  (* Using [Sys.opaque_identity] prevents two potential problems:
     - If the value is known to have Forward_tag, then its tag could have
       changed during GC, so that information must be forgotten (see GPR#713
       and issue #7301)
     - If the value is known to be immutable, then if the compiler
       cannot prove that the last branch is not taken it will issue a
       warning 59 (modification of an immutable value) *)
  let lzv = Sys.opaque_identity (castToConcrete lzv : _ concrete) in
  if lzv.tag  then lzv.value else
    force_lazy_block (of_concrete lzv)

let force_val (type a) (lzv : a lazy_t) : a =
  let lzv : _ concrete = castToConcrete lzv in
  if lzv.tag then lzv.value  else
    force_val_lazy_block (of_concrete lzv)
