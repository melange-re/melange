[@@@mel.config { flags = [|"--mel-no-cross-module-opt"; |]}]
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

type backend_type =
  | Native
  | Bytecode
  | Other of string
(* System interface *)

(* external get_config: unit -> string * int * bool = "caml_sys_get_config" *)
external get_executable_name : unit -> string = "caml_sys_executable_name"
external argv : string array = "%sys_argv"
external big_endian : unit -> bool = "%big_endian"
external word_size : unit -> int = "%word_size"
external int_size : unit -> int = "%int_size"
(* external max_wosize : unit -> int = "%max_wosize" *)
external unix : unit -> bool = "%ostype_unix"
external win32 : unit -> bool = "%ostype_win32"
external cygwin : unit -> bool = "%ostype_cygwin"
external get_backend_type : unit -> backend_type = "%backend_type"

let executable_name = get_executable_name()

#ifdef BS
external get_os_type : unit -> string = "#os_type"
let os_type = get_os_type ()
#else
let (os_type, _, _) = get_config()
#endif
let backend_type = get_backend_type ()
let big_endian = big_endian ()
let word_size = word_size ()
let int_size = int_size ()
let unix = unix ()
let win32 = win32 ()
let cygwin = cygwin ()

#ifdef BS
let max_array_length = 2147483647 (* 2^ 31 - 1 *)
let max_floatarray_length = 2147483647
let max_string_length = 2147483647
#else
let max_array_length = max_wosize ()
let max_floatarray_length = max_array_length / (64 / word_size)
let max_string_length = word_size / 8 * max_array_length - 1
#endif
external runtime_variant : unit -> string = "caml_runtime_variant"
external runtime_parameters : unit -> string = "caml_runtime_parameters"

#ifdef BS
#else
external poll_actions : unit -> unit = "%poll"
#endif

external file_exists: string -> bool = "caml_sys_file_exists"
external is_directory : string -> bool = "caml_sys_is_directory"
external is_regular_file : string -> bool = "caml_sys_is_regular_file"
external remove: string -> unit = "caml_sys_remove"
external rename : string -> string -> unit = "caml_sys_rename"
external getenv: string -> string = "caml_sys_getenv"


#ifdef BS
external getEnv : 'a -> string -> string option = "" [@@mel.get_index]
let getenv_opt s =
    match [%external process ] with
    | None -> None
    | Some x -> getEnv x##env s
#else
external getenv_opt: string -> string option = "caml_sys_getenv_opt"
#endif

external command: string -> int = "caml_sys_system_command"
external time: unit -> (float [@unboxed]) =
  "caml_sys_time" "caml_sys_time_unboxed" [@@noalloc]
external chdir: string -> unit = "caml_sys_chdir"
external mkdir: string -> int -> unit = "caml_sys_mkdir"
external rmdir: string -> unit = "caml_sys_rmdir"
external getcwd: unit -> string = "caml_sys_getcwd"
external readdir : string -> string array = "caml_sys_read_directory"

#ifdef BS
let io_buffer_size = 65536
#else
external io_buffer_size: unit -> int = "caml_sys_io_buffer_size"
let io_buffer_size = io_buffer_size ()
#endif

let interactive = ref false

type signal = int

type signal_behavior =
    Signal_default
  | Signal_ignore
  | Signal_handle of (signal -> unit)

external signal : signal -> signal_behavior -> signal_behavior
                = "caml_install_signal_handler"

let set_signal sig_num sig_beh = ignore(signal sig_num sig_beh)

let sigabrt = -1
let sigalrm = -2
let sigfpe = -3
let sighup = -4
let sigill = -5
let sigint = -6
let sigkill = -7
let sigpipe = -8
let sigquit = -9
let sigsegv = -10
let sigterm = -11
let sigusr1 = -12
let sigusr2 = -13
let sigchld = -14
let sigcont = -15
let sigstop = -16
let sigtstp = -17
let sigttin = -18
let sigttou = -19
let sigvtalrm = -20
let sigprof = -21
let sigbus = -22
let sigpoll = -23
let sigsys = -24
let sigtrap = -25
let sigurg = -26
let sigxcpu = -27
let sigxfsz = -28
let sigio = -29
let sigwinch = -30

