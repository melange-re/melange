(** JavaScript BigInt API *)

type t

external make : 'a -> t = "BigInt"
(**
  [make repr] creates a new BigInt from the representation [repr]. [repr] can
  be a number, a string, boolean, etc.
 *)

external asIntN : precision:int -> t -> t = "asIntN"
[@@mel.scope "BigInt"]
(**
  [asIntN ~precision bigint] truncates the BigInt value of [bigint] to the
  given number of least significant bits specified by [precision] and returns
  that value as a signed integer. *)

external asUintN : precision:int -> t -> t = "asUintN"
[@@mel.scope "BigInt"]
(**
  [asUintN ~precision bigint] truncates the BigInt value of [bigint] to the
  given number of least significant bits specified by [precision] and returns
  that value as an unsigned integer. *)

type toLocaleStringOptions = { style : string; currency : string }

external toLocaleString :
  locale:string -> ?options:toLocaleStringOptions -> string = "toLocaleString"
[@@mel.send.pipe: t]
(**
  [toLocaleString bigint] returns a string with a language-sensitive
  representation of this BigInt. *)

external toString : t -> string = "toLocaleString"
[@@mel.send]
(**
    [toString bigint] returns a string representing the specified BigInt value.
 *)

external neg : t -> t = "%negfloat"
external add : t -> t -> t = "%addfloat"

external sub : t -> t -> t = "%subfloat"
(** Subtraction. *)

external mul : t -> t -> t = "%mulfloat"
(** Multiplication. *)

external div : t -> t -> t = "%divfloat"
(** Division. *)

external rem : t -> t -> t = "caml_fmod_float" "fmod"
