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







(*
   {[ split " test_unsafe_obj_ffi_ppx.cmi" ~keep_empty:false ' ']}
*)
let split_by ?(keep_empty=false) is_delim str =
  let len = String.length str in
  let rec loop acc last_pos pos =
    if pos = -1 then
      if last_pos = 0 && not keep_empty then

        acc
      else
        String.sub str 0 last_pos :: acc
    else
    if is_delim str.[pos] then
      let new_len = (last_pos - pos - 1) in
      if new_len <> 0 || keep_empty then
        let v = String.sub str (pos + 1) new_len in
        loop ( v :: acc)
          pos (pos - 1)
      else loop acc pos (pos - 1)
    else loop acc last_pos (pos - 1)
  in
  loop [] len (len - 1)

let trim s =
  let i = ref 0  in
  let j = String.length s in
  while !i < j &&
        let u = String.unsafe_get s !i in
        u = '\t' || u = '\n' || u = ' '
  do
    incr i;
  done;
  let k = ref (j - 1)  in
  while !k >= !i &&
        let u = String.unsafe_get s !k in
        u = '\t' || u = '\n' || u = ' ' do
    decr k ;
  done;
  String.sub s !i (!k - !i + 1)

let split ?keep_empty  str on =
  if str = "" then [] else
    split_by ?keep_empty (fun x -> (x : char) = on) str  ;;

let quick_split_by_ws str : string list =
  split_by ~keep_empty:false (fun x -> x = '\t' || x = '\n' || x = ' ') str

let starts_with s beg =
  let beg_len = String.length beg in
  let s_len = String.length s in
  beg_len <=  s_len &&
  (let i = ref 0 in
   while !i <  beg_len
         && String.unsafe_get s !i =
            String.unsafe_get beg !i do
     incr i
   done;
   !i = beg_len
  )


(** return an index which is minus when [s] does not
    end with [beg]
*)
let ends_with_index s end_ =
  let s_finish = String.length s - 1 in
  let s_beg = String.length end_ - 1 in
  if s_beg > s_finish then -1
  else
    let rec aux j k =
      if k < 0 then (j + 1)
      else if String.unsafe_get s j = String.unsafe_get end_ k then
        aux (j - 1) (k - 1)
      else  -1 in
    aux s_finish s_beg

let ends_with s end_ = ends_with_index s end_ >= 0

let ends_with_then_chop s beg =
  let i =  ends_with_index s beg in
  if i >= 0 then Some (String.sub s 0 i)
  else None

let check_suffix_case = ends_with
let check_suffix_case_then_chop = ends_with_then_chop

let check_any_suffix_case s suffixes =
  List.exists (fun x -> check_suffix_case s x) suffixes

let check_any_suffix_case_then_chop s suffixes =
  let rec aux suffixes =
    match suffixes with
    | [] -> None
    | x::xs ->
      let id = ends_with_index s x in
      if id >= 0 then Some (String.sub s 0 id)
      else aux xs in
  aux suffixes



(**  In OCaml 4.02.3, {!String.escaped} is locale senstive,
     this version try to make it not locale senstive, this bug is fixed
     in the compiler trunk
*)
let escaped s =
  let rec needs_escape i =
    if i >= String.length s then false else
      match String.unsafe_get s i with
      | '"' | '\\' | '\n' | '\t' | '\r' | '\b' -> true
      | ' ' .. '~' -> needs_escape (i+1)
      | _ -> true
  in
  if needs_escape 0 then
    Bytes.unsafe_to_string (Ext_bytes_test.escaped (Bytes.unsafe_of_string s))
  else
    s

(* it is unsafe to expose such API as unsafe since
   user can provide bad input range

*)
let rec unsafe_for_all_range s ~start ~finish p =
  start > finish ||
  p (String.unsafe_get s start) &&
  unsafe_for_all_range s ~start:(start + 1) ~finish p

let for_all_range s ~start ~finish p =
  let len = String.length s in
  if start < 0 || finish >= len then invalid_arg "Ext_string_test.for_all_range"
  else unsafe_for_all_range s ~start ~finish p

let for_all (p : char -> bool) s =
  unsafe_for_all_range s ~start:0  ~finish:(String.length s - 1) p

let is_empty s = String.length s = 0


let repeat n s  =
  let len = String.length s in
  let res = Bytes.create(n * len) in
  for i = 0 to pred n do
    String.blit s 0 res (i * len) len
  done;
  Bytes.to_string res

let equal (x : string) y  = x = y



let unsafe_is_sub ~sub i s j ~len =
  let rec check k =
    if k = len
    then true
    else
      String.unsafe_get sub (i+k) =
      String.unsafe_get s (j+k) && check (k+1)
  in
  j+len <= String.length s && check 0


exception Local_exit
let find ?(start=0) ~sub s =
  let n = String.length sub in
  let s_len = String.length s in
  let i = ref start in
  try
    while !i + n <= s_len do
      if unsafe_is_sub ~sub 0 s !i ~len:n then
        raise_notrace Local_exit;
      incr i
    done;
    -1
  with Local_exit ->
    !i