let signal_to_string s =
  if s = sigabrt then "SIGABRT"
  else if s = sigalrm then "SIGALRM"
  else if s = sigfpe then "SIGFPE"
  else if s = sighup then "SIGHUP"
  else if s = sigill then "SIGILL"
  else if s = sigint then "SIGINT"
  else if s = sigkill then "SIGKILL"
  else if s = sigpipe then "SIGPIPE"
  else if s = sigquit then "SIGQUIT"
  else if s = sigsegv then "SIGSEGV"
  else if s = sigterm then "SIGTERM"
  else if s = sigusr1 then "SIGUSR1"
  else if s = sigusr2 then "SIGUSR2"
  else if s = sigchld then "SIGCHLD"
  else if s = sigcont then "SIGCONT"
  else if s = sigstop then "SIGSTOP"
  else if s = sigtstp then "SIGTSTP"
  else if s = sigttin then "SIGTTIN"
  else if s = sigttou then "SIGTTOU"
  else if s = sigvtalrm then "SIGVTALRM"
  else if s = sigprof then "SIGPROF"
  else if s = sigbus then "SIGBUS"
  else if s = sigpoll then "SIGPOLL"
  else if s = sigsys then "SIGSYS"
  else if s = sigtrap then "SIGTRAP"
  else if s = sigurg then "SIGURG"
  else if s = sigxcpu then "SIGXCPU"
  else if s = sigxfsz then "SIGXFSZ"
  else if s = sigio then "SIGIO"
  else if s = sigwinch then "SIGWINCH"
  else if s < sigwinch then invalid_arg "Sys.signal_to_string"
  else "SIG(" ^ string_of_int s ^ ")"

external rev_convert_signal_number: int -> int =
  "caml_sys_rev_convert_signal_number"
external convert_signal_number: int -> int =
  "caml_sys_convert_signal_number"

let signal_of_int i =
  if i < 0 then invalid_arg "Sys.signal_of_int"
  else rev_convert_signal_number i

let signal_to_int i =
  if i < sigwinch then invalid_arg "Sys.signal_to_int"
  else convert_signal_number i

exception Break

let catch_break on =
  if on then
    set_signal sigint (Signal_handle(fun _ -> raise Break))
  else
    set_signal sigint Signal_default


external enable_runtime_warnings: bool -> unit =
  "caml_ml_enable_runtime_warnings"
external runtime_warnings_enabled: unit -> bool =
  "caml_ml_runtime_warnings_enabled"

(* The version string is found in file ../VERSION *)

(* TODO(anmonteiro): fix correct version *)
let ocaml_version = "4.14.0+mel"

let development_version = false

type extra_prefix = Plus | Tilde

type extra_info = extra_prefix * string

type ocaml_release_info = {
  major : int;
  minor : int;
  patchlevel : int;
  extra : extra_info option
}

let ocaml_release = {
  major = 4;
  minor = 14;
  patchlevel = 0;
  extra = Some (Plus, "mel")
}

(* Optimization *)

external opaque_identity : 'a -> 'a = "%opaque"

module Immediate64 = struct
  module type Non_immediate = sig
    type t
  end
  module type Immediate = sig
    type t [@@immediate]
  end

  module Make(Immediate : Immediate)(Non_immediate : Non_immediate) = struct
    type t [@@immediate64]
    type 'a repr =
      | Immediate : Immediate.t repr
      | Non_immediate : Non_immediate.t repr
    external magic : _ repr -> t repr = "%identity"
    let repr =
      if word_size = 64 then
        magic Immediate
      else
        magic Non_immediate
  end
end
