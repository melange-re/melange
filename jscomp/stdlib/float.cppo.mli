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

(* NOTE:
   If this file is float.template.mli, run tools/sync_stdlib_docs after editing
   it to generate float.mli.

   If this file is float.mli, do not edit it directly -- edit
   templates/float.template.mli instead.
 *)

(** Floating-point arithmetic.

    OCaml's floating-point numbers follow the
    IEEE 754 standard, using double precision (64 bits) numbers.
    Floating-point operations never raise an exception on overflow,
    underflow, division by zero, etc.  Instead, special IEEE numbers
    are returned as appropriate, such as [infinity] for [1.0 /. 0.0],
    [neg_infinity] for [-1.0 /. 0.0], and [nan] ('not a number')
    for [0.0 /. 0.0].  These special numbers then propagate through
    floating-point computations as expected: for instance,
    [1.0 /. infinity] is [0.0], basic arithmetic operations
    ([+.], [-.], [*.], [/.]) with [nan] as an argument return [nan], ...

    @since 4.07
*)

val zero : float
(** The floating point 0.
   @since 4.08 *)

val one : float
(** The floating-point 1.
   @since 4.08 *)

val minus_one : float
(** The floating-point -1.
   @since 4.08 *)

external neg : float -> float = "%negfloat"
(** Unary negation. *)

external add : float -> float -> float = "%addfloat"
(** Floating-point addition. *)

external sub : float -> float -> float = "%subfloat"
(** Floating-point subtraction. *)

external mul : float -> float -> float = "%mulfloat"
(** Floating-point multiplication. *)

external div : float -> float -> float = "%divfloat"
(** Floating-point division. *)

external fma : float -> float -> float -> float =
  "caml_fma_float" "caml_fma" [@@unboxed] [@@noalloc]
(** [fma x y z] returns [x * y + z], with a best effort for computing
   this expression with a single rounding, using either hardware
   instructions (providing full IEEE compliance) or a software
   emulation.

   On 64-bit Cygwin, 64-bit mingw-w64 and MSVC 2017 and earlier, this function
   may be emulated owing to known bugs on limitations on these platforms.
   Note: since software emulation of the fma is costly, make sure that you are
   using hardware fma support if performance matters.

   @since 4.08 *)

external rem : float -> float -> float = "caml_fmod_float" "fmod"
[@@unboxed] [@@noalloc]
(** [rem a b] returns the remainder of [a] with respect to [b].  The returned
    value is [a -. n *. b], where [n] is the quotient [a /. b] rounded towards
    zero to an integer. *)

val succ : float -> float
(** [succ x] returns the floating point number right after [x] i.e.,
   the smallest floating-point number greater than [x].  See also
   {!next_after}.
   @since 4.08 *)

val pred : float -> float
(** [pred x] returns the floating-point number right before [x] i.e.,
   the greatest floating-point number smaller than [x].  See also
   {!next_after}.
   @since 4.08 *)

#ifdef BS
external abs : float -> float = "abs" [@@mel.scope "Math"]
#else
external abs : float -> float = "%absfloat"
#endif
(** [abs f] returns the absolute value of [f]. *)

val infinity : float
(** Positive infinity. *)

val neg_infinity : float
(** Negative infinity. *)

val nan : float
(** A special floating-point value denoting the result of an
    undefined operation such as [0.0 /. 0.0].  Stands for
    'not a number'.  Any floating-point operation with [nan] as
    argument returns [nan] as result, unless otherwise specified in
    IEEE 754 standard.  As for floating-point comparisons,
    [=], [<], [<=], [>] and [>=] return [false] and [<>] returns [true]
    if one or both of their arguments is [nan].

    [nan] is [quiet_nan] since 5.1; it was a signaling NaN before. *)

val signaling_nan : float
(** Signaling NaN. The corresponding signals do not raise OCaml exception,
    but the value can be useful for interoperability with C libraries.

    @since 5.1 *)

val quiet_nan : float
(** Quiet NaN.

    @since 5.1 *)

val pi : float
(** The constant pi. *)

val max_float : float
(** The largest positive finite value of type [float]. *)

val min_float : float
(** The smallest positive, non-zero, non-denormalized value of type [float]. *)

val epsilon : float
(** The difference between [1.0] and the smallest exactly representable
    floating-point number greater than [1.0]. *)

val is_finite : float -> bool
(** [is_finite x] is [true] if and only if [x] is finite i.e., not infinite and
   not {!nan}.

   @since 4.08 *)

val is_infinite : float -> bool
(** [is_infinite x] is [true] if and only if [x] is {!infinity} or
    {!neg_infinity}.

   @since 4.08 *)

val is_nan : float -> bool
(** [is_nan x] is [true] if and only if [x] is not a number (see {!nan}).

   @since 4.08 *)

val is_integer : float -> bool
(** [is_integer x] is [true] if and only if [x] is an integer.

   @since 4.08 *)

external of_int : int -> float = "%floatofint"
(** Convert an integer to floating-point. *)

external to_int : float -> int = "%intoffloat"
(** Truncate the given floating-point number to an integer.
    The result is unspecified if the argument is [nan] or falls outside the
    range of representable integers. *)

external of_string : string -> float = "caml_float_of_string"
(** Convert the given string to a float.  The string is read in decimal
    (by default) or in hexadecimal (marked by [0x] or [0X]).
    The format of decimal floating-point numbers is
    [ [-] dd.ddd (e|E) [+|-] dd ], where [d] stands for a decimal digit.
    The format of hexadecimal floating-point numbers is
    [ [-] 0(x|X) hh.hhh (p|P) [+|-] dd ], where [h] stands for an
    hexadecimal digit and [d] for a decimal digit.
    In both cases, at least one of the integer and fractional parts must be
    given; the exponent part is optional.
    The [_] (underscore) character can appear anywhere in the string
    and is ignored.
    Depending on the execution platforms, other representations of
    floating-point numbers can be accepted, but should not be relied upon.
    @raise Failure if the given string is not a valid
    representation of a float. *)

val of_string_opt: string -> float option
(** Same as [of_string], but returns [None] instead of raising. *)

val to_string : float -> string
(** Return a string representation of a floating-point number.

    This conversion can involve a loss of precision. For greater control over
    the manner in which the number is printed, see {!Printf}.

    This function is an alias for {!Stdlib.string_of_float}. *)

