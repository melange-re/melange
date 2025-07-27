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

let [@inline] min (x :int) y = if x < y then x else y

#if defined TYPE_FUNCTOR
external unsafe_blit :
    'a array -> int -> 'a array -> int -> int -> unit = "caml_array_blit"
module Make ( Resize :  Vec_gen.ResizeType) = struct
  type elt = Resize.t

  let null = Resize.null

#elif defined TYPE_INT

type elt = int
let null = 0 (* can be optimized *)
let unsafe_blit = Stdlib.Array.blit
#else
[%error "unknown type"]
#endif

external unsafe_sub : 'a array -> int -> int -> 'a array = "caml_array_sub"

type  t = {
  mutable arr : elt array ;
  mutable len : int ;
}

let length d = d.len

let compact d =
  let d_arr = d.arr in
  if d.len <> Stdlib.Array.length d_arr then
    begin
      let newarr = unsafe_sub d_arr 0 d.len in
      d.arr <- newarr
    end
let singleton v =
  {
    len = 1 ;
    arr = [|v|]
  }

let empty () =
  {
    len = 0;
    arr = [||];
  }

let is_empty d =
  d.len = 0

let reset d =
  d.len <- 0;
  d.arr <- [||]


(* For [to_*] operations, we should be careful to call {!Array.*} function
   in case we operate on the whole array
*)
let to_list d =
  let rec loop (d_arr : elt array) idx accum =
    if idx < 0 then accum else loop d_arr (idx - 1) (Stdlib.Array.unsafe_get d_arr idx :: accum)
  in
  loop d.arr (d.len - 1) []

let of_list lst =
  let arr = Stdlib.Array.of_list lst in
  { arr ; len = Stdlib.Array.length arr}


let to_array d =
  unsafe_sub d.arr 0 d.len

let of_array src =
  {
    len = Stdlib.Array.length src;
    arr = Stdlib.Array.copy src;
    (* okay to call {!Stdlib.Array.copy}*)
  }
let of_sub_array arr ~off ~len =
  {
    len = len ;
    arr = Stdlib.Array.sub arr off len
  }
let unsafe_internal_array v = v.arr
(* we can not call {!Stdlib.Array.copy} *)
let copy src =
  let len = src.len in
  {
    len ;
    arr = unsafe_sub src.arr 0 len ;
  }

(* FIXME *)
let reverse_in_place src =
  Array.reverse_range src.arr 0 src.len




(* {!Stdlib.Array.sub} is not enough for error checking, it
   may contain some garbage
 *)
let sub (src : t) ~off:start ~len =
  let src_len = src.len in
  if len < 0 || start > src_len - len then invalid_arg "Vec.sub"
  else
  { len ;
    arr = unsafe_sub src.arr start len }

let iter ~f d =
  let arr = d.arr in
  for i = 0 to d.len - 1 do
    f (Stdlib.Array.unsafe_get arr i)
  done

let iteri ~f d =
  let arr = d.arr in
  for i = 0 to d.len - 1 do
    f i (Stdlib.Array.unsafe_get arr i)
  done

let iter_range ~from ~to_ ~f d =
  if from < 0 || to_ >= d.len then invalid_arg "Vec.iter_range"
  else
    let d_arr = d.arr in
    for i = from to to_ do
      f  (Stdlib.Array.unsafe_get d_arr i)
    done

let iteri_range ~from ~to_ ~f d =
  if from < 0 || to_ >= d.len then invalid_arg "Vec.iteri_range"
  else
    let d_arr = d.arr in
    for i = from to to_ do
      f i (Stdlib.Array.unsafe_get d_arr i)
    done

let map_into_array ~f src =
  let src_len = src.len in
  let src_arr = src.arr in
  if src_len = 0 then [||]
  else
    let first_one = f (Stdlib.Array.unsafe_get src_arr 0) in
    let arr = Stdlib.Array.make  src_len  first_one in
    for i = 1 to src_len - 1 do
      Stdlib.Array.unsafe_set arr i (f (Stdlib.Array.unsafe_get src_arr i))
    done;
    arr

let map_into_list ~f src =
  let src_len = src.len in
  let src_arr = src.arr in
  if src_len = 0 then []
  else
    let acc = ref [] in
    for i =  src_len - 1 downto 0 do
      acc := f (Stdlib.Array.unsafe_get src_arr i) :: !acc
    done;
    !acc

let mapi ~f src =
  let len = src.len in
  if len = 0 then { len ; arr = [| |] }
  else
    let src_arr = src.arr in
    let arr = Stdlib.Array.make len (Stdlib.Array.unsafe_get src_arr 0) in
    for i = 1 to len - 1 do
      Stdlib.Array.unsafe_set arr i (f i (Stdlib.Array.unsafe_get src_arr i))
    done;
    {
      len ;
      arr ;
    }

let fold_left ~f ~init:x a =
  let rec loop a_len (a_arr : elt array) idx x =
    if idx >= a_len then x else
      loop a_len a_arr (idx + 1) (f x (Stdlib.Array.unsafe_get a_arr idx))
  in
  loop a.len a.arr 0 x

