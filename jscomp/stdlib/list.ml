(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* An alias for the type of lists. *)
type 'a t = 'a list = [] | (::) of 'a * 'a list

(* List operations *)

let rec length_aux len = function
    [] -> len
  | _::l -> length_aux (len + 1) l

let length l = length_aux 0 l

let cons a l = a::l

let singleton a = [a]

let hd = function
    [] -> failwith "hd"
  | a::_ -> a

let tl = function
    [] -> failwith "tl"
  | _::l -> l

let nth l n =
  if n < 0 then invalid_arg "List.nth" else
  let rec nth_aux l n =
    match l with
    | [] -> failwith "nth"
    | a::l -> if n = 0 then a else nth_aux l (n-1)
  in nth_aux l n

let nth_opt l n =
  if n < 0 then invalid_arg "List.nth" else
  let rec nth_aux l n =
    match l with
    | [] -> None
    | a::l -> if n = 0 then Some a else nth_aux l (n-1)
  in nth_aux l n

let append = (@)

let rec rev_append l1 l2 =
  match l1 with
    [] -> l2
  | a :: l -> rev_append l (a :: l2)

let rev l = rev_append l []

let[@tail_mod_cons] rec init i last f =
  if i > last then []
  else if i = last then [f i]
  else
    let r1 = f i in
    let r2 = f (i+1) in
    r1 :: r2 :: init (i+2) last f

let init len f =
  if len < 0 then invalid_arg "List.init" else
  init 0 (len - 1) f

let rec flatten = function
    [] -> []
  | l::r -> l @ flatten r

let concat = flatten

let[@tail_mod_cons] rec map f = function
    [] -> []
  | [a1] ->
      let r1 = f a1 in
      [r1]
  | a1::a2::l ->
      let r1 = f a1 in
      let r2 = f a2 in
      r1::r2::map f l

let[@tail_mod_cons] rec mapi i f = function
    [] -> []
  | [a1] ->
      let r1 = f i a1 in
      [r1]
  | a1::a2::l ->
      let r1 = f i a1 in
      let r2 = f (i+1) a2 in
      r1::r2::mapi (i+2) f l

let mapi f l = mapi 0 f l

let rev_map f l =
  let rec rmap_f accu = function
    | [] -> accu
    | a::l -> rmap_f (f a :: accu) l
  in
  rmap_f [] l


let rec iter f = function
    [] -> ()
  | a::l -> f a; iter f l

let rec iteri i f = function
    [] -> ()
  | a::l -> f i a; iteri (i + 1) f l

let iteri f l = iteri 0 f l

let rec fold_left f accu l =
  match l with
    [] -> accu
  | a::l -> fold_left f (f accu a) l

let rec fold_right f l accu =
  match l with
    [] -> accu
  | a::l -> f a (fold_right f l accu)

let[@tail_mod_cons] rec map2 f l1 l2 =
  match (l1, l2) with
    ([], []) -> []
  | ([a1], [b1]) ->
      let r1 = f a1 b1 in
      [r1]
  | (a1::a2::l1, b1::b2::l2) ->
      let r1 = f a1 b1 in
      let r2 = f a2 b2 in
      r1::r2::map2 f l1 l2
  | (_, _) -> invalid_arg "List.map2"

let rev_map2 f l1 l2 =
  let rec rmap2_f accu l1 l2 =
    match (l1, l2) with
    | ([], []) -> accu
    | (a1::l1, a2::l2) -> rmap2_f (f a1 a2 :: accu) l1 l2
    | (_, _) -> invalid_arg "List.rev_map2"
  in
  rmap2_f [] l1 l2


let rec iter2 f l1 l2 =
  match (l1, l2) with
    ([], []) -> ()
  | (a1::l1, a2::l2) -> f a1 a2; iter2 f l1 l2
  | (_, _) -> invalid_arg "List.iter2"

let rec fold_left2 f accu l1 l2 =
  match (l1, l2) with
    ([], []) -> accu
  | (a1::l1, a2::l2) -> fold_left2 f (f accu a1 a2) l1 l2
  | (_, _) -> invalid_arg "List.fold_left2"

let rec fold_right2 f l1 l2 accu =
  match (l1, l2) with
    ([], []) -> accu
  | (a1::l1, a2::l2) -> f a1 a2 (fold_right2 f l1 l2 accu)
  | (_, _) -> invalid_arg "List.fold_right2"

let rec for_all p = function
    [] -> true
  | a::l -> p a && for_all p l

let rec exists p = function
    [] -> false
  | a::l -> p a || exists p l

