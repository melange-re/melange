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

(*
   perf is not everything, there are better memory represenations
   {[
     type 'a cell = {
       mutable head : 'a;
       mutable tail : 'a opt_cell
     }

     and 'a opt_cell = 'a cell Js.null

     and 'a t = {
       length : int ;
       data : 'a opt_cell
     }
   ]}
   However,
   - people use List not because of its perf, but its
   convenencie, in that case, pattern match and compatibility seems
   more attractive, we could keep a mutable list
   - The built in types would indicate that
     its construtor is immutable, a better optimizer would break such code

   {[
     type 'a t = {
       head : 'a;
       mutable tail : 'a t | int
     }
   ]}
   In the future, we could come up with a safer version
   {[
     type 'a t =
       | Nil
       | Cons of { hd : 'a ; mutable tail : 'a t }
   ]}
*)

[@@@mel.config { flags = [| "-mel-noassertfalse" |] }]

type 'a t = 'a list

module A = Belt_Array

external mutableCell : 'a -> 'a t -> 'a t = "#makemutablelist"

(*
    [mutableCell x []] == [x]
    but tell the compiler that is a mutable cell, so it wont
    be mis-inlined in the future
     dont inline a binding to mutable cell, it is mutable
*)
(* INVARIANT: relies on Literals.tl (internal representation) *)
external unsafeMutateTail : 'a t -> 'a t -> unit = "tl" [@@mel.set]

(*
   - the cell is not empty
*)

let head x = match x with [] -> None | x :: _ -> Some x
let headExn x = match x with [] -> raise Not_found | x :: _ -> x
let tail x = match x with [] -> None | _ :: xs -> Some xs
let tailExn x = match x with [] -> raise Not_found | _ :: t -> t
let add xs x = x :: xs

(* Assume [n >=0] *)
let rec nthAux x n =
  match x with
  | h :: t -> if n = 0 then Some h else nthAux t (n - 1)
  | _ -> None

let rec nthAuxAssert x n =
  match x with
  | h :: t -> if n = 0 then h else nthAuxAssert t (n - 1)
  | _ -> raise Not_found

let get x n = if n < 0 then None else nthAux x n
let getExn x n = if n < 0 then raise Not_found else nthAuxAssert x n

let rec partitionAux p cell precX precY =
  match cell with
  | [] -> ()
  | h :: t ->
      let next = mutableCell h [] in
      if p h [@u] then (
        unsafeMutateTail precX next;
        partitionAux p t next precY)
      else (
        unsafeMutateTail precY next;
        partitionAux p t precX next)

let rec splitAux cell precX precY =
  match cell with
  | [] -> ()
  | (a, b) :: t ->
      let nextA = mutableCell a [] in
      let nextB = mutableCell b [] in
      unsafeMutateTail precX nextA;
      unsafeMutateTail precY nextB;
      splitAux t nextA nextB

(* return the tail pointer so it can continue copy other
   list
*)
let rec copyAuxCont cellX prec =
  match cellX with
  | [] -> prec
  | h :: t ->
      let next = mutableCell h [] in
      unsafeMutateTail prec next;
      copyAuxCont t next

let rec copyAuxWitFilter f cellX prec =
  match cellX with
  | [] -> ()
  | h :: t ->
      if f h [@u] then (
        let next = mutableCell h [] in
        unsafeMutateTail prec next;
        copyAuxWitFilter f t next)
      else copyAuxWitFilter f t prec

let rec copyAuxWithFilterIndex f cellX prec i =
  match cellX with
  | [] -> ()
  | h :: t ->
      if f h i [@u] then (
        let next = mutableCell h [] in
        unsafeMutateTail prec next;
        copyAuxWithFilterIndex f t next (i + 1))
      else copyAuxWithFilterIndex f t prec (i + 1)

let rec copyAuxWitFilterMap f cellX prec =
  match cellX with
  | [] -> ()
  | h :: t -> (
      match f h [@u] with
      | Some h ->
          let next = mutableCell h [] in
          unsafeMutateTail prec next;
          copyAuxWitFilterMap f t next
      | None -> copyAuxWitFilterMap f t prec)