let contain_substring s sub =
  find s ~sub >= 0

(** TODO: optimize
    avoid nonterminating when string is empty
*)
let non_overlap_count ~sub s =
  let sub_len = String.length sub in
  let rec aux  acc off =
    let i = find ~start:off ~sub s  in
    if i < 0 then acc
    else aux (acc + 1) (i + sub_len) in
  if String.length sub = 0 then invalid_arg "Ext_string_test.non_overlap_count"
  else aux 0 0


let rfind ~sub s =
  let n = String.length sub in
  let i = ref (String.length s - n) in
  try
    while !i >= 0 do
      if unsafe_is_sub ~sub 0 s !i ~len:n then
        raise_notrace Local_exit;
      decr i
    done;
    -1
  with Local_exit ->
    !i

let tail_from s x =
  let len = String.length s  in
  if  x > len then invalid_arg ("Ext_string_test.tail_from " ^s ^ " : "^ string_of_int x )
  else String.sub s x (len - x)


(**
   {[
     digits_of_str "11_js" 2 == 11
   ]}
*)
let digits_of_str s ~offset x =
  let rec aux i acc s x  =
    if i >= x then acc
    else aux (i + 1) (10 * acc + Char.code s.[offset + i] - 48 (* Char.code '0' *)) s x in
  aux 0 0 s x



(*
   {[
     starts_with_and_number "js_fn_mk_01" 0 "js_fn_mk_" = 1 ;;
     starts_with_and_number "js_fn_run_02" 0 "js_fn_mk_" = -1 ;;
     starts_with_and_number "js_fn_mk_03" 6 "mk_" = 3 ;;
     starts_with_and_number "js_fn_mk_04" 6 "run_" = -1;;
     starts_with_and_number "js_fn_run_04" 6 "run_" = 4;;
     (starts_with_and_number "js_fn_run_04" 6 "run_" = 3) = false ;;
   ]}
*)
let starts_with_and_number s ~offset beg =
  let beg_len = String.length beg in
  let s_len = String.length s in
  let finish_delim = offset + beg_len in

  if finish_delim >  s_len  then -1
  else
    let i = ref offset  in
    while !i <  finish_delim
          && String.unsafe_get s !i =
             String.unsafe_get beg (!i - offset) do
      incr i
    done;
    if !i = finish_delim then
      digits_of_str ~offset:finish_delim s 2
    else
      -1

let equal (x : string) y  = x = y

let unsafe_concat_with_length len sep l =
  match l with
  | [] -> ""
  | hd :: tl -> (* num is positive *)
    let r = Bytes.create len in
    let hd_len = String.length hd in
    let sep_len = String.length sep in
    String.unsafe_blit hd 0 r 0 hd_len;
    let pos = ref hd_len in
    List.iter
      (fun s ->
         let s_len = String.length s in
         String.unsafe_blit sep 0 r !pos sep_len;
         pos := !pos +  sep_len;
         String.unsafe_blit s 0 r !pos s_len;
         pos := !pos + s_len)
      tl;
    Bytes.unsafe_to_string r


let rec rindex_rec s i c =
  if i < 0 then i else
  if String.unsafe_get s i = c then i else rindex_rec s (i - 1) c;;

let rec rindex_rec_opt s i c =
  if i < 0 then None else
  if String.unsafe_get s i = c then Some i else rindex_rec_opt s (i - 1) c;;

let rindex_neg s c =
  rindex_rec s (String.length s - 1) c;;

let rindex_opt s c =
  rindex_rec_opt s (String.length s - 1) c;;

let is_valid_module_file (s : string) =
  let len = String.length s in
  len > 0 &&
  match String.unsafe_get s 0 with
  | 'A' .. 'Z'
  | 'a' .. 'z' ->
    unsafe_for_all_range s ~start:1 ~finish:(len - 1)
      (fun x ->
         match x with
         | 'A'..'Z' | 'a'..'z' | '0'..'9' | '_' | '\'' -> true
         | _ -> false )
  | _ -> false


(* https://docs.npmjs.com/files/package.json
  Some rules:
  The name must be less than or equal to 214 characters. This includes the scope for scoped packages.
  The name can't start with a dot or an underscore.
  New packages must not have uppercase letters in the name.
  The name ends up being part of a URL, an argument on the command line, and a folder name. Therefore, the name can't contain any non-URL-safe characters.
*)
let is_valid_npm_package_name (s : string) =
  let len = String.length s in
  len <= 214 && (* magic number forced by npm *)
  len > 0 &&
  match String.unsafe_get s 0 with
  | 'a' .. 'z' | '@' ->
    unsafe_for_all_range s ~start:1 ~finish:(len - 1)
      (fun x ->
         match x with
         |  'a'..'z' | '0'..'9' | '_' | '-' -> true
         | _ -> false )
  | _ -> false