let rec for_all2 p l1 l2 =
  match (l1, l2) with
    ([], []) -> true
  | (a1::l1, a2::l2) -> p a1 a2 && for_all2 p l1 l2
  | (_, _) -> invalid_arg "List.for_all2"

let rec exists2 p l1 l2 =
  match (l1, l2) with
    ([], []) -> false
  | (a1::l1, a2::l2) -> p a1 a2 || exists2 p l1 l2
  | (_, _) -> invalid_arg "List.exists2"

let rec mem x = function
    [] -> false
  | a::l -> compare a x = 0 || mem x l

let rec memq x = function
    [] -> false
  | a::l -> a == x || memq x l

let rec assoc x = function
    [] -> raise Not_found
  | (a,b)::l -> if compare a x = 0 then b else assoc x l

let rec assoc_opt x = function
    [] -> None
  | (a,b)::l -> if compare a x = 0 then Some b else assoc_opt x l

let rec assq x = function
    [] -> raise Not_found
  | (a,b)::l -> if a == x then b else assq x l

let rec assq_opt x = function
    [] -> None
  | (a,b)::l -> if a == x then Some b else assq_opt x l

let rec mem_assoc x = function
  | [] -> false
  | (a, _) :: l -> compare a x = 0 || mem_assoc x l

let rec mem_assq x = function
  | [] -> false
  | (a, _) :: l -> a == x || mem_assq x l

let rec remove_assoc x = function
  | [] -> []
  | (a, _ as pair) :: l ->
      if compare a x = 0 then l else pair :: remove_assoc x l

let rec remove_assq x = function
  | [] -> []
  | (a, _ as pair) :: l -> if a == x then l else pair :: remove_assq x l

let rec find p = function
  | [] -> raise Not_found
  | x :: l -> if p x then x else find p l

let rec find_opt p = function
  | [] -> None
  | x :: l -> if p x then Some x else find_opt p l

let find_index p =
  let rec aux i = function
    [] -> None
    | a::l -> if p a then Some i else aux (i+1) l in
  aux 0

let rec find_map f = function
  | [] -> None
  | x :: l ->
     begin match f x with
       | Some _ as result -> result
       | None -> find_map f l
     end

let find_mapi f =
  let rec aux i = function
  | [] -> None
  | x :: l ->
     begin match f i x with
       | Some _ as result -> result
       | None -> aux (i+1) l
     end in
  aux 0

let[@tail_mod_cons] rec find_all p = function
  | [] -> []
  | x :: l -> if p x then x :: find_all p l else find_all p l

let filter = find_all

let[@tail_mod_cons] rec filteri p i = function
  | [] -> []
  | x::l ->
      let i' = i + 1 in
      if p i x then x :: filteri p i' l else filteri p i' l

let filteri p l = filteri p 0 l

let[@tail_mod_cons] rec filter_map f = function
  | [] -> []
  | x :: l ->
      match f x with
      | None -> filter_map f l
      | Some v -> v :: filter_map f l

let[@tail_mod_cons] rec concat_map f = function
  | [] -> []
  | x::xs -> prepend_concat_map (f x) f xs
and[@tail_mod_cons] prepend_concat_map ys f xs =
  match ys with
  | [] -> concat_map f xs
  | y :: ys -> y :: prepend_concat_map ys f xs

let take n l =
  let[@tail_mod_cons] rec aux n l =
    match n, l with
    | 0, _ | _, [] -> []
    | n, x::l -> x::aux (n - 1) l
  in
  if n <= 0 then [] else aux n l

let drop n l =
  let rec aux i = function
    | _x::l when i < n -> aux (i + 1) l
    | rest -> rest
  in
  if n <= 0 then l else aux 0 l

let take_while p l =
  let[@tail_mod_cons] rec aux = function
    | x::l when p x -> x::aux l
    | _rest -> []
  in
  aux l

let rec drop_while p = function
  | x::l when p x -> drop_while p l
  | rest -> rest

let fold_left_map f accu l =
  let rec aux accu l_accu = function
    | [] -> accu, rev l_accu
    | x :: l ->
        let accu, x = f accu x in
        aux accu (x :: l_accu) l in
  aux accu [] l

let partition p l =
  let rec part yes no = function
  | [] -> (rev yes, rev no)
  | x :: l -> if p x then part (x :: yes) no l else part yes (x :: no) l in
  part [] [] l

let partition_map p l =
  let rec part left right = function
  | [] -> (rev left, rev right)
  | x :: l ->
     begin match p x with
       | Either.Left v -> part (v :: left) right l
       | Either.Right v -> part left (v :: right) l
     end
  in
  part [] [] l

let rec split = function
    [] -> ([], [])
  | (x,y)::l ->
      let (rx, ry) = split l in (x::rx, y::ry)