let fold_right ~f a ~init:x =
  let rec loop (a_arr : elt array) idx x =
    if idx < 0 then x
    else loop a_arr (idx - 1) (f (Stdlib.Array.unsafe_get a_arr idx) x)
  in
  loop a.arr (a.len - 1) x

(**
   [filter] and [inplace_filter]
*)
let filter ~f d =
  let new_d = copy d in
  let new_d_arr = new_d.arr in
  let d_arr = d.arr in
  let p = ref 0 in
  for i = 0 to d.len  - 1 do
    let x = Stdlib.Array.unsafe_get d_arr i in
    (* TODO: can be optimized for segments blit *)
    if f x  then
      begin
        Stdlib.Array.unsafe_set new_d_arr !p x;
        incr p;
      end;
  done;
  new_d.len <- !p;
  new_d

let equal ~f:eq x y : bool =
  if x.len <> y.len then false
  else
    let rec aux x_arr y_arr i =
      if i < 0 then true else
      if eq (Stdlib.Array.unsafe_get x_arr i) (Stdlib.Array.unsafe_get y_arr i) then
        aux x_arr y_arr (i - 1)
      else false in
    aux x.arr y.arr (x.len - 1)

let get d i =
  if i < 0 || i >= d.len then invalid_arg "Vec.get"
  else Stdlib.Array.unsafe_get d.arr i
let unsafe_get d i = Stdlib.Array.unsafe_get d.arr i
let last d =
  if d.len <= 0 then invalid_arg   "Vec.last"
  else Stdlib.Array.unsafe_get d.arr (d.len - 1)

let capacity d = Stdlib.Array.length d.arr

(* Attention can not use {!Stdlib.Array.exists} since the bound is not the same *)
let exists ~f:p d =
  let a = d.arr in
  let n = d.len in
  let rec loop i =
    if i = n then false
    else if p (Stdlib.Array.unsafe_get a i) then true
    else loop (succ i) in
  loop 0

let map ~f src =
  let src_len = src.len in
  if src_len = 0 then { len = 0 ; arr = [||]}
  (* TODO: we may share the empty array
     but sharing mutable state is very challenging,
     the tricky part is to avoid mutating the immutable array,
     here it looks fine --
     invariant: whenever [.arr] mutated, make sure  it is not an empty array
     Actually no: since starting from an empty array
     {[
       push v (* the address of v should not be changed *)
     ]}
  *)
  else
    let src_arr = src.arr in
    let first = f (Stdlib.Array.unsafe_get src_arr 0 ) in
    let arr = Stdlib.Array.make  src_len first in
    for i = 1 to src_len - 1 do
      Stdlib.Array.unsafe_set arr i (f (Stdlib.Array.unsafe_get src_arr i))
    done;
    {
      len = src_len;
      arr = arr;
    }

let init len ~f =
  if len < 0 then invalid_arg  "Vec.init"
  else if len = 0 then { len = 0 ; arr = [||] }
  else
    let first = f 0 in
    let arr = Stdlib.Array.make len first in
    for i = 1 to len - 1 do
      Stdlib.Array.unsafe_set arr i (f i)
    done;
    {

      len ;
      arr
    }

  let make initsize : t =
    if initsize < 0 then invalid_arg  "Vec.make" ;
    {

      len = 0;
      arr = Stdlib.Array.make  initsize null ;
    }

  let reserve (d : t ) s =
    let d_len = d.len in
    let d_arr = d.arr in
    if s < d_len || s < Stdlib.Array.length d_arr then ()
    else
      let new_capacity = min Sys.max_array_length s in
      let new_d_arr = Stdlib.Array.make new_capacity null in
       unsafe_blit d_arr 0 new_d_arr 0 d_len;
      d.arr <- new_d_arr

  let push (d : t) v  =
    let d_len = d.len in
    let d_arr = d.arr in
    let d_arr_len = Stdlib.Array.length d_arr in
    if d_arr_len = 0 then
      begin
        d.len <- 1 ;
        d.arr <- [| v |]
      end
    else
      begin
        if d_len = d_arr_len then
          begin
            if d_len >= Sys.max_array_length then
              failwith "exceeds max_array_length";
            let new_capacity = min Sys.max_array_length d_len * 2
            (* [d_len] can not be zero, so [*2] will enlarge   *)
            in
            let new_d_arr = Stdlib.Array.make new_capacity null in
            d.arr <- new_d_arr;
             unsafe_blit d_arr 0 new_d_arr 0 d_len ;
          end;
        d.len <- d_len + 1;
        Stdlib.Array.unsafe_set d.arr d_len v
      end

(** delete element at offset [idx], will raise exception when have invalid input *)
  let delete (d : t) idx =
    let d_len = d.len in
    if idx < 0 || idx >= d_len then invalid_arg "Vec.delete" ;
    let arr = d.arr in
     unsafe_blit arr (idx + 1) arr idx  (d_len - idx - 1);
    let idx = d_len - 1 in
    d.len <- idx
