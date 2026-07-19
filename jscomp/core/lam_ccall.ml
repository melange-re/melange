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
type lowering = Builtin of builtin | Conditional of conditional | External

type effects =
  | No_side_effects
  | May_have_side_effects
  | Depends_on_arguments of conditional

type result_kind = Unknown | Boolean

type t = {
  prim_name : string;
  lowering : lowering;
  effects : effects;
  result_kind : result_kind;
}

let make ?(effects = May_have_side_effects) ?(result_kind = Unknown) prim_name
    lowering =
  { prim_name; lowering; effects; result_kind }

let builtin ?effects ?result_kind prim_name builtin =
  make ?effects ?result_kind prim_name (Builtin builtin)

let runtime ?effects ?result_kind prim_name runtime_module runtime_name =
  builtin ?effects ?result_kind prim_name
    (Runtime_call (runtime_module, runtime_name))

let runtime_primitive ?effects ?result_kind prim_name runtime_module =
  runtime ?effects ?result_kind prim_name runtime_module Primitive_name

let boolean_builtin ?effects prim_name lowering =
  builtin ?effects ~result_kind:Boolean prim_name lowering

let boolean_runtime_primitive ?effects prim_name runtime_module =
  runtime_primitive ?effects ~result_kind:Boolean prim_name runtime_module

(* Keep all name-based C-call classification here. Once a primitive enters
   [Lam_primitive.Pccall], consumers operate on this typed description. *)