let rec combine l1 l2 =
  match (l1, l2) with
    ([], []) -> []
  | (a1::l1, a2::l2) -> (a1, a2) :: combine l1 l2
  | (_, _) -> invalid_arg "List.combine"

(** sorting *)

let rec merge cmp l1 l2 =
  match l1, l2 with
  | [], l2 -> l2
  | l1, [] -> l1
  | h1 :: t1, h2 :: t2 ->
      if cmp h1 h2 <= 0
      then h1 :: merge cmp t1 l2
      else h2 :: merge cmp l1 t2


let stable_sort cmp l =
  let rec rev_merge l1 l2 accu =
    match l1, l2 with
    | [], l2 -> rev_append l2 accu
    | l1, [] -> rev_append l1 accu
    | h1::t1, h2::t2 ->
        if cmp h1 h2 <= 0
        then rev_merge t1 l2 (h1::accu)
        else rev_merge l1 t2 (h2::accu)
  in
  let rec rev_merge_rev l1 l2 accu =
    match l1, l2 with
    | [], l2 -> rev_append l2 accu
    | l1, [] -> rev_append l1 accu
    | h1::t1, h2::t2 ->
        if cmp h1 h2 > 0
        then rev_merge_rev t1 l2 (h1::accu)
        else rev_merge_rev l1 t2 (h2::accu)
  in
  let rec sort n l =
    match n, l with
    | 2, x1 :: x2 :: tl ->
        let s = if cmp x1 x2 <= 0 then [x1; x2] else [x2; x1] in
        (s, tl)
    | 3, x1 :: x2 :: x3 :: tl ->
        let s =
          if cmp x1 x2 <= 0 then
            if cmp x2 x3 <= 0 then [x1; x2; x3]
            else if cmp x1 x3 <= 0 then [x1; x3; x2]
            else [x3; x1; x2]
          else if cmp x1 x3 <= 0 then [x2; x1; x3]
          else if cmp x2 x3 <= 0 then [x2; x3; x1]
          else [x3; x2; x1]
        in
        (s, tl)
    | n, l ->
        let n1 = n asr 1 in
        let n2 = n - n1 in
        let s1, l2 = rev_sort n1 l in
        let s2, tl = rev_sort n2 l2 in
        (rev_merge_rev s1 s2 [], tl)
  and rev_sort n l =
    match n, l with
    | 2, x1 :: x2 :: tl ->
        let s = if cmp x1 x2 > 0 then [x1; x2] else [x2; x1] in
        (s, tl)
    | 3, x1 :: x2 :: x3 :: tl ->
        let s =
          if cmp x1 x2 > 0 then
            if cmp x2 x3 > 0 then [x1; x2; x3]
            else if cmp x1 x3 > 0 then [x1; x3; x2]
            else [x3; x1; x2]
          else if cmp x1 x3 > 0 then [x2; x1; x3]
          else if cmp x2 x3 > 0 then [x2; x3; x1]
          else [x3; x2; x1]
        in
        (s, tl)
    | n, l ->
        let n1 = n asr 1 in
        let n2 = n - n1 in
        let s1, l2 = sort n1 l in
        let s2, tl = sort n2 l2 in
        (rev_merge s1 s2 [], tl)
  in
  let len = length l in
  if len < 2 then l else fst (sort len l)


let sort = stable_sort
let fast_sort = stable_sort

(* Note: on a very long list (length over about 100000), it used to be
   faster to convert the list to an array, sort the array, and convert
   back, truncating the array object after prepending each thousand
   entries to the resulting list. Impossible now that Obj.truncate has
   been removed. *)

(** sorting + removing non-first duplicates *)

