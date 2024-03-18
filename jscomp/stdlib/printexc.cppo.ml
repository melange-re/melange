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

open Printf

type t = exn = ..

let printers = Atomic.make []

let locfmt = format_of_string "File \"%s\", line %d, characters %d-%d: %s"

let fields : exn -> string = [%raw{|function(x){
  var s = ""
  var index = 1
  while ("_"+index in x){
    s += x ["_" + index];
    ++ index
  }
  if(index === 1){
    return s
  }
  return "(" + s + ")"
}
|}]

external exn_slot_id :  exn -> int  = "caml_exn_slot_id"

external exn_slot_name : exn -> string = "caml_exn_slot_name"

let use_printers x =
  let rec conv = function
    | hd :: tl ->
        (match hd x with
         | None | exception _ -> conv tl
         | Some s -> Some s)
    | [] -> None in
  conv (Atomic.get printers)

let to_string_default = function
  | Out_of_memory -> "Out of memory"
  | Stack_overflow -> "Stack overflow"
  | Match_failure(file, line, char) ->
      sprintf locfmt file line char (char+5) "Pattern matching failed"
  | Assert_failure(file, line, char) ->
      sprintf locfmt file line char (char+6) "Assertion failed"
  | Undefined_recursive_module(file, line, char) ->
      sprintf locfmt file line char (char+6) "Undefined recursive module"
  | x ->
      let constructor = exn_slot_name x in
      constructor ^ fields  x

let to_string e =
  match use_printers e with
  | Some s -> s
  | None -> to_string_default e

let print fct arg =
  try
    fct arg
  with x ->
    eprintf "Uncaught exception: %s\n" (to_string x);
    flush stderr;
    raise x

let catch fct arg =
  try
    fct arg
  with x ->
    flush stdout;
    eprintf "Uncaught exception: %s\n" (to_string x);
    exit 2

type raw_backtrace_slot
type raw_backtrace_entry = private int
type raw_backtrace = raw_backtrace_entry array

let raw_backtrace_entries bt = bt

external get_raw_backtrace:
  unit -> raw_backtrace = "caml_get_exception_raw_backtrace"

external raise_with_backtrace: exn -> raw_backtrace -> 'a
  = "%raise_with_backtrace"

(* Disable warning 37: values are constructed in the runtime *)
type[@warning "-37"] backtrace_slot =
  | Known_location of {
      is_raise   : bool;
      filename   : string;
      start_lnum : int;
      start_char : int;
      end_offset : int; (* Relative to beginning of start_lnum *)
      end_lnum   : int;
      end_char   : int; (* Relative to beginning of end_lnum line *)
      is_inline  : bool;
      defname    : string;
    }
  | Unknown_location of {
      is_raise : bool
    }

#ifdef BS
let convert_raw_backtrace_slot:
  raw_backtrace_slot -> backtrace_slot =
    fun _ -> failwith "convert_raw_backtrace_slot not implemented"
#else
external convert_raw_backtrace_slot:
  raw_backtrace_slot -> backtrace_slot = "caml_convert_raw_backtrace_slot"
#endif

external convert_raw_backtrace:
  raw_backtrace -> backtrace_slot array = "caml_convert_raw_backtrace"

let convert_raw_backtrace bt =
  try Some (convert_raw_backtrace bt)
  with Failure _ -> None

let format_backtrace_slot pos slot =
  let info is_raise =
    if is_raise then
      if pos = 0 then "Raised at" else "Re-raised at"
    else
      if pos = 0 then "Raised by primitive operation at" else "Called from"
  in
  match slot with
  | Unknown_location l ->
      if l.is_raise then
        (* compiler-inserted re-raise, skipped *) None
      else
        Some (sprintf "%s unknown location" (info false))
  | Known_location l ->
      let lines =
        if l.start_lnum = l.end_lnum then
          Printf.sprintf " %d" l.start_lnum
        else
          Printf.sprintf "s %d-%d" l.start_lnum l.end_lnum
      in
      Some (sprintf "%s %s in file \"%s\"%s, line%s, characters %d-%d"
              (info l.is_raise) l.defname l.filename
              (if l.is_inline then " (inlined)" else "")
              lines l.start_char l.end_char)

let print_exception_backtrace outchan backtrace =
  match backtrace with
  | None ->
      fprintf outchan
        "(Program not linked with -g, cannot print stack backtrace)\n"
  | Some a ->
      for i = 0 to Array.length a - 1 do
        match format_backtrace_slot i a.(i) with
          | None -> ()
          | Some str -> fprintf outchan "%s\n" str
      done

let print_raw_backtrace outchan raw_backtrace =
  print_exception_backtrace outchan (convert_raw_backtrace raw_backtrace)

(* confusingly named: prints the global current backtrace *)
let print_backtrace outchan =
  print_raw_backtrace outchan (get_raw_backtrace ())

let backtrace_to_string backtrace =
  match backtrace with
  | None ->
     "(Program not linked with -g, cannot print stack backtrace)\n"
  | Some a ->
      let b = Buffer.create 1024 in
      for i = 0 to Array.length a - 1 do
        match format_backtrace_slot i a.(i) with
          | None -> ()
          | Some str -> bprintf b "%s\n" str
      done;
      Buffer.contents b

let raw_backtrace_to_string raw_backtrace =
  backtrace_to_string (convert_raw_backtrace raw_backtrace)

let backtrace_slot_is_raise = function
  | Known_location l -> l.is_raise
  | Unknown_location l -> l.is_raise

let backtrace_slot_is_inline = function
  | Known_location l -> l.is_inline
  | Unknown_location _ -> false