type fpclass = Stdlib.fpclass =
    FP_normal           (** Normal number, none of the below *)
  | FP_subnormal        (** Number very close to 0.0, has reduced precision *)
  | FP_zero             (** Number is 0.0 or -0.0 *)
  | FP_infinite         (** Number is positive or negative infinity *)
  | FP_nan              (** Not a number: result of an undefined operation *)
(** The five classes of floating-point numbers, as determined by
    the {!classify_float} function. *)

external classify_float : (float [@unboxed]) -> fpclass =
  "caml_classify_float" "caml_classify_float_unboxed" [@@noalloc]
(** Return the class of the given floating-point number:
    normal, subnormal, zero, infinite, or not a number. *)

#ifdef BS
external pow : float -> float -> float = "pow"  [@@mel.scope "Math"]
#else
external pow : float -> float -> float = "caml_power_float" "pow"
[@@unboxed] [@@noalloc]
#endif
(** Exponentiation. *)

#ifdef BS
external sqrt : float -> float =  "sqrt"  [@@mel.scope "Math"]
#else
external sqrt : float -> float = "caml_sqrt_float" "sqrt"
[@@unboxed] [@@noalloc]
#endif
(** Square root. *)

#ifdef BS
external cbrt : float -> float = "cbrt"  [@@mel.scope "Math"]
#else
external cbrt : float -> float = "caml_cbrt_float" "caml_cbrt"
  [@@unboxed] [@@noalloc]
#endif
(** Cube root.

    @since 4.13
*)

#ifdef BS
external exp : float -> float = "exp" [@@mel.scope "Math"]
#else
external exp : float -> float = "caml_exp_float" "exp" [@@unboxed] [@@noalloc]
#endif
(** Exponential. *)

external exp2 : float -> float = "caml_exp2_float" "caml_exp2"
  [@@unboxed] [@@noalloc]
(** Base 2 exponential function.

    @since 4.13
*)

#ifdef BS
external log : float -> float =  "log"  [@@mel.scope "Math"]
#else
external log : float -> float = "caml_log_float" "log" [@@unboxed] [@@noalloc]
#endif
(** Natural logarithm. *)

#ifdef BS
external log10 : float -> float = "log10" [@@mel.scope "Math"]
#else
external log10 : float -> float = "caml_log10_float" "log10"
[@@unboxed] [@@noalloc]
#endif
(** Base 10 logarithm. *)

external log2 : float -> float = "caml_log2_float" "caml_log2"
  [@@unboxed] [@@noalloc]
(** Base 2 logarithm.

    @since 4.13
*)

external expm1 : float -> float = "caml_expm1_float" "caml_expm1"
[@@unboxed] [@@noalloc]
(** [expm1 x] computes [exp x -. 1.0], giving numerically-accurate results
    even if [x] is close to [0.0]. *)

#ifdef BS
external log1p : float -> float = "log1p"  [@@mel.scope "Math"]
#else
external log1p : float -> float = "caml_log1p_float" "caml_log1p"
[@@unboxed] [@@noalloc]
#endif
(** [log1p x] computes [log(1.0 +. x)] (natural logarithm),
    giving numerically-accurate results even if [x] is close to [0.0]. *)

#ifdef BS
external cos : float -> float = "cos"  [@@mel.scope "Math"]
#else
external cos : float -> float = "caml_cos_float" "cos" [@@unboxed] [@@noalloc]
#endif
(** Cosine.  Argument is in radians. *)

#ifdef BS
external sin : float -> float =  "sin"  [@@mel.scope "Math"]
#else
external sin : float -> float = "caml_sin_float" "sin" [@@unboxed] [@@noalloc]
#endif
(** Sine.  Argument is in radians. *)

#ifdef BS
external tan : float -> float =  "tan"  [@@mel.scope "Math"]
#else
external tan : float -> float = "caml_tan_float" "tan" [@@unboxed] [@@noalloc]
#endif
(** Tangent.  Argument is in radians. *)

#ifdef BS
external acos : float -> float =  "acos"  [@@mel.scope "Math"]
#else
external acos : float -> float = "caml_acos_float" "acos"
[@@unboxed] [@@noalloc]
#endif
(** Arc cosine.  The argument must fall within the range [[-1.0, 1.0]].
    Result is in radians and is between [0.0] and [pi]. *)

#ifdef BS
external asin : float -> float = "asin"  [@@mel.scope "Math"]
#else
external asin : float -> float = "caml_asin_float" "asin"
[@@unboxed] [@@noalloc]
#endif
(** Arc sine.  The argument must fall within the range [[-1.0, 1.0]].
    Result is in radians and is between [-pi/2] and [pi/2]. *)

#ifdef BS
external atan : float -> float = "atan"  [@@mel.scope "Math"]
#else
external atan : float -> float = "caml_atan_float" "atan"
[@@unboxed] [@@noalloc]
#endif
(** Arc tangent.
    Result is in radians and is between [-pi/2] and [pi/2]. *)

#ifdef BS
external atan2 : float -> float -> float = "atan2"  [@@mel.scope "Math"]
#else
external atan2 : float -> float -> float = "caml_atan2_float" "atan2"
[@@unboxed] [@@noalloc]
#endif
(** [atan2 y x] returns the arc tangent of [y /. x].  The signs of [x]
    and [y] are used to determine the quadrant of the result.
    Result is in radians and is between [-pi] and [pi]. *)

external hypot : float -> float -> float = "caml_hypot_float" "caml_hypot"
[@@unboxed] [@@noalloc]
(** [hypot x y] returns [sqrt(x *. x +. y *. y)], that is, the length
    of the hypotenuse of a right-angled triangle with sides of length
    [x] and [y], or, equivalently, the distance of the point [(x,y)]
    to origin.  If one of [x] or [y] is infinite, returns [infinity]
    even if the other is [nan]. *)

#ifdef BS
external cosh : float -> float = "cosh"  [@@mel.scope "Math"]
#else
external cosh : float -> float = "caml_cosh_float" "cosh"
[@@unboxed] [@@noalloc]
#endif
(** Hyperbolic cosine.  Argument is in radians. *)

#ifdef BS
external sinh : float -> float = "sinh"  [@@mel.scope "Math"]
#else
external sinh : float -> float = "caml_sinh_float" "sinh"
[@@unboxed] [@@noalloc]
#endif
(** Hyperbolic sine.  Argument is in radians. *)