let rec removeAssocAuxWithMap cellX x prec f =
  match cellX with
  | [] -> false
  | ((a, _) as h) :: t ->
      if f a x [@u] then (
        unsafeMutateTail prec t;
        true)
      else
        let next = mutableCell h [] in
        unsafeMutateTail prec next;
        removeAssocAuxWithMap t x next f

let rec setAssocAuxWithMap cellX x k prec eq =
  match cellX with
  | [] -> false
  | ((a, _) as h) :: t ->
      if eq a x [@u] then (
        unsafeMutateTail prec ((x, k) :: t);
        true)
      else
        let next = mutableCell h [] in
        unsafeMutateTail prec next;
        setAssocAuxWithMap t x k next eq

let rec copyAuxWithMap cellX prec f =
  match cellX with
  | [] -> ()
  | h :: t ->
      let next = mutableCell (f h [@u]) [] in
      unsafeMutateTail prec next;
      copyAuxWithMap t next f

let rec zipAux cellX cellY prec =
  match (cellX, cellY) with
  | h1 :: t1, h2 :: t2 ->
      let next = mutableCell (h1, h2) [] in
      unsafeMutateTail prec next;
      zipAux t1 t2 next
  | [], _ | _, [] -> ()

let rec copyAuxWithMap2 f cellX cellY prec =
  match (cellX, cellY) with
  | h1 :: t1, h2 :: t2 ->
      let next = mutableCell (f h1 h2 [@u]) [] in
      unsafeMutateTail prec next;
      copyAuxWithMap2 f t1 t2 next
  | [], _ | _, [] -> ()

let rec copyAuxWithMapI f i cellX prec =
  match cellX with
  | h :: t ->
      let next = mutableCell (f i h [@u]) [] in
      unsafeMutateTail prec next;
      copyAuxWithMapI f (i + 1) t next
  | [] -> ()

let rec takeAux n cell prec =
  if n = 0 then true
  else
    match cell with
    | [] -> false
    | x :: xs ->
        let cell = mutableCell x [] in
        unsafeMutateTail prec cell;
        takeAux (n - 1) xs cell

let rec splitAtAux n cell prec =
  if n = 0 then Some cell
  else
    match cell with
    | [] -> None
    | x :: xs ->
        let cell = mutableCell x [] in
        unsafeMutateTail prec cell;
        splitAtAux (n - 1) xs cell

(* invarint [n >= 0] *)
let take lst n =
  if n < 0 then None
  else if n = 0 then Some []
  else
    match lst with
    | [] -> None
    | x :: xs ->
        let cell = mutableCell x [] in
        let has = takeAux (n - 1) xs cell in
        if has then Some cell else None

(* invariant [n >= 0 ] *)
let rec dropAux l n =
  if n = 0 then Some l
  else match l with _ :: tl -> dropAux tl (n - 1) | [] -> None

let drop lst n = if n < 0 then None else dropAux lst n

let splitAt lst n =
  if n < 0 then None
  else if n = 0 then Some ([], lst)
  else
    match lst with
    | [] -> None
    | x :: xs -> (
        let cell = mutableCell x [] in
        let rest = splitAtAux (n - 1) xs cell in
        match rest with Some rest -> Some (cell, rest) | None -> None)

let concat xs ys =
  match xs with
  | [] -> ys
  | h :: t ->
      let cell = mutableCell h [] in
      unsafeMutateTail (copyAuxCont t cell) ys;
      cell

let mapU xs f =
  match xs with
  | [] -> []
  | h :: t ->
      let cell = mutableCell (f h [@u]) [] in
      copyAuxWithMap t cell f;
      cell

let map xs f = mapU xs (fun [@u] x -> f x)

let zipByU l1 l2 f =
  match (l1, l2) with
  | a1 :: l1, a2 :: l2 ->
      let cell = mutableCell (f a1 a2 [@u]) [] in
      copyAuxWithMap2 f l1 l2 cell;
      cell
  | [], _ | _, [] -> []

let zipBy l1 l2 f = zipByU l1 l2 (fun [@u] x y -> f x y)

let mapWithIndexU xs f =
  match xs with
  | [] -> []
  | h :: t ->
      let cell = mutableCell (f 0 h [@u]) [] in
      copyAuxWithMapI f 1 t cell;
      cell

let mapWithIndex xs f = mapWithIndexU xs (fun [@u] i x -> f i x)

