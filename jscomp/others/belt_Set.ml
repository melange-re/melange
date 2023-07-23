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

module Int = Belt_SetInt
module String = Belt_SetString
module Dict = Belt_SetDict

type ('value, 'id) id = ('value, 'id) Belt_Id.comparable
type ('value, 'id) cmp = ('value, 'id) Belt_Id.cmp
type ('value, 'id) t = { cmp : ('value, 'id) cmp; data : ('value, 'id) Dict.t }

let fromArray (type value identity) data ~(id : (value, identity) id) =
  let module M = (val id) in
  let cmp = M.cmp in
  { cmp; data = Dict.fromArray ~cmp data }

let remove m e =
  let { cmp; data } = m in
  let newData = Dict.remove ~cmp data e in
  if newData == data then m else { cmp; data = newData }

let add m e =
  let { cmp; data } = m in
  let newData = Dict.add ~cmp data e in
  if newData == data then m else { cmp; data = newData }

let mergeMany ({ cmp; _ } as m) e = { cmp; data = Dict.mergeMany ~cmp m.data e }

let removeMany ({ cmp; _ } as m) e =
  { cmp; data = Dict.removeMany ~cmp m.data e }

let union ({ cmp; _ } as m) n = { data = Dict.union ~cmp m.data n.data; cmp }

let intersect m n =
  let cmp = m.cmp in
  { data = Dict.intersect ~cmp m.data n.data; cmp }

let diff m n =
  let cmp = m.cmp in
  { cmp; data = Dict.diff ~cmp m.data n.data }

let subset m n =
  let cmp = m.cmp in
  Dict.subset ~cmp m.data n.data

let split m e =
  let cmp = m.cmp in
  let (l, r), b = Dict.split ~cmp m.data e in
  (({ cmp; data = l }, { cmp; data = r }), b)

let make (type value identity) ~(id : (value, identity) id) =
  let module M = (val id) in
  { cmp = M.cmp; data = Dict.empty }

let isEmpty m = Dict.isEmpty m.data

let cmp m n =
  let cmp = m.cmp in
  Dict.cmp ~cmp m.data n.data

let eq m n = Dict.eq ~cmp:m.cmp m.data n.data
let forEachU m f = Dict.forEachU m.data f
let forEach m f = forEachU m (fun [@u] a -> f a)
let reduceU m acc f = Dict.reduceU m.data acc f
let reduce m acc f = reduceU m acc (fun [@u] a b -> f a b)
let everyU m f = Dict.everyU m.data f
let every m f = everyU m (fun [@u] a -> f a)
let someU m f = Dict.someU m.data f
let some m f = someU m (fun [@u] a -> f a)
let keepU m f = { cmp = m.cmp; data = Dict.keepU m.data f }
let keep m f = keepU m (fun [@u] a -> f a)

let partitionU m f =
  let l, r = Dict.partitionU m.data f in
  let cmp = m.cmp in
  ({ data = l; cmp }, { data = r; cmp })

let partition m f = partitionU m (fun [@u] a -> f a)
let size m = Dict.size m.data
let toList m = Dict.toList m.data
let toArray m = Dict.toArray m.data
let minimum m = Dict.minimum m.data
let minUndefined m = Dict.minUndefined m.data
let maximum m = Dict.maximum m.data
let maxUndefined m = Dict.maxUndefined m.data
let get m e = Dict.get ~cmp:m.cmp m.data e
let getUndefined m e = Dict.getUndefined ~cmp:m.cmp m.data e
let getExn m e = Dict.getExn ~cmp:m.cmp m.data e
let has m e = Dict.has ~cmp:m.cmp m.data e

let fromSortedArrayUnsafe (type value identity) xs ~(id : (value, identity) id)
    =
  let module M = (val id) in
  { cmp = M.cmp; data = Dict.fromSortedArrayUnsafe xs }

let getData m = m.data

let getId (type value identity) (m : (value, identity) t) : (value, identity) id
    =
  let module T = struct
    type nonrec identity = identity
    type nonrec t = value

    let cmp = m.cmp
  end in
  (module T)

let packIdData (type value identity) ~(id : (value, identity) id) ~data =
  let module M = (val id) in
  { cmp = M.cmp; data }

let checkInvariantInternal d = Dict.checkInvariantInternal d.data