#ifdef BS
external tanh : float -> float =  "tanh"  [@@mel.scope "Math"]
#else
external tanh : float -> float = "caml_tanh_float" "tanh"
[@@unboxed] [@@noalloc]
#endif
(** Hyperbolic tangent.  Argument is in radians. *)

#ifdef BS
external acosh : float -> float = "acosh"   [@@mel.scope "Math"]
#else
external acosh : float -> float = "caml_acosh_float" "caml_acosh"
  [@@unboxed] [@@noalloc]
#endif
(** Hyperbolic arc cosine.  The argument must fall within the range
    [[1.0, inf]].
    Result is in radians and is between [0.0] and [inf].

    @since 4.13
*)

#ifdef BS
external asinh : float -> float = "asinh"  [@@mel.scope "Math"]
#else
external asinh : float -> float = "caml_asinh_float" "caml_asinh"
  [@@unboxed] [@@noalloc]
#endif
(** Hyperbolic arc sine.  The argument and result range over the entire
    real line.
    Result is in radians.

    @since 4.13
*)

#ifdef BS
external atanh : float -> float =  "atanh"  [@@mel.scope "Math"]
#else
external atanh : float -> float = "caml_atanh_float" "caml_atanh"
  [@@unboxed] [@@noalloc]
#endif
(** Hyperbolic arc tangent.  The argument must fall within the range
    [[-1.0, 1.0]].
    Result is in radians and ranges over the entire real line.

    @since 4.13
*)

external erf : float -> float = "caml_erf_float" "caml_erf"
  [@@unboxed] [@@noalloc]
(** Error function.  The argument ranges over the entire real line.
    The result is always within [[-1.0, 1.0]].

    @since 4.13
*)

external erfc : float -> float = "caml_erfc_float" "caml_erfc"
  [@@unboxed] [@@noalloc]
(** Complementary error function ([erfc x = 1 - erf x]).
    The argument ranges over the entire real line.
    The result is always within [[0.0, 2.0]].

    @since 4.13
*)

external trunc : float -> float = "caml_trunc_float" "caml_trunc"
                                    [@@unboxed] [@@noalloc]
(** [trunc x] rounds [x] to the nearest integer whose absolute value is
   less than or equal to [x].

   @since 4.08 *)

external round : float -> float = "caml_round_float" "caml_round"
                                    [@@unboxed] [@@noalloc]
(** [round x] rounds [x] to the nearest integer with ties (fractional
   values of 0.5) rounded away from zero, regardless of the current
   rounding direction.  If [x] is an integer, [+0.], [-0.], [nan], or
   infinite, [x] itself is returned.

   On 64-bit mingw-w64, this function may be emulated owing to a bug in the
   C runtime library (CRT) on this platform.

   @since 4.08 *)

external ceil : float -> float = "caml_ceil_float" "ceil"
[@@unboxed] [@@noalloc]
(** Round above to an integer value.
    [ceil f] returns the least integer value greater than or equal to [f].
    The result is returned as a float. *)

external floor : float -> float = "caml_floor_float" "floor"
[@@unboxed] [@@noalloc]
(** Round below to an integer value.
    [floor f] returns the greatest integer value less than or
    equal to [f].
    The result is returned as a float. *)

external next_after : float -> float -> float
  = "caml_nextafter_float" "caml_nextafter" [@@unboxed] [@@noalloc]
(** [next_after x y] returns the next representable floating-point
   value following [x] in the direction of [y].  More precisely, if
   [y] is greater (resp. less) than [x], it returns the smallest
   (resp. largest) representable number greater (resp. less) than [x].
   If [x] equals [y], the function returns [y].  If [x] or [y] is
   [nan], a [nan] is returned.
   Note that [next_after max_float infinity = infinity] and that
   [next_after 0. infinity] is the smallest denormalized positive number.
   If [x] is the smallest denormalized positive number,
   [next_after x 0. = 0.]

   @since 4.08 *)

external copy_sign : float -> float -> float
  = "caml_copysign_float" "caml_copysign"
[@@unboxed] [@@noalloc]
(** [copy_sign x y] returns a float whose absolute value is that of [x]
    and whose sign is that of [y].  If [x] is [nan], returns [nan].
    If [y] is [nan], returns either [x] or [-. x], but it is not
    specified which. *)

external sign_bit : (float [@unboxed]) -> bool
  = "caml_signbit_float" "caml_signbit" [@@noalloc]
(** [sign_bit x] is [true] if and only if the sign bit of [x] is set.
    For example [sign_bit 1.] and [signbit 0.] are [false] while
    [sign_bit (-1.)] and [sign_bit (-0.)] are [true].

    @since 4.08 *)

external frexp : float -> float * int = "caml_frexp_float"
(** [frexp f] returns the pair of the significant
    and the exponent of [f].  When [f] is zero, the
    significant [x] and the exponent [n] of [f] are equal to
    zero.  When [f] is non-zero, they are defined by
    [f = x *. 2 ** n] and [0.5 <= x < 1.0]. *)

external ldexp : (float [@unboxed]) -> (int [@untagged]) -> (float [@unboxed]) =
  "caml_ldexp_float" "caml_ldexp_float_unboxed" [@@noalloc]
(** [ldexp x n] returns [x *. 2 ** n]. *)

external modf : float -> float * float = "caml_modf_float"
(** [modf f] returns the pair of the fractional and integral
    part of [f]. *)

type t = float
(** An alias for the type of floating-point numbers. *)

val compare: t -> t -> int
(** [compare x y] returns [0] if [x] is equal to [y], a negative integer if [x]
    is less than [y], and a positive integer if [x] is greater than
    [y]. [compare] treats [nan] as equal to itself and less than any other float
    value.  This treatment of [nan] ensures that [compare] defines a total
    ordering relation.  *)

val equal: t -> t -> bool
(** The equal function for floating-point numbers, compared using {!compare}. *)

val min : t -> t -> t
(** [min x y] returns the minimum of [x] and [y].  It returns [nan]
   when [x] or [y] is [nan].  Moreover [min (-0.) (+0.) = -0.]

   @since 4.08 *)

val max : float -> float -> float
(** [max x y] returns the maximum of [x] and [y].  It returns [nan]
   when [x] or [y] is [nan].  Moreover [max (-0.) (+0.) = +0.]

   @since 4.08 *)