#ifdef TYPE_INT
#else
    ;
    Stdlib.Array.unsafe_set arr idx  null
#endif

(** pop the last element, a specialized version of [delete] *)
  let pop (d : t) =
    let idx  = d.len - 1  in
    if idx < 0 then invalid_arg "Vec.pop";
    d.len <- idx
#ifdef TYPE_INT
#else
    ;
    Stdlib.Array.unsafe_set d.arr idx null
#endif

(** pop and return the last element *)
  let get_last_and_pop (d : t) =
    let idx  = d.len - 1  in
    if idx < 0 then invalid_arg "Vec.get_last_and_pop";
    let last = Stdlib.Array.unsafe_get d.arr idx in
    d.len <- idx
#ifdef TYPE_INT
#else
    ;
    Stdlib.Array.unsafe_set d.arr idx null
#endif
    ;
    last

(** delete elements start from [idx] with length [len] *)
  let delete_range (d : t) idx len =
    let d_len = d.len in
    if len < 0 || idx < 0 || idx + len > d_len then invalid_arg  "Vec.delete_range"  ;
    let arr = d.arr in
     unsafe_blit arr (idx + len) arr idx (d_len  - idx - len);
    d.len <- d_len - len
#ifdef TYPE_INT
#else
    ;
    for i = d_len - len to d_len - 1 do
      Stdlib.Array.unsafe_set arr i null
    done
#endif

(** delete elements from [idx] with length [len] return the deleted elements as a new vec*)
  let get_and_delete_range (d : t) idx len : t =
    let d_len = d.len in
    if len < 0 || idx < 0 || idx + len > d_len then invalid_arg  "Vec.get_and_delete_range"  ;
    let arr = d.arr in
    let value =  unsafe_sub arr idx len in
     unsafe_blit arr (idx + len) arr idx (d_len  - idx - len);
    d.len <- d_len - len;
#ifdef TYPE_INT
#else
    for i = d_len - len to d_len - 1 do
      Stdlib.Array.unsafe_set arr i null
    done;
#endif
    {len = len ; arr = value}


  (** Below are simple wrapper around normal Array operations *)

  let clear (d : t ) =
#ifdef TYPE_INT
#else
    for i = 0 to d.len - 1 do
      Stdlib.Array.unsafe_set d.arr i null
    done;
#endif
    d.len <- 0

  let inplace_filter ~f (d : t) : unit =
    let d_arr = d.arr in
    let d_len = d.len in
    let p = ref 0 in
    for i = 0 to d_len - 1 do
      let x = Stdlib.Array.unsafe_get d_arr i in
      if f x then
        begin
          let curr_p = !p in
          (if curr_p <> i then
             Stdlib.Array.unsafe_set d_arr curr_p x) ;
          incr p
        end
    done ;
    let last = !p  in
#ifdef TYPE_INT
    d.len <-  last
    (* INT , there is not need to reset it, since it will cause GC behavior *)
#else
    delete_range d last  (d_len - last)
#endif

  let inplace_filter_from ~from:start ~f (d : t) : unit =
    if start < 0 then invalid_arg "Vec.inplace_filter_from";
    let d_arr = d.arr in
    let d_len = d.len in
    let p = ref start in
    for i = start to d_len - 1 do
      let x = Stdlib.Array.unsafe_get d_arr i in
      if f x then
        begin
          let curr_p = !p in
          (if curr_p <> i then
             Stdlib.Array.unsafe_set d_arr curr_p x) ;
          incr p
        end
    done ;
    let last = !p  in
#ifdef TYPE_INT
    d.len <-  last
#else
    delete_range d last  (d_len - last)
#endif


(** inplace filter the elements and accumulate the non-filtered elements *)
  let inplace_filter_with ~f ~cb_no ~init:acc (d : t)  =
    let d_arr = d.arr in
    let p = ref 0 in
    let d_len = d.len in
    let acc = ref acc in
    for i = 0 to d_len - 1 do
      let x = Stdlib.Array.unsafe_get d_arr i in
      if f x then
        begin
          let curr_p = !p in
          (if curr_p <> i then
             Stdlib.Array.unsafe_set d_arr curr_p x) ;
          incr p
        end
      else
        acc := cb_no  x  !acc
    done ;
    let last = !p  in
#ifdef TYPE_INT
    d.len <-  last
    (* INT , there is not need to reset it, since it will cause GC behavior *)
#else
    delete_range d last  (d_len - last)
#endif
    ; !acc

#ifdef TYPE_INT
let mem =
  let rec unsafe_mem_aux arr i (key : int) bound =
    if i <= bound then
      if Stdlib.Array.unsafe_get arr i = (key : int) then true
      else unsafe_mem_aux arr (i + 1) key bound
    else false
  in
  fun key (x : t) ->
    let internal_array = unsafe_internal_array x in
    let len = length x in
    unsafe_mem_aux internal_array 0 key (len - 1)
#endif

#ifdef TYPE_FUNCTOR
end
#endif
