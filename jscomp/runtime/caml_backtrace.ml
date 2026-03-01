(* Copyright (C) 2026 Contributors to Melange
 *
 * This file is distributed under the terms of the GNU Lesser General Public
 * License version 3, with the special exception on linking described in the
 * file LICENSE.
 *)

let record_backtrace = ref false
let last_raw_backtrace : int array ref = ref [||]

let caml_backtrace_status () = record_backtrace.contents
let caml_get_exception_backtrace () = ""
let caml_get_exception_raw_backtrace () : int array = last_raw_backtrace.contents
let caml_record_backtrace flag = record_backtrace.contents <- flag
let caml_convert_raw_backtrace _ = [||]
let caml_get_current_callstack _ : int array = [||]
let caml_restore_raw_backtrace _exn bt =
  last_raw_backtrace.contents <- (Obj.magic bt : int array)