val min_max : float -> float -> float * float
(** [min_max x y] is [(min x y, max x y)], just more efficient.

   @since 4.08 *)

val min_num : t -> t -> t
(** [min_num x y] returns the minimum of [x] and [y] treating [nan] as
   missing values.  If both [x] and [y] are [nan], [nan] is returned.
   Moreover [min_num (-0.) (+0.) = -0.]

   @since 4.08 *)

val max_num : t -> t -> t
(** [max_num x y] returns the maximum of [x] and [y] treating [nan] as
   missing values.  If both [x] and [y] are [nan] [nan] is returned.
   Moreover [max_num (-0.) (+0.) = +0.]

   @since 4.08 *)

val min_max_num : float -> float -> float * float
(** [min_max_num x y] is [(min_num x y, max_num x y)], just more
   efficient.  Note that in particular [min_max_num x nan = (x, x)]
   and [min_max_num nan y = (y, y)].

   @since 4.08 *)

val seeded_hash : int -> t -> int
(** A seeded hash function for floats, with the same output value as
    {!Hashtbl.seeded_hash}. This function allows this module to be passed as
    argument to the functor {!Hashtbl.MakeSeeded}.

    @since 5.1 *)

val hash : t -> int
(** An unseeded hash function for floats, with the same output value as
    {!Hashtbl.hash}. This function allows this module to be passed as argument
    to the functor {!Hashtbl.Make}. *)