let makeByU n f =
  if n <= 0 then []
  else
    let headX = mutableCell (f 0 [@u]) [] in
    let cur = ref headX in
    let i = ref 1 in
    while i.contents < n do
      let v = mutableCell (f i.contents [@u]) [] in
      unsafeMutateTail cur.contents v;
      cur.contents <- v;
      i.contents <- i.contents + 1
    done;
    headX

let makeBy n f = makeByU n (fun [@u] x -> f x)

let make (type a) n (v : a) : a list =
  if n <= 0 then []
  else
    let headX = mutableCell v [] in
    let cur = ref headX in
    let i = ref 1 in
    while i.contents < n do
      let v = mutableCell v [] in
      unsafeMutateTail cur.contents v;
      cur.contents <- v;
      i.contents <- i.contents + 1
    done;
    headX

let rec lengthAux x acc =
  match x with [] -> acc | _ :: t -> lengthAux t (acc + 1)

let length xs = lengthAux xs 0
let size = length

let rec fillAux arr i x =
  match x with
  | [] -> ()
  | h :: t ->
      A.setUnsafe arr i h;
      fillAux arr (i + 1) t

let rec fromArrayAux a i res =
  if i < 0 then res else fromArrayAux a (i - 1) (A.getUnsafe a i :: res)

let fromArray a = fromArrayAux a (A.length a - 1) []

let toArray (x : _ t) =
  let len = length x in
  let arr = A.makeUninitializedUnsafe len in
  fillAux arr 0 x;
  arr

let shuffle xs =
  let v = toArray xs in
  A.shuffleInPlace v;
  fromArray v

(* let rec fillAuxMap arr i x f =
   match x with
   | [] -> ()
   | h::t ->
     A.setUnsafe arr i (f h [@u]) ;
     fillAuxMap arr (i + 1) t f *)

(* module J = Js_json *)
(* type json = J.t  *)
(* let toJson x f =    *)
(*   let len = length x in *)
(*   let arr = Belt_Array.makeUninitializedUnsafe len in *)
(*   fillAuxMap arr 0 x f; *)
(*   J.array arr *)

(* TODO: best practice about raising excpetion
   1. raise OCaml exception, no stacktrace
   2. raise JS exception, how to pattern match
*)

let rec reverseConcat l1 l2 =
  match l1 with [] -> l2 | a :: l -> reverseConcat l (a :: l2)

let reverse l = reverseConcat l []

let rec flattenAux prec xs =
  match xs with
  | [] -> unsafeMutateTail prec []
  | h :: r -> flattenAux (copyAuxCont h prec) r

let rec flatten xs =
  match xs with
  | [] -> []
  | [] :: xs -> flatten xs
  | (h :: t) :: r ->
      let cell = mutableCell h [] in
      flattenAux (copyAuxCont t cell) r;
      cell

let concatMany xs =
  match xs with
  | [||] -> []
  | [| x |] -> x
  | _ ->
      let len = A.length xs in
      let v = ref (A.getUnsafe xs (len - 1)) in
      for i = len - 2 downto 0 do
        v.contents <- concat (A.getUnsafe xs i) v.contents
      done;
      v.contents

let rec mapRevAux f accu xs =
  match xs with [] -> accu | a :: l -> mapRevAux f ((f a [@u]) :: accu) l

let mapReverseU l f = mapRevAux f [] l
let mapReverse l f = mapReverseU l (fun [@u] x -> f x)

let rec forEachU xs f =
  match xs with
  | [] -> ()
  | a :: l ->
      (f a [@u]) |. ignore;
      forEachU l f

let forEach xs f = forEachU xs (fun [@u] x -> f x)

let rec iteri xs i f =
  match xs with
  | [] -> ()
  | a :: l ->
      (f i a [@u]) |. ignore;
      iteri l (i + 1) f

let forEachWithIndexU l f = iteri l 0 f
let forEachWithIndex l f = forEachWithIndexU l (fun [@u] i x -> f i x)

let rec reduceU l accu f =
  match l with [] -> accu | a :: l -> reduceU l (f accu a [@u]) f

let reduce l accu f = reduceU l accu (fun [@u] acc x -> f acc x)

let rec reduceReverseUnsafeU l accu f =
  match l with [] -> accu | a :: l -> f (reduceReverseUnsafeU l accu f) a [@u]

