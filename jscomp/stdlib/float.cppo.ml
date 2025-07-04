(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                        Nicolas Ojeda Bar, LexiFi                       *)
(*                                                                        *)
(*   Copyright 2018 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

external neg : float -> float = "%negfloat"
external add : float -> float -> float = "%addfloat"
external sub : float -> float -> float = "%subfloat"
external mul : float -> float -> float = "%mulfloat"
external div : float -> float -> float = "%divfloat"
external rem : float -> float -> float = "caml_fmod_float" "fmod"
  [@@unboxed] [@@noalloc]
external fma : float -> float -> float -> float = "caml_fma_float" "caml_fma"
  [@@unboxed] [@@noalloc]
#ifdef BS
external abs : float -> float = "abs" [@@mel.scope "Math"]
#else
external abs : float -> float = "%absfloat"
#endif

let zero = 0.
let one = 1.
let minus_one = -1.
let infinity = Stdlib.infinity
let neg_infinity = Stdlib.neg_infinity
let nan = Stdlib.nan
let quiet_nan = nan
external float_of_bits : int64 -> float
  = "caml_int64_float_of_bits" "caml_int64_float_of_bits_unboxed"
  [@@unboxed] [@@noalloc]
let signaling_nan = float_of_bits 0x7F_F0_00_00_00_00_00_01L
let is_finite (x: float) = x -. x = 0.
let is_infinite (x: float) = 1. /. x = 0.
let is_nan (x: float) = x <> x

let pi = 0x1.921fb54442d18p+1
let max_float = Stdlib.max_float
let min_float = Stdlib.min_float
let epsilon = Stdlib.epsilon_float
external of_int : int -> float = "%floatofint"
external to_int : float -> int = "%intoffloat"
external of_string : string -> float = "caml_float_of_string"
let of_string_opt = Stdlib.float_of_string_opt
let to_string = Stdlib.string_of_float
type fpclass = Stdlib.fpclass =
    FP_normal
  | FP_subnormal
  | FP_zero
  | FP_infinite
  | FP_nan
external classify_float : (float [@unboxed]) -> fpclass =
  "caml_classify_float" "caml_classify_float_unboxed" [@@noalloc]

#ifdef BS
external pow : float -> float -> float = "pow"  [@@mel.scope "Math"]
external sqrt : float -> float =  "sqrt"  [@@mel.scope "Math"]
external cbrt : float -> float = "cbrt"  [@@mel.scope "Math"]
external exp : float -> float = "exp" [@@mel.scope "Math"]
external exp2 : float -> float = "caml_exp2_float" "caml_exp2"
  [@@unboxed] [@@noalloc]
external log : float -> float =  "log"  [@@mel.scope "Math"]
external log10 : float -> float = "log10" [@@mel.scope "Math"]
external log2 : float -> float = "caml_log2_float" "caml_log2"
  [@@unboxed] [@@noalloc]
external expm1 : float -> float = "caml_expm1_float" "caml_expm1"
  [@@unboxed] [@@noalloc]
external log1p : float -> float = "log1p"  [@@mel.scope "Math"]
external cos : float -> float = "cos"  [@@mel.scope "Math"]
external sin : float -> float =  "sin"  [@@mel.scope "Math"]
external tan : float -> float =  "tan"  [@@mel.scope "Math"]
external acos : float -> float =  "acos"  [@@mel.scope "Math"]
external asin : float -> float = "asin"  [@@mel.scope "Math"]
external atan : float -> float = "atan"  [@@mel.scope "Math"]
external atan2 : float -> float -> float = "atan2"  [@@mel.scope "Math"]
external hypot : float -> float -> float
               = "caml_hypot_float" "caml_hypot" [@@unboxed] [@@noalloc]
external cosh : float -> float = "cosh"  [@@mel.scope "Math"]
external sinh : float -> float = "sinh"  [@@mel.scope "Math"]
external tanh : float -> float =  "tanh"  [@@mel.scope "Math"]
external acosh : float -> float = "acosh"   [@@mel.scope "Math"]
external asinh : float -> float = "asinh"  [@@mel.scope "Math"]
external atanh : float -> float =  "atanh"  [@@mel.scope "Math"]
external erf : float -> float = "caml_erf_float" "caml_erf"
  [@@unboxed] [@@noalloc]
external erfc : float -> float = "caml_erfc_float" "caml_erfc"
  [@@unboxed] [@@noalloc]
external trunc : float -> float = "caml_trunc_float" "caml_trunc"
  [@@unboxed] [@@noalloc]
external round : float -> float = "caml_round_float" "caml_round"
  [@@unboxed] [@@noalloc]
external ceil : float -> float = "caml_ceil_float" "ceil"
  [@@unboxed] [@@noalloc]
external floor : float -> float = "caml_floor_float" "floor"
[@@unboxed] [@@noalloc]
#else
external pow : float -> float -> float = "caml_power_float" "pow"
  [@@unboxed] [@@noalloc]
external sqrt : float -> float = "caml_sqrt_float" "sqrt"
  [@@unboxed] [@@noalloc]
external cbrt : float -> float = "caml_cbrt_float" "caml_cbrt"
  [@@unboxed] [@@noalloc]
external exp : float -> float = "caml_exp_float" "exp" [@@unboxed] [@@noalloc]
external exp2 : float -> float = "caml_exp2_float" "caml_exp2"
  [@@unboxed] [@@noalloc]
external log : float -> float = "caml_log_float" "log" [@@unboxed] [@@noalloc]
external log10 : float -> float = "caml_log10_float" "log10"
  [@@unboxed] [@@noalloc]
external log2 : float -> float = "caml_log2_float" "caml_log2"
  [@@unboxed] [@@noalloc]
external expm1 : float -> float = "caml_expm1_float" "caml_expm1"
  [@@unboxed] [@@noalloc]
external log1p : float -> float = "caml_log1p_float" "caml_log1p"
  [@@unboxed] [@@noalloc]
external cos : float -> float = "caml_cos_float" "cos" [@@unboxed] [@@noalloc]
external sin : float -> float = "caml_sin_float" "sin" [@@unboxed] [@@noalloc]
external tan : float -> float = "caml_tan_float" "tan" [@@unboxed] [@@noalloc]
external acos : float -> float = "caml_acos_float" "acos"
  [@@unboxed] [@@noalloc]
external asin : float -> float = "caml_asin_float" "asin"
  [@@unboxed] [@@noalloc]
external atan : float -> float = "caml_atan_float" "atan"
  [@@unboxed] [@@noalloc]
external atan2 : float -> float -> float = "caml_atan2_float" "atan2"
  [@@unboxed] [@@noalloc]
external hypot : float -> float -> float
               = "caml_hypot_float" "caml_hypot" [@@unboxed] [@@noalloc]
external cosh : float -> float = "caml_cosh_float" "cosh"
  [@@unboxed] [@@noalloc]
external sinh : float -> float = "caml_sinh_float" "sinh"
  [@@unboxed] [@@noalloc]
external tanh : float -> float = "caml_tanh_float" "tanh"
  [@@unboxed] [@@noalloc]
external acosh : float -> float = "caml_acosh_float" "caml_acosh"
  [@@unboxed] [@@noalloc]
external asinh : float -> float = "caml_asinh_float" "caml_asinh"
  [@@unboxed] [@@noalloc]
external atanh : float -> float = "caml_atanh_float" "caml_atanh"
  [@@unboxed] [@@noalloc]
external erf : float -> float = "caml_erf_float" "caml_erf"
  [@@unboxed] [@@noalloc]
external erfc : float -> float = "caml_erfc_float" "caml_erfc"
  [@@unboxed] [@@noalloc]
external trunc : float -> float = "caml_trunc_float" "caml_trunc"
  [@@unboxed] [@@noalloc]
external round : float -> float = "caml_round_float" "caml_round"
  [@@unboxed] [@@noalloc]
external ceil : float -> float = "caml_ceil_float" "ceil"
  [@@unboxed] [@@noalloc]
external floor : float -> float = "caml_floor_float" "floor"
[@@unboxed] [@@noalloc]
#endif



let is_integer x = x = trunc x && is_finite x

external next_after : float -> float -> float
  = "caml_nextafter_float" "caml_nextafter" [@@unboxed] [@@noalloc]

let succ x = next_after x infinity
let pred x = next_after x neg_infinity

external copy_sign : float -> float -> float
                  = "caml_copysign_float" "caml_copysign"
                  [@@unboxed] [@@noalloc]
external sign_bit : (float [@unboxed]) -> bool
  = "caml_signbit_float" "caml_signbit" [@@noalloc]

external frexp : float -> float * int = "caml_frexp_float"
external ldexp : (float [@unboxed]) -> (int [@untagged]) -> (float [@unboxed]) =
  "caml_ldexp_float" "caml_ldexp_float_unboxed" [@@noalloc]
external modf : float -> float * float = "caml_modf_float"
type t = float
external compare : float -> float -> int = "%compare"
let equal x y = compare x y = 0

let[@inline] min (x: float) (y: float) =
  if y > x || (not(sign_bit y) && sign_bit x) then
    if is_nan y then y else x
  else if is_nan x then x else y

let[@inline] max (x: float) (y: float) =
  if y > x || (not(sign_bit y) && sign_bit x) then
    if is_nan x then x else y
  else if is_nan y then y else x

let[@inline] min_max (x: float) (y: float) =
  if is_nan x || is_nan y then (nan, nan)
  else if y > x || (not(sign_bit y) && sign_bit x) then (x, y) else (y, x)

let[@inline] min_num (x: float) (y: float) =
  if y > x || (not(sign_bit y) && sign_bit x) then
    if is_nan x then y else x
  else if is_nan y then x else y

let[@inline] max_num (x: float) (y: float) =
  if y > x || (not(sign_bit y) && sign_bit x) then
    if is_nan y then x else y
  else if is_nan x then y else x

let[@inline] min_max_num (x: float) (y: float) =
  if is_nan x then (y,y)
  else if is_nan y then (x,x)
  else if y > x || (not(sign_bit y) && sign_bit x) then (x,y) else (y,x)

external seeded_hash_param :
  int -> int -> int -> 'a -> int = "caml_hash" [@@noalloc]
let seeded_hash seed x = seeded_hash_param 10 100 seed x
let hash x = seeded_hash_param 10 100 0 x

module Array = struct

  type t = floatarray

  external length : t -> int = "%floatarray_length"
  external get : t -> int -> float = "%floatarray_safe_get"
  external set : t -> int -> float -> unit = "%floatarray_safe_set"
  external create : int -> t = "caml_floatarray_create"
  external unsafe_get : t -> int -> float = "%floatarray_unsafe_get"
  external unsafe_set : t -> int -> float -> unit = "%floatarray_unsafe_set"

  let unsafe_fill a ofs len v =
    for i = ofs to ofs + len - 1 do unsafe_set a i v done


  external make : (int[@untagged]) -> (float[@unboxed]) -> t =
    "caml_floatarray_make" "caml_floatarray_make_unboxed"

#ifdef BS
#else
  external unsafe_fill
    : t -> (int[@untagged]) -> (int[@untagged]) -> (float[@unboxed]) -> unit
    = "caml_floatarray_fill" "caml_floatarray_fill_unboxed" [@@noalloc]
#endif

  external unsafe_blit: t -> int -> t -> int -> int -> unit =
    "caml_floatarray_blit" [@@noalloc]

#ifdef BS
#else
  external unsafe_sub : t -> int -> int -> t = "caml_floatarray_sub"
  external append_prim : t -> t -> t = "caml_floatarray_append"
  external concat : t list -> t = "caml_floatarray_concat"
#endif

  let check a ofs len msg =
    if ofs < 0 || len < 0 || ofs + len < 0 || ofs + len > length a then
      invalid_arg msg

#ifdef BS
#else
  let empty = create 0
#endif

  let init l f =
    if l < 0 then invalid_arg "Float.Array.init"
    else
      let res = create l in
      for i = 0 to l - 1 do
        unsafe_set res i (f i)
      done;
      res

  let make_matrix sx sy v =
    (* We raise even if [sx = 0 && sy < 0]: *)
    if sy < 0 then invalid_arg "Float.Array.make_matrix";
    let res = Array.make sx (create 0) in
    if sy > 0 then begin
      for x = 0 to sx - 1 do
        Array.unsafe_set res x (make sy v)
      done;
    end;
    res

  let init_matrix sx sy f =
    (* We raise even if [sx = 0 && sy < 0]: *)
    if sy < 0 then invalid_arg "Float.Array.init_matrix";
    let res = Array.make sx (create 0) in
    if sy > 0 then begin
      for x = 0 to sx - 1 do
        let row = create sy in
        for y = 0 to sy - 1 do
          unsafe_set row y (f x y)
        done;
        Array.unsafe_set res x row
      done;
    end;
    res

  let sub a ofs len =
    check a ofs len "Float.Array.sub";
#ifdef BS
    let result = create len in
    unsafe_blit a ofs result 0 len;
    result
#else
    unsafe_sub a ofs len
#endif

  let copy a =
    let l = length a in
#ifdef BS
    let result = create l in
    unsafe_blit a 0 result 0 l;
    result
#else
    if l = 0 then empty
    else unsafe_sub a 0 l
#endif

  let append a1 a2 =
    let l1 = length a1 in
    let l2 = length a2 in
    let result = create (l1 + l2) in
    unsafe_blit a1 0 result 0 l1;
    unsafe_blit a2 0 result l1 l2;
    result

  (* inlining exposes a float-unboxing opportunity for [v] *)
  let[@inline] fill a ofs len v =
    check a ofs len "Float.Array.fill";
    unsafe_fill a ofs len v

  let blit src sofs dst dofs len =
    check src sofs len "Float.array.blit";
    check dst dofs len "Float.array.blit";
    unsafe_blit src sofs dst dofs len

  let to_list a =
    List.init (length a) (unsafe_get a)

  let of_list l =
    let result = create (List.length l) in
    let rec fill i l =
      match l with
      | [] -> result
      | h :: t -> unsafe_set result i h; fill (i + 1) t
    in
    fill 0 l

  (* duplicated from array.ml *)
  let equal eq a b =
    if length a <> length b then false else
    let i = ref 0 in
    let len = length a in
    while !i < len && eq (unsafe_get a !i) (unsafe_get b !i) do incr i done;
    !i = len

  let float_compare = compare
  (* duplicated from array.ml *)
  let compare cmp a b =
    let len_a = length a and len_b = length b in
    let diff = len_a - len_b in
    if diff <> 0 then (if diff < 0 then -1 else 1) else
    let i = ref 0 and c = ref 0 in
    while !i < len_a && !c = 0
    do c := cmp (unsafe_get a !i) (unsafe_get b !i); incr i done;
    !c

  (* duplicated from array.ml *)
  let iter f a =
    for i = 0 to length a - 1 do f (unsafe_get a i) done

  (* duplicated from array.ml *)
  let iter2 f a b =
    if length a <> length b then
      invalid_arg "Float.Array.iter2: arrays must have the same length"
    else
      for i = 0 to length a - 1 do f (unsafe_get a i) (unsafe_get b i) done

  let map f a =
    let l = length a in
    let r = create l in
    for i = 0 to l - 1 do
      unsafe_set r i (f (unsafe_get a i))
    done;
    r

  (* duplicated from array.ml *)
  let map_inplace f a =
    for i = 0 to length a - 1 do
      unsafe_set a i (f (unsafe_get a i))
    done

  let map2 f a b =
    let la = length a in
    let lb = length b in
    if la <> lb then
      invalid_arg "Float.Array.map2: arrays must have the same length"
    else begin
      let r = create la in
      for i = 0 to la - 1 do
        unsafe_set r i (f (unsafe_get a i) (unsafe_get b i))
      done;
      r
    end

  (* duplicated from array.ml *)
  let iteri f a =
    for i = 0 to length a - 1 do f i (unsafe_get a i) done

  let mapi f a =
    let l = length a in
    let r = create l in
    for i = 0 to l - 1 do
      unsafe_set r i (f i (unsafe_get a i))
    done;
    r

  (* duplicated from array.ml *)
  let mapi_inplace f a =
    for i = 0 to length a - 1 do
      unsafe_set a i (f i (unsafe_get a i))
    done

  (* duplicated from array.ml *)
  let fold_left f x a =
    let r = ref x in
    for i = 0 to length a - 1 do
      r := f !r (unsafe_get a i)
    done;
    !r

  (* duplicated from array.ml *)
  let fold_right f a x =
    let r = ref x in
    for i = length a - 1 downto 0 do
      r := f (unsafe_get a i) !r
    done;
    !r

  (* duplicated from array.ml *)
  let exists p a =
    let n = length a in
    let rec loop i =
      if i = n then false
      else if p (unsafe_get a i) then true
      else loop (i + 1) in
    loop 0

  (* duplicated from array.ml *)
  let for_all p a =
    let n = length a in
    let rec loop i =
      if i = n then true
      else if p (unsafe_get a i) then loop (i + 1)
      else false in
    loop 0

  (* duplicated from array.ml *)
  let mem x a =
    let n = length a in
    let rec loop i =
      if i = n then false
      else if float_compare (unsafe_get a i) x = 0 then true
      else loop (i + 1)
    in
    loop 0

  (* mostly duplicated from array.ml, but slightly different *)
  let mem_ieee x a =
    let n = length a in
    let rec loop i =
      if i = n then false
      else if x = (unsafe_get a i) then true
      else loop (i + 1)
    in
    loop 0

  (* duplicated from array.ml *)
  let find_opt p a =
    let n = length a in
    let rec loop i =
      if i = n then None
      else
        let x = unsafe_get a i in
        if p x then Some x
        else loop (i + 1)
    in
    loop 0

  (* duplicated from array.ml *)
  let find_index p a =
    let n = length a in
    let rec loop i =
      if i = n then None
      else if p (unsafe_get a i) then Some i
      else loop (i + 1) in
    loop 0

  (* duplicated from array.ml *)
  let find_map f a =
    let n = length a in
    let rec loop i =
      if i = n then None
      else
        match f (unsafe_get a i) with
        | None -> loop (i + 1)
        | Some _ as r -> r
    in
    loop 0

  (* duplicated from array.ml *)
  let find_mapi f a =
    let n = length a in
    let rec loop i =
      if i = n then None
      else
        match f i (unsafe_get a i) with
        | None -> loop (i + 1)
        | Some _ as r -> r
    in
    loop 0

  (* duplicated from array.ml *)
  exception Bottom of int
  let sort cmp a =
    let maxson l i =
      let i31 = i+i+i+1 in
      let x = ref i31 in
      if i31+2 < l then begin
        if cmp (get a i31) (get a (i31+1)) < 0 then x := i31+1;
        if cmp (get a !x) (get a (i31+2)) < 0 then x := i31+2;
        !x
      end else
        if i31+1 < l && cmp (get a i31) (get a (i31+1)) < 0
        then i31+1
        else if i31 < l then i31 else raise (Bottom i)
    in
    let rec trickledown l i e =
      let j = maxson l i in
      if cmp (get a j) e > 0 then begin
        set a i (get a j);
        trickledown l j e;
      end else begin
        set a i e;
      end;
    in
    let trickle l i e = try trickledown l i e with Bottom i -> set a i e in
    let rec bubbledown l i =
      let j = maxson l i in
      set a i (get a j);
      bubbledown l j
    in
    let bubble l i = try bubbledown l i with Bottom i -> i in
    let rec trickleup i e =
      let father = (i - 1) / 3 in
      assert (i <> father);
      if cmp (get a father) e < 0 then begin
        set a i (get a father);
        if father > 0 then trickleup father e else set a 0 e;
      end else begin
        set a i e;
      end;
    in
    let l = length a in
    for i = (l + 1) / 3 - 1 downto 0 do trickle l i (get a i); done;
    for i = l - 1 downto 2 do
      let e = (get a i) in
      set a i (get a 0);
      trickleup (bubble i 0) e;
    done;
    if l > 1 then (let e = (get a 1) in set a 1 (get a 0); set a 0 e)

  (* duplicated from array.ml, except for the call to [create] *)
  let cutoff = 5
  let stable_sort cmp a =
    let merge src1ofs src1len src2 src2ofs src2len dst dstofs =
      let src1r = src1ofs + src1len and src2r = src2ofs + src2len in
      let rec loop i1 s1 i2 s2 d =
        if cmp s1 s2 <= 0 then begin
          set dst d s1;
          let i1 = i1 + 1 in
          if i1 < src1r then
            loop i1 (get a i1) i2 s2 (d + 1)
          else
            blit src2 i2 dst (d + 1) (src2r - i2)
        end else begin
          set dst d s2;
          let i2 = i2 + 1 in
          if i2 < src2r then
            loop i1 s1 i2 (get src2 i2) (d + 1)
          else
            blit a i1 dst (d + 1) (src1r - i1)
        end
      in loop src1ofs (get a src1ofs) src2ofs (get src2 src2ofs) dstofs;
    in
    let isortto srcofs dst dstofs len =
      for i = 0 to len - 1 do
        let e = (get a (srcofs + i)) in
        let j = ref (dstofs + i - 1) in
        while (!j >= dstofs && cmp (get dst !j) e > 0) do
          set dst (!j + 1) (get dst !j);
          decr j;
        done;
        set dst (!j + 1) e;
      done;
    in
    let rec sortto srcofs dst dstofs len =
      if len <= cutoff then isortto srcofs dst dstofs len else begin
        let l1 = len / 2 in
        let l2 = len - l1 in
        sortto (srcofs + l1) dst (dstofs + l1) l2;
        sortto srcofs a (srcofs + l2) l1;
        merge (srcofs + l2) l1 dst (dstofs + l1) l2 dst dstofs;
      end;
    in
    let l = length a in
    if l <= cutoff then isortto 0 a 0 l else begin
      let l1 = l / 2 in
      let l2 = l - l1 in
      let t = create l2 in
      sortto l1 t 0 l2;
      sortto 0 a l2 l1;
      merge l2 l1 t 0 l2 a 0;
    end

  let fast_sort = stable_sort

  (* duplicated from array.ml *)
  let shuffle ~rand a = (* Fisher-Yates *)
    for i = length a - 1 downto 1 do
      let j = rand (i + 1) in
      let v = unsafe_get a i in
      unsafe_set a i (get a j);
      unsafe_set a j v
    done

  (* duplicated from array.ml *)
  let to_seq a =
    let rec aux i () =
      if i < length a
      then
        let x = unsafe_get a i in
        Seq.Cons (x, aux (i+1))
      else Seq.Nil
    in
    aux 0

  (* duplicated from array.ml *)
  let to_seqi a =
    let rec aux i () =
      if i < length a
      then
        let x = unsafe_get a i in
        Seq.Cons ((i,x), aux (i+1))
      else Seq.Nil
    in
    aux 0

  (* mostly duplicated from array.ml *)
  let of_rev_list l =
    let len = List.length l in
    let a = create len in
    let rec fill i = function
        [] -> a
      | hd::tl -> unsafe_set a i hd; fill (i-1) tl
    in
    fill (len-1) l

  (* duplicated from array.ml *)
  let of_seq i =
    let l = Seq.fold_left (fun acc x -> x::acc) [] i in
    of_rev_list l


  let map_to_array f a =
    let l = length a in
    if l = 0 then [| |] else begin
      let r = Array.make l (f (unsafe_get a 0)) in
      for i = 1 to l - 1 do
        Array.unsafe_set r i (f (unsafe_get a i))
      done;
      r
    end

  let map_from_array f a =
    let l = Array.length a in
    let r = create l in
    for i = 0 to l - 1 do
      unsafe_set r i (f (Array.unsafe_get a i))
    done;
    r

end

#ifdef BS
#else
module ArrayLabels = Array
#endif