type location = {
  filename : string;
  line_number : int;
  start_char : int;
  end_char : int;
  end_line : int;
  end_col : int;
}

let backtrace_slot_location = function
  | Unknown_location _ -> None
  | Known_location l ->
    Some {
      filename    = l.filename;
      line_number = l.start_lnum;
      start_char  = l.start_char;
      end_char    = l.end_offset;
      end_line    = l.end_lnum;
      end_col     = l.end_char;
    }

let backtrace_slot_defname = function
  | Unknown_location _
  | Known_location { defname = "" } -> None
  | Known_location l -> Some l.defname

let backtrace_slots raw_backtrace =
  (* The documentation of this function guarantees that Some is
     returned only if a part of the trace is usable. This gives us
     a bit more work than just convert_raw_backtrace, but it makes the
     API more user-friendly -- otherwise most users would have to
     reimplement the "Program not linked with -g, sorry" logic
     themselves. *)
  match convert_raw_backtrace raw_backtrace with
    | None -> None
    | Some backtrace ->
      let usable_slot = function
        | Unknown_location _ -> false
        | Known_location _ -> true in
      let rec exists_usable = function
        | (-1) -> false
        | i -> usable_slot backtrace.(i) || exists_usable (i - 1) in
      if exists_usable (Array.length backtrace - 1)
      then Some backtrace
      else None

let backtrace_slots_of_raw_entry entry =
  backtrace_slots [| entry |]

module Slot = struct
  type t = backtrace_slot
  let format = format_backtrace_slot
  let is_raise = backtrace_slot_is_raise
  let is_inline = backtrace_slot_is_inline
  let location = backtrace_slot_location
  let name = backtrace_slot_defname
end

let raw_backtrace_length bt = Array.length bt

external get_raw_backtrace_slot :
  raw_backtrace -> int -> raw_backtrace_slot = "caml_raw_backtrace_slot"

external get_raw_backtrace_next_slot :
  raw_backtrace_slot -> raw_backtrace_slot option
  = "caml_raw_backtrace_next_slot"

(* confusingly named:
   returns the *string* corresponding to the global current backtrace *)
let get_backtrace () = raw_backtrace_to_string (get_raw_backtrace ())

external record_backtrace: bool -> unit = "caml_record_backtrace"
external backtrace_status: unit -> bool = "caml_backtrace_status"

let rec register_printer fn =
  let old_printers = Atomic.get printers in
  let new_printers = fn :: old_printers in
  let success = Atomic.compare_and_set printers old_printers new_printers in
  if not success then register_printer fn

external get_callstack: int -> raw_backtrace = "caml_get_current_callstack"

external get_debug_info_status : unit -> int = "caml_ml_debug_info_status"

(* Descriptions for errors in startup.h. See also backtrace.c *)
let errors = [| "";
  (* FILE_NOT_FOUND *)
  "(Cannot print locations:\n \
      bytecode executable program file not found)";
  (* BAD_BYTECODE *)
  "(Cannot print locations:\n \
      bytecode executable program file appears to be corrupt)";
  (* WRONG_MAGIC *)
  "(Cannot print locations:\n \
      bytecode executable program file has wrong magic number)";
  (* NO_FDS *)
  "(Cannot print locations:\n \
      bytecode executable program file cannot be opened;\n \
      -- too many open files. Try running with OCAMLRUNPARAM=b=2)"
|]

let default_uncaught_exception_handler exn raw_backtrace =
  eprintf "Fatal error: exception %s\n" (to_string exn);
  print_raw_backtrace stderr raw_backtrace;
  let status = get_debug_info_status () in
  if status < 0 then
    prerr_endline errors.(abs status);
  flush stderr

let uncaught_exception_handler = ref default_uncaught_exception_handler

#ifdef BS
let set_uncaught_exception_handler _ = ()
#else
let set_uncaught_exception_handler fn = uncaught_exception_handler := fn
#endif

let empty_backtrace : raw_backtrace = [| |]

let try_get_raw_backtrace () =
  try
    get_raw_backtrace ()
  with _ (* Out_of_memory? *) ->
    empty_backtrace

let handle_uncaught_exception' exn debugger_in_use =
  try
    (* Get the backtrace now, in case one of the [at_exit] function
       destroys it. *)
    let raw_backtrace =
      if debugger_in_use (* Same test as in [runtime/printexc.c] *) then
        empty_backtrace
      else
        try_get_raw_backtrace ()
    in
    (try Stdlib.do_at_exit () with _ -> ());
    try
      !uncaught_exception_handler exn raw_backtrace
    with exn' ->
      let raw_backtrace' = try_get_raw_backtrace () in
      eprintf "Fatal error: exception %s\n" (to_string exn);
      print_raw_backtrace stderr raw_backtrace;
      eprintf "Fatal error in uncaught exception handler: exception %s\n"
        (to_string exn');
      print_raw_backtrace stderr raw_backtrace';
      flush stderr
  with
    | Out_of_memory ->
        prerr_endline
          "Fatal error: out of memory in uncaught exception handler"

(* This function is called by [caml_fatal_uncaught_exception] in
   [runtime/printexc.c] which expects no exception is raised. *)
let handle_uncaught_exception exn debugger_in_use =
  try
    handle_uncaught_exception' exn debugger_in_use
  with _ ->
    (* There is not much we can do at this point *)
    ()

external register_named_value : string -> 'a -> unit
  = "caml_register_named_value"

let () =
  register_named_value "Printexc.handle_uncaught_exception"
    handle_uncaught_exception