let reduceReverseU (type a b) (l : a list) (acc : b) f =
  let len = length l in
  if len < 1000 then reduceReverseUnsafeU l acc f
  else A.reduceReverseU (toArray l) acc f

let reduceReverse l accu f = reduceReverseU l accu (fun [@u] a b -> f a b)

let rec reduceWithIndexAuxU l acc f i =
  match l with
  | [] -> acc
  | x :: xs -> reduceWithIndexAuxU xs (f acc x i [@u]) f (i + 1)

let reduceWithIndexU l acc f = reduceWithIndexAuxU l acc f 0

let reduceWithIndex l acc f =
  reduceWithIndexU l acc (fun [@u] acc x i -> f acc x i)

let rec mapRevAux2 l1 l2 accu f =
  match (l1, l2) with
  | a1 :: l1, a2 :: l2 -> mapRevAux2 l1 l2 ((f a1 a2 [@u]) :: accu) f
  | _, [] | [], _ -> accu

let mapReverse2U l1 l2 f = mapRevAux2 l1 l2 [] f
let mapReverse2 l1 l2 f = mapReverse2U l1 l2 (fun [@u] a b -> f a b)

let rec forEach2U l1 l2 f =
  match (l1, l2) with
  | a1 :: l1, a2 :: l2 ->
      (f a1 a2 [@u]) |. ignore;
      forEach2U l1 l2 f
  | [], _ | _, [] -> ()

let forEach2 l1 l2 f = forEach2U l1 l2 (fun [@u] a b -> f a b)

let rec reduce2U l1 l2 accu f =
  match (l1, l2) with
  | a1 :: l1, a2 :: l2 -> reduce2U l1 l2 (f accu a1 a2 [@u]) f
  | [], _ | _, [] -> accu

let reduce2 l1 l2 acc f = reduce2U l1 l2 acc (fun [@u] a b c -> f a b c)

let rec reduceReverse2UnsafeU l1 l2 accu f =
  match (l1, l2) with
  | [], [] -> accu
  | a1 :: l1, a2 :: l2 -> f (reduceReverse2UnsafeU l1 l2 accu f) a1 a2 [@u]
  | _, [] | [], _ -> accu

let reduceReverse2U (type a b c) (l1 : a list) (l2 : b list) (acc : c) f =
  let len = length l1 in
  if len < 1000 then reduceReverse2UnsafeU l1 l2 acc f
  else A.reduceReverse2U (toArray l1) (toArray l2) acc f

let reduceReverse2 l1 l2 acc f =
  reduceReverse2U l1 l2 acc (fun [@u] a b c -> f a b c)

let rec everyU xs p =
  match xs with [] -> true | a :: l -> (p a [@u]) && everyU l p

let every xs p = everyU xs (fun [@u] x -> p x)

let rec someU xs p =
  match xs with [] -> false | a :: l -> (p a [@u]) || someU l p

let some xs p = someU xs (fun [@u] x -> p x)

let rec every2U l1 l2 p =
  match (l1, l2) with
  | _, [] | [], _ -> true
  | a1 :: l1, a2 :: l2 -> (p a1 a2 [@u]) && every2U l1 l2 p

let every2 l1 l2 p = every2U l1 l2 (fun [@u] a b -> p a b)

let rec cmpByLength l1 l2 =
  match (l1, l2) with
  | [], [] -> 0
  | _, [] -> 1
  | [], _ -> -1
  | _ :: l1s, _ :: l2s -> cmpByLength l1s l2s

let rec cmpU l1 l2 p =
  match (l1, l2) with
  | [], [] -> 0
  | _, [] -> 1
  | [], _ -> -1
  | a1 :: l1, a2 :: l2 ->
      let c = (p a1 a2 [@u]) in
      if c = 0 then cmpU l1 l2 p else c

let cmp l1 l2 f = cmpU l1 l2 (fun [@u] x y -> f x y)

let rec eqU l1 l2 p =
  match (l1, l2) with
  | [], [] -> true
  | _, [] | [], _ -> false
  | a1 :: l1, a2 :: l2 -> if p a1 a2 [@u] then eqU l1 l2 p else false

let eq l1 l2 f = eqU l1 l2 (fun [@u] x y -> f x y)

