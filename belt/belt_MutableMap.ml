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

module Int = Belt_MutableMapInt
module String = Belt_MutableMapString
module N = Belt_internalAVLtree
module A = Belt_Array

type ('key, 'id) id = ('key, 'id) Belt_Id.comparable
type ('key, 'id) cmp = ('key, 'id) Belt_Id.cmp
type ('k, 'v, 'id) t = { cmp : ('k, 'id) cmp; mutable data : ('k, 'v) N.t }

let rec removeMutateAux nt x ~cmp =
  let k = nt.N.key in
  let c = ((Belt_Id.getCmpInternal cmp) x k [@u]) in
  if c = 0 then
    let { N.left = l; right = r; _ } = nt in
    match (l, r) with
    | Some _, Some nr ->
        nt.right <- N.removeMinAuxWithRootMutate nt nr;
        Some (N.balMutate nt)
    | None, Some _ -> r
    | (Some _ | None), None -> l
  else if c < 0 then (
    match nt.N.left with
    | None -> Some nt
    | Some l ->
        nt.left <- removeMutateAux ~cmp l x;
        Some (N.balMutate nt))
  else
    match nt.right with
    | None -> Some nt
    | Some r ->
        nt.right <- removeMutateAux ~cmp r x;
        Some (N.balMutate nt)

let remove d k =
  let oldRoot = d.data in
  match oldRoot with
  | None -> ()
  | Some oldRoot2 ->
      let newRoot = removeMutateAux ~cmp:d.cmp oldRoot2 k in
      if newRoot != oldRoot then d.data <- newRoot

let rec removeArrayMutateAux t xs i len ~cmp =
  if i < len then
    let ele = A.getUnsafe xs i in
    let u = removeMutateAux t ele ~cmp in
    match u with
    | None -> None
    | Some t -> removeArrayMutateAux t xs (i + 1) len ~cmp
  else Some t

let removeMany d xs =
  let oldRoot = d.data in
  match oldRoot with
  | None -> ()
  | Some nt ->
      let len = A.length xs in
      let newRoot = removeArrayMutateAux nt xs 0 len ~cmp:d.cmp in
      if newRoot != oldRoot then d.data <- newRoot

let rec updateDone t x f ~cmp =
  match t with
  | None -> (
      match f None [@u] with Some data -> N.singleton x data | None -> t)
  | Some nt ->
      let k = nt.N.key in
      let c = ((Belt_Id.getCmpInternal cmp) x k [@u]) in
      if c = 0 then (
        match f (Some nt.value) [@u] with
        | None -> (
            let { N.left = l; right = r; _ } = nt in
            match (l, r) with
            | Some _, Some nr ->
                nt.right <- N.removeMinAuxWithRootMutate nt nr;
                Some (N.balMutate nt)
            | None, Some _ -> r
            | (Some _ | None), None -> l)
        | Some data ->
            nt.value <- data;
            Some nt)
      else (
        if c < 0 then nt.left <- updateDone nt.left x f ~cmp
        else nt.right <- updateDone nt.right x f ~cmp;
        Some (N.balMutate nt))

let updateU t x f =
  let oldRoot = t.data in
  let newRoot = updateDone oldRoot x f ~cmp:t.cmp in
  if newRoot != oldRoot then t.data <- newRoot

let update t x f = updateU t x (fun [@u] a -> f a)

let make (type key identity) ~(id : (key, identity) id) =
  let module M = (val id) in
  { cmp = M.cmp; data = None }

let clear m = m.data <- None
let isEmpty d = N.isEmpty d.data
let minKey m = N.minKey m.data
let minKeyUndefined m = N.minKeyUndefined m.data
let maxKey m = N.maxKey m.data
let maxKeyUndefined m = N.maxKeyUndefined m.data
let minimum m = N.minimum m.data
let minUndefined m = N.minUndefined m.data
let maximum m = N.maximum m.data
let maxUndefined m = N.maxUndefined m.data
let forEachU d f = N.forEachU d.data f
let forEach d f = forEachU d (fun [@u] a b -> f a b)
let reduceU d acc cb = N.reduceU d.data acc cb
let reduce d acc cb = reduceU d acc (fun [@u] a b c -> cb a b c)
let everyU d p = N.everyU d.data p
let every d p = everyU d (fun [@u] a b -> p a b)
let someU d p = N.someU d.data p
let some d p = someU d (fun [@u] a b -> p a b)
let size d = N.size d.data
let toList d = N.toList d.data
let toArray d = N.toArray d.data
let keysToArray d = N.keysToArray d.data
let valuesToArray d = N.valuesToArray d.data

(* let fromSortedArrayUnsafe (type key) (type identity) ~(id : (key,identity) id) xs : _ t =
   let module M = (val id) in
   S.t ~data:(N.fromSortedArrayUnsafe xs) ~cmp:M.cmp *)

let checkInvariantInternal d = N.checkInvariantInternal d.data
let cmpU m1 m2 cmp = N.cmpU ~kcmp:m1.cmp ~vcmp:cmp m1.data m2.data
let cmp m1 m2 cmp = cmpU m1 m2 (fun [@u] a b -> cmp a b)
let eqU m1 m2 cmp = N.eqU ~kcmp:m1.cmp ~veq:cmp m1.data m2.data
let eq m1 m2 cmp = eqU m1 m2 (fun [@u] a b -> cmp a b)
let mapU m f = { cmp = m.cmp; data = N.mapU m.data f }
let map m f = mapU m (fun [@u] a -> f a)
let mapWithKeyU m f = { cmp = m.cmp; data = N.mapWithKeyU m.data f }
let mapWithKey m f = mapWithKeyU m (fun [@u] a b -> f a b)
let get m x = N.get ~cmp:m.cmp m.data x
let getUndefined m x = N.getUndefined ~cmp:m.cmp m.data x
let getWithDefault m x def = N.getWithDefault ~cmp:m.cmp m.data x def
let getExn m x = N.getExn ~cmp:m.cmp m.data x
let has m x = N.has ~cmp:m.cmp m.data x

let fromArray (type k identity) data ~(id : (k, identity) id) =
  let module M = (val id) in
  let cmp = M.cmp in
  { cmp; data = N.fromArray ~cmp data }

let set m e v =
  let oldRoot = m.data in
  let newRoot = N.updateMutate ~cmp:m.cmp oldRoot e v in
  if newRoot != oldRoot then m.data <- newRoot

let mergeManyAux t xs ~cmp =
  let v = ref t in
  for i = 0 to A.length xs - 1 do
    let key, value = A.getUnsafe xs i in
    v.contents <- N.updateMutate v.contents key value ~cmp
  done;
  v.contents

let mergeMany d xs =
  let oldRoot = d.data in
  let newRoot = mergeManyAux oldRoot xs ~cmp:d.cmp in
  if newRoot != oldRoot then d.data <- newRoot