module Array : sig
  type t = floatarray
  (** The type of float arrays with packed representation.
      @since 4.08
    *)

  val length : t -> int
  (** Return the length (number of elements) of the given floatarray. *)

  val get : t -> int -> float
  (** [get a n] returns the element number [n] of floatarray [a].
      @raise Invalid_argument if [n] is outside the range 0 to
      [(length a - 1)]. *)

  val set : t -> int -> float -> unit
  (** [set a n x] modifies floatarray [a] in place, replacing element
      number [n] with [x].
      @raise Invalid_argument if [n] is outside the range 0 to
      [(length a - 1)]. *)

  val make : int -> float -> t
  (** [make n x] returns a fresh floatarray of length [n], initialized with [x].
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val create : int -> t
  (** [create n] returns a fresh floatarray of length [n],
      with uninitialized data.
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val init : int -> (int -> float) -> t
  (** [init n f] returns a fresh floatarray of length [n],
      with element number [i] initialized to the result of [f i].
      In other terms, [init n f] tabulates the results of [f]
      applied to the integers [0] to [n-1].
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val make_matrix : int -> int -> float -> t array
  (** [make_matrix dimx dimy e] returns a two-dimensional array
      (an array of arrays) with first dimension [dimx] and
      second dimension [dimy], where all elements are initialized with [e].

      @raise Invalid_argument if [dimx] or [dimy] is negative or
      greater than {!Sys.max_floatarray_length}.

      @since 5.2 *)

  val init_matrix : int -> int -> (int -> int -> float) -> t array
  (** [init_matrix dimx dimy f] returns a two-dimensional array
      (an array of arrays)
      with first dimension [dimx] and second dimension [dimy],
      where the element at index ([x,y]) is initialized with [f x y].

      @raise Invalid_argument if [dimx] or [dimy] is negative or
      greater than {!Sys.max_floatarray_length}.

      @since 5.2 *)

  val append : t -> t -> t
  (** [append v1 v2] returns a fresh floatarray containing the
      concatenation of the floatarrays [v1] and [v2].
      @raise Invalid_argument if
      [length v1 + length v2 > Sys.max_floatarray_length]. *)

#ifdef BS
#else
  val concat : t list -> t
  (** Same as {!append}, but concatenates a list of floatarrays. *)
#endif

  val sub : t -> int -> int -> t
  (** [sub a pos len] returns a fresh floatarray of length [len],
      containing the elements number [pos] to [pos + len - 1]
      of floatarray [a].
      @raise Invalid_argument if [pos] and [len] do not
      designate a valid subarray of [a]; that is, if
      [pos < 0], or [len < 0], or [pos + len > length a]. *)

  val copy : t -> t
  (** [copy a] returns a copy of [a], that is, a fresh floatarray
      containing the same elements as [a]. *)

  val fill : t -> int -> int -> float -> unit
  (** [fill a pos len x] modifies the floatarray [a] in place,
      storing [x] in elements number [pos] to [pos + len - 1].
      @raise Invalid_argument if [pos] and [len] do not
      designate a valid subarray of [a]. *)

  val blit : t -> int -> t -> int -> int -> unit
  (** [blit src src_pos dst dst_pos len] copies [len] elements
      from floatarray [src], starting at element number [src_pos],
      to floatarray [dst], starting at element number [dst_pos].
      It works correctly even if
      [src] and [dst] are the same floatarray, and the source and
      destination chunks overlap.
      @raise Invalid_argument if [src_pos] and [len] do not
      designate a valid subarray of [src], or if [dst_pos] and [len] do not
      designate a valid subarray of [dst]. *)

  val to_list : t -> float list
  (** [to_list a] returns the list of all the elements of [a]. *)

  val of_list : float list -> t
  (** [of_list l] returns a fresh floatarray containing the elements
      of [l].
      @raise Invalid_argument if the length of [l] is greater than
      [Sys.max_floatarray_length].*)

  (** {1:comparison Comparison} *)

  val equal : (float -> float -> bool) -> t -> t -> bool
  (** [equal eq a b] is [true] if and only if [a] and [b] have the
      same length [n] and for all [i] in \[[0];[n-1]\], [eq a.(i) b.(i)]
      is [true].
      @since 5.4 *)

  val compare : (float -> float -> int) -> t -> t -> int
  (** [compare cmp a b] compares [a] and [b] according to the shortlex order,
      that is, shorter arrays are smaller and equal-sized arrays are compared
      in lexicographic order using [cmp] to compare elements.
      @since 5.4 *)

  (** {1 Iterators} *)

  val iter : (float -> unit) -> t -> unit
  (** [iter f a] applies function [f] in turn to all
      the elements of [a].  It is equivalent to
      [f a.(0); f a.(1); ...; f a.(length a - 1); ()]. *)

  val iteri : (int -> float -> unit) -> t -> unit
  (** Same as {!iter}, but the
      function is applied with the index of the element as first argument,
      and the element itself as second argument. *)

  val map : (float -> float) -> t -> t
  (** [map f a] applies function [f] to all the elements of [a],
      and builds a floatarray with the results returned by [f]. *)

  val map_inplace : (float -> float) -> t -> unit
  (** [map_inplace f a] applies function [f] to all elements of [a],
      and updates their values in place.
      @since 5.1 *)

  val mapi : (int -> float -> float) -> t -> t
  (** Same as {!map}, but the
      function is applied to the index of the element as first argument,
      and the element itself as second argument. *)

  val mapi_inplace : (int -> float -> float) -> t -> unit
  (** Same as {!map_inplace}, but the function is applied to the index of the
      element as first argument, and the element itself as second argument.
      @since 5.1 *)

  val fold_left : ('acc -> float -> 'acc) -> 'acc -> t -> 'acc
  (** [fold_left f x init] computes
      [f (... (f (f x init.(0)) init.(1)) ...) init.(n-1)],
      where [n] is the length of the floatarray [init]. *)

  val fold_right : (float -> 'acc -> 'acc) -> t -> 'acc -> 'acc
  (** [fold_right f a init] computes
      [f a.(0) (f a.(1) ( ... (f a.(n-1) init) ...))],
      where [n] is the length of the floatarray [a]. *)

  (** {1 Iterators on two arrays} *)

  val iter2 : (float -> float -> unit) -> t -> t -> unit
  (** [Array.iter2 f a b] applies function [f] to all the elements of [a]
      and [b].
      @raise Invalid_argument if the floatarrays are not the same size. *)

  val map2 : (float -> float -> float) -> t -> t -> t
  (** [map2 f a b] applies function [f] to all the elements of [a]
      and [b], and builds a floatarray with the results returned by [f]:
      [[| f a.(0) b.(0); ...; f a.(length a - 1) b.(length b - 1)|]].
      @raise Invalid_argument if the floatarrays are not the same size. *)

  (** {1 Array scanning} *)

  val for_all : (float -> bool) -> t -> bool
  (** [for_all f [|a1; ...; an|]] checks if all elements of the floatarray
      satisfy the predicate [f]. That is, it returns
      [(f a1) && (f a2) && ... && (f an)]. *)

  val exists : (float -> bool) -> t -> bool
  (** [exists f [|a1; ...; an|]] checks if at least one element of
      the floatarray satisfies the predicate [f]. That is, it returns
      [(f a1) || (f a2) || ... || (f an)]. *)

  val mem : float -> t -> bool
  (** [mem a set] is true if and only if there is an element of [set] that is
      structurally equal to [a], i.e. there is an [x] in [set] such
      that [compare a x = 0]. *)

  val mem_ieee : float -> t -> bool
  (** Same as {!mem}, but uses IEEE equality instead of structural equality. *)

  (** {1 Array searching} *)

  val find_opt : (float -> bool) -> t -> float option
  (* [find_opt f a] returns the first element of the array [a] that satisfies
     the predicate [f]. Returns [None] if there is no value that satisfies [f]
     in the array [a].
     @since 5.1 *)

  val find_index : (float-> bool) -> t -> int option
  (** [find_index f a] returns [Some i], where [i] is the index of the first
      element of the array [a] that satisfies [f x], if there is such an
      element.

      It returns [None] if there is no such element.
      @since 5.1 *)

  val find_map : (float -> 'a option) -> t -> 'a option
  (* [find_map f a] applies [f] to the elements of [a] in order, and returns
     the first result of the form [Some v], or [None] if none exist.
     @since 5.1 *)

  val find_mapi : (int -> float -> 'a option) -> t -> 'a option
  (** Same as [find_map], but the predicate is applied to the index of
     the element as first argument (counting from 0), and the element
     itself as second argument.

     @since 5.1 *)

  (** {1:sorting_and_shuffling Sorting and shuffling} *)

  val sort : (float -> float -> int) -> t -> unit
  (** Sort a floatarray in increasing order according to a comparison
      function.  The comparison function must return 0 if its arguments
      compare as equal, a positive integer if the first is greater,
      and a negative integer if the first is smaller (see below for a
      complete specification).  For example, {!Stdlib.compare} is
      a suitable comparison function.  After calling [sort], the
      array is sorted in place in increasing order.
      [sort] is guaranteed to run in constant heap space
      and (at most) logarithmic stack space.

      The current implementation uses Heap Sort.  It runs in constant
      stack space.

      Specification of the comparison function:
      Let [a] be the floatarray and [cmp] the comparison function. The following
      must be true for all [x], [y], [z] in [a] :
  -      [cmp x y] > 0 if and only if [cmp y x] < 0
  -      if [cmp x y] >= 0 and [cmp y z] >= 0 then [cmp x z] >= 0

      When [sort] returns, [a] contains the same elements as before,
      reordered in such a way that for all i and j valid indices of [a] :
  -      [cmp a.(i) a.(j)] >= 0 if i >= j
  *)

  val stable_sort : (float -> float -> int) -> t -> unit
  (** Same as {!sort}, but the sorting algorithm is stable (i.e.
       elements that compare equal are kept in their original order) and
       not guaranteed to run in constant heap space.

       The current implementation uses Merge Sort. It uses a temporary
       floatarray of length [n/2], where [n] is the length of the floatarray.
       It is usually faster than the current implementation of {!sort}. *)

  val fast_sort : (float -> float -> int) -> t -> unit
  (** Same as {!sort} or {!stable_sort}, whichever is faster
      on typical input. *)

  val shuffle :
    rand: (* thwart tools/sync_stdlib_docs *) (int -> int) -> t -> unit
  (** [shuffle rand a] randomly permutes [a]'s elements using [rand]
      for randomness. The distribution of permutations is uniform.

      [rand] must be such that a call to [rand n] returns a uniformly
      distributed random number in the range \[[0];[n-1]\].
      {!Random.int} can be used for this (do not forget to
      {{!Random.self_init}initialize} the generator).

      @since 5.2 *)

  (** {1 Float arrays and Sequences} *)

  val to_seq : t -> float Seq.t
  (** Iterate on the floatarray, in increasing order. Modifications of the
      floatarray during iteration will be reflected in the sequence. *)

  val to_seqi : t -> (int * float) Seq.t
  (** Iterate on the floatarray, in increasing order, yielding indices along
      elements. Modifications of the floatarray during iteration will be
      reflected in the sequence. *)

  val of_seq : float Seq.t -> t
  (** Create an array from the generator. *)


  val map_to_array : (float -> 'a) -> t -> 'a array
  (** [map_to_array f a] applies function [f] to all the elements of [a],
      and builds an array with the results returned by [f]:
      [[| f a.(0); f a.(1); ...; f a.(length a - 1) |]]. *)

  val map_from_array : ('a -> float) -> 'a array -> t
  (** [map_from_array f a] applies function [f] to all the elements of [a],
      and builds a floatarray with the results returned by [f]. *)

  (** {1:floatarray_concurrency Arrays and concurrency safety}

      Care must be taken when concurrently accessing float arrays from multiple
      domains: accessing an array will never crash a program, but unsynchronized
      accesses might yield surprising (non-sequentially-consistent) results.

      {2:floatarray_atomicity Atomicity}

      Every float array operation that accesses more than one array element is
      not atomic. This includes iteration, scanning, sorting, splitting and
      combining arrays.

      For example, consider the following program:
  {[let size = 100_000_000
  let a = Float.Array.make size 1.
  let update a f () =
     Float.Array.iteri (fun i x -> Float.Array.set a i (f x)) a
  let d1 = Domain.spawn (update a (fun x -> x +. 1.))
  let d2 = Domain.spawn (update a (fun x ->  2. *. x +. 1.))
  let () = Domain.join d1; Domain.join d2
  ]}

      After executing this code, each field of the float array [a] is either
      [2.], [3.], [4.] or [5.]. If atomicity is required, then the user must
      implement their own synchronization (for example, using {!Mutex.t}).

      {2:floatarray_data_race Data races}

      If two domains only access disjoint parts of the array, then the
      observed behaviour is the equivalent to some sequential interleaving of
      the operations from the two domains.

      A data race is said to occur when two domains access the same array
      element without synchronization and at least one of the accesses is a
      write. In the absence of data races, the observed behaviour is equivalent
      to some sequential interleaving of the operations from different domains.

      Whenever possible, data races should be avoided by using synchronization
      to mediate the accesses to the array elements.

      Indeed, in the presence of data races, programs will not crash but the
      observed behaviour may not be equivalent to any sequential interleaving of
      operations from different domains. Nevertheless, even in the presence of
      data races, a read operation will return the value of some prior write to
      that location with a few exceptions.


      {2:floatarray_datarace_tearing Tearing }

      Float arrays have two supplementary caveats in the presence of data races.

      First, the blit operation might copy an array byte-by-byte. Data races
      between such a blit operation and another operation might produce
      surprising values due to tearing: partial writes interleaved with other
      operations can create float values that would not exist with a sequential
      execution.

      For instance, at the end of
  {[let zeros = Float.Array.make size 0.
  let max_floats = Float.Array.make size Float.max_float
  let res = Float.Array.copy zeros
  let d1 = Domain.spawn (fun () -> Float.Array.blit zeros 0 res 0 size)
  let d2 = Domain.spawn (fun () -> Float.Array.blit max_floats 0 res 0 size)
  let () = Domain.join d1; Domain.join d2
  ]}

      the [res] float array might contain values that are neither [0.]
      nor [max_float].

      Second, on 32-bit architectures, getting or setting a field involves two
      separate memory accesses. In the presence of data races, the user may
      observe tearing on any operation.
  *)

  (**/**)

  (** {1 Undocumented functions} *)

  (* These functions are for system use only. Do not call directly. *)
  external unsafe_get : t -> int -> float = "%floatarray_unsafe_get"
  external unsafe_set : t -> int -> float -> unit = "%floatarray_unsafe_set"

end
(** Float arrays with packed representation. *)

#ifdef BS
#else
module ArrayLabels : sig
  type t = floatarray
  (** The type of float arrays with packed representation.
      @since 4.08
    *)

  val length : t -> int
  (** Return the length (number of elements) of the given floatarray. *)

  val get : t -> int -> float
  (** [get a n] returns the element number [n] of floatarray [a].
      @raise Invalid_argument if [n] is outside the range 0 to
      [(length a - 1)]. *)

  val set : t -> int -> float -> unit
  (** [set a n x] modifies floatarray [a] in place, replacing element
      number [n] with [x].
      @raise Invalid_argument if [n] is outside the range 0 to
      [(length a - 1)]. *)

  val make : int -> float -> t
  (** [make n x] returns a fresh floatarray of length [n], initialized with [x].
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val create : int -> t
  (** [create n] returns a fresh floatarray of length [n],
      with uninitialized data.
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val init : int -> f:(int -> float) -> t
  (** [init n ~f] returns a fresh floatarray of length [n],
      with element number [i] initialized to the result of [f i].
      In other terms, [init n ~f] tabulates the results of [f]
      applied to the integers [0] to [n-1].
      @raise Invalid_argument if [n < 0] or [n > Sys.max_floatarray_length]. *)

  val make_matrix : dimx:int -> dimy:int -> float -> t array
  (** [make_matrix ~dimx ~dimy e] returns a two-dimensional array
      (an array of arrays) with first dimension [dimx] and
      second dimension [dimy], where all elements are initialized with [e].

      @raise Invalid_argument if [dimx] or [dimy] is negative or
      greater than {!Sys.max_floatarray_length}.

      @since 5.2 *)

  val init_matrix : dimx:int -> dimy:int -> f:(int -> int -> float) -> t array
  (** [init_matrix ~dimx ~dimy ~f] returns a two-dimensional array
      (an array of arrays)
      with first dimension [dimx] and second dimension [dimy],
      where the element at index ([x,y]) is initialized with [f x y].

      @raise Invalid_argument if [dimx] or [dimy] is negative or
      greater than {!Sys.max_floatarray_length}.

      @since 5.2 *)

  val append : t -> t -> t
  (** [append v1 v2] returns a fresh floatarray containing the
      concatenation of the floatarrays [v1] and [v2].
      @raise Invalid_argument if
      [length v1 + length v2 > Sys.max_floatarray_length]. *)

  val concat : t list -> t
  (** Same as {!append}, but concatenates a list of floatarrays. *)

  val sub : t -> pos:int -> len:int -> t
  (** [sub a ~pos ~len] returns a fresh floatarray of length [len],
      containing the elements number [pos] to [pos + len - 1]
      of floatarray [a].
      @raise Invalid_argument if [pos] and [len] do not
      designate a valid subarray of [a]; that is, if
      [pos < 0], or [len < 0], or [pos + len > length a]. *)

  val copy : t -> t
  (** [copy a] returns a copy of [a], that is, a fresh floatarray
      containing the same elements as [a]. *)

  val fill : t -> pos:int -> len:int -> float -> unit
  (** [fill a ~pos ~len x] modifies the floatarray [a] in place,
      storing [x] in elements number [pos] to [pos + len - 1].
      @raise Invalid_argument if [pos] and [len] do not
      designate a valid subarray of [a]. *)

  val blit : src:t -> src_pos:int -> dst:t -> dst_pos:int -> len:int -> unit
  (** [blit ~src ~src_pos ~dst ~dst_pos ~len] copies [len] elements
      from floatarray [src], starting at element number [src_pos],
      to floatarray [dst], starting at element number [dst_pos].
      It works correctly even if
      [src] and [dst] are the same floatarray, and the source and
      destination chunks overlap.
      @raise Invalid_argument if [src_pos] and [len] do not
      designate a valid subarray of [src], or if [dst_pos] and [len] do not
      designate a valid subarray of [dst]. *)

  val to_list : t -> float list
  (** [to_list a] returns the list of all the elements of [a]. *)

  val of_list : float list -> t
  (** [of_list l] returns a fresh floatarray containing the elements
      of [l].
      @raise Invalid_argument if the length of [l] is greater than
      [Sys.max_floatarray_length].*)

  (** {1:comparison Comparison} *)

  val equal : eq:(float -> float -> bool) -> t -> t -> bool
  (** [equal eq a b] is [true] if and only if [a] and [b] have the
      same length [n] and for all [i] in \[[0];[n-1]\], [eq a.(i) b.(i)]
      is [true].
      @since 5.4 *)

  val compare : cmp:(float -> float -> int) -> t -> t -> int
  (** [compare cmp a b] compares [a] and [b] according to the shortlex order,
      that is, shorter arrays are smaller and equal-sized arrays are compared
      in lexicographic order using [cmp] to compare elements.
      @since 5.4 *)

  (** {1 Iterators} *)

  val iter : f:(float -> unit) -> t -> unit
  (** [iter ~f a] applies function [f] in turn to all
      the elements of [a].  It is equivalent to
      [f a.(0); f a.(1); ...; f a.(length a - 1); ()]. *)

  val iteri : f:(int -> float -> unit) -> t -> unit
  (** Same as {!iter}, but the
      function is applied with the index of the element as first argument,
      and the element itself as second argument. *)

  val map : f:(float -> float) -> t -> t
  (** [map ~f a] applies function [f] to all the elements of [a],
      and builds a floatarray with the results returned by [f]. *)

  val map_inplace : f:(float -> float) -> t -> unit
  (** [map_inplace f a] applies function [f] to all elements of [a],
      and updates their values in place.
      @since 5.1 *)

  val mapi : f:(int -> float -> float) -> t -> t
  (** Same as {!map}, but the
      function is applied to the index of the element as first argument,
      and the element itself as second argument. *)

  val mapi_inplace : f:(int -> float -> float) -> t -> unit
  (** Same as {!map_inplace}, but the function is applied to the index of the
      element as first argument, and the element itself as second argument.
      @since 5.1 *)

  val fold_left : f:('acc -> float -> 'acc) -> init:'acc -> t -> 'acc
  (** [fold_left ~f x ~init] computes
      [f (... (f (f x init.(0)) init.(1)) ...) init.(n-1)],
      where [n] is the length of the floatarray [init]. *)

  val fold_right : f:(float -> 'acc -> 'acc) -> t -> init:'acc -> 'acc
  (** [fold_right f a init] computes
      [f a.(0) (f a.(1) ( ... (f a.(n-1) init) ...))],
      where [n] is the length of the floatarray [a]. *)

  (** {1 Iterators on two arrays} *)

  val iter2 : f:(float -> float -> unit) -> t -> t -> unit
  (** [Array.iter2 ~f a b] applies function [f] to all the elements of [a]
      and [b].
      @raise Invalid_argument if the floatarrays are not the same size. *)

  val map2 : f:(float -> float -> float) -> t -> t -> t
  (** [map2 ~f a b] applies function [f] to all the elements of [a]
      and [b], and builds a floatarray with the results returned by [f]:
      [[| f a.(0) b.(0); ...; f a.(length a - 1) b.(length b - 1)|]].
      @raise Invalid_argument if the floatarrays are not the same size. *)

  (** {1 Array scanning} *)

  val for_all : f:(float -> bool) -> t -> bool
  (** [for_all ~f [|a1; ...; an|]] checks if all elements of the floatarray
      satisfy the predicate [f]. That is, it returns
      [(f a1) && (f a2) && ... && (f an)]. *)

  val exists : f:(float -> bool) -> t -> bool
  (** [exists f [|a1; ...; an|]] checks if at least one element of
      the floatarray satisfies the predicate [f]. That is, it returns
      [(f a1) || (f a2) || ... || (f an)]. *)

  val mem : float -> set:t -> bool
  (** [mem a ~set] is true if and only if there is an element of [set] that is
      structurally equal to [a], i.e. there is an [x] in [set] such
      that [compare a x = 0]. *)

  val mem_ieee : float -> set:t -> bool
  (** Same as {!mem}, but uses IEEE equality instead of structural equality. *)

  (** {1 Array searching} *)

  val find_opt : f:(float -> bool) -> t -> float option
  (* [find_opt ~f a] returns the first element of the array [a] that satisfies
     the predicate [f]. Returns [None] if there is no value that satisfies [f]
     in the array [a].
     @since 5.1 *)

  val find_index : f:(float-> bool) -> t -> int option
  (** [find_index ~f a] returns [Some i], where [i] is the index of the first
      element of the array [a] that satisfies [f x], if there is such an
      element.

      It returns [None] if there is no such element.
      @since 5.1 *)

  val find_map : f:(float -> 'a option) -> t -> 'a option
  (* [find_map ~f a] applies [f] to the elements of [a] in order, and returns
     the first result of the form [Some v], or [None] if none exist.
     @since 5.1 *)

  val find_mapi : f:(int -> float -> 'a option) -> t -> 'a option
  (** Same as [find_map], but the predicate is applied to the index of
     the element as first argument (counting from 0), and the element
     itself as second argument.

     @since 5.1 *)

  (** {1:sorting_and_shuffling Sorting and shuffling} *)

  val sort : cmp:(float -> float -> int) -> t -> unit
  (** Sort a floatarray in increasing order according to a comparison
      function.  The comparison function must return 0 if its arguments
      compare as equal, a positive integer if the first is greater,
      and a negative integer if the first is smaller (see below for a
      complete specification).  For example, {!Stdlib.compare} is
      a suitable comparison function.  After calling [sort], the
      array is sorted in place in increasing order.
      [sort] is guaranteed to run in constant heap space
      and (at most) logarithmic stack space.

      The current implementation uses Heap Sort.  It runs in constant
      stack space.

      Specification of the comparison function:
      Let [a] be the floatarray and [cmp] the comparison function. The following
      must be true for all [x], [y], [z] in [a] :
  -      [cmp x y] > 0 if and only if [cmp y x] < 0
  -      if [cmp x y] >= 0 and [cmp y z] >= 0 then [cmp x z] >= 0

      When [sort] returns, [a] contains the same elements as before,
      reordered in such a way that for all i and j valid indices of [a] :
  -      [cmp a.(i) a.(j)] >= 0 if i >= j
  *)

  val stable_sort : cmp:(float -> float -> int) -> t -> unit
  (** Same as {!sort}, but the sorting algorithm is stable (i.e.
       elements that compare equal are kept in their original order) and
       not guaranteed to run in constant heap space.

       The current implementation uses Merge Sort. It uses a temporary
       floatarray of length [n/2], where [n] is the length of the floatarray.
       It is usually faster than the current implementation of {!sort}. *)

  val fast_sort : cmp:(float -> float -> int) -> t -> unit
  (** Same as {!sort} or {!stable_sort}, whichever is faster
      on typical input. *)

  val shuffle :
    rand: (* thwart tools/sync_stdlib_docs *) (int -> int) -> t -> unit
  (** [shuffle ~rand a] randomly permutes [a]'s elements using [rand]
      for randomness. The distribution of permutations is uniform.

      [rand] must be such that a call to [rand n] returns a uniformly
      distributed random number in the range \[[0];[n-1]\].
      {!Random.int} can be used for this (do not forget to
      {{!Random.self_init}initialize} the generator).

      @since 5.2 *)

  (** {1 Float arrays and Sequences} *)

  val to_seq : t -> float Seq.t
  (** Iterate on the floatarray, in increasing order. Modifications of the
      floatarray during iteration will be reflected in the sequence. *)

  val to_seqi : t -> (int * float) Seq.t
  (** Iterate on the floatarray, in increasing order, yielding indices along
      elements. Modifications of the floatarray during iteration will be
      reflected in the sequence. *)

  val of_seq : float Seq.t -> t
  (** Create an array from the generator. *)


  val map_to_array : f:(float -> 'a) -> t -> 'a array
  (** [map_to_array ~f a] applies function [f] to all the elements of [a],
      and builds an array with the results returned by [f]:
      [[| f a.(0); f a.(1); ...; f a.(length a - 1) |]]. *)

  val map_from_array : f:('a -> float) -> 'a array -> t
  (** [map_from_array ~f a] applies function [f] to all the elements of [a],
      and builds a floatarray with the results returned by [f]. *)

  (** {1:floatarray_concurrency Arrays and concurrency safety}

      Care must be taken when concurrently accessing float arrays from multiple
      domains: accessing an array will never crash a program, but unsynchronized
      accesses might yield surprising (non-sequentially-consistent) results.

      {2:floatarray_atomicity Atomicity}

      Every float array operation that accesses more than one array element is
      not atomic. This includes iteration, scanning, sorting, splitting and
      combining arrays.

      For example, consider the following program:
  {[let size = 100_000_000
  let a = Float.ArrayLabels.make size 1.
  let update a f () =
     Float.ArrayLabels.iteri ~f:(fun i x -> Float.Array.set a i (f x)) a
  let d1 = Domain.spawn (update a (fun x -> x +. 1.))
  let d2 = Domain.spawn (update a (fun x ->  2. *. x +. 1.))
  let () = Domain.join d1; Domain.join d2
  ]}

      After executing this code, each field of the float array [a] is either
      [2.], [3.], [4.] or [5.]. If atomicity is required, then the user must
      implement their own synchronization (for example, using {!Mutex.t}).

      {2:floatarray_data_race Data races}

      If two domains only access disjoint parts of the array, then the
      observed behaviour is the equivalent to some sequential interleaving of
      the operations from the two domains.

      A data race is said to occur when two domains access the same array
      element without synchronization and at least one of the accesses is a
      write. In the absence of data races, the observed behaviour is equivalent
      to some sequential interleaving of the operations from different domains.

      Whenever possible, data races should be avoided by using synchronization
      to mediate the accesses to the array elements.

      Indeed, in the presence of data races, programs will not crash but the
      observed behaviour may not be equivalent to any sequential interleaving of
      operations from different domains. Nevertheless, even in the presence of
      data races, a read operation will return the value of some prior write to
      that location with a few exceptions.


      {2:floatarray_datarace_tearing Tearing }

      Float arrays have two supplementary caveats in the presence of data races.

      First, the blit operation might copy an array byte-by-byte. Data races
      between such a blit operation and another operation might produce
      surprising values due to tearing: partial writes interleaved with other
      operations can create float values that would not exist with a sequential
      execution.

      For instance, at the end of
  {[let zeros = Float.Array.make size 0.
  let max_floats = Float.Array.make size Float.max_float
  let res = Float.Array.copy zeros
  let d1 = Domain.spawn (fun () -> Float.Array.blit zeros 0 res 0 size)
  let d2 = Domain.spawn (fun () -> Float.Array.blit max_floats 0 res 0 size)
  let () = Domain.join d1; Domain.join d2
  ]}

      the [res] float array might contain values that are neither [0.]
      nor [max_float].

      Second, on 32-bit architectures, getting or setting a field involves two
      separate memory accesses. In the presence of data races, the user may
      observe tearing on any operation.
  *)

  (**/**)

  (** {1 Undocumented functions} *)

  (* These functions are for system use only. Do not call directly. *)
  external unsafe_get : t -> int -> float = "%floatarray_unsafe_get"
  external unsafe_set : t -> int -> float -> unit = "%floatarray_unsafe_set"

end
(** Float arrays with packed representation (labeled functions). *)
#endif