let rec some2U l1 l2 p =
  match (l1, l2) with
  | [], _ | _, [] -> false
  | a1 :: l1, a2 :: l2 -> (p a1 a2 [@u]) || some2U l1 l2 p

let some2 l1 l2 p = some2U l1 l2 (fun [@u] a b -> p a b)

let rec hasU xs x eq =
  match xs with [] -> false | a :: l -> (eq a x [@u]) || hasU l x eq

let has xs x eq = hasU xs x (fun [@u] a b -> eq a b)

let rec getAssocU xs x eq =
  match xs with
  | [] -> None
  | (a, b) :: l -> if eq a x [@u] then Some b else getAssocU l x eq

let getAssoc xs x eq = getAssocU xs x (fun [@u] a b -> eq a b)

let rec hasAssocU xs x eq =
  match xs with [] -> false | (a, _) :: l -> (eq a x [@u]) || hasAssocU l x eq

let hasAssoc xs x eq = hasAssocU xs x (fun [@u] a b -> eq a b)

let removeAssocU xs x eq =
  match xs with
  | [] -> []
  | ((a, _) as pair) :: l ->
      if eq a x [@u] then l
      else
        let cell = mutableCell pair [] in
        let removed = removeAssocAuxWithMap l x cell eq in
        if removed then cell else xs

let removeAssoc xs x eq = removeAssocU xs x (fun [@u] a b -> eq a b)

let setAssocU xs x k eq =
  match xs with
  | [] -> [ (x, k) ]
  | ((a, _) as pair) :: l ->
      if eq a x [@u] then (x, k) :: l
      else
        let cell = mutableCell pair [] in
        let replaced = setAssocAuxWithMap l x k cell eq in
        if replaced then cell else (x, k) :: xs

let setAssoc xs x k eq = setAssocU xs x k (fun [@u] a b -> eq a b)

let sortU xs cmp =
  let arr = toArray xs in
  Belt_SortArray.stableSortInPlaceByU arr cmp;
  fromArray arr

let sort xs cmp = sortU xs (fun [@u] x y -> cmp x y)

let rec getByU xs p =
  match xs with [] -> None | x :: l -> if p x [@u] then Some x else getByU l p

let getBy xs p = getByU xs (fun [@u] a -> p a)

let rec keepU xs p =
  match xs with
  | [] -> []
  | h :: t ->
      if p h [@u] then (
        let cell = mutableCell h [] in
        copyAuxWitFilter p t cell;
        cell)
      else keepU t p

let keep xs p = keepU xs (fun [@u] x -> p x)

let keepWithIndexU xs p =
  let rec auxKeepWithIndex xs p i =
    match xs with
    | [] -> []
    | h :: t ->
        if p h i [@u] then (
          let cell = mutableCell h [] in
          copyAuxWithFilterIndex p t cell (i + 1);
          cell)
        else auxKeepWithIndex t p (i + 1)
  in
  auxKeepWithIndex xs p 0

let keepWithIndex xs p = keepWithIndexU xs (fun [@u] x i -> p x i)

let rec keepMapU xs p =
  match xs with
  | [] -> []
  | h :: t -> (
      match p h [@u] with
      | Some h ->
          let cell = mutableCell h [] in
          copyAuxWitFilterMap p t cell;
          cell
      | None -> keepMapU t p)

let keepMap xs p = keepMapU xs (fun [@u] x -> p x)

let partitionU l p =
  match l with
  | [] -> ([], [])
  | h :: t ->
      let nextX = mutableCell h [] in
      let nextY = mutableCell h [] in
      let b = (p h [@u]) in
      partitionAux p t nextX nextY;
      if b then
        (nextX, match nextY with _ :: tail -> tail | [] -> assert false)
      else ((match nextX with _ :: tail -> tail | [] -> assert false), nextY)

let partition l p = partitionU l (fun [@u] x -> p x)

let unzip xs =
  match xs with
  | [] -> ([], [])
  | (x, y) :: l ->
      let cellX = mutableCell x [] in
      let cellY = mutableCell y [] in
      splitAux l cellX cellY;
      (cellX, cellY)

let zip l1 l2 =
  match (l1, l2) with
  | _, [] | [], _ -> []
  | a1 :: l1, a2 :: l2 ->
      let cell = mutableCell (a1, a2) [] in
      zipAux l1 l2 cell;
      cell