let of_name prim_name =
  match prim_name with
  | "caml_add_float" -> builtin prim_name Float_add
  | "caml_div_float" -> builtin prim_name Float_div
  | "caml_sub_float" -> builtin prim_name Float_sub
  | "caml_eq_float" -> boolean_builtin prim_name Float_equal
  | "caml_ge_float" -> boolean_builtin prim_name Float_greater_equal
  | "caml_gt_float" -> boolean_builtin prim_name Float_greater
  | "caml_float_of_int" | "caml_int32_of_int" | "caml_nativeint_of_int"
  | "caml_nativeint_of_int32" | "caml_int32_to_float" | "caml_int32_to_int"
  | "caml_nativeint_to_int" | "caml_nativeint_to_float"
  | "caml_nativeint_to_int32" ->
      builtin prim_name Identity
  | "caml_int32_of_float" | "caml_int_of_float" | "caml_nativeint_of_float" ->
      builtin prim_name To_int32
  | "caml_bytes_greaterthan" | "caml_bytes_greaterequal" | "caml_bytes_lessthan"
  | "caml_bytes_lessequal" | "caml_bytes_equal" ->
      boolean_runtime_primitive prim_name Bytes
  | "caml_bytes_compare" -> runtime_primitive prim_name Bytes
  | "caml_int64_succ" -> builtin prim_name (Int64 Int64_succ)
  | "caml_int64_to_string" -> builtin prim_name (Int64 Int64_to_string)
  | "caml_int64_equal_null" ->
      boolean_builtin prim_name (Int64 Int64_equal_null)
  | "caml_int64_equal_undefined" ->
      boolean_builtin prim_name (Int64 Int64_equal_undefined)
  | "caml_int64_equal_nullable" ->
      boolean_builtin prim_name (Int64 Int64_equal_nullable)
  | "caml_int64_to_float" -> builtin prim_name (Int64 Int64_to_float)
  | "caml_int64_of_float" -> builtin prim_name (Int64 Int64_of_float)
  | "caml_int64_compare" -> builtin prim_name (Int64 Int64_compare)
  | "caml_int64_bits_of_float" -> builtin prim_name (Int64 Int64_bits_of_float)
  | "caml_int64_float_of_bits" ->
      (* More safe to check if arguments are constant. This has no observable
         side effect. *)
      builtin ~effects:No_side_effects prim_name (Int64 Int64_float_of_bits)
  | "caml_int64_bswap" -> builtin prim_name (Int64 Int64_bswap)
  | "caml_int64_min" -> builtin prim_name (Int64 Int64_min)
  | "caml_int64_max" -> builtin prim_name (Int64 Int64_max)
  | "caml_int32_float_of_bits" | "caml_int32_bits_of_float" | "caml_modf_float"
  | "caml_ldexp_float" | "caml_frexp_float" | "caml_copysign_float"
  | "caml_expm1_float" | "caml_hypot_float" ->
      runtime_primitive prim_name Float
  | "caml_signbit_float" -> boolean_runtime_primitive prim_name Float
  | "caml_fmod_float" ->
      (* Float module, like the JavaScript Number module. *)
      builtin prim_name Float_mod
  | "caml_fma_float" -> builtin prim_name Float_fma
  | "caml_string_equal" -> boolean_builtin prim_name (String_comparison Eq)
  | "caml_string_notequal" -> boolean_builtin prim_name (String_comparison Ne)
  | "caml_string_lessequal" -> boolean_builtin prim_name (String_comparison Le)
  | "caml_string_lessthan" -> boolean_builtin prim_name (String_comparison Lt)
  | "caml_string_greaterequal" ->
      boolean_builtin prim_name (String_comparison Ge)
  | "caml_string_greaterthan" ->
      boolean_builtin prim_name (String_comparison Gt)
  | "caml_string_repeat" ->
      builtin ~effects:No_side_effects prim_name String_repeat
  | "caml_bool_notequal" -> boolean_builtin prim_name (Bool_comparison Ne)
  | "caml_bool_lessequal" -> boolean_builtin prim_name (Bool_comparison Le)
  | "caml_bool_lessthan" -> boolean_builtin prim_name (Bool_comparison Lt)
  | "caml_bool_greaterequal" -> boolean_builtin prim_name (Bool_comparison Ge)
  | "caml_bool_greaterthan" -> boolean_builtin prim_name (Bool_comparison Gt)
  | "caml_bool_equal" | "caml_bool_equal_null" | "caml_bool_equal_nullable"
  | "caml_bool_equal_undefined" ->
      boolean_builtin prim_name (Bool_comparison Eq)
  | "caml_int_equal_null" | "caml_int_equal_nullable"
  | "caml_int_equal_undefined" | "caml_int32_equal_null"
  | "caml_int32_equal_nullable" | "caml_int32_equal_undefined" ->
      boolean_builtin prim_name Int_equal
  | "caml_float_equal_null" | "caml_float_equal_nullable"
  | "caml_float_equal_undefined" ->
      boolean_builtin prim_name Float_nullable_equal
  | "caml_string_equal_null" | "caml_string_equal_nullable"
  | "caml_string_equal_undefined" ->
      boolean_builtin prim_name String_nullable_equal
  | "caml_create_bytes" ->
      builtin ~effects:No_side_effects prim_name Create_bytes
  | "caml_bool_compare" -> builtin prim_name Bool_compare
  | "caml_int_compare" -> runtime_primitive prim_name Caml_primitive
  | "caml_int32_compare" ->
      runtime prim_name Caml_primitive (Runtime_name "caml_int_compare")
  | "caml_float_compare" | "caml_string_compare" ->
      runtime_primitive prim_name Caml_primitive
  | "caml_bool_min" -> boolean_builtin prim_name Min
  | "caml_int_min" | "caml_float_min" | "caml_string_min" | "caml_int32_min" ->
      builtin prim_name Min
  | "caml_bool_max" -> boolean_builtin prim_name Max
  | "caml_int_max" | "caml_float_max" | "caml_string_max" | "caml_int32_max" ->
      builtin prim_name Max
  | "caml_string_get" -> runtime prim_name String (Runtime_name "get")
  | "caml_fill_bytes" | "bytes_to_string" | "bytes_of_string"
  | "caml_blit_string" | "caml_blit_bytes" ->
      runtime_primitive prim_name Bytes
  (* unit -> unit
     _ -> unit
     major_slice : int -> int *)
  | "caml_backtrace_status" | "caml_get_exception_backtrace"
  | "caml_get_exception_raw_backtrace" | "caml_record_backtrace"
  | "caml_convert_raw_backtrace" | "caml_get_current_callstack" ->
      builtin prim_name Unit
  (* We captured exception/extension creation in the early pass. These
     primitives only operate on the resulting identifier. *)
  | "caml_exn_slot_id" | "caml_exn_slot_name" ->
      runtime_primitive prim_name Exceptions
  | "caml_is_extension" -> boolean_runtime_primitive prim_name Exceptions
  (* | "caml_as_js_exn" -> call Js_runtime_modules.caml_js_exceptions *)
  | "caml_set_oo_id" ->
      (* Needed in [CamlinternalOO.set_id]. *)
      runtime_primitive prim_name Oo
  (* TODO: refine. Inlining these is helpful for DCE:
     {[ external get_argv : unit -> string * string array = "caml_sys_get_argv" ]}

     A possible inline representation was:
     {[ Js_of_lam_tuple.make
          [ E.str "cmd"; Js_of_lam_array.make_array NA Pgenarray [] ] ]} *)
  | "caml_sys_executable_name" ->
      runtime_primitive ~effects:No_side_effects prim_name Sys
  | "caml_sys_argv" -> runtime_primitive ~effects:No_side_effects prim_name Sys
  | "caml_sys_time" | "caml_sys_getenv" | "caml_sys_system_command"
  | "caml_sys_getcwd" (* Check browser or Node.js. *) | "caml_sys_exit" ->
      runtime_primitive prim_name Sys
  | "caml_sys_is_directory" -> boolean_runtime_primitive prim_name Sys
  (* | "caml_sys_file_exists" *)
  | "caml_lex_engine" | "caml_new_lex_engine" ->
      runtime_primitive prim_name Lexer
  | "caml_parse_engine" | "caml_set_parser_trace" ->
      runtime_primitive prim_name Parser
  | "caml_make_float_vect" | "caml_array_create_float"
  | "caml_floatarray_create" ->
      (* TODO: compile float arrays into TypedArray. *)
      runtime prim_name Array (Runtime_name "make_float")
  | "caml_array_sub" -> runtime prim_name Array (Runtime_name "sub")
  | "caml_array_concat" ->
      (* [concat : 'a array list -> 'a array] is not good for inlining. *)
      runtime prim_name Array (Runtime_name "concat")
  | "caml_array_blit" -> runtime prim_name Array (Runtime_name "blit")
  | "caml_make_vect" | "caml_array_make" ->
      runtime ~effects:No_side_effects prim_name Array (Runtime_name "make")
  | "caml_ml_flush" | "caml_ml_out_channels_list" | "caml_ml_output_char"
  | "caml_ml_output" ->
      runtime_primitive prim_name Io
  | "caml_array_dup" -> builtin ~effects:No_side_effects prim_name Array_dup
  | "caml_format_float" | "caml_hexstring_of_float" | "caml_nativeint_format"
  | "caml_int32_format" | "caml_float_of_string"
  | "caml_int_of_string" (* What is the semantics? *) | "caml_int32_of_string"
  | "caml_nativeint_of_string" | "caml_int64_format" | "caml_int64_of_string"
  | "caml_format_int" ->
      runtime_primitive prim_name Format
  | "caml_obj_dup" -> runtime_primitive ~effects:No_side_effects prim_name Obj
  | "caml_notequal" ->
      boolean_builtin prim_name (Polymorphic_comparison Polymorphic_not_equal)
  | "caml_equal" ->
      boolean_builtin prim_name (Polymorphic_comparison Polymorphic_equal)
  | "caml_greaterequal" | "caml_greaterthan" | "caml_lessequal"
  | "caml_lessthan" | "caml_equal_null" | "caml_equal_undefined"
  | "caml_equal_nullable" ->
      boolean_builtin prim_name (Polymorphic_comparison Polymorphic_other)
  | "caml_min" | "caml_max" | "caml_compare" ->
      builtin prim_name (Polymorphic_comparison Polymorphic_other)
  | "caml_obj_tag" -> builtin prim_name Obj_tag
  | "caml_get_public_method" -> runtime_primitive prim_name Oo
  | "caml_install_signal_handler" -> builtin prim_name Install_signal_handler
  | "caml_md5_string" | "caml_md5_bytes" -> runtime_primitive prim_name Md5
  | "caml_hash_mix_string" | "caml_hash_mix_int" | "caml_hash_final_mix" ->
      runtime_primitive prim_name Hash_primitive
  | "caml_hash" | "caml_string_hash" -> runtime_primitive prim_name Hash
  | "nativeint_add" ->
      builtin ~effects:No_side_effects prim_name (Nativeint Nativeint_add)
  | "nativeint_div" ->
      builtin ~effects:No_side_effects prim_name (Nativeint Nativeint_div)
  | "nativeint_mod" ->
      builtin ~effects:No_side_effects prim_name (Nativeint Nativeint_mod)
  | "nativeint_lsr" ->
      builtin ~effects:No_side_effects prim_name (Nativeint Nativeint_lsr)
  | "nativeint_mul" ->
      builtin ~effects:No_side_effects prim_name (Nativeint Nativeint_mul)
  | "caml_ml_open_descriptor_in" ->
      make ~effects:(Depends_on_arguments Open_descriptor_in) prim_name
        (Conditional Open_descriptor_in)
  | "caml_ml_open_descriptor_out" ->
      make ~effects:(Depends_on_arguments Open_descriptor_out) prim_name
        (Conditional Open_descriptor_out)
  | "caml_register_named_value" ->
      (* Registering with the C runtime does not make sense in Melange. Keep
         the call effectful so its arguments are still evaluated, then lower
         the primitive itself to unit. *)
      builtin ~effects:May_have_side_effects prim_name Unit
  | "caml_sys_get_config" ->
      (* Should be fine to eliminate when unused. *)
      make ~effects:No_side_effects prim_name External
  | _ ->
      (* "caml_alloc_dummy"; *)
      (* TODO: "caml_alloc_dummy_float". *)
      make prim_name External

let name t = t.prim_name
let lowering t = t.lowering
let effects t = t.effects
let result_kind t = t.result_kind

let returns_boolean t =
  match t.result_kind with Boolean -> true | Unknown -> false

let is_relocatable t =
  match t.lowering with Builtin _ -> true | Conditional _ | External -> false

let equal left right = String.equal left.prim_name right.prim_name
let int_compare = of_name "caml_int_compare"
let float_compare = of_name "caml_float_compare"
let int32_compare = of_name "caml_int32_compare"
let int64_compare = of_name "caml_int64_compare"
let string_equal = of_name "caml_string_equal"
let obj_dup = of_name "caml_obj_dup"