let sort_uniq cmp l =
  let rec rev_merge l1 l2 accu =
    match l1, l2 with
    | [], l2 -> rev_append l2 accu
    | l1, [] -> rev_append l1 accu
    | h1::t1, h2::t2 ->
        let c = cmp h1 h2 in
        if c = 0 then rev_merge t1 t2 (h1::accu)
        else if c < 0
        then rev_merge t1 l2 (h1::accu)
        else rev_merge l1 t2 (h2::accu)
  in
  let rec rev_merge_rev l1 l2 accu =
    match l1, l2 with
    | [], l2 -> rev_append l2 accu
    | l1, [] -> rev_append l1 accu
    | h1::t1, h2::t2 ->
        let c = cmp h1 h2 in
        if c = 0 then rev_merge_rev t1 t2 (h1::accu)
        else if c > 0
        then rev_merge_rev t1 l2 (h1::accu)
        else rev_merge_rev l1 t2 (h2::accu)
  in
  let rec sort n l =
    match n, l with
    | 2, x1 :: x2 :: tl ->
        let s =
          let c = cmp x1 x2 in
          if c = 0 then [x1] else if c < 0 then [x1; x2] else [x2; x1]
        in
        (s, tl)
    | 3, x1 :: x2 :: x3 :: tl ->
        let s =
          let c = cmp x1 x2 in
          if c = 0 then
            let c = cmp x1 x3 in
            if c = 0 then [x1] else if c < 0 then [x1; x3] else [x3; x1]
          else if c < 0 then
            let c = cmp x2 x3 in
            if c = 0 then [x1; x2]
            else if c < 0 then [x1; x2; x3]
            else
              let c = cmp x1 x3 in
              if c = 0 then [x1; x2]
              else if c < 0 then [x1; x3; x2]
              else [x3; x1; x2]
          else
            let c = cmp x1 x3 in
            if c = 0 then [x2; x1]
            else if c < 0 then [x2; x1; x3]
            else
              let c = cmp x2 x3 in
              if c = 0 then [x2; x1]
              else if c < 0 then [x2; x3; x1]
              else [x3; x2; x1]
        in
        (s, tl)
    | n, l ->
        let n1 = n asr 1 in
        let n2 = n - n1 in
        let s1, l2 = rev_sort n1 l in
        let s2, tl = rev_sort n2 l2 in
        (rev_merge_rev s1 s2 [], tl)
  and rev_sort n l =
    match n, l with
    | 2, x1 :: x2 :: tl ->
        let s =
          let c = cmp x1 x2 in
          if c = 0 then [x1] else if c > 0 then [x1; x2] else [x2; x1]
        in
        (s, tl)
    | 3, x1 :: x2 :: x3 :: tl ->
        let s =
          let c = cmp x1 x2 in
          if c = 0 then
            let c = cmp x1 x3 in
            if c = 0 then [x1] else if c > 0 then [x1; x3] else [x3; x1]
          else if c > 0 then
            let c = cmp x2 x3 in
            if c = 0 then [x1; x2]
            else if c > 0 then [x1; x2; x3]
            else
              let c = cmp x1 x3 in
              if c = 0 then [x1; x2]
              else if c > 0 then [x1; x3; x2]
              else [x3; x1; x2]
          else
            let c = cmp x1 x3 in
            if c = 0 then [x2; x1]
            else if c > 0 then [x2; x1; x3]
            else
              let c = cmp x2 x3 in
              if c = 0 then [x2; x1]
              else if c > 0 then [x2; x3; x1]
              else [x3; x2; x1]
        in
        (s, tl)
    | n, l ->
        let n1 = n asr 1 in
        let n2 = n - n1 in
        let s1, l2 = sort n1 l in
        let s2, tl = sort n2 l2 in
        (rev_merge s1 s2 [], tl)
  in
  let len = length l in
  if len < 2 then l else fst (sort len l)


let rec compare_lengths l1 l2 =
  match l1, l2 with
  | [], [] -> 0
  | [], _ -> -1
  | _, [] -> 1
  | _ :: l1, _ :: l2 -> compare_lengths l1 l2

let rec compare_length_with l n =
  match l with
  | [] ->
    if n = 0 then 0 else
      if n > 0 then -1 else 1
  | _ :: l ->
    if n <= 0 then 1 else
      compare_length_with l (n-1)

let is_empty = function
  | [] -> true
  | _ :: _ -> false

(** {1 Comparison} *)

(* Note: we are *not* shortcutting the list by using
   [List.compare_lengths] first; this may be slower on long lists
   immediately start with distinct elements. It is also incorrect for
   [compare] below, and it is better (principle of least surprise) to
   use the same approach for both functions. *)
let rec equal eq l1 l2 =
  match l1, l2 with
  | [], [] -> true
  | [], _::_ | _::_, [] -> false
  | a1::l1, a2::l2 -> eq a1 a2 && equal eq l1 l2

let rec compare cmp l1 l2 =
  match l1, l2 with
  | [], [] -> 0
  | [], _::_ -> -1
  | _::_, [] -> 1
  | a1::l1, a2::l2 ->
    let c = cmp a1 a2 in
    if c <> 0 then c
    else compare cmp l1 l2

(** {1 Iterators} *)

let to_seq l =
  let rec aux l () = match l with
    | [] -> Seq.Nil
    | x :: tail -> Seq.Cons (x, aux tail)
  in
  aux l

let[@tail_mod_cons] rec of_seq seq =
  match seq () with
  | Seq.Nil -> []
  | Seq.Cons (x1, seq) ->
      begin match seq () with
      | Seq.Nil -> [x1]
      | Seq.Cons (x2, seq) -> x1 :: x2 :: of_seq seq
      end
