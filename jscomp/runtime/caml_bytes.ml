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

open Melange_mini_stdlib

external new_uninitialized : int -> bytes = "Array" [@@mel.new]
external ( .![] ) : bytes -> int -> char = "%bytes_unsafe_get"
external ( .![]<- ) : bytes -> int -> char -> unit = "%bytes_unsafe_set"
external length : bytes -> int = "%bytes_length"

let set s i ch =
  if i < 0 || i >= length s then raise (Invalid_argument "index out of bounds")
  else s.![i] <- ch

let get s i =
  if i < 0 || i >= length s then raise (Invalid_argument "index out of bounds")
  else s.![i]

let caml_fill_bytes (s : bytes) i l (c : char) =
  if l > 0 then
    for k = i to l + i - 1 do
      s.![k] <- c
    done

let caml_create_bytes len : bytes =
  (* Node raise [RangeError] exception *)
  if len < 0 then raise (Invalid_argument "String.create")
  else
    let result = new_uninitialized len in
    for i = 0 to len - 1 do
      result.![i] <- '\000'
    done;
    result

(** Same as {!Array.prototype.copyWithin} *)
let copyWithin (s1 : bytes) i1 i2 len =
  if i1 < i2 then
    (* nop for i1 = i2 *)
    let range_a = length s1 - i2 - 1 in
    let range_b = len - 1 in
    let range = if range_a > range_b then range_b else range_a in
    for j = range downto 0 do
      s1.![i2 + j] <- s1.![i1 + j]
    done
  else if i1 > i2 then
    let range_a = length s1 - i1 - 1 in
    let range_b = len - 1 in
    let range = if range_a > range_b then range_b else range_a in
    for k = 0 to range do
      s1.![i2 + k] <- s1.![i1 + k]
    done

(* TODO: when the compiler could optimize small function calls,
   use high order functions instead
*)
let caml_blit_bytes (s1 : bytes) i1 (s2 : bytes) i2 len =
  if len > 0 then
    if s1 == s2 then copyWithin s1 i1 i2 len
    else
      let off1 = length s1 - i1 in
      if len <= off1 then
        for i = 0 to len - 1 do
          s2.![i2 + i] <- s1.![i1 + i]
        done
      else (
        for i = 0 to off1 - 1 do
          s2.![i2 + i] <- s1.![i1 + i]
        done;
        for i = off1 to len - 1 do
          s2.![i2 + i] <- '\000'
        done)

external to_int_array : bytes -> int array = "%identity"

let string_of_large_bytes (bytes : bytes) i len =
  let s = ref "" in
  let s_len = ref len in
  let seg = 1024 in
  if i = 0 && len <= 4 * seg && len = length bytes then
    Caml_string_extern.of_small_int_array (to_int_array bytes)
  else
    let offset = ref 0 in
    while s_len.contents > 0 do
      let next = if s_len.contents < 1024 then s_len.contents else seg in
      let tmp_bytes = new_uninitialized next in
      for k = 0 to next - 1 do
        tmp_bytes.![k] <- bytes.![k + offset.contents]
      done;
      s.contents <-
        s.contents
        ^ Caml_string_extern.of_small_int_array (to_int_array tmp_bytes);
      s_len.contents <- s_len.contents - next;
      offset.contents <- offset.contents + next
    done;
    s.contents

let bytes_to_string a = string_of_large_bytes a 0 (length a)

(**
   TODO: [min] is not type specialized in OCaml
*)
let caml_blit_string (s1 : string) i1 (s2 : bytes) i2 (len : int) =
  if len > 0 then
    let off1 = Caml_string_extern.length s1 - i1 in
    if len <= off1 then
      for i = 0 to len - 1 do
        s2.![i2 + i] <- Caml_string_extern.unsafe_get s1 (i1 + i)
      done
    else (
      for i = 0 to off1 - 1 do
        s2.![i2 + i] <- Caml_string_extern.unsafe_get s1 (i1 + i)
      done;
      for i = off1 to len - 1 do
        s2.![i2 + i] <- '\000'
      done)

