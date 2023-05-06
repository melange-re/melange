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

(** Extension to the standard library [String] module, fixed some bugs like
    avoiding locale sensitivity *)

(** default is false *)
val split_by : ?keep_empty:bool -> (char -> bool) -> string -> string list


(** default is false *)
val split : ?keep_empty:bool -> string -> char -> string list

val starts_with : string -> string -> bool

val ends_with : string -> string -> bool
val ends_with_char : string -> char -> bool

(**
  [ends_with_then_chop name ext]
  @example:
   {[
     ends_with_then_chop "a.cmj" ".cmj"
     "a"
   ]}
   This is useful in controlled or file case sensitve system
*)
val ends_with_then_chop : string -> string -> string option




(**
  [for_all_from  s start p]
  if [start] is negative, it raises,
  if [start] is too large, it returns true
*)
val for_all_from:
  string ->
  int ->
  (char -> bool) ->
  bool

val for_all :
  string ->
  (char -> bool) ->
  bool

val is_empty : string -> bool

val equal : string -> string -> bool

val rfind : sub:string -> string -> int

(** [tail_from s 1]
  return a substring from offset 1 (inclusive)
*)
val tail_from : string -> int -> string


(** returns negative number if not found *)
val rindex_neg : string -> char -> int

(** if no conversion happens, reference equality holds *)
val replace_slash_backward : string -> string

(** if no conversion happens, reference equality holds *)
val replace_backward_slash : string -> string

val empty : string

#if defined BS_BROWSER
val compare :  string -> string -> int
#else
external compare : string -> string -> int = "caml_string_length_based_compare" [@@noalloc];;
#endif

val parent_dir_lit : string
val current_dir_lit : string

val capitalize_ascii : string -> string

val capitalize_sub:
  string ->
  int ->
  string

val uncapitalize_ascii : string -> string

val lowercase_ascii : string -> string

val first_marshal_char:
  string ->
  bool

val fold_left : ('a -> char -> 'a) -> 'a -> string -> 'a
