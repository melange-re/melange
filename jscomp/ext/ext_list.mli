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

val map_combine : 'a list -> 'b list -> ('a -> 'c) -> ('c * 'b) list
val combine_array : 'a array -> 'b list -> ('a -> 'c) -> ('c * 'b) list

val combine_array_append :
  'a array -> 'b list -> ('c * 'b) list -> ('a -> 'c) -> ('c * 'b) list

val map_snd : ('a * 'b) list -> ('b -> 'c) -> ('a * 'c) list

val map_last : 'a list -> (bool -> 'a -> 'b) -> 'b list
(** [map_last f xs ]
    will pass [true] to [f] for the last element,
    [false] otherwise.
    For empty list, it returns empty
*)

val append_one : 'a list -> 'a -> 'a list

val fold_right3 :
  'a list -> 'b list -> 'c list -> 'd -> ('a -> 'b -> 'c -> 'd -> 'd) -> 'd

val fold_left_with_offset :
  'a list -> 'acc -> int -> ('a -> 'acc -> int -> 'acc) -> 'acc

val exclude_with_val : 'a list -> ('a -> bool) -> 'a list option
(** [excludes p l]
    return a tuple [excluded,newl]
    where [exluded] is true indicates that at least one
    element is removed,[newl] is the new list where all [p x] for [x] is false

*)

val same_length : 'a list -> 'b list -> bool

val split_at : 'a list -> int -> 'a list * 'a list
(** [split_at n l]
    will split [l] into two lists [a,b], [a] will be of length [n],
    otherwise, it will raise
*)

val split_at_last : 'a list -> 'a list * 'a
(** [split_at_last l]
    It is equivalent to [split_at (List.length l - 1) l ]
*)

val filter_mapi : 'a list -> ('a -> int -> 'b option) -> 'b list
val length_ge : 'a list -> int -> bool

(**

   {[length xs = length ys + n ]}
   input n should be positive
   TODO: input checking
*)

val length_larger_than_n : 'a list -> 'a list -> int -> bool

val stable_group : 'a list -> ('a -> 'a -> bool) -> 'a list list
(**
    [stable_group eq lst]
    Example:
    Input:
   {[
     stable_group (=) [1;2;3;4;3]
   ]}
    Output:
   {[
     [[1];[2];[4];[3;3]]
   ]}
    TODO: this is O(n^2) behavior
    which could be improved later
*)

val find_first_not : 'a list -> ('a -> bool) -> 'a option
(** [find_first_not p lst ]
    if all elements in [lst] pass, return [None]
    otherwise return the first element [e] as [Some e] which
    fails the predicate
*)

(** [find_opt f l] returns [None] if all return [None],
    otherwise returns the first one.
*)

val find_opt : 'a list -> ('a -> 'b option) -> 'b option
val find_def : 'a list -> ('a -> 'b option) -> 'b -> 'b
val rev_iter : 'a list -> ('a -> unit) -> unit
val for_all_snd : ('a * 'b) list -> ('b -> bool) -> bool

val for_all2_no_exn : 'a list -> 'b list -> ('a -> 'b -> bool) -> bool
(** [for_all2_no_exn p xs ys]
    return [true] if all satisfied,
    [false] otherwise or length not equal
*)

val split_map : 'a list -> ('a -> 'b * 'c) -> 'b list * 'c list
(** [f] is applied follow the list order *)

val reduce_from_left : 'a list -> ('a -> 'a -> 'a) -> 'a
(** [fn] is applied from left to right *)

val sort_via_array : 'a list -> ('a -> 'a -> int) -> 'a list
val sort_via_arrayf : 'a list -> ('a -> 'a -> int) -> ('a -> 'b) -> 'b list

val assoc_by_string : (string * 'a) list -> string -> 'a option -> 'a
(** [assoc_by_string default key lst]
    if  [key] is found in the list  return that val,
    other unbox the [default],
    otherwise [assert false ]
*)

val assoc_by_int : (int * 'a) list -> int -> 'a option -> 'a
val concat_append : 'a list list -> 'a list -> 'a list