(** checkout [Bytes.empty] -- to be inlined? *)
let bytes_of_string s =
  let len = Caml_string_extern.length s in
  let res = new_uninitialized len in
  for i = 0 to len - 1 do
    res.![i] <- Caml_string_extern.unsafe_get s i
    (* Note that when get a char and convert it to int immedately, should be optimized
       should be [s.charCodeAt[i]]
    *)
  done;
  res

let rec caml_bytes_compare_aux (s1 : bytes) (s2 : bytes) off len def =
  if off < len then
    let a, b = (s1.![off], s2.![off]) in
    if a > b then 1
    else if a < b then -1
    else caml_bytes_compare_aux s1 s2 (off + 1) len def
  else def

(* code path could be using a tuple if we can eliminate the tuple allocation for code below
   {[
     let (len, v) =
       if len1 = len2 then (..,...)
       else (.., .)
   ]}
*)
let caml_bytes_compare (s1 : bytes) (s2 : bytes) : int =
  let len1, len2 = (length s1, length s2) in
  if len1 = len2 then caml_bytes_compare_aux s1 s2 0 len1 0
  else if len1 < len2 then caml_bytes_compare_aux s1 s2 0 len1 (-1)
  else caml_bytes_compare_aux s1 s2 0 len2 1

let rec caml_bytes_equal_aux (s1 : bytes) s2 (off : int) len =
  if off = len then true
  else
    let a, b = (s1.![off], s2.![off]) in
    a = b && caml_bytes_equal_aux s1 s2 (off + 1) len

let caml_bytes_equal (s1 : bytes) (s2 : bytes) : bool =
  let len1, len2 = (length s1, length s2) in
  len1 = len2 && caml_bytes_equal_aux s1 s2 0 len1

let caml_bytes_greaterthan (s1 : bytes) s2 = caml_bytes_compare s1 s2 > 0
let caml_bytes_greaterequal (s1 : bytes) s2 = caml_bytes_compare s1 s2 >= 0
let caml_bytes_lessthan (s1 : bytes) s2 = caml_bytes_compare s1 s2 < 0
let caml_bytes_lessequal (s1 : bytes) s2 = caml_bytes_compare s1 s2 <= 0
let bswap16 x = ((x land 0x00FF) lsl 8) lor ((x land 0xFF00) lsr 8)

let {
      logand = ( &~ );
      logor = ( |~ );
      shift_left = ( <<~ );
      shift_right_logical = ( >>~ );
    } =
  (module Caml_int32_extern)

let bswap32 (x : int32) =
  x &~ 0x000000FFl <<~ 24
  |~ (x &~ 0x0000FF00l <<~ 8)
  |~ (x &~ 0x00FF0000l >>~ 8)
  |~ (x &~ 0xFF000000l >>~ 24)

let { and_ = ( &&~ ); or_ = ( ||~ ); lsl_ = ( <<<~ ); lsr_ = ( >>>~ ) } =
  (module Caml_int64)

let bswap64 (x : int64) =
  let x = Caml_int64.unsafe_of_int64 x in
  let r =
    x
    &&~ Caml_int64.unsafe_of_int64 0x00000000000000FFL
    <<<~ 56
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x000000000000FF00L <<<~ 40)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x0000000000FF0000L <<<~ 24)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x00000000FF000000L <<<~ 8)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x000000FF00000000L >>>~ 8)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x0000FF0000000000L >>>~ 24)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0x00FF000000000000L >>>~ 40)
    ||~ (x &&~ Caml_int64.unsafe_of_int64 0xFF00000000000000L >>>~ 56)
  in
  Caml_int64.unsafe_to_int64 r

external unsafe_code : int -> char = "%identity"
external unsafe_chr : char -> int = "%identity"

let get16u str idx =
  let b1 = str.![idx] in
  let b2 = str.![idx + 1] in
  (unsafe_chr b2 lsl 8) lor unsafe_chr b1

let get16 str idx =
  if idx < 0 || idx + 1 >= length str then
    raise (Invalid_argument "index out of bounds");
  get16u str idx

