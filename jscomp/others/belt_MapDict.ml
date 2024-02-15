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

module N = Belt_internalAVLtree
module A = Belt_Array

type ('key, 'a, 'id) t = ('key, 'a) N.t
type ('key, 'id) cmp = ('key, 'id) Belt_Id.cmp

let empty = None
let fromArray = N.fromArray
let isEmpty = N.isEmpty
let cmp = N.cmp
let cmpU = N.cmpU
let eq = N.eq
let eqU = N.eqU
let has = N.has
let forEach = N.forEach
let forEachU = N.forEachU
let reduce = N.reduce
let reduceU = N.reduceU
let every = N.every
let everyU = N.everyU
let some = N.some
let someU = N.someU
let size = N.size
let toList = N.toList
let toArray = N.toArray
let keysToArray = N.keysToArray
let valuesToArray = N.valuesToArray
let minimum = N.minimum
let maximum = N.maximum
let minKey = N.minKey
let maxKey = N.maxKey
let minKeyUndefined = N.minKeyUndefined
let maxKeyUndefined = N.maxKeyUndefined
let minUndefined = N.minUndefined
let maxUndefined = N.maxUndefined
let get = N.get
let getUndefined = N.getUndefined
let getWithDefault = N.getWithDefault
let getExn = N.getExn
let mapWithKey = N.mapWithKey
let mapWithKeyU = N.mapWithKeyU
let mapU = N.mapU
let map = N.map
let keep = N.keepShared
let keepU = N.keepSharedU
let partitionU = N.partitionSharedU
let partition = N.partitionShared
let checkInvariantInternal = N.checkInvariantInternal

let rec set (t : _ t) newK newD ~cmp =
  match t with
  | None -> N.singleton newK newD
  | Some n ->
      let k = n.N.key in
      let c = ((Belt_Id.getCmpInternal cmp) newK k [@u]) in
      if c = 0 then Some (N.updateValue n newD)
      else
        let l, r, v = (n.N.left, n.N.right, n.N.value) in
        if c < 0 then
          (* Worth optimize for reference equality? *)
          N.bal (set ~cmp l newK newD) k v r
        else N.bal l k v (set ~cmp r newK newD)

let rec updateU (t : _ t) newK f ~cmp : _ t =
  match t with
  | None -> (
      match f None [@u] with None -> t | Some newD -> N.singleton newK newD)
  | Some n ->
      let k = n.N.key in
      let c = ((Belt_Id.getCmpInternal cmp) newK k [@u]) in
      if c = 0 then
        match f (Some n.N.value) [@u] with
        | None -> (
            let l, r = (n.N.left, n.N.right) in
            match (l, r) with
            | None, _ -> r
            | _, None -> l
            | _, Some rn ->
                let kr, vr = (ref rn.key, ref rn.value) in
                let r = N.removeMinAuxWithRef rn kr vr in
                N.bal l kr.contents vr.contents r)
        | Some newD -> Some (N.updateValue n newD)
      else
        let l, r, v = (n.N.left, n.N.right, n.N.value) in
        if c < 0 then
          let ll = updateU ~cmp l newK f in
          if l == ll then t else N.bal ll k v r
        else
          let rr = updateU ~cmp r newK f in
          if r == rr then t else N.bal l k v rr

let update t newK f ~cmp = updateU t newK (fun [@u] a -> f a) ~cmp

(* unboxing API was not exported
   since the correct API is really awkard
   [bool -> 'k Js.null -> ('a Js.null * bool)]
   even for specialized [k] the first [bool] can
   be erased, maybe the perf boost does not justify the inclusion of such API

   [updateWithNull m x f]
   the callback to [f exist v]
   when [v] is non-null,
   [exist] is guaranteed to be true
   [v] is guranteed to be [null],
   when [exist] is [true], [v] could be [null],
   since ['a] is polymorphic
*)

let rec removeAux0 n x ~cmp =
  let { N.left = l; key = v; right = r; _ } = n in
  let c = ((Belt_Id.getCmpInternal cmp) x v [@u]) in
  if c = 0 then
    match (l, r) with
    | None, _ -> r
    | _, None -> l
    | _, Some rn ->
        let kr, vr = (ref rn.key, ref rn.value) in
        let r = N.removeMinAuxWithRef rn kr vr in
        N.bal l kr.contents vr.contents r
  else if c < 0 then
    match l with
    | None -> Some n (* Nothing to remove *)
    | Some left ->
        let ll = removeAux0 left x ~cmp in
        if ll == l then Some n else N.bal ll v n.N.value r
  else
    match r with
    | None -> Some n (* Nothing to remove *)
    | Some right ->
        let rr = removeAux0 ~cmp right x in
        if rr == r then Some n else N.bal l v n.N.value rr

let remove n x ~cmp =
  match n with None -> None | Some n -> removeAux0 n x ~cmp

let mergeMany h arr ~cmp =
  let len = A.length arr in
  let v = ref h in
  for i = 0 to len - 1 do
    let key, value = A.getUnsafe arr i in
    v.contents <- set v.contents ~cmp key value
  done;
  v.contents

let rec splitAuxPivot n x pres ~cmp =
  let { N.left = l; key = v; value = d; right = r; _ } = n in
  let c = ((Belt_Id.getCmpInternal cmp) x v [@u]) in
  if c = 0 then (
    pres.contents <- Some d;
    (l, r))
  else if c < 0 then
    match l with
    | None -> (None, Some n)
    | Some l ->
        let ll, rl = splitAuxPivot ~cmp l x pres in
        (ll, N.join rl v d r)
  else
    match r with
    | None -> (Some n, None)
    | Some r ->
        let lr, rr = splitAuxPivot ~cmp r x pres in
        (N.join l v d lr, rr)

let split n x ~cmp =
  match n with
  | None -> ((None, None), None)
  | Some n ->
      let pres = ref None in
      let v = splitAuxPivot ~cmp n x pres in
      (v, pres.contents)

let findFirstByU = N.findFirstByU
let findFirstBy = N.findFirstBy

let rec mergeU s1 s2 f ~cmp =
  match (s1, s2) with
  | None, None -> None
  | Some _, None -> N.keepMapU s1 (fun [@u] k v -> (f k (Some v) None [@u]))
  | None, Some _ -> N.keepMapU s2 (fun [@u] k v -> (f k None (Some v) [@u]))
  | Some s1n, Some s2n ->
      if s1n.height >= s2n.height then
        let { N.left = l1; key = v1; value = d1; right = r1; _ } = s1n in
        let d2 = ref None in
        let l2, r2 = splitAuxPivot ~cmp s2n v1 d2 in
        let d2 = d2.contents in
        let newLeft = mergeU ~cmp l1 l2 f in
        let newD = (f v1 (Some d1) d2 [@u]) in
        let newRight = mergeU ~cmp r1 r2 f in
        N.concatOrJoin newLeft v1 newD newRight
      else
        let { N.left = l2; key = v2; value = d2; right = r2; _ } = s2n in
        let d1 = ref None in
        let l1, r1 = splitAuxPivot ~cmp s1n v2 d1 in
        let d1 = d1.contents in
        let newLeft = mergeU ~cmp l1 l2 f in
        let newD = (f v2 d1 (Some d2) [@u]) in
        let newRight = mergeU ~cmp r1 r2 f in
        N.concatOrJoin newLeft v2 newD newRight

let merge s1 s2 f ~cmp = mergeU s1 s2 (fun [@u] a b c -> f a b c) ~cmp

let rec removeMany0 t xs i len ~cmp =
  if i < len then
    let ele = A.getUnsafe xs i in
    let u = removeAux0 t ele ~cmp in
    match u with None -> u | Some t -> removeMany0 t xs (i + 1) len ~cmp
  else Some t

let removeMany t keys ~cmp =
  let len = A.length keys in
  match t with None -> None | Some t -> removeMany0 t keys 0 len ~cmp
