type runtime_module =
  | Bytes
  | Float
  | Caml_primitive
  | String
  | Exceptions
  | Oo
  | Sys
  | Lexer
  | Parser
  | Array
  | Io
  | Format
  | Obj
  | Md5
  | Hash_primitive
  | Hash

type runtime_name = Primitive_name | Runtime_name of string
type comparison = Eq | Ne | Le | Lt | Ge | Gt

type int64_operation =
  | Int64_succ
  | Int64_to_string
  | Int64_equal_null
  | Int64_equal_undefined
  | Int64_equal_nullable
  | Int64_to_float
  | Int64_of_float
  | Int64_compare
  | Int64_bits_of_float
  | Int64_float_of_bits
  | Int64_bswap
  | Int64_min
  | Int64_max

type nativeint_operation =
  | Nativeint_add
  | Nativeint_div
  | Nativeint_mod
  | Nativeint_lsr
  | Nativeint_mul

type polymorphic_comparison =
  | Polymorphic_equal
  | Polymorphic_not_equal
  | Polymorphic_other

type builtin =
  | Float_add
  | Float_div
  | Float_sub
  | Float_equal
  | Float_greater_equal
  | Float_greater
  | Identity
  | To_int32
  | Runtime_call of runtime_module * runtime_name
  | Int64 of int64_operation
  | Float_mod
  | Float_fma
  | String_repeat
  | String_comparison of comparison
  | Bool_comparison of comparison
  | Int_equal
  | Float_nullable_equal
  | String_nullable_equal
  | Create_bytes
  | Bool_compare
  | Min
  | Max
  | Unit
  | Array_dup
  | Polymorphic_comparison of polymorphic_comparison
  | Obj_tag
  | Install_signal_handler
  | Nativeint of nativeint_operation

type conditional = Open_descriptor_in | Open_descriptor_out
type effects = No_side_effects | May_have_side_effects

type behavior =
  | Builtin of builtin * effects
  | Conditional of conditional
  | External of effects

type result_kind = Unknown | Boolean

type t
(** A C-call classified for lowering and Lambda analysis. *)

val of_name : string -> t
(** The only boundary that converts a primitive name to its typed
    classification. *)

val name : t -> string
val behavior : t -> behavior

val resolve_conditional :
  conditional -> int32 -> (runtime_module * string) option
(** Select the shared lowering/effect case for a constant argument. *)

val result_kind : t -> result_kind
val returns_boolean : t -> bool
val is_relocatable : t -> bool
val equal : t -> t -> bool
val int_compare : t
val float_compare : t
val int32_compare : t
val int64_compare : t
val string_equal : t
val obj_dup : t