type check_result =
  | Good
  | Invalid_module_name
  | Suffix_mismatch
(**
   TODO: move to another module
   Make {!Ext_filename_test} not stateful
*)
let is_valid_source_name name : check_result =
  match check_any_suffix_case_then_chop name [
      ".ml";
      ".re";
      ".mli";
      ".rei"
    ] with
  | None -> Suffix_mismatch
  | Some x ->
    if is_valid_module_file  x then
      Good
    else Invalid_module_name

(** TODO: can be improved to return a positive integer instead *)
let rec unsafe_no_char x ch i  last_idx =
  i > last_idx  ||
  (String.unsafe_get x i <> ch && unsafe_no_char x ch (i + 1)  last_idx)

let rec unsafe_no_char_idx x ch i last_idx =
  if i > last_idx  then -1
  else
    if String.unsafe_get x i <> ch then
      unsafe_no_char_idx x ch (i + 1)  last_idx
    else i

let no_char x ch i len  : bool =
  let str_len = String.length x in
  if i < 0 || i >= str_len || len >= str_len then invalid_arg "Ext_string_test.no_char"
  else unsafe_no_char x ch i len


let no_slash x =
  unsafe_no_char x '/' 0 (String.length x - 1)

let no_slash_idx x =
  unsafe_no_char_idx x '/' 0 (String.length x - 1)

let replace_slash_backward (x : string ) =
  let len = String.length x in
  if unsafe_no_char x '/' 0  (len - 1) then x
  else
    String.map (function
        | '/' -> '\\'
        | x -> x ) x

let replace_backward_slash (x : string)=
  let len = String.length x in
  if unsafe_no_char x '\\' 0  (len -1) then x
  else
    String.map (function
        |'\\'-> '/'
        | x -> x) x

let empty = ""

external compare : string -> string -> int = "caml_string_length_based_compare"  [@@noalloc];;

let single_space = " "
let single_colon = ":"

let concat_array sep (s : string array) =
  let s_len = Array.length s in
  match s_len with
  | 0 -> empty
  | 1 -> Array.unsafe_get s 0
  | _ ->
    let sep_len = String.length sep in
    let len = ref 0 in
    for i = 0 to  s_len - 1 do
      len := !len + String.length (Array.unsafe_get s i)
    done;
    let target =
      Bytes.create
        (!len + (s_len - 1) * sep_len ) in
    let hd = (Array.unsafe_get s 0) in
    let hd_len = String.length hd in
    String.unsafe_blit hd  0  target 0 hd_len;
    let current_offset = ref hd_len in
    for i = 1 to s_len - 1 do
      String.unsafe_blit sep 0 target  !current_offset sep_len;
      let cur = Array.unsafe_get s i in
      let cur_len = String.length cur in
      let new_off_set = (!current_offset + sep_len ) in
      String.unsafe_blit cur 0 target new_off_set cur_len;
      current_offset :=
        new_off_set + cur_len ;
    done;
    Bytes.unsafe_to_string target

let concat3 a b c =
  let a_len = String.length a in
  let b_len = String.length b in
  let c_len = String.length c in
  let len = a_len + b_len + c_len in
  let target = Bytes.create len in
  String.unsafe_blit a 0 target 0 a_len ;
  String.unsafe_blit b 0 target a_len b_len;
  String.unsafe_blit c 0 target (a_len + b_len) c_len;
  Bytes.unsafe_to_string target

let concat4 a b c d =
  let a_len = String.length a in
  let b_len = String.length b in
  let c_len = String.length c in
  let d_len = String.length d in
  let len = a_len + b_len + c_len + d_len in

  let target = Bytes.create len in
  String.unsafe_blit a 0 target 0 a_len ;
  String.unsafe_blit b 0 target a_len b_len;
  String.unsafe_blit c 0 target (a_len + b_len) c_len;
  String.unsafe_blit d 0 target (a_len + b_len + c_len) d_len;
  Bytes.unsafe_to_string target


let concat5 a b c d e =
  let a_len = String.length a in
  let b_len = String.length b in
  let c_len = String.length c in
  let d_len = String.length d in
  let e_len = String.length e in
  let len = a_len + b_len + c_len + d_len + e_len in

  let target = Bytes.create len in
  String.unsafe_blit a 0 target 0 a_len ;
  String.unsafe_blit b 0 target a_len b_len;
  String.unsafe_blit c 0 target (a_len + b_len) c_len;
  String.unsafe_blit d 0 target (a_len + b_len + c_len) d_len;
  String.unsafe_blit e 0 target (a_len + b_len + c_len + d_len) e_len;
  Bytes.unsafe_to_string target



let inter2 a b =
    concat3 a single_space b


let inter3 a b c =
  concat5 a  single_space  b  single_space  c





let inter4 a b c d =
  concat_array single_space [| a; b ; c; d|]


let parent_dir_lit = ".."
let current_dir_lit = "."