let get32 str idx =
  if idx < 0 || idx + 3 >= length str then
    raise (Invalid_argument "index out of bounds");
  let b1 = str.![idx] in
  let b2 = str.![idx + 1] in
  let b3 = str.![idx + 2] in
  let b4 = str.![idx + 3] in
  let res =
    (unsafe_chr b4 lsl 24)
    lor (unsafe_chr b3 lsl 16)
    lor (unsafe_chr b2 lsl 8)
    lor unsafe_chr b1
  in
  Caml_int32_extern.of_int res

let get64 str idx =
  if idx < 0 || idx + 7 >= length str then
    raise (Invalid_argument "index out of bounds");
  let b1 = str.![idx] in
  let b2 = str.![idx + 1] in
  let b3 = str.![idx + 2] in
  let b4 = str.![idx + 3] in
  let b5 = str.![idx + 4] in
  let b6 = str.![idx + 5] in
  let b7 = str.![idx + 6] in
  let b8 = str.![idx + 7] in
  let res =
    Caml_int64.of_int32 (unsafe_chr b8)
    <<<~ 56
    ||~ Caml_int64.of_int32 (unsafe_chr b7)
    <<<~ 48
    ||~ Caml_int64.of_int32 (unsafe_chr b6)
    <<<~ 40
    ||~ Caml_int64.of_int32 (unsafe_chr b5)
    <<<~ 32
    ||~ Caml_int64.of_int32 (unsafe_chr b4)
    <<<~ 24
    ||~ Caml_int64.of_int32 (unsafe_chr b3)
    <<<~ 16
    ||~ Caml_int64.of_int32 (unsafe_chr b2)
    <<<~ 8
    ||~ Caml_int64.of_int32 (unsafe_chr b1)
  in
  Caml_int64.unsafe_to_int64 res

let set16u b idx newval =
  (* XXX(anmonteiro): assumes little endian *)
  let b2 = 0xFF land (newval lsr 8) in
  let b1 = 0xFF land newval in
  b.![idx] <- unsafe_code b1;
  b.![idx + 1] <- unsafe_code b2

let set16 b idx newval =
  if idx < 0 || idx + 1 >= length b then
    raise (Invalid_argument "index out of bounds");
  set16u b idx newval

let set32u str idx newval =
  let b4 = 0xFFl &~ (newval >>~ 24) in
  let b3 = 0xFFl &~ (newval >>~ 16) in
  let b2 = 0xFFl &~ (newval >>~ 8) in
  let b1 = 0xFFl &~ newval in
  str.![idx] <- unsafe_code (Caml_int32_extern.to_int b1);
  str.![idx + 1] <- unsafe_code (Caml_int32_extern.to_int b2);
  str.![idx + 2] <- unsafe_code (Caml_int32_extern.to_int b3);
  str.![idx + 3] <- unsafe_code (Caml_int32_extern.to_int b4)

let set32 str idx newval =
  if idx < 0 || idx + 3 >= length str then
    raise (Invalid_argument "index out of bounds");
  set32u str idx newval

let set64u str idx newval =
  let newval = Caml_int64.unsafe_of_int64 newval in
  let b8 = 0xFF land Caml_int64.to_int32 (newval >>>~ 56) in
  let b7 = 0xFF land Caml_int64.to_int32 (newval >>>~ 48) in
  let b6 = 0xFF land Caml_int64.to_int32 (newval >>>~ 40) in
  let b5 = 0xFF land Caml_int64.to_int32 (newval >>>~ 32) in
  let b4 = 0xFF land Caml_int64.to_int32 (newval >>>~ 24) in
  let b3 = 0xFF land Caml_int64.to_int32 (newval >>>~ 16) in
  let b2 = 0xFF land Caml_int64.to_int32 (newval >>>~ 8) in
  let b1 = 0xFF land Caml_int64.to_int32 newval in
  str.![idx] <- unsafe_code b1;
  str.![idx + 1] <- unsafe_code b2;
  str.![idx + 2] <- unsafe_code b3;
  str.![idx + 3] <- unsafe_code b4;
  str.![idx + 4] <- unsafe_code b5;
  str.![idx + 5] <- unsafe_code b6;
  str.![idx + 6] <- unsafe_code b7;
  str.![idx + 7] <- unsafe_code b8

let set64 str idx newval =
  if idx < 0 || idx + 7 >= length str then
    raise (Invalid_argument "index out of bounds");
  set64u str idx newval
