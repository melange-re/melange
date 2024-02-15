[@@@mel.config {flags = [|"-w";"a"|]}]
module Config : sig
#1 "config.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* System configuration *)

val version: string
        (* The current version number of the system *)

val standard_library: string
        (* The directory containing the standard libraries *)
val standard_runtime: string
        (* The full path to the standard bytecode interpreter ocamlrun *)
val ccomp_type: string
        (* The "kind" of the C compiler, assembler and linker used: one of
               "cc" (for Unix-style C compilers)
               "msvc" (for Microsoft Visual C++ and MASM) *)
val bytecomp_c_compiler: string
        (* The C compiler to use for compiling C files
           with the bytecode compiler *)
val bytecomp_c_libraries: string
        (* The C libraries to link with custom runtimes *)
val native_c_compiler: string
        (* The C compiler to use for compiling C files
           with the native-code compiler *)
val native_c_libraries: string
        (* The C libraries to link with native-code programs *)
val native_pack_linker: string
        (* The linker to use for packaging (ocamlopt -pack) and for partial
           links (ocamlopt -output-obj). *)
val mkdll: string
        (* The linker command line to build dynamic libraries. *)
val mkexe: string
        (* The linker command line to build executables. *)
val mkmaindll: string
        (* The linker command line to build main programs as dlls. *)
val ranlib: string
        (* Command to randomize a library, or "" if not needed *)
val ar: string
        (* Name of the ar command, or "" if not needed  (MSVC) *)
val cc_profile : string
        (* The command line option to the C compiler to enable profiling. *)

val load_path: string list ref
        (* Directories in the search path for .cmi and .cmo files *)

val interface_suffix: string ref
        (* Suffix for interface file names *)

val exec_magic_number: string
        (* Magic number for bytecode executable files *)
val cmi_magic_number: string
        (* Magic number for compiled interface files *)
val cmo_magic_number: string
        (* Magic number for object bytecode files *)
val cma_magic_number: string
        (* Magic number for archive files *)
val cmx_magic_number: string
        (* Magic number for compilation unit descriptions *)
val cmxa_magic_number: string
        (* Magic number for libraries of compilation unit descriptions *)
val ast_intf_magic_number: string
        (* Magic number for file holding an interface syntax tree *)
val ast_impl_magic_number: string
        (* Magic number for file holding an implementation syntax tree *)
val cmxs_magic_number: string
        (* Magic number for dynamically-loadable plugins *)
val cmt_magic_number: string
        (* Magic number for compiled interface files *)

val max_tag: int
        (* Biggest tag that can be stored in the header of a regular block. *)
val lazy_tag : int
        (* Normally the same as Obj.lazy_tag.  Separate definition because
           of technical reasons for bootstrapping. *)
val max_young_wosize: int
        (* Maximal size of arrays that are directly allocated in the
           minor heap *)
val stack_threshold: int
        (* Size in words of safe area at bottom of VM stack,
           see byterun/config.h *)

val architecture: string
        (* Name of processor type for the native-code compiler *)
val model: string
        (* Name of processor submodel for the native-code compiler *)
val system: string
        (* Name of operating system for the native-code compiler *)

val asm: string
        (* The assembler (and flags) to use for assembling
           ocamlopt-generated code. *)

val asm_cfi_supported: bool
        (* Whether assembler understands CFI directives *)
val with_frame_pointers : bool
        (* Whether assembler should maintain frame pointers *)

val ext_obj: string
        (* Extension for object files, e.g. [.o] under Unix. *)
val ext_asm: string
        (* Extension for assembler files, e.g. [.s] under Unix. *)
val ext_lib: string
        (* Extension for library files, e.g. [.a] under Unix. *)
val ext_dll: string
        (* Extension for dynamically-loaded libraries, e.g. [.so] under Unix.*)

val default_executable_name: string
        (* Name of executable produced by linking if none is given with -o,
           e.g. [a.out] under Unix. *)

val systhread_supported : bool
        (* Whether the system thread library is implemented *)

val host : string
        (* Whether the compiler is a cross-compiler *)

val target : string
        (* Whether the compiler is a cross-compiler *)

val print_config : out_channel -> unit;;

end = struct
#1 "config.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(***********************************************************************)
(**                                                                   **)
(**               WARNING WARNING WARNING                             **)
(**                                                                   **)
(** When you change this file, you must make the parallel change      **)
(** in config.mlbuild                                                 **)
(**                                                                   **)
(***********************************************************************)


(* The main OCaml version string has moved to ../VERSION *)
let version = Sys.ocaml_version

let standard_library_default = "/Users/chenglou/Github/bucklescript/vendor/ocaml/lib/ocaml"

let standard_library =

  try
    Sys.getenv "BSLIB"
  with Not_found ->

    standard_library_default

let standard_runtime = "/Users/chenglou/Github/bucklescript/vendor/ocaml/bin/ocamlrun"
let ccomp_type = "cc"
let bytecomp_c_compiler = "gcc -O  -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -O "
let bytecomp_c_libraries = "-lcurses -lpthread"
let native_c_compiler = "gcc -O  -D_FILE_OFFSET_BITS=64 -D_REENTRANT"
let native_c_libraries = ""
let native_pack_linker = "ld -r -arch x86_64  -o "
let ranlib = "ranlib"
let ar = "ar"
let cc_profile = "-pg"
let mkdll = "gcc -bundle -flat_namespace -undefined suppress -Wl,-no_compact_unwind"
let mkexe = "gcc -Wl,-no_compact_unwind"
let mkmaindll = "gcc -bundle -flat_namespace -undefined suppress -Wl,-no_compact_unwind"

let exec_magic_number = "Caml1999X011"
and cmi_magic_number = "Caml1999I017"
and cmo_magic_number = "Caml1999O010"
and cma_magic_number = "Caml1999A011"
and cmx_magic_number = "Caml1999Y014"
and cmxa_magic_number = "Caml1999Z013"
and ast_impl_magic_number = "Caml1999M016"
and ast_intf_magic_number = "Caml1999N015"
and cmxs_magic_number = "Caml2007D002"
and cmt_magic_number = "Caml2012T004"

let load_path = ref ([] : string list)

let interface_suffix = ref ".mli"

let max_tag = 245
(* This is normally the same as in obj.ml, but we have to define it
   separately because it can differ when we're in the middle of a
   bootstrapping phase. *)
let lazy_tag = 246

let max_young_wosize = 256
let stack_threshold = 256 (* see byterun/config.h *)

let architecture = "amd64"
let model = "default"
let system = "macosx"

let asm = "clang -arch x86_64 -c"
let asm_cfi_supported = true
let with_frame_pointers = false

let ext_obj = ".o"
let ext_asm = ".s"
let ext_lib = ".a"
let ext_dll = ".so"

let host = "x86_64-apple-darwin18.2.0"
let target = "x86_64-apple-darwin18.2.0"

let default_executable_name =
  match Sys.os_type with
    "Unix" -> "a.out"
  | "Win32" | "Cygwin" -> "camlprog.exe"
  | _ -> "camlprog"

let systhread_supported = true;;

let print_config oc =
  let p name valu = Printf.fprintf oc "%s: %s\n" name valu in
  let p_bool name valu = Printf.fprintf oc "%s: %B\n" name valu in
  p "version" version;
  p "standard_library_default" standard_library_default;
  p "standard_library" standard_library;
  p "standard_runtime" standard_runtime;
  p "ccomp_type" ccomp_type;
  p "bytecomp_c_compiler" bytecomp_c_compiler;
  p "bytecomp_c_libraries" bytecomp_c_libraries;
  p "native_c_compiler" native_c_compiler;
  p "native_c_libraries" native_c_libraries;
  p "native_pack_linker" native_pack_linker;
  p "ranlib" ranlib;
  p "cc_profile" cc_profile;
  p "architecture" architecture;
  p "model" model;
  p "system" system;
  p "asm" asm;
  p_bool "asm_cfi_supported" asm_cfi_supported;
  p_bool "with_frame_pointers" with_frame_pointers;
  p "ext_obj" ext_obj;
  p "ext_asm" ext_asm;
  p "ext_lib" ext_lib;
  p "ext_dll" ext_dll;
  p "os_type" Sys.os_type;
  p "default_executable_name" default_executable_name;
  p_bool "systhread_supported" systhread_supported;
  p "host" host;
  p "target" target;

  (* print the magic number *)
  p "exec_magic_number" exec_magic_number;
  p "cmi_magic_number" cmi_magic_number;
  p "cmo_magic_number" cmo_magic_number;
  p "cma_magic_number" cma_magic_number;
  p "cmx_magic_number" cmx_magic_number;
  p "cmxa_magic_number" cmxa_magic_number;
  p "ast_impl_magic_number" ast_impl_magic_number;
  p "ast_intf_magic_number" ast_intf_magic_number;
  p "cmxs_magic_number" cmxs_magic_number;
  p "cmt_magic_number" cmt_magic_number;

  flush oc;
;;

end
module Clflags : sig
#1 "clflags.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 2005 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

val objfiles : string list ref
val ccobjs : string list ref
val dllibs : string list ref
val compile_only : bool ref
val output_name : string option ref
val include_dirs : string list ref
val no_std_include : bool ref
val print_types : bool ref
val make_archive : bool ref
val debug : bool ref
val fast : bool ref
val link_everything : bool ref
val custom_runtime : bool ref
val no_check_prims : bool ref
val bytecode_compatible_32 : bool ref
val output_c_object : bool ref
val output_complete_object : bool ref
val all_ccopts : string list ref
val classic : bool ref
val nopervasives : bool ref
val open_modules : string list ref
val preprocessor : string option ref
val all_ppx : string list ref
val annotations : bool ref
val binary_annotations : bool ref
val use_threads : bool ref
val use_vmthreads : bool ref
val noassert : bool ref
val verbose : bool ref
val noprompt : bool ref
val nopromptcont : bool ref
val init_file : string option ref
val noinit : bool ref
val use_prims : string ref
val use_runtime : string ref
val principal : bool ref
val real_paths : bool ref
val recursive_types : bool ref
val strict_sequence : bool ref
val strict_formats : bool ref
val applicative_functors : bool ref
val make_runtime : bool ref
val gprofile : bool ref
val c_compiler : string option ref
val no_auto_link : bool ref
val dllpaths : string list ref
val make_package : bool ref
val for_package : string option ref
val error_size : int ref
val float_const_prop : bool ref
val transparent_modules : bool ref
val dump_source : bool ref
val dump_parsetree : bool ref
val dump_typedtree : bool ref
val dump_rawlambda : bool ref
val dump_lambda : bool ref
val dump_clambda : bool ref
val dump_instr : bool ref
val keep_asm_file : bool ref
val optimize_for_speed : bool ref
val dump_cmm : bool ref
val dump_selection : bool ref
val dump_cse : bool ref
val dump_live : bool ref
val dump_spill : bool ref
val dump_split : bool ref
val dump_interf : bool ref
val dump_prefer : bool ref
val dump_regalloc : bool ref
val dump_reload : bool ref
val dump_scheduling : bool ref
val dump_linear : bool ref
val keep_startup_file : bool ref
val dump_combine : bool ref
val native_code : bool ref
val inline_threshold : int ref
val dont_write_files : bool ref
val std_include_flag : string -> string
val std_include_dir : unit -> string list
val shared : bool ref
val dlcode : bool ref
val runtime_variant : string ref
val force_slash : bool ref
val keep_docs : bool ref
val keep_locs : bool ref
val unsafe_string : bool ref
val opaque : bool ref



type mli_status = Mli_na | Mli_exists | Mli_non_exists
val no_implicit_current_dir : bool ref
val assume_no_mli : mli_status ref
val record_event_when_debug : bool ref
val bs_vscode : bool
val dont_record_crc_unit : string option ref
val bs_only : bool ref (* set true on bs top*)
val no_assert_false : bool ref


type color_setting = Auto | Always | Never
val parse_color_setting : string -> color_setting option
val color : color_setting option ref


end = struct
#1 "clflags.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Command-line parameters *)

let objfiles = ref ([] : string list)   (* .cmo and .cma files *)
and ccobjs = ref ([] : string list)     (* .o, .a, .so and -cclib -lxxx *)
and dllibs = ref ([] : string list)     (* .so and -dllib -lxxx *)

let compile_only = ref false            (* -c *)
and output_name = ref (None : string option) (* -o *)
and include_dirs = ref ([] : string list)(* -I *)
and no_std_include = ref false          (* -nostdlib *)
and print_types = ref false             (* -i *)
and make_archive = ref false            (* -a *)
and debug = ref false                   (* -g *)
and fast = ref false                    (* -unsafe *)
and link_everything = ref false         (* -linkall *)
and custom_runtime = ref false          (* -custom *)
and no_check_prims = ref false          (* -no-check-prims *)
and bytecode_compatible_32 = ref false  (* -compat-32 *)
and output_c_object = ref false         (* -output-obj *)
and output_complete_object = ref false  (* -output-complete-obj *)
and all_ccopts = ref ([] : string list)     (* -ccopt *)
and classic = ref false                 (* -nolabels *)
and nopervasives = ref false            (* -nopervasives *)
and preprocessor = ref(None : string option) (* -pp *)
and all_ppx = ref ([] : string list)        (* -ppx *)
let annotations = ref false             (* -annot *)
let binary_annotations = ref false      (* -annot *)
and use_threads = ref false             (* -thread *)
and use_vmthreads = ref false           (* -vmthread *)
and noassert = ref false                (* -noassert *)
and verbose = ref false                 (* -verbose *)
and noprompt = ref false                (* -noprompt *)
and nopromptcont = ref false            (* -nopromptcont *)
and init_file = ref (None : string option)   (* -init *)
and noinit = ref false                  (* -noinit *)
and open_modules = ref []               (* -open *)
and use_prims = ref ""                  (* -use-prims ... *)
and use_runtime = ref ""                (* -use-runtime ... *)
and principal = ref false               (* -principal *)
and real_paths = ref true               (* -short-paths *)
and recursive_types = ref false         (* -rectypes *)
and strict_sequence = ref false         (* -strict-sequence *)
and strict_formats = ref false          (* -strict-formats *)
and applicative_functors = ref true     (* -no-app-funct *)
and make_runtime = ref false            (* -make-runtime *)
and gprofile = ref false                (* -p *)
and c_compiler = ref (None: string option) (* -cc *)
and no_auto_link = ref false            (* -noautolink *)
and dllpaths = ref ([] : string list)   (* -dllpath *)
and make_package = ref false            (* -pack *)
and for_package = ref (None: string option) (* -for-pack *)
and error_size = ref 500                (* -error-size *)
and float_const_prop = ref true         (* -no-float-const-prop *)
and transparent_modules = ref false     (* -trans-mod *)
let dump_source = ref false             (* -dsource *)
let dump_parsetree = ref false          (* -dparsetree *)
and dump_typedtree = ref false          (* -dtypedtree *)
and dump_rawlambda = ref false          (* -drawlambda *)
and dump_lambda = ref false             (* -dlambda *)
and dump_clambda = ref false            (* -dclambda *)
and dump_instr = ref false              (* -dinstr *)

let keep_asm_file = ref false           (* -S *)
let optimize_for_speed = ref true       (* -compact *)
and opaque = ref false                  (* -opaque *)

and dump_cmm = ref false                (* -dcmm *)
let dump_selection = ref false          (* -dsel *)
let dump_cse = ref false                (* -dcse *)
let dump_live = ref false               (* -dlive *)
let dump_spill = ref false              (* -dspill *)
let dump_split = ref false              (* -dsplit *)
let dump_interf = ref false             (* -dinterf *)
let dump_prefer = ref false             (* -dprefer *)
let dump_regalloc = ref false           (* -dalloc *)
let dump_reload = ref false             (* -dreload *)
let dump_scheduling = ref false         (* -dscheduling *)
let dump_linear = ref false             (* -dlinear *)
let keep_startup_file = ref false       (* -dstartup *)
let dump_combine = ref false            (* -dcombine *)
let native_code = ref false             (* set to true under ocamlopt *)
let inline_threshold = ref 10
let force_slash = ref false             (* for ocamldep *)

let dont_write_files = ref false        (* set to true under ocamldoc *)

let std_include_flag prefix =
  if !no_std_include then ""
  else (prefix ^ (Filename.quote Config.standard_library))
;;

let std_include_dir () =
  if !no_std_include then [] else [Config.standard_library]
;;

let shared = ref false (* -shared *)
let dlcode = ref true (* not -nodynlink *)

let runtime_variant = ref "";;      (* -runtime-variant *)

let keep_docs = ref false              (* -keep-docs *)
let keep_locs = ref false              (* -keep-locs *)
let unsafe_string = ref true;;         (* -safe-string / -unsafe-string *)



type mli_status = Mli_na | Mli_exists | Mli_non_exists
let no_implicit_current_dir = ref false
let assume_no_mli = ref Mli_na
let record_event_when_debug = ref true (* turned off in BuckleScript*)
let bs_vscode =
    try ignore @@ Sys.getenv "BS_VSCODE" ; true with _ -> false
    (* We get it from environment variable mostly due to
       we don't want to rebuild when flip on or off
    *)
let dont_record_crc_unit : string option ref = ref None
let bs_only = ref false
let no_assert_false = ref false


type color_setting = Auto | Always | Never
let parse_color_setting = function
  | "auto" -> Some Auto
  | "always" -> Some Always
  | "never" -> Some Never
  | _ -> None
let color = ref None ;; (* -color *)


end
module Misc : sig
#1 "misc.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Miscellaneous useful types and functions *)

val fatal_error: string -> 'a
exception Fatal_error

val try_finally : (unit -> 'a) -> (unit -> unit) -> 'a;;

val map_end: ('a -> 'b) -> 'a list -> 'b list -> 'b list
        (* [map_end f l t] is [map f l @ t], just more efficient. *)
val map_left_right: ('a -> 'b) -> 'a list -> 'b list
        (* Like [List.map], with guaranteed left-to-right evaluation order *)
val for_all2: ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
        (* Same as [List.for_all] but for a binary predicate.
           In addition, this [for_all2] never fails: given two lists
           with different lengths, it returns false. *)
val replicate_list: 'a -> int -> 'a list
        (* [replicate_list elem n] is the list with [n] elements
           all identical to [elem]. *)
val list_remove: 'a -> 'a list -> 'a list
        (* [list_remove x l] returns a copy of [l] with the first
           element equal to [x] removed. *)
val split_last: 'a list -> 'a list * 'a
        (* Return the last element and the other elements of the given list. *)
val samelist: ('a -> 'a -> bool) -> 'a list -> 'a list -> bool
        (* Like [List.for_all2] but returns [false] if the two
           lists have different length. *)

val may: ('a -> unit) -> 'a option -> unit
val may_map: ('a -> 'b) -> 'a option -> 'b option

val find_in_path: string list -> string -> string
        (* Search a file in a list of directories. *)
val find_in_path_rel: string list -> string -> string
        (* Search a relative file in a list of directories. *)
val find_in_path_uncap: string list -> string -> string
        (* Same, but search also for uncapitalized name, i.e.
           if name is Foo.ml, allow /path/Foo.ml and /path/foo.ml
           to match. *)
val remove_file: string -> unit
        (* Delete the given file if it exists. Never raise an error. *)
val expand_directory: string -> string -> string
        (* [expand_directory alt file] eventually expands a [+] at the
           beginning of file into [alt] (an alternate root directory) *)

val create_hashtable: int -> ('a * 'b) list -> ('a, 'b) Hashtbl.t
        (* Create a hashtable of the given size and fills it with the
           given bindings. *)

val copy_file: in_channel -> out_channel -> unit
        (* [copy_file ic oc] reads the contents of file [ic] and copies
           them to [oc]. It stops when encountering EOF on [ic]. *)
val copy_file_chunk: in_channel -> out_channel -> int -> unit
        (* [copy_file_chunk ic oc n] reads [n] bytes from [ic] and copies
           them to [oc]. It raises [End_of_file] when encountering
           EOF on [ic]. *)
val string_of_file: in_channel -> string
        (* [string_of_file ic] reads the contents of file [ic] and copies
           them to a string. It stops when encountering EOF on [ic]. *)
val log2: int -> int
        (* [log2 n] returns [s] such that [n = 1 lsl s]
           if [n] is a power of 2*)
val align: int -> int -> int
        (* [align n a] rounds [n] upwards to a multiple of [a]
           (a power of 2). *)
val no_overflow_add: int -> int -> bool
        (* [no_overflow_add n1 n2] returns [true] if the computation of
           [n1 + n2] does not overflow. *)
val no_overflow_sub: int -> int -> bool
        (* [no_overflow_add n1 n2] returns [true] if the computation of
           [n1 - n2] does not overflow. *)
val no_overflow_lsl: int -> bool
        (* [no_overflow_add n] returns [true] if the computation of
           [n lsl 1] does not overflow. *)

val chop_extension_if_any: string -> string
        (* Like Filename.chop_extension but returns the initial file
           name if it has no extension *)

val chop_extensions: string -> string
        (* Return the given file name without its extensions. The extensions
           is the longest suffix starting with a period and not including
           a directory separator, [.xyz.uvw] for instance.

           Return the given name if it does not contain an extension. *)

val search_substring: string -> string -> int -> int
        (* [search_substring pat str start] returns the position of the first
           occurrence of string [pat] in string [str].  Search starts
           at offset [start] in [str].  Raise [Not_found] if [pat]
           does not occur. *)

val replace_substring: before:string -> after:string -> string -> string
        (* [search_substring ~before ~after str] replaces all occurences
           of [before] with [after] in [str] and returns the resulting string. *)

val rev_split_words: string -> string list
        (* [rev_split_words s] splits [s] in blank-separated words, and return
           the list of words in reverse order. *)

val get_ref: 'a list ref -> 'a list
        (* [get_ref lr] returns the content of the list reference [lr] and reset
           its content to the empty list. *)


val fst3: 'a * 'b * 'c -> 'a
val snd3: 'a * 'b * 'c -> 'b
val thd3: 'a * 'b * 'c -> 'c

val fst4: 'a * 'b * 'c * 'd -> 'a
val snd4: 'a * 'b * 'c * 'd -> 'b
val thd4: 'a * 'b * 'c * 'd -> 'c
val for4: 'a * 'b * 'c * 'd -> 'd

module LongString :
  sig
    type t = bytes array
    val create : int -> t
    val length : t -> int
    val get : t -> int -> char
    val set : t -> int -> char -> unit
    val blit : t -> int -> t -> int -> int -> unit
    val output : out_channel -> t -> int -> int -> unit
    val unsafe_blit_to_bytes : t -> int -> bytes -> int -> int -> unit
    val input_bytes : in_channel -> int -> t
  end

val edit_distance : string -> string -> int -> int option
(** [edit_distance a b cutoff] computes the edit distance between
    strings [a] and [b]. To help efficiency, it uses a cutoff: if the
    distance [d] is smaller than [cutoff], it returns [Some d], else
    [None].

    The distance algorithm currently used is Damerau-Levenshtein: it
    computes the number of insertion, deletion, substitution of
    letters, or swapping of adjacent letters to go from one word to the
    other. The particular algorithm may change in the future.
*)

val split : string -> char -> string list
(** [String.split string char] splits the string [string] at every char
    [char], and returns the list of sub-strings between the chars.
    [String.concat (String.make 1 c) (String.split s c)] is the identity.
    @since 4.01
 *)

val cut_at : string -> char -> string * string
(** [String.cut_at s c] returns a pair containing the sub-string before
   the first occurrence of [c] in [s], and the sub-string after the
   first occurrence of [c] in [s].
   [let (before, after) = String.cut_at s c in
    before ^ String.make 1 c ^ after] is the identity if [s] contains [c].

   Raise [Not_found] if the character does not appear in the string
   @since 4.01
*)





(* Color handling *)
module Color : sig
  type color =
    | Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White
  ;;

  type style =
    | FG of color (* foreground *)
    | BG of color (* background *)
    | Bold
    | Reset

    | Dim


  val ansi_of_style_l : style list -> string
  (* ANSI escape sequence for the given style *)

  type styles = {
    error: style list;
    warning: style list;
    loc: style list;
  }

  val default_styles: styles
  val get_styles: unit -> styles
  val set_styles: styles -> unit

  val setup : Clflags.color_setting option -> unit
  (* [setup opt] will enable or disable color handling on standard formatters
     according to the value of color setting [opt].
     Only the first call to this function has an effect. *)

  val set_color_tag_handling : Format.formatter -> unit
  (* adds functions to support color tags to the given formatter. *)
end


end = struct
#1 "misc.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Errors *)

exception Fatal_error

let fatal_error msg =
  prerr_string ">> Fatal error: "; prerr_endline msg; raise Fatal_error

(* Exceptions *)

let try_finally work cleanup =
  let result = (try work () with e -> cleanup (); raise e) in
  cleanup ();
  result
;;

(* List functions *)

let rec map_end f l1 l2 =
  match l1 with
    [] -> l2
  | hd::tl -> f hd :: map_end f tl l2

let rec map_left_right f = function
    [] -> []
  | hd::tl -> let res = f hd in res :: map_left_right f tl

let rec for_all2 pred l1 l2 =
  match (l1, l2) with
    ([], []) -> true
  | (hd1::tl1, hd2::tl2) -> pred hd1 hd2 && for_all2 pred tl1 tl2
  | (_, _) -> false

let rec replicate_list elem n =
  if n <= 0 then [] else elem :: replicate_list elem (n-1)

let rec list_remove x = function
    [] -> []
  | hd :: tl ->
      if hd = x then tl else hd :: list_remove x tl

let rec split_last = function
    [] -> assert false
  | [x] -> ([], x)
  | hd :: tl ->
      let (lst, last) = split_last tl in
      (hd :: lst, last)

let rec samelist pred l1 l2 =
  match (l1, l2) with
  | ([], []) -> true
  | (hd1 :: tl1, hd2 :: tl2) -> pred hd1 hd2 && samelist pred tl1 tl2
  | (_, _) -> false

(* Options *)

let may f = function
    Some x -> f x
  | None -> ()

let may_map f = function
    Some x -> Some (f x)
  | None -> None

(* File functions *)

let find_in_path path name =
  if not (Filename.is_implicit name) then
    if Sys.file_exists name then name else raise Not_found
  else begin
    let rec try_dir = function
      [] -> raise Not_found
    | dir::rem ->
        let fullname = Filename.concat dir name in
        if Sys.file_exists fullname then fullname else try_dir rem
    in try_dir path
  end

let find_in_path_rel path name =
  let rec simplify s =
    let open Filename in
    let base = basename s in
    let dir = dirname s in
    if dir = s then dir
    else if base = current_dir_name then simplify dir
    else concat (simplify dir) base
  in
  let rec try_dir = function
    [] -> raise Not_found
  | dir::rem ->
      let fullname = simplify (Filename.concat dir name) in
      if Sys.file_exists fullname then fullname else try_dir rem
  in try_dir path

let find_in_path_uncap path name =
  let uname = String.uncapitalize_ascii name in
  let rec try_dir = function
    [] -> raise Not_found
  | dir::rem ->
      let fullname = Filename.concat dir name
      and ufullname = Filename.concat dir uname in
      if Sys.file_exists ufullname then ufullname
      else if Sys.file_exists fullname then fullname
      else try_dir rem
  in try_dir path

let remove_file filename =
  try
    Sys.remove filename
  with Sys_error msg ->
    ()

(* Expand a -I option: if it starts with +, make it relative to the standard
   library directory *)

let expand_directory alt s =
  if String.length s > 0 && s.[0] = '+'
  then Filename.concat alt
                       (String.sub s 1 (String.length s - 1))
  else s

(* Hashtable functions *)

let create_hashtable size init =
  let tbl = Hashtbl.create size in
  List.iter (fun (key, data) -> Hashtbl.add tbl key data) init;
  tbl

(* File copy *)

let copy_file ic oc =
  let buff = Bytes.create 0x1000 in
  let rec copy () =
    let n = input ic buff 0 0x1000 in
    if n = 0 then () else (output oc buff 0 n; copy())
  in copy()

let copy_file_chunk ic oc len =
  let buff = Bytes.create 0x1000 in
  let rec copy n =
    if n <= 0 then () else begin
      let r = input ic buff 0 (min n 0x1000) in
      if r = 0 then raise End_of_file else (output oc buff 0 r; copy(n-r))
    end
  in copy len

let string_of_file ic =
  let b = Buffer.create 0x10000 in
  let buff = Bytes.create 0x1000 in
  let rec copy () =
    let n = input ic buff 0 0x1000 in
    if n = 0 then Buffer.contents b else
      (Buffer.add_subbytes b buff 0 n; copy())
  in copy()

(* Integer operations *)

let rec log2 n =
  if n <= 1 then 0 else 1 + log2(n asr 1)

let align n a =
  if n >= 0 then (n + a - 1) land (-a) else n land (-a)

let no_overflow_add a b = (a lxor b) lor (a lxor (lnot (a+b))) < 0

let no_overflow_sub a b = (a lxor (lnot b)) lor (b lxor (a-b)) < 0

let no_overflow_lsl a = min_int asr 1 <= a && a <= max_int asr 1

(* String operations *)

let chop_extension_if_any fname =
  try Filename.chop_extension fname with Invalid_argument _ -> fname

let chop_extensions file =
  let dirname = Filename.dirname file and basename = Filename.basename file in
  try
    let pos = String.index basename '.' in
    let basename = String.sub basename 0 pos in
    if Filename.is_implicit file && dirname = Filename.current_dir_name then
      basename
    else
      Filename.concat dirname basename
  with Not_found -> file

let search_substring pat str start =
  let rec search i j =
    if j >= String.length pat then i
    else if i + j >= String.length str then raise Not_found
    else if str.[i + j] = pat.[j] then search i (j+1)
    else search (i+1) 0
  in search start 0

let replace_substring ~before ~after str =
  let rec search acc curr =
    match search_substring before str curr with
      | next ->
         let prefix = String.sub str curr (next - curr) in
         search (prefix :: acc) (next + String.length before)
      | exception Not_found ->
        let suffix = String.sub str curr (String.length str - curr) in
        List.rev (suffix :: acc)
  in String.concat after (search [] 0)

let rev_split_words s =
  let rec split1 res i =
    if i >= String.length s then res else begin
      match s.[i] with
        ' ' | '\t' | '\r' | '\n' -> split1 res (i+1)
      | _ -> split2 res i (i+1)
    end
  and split2 res i j =
    if j >= String.length s then String.sub s i (j-i) :: res else begin
      match s.[j] with
        ' ' | '\t' | '\r' | '\n' -> split1 (String.sub s i (j-i) :: res) (j+1)
      | _ -> split2 res i (j+1)
    end
  in split1 [] 0

let get_ref r =
  let v = !r in
  r := []; v

let fst3 (x, _, _) = x
let snd3 (_,x,_) = x
let thd3 (_,_,x) = x

let fst4 (x, _, _, _) = x
let snd4 (_,x,_, _) = x
let thd4 (_,_,x,_) = x
let for4 (_,_,_,x) = x


module LongString = struct
  type t = bytes array

  let create str_size =
    let tbl_size = str_size / Sys.max_string_length + 1 in
    let tbl = Array.make tbl_size Bytes.empty in
    for i = 0 to tbl_size - 2 do
      tbl.(i) <- Bytes.create Sys.max_string_length;
    done;
    tbl.(tbl_size - 1) <- Bytes.create (str_size mod Sys.max_string_length);
    tbl

  let length tbl =
    let tbl_size = Array.length tbl in
    Sys.max_string_length * (tbl_size - 1) + Bytes.length tbl.(tbl_size - 1)

  let get tbl ind =
    Bytes.get tbl.(ind / Sys.max_string_length) (ind mod Sys.max_string_length)

  let set tbl ind c =
    Bytes.set tbl.(ind / Sys.max_string_length) (ind mod Sys.max_string_length)
              c

  let blit src srcoff dst dstoff len =
    for i = 0 to len - 1 do
      set dst (dstoff + i) (get src (srcoff + i))
    done

  let output oc tbl pos len =
    for i = pos to pos + len - 1 do
      output_char oc (get tbl i)
    done

  let unsafe_blit_to_bytes src srcoff dst dstoff len =
    for i = 0 to len - 1 do
      Bytes.unsafe_set dst (dstoff + i) (get src (srcoff + i))
    done

  let input_bytes ic len =
    let tbl = create len in
    Array.iter (fun str -> really_input ic str 0 (Bytes.length str)) tbl;
    tbl
end


let edit_distance a b cutoff =
  let la, lb = String.length a, String.length b in
  let cutoff =
    (* using max_int for cutoff would cause overflows in (i + cutoff + 1);
       we bring it back to the (max la lb) worstcase *)
    min (max la lb) cutoff in
  if abs (la - lb) > cutoff then None
  else begin
    (* initialize with 'cutoff + 1' so that not-yet-written-to cases have
       the worst possible cost; this is useful when computing the cost of
       a case just at the boundary of the cutoff diagonal. *)
    let m = Array.make_matrix (la + 1) (lb + 1) (cutoff + 1) in
    m.(0).(0) <- 0;
    for i = 1 to la do
      m.(i).(0) <- i;
    done;
    for j = 1 to lb do
      m.(0).(j) <- j;
    done;
    for i = 1 to la do
      for j = max 1 (i - cutoff - 1) to min lb (i + cutoff + 1) do
        let cost = if a.[i-1] = b.[j-1] then 0 else 1 in
        let best =
          (* insert, delete or substitute *)
          min (1 + min m.(i-1).(j) m.(i).(j-1)) (m.(i-1).(j-1) + cost)
        in
        let best =
          (* swap two adjacent letters; we use "cost" again in case of
             a swap between two identical letters; this is slightly
             redundant as this is a double-substitution case, but it
             was done this way in most online implementations and
             imitation has its virtues *)
          if not (i > 1 && j > 1 && a.[i-1] = b.[j-2] && a.[i-2] = b.[j-1])
          then best
          else min best (m.(i-2).(j-2) + cost)
        in
        m.(i).(j) <- best
      done;
    done;
    let result = m.(la).(lb) in
    if result > cutoff
    then None
    else Some result
  end


(* split a string [s] at every char [c], and return the list of sub-strings *)
let split s c =
  let len = String.length s in
  let rec iter pos to_rev =
    if pos = len then List.rev ("" :: to_rev) else
      match try
              Some ( String.index_from s pos c )
        with Not_found -> None
      with
          Some pos2 ->
            if pos2 = pos then iter (pos+1) ("" :: to_rev) else
              iter (pos2+1) ((String.sub s pos (pos2-pos)) :: to_rev)
        | None -> List.rev ( String.sub s pos (len-pos) :: to_rev )
  in
  iter 0 []

let cut_at s c =
  let pos = String.index s c in
  String.sub s 0 pos, String.sub s (pos+1) (String.length s - pos - 1)





(* Color handling *)
module Color = struct
  (* use ANSI color codes, see https://en.wikipedia.org/wiki/ANSI_escape_code *)
  type color =
    | Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White
  ;;

  type style =
    | FG of color (* foreground *)
    | BG of color (* background *)
    | Bold
    | Reset

    | Dim


  let ansi_of_color = function
    | Black -> "0"
    | Red -> "1"
    | Green -> "2"
    | Yellow -> "3"
    | Blue -> "4"
    | Magenta -> "5"
    | Cyan -> "6"
    | White -> "7"

  let code_of_style = function
    | FG c -> "3" ^ ansi_of_color c
    | BG c -> "4" ^ ansi_of_color c
    | Bold -> "1"
    | Reset -> "0"

    | Dim -> "2"


  let ansi_of_style_l l =
    let s = match l with
      | [] -> code_of_style Reset
      | [s] -> code_of_style s
      | _ -> String.concat ";" (List.map code_of_style l)
    in
    "\x1b[" ^ s ^ "m"

  type styles = {
    error: style list;
    warning: style list;
    loc: style list;
  }

  let default_styles = {
    warning = [Bold; FG Magenta];
    error = [Bold; FG Red];
    loc = [Bold];
  }

  let cur_styles = ref default_styles
  let get_styles () = !cur_styles
  let set_styles s = cur_styles := s

  (* map a tag to a style, if the tag is known.
     @raise Not_found otherwise *)
  let style_of_tag (Format.String_tag s) = match s with
    | "error" -> (!cur_styles).error
    | "warning" -> (!cur_styles).warning
    | "loc" -> (!cur_styles).loc

    | "info" -> [Bold; FG Yellow]
    | "dim" -> [Dim]
    | "filename" -> [FG Cyan]

    | _ -> raise Not_found

  let color_enabled = ref true

  (* either prints the tag of [s] or delegate to [or_else] *)
  let mark_open_tag ~or_else s =
    try
      let style = style_of_tag s in
      if !color_enabled then ansi_of_style_l style else ""
    with Not_found -> or_else s

  let mark_close_tag ~or_else s =
    try
      let _ = style_of_tag s in
      if !color_enabled then ansi_of_style_l [Reset] else ""
    with Not_found -> or_else s

  (* add color handling to formatter [ppf] *)
  let set_color_tag_handling ppf =
    let open Format in
    let functions = pp_get_formatter_stag_functions ppf () in
    let functions' = {functions with
      mark_open_stag=(mark_open_tag ~or_else:functions.mark_open_stag);
      mark_close_stag=(mark_close_tag ~or_else:functions.mark_close_stag);
    } in
    pp_set_mark_tags ppf true; (* enable tags *)
    pp_set_formatter_stag_functions ppf functions'

  (* external isatty : out_channel -> bool = "caml_sys_isatty" *)

  (* reasonable heuristic on whether colors should be enabled *)
   let should_enable_color () = false
(*    let term = try Sys.getenv "TERM" with Not_found -> "" in
    term <> "dumb"
    && term <> "" *)
(*    && isatty stderr *)

  let setup =
    let first = ref true in (* initialize only once *)
    let formatter_l = [Format.std_formatter; Format.err_formatter; Format.str_formatter] in
    fun o ->
      if !first then (
        first := false;
        Format.set_mark_tags true;
        List.iter set_color_tag_handling formatter_l;
        color_enabled := (match o with
          | Some Clflags.Always -> true
          | Some Clflags.Auto -> should_enable_color ()
          | Some Clflags.Never -> false
          | None -> should_enable_color ()
        )
      );
      ()
end


end
module Terminfo : sig
#1 "terminfo.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Basic interface to the terminfo database *)

type status =
  | Uninitialised
  | Bad_term
  | Good_term of int  (* number of lines of the terminal *)
;;
external setup : out_channel -> status = "caml_terminfo_setup";;
external backup : int -> unit = "caml_terminfo_backup";;
external standout : bool -> unit = "caml_terminfo_standout";;
external resume : int -> unit = "caml_terminfo_resume";;

end = struct
#1 "terminfo.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Basic interface to the terminfo database *)

type status =
  | Uninitialised
  | Bad_term
  | Good_term of int
;;
external setup : out_channel -> status = "caml_terminfo_setup";;
external backup : int -> unit = "caml_terminfo_backup";;
external standout : bool -> unit = "caml_terminfo_standout";;
external resume : int -> unit = "caml_terminfo_resume";;

end
module Warnings : sig
#1 "warnings.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Pierre Weis && Damien Doligez, INRIA Rocquencourt        *)
(*                                                                     *)
(*  Copyright 1998 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

open Format

type t =
  | Comment_start                           (*  1 *)
  | Comment_not_end                         (*  2 *)
  | Deprecated of string                    (*  3 *)
  | Fragile_match of string                 (*  4 *)
  | Partial_application                     (*  5 *)
  | Labels_omitted                          (*  6 *)
  | Method_override of string list          (*  7 *)
  | Partial_match of string                 (*  8 *)
  | Non_closed_record_pattern of string     (*  9 *)
  | Statement_type                          (* 10 *)
  | Unused_match                            (* 11 *)
  | Unused_pat                              (* 12 *)
  | Instance_variable_override of string list (* 13 *)
  | Illegal_backslash                       (* 14 *)
  | Implicit_public_methods of string list  (* 15 *)
  | Unerasable_optional_argument            (* 16 *)
  | Undeclared_virtual_method of string     (* 17 *)
  | Not_principal of string                 (* 18 *)
  | Without_principality of string          (* 19 *)
  | Unused_argument                         (* 20 *)
  | Nonreturning_statement                  (* 21 *)
  | Preprocessor of string                  (* 22 *)
  | Useless_record_with                     (* 23 *)
  | Bad_module_name of string               (* 24 *)
  | All_clauses_guarded                     (* 25 *)
  | Unused_var of string                    (* 26 *)
  | Unused_var_strict of string             (* 27 *)
  | Wildcard_arg_to_constant_constr         (* 28 *)
  | Eol_in_string                           (* 29 *)
  | Duplicate_definitions of string * string * string * string (* 30 *)
  | Multiple_definition of string * string * string (* 31 *)
  | Unused_value_declaration of string      (* 32 *)
  | Unused_open of string                   (* 33 *)
  | Unused_type_declaration of string       (* 34 *)
  | Unused_for_index of string              (* 35 *)
  | Unused_ancestor of string               (* 36 *)
  | Unused_constructor of string * bool * bool (* 37 *)
  | Unused_extension of string * bool * bool   (* 38 *)
  | Unused_rec_flag                         (* 39 *)
  | Name_out_of_scope of string * string list * bool   (* 40 *)
  | Ambiguous_name of string list * string list * bool (* 41 *)
  | Disambiguated_name of string            (* 42 *)
  | Nonoptional_label of string             (* 43 *)
  | Open_shadow_identifier of string * string (* 44 *)
  | Open_shadow_label_constructor of string * string (* 45 *)
  | Bad_env_variable of string * string     (* 46 *)
  | Attribute_payload of string * string    (* 47 *)
  | Eliminated_optional_arguments of string list (* 48 *)
  | No_cmi_file of string                   (* 49 *)
  | Bad_docstring of bool                   (* 50 *)

  | Mel_unused_attribute of string          (* 101 *)
  | Bs_polymorphic_comparison               (* 102 *)
  | Mel_ffi_warning of string               (* 103 *)
  | Bs_derive_warning of string             (* 104 *)
;;

val parse_options : bool -> string -> unit;;

val is_active : t -> bool;;
val is_error : t -> bool;;

val defaults_w : string;;
val defaults_warn_error : string;;

val print : formatter -> t -> unit;;

exception Errors of int;;

val check_fatal : unit -> unit;;

val help_warnings: unit -> unit

type state
val backup: unit -> state
val restore: state -> unit


val message : t -> string
val number: t -> int
val super_print : (t -> string) -> formatter -> t -> unit;;


end = struct
#1 "warnings.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Pierre Weis && Damien Doligez, INRIA Rocquencourt        *)
(*                                                                     *)
(*  Copyright 1998 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* When you change this, you need to update the documentation:
   - man/ocamlc.m   in ocaml
   - man/ocamlopt.m in ocaml
   - manual/cmds/comp.etex   in the doc sources
   - manual/cmds/native.etex in the doc sources
*)

type t =
  | Comment_start                           (*  1 *)
  | Comment_not_end                         (*  2 *)
  | Deprecated of string                    (*  3 *)
  | Fragile_match of string                 (*  4 *)
  | Partial_application                     (*  5 *)
  | Labels_omitted                          (*  6 *)
  | Method_override of string list          (*  7 *)
  | Partial_match of string                 (*  8 *)
  | Non_closed_record_pattern of string     (*  9 *)
  | Statement_type                          (* 10 *)
  | Unused_match                            (* 11 *)
  | Unused_pat                              (* 12 *)
  | Instance_variable_override of string list (* 13 *)
  | Illegal_backslash                       (* 14 *)
  | Implicit_public_methods of string list  (* 15 *)
  | Unerasable_optional_argument            (* 16 *)
  | Undeclared_virtual_method of string     (* 17 *)
  | Not_principal of string                 (* 18 *)
  | Without_principality of string          (* 19 *)
  | Unused_argument                         (* 20 *)
  | Nonreturning_statement                  (* 21 *)
  | Preprocessor of string                  (* 22 *)
  | Useless_record_with                     (* 23 *)
  | Bad_module_name of string               (* 24 *)
  | All_clauses_guarded                     (* 25 *)
  | Unused_var of string                    (* 26 *)
  | Unused_var_strict of string             (* 27 *)
  | Wildcard_arg_to_constant_constr         (* 28 *)
  | Eol_in_string                           (* 29 *)
  | Duplicate_definitions of string * string * string * string (*30 *)
  | Multiple_definition of string * string * string (* 31 *)
  | Unused_value_declaration of string      (* 32 *)
  | Unused_open of string                   (* 33 *)
  | Unused_type_declaration of string       (* 34 *)
  | Unused_for_index of string              (* 35 *)
  | Unused_ancestor of string               (* 36 *)
  | Unused_constructor of string * bool * bool  (* 37 *)
  | Unused_extension of string * bool * bool    (* 38 *)
  | Unused_rec_flag                         (* 39 *)
  | Name_out_of_scope of string * string list * bool (* 40 *)
  | Ambiguous_name of string list * string list *  bool    (* 41 *)
  | Disambiguated_name of string            (* 42 *)
  | Nonoptional_label of string             (* 43 *)
  | Open_shadow_identifier of string * string (* 44 *)
  | Open_shadow_label_constructor of string * string (* 45 *)
  | Bad_env_variable of string * string     (* 46 *)
  | Attribute_payload of string * string    (* 47 *)
  | Eliminated_optional_arguments of string list (* 48 *)
  | No_cmi_file of string                   (* 49 *)
  | Bad_docstring of bool                   (* 50 *)

  | Mel_unused_attribute of string           (* 101 *)
  | Bs_polymorphic_comparison               (* 102 *)
  | Mel_ffi_warning of string                (* 103 *)
  | Bs_derive_warning of string             (* 104 *)
;;

(* If you remove a warning, leave a hole in the numbering.  NEVER change
   the numbers of existing warnings.
   If you add a new warning, add it at the end with a new number;
   do NOT reuse one of the holes.
*)

let number = function
  | Comment_start -> 1
  | Comment_not_end -> 2
  | Deprecated _ -> 3
  | Fragile_match _ -> 4
  | Partial_application -> 5
  | Labels_omitted -> 6
  | Method_override _ -> 7
  | Partial_match _ -> 8
  | Non_closed_record_pattern _ -> 9
  | Statement_type -> 10
  | Unused_match -> 11
  | Unused_pat -> 12
  | Instance_variable_override _ -> 13
  | Illegal_backslash -> 14
  | Implicit_public_methods _ -> 15
  | Unerasable_optional_argument -> 16
  | Undeclared_virtual_method _ -> 17
  | Not_principal _ -> 18
  | Without_principality _ -> 19
  | Unused_argument -> 20
  | Nonreturning_statement -> 21
  | Preprocessor _ -> 22
  | Useless_record_with -> 23
  | Bad_module_name _ -> 24
  | All_clauses_guarded -> 25
  | Unused_var _ -> 26
  | Unused_var_strict _ -> 27
  | Wildcard_arg_to_constant_constr -> 28
  | Eol_in_string -> 29
  | Duplicate_definitions _ -> 30
  | Multiple_definition _ -> 31
  | Unused_value_declaration _ -> 32
  | Unused_open _ -> 33
  | Unused_type_declaration _ -> 34
  | Unused_for_index _ -> 35
  | Unused_ancestor _ -> 36
  | Unused_constructor _ -> 37
  | Unused_extension _ -> 38
  | Unused_rec_flag -> 39
  | Name_out_of_scope _ -> 40
  | Ambiguous_name _ -> 41
  | Disambiguated_name _ -> 42
  | Nonoptional_label _ -> 43
  | Open_shadow_identifier _ -> 44
  | Open_shadow_label_constructor _ -> 45
  | Bad_env_variable _ -> 46
  | Attribute_payload _ -> 47
  | Eliminated_optional_arguments _ -> 48
  | No_cmi_file _ -> 49
  | Bad_docstring _ -> 50

  | Mel_unused_attribute _ -> 101
  | Bs_polymorphic_comparison -> 102
  | Mel_ffi_warning _ -> 103
  | Bs_derive_warning _ -> 104
;;

let last_warning_number = 104
(* Must be the max number returned by the [number] function. *)
let letter_all =
  let rec loop i = if i = 0 then [] else i :: loop (i - 1) in
  loop last_warning_number

let letter = function
  | 'a' ->
    letter_all
  | 'b' -> []
  | 'c' -> [1; 2]
  | 'd' -> [3]
  | 'e' -> [4]
  | 'f' -> [5]
  | 'g' -> []
  | 'h' -> []
  | 'i' -> []
  | 'j' -> []
  | 'k' -> [32; 33; 34; 35; 36; 37; 38; 39]
  | 'l' -> [6]
  | 'm' -> [7]
  | 'n' -> []
  | 'o' -> []
  | 'p' -> [8]
  | 'q' -> []
  | 'r' -> [9]
  | 's' -> [10]
  | 't' -> []
  | 'u' -> [11; 12]
  | 'v' -> [13]
  | 'w' -> []
  | 'x' -> [14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 30]
  | 'y' -> [26]
  | 'z' -> [27]
  | _ -> assert false
;;

type state =
  {
    active: bool array;
    error: bool array;
  }

let current =
  ref
    {
      active = Array.make (last_warning_number + 1) true;
      error = Array.make (last_warning_number + 1) false;
    }

let backup () = !current

let restore x = current := x

let is_active x = (!current).active.(number x);;
let is_error x = (!current).error.(number x);;

let parse_opt error active flags s =
  let set i = flags.(i) <- true in
  let clear i = flags.(i) <- false in
  let set_all i = active.(i) <- true; error.(i) <- true in
  let error () = raise (Arg.Bad "Ill-formed list of warnings") in
  let rec get_num n i =
    if i >= String.length s then i, n
    else match s.[i] with
    | '0'..'9' -> get_num (10 * n + Char.code s.[i] - Char.code '0') (i + 1)
    | _ -> i, n
  in
  let get_range i =
    let i, n1 = get_num 0 i in
    if i + 2 < String.length s && s.[i] = '.' && s.[i + 1] = '.' then
      let i, n2 = get_num 0 (i + 2) in
      if n2 < n1 then error ();
      i, n1, n2
    else
      i, n1, n1
  in
  let rec loop i =
    if i >= String.length s then () else
    match s.[i] with
    | 'A' .. 'Z' ->
       List.iter set (letter (Char.lowercase_ascii s.[i]));
       loop (i+1)
    | 'a' .. 'z' ->
       List.iter clear (letter s.[i]);
       loop (i+1)
    | '+' -> loop_letter_num set (i+1)
    | '-' -> loop_letter_num clear (i+1)
    | '@' -> loop_letter_num set_all (i+1)
    | c -> error ()
  and loop_letter_num myset i =
    if i >= String.length s then error () else
    match s.[i] with
    | '0' .. '9' ->
        let i, n1, n2 = get_range i in
        for n = n1 to min n2 last_warning_number do myset n done;
        loop i
    | 'A' .. 'Z' ->
       List.iter myset (letter (Char.lowercase_ascii s.[i]));
       loop (i+1)
    | 'a' .. 'z' ->
       List.iter myset (letter s.[i]);
       loop (i+1)
    | _ -> error ()
  in
  loop 0
;;

let parse_options errflag s =
  let error = Array.copy (!current).error in
  let active = Array.copy (!current).active in
  parse_opt error active (if errflag then error else active) s;
  current := {error; active}

(* If you change these, don't forget to change them in man/ocamlc.m *)
let defaults_w = "+a-4-6-7-9-27-29-32..39-41..42-44-45-48-50-102";;
let defaults_warn_error = "-a";;

let () = parse_options false defaults_w;;
let () = parse_options true defaults_warn_error;;

let message = function
  | Comment_start -> "this is the start of a comment."
  | Comment_not_end -> "this is not the end of a comment."
  | Deprecated s -> "deprecated: " ^ s
  | Fragile_match "" ->
      "this pattern-matching is fragile."
  | Fragile_match s ->
      "this pattern-matching is fragile.\n\
       It will remain exhaustive when constructors are added to type " ^ s ^ "."
  | Partial_application ->
      "this function application is partial,\n\
       maybe some arguments are missing."
  | Labels_omitted ->
      "labels were omitted in the application of this function."
  | Method_override [lab] ->
      "the method " ^ lab ^ " is overridden."
  | Method_override (cname :: slist) ->
      String.concat " "
        ("the following methods are overridden by the class"
         :: cname  :: ":\n " :: slist)
  | Method_override [] -> assert false
  | Partial_match "" -> "this pattern-matching is not exhaustive."
  | Partial_match s ->
      "this pattern-matching is not exhaustive.\n\
       Here is an example of a value that is not matched:\n" ^ s
  | Non_closed_record_pattern s ->
      "the following labels are not bound in this record pattern:\n" ^ s ^
      "\nEither bind these labels explicitly or add '; _' to the pattern."
  | Statement_type ->
      "this expression should have type unit."
  | Unused_match -> "this match case is unused."
  | Unused_pat   -> "this sub-pattern is unused."
  | Instance_variable_override [lab] ->
      "the instance variable " ^ lab ^ " is overridden.\n" ^
      "The behaviour changed in ocaml 3.10 (previous behaviour was hiding.)"
  | Instance_variable_override (cname :: slist) ->
      String.concat " "
        ("the following instance variables are overridden by the class"
         :: cname  :: ":\n " :: slist) ^
      "\nThe behaviour changed in ocaml 3.10 (previous behaviour was hiding.)"
  | Instance_variable_override [] -> assert false
  | Illegal_backslash -> "illegal backslash escape in string."
  | Implicit_public_methods l ->
      "the following private methods were made public implicitly:\n "
      ^ String.concat " " l ^ "."
  | Unerasable_optional_argument -> "this optional argument cannot be erased."
  | Undeclared_virtual_method m -> "the virtual method "^m^" is not declared."
  | Not_principal s -> s^" is not principal."
  | Without_principality s -> s^" without principality."
  | Unused_argument -> "this argument will not be used by the function."
  | Nonreturning_statement ->
      "this statement never returns (or has an unsound type.)"
  | Preprocessor s -> s
  | Useless_record_with ->
      "all the fields are explicitly listed in this record:\n\
       the 'with' clause is useless."
  | Bad_module_name (modname) ->
      "bad source file name: \"" ^ modname ^ "\" is not a valid module name."
  | All_clauses_guarded ->
      "bad style, all clauses in this pattern-matching are guarded."
  | Unused_var v | Unused_var_strict v -> "unused variable " ^ v ^ "."
  | Wildcard_arg_to_constant_constr ->
     "wildcard pattern given as argument to a constant constructor"
  | Eol_in_string ->
     "unescaped end-of-line in a string constant (non-portable code)"
  | Duplicate_definitions (kind, cname, tc1, tc2) ->
      Printf.sprintf "the %s %s is defined in both types %s and %s."
        kind cname tc1 tc2
  | Multiple_definition(modname, file1, file2) ->
      Printf.sprintf
        "files %s and %s both define a module named %s"
        file1 file2 modname
  | Unused_value_declaration v -> "unused value " ^ v ^ "."
  | Unused_open s -> "unused open " ^ s ^ "."
  | Unused_type_declaration s -> "unused type " ^ s ^ "."
  | Unused_for_index s -> "unused for-loop index " ^ s ^ "."
  | Unused_ancestor s -> "unused ancestor variable " ^ s ^ "."
  | Unused_constructor (s, false, false) -> "unused constructor " ^ s ^ "."
  | Unused_constructor (s, true, _) ->
      "constructor " ^ s ^
      " is never used to build values.\n\
        (However, this constructor appears in patterns.)"
  | Unused_constructor (s, false, true) ->
      "constructor " ^ s ^
      " is never used to build values.\n\
        Its type is exported as a private type."
  | Unused_extension (s, false, false) ->
      "unused extension constructor " ^ s ^ "."
  | Unused_extension (s, true, _) ->
      "extension constructor " ^ s ^
      " is never used to build values.\n\
        (However, this constructor appears in patterns.)"
  | Unused_extension (s, false, true) ->
      "extension constructor " ^ s ^
      " is never used to build values.\n\
        It is exported or rebound as a private extension."
  | Unused_rec_flag ->
      "unused rec flag."
  | Name_out_of_scope (ty, [nm], false) ->
      nm ^ " was selected from type " ^ ty ^
      ".\nIt is not visible in the current scope, and will not \n\
       be selected if the type becomes unknown."
  | Name_out_of_scope (_, _, false) -> assert false
  | Name_out_of_scope (ty, slist, true) ->
      "this record of type "^ ty ^" contains fields that are \n\
       not visible in the current scope: "
      ^ String.concat " " slist ^ ".\n\
       They will not be selected if the type becomes unknown."
  | Ambiguous_name ([s], tl, false) ->
      s ^ " belongs to several types: " ^ String.concat " " tl ^
      "\nThe first one was selected. Please disambiguate if this is wrong."
  | Ambiguous_name (_, _, false) -> assert false
  | Ambiguous_name (slist, tl, true) ->
      "these field labels belong to several types: " ^
      String.concat " " tl ^
      "\nThe first one was selected. Please disambiguate if this is wrong."
  | Disambiguated_name s ->
      "this use of " ^ s ^ " required disambiguation."
  | Nonoptional_label s ->
      "the label " ^ s ^ " is not optional."
  | Open_shadow_identifier (kind, s) ->
      Printf.sprintf
        "this open statement shadows the %s identifier %s (which is later used)"
        kind s
  | Open_shadow_label_constructor (kind, s) ->
      Printf.sprintf
        "this open statement shadows the %s %s (which is later used)"
        kind s
  | Bad_env_variable (var, s) ->
      Printf.sprintf "illegal environment variable %s : %s" var s
  | Attribute_payload (a, s) ->
      Printf.sprintf "illegal payload for attribute '%s'.\n%s" a s
  | Eliminated_optional_arguments sl ->
      Printf.sprintf "implicit elimination of optional argument%s %s"
        (if List.length sl = 1 then "" else "s")
        (String.concat ", " sl)
  | No_cmi_file s ->
      "no cmi file was found in path for module " ^ s
  | Bad_docstring unattached ->
      if unattached then "unattached documentation comment (ignored)"
      else "ambiguous documentation comment"
  | Mel_unused_attribute s ->
      "Unused BuckleScript attribute: " ^ s
  | Bs_polymorphic_comparison ->
      "polymorphic comparison introduced (maybe unsafe)"
  | Mel_ffi_warning s ->
      "BuckleScript FFI warning: " ^ s
  | Bs_derive_warning s ->
      "BuckleScript bs.deriving warning: " ^ s
;;

let nerrors = ref 0;;

let print ppf w =
  let msg = message w in
  let num = number w in
  Format.fprintf ppf "%d: %s" num msg;
  Format.pp_print_flush ppf ();
  if (!current).error.(num) then incr nerrors
;;


(* used by super-errors. Copied from the `print` above *)
let super_print message ppf w =
  let msg = message w in
  let num = number w in
  Format.fprintf ppf "%s" msg;
  Format.pp_print_flush ppf ();
  if (!current).error.(num) then incr nerrors
;;


exception Errors of int;;

let check_fatal () =
  if !nerrors > 0 then begin
    let e = Errors !nerrors in
    nerrors := 0;
    raise e;
  end;
;;

let descriptions =
  [
    1, "Suspicious-looking start-of-comment mark.";
    2, "Suspicious-looking end-of-comment mark.";
    3, "Deprecated feature.";
    4, "Fragile pattern matching: matching that will remain complete even\n\
   \    if additional constructors are added to one of the variant types\n\
   \    matched.";
    5, "Partially applied function: expression whose result has function\n\
   \    type and is ignored.";
    6, "Label omitted in function application.";
    7, "Method overridden.";
    8, "Partial match: missing cases in pattern-matching.";
    9, "Missing fields in a record pattern.";
   10, "Expression on the left-hand side of a sequence that doesn't have type\n\
   \    \"unit\" (and that is not a function, see warning number 5).";
   11, "Redundant case in a pattern matching (unused match case).";
   12, "Redundant sub-pattern in a pattern-matching.";
   13, "Instance variable overridden.";
   14, "Illegal backslash escape in a string constant.";
   15, "Private method made public implicitly.";
   16, "Unerasable optional argument.";
   17, "Undeclared virtual method.";
   18, "Non-principal type.";
   19, "Type without principality.";
   20, "Unused function argument.";
   21, "Non-returning statement.";
   22, "Proprocessor warning.";
   23, "Useless record \"with\" clause.";
   24, "Bad module name: the source file name is not a valid OCaml module \
        name.";
   25, "Pattern-matching with all clauses guarded.  Exhaustiveness cannot be\n\
   \    checked.";
   26, "Suspicious unused variable: unused variable that is bound\n\
   \    with \"let\" or \"as\", and doesn't start with an underscore (\"_\")\n\
   \    character.";
   27, "Innocuous unused variable: unused variable that is not bound with\n\
   \    \"let\" nor \"as\", and doesn't start with an underscore (\"_\")\n\
   \    character.";
   28, "Wildcard pattern given as argument to a constant constructor.";
   29, "Unescaped end-of-line in a string constant (non-portable code).";
   30, "Two labels or constructors of the same name are defined in two\n\
   \    mutually recursive types.";
   31, "A module is linked twice in the same executable.";
   32, "Unused value declaration.";
   33, "Unused open statement.";
   34, "Unused type declaration.";
   35, "Unused for-loop index.";
   36, "Unused ancestor variable.";
   37, "Unused constructor.";
   38, "Unused extension constructor.";
   39, "Unused rec flag.";
   40, "Constructor or label name used out of scope.";
   41, "Ambiguous constructor or label name.";
   42, "Disambiguated constructor or label name.";
   43, "Nonoptional label applied as optional.";
   44, "Open statement shadows an already defined identifier.";
   45, "Open statement shadows an already defined label or constructor.";
   46, "Error in environment variable.";
   47, "Illegal attribute payload.";
   48, "Implicit elimination of optional arguments.";
   49, "Missing cmi file when looking up module alias.";
   50, "Unexpected documentation comment.";
   101,"Unused bs attributes";
  ]
;;

let help_warnings () =
  List.iter (fun (i, s) -> Printf.printf "%3i %s\n" i s) descriptions;
  print_endline "  A all warnings";
  for i = Char.code 'b' to Char.code 'z' do
    let c = Char.chr i in
    match letter c with
    | [] -> ()
    | [n] ->
        Printf.printf "  %c warning %i\n" (Char.uppercase_ascii c) n
    | l ->
        Printf.printf "  %c warnings %s.\n"
          (Char.uppercase_ascii c)
          (String.concat ", " (List.map string_of_int l))
  done;
  exit 0
;;

end
module Location : sig
#1 "location.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Source code locations (ranges of positions), used in parsetree. *)

open Format

type t = {
  loc_start: Lexing.position;
  loc_end: Lexing.position;
  loc_ghost: bool;
}

(* Note on the use of Lexing.position in this module.
   If [pos_fname = ""], then use [!input_name] instead.
   If [pos_lnum = -1], then [pos_bol = 0]. Use [pos_cnum] and
     re-parse the file to get the line and character numbers.
   Else all fields are correct.
*)

val none : t
(** An arbitrary value of type [t]; describes an empty ghost range. *)

val in_file : string -> t
(** Return an empty ghost range located in a given file. *)

val init : Lexing.lexbuf -> string -> unit
(** Set the file name and line number of the [lexbuf] to be the start
    of the named file. *)

val curr : Lexing.lexbuf -> t
(** Get the location of the current token from the [lexbuf]. *)

val symbol_rloc: unit -> t
val symbol_gloc: unit -> t

(** [rhs_loc n] returns the location of the symbol at position [n], starting
  at 1, in the current parser rule. *)
val rhs_loc: int -> t

val input_name: string ref
val input_lexbuf: Lexing.lexbuf option ref

val get_pos_info: Lexing.position -> string * int * int (* file, line, char *)
val print_loc: formatter -> t -> unit
val print_error: formatter -> t -> unit
val print_error_cur_file: formatter -> unit -> unit
val print_warning: t -> formatter -> Warnings.t -> unit
val formatter_for_warnings : formatter ref
val prerr_warning: t -> Warnings.t -> unit
val echo_eof: unit -> unit
val reset: unit -> unit

val warning_printer : (t -> formatter -> Warnings.t -> unit) ref
(** Hook for intercepting warnings. *)

val default_warning_printer : t -> formatter -> Warnings.t -> unit
(** Original warning printer for use in hooks. *)

val highlight_locations: formatter -> t list -> bool

type 'a loc = {
  txt : 'a;
  loc : t;
}

val mknoloc : 'a -> 'a loc
val mkloc : 'a -> t -> 'a loc

val print: formatter -> t -> unit
val print_filename: formatter -> string -> unit

val absolute_path: string -> string

val show_filename: string -> string
    (** In -absname mode, return the absolute path for this filename.
        Otherwise, returns the filename unchanged. *)


val absname: bool ref

(* Support for located errors *)

type error =
  {
    loc: t;
    msg: string;
    sub: error list;
    if_highlight: string; (* alternative message if locations are highlighted *)
  }

exception Error of error

val print_error_prefix: formatter -> unit -> unit
  (* print the prefix "Error:" possibly with style *)

val error: ?loc:t -> ?sub:error list -> ?if_highlight:string -> string -> error


val pp_ksprintf : ?before:(formatter -> unit) -> (string -> 'a) -> ('b, formatter, unit, 'a) format4 -> 'b


val errorf: ?loc:t -> ?sub:error list -> ?if_highlight:string
            -> ('a, Format.formatter, unit, error) format4 -> 'a

val raise_errorf: ?loc:t -> ?sub:error list -> ?if_highlight:string
            -> ('a, Format.formatter, unit, 'b) format4 -> 'a

val error_of_printer: t -> (formatter -> 'a -> unit) -> 'a -> error

val error_of_printer_file: (formatter -> 'a -> unit) -> 'a -> error

val error_of_exn: exn -> error option

val register_error_of_exn: (exn -> error option) -> unit
  (* Each compiler module which defines a custom type of exception
     which can surface as a user-visible error should register
     a "printer" for this exception using [register_error_of_exn].
     The result of the printer is an [error] value containing
     a location, a message, and optionally sub-messages (each of them
     being located as well). *)

val report_error: formatter -> error -> unit

val error_reporter : (formatter -> error -> unit) ref
(** Hook for intercepting error reports. *)

val default_error_reporter : formatter -> error -> unit
(** Original error reporter for use in hooks. *)

val report_exception: formatter -> exn -> unit
  (* Reraise the exception if it is unknown. *)

end = struct
#1 "location.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

open Lexing

let absname = ref false
    (* This reference should be in Clflags, but it would create an additional
       dependency and make bootstrapping Camlp4 more difficult. *)

type t = { loc_start: position; loc_end: position; loc_ghost: bool };;

let in_file name =
  let loc = {
    pos_fname = name;
    pos_lnum = 1;
    pos_bol = 0;
    pos_cnum = -1;
  } in
  { loc_start = loc; loc_end = loc; loc_ghost = true }
;;

let none = in_file "_none_";;

let curr lexbuf = {
  loc_start = lexbuf.lex_start_p;
  loc_end = lexbuf.lex_curr_p;
  loc_ghost = false
};;

let init lexbuf fname =
  lexbuf.lex_curr_p <- {
    pos_fname = fname;
    pos_lnum = 1;
    pos_bol = 0;
    pos_cnum = 0;
  }
;;

let symbol_rloc () = {
  loc_start = Parsing.symbol_start_pos ();
  loc_end = Parsing.symbol_end_pos ();
  loc_ghost = false;
};;

let symbol_gloc () = {
  loc_start = Parsing.symbol_start_pos ();
  loc_end = Parsing.symbol_end_pos ();
  loc_ghost = true;
};;

let rhs_loc n = {
  loc_start = Parsing.rhs_start_pos n;
  loc_end = Parsing.rhs_end_pos n;
  loc_ghost = false;
};;

let input_name = ref "_none_"
let input_lexbuf = ref (None : lexbuf option)

(* Terminal info *)

let status = ref Terminfo.Uninitialised

let num_loc_lines = ref 0 (* number of lines already printed after input *)

let print_updating_num_loc_lines ppf f arg =
  let open Format in
  let out_functions = pp_get_formatter_out_functions ppf () in
  let out_string str start len =
    let rec count i c =
      if i = start + len then c
      else if String.get str i = '\n' then count (succ i) (succ c)
      else count (succ i) c in
    num_loc_lines := !num_loc_lines + count start 0 ;
    out_functions.out_string str start len in
  pp_set_formatter_out_functions ppf
    { out_functions with out_string } ;
  f ppf arg ;
  pp_print_flush ppf ();
  pp_set_formatter_out_functions ppf out_functions

(* Highlight the locations using standout mode. *)

let highlight_terminfo ppf num_lines lb locs =
  Format.pp_print_flush ppf ();  (* avoid mixing Format and normal output *)
  (* Char 0 is at offset -lb.lex_abs_pos in lb.lex_buffer. *)
  let pos0 = -lb.lex_abs_pos in
  (* Do nothing if the buffer does not contain the whole phrase. *)
  if pos0 < 0 then raise Exit;
  (* Count number of lines in phrase *)
  let lines = ref !num_loc_lines in
  for i = pos0 to lb.lex_buffer_len - 1 do
    if Bytes.get lb.lex_buffer i = '\n' then incr lines
  done;
  (* If too many lines, give up *)
  if !lines >= num_lines - 2 then raise Exit;
  (* Move cursor up that number of lines *)
  flush stdout; Terminfo.backup !lines;
  (* Print the input, switching to standout for the location *)
  let bol = ref false in
  print_string "# ";
  for pos = 0 to lb.lex_buffer_len - pos0 - 1 do
    if !bol then (print_string "  "; bol := false);
    if List.exists (fun loc -> pos = loc.loc_start.pos_cnum) locs then
      Terminfo.standout true;
    if List.exists (fun loc -> pos = loc.loc_end.pos_cnum) locs then
      Terminfo.standout false;
    let c = Bytes.get lb.lex_buffer (pos + pos0) in
    print_char c;
    bol := (c = '\n')
  done;
  (* Make sure standout mode is over *)
  Terminfo.standout false;
  (* Position cursor back to original location *)
  Terminfo.resume !num_loc_lines;
  flush stdout

(* Highlight the location by printing it again. *)

let highlight_dumb ppf lb loc =
  (* Char 0 is at offset -lb.lex_abs_pos in lb.lex_buffer. *)
  let pos0 = -lb.lex_abs_pos in
  (* Do nothing if the buffer does not contain the whole phrase. *)
  if pos0 < 0 then raise Exit;
  let end_pos = lb.lex_buffer_len - pos0 - 1 in
  (* Determine line numbers for the start and end points *)
  let line_start = ref 0 and line_end = ref 0 in
  for pos = 0 to end_pos do
    if Bytes.get lb.lex_buffer (pos + pos0) = '\n' then begin
      if loc.loc_start.pos_cnum > pos then incr line_start;
      if loc.loc_end.pos_cnum   > pos then incr line_end;
    end
  done;
  (* Print character location (useful for Emacs) *)
  Format.fprintf ppf "Characters %i-%i:@."
                 loc.loc_start.pos_cnum loc.loc_end.pos_cnum;
  (* Print the input, underlining the location *)
  Format.pp_print_string ppf "  ";
  let line = ref 0 in
  let pos_at_bol = ref 0 in
  for pos = 0 to end_pos do
    match Bytes.get lb.lex_buffer (pos + pos0) with
    | '\n' ->
      if !line = !line_start && !line = !line_end then begin
        (* loc is on one line: underline location *)
        Format.fprintf ppf "@.  ";
        for _i = !pos_at_bol to loc.loc_start.pos_cnum - 1 do
          Format.pp_print_char ppf ' '
        done;
        for _i = loc.loc_start.pos_cnum to loc.loc_end.pos_cnum - 1 do
          Format.pp_print_char ppf '^'
        done
      end;
      if !line >= !line_start && !line <= !line_end then begin
        Format.fprintf ppf "@.";
        if pos < loc.loc_end.pos_cnum then Format.pp_print_string ppf "  "
      end;
      incr line;
      pos_at_bol := pos + 1
    | '\r' -> () (* discard *)
    | c ->
      if !line = !line_start && !line = !line_end then
        (* loc is on one line: print whole line *)
        Format.pp_print_char ppf c
      else if !line = !line_start then
        (* first line of multiline loc:
           print a dot for each char before loc_start *)
        if pos < loc.loc_start.pos_cnum then
          Format.pp_print_char ppf '.'
        else
          Format.pp_print_char ppf c
      else if !line = !line_end then
        (* last line of multiline loc: print a dot for each char
           after loc_end, even whitespaces *)
        if pos < loc.loc_end.pos_cnum then
          Format.pp_print_char ppf c
        else
          Format.pp_print_char ppf '.'
      else if !line > !line_start && !line < !line_end then
        (* intermediate line of multiline loc: print whole line *)
        Format.pp_print_char ppf c
  done

(* Highlight the location using one of the supported modes. *)

let rec highlight_locations ppf locs =
  match !status with
    Terminfo.Uninitialised ->
      status := Terminfo.setup stdout; highlight_locations ppf locs
  | Terminfo.Bad_term ->
      begin match !input_lexbuf with
        None -> false
      | Some lb ->
          let norepeat =
            try Sys.getenv "TERM" = "norepeat" with Not_found -> false in
          if norepeat then false else
            let loc1 = List.hd locs in
            try highlight_dumb ppf lb loc1; true
            with Exit -> false
      end
  | Terminfo.Good_term num_lines ->
      begin match !input_lexbuf with
        None -> false
      | Some lb ->
          try highlight_terminfo ppf num_lines lb locs; true
          with Exit -> false
      end

(* Print the location in some way or another *)

open Format

let absolute_path s = (* This function could go into Filename *)
  let open Filename in
  let s = if is_relative s then concat (Sys.getcwd ()) s else s in
  (* Now simplify . and .. components *)
  let rec aux s =
    let base = basename s in
    let dir = dirname s in
    if dir = s then dir
    else if base = current_dir_name then aux dir
    else if base = parent_dir_name then dirname (aux dir)
    else concat (aux dir) base
  in
  aux s

let show_filename file =
  if !absname then absolute_path file else file

let print_filename ppf file =
  Format.fprintf ppf "%s" (show_filename file)

let reset () =
  num_loc_lines := 0

let (msg_file, msg_line, msg_chars, msg_to, msg_colon) =
  ("File \"", "\", line ", ", characters ", "-", ":")

(* return file, line, char from the given position *)
let get_pos_info pos =
  (pos.pos_fname, pos.pos_lnum, pos.pos_cnum - pos.pos_bol)
;;

let setup_colors () =
  Misc.Color.setup !Clflags.color

let print_loc ppf loc =
  setup_colors ();
  let (file, line, startchar) = get_pos_info loc.loc_start in

  let startchar =
    if Clflags.bs_vscode then startchar + 1 else startchar in

  let endchar = loc.loc_end.pos_cnum - loc.loc_start.pos_cnum + startchar in
  if file = "//toplevel//" then begin
    if highlight_locations ppf [loc] then () else
      fprintf ppf "Characters %i-%i"
              loc.loc_start.pos_cnum loc.loc_end.pos_cnum
  end else begin
    fprintf ppf "%s@{<loc>%a%s%i" msg_file print_filename file msg_line line;
    if startchar >= 0 then
      fprintf ppf "%s%i%s%i" msg_chars startchar msg_to endchar;
    fprintf ppf "@}"
  end
;;

let print ppf loc =
  setup_colors ();
  if loc.loc_start.pos_fname = "//toplevel//"
  && highlight_locations ppf [loc] then ()
  else fprintf ppf "@{<loc>%a@}%s@." print_loc loc msg_colon
;;

let error_prefix = "Error"
let warning_prefix = "Warning"

let print_error_prefix ppf () =
  setup_colors ();
  fprintf ppf "@{<error>%s@}:" error_prefix;
  ()
;;

let print_error ppf loc =
  print ppf loc;
  print_error_prefix ppf ()
;;

let print_error_cur_file ppf () = print_error ppf (in_file !input_name);;

let default_warning_printer loc ppf w =
  if Warnings.is_active w then begin
    setup_colors ();
    print ppf loc;
    fprintf ppf "@{<warning>%s@} %a@." warning_prefix Warnings.print w
  end
;;

let warning_printer = ref default_warning_printer ;;

let print_warning loc ppf w =
  print_updating_num_loc_lines ppf (!warning_printer loc) w
;;

let formatter_for_warnings = ref err_formatter;;
let prerr_warning loc w = print_warning loc !formatter_for_warnings w;;

let echo_eof () =
  print_newline ();
  incr num_loc_lines

type 'a loc = {
  txt : 'a;
  loc : t;
}

let mkloc txt loc = { txt ; loc }
let mknoloc txt = mkloc txt none


type error =
  {
    loc: t;
    msg: string;
    sub: error list;
    if_highlight: string; (* alternative message if locations are highlighted *)
  }

let pp_ksprintf ?before k fmt =
  let buf = Buffer.create 64 in
  let ppf = Format.formatter_of_buffer buf in
  Misc.Color.set_color_tag_handling ppf;
  begin match before with
    | None -> ()
    | Some f -> f ppf
  end;
  kfprintf
    (fun _ ->
      pp_print_flush ppf ();
      let msg = Buffer.contents buf in
      k msg)
    ppf fmt

(* Shift the formatter's offset by the length of the error prefix, which
   is always added by the compiler after the message has been formatted *)
let print_phanton_error_prefix ppf =
  Format.pp_print_as ppf (String.length error_prefix + 2 (* ": " *)) ""

let errorf ?(loc = none) ?(sub = []) ?(if_highlight = "") fmt =
  pp_ksprintf
    ~before:print_phanton_error_prefix
    (fun msg -> {loc; msg; sub; if_highlight})
    fmt

let error ?(loc = none) ?(sub = []) ?(if_highlight = "") msg =
  {loc; msg; sub; if_highlight}

let error_of_exn : (exn -> error option) list ref = ref []

let register_error_of_exn f = error_of_exn := f :: !error_of_exn

let error_of_exn exn =
  let rec loop = function
    | [] -> None
    | f :: rest ->
        match f exn with
        | Some _ as r -> r
        | None -> loop rest
  in
  loop !error_of_exn

let rec default_error_reporter ppf ({loc; msg; sub; if_highlight} as err) =
  let highlighted =
    if if_highlight <> "" then
      let rec collect_locs locs {loc; sub; if_highlight; _} =
        List.fold_left collect_locs (loc :: locs) sub
      in
      let locs = collect_locs [] err in
      highlight_locations ppf locs
    else
      false
  in
  if highlighted then
    Format.pp_print_string ppf if_highlight
  else begin
    fprintf ppf "%a%a %s" print loc print_error_prefix () msg;
    List.iter (Format.fprintf ppf "@\n@[<2>%a@]" default_error_reporter) sub
  end

let error_reporter = ref default_error_reporter

let report_error ppf err =
  print_updating_num_loc_lines ppf !error_reporter err
;;

let error_of_printer loc print x =
  errorf ~loc "%a@?" print x

let error_of_printer_file print x =
  error_of_printer (in_file !input_name) print x

let () =
  register_error_of_exn
    (function
      | Sys_error msg ->
          Some (errorf ~loc:(in_file !input_name)
                "I/O error: %s" msg)
      | Warnings.Errors n ->
          Some
            (errorf ~loc:(in_file !input_name)
             "Some fatal warnings were triggered (%d occurrences)" n)
      | _ ->
          None
    )


let rec report_exception_rec n ppf exn =
  try match error_of_exn exn with
  | Some err ->
      fprintf ppf "@[%a@]@." report_error err
  | None -> raise exn
  with exn when n > 0 ->
    report_exception_rec (n-1) ppf exn

let report_exception ppf exn = report_exception_rec 5 ppf exn


exception Error of error

let () =
  register_error_of_exn
    (function
      | Error e -> Some e
      | _ -> None
    )

let raise_errorf ?(loc = none) ?(sub = []) ?(if_highlight = "") =
  pp_ksprintf
    ~before:print_phanton_error_prefix
    (fun msg -> raise (Error ({loc; msg; sub; if_highlight})))

end
(** Interface as module  *)
module Asttypes
= struct
#1 "asttypes.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Auxiliary a.s.t. types used by parsetree and typedtree. *)

type constant =
    Const_int of int
  | Const_char of char
  | Const_string of string * string option
  | Const_float of string
  | Const_int32 of int32
  | Const_int64 of int64
  | Const_nativeint of nativeint

type rec_flag = Nonrecursive | Recursive

type direction_flag = Upto | Downto

type private_flag = Private | Public

type mutable_flag = Immutable | Mutable

type virtual_flag = Virtual | Concrete

type override_flag = Override | Fresh

type closed_flag = Closed | Open

type label = string

type 'a loc = 'a Location.loc = {
  txt : 'a;
  loc : Location.t;
}


type variance =
  | Covariant
  | Contravariant
  | Invariant

end
module Longident : sig
#1 "longident.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Long identifiers, used in parsetree. *)

type t =
    Lident of string
  | Ldot of t * string
  | Lapply of t * t

val flatten: t -> string list
val last: t -> string
val parse: string -> t

end = struct
#1 "longident.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

type t =
    Lident of string
  | Ldot of t * string
  | Lapply of t * t

let rec flat accu = function
    Lident s -> s :: accu
  | Ldot(lid, s) -> flat (s :: accu) lid
  | Lapply(_, _) -> Misc.fatal_error "Longident.flat"

let flatten lid = flat [] lid

let last = function
    Lident s -> s
  | Ldot(_, s) -> s
  | Lapply(_, _) -> Misc.fatal_error "Longident.last"

let rec split_at_dots s pos =
  try
    let dot = String.index_from s pos '.' in
    String.sub s pos (dot - pos) :: split_at_dots s (dot + 1)
  with Not_found ->
    [String.sub s pos (String.length s - pos)]

let parse s =
  match split_at_dots s 0 with
    [] -> Lident ""  (* should not happen, but don't put assert false
                        so as not to crash the toplevel (see Genprintval) *)
  | hd :: tl -> List.fold_left (fun p s -> Ldot(p, s)) (Lident hd) tl

end
(** Interface as module  *)
module Parsetree
= struct
#1 "parsetree.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(** Abstract syntax tree produced by parsing *)

open Asttypes

(** {2 Extension points} *)

type attribute = string loc * payload
       (* [@id ARG]
          [@@id ARG]

          Metadata containers passed around within the AST.
          The compiler ignores unknown attributes.
       *)

and extension = string loc * payload
      (* [%id ARG]
         [%%id ARG]

         Sub-language placeholder -- rejected by the typechecker.
      *)

and attributes = attribute list

and payload =
  | PStr of structure
  | PTyp of core_type  (* : T *)
  | PPat of pattern * expression option  (* ? P  or  ? P when E *)

(** {2 Core language} *)

(* Type expressions *)

and core_type =
    {
     ptyp_desc: core_type_desc;
     ptyp_loc: Location.t;
     ptyp_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and core_type_desc =
  | Ptyp_any
        (*  _ *)
  | Ptyp_var of string
        (* 'a *)
  | Ptyp_arrow of label * core_type * core_type
        (* T1 -> T2       (label = "")
           ~l:T1 -> T2    (label = "l")
           ?l:T1 -> T2    (label = "?l")
         *)
  | Ptyp_tuple of core_type list
        (* T1 * ... * Tn

           Invariant: n >= 2
        *)
  | Ptyp_constr of Longident.t loc * core_type list
        (* tconstr
           T tconstr
           (T1, ..., Tn) tconstr
         *)
  | Ptyp_object of (string * attributes * core_type) list * closed_flag
        (* < l1:T1; ...; ln:Tn >     (flag = Closed)
           < l1:T1; ...; ln:Tn; .. > (flag = Open)
         *)
  | Ptyp_class of Longident.t loc * core_type list
        (* #tconstr
           T #tconstr
           (T1, ..., Tn) #tconstr
         *)
  | Ptyp_alias of core_type * string
        (* T as 'a *)
  | Ptyp_variant of row_field list * closed_flag * label list option
        (* [ `A|`B ]         (flag = Closed; labels = None)
           [> `A|`B ]        (flag = Open;   labels = None)
           [< `A|`B ]        (flag = Closed; labels = Some [])
           [< `A|`B > `X `Y ](flag = Closed; labels = Some ["X";"Y"])
         *)
  | Ptyp_poly of string list * core_type
        (* 'a1 ... 'an. T

           Can only appear in the following context:

           - As the core_type of a Ppat_constraint node corresponding
             to a constraint on a let-binding: let x : 'a1 ... 'an. T
             = e ...

           - Under Cfk_virtual for methods (not values).

           - As the core_type of a Pctf_method node.

           - As the core_type of a Pexp_poly node.

           - As the pld_type field of a label_declaration.

           - As a core_type of a Ptyp_object node.
         *)

  | Ptyp_package of package_type
        (* (module S) *)
  | Ptyp_extension of extension
        (* [%id] *)

and package_type = Longident.t loc * (Longident.t loc * core_type) list
      (*
        (module S)
        (module S with type t1 = T1 and ... and tn = Tn)
       *)

and row_field =
  | Rtag of label * attributes * bool * core_type list
        (* [`A]                   ( true,  [] )
           [`A of T]              ( false, [T] )
           [`A of T1 & .. & Tn]   ( false, [T1;...Tn] )
           [`A of & T1 & .. & Tn] ( true,  [T1;...Tn] )

          - The 2nd field is true if the tag contains a
            constant (empty) constructor.
          - '&' occurs when several types are used for the same constructor
            (see 4.2 in the manual)

          - TODO: switch to a record representation, and keep location
        *)
  | Rinherit of core_type
        (* [ T ] *)

(* Patterns *)

and pattern =
    {
     ppat_desc: pattern_desc;
     ppat_loc: Location.t;
     ppat_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and pattern_desc =
  | Ppat_any
        (* _ *)
  | Ppat_var of string loc
        (* x *)
  | Ppat_alias of pattern * string loc
        (* P as 'a *)
  | Ppat_constant of constant
        (* 1, 'a', "true", 1.0, 1l, 1L, 1n *)
  | Ppat_interval of constant * constant
        (* 'a'..'z'

           Other forms of interval are recognized by the parser
           but rejected by the type-checker. *)
  | Ppat_tuple of pattern list
        (* (P1, ..., Pn)

           Invariant: n >= 2
        *)
  | Ppat_construct of Longident.t loc * pattern option
        (* C                None
           C P              Some P
           C (P1, ..., Pn)  Some (Ppat_tuple [P1; ...; Pn])
         *)
  | Ppat_variant of label * pattern option
        (* `A             (None)
           `A P           (Some P)
         *)
  | Ppat_record of (Longident.t loc * pattern) list * closed_flag
        (* { l1=P1; ...; ln=Pn }     (flag = Closed)
           { l1=P1; ...; ln=Pn; _}   (flag = Open)

           Invariant: n > 0
         *)
  | Ppat_array of pattern list
        (* [| P1; ...; Pn |] *)
  | Ppat_or of pattern * pattern
        (* P1 | P2 *)
  | Ppat_constraint of pattern * core_type
        (* (P : T) *)
  | Ppat_type of Longident.t loc
        (* #tconst *)
  | Ppat_lazy of pattern
        (* lazy P *)
  | Ppat_unpack of string loc
        (* (module P)
           Note: (module P : S) is represented as
           Ppat_constraint(Ppat_unpack, Ptyp_package)
         *)
  | Ppat_exception of pattern
        (* exception P *)
  | Ppat_extension of extension
        (* [%id] *)

(* Value expressions *)

and expression =
    {
     pexp_desc: expression_desc;
     pexp_loc: Location.t;
     pexp_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and expression_desc =
  | Pexp_ident of Longident.t loc
        (* x
           M.x
         *)
  | Pexp_constant of constant
        (* 1, 'a', "true", 1.0, 1l, 1L, 1n *)
  | Pexp_let of rec_flag * value_binding list * expression
        (* let P1 = E1 and ... and Pn = EN in E       (flag = Nonrecursive)
           let rec P1 = E1 and ... and Pn = EN in E   (flag = Recursive)
         *)
  | Pexp_function of case list
        (* function P1 -> E1 | ... | Pn -> En *)
  | Pexp_fun of label * expression option * pattern * expression
        (* fun P -> E1                          (lab = "", None)
           fun ~l:P -> E1                       (lab = "l", None)
           fun ?l:P -> E1                       (lab = "?l", None)
           fun ?l:(P = E0) -> E1                (lab = "?l", Some E0)

           Notes:
           - If E0 is provided, lab must start with '?'.
           - "fun P1 P2 .. Pn -> E1" is represented as nested Pexp_fun.
           - "let f P = E" is represented using Pexp_fun.
         *)
  | Pexp_apply of expression * (label * expression) list
        (* E0 ~l1:E1 ... ~ln:En
           li can be empty (non labeled argument) or start with '?'
           (optional argument).

           Invariant: n > 0
         *)
  | Pexp_match of expression * case list
        (* match E0 with P1 -> E1 | ... | Pn -> En *)
  | Pexp_try of expression * case list
        (* try E0 with P1 -> E1 | ... | Pn -> En *)
  | Pexp_tuple of expression list
        (* (E1, ..., En)

           Invariant: n >= 2
        *)
  | Pexp_construct of Longident.t loc * expression option
        (* C                None
           C E              Some E
           C (E1, ..., En)  Some (Pexp_tuple[E1;...;En])
        *)
  | Pexp_variant of label * expression option
        (* `A             (None)
           `A E           (Some E)
         *)
  | Pexp_record of (Longident.t loc * expression) list * expression option
        (* { l1=P1; ...; ln=Pn }     (None)
           { E0 with l1=P1; ...; ln=Pn }   (Some E0)

           Invariant: n > 0
         *)
  | Pexp_field of expression * Longident.t loc
        (* E.l *)
  | Pexp_setfield of expression * Longident.t loc * expression
        (* E1.l <- E2 *)
  | Pexp_array of expression list
        (* [| E1; ...; En |] *)
  | Pexp_ifthenelse of expression * expression * expression option
        (* if E1 then E2 else E3 *)
  | Pexp_sequence of expression * expression
        (* E1; E2 *)
  | Pexp_while of expression * expression
        (* while E1 do E2 done *)
  | Pexp_for of
      pattern *  expression * expression * direction_flag * expression
        (* for i = E1 to E2 do E3 done      (flag = Upto)
           for i = E1 downto E2 do E3 done  (flag = Downto)
         *)
  | Pexp_constraint of expression * core_type
        (* (E : T) *)
  | Pexp_coerce of expression * core_type option * core_type
        (* (E :> T)        (None, T)
           (E : T0 :> T)   (Some T0, T)
         *)
  | Pexp_send of expression * string
        (*  E # m *)
  | Pexp_new of Longident.t loc
        (* new M.c *)
  | Pexp_setinstvar of string loc * expression
        (* x <- 2 *)
  | Pexp_override of (string loc * expression) list
        (* {< x1 = E1; ...; Xn = En >} *)
  | Pexp_letmodule of string loc * module_expr * expression
        (* let module M = ME in E *)
  | Pexp_assert of expression
        (* assert E
           Note: "assert false" is treated in a special way by the
           type-checker. *)
  | Pexp_lazy of expression
        (* lazy E *)
  | Pexp_poly of expression * core_type option
        (* Used for method bodies.

           Can only be used as the expression under Cfk_concrete
           for methods (not values). *)
  | Pexp_object of class_structure
        (* object ... end *)
  | Pexp_newtype of string * expression
        (* fun (type t) -> E *)
  | Pexp_pack of module_expr
        (* (module ME)

           (module ME : S) is represented as
           Pexp_constraint(Pexp_pack, Ptyp_package S) *)
  | Pexp_open of override_flag * Longident.t loc * expression
        (* let open M in E
           let! open M in E
        *)
  | Pexp_extension of extension
        (* [%id] *)

and case =   (* (P -> E) or (P when E0 -> E) *)
    {
     pc_lhs: pattern;
     pc_guard: expression option;
     pc_rhs: expression;
    }

(* Value descriptions *)

and value_description =
    {
     pval_name: string loc;
     pval_type: core_type;
     pval_prim: string list;
     pval_attributes: attributes;  (* ... [@@id1] [@@id2] *)
     pval_loc: Location.t;
    }

(*
  val x: T                            (prim = [])
  external x: T = "s1" ... "sn"       (prim = ["s1";..."sn"])

  Note: when used under Pstr_primitive, prim cannot be empty
*)

(* Type declarations *)

and type_declaration =
    {
     ptype_name: string loc;
     ptype_params: (core_type * variance) list;
           (* ('a1,...'an) t; None represents  _*)
     ptype_cstrs: (core_type * core_type * Location.t) list;
           (* ... constraint T1=T1'  ... constraint Tn=Tn' *)
     ptype_kind: type_kind;
     ptype_private: private_flag;   (* = private ... *)
     ptype_manifest: core_type option;  (* = T *)
     ptype_attributes: attributes;   (* ... [@@id1] [@@id2] *)
     ptype_loc: Location.t;
    }

(*
  type t                     (abstract, no manifest)
  type t = T0                (abstract, manifest=T0)
  type t = C of T | ...      (variant,  no manifest)
  type t = T0 = C of T | ... (variant,  manifest=T0)
  type t = {l: T; ...}       (record,   no manifest)
  type t = T0 = {l : T; ...} (record,   manifest=T0)
  type t = ..                (open,     no manifest)
*)

and type_kind =
  | Ptype_abstract
  | Ptype_variant of constructor_declaration list
        (* Invariant: non-empty list *)
  | Ptype_record of label_declaration list
        (* Invariant: non-empty list *)
  | Ptype_open

and label_declaration =
    {
     pld_name: string loc;
     pld_mutable: mutable_flag;
     pld_type: core_type;
     pld_loc: Location.t;
     pld_attributes: attributes; (* l [@id1] [@id2] : T *)
    }

(*  { ...; l: T; ... }            (mutable=Immutable)
    { ...; mutable l: T; ... }    (mutable=Mutable)

    Note: T can be a Ptyp_poly.
*)

and constructor_declaration =
    {
     pcd_name: string loc;
     pcd_args: core_type list;
     pcd_res: core_type option;
     pcd_loc: Location.t;
     pcd_attributes: attributes; (* C [@id1] [@id2] of ... *)
    }
(*
  | C of T1 * ... * Tn     (res = None)
  | C: T0                  (args = [], res = Some T0)
  | C: T1 * ... * Tn -> T0 (res = Some T0)
*)

and type_extension =
    {
     ptyext_path: Longident.t loc;
     ptyext_params: (core_type * variance) list;
     ptyext_constructors: extension_constructor list;
     ptyext_private: private_flag;
     ptyext_attributes: attributes;   (* ... [@@id1] [@@id2] *)
    }
(*
  type t += ...
*)

and extension_constructor =
    {
     pext_name: string loc;
     pext_kind : extension_constructor_kind;
     pext_loc : Location.t;
     pext_attributes: attributes; (* C [@id1] [@id2] of ... *)
    }

and extension_constructor_kind =
    Pext_decl of core_type list * core_type option
      (*
         | C of T1 * ... * Tn     ([T1; ...; Tn], None)
         | C: T0                  ([], Some T0)
         | C: T1 * ... * Tn -> T0 ([T1; ...; Tn], Some T0)
       *)
  | Pext_rebind of Longident.t loc
      (*
         | C = D
       *)

(** {2 Class language} *)

(* Type expressions for the class language *)

and class_type =
    {
     pcty_desc: class_type_desc;
     pcty_loc: Location.t;
     pcty_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and class_type_desc =
  | Pcty_constr of Longident.t loc * core_type list
        (* c
           ['a1, ..., 'an] c *)
  | Pcty_signature of class_signature
        (* object ... end *)
  | Pcty_arrow of label * core_type * class_type
        (* T -> CT       (label = "")
           ~l:T -> CT    (label = "l")
           ?l:T -> CT    (label = "?l")
         *)
  | Pcty_extension of extension
        (* [%id] *)

and class_signature =
    {
     pcsig_self: core_type;
     pcsig_fields: class_type_field list;
    }
(* object('selfpat) ... end
   object ... end             (self = Ptyp_any)
 *)

and class_type_field =
    {
     pctf_desc: class_type_field_desc;
     pctf_loc: Location.t;
     pctf_attributes: attributes; (* ... [@@id1] [@@id2] *)
    }

and class_type_field_desc =
  | Pctf_inherit of class_type
        (* inherit CT *)
  | Pctf_val of (string * mutable_flag * virtual_flag * core_type)
        (* val x: T *)
  | Pctf_method  of (string * private_flag * virtual_flag * core_type)
        (* method x: T

           Note: T can be a Ptyp_poly.
         *)
  | Pctf_constraint  of (core_type * core_type)
        (* constraint T1 = T2 *)
  | Pctf_attribute of attribute
        (* [@@@id] *)
  | Pctf_extension of extension
        (* [%%id] *)

and 'a class_infos =
    {
     pci_virt: virtual_flag;
     pci_params: (core_type * variance) list;
     pci_name: string loc;
     pci_expr: 'a;
     pci_loc: Location.t;
     pci_attributes: attributes;  (* ... [@@id1] [@@id2] *)
    }
(* class c = ...
   class ['a1,...,'an] c = ...
   class virtual c = ...

   Also used for "class type" declaration.
*)

and class_description = class_type class_infos

and class_type_declaration = class_type class_infos

(* Value expressions for the class language *)

and class_expr =
    {
     pcl_desc: class_expr_desc;
     pcl_loc: Location.t;
     pcl_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and class_expr_desc =
  | Pcl_constr of Longident.t loc * core_type list
        (* c
           ['a1, ..., 'an] c *)
  | Pcl_structure of class_structure
        (* object ... end *)
  | Pcl_fun of label * expression option * pattern * class_expr
        (* fun P -> CE                          (lab = "", None)
           fun ~l:P -> CE                       (lab = "l", None)
           fun ?l:P -> CE                       (lab = "?l", None)
           fun ?l:(P = E0) -> CE                (lab = "?l", Some E0)
         *)
  | Pcl_apply of class_expr * (label * expression) list
        (* CE ~l1:E1 ... ~ln:En
           li can be empty (non labeled argument) or start with '?'
           (optional argument).

           Invariant: n > 0
         *)
  | Pcl_let of rec_flag * value_binding list * class_expr
        (* let P1 = E1 and ... and Pn = EN in CE      (flag = Nonrecursive)
           let rec P1 = E1 and ... and Pn = EN in CE  (flag = Recursive)
         *)
  | Pcl_constraint of class_expr * class_type
        (* (CE : CT) *)
  | Pcl_extension of extension
        (* [%id] *)

and class_structure =
    {
     pcstr_self: pattern;
     pcstr_fields: class_field list;
    }
(* object(selfpat) ... end
   object ... end           (self = Ppat_any)
 *)

and class_field =
    {
     pcf_desc: class_field_desc;
     pcf_loc: Location.t;
     pcf_attributes: attributes; (* ... [@@id1] [@@id2] *)
    }

and class_field_desc =
  | Pcf_inherit of override_flag * class_expr * string option
        (* inherit CE
           inherit CE as x
           inherit! CE
           inherit! CE as x
         *)
  | Pcf_val of (string loc * mutable_flag * class_field_kind)
        (* val x = E
           val virtual x: T
         *)
  | Pcf_method of (string loc * private_flag * class_field_kind)
        (* method x = E            (E can be a Pexp_poly)
           method virtual x: T     (T can be a Ptyp_poly)
         *)
  | Pcf_constraint of (core_type * core_type)
        (* constraint T1 = T2 *)
  | Pcf_initializer of expression
        (* initializer E *)
  | Pcf_attribute of attribute
        (* [@@@id] *)
  | Pcf_extension of extension
        (* [%%id] *)

and class_field_kind =
  | Cfk_virtual of core_type
  | Cfk_concrete of override_flag * expression

and class_declaration = class_expr class_infos

(** {2 Module language} *)

(* Type expressions for the module language *)

and module_type =
    {
     pmty_desc: module_type_desc;
     pmty_loc: Location.t;
     pmty_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and module_type_desc =
  | Pmty_ident of Longident.t loc
        (* S *)
  | Pmty_signature of signature
        (* sig ... end *)
  | Pmty_functor of string loc * module_type option * module_type
        (* functor(X : MT1) -> MT2 *)
  | Pmty_with of module_type * with_constraint list
        (* MT with ... *)
  | Pmty_typeof of module_expr
        (* module type of ME *)
  | Pmty_extension of extension
        (* [%id] *)
  | Pmty_alias of Longident.t loc
        (* (module M) *)

and signature = signature_item list

and signature_item =
    {
     psig_desc: signature_item_desc;
     psig_loc: Location.t;
    }

and signature_item_desc =
  | Psig_value of value_description
        (*
          val x: T
          external x: T = "s1" ... "sn"
         *)
  | Psig_type of type_declaration list
        (* type t1 = ... and ... and tn = ... *)
  | Psig_typext of type_extension
        (* type t1 += ... *)
  | Psig_exception of extension_constructor
        (* exception C of T *)
  | Psig_module of module_declaration
        (* module X : MT *)
  | Psig_recmodule of module_declaration list
        (* module rec X1 : MT1 and ... and Xn : MTn *)
  | Psig_modtype of module_type_declaration
        (* module type S = MT
           module type S *)
  | Psig_open of open_description
        (* open X *)
  | Psig_include of include_description
        (* include MT *)
  | Psig_class of class_description list
        (* class c1 : ... and ... and cn : ... *)
  | Psig_class_type of class_type_declaration list
        (* class type ct1 = ... and ... and ctn = ... *)
  | Psig_attribute of attribute
        (* [@@@id] *)
  | Psig_extension of extension * attributes
        (* [%%id] *)

and module_declaration =
    {
     pmd_name: string loc;
     pmd_type: module_type;
     pmd_attributes: attributes; (* ... [@@id1] [@@id2] *)
     pmd_loc: Location.t;
    }
(* S : MT *)

and module_type_declaration =
    {
     pmtd_name: string loc;
     pmtd_type: module_type option;
     pmtd_attributes: attributes; (* ... [@@id1] [@@id2] *)
     pmtd_loc: Location.t;
    }
(* S = MT
   S       (abstract module type declaration, pmtd_type = None)
*)

and open_description =
    {
     popen_lid: Longident.t loc;
     popen_override: override_flag;
     popen_loc: Location.t;
     popen_attributes: attributes;
    }
(* open! X - popen_override = Override (silences the 'used identifier
                              shadowing' warning)
   open  X - popen_override = Fresh
 *)

and 'a include_infos =
    {
     pincl_mod: 'a;
     pincl_loc: Location.t;
     pincl_attributes: attributes;
    }

and include_description = module_type include_infos
(* include MT *)

and include_declaration = module_expr include_infos
(* include ME *)

and with_constraint =
  | Pwith_type of Longident.t loc * type_declaration
        (* with type X.t = ...

           Note: the last component of the longident must match
           the name of the type_declaration. *)
  | Pwith_module of Longident.t loc * Longident.t loc
        (* with module X.Y = Z *)
  | Pwith_typesubst of type_declaration
        (* with type t := ... *)
  | Pwith_modsubst of string loc * Longident.t loc
        (* with module X := Z *)

(* Value expressions for the module language *)

and module_expr =
    {
     pmod_desc: module_expr_desc;
     pmod_loc: Location.t;
     pmod_attributes: attributes; (* ... [@id1] [@id2] *)
    }

and module_expr_desc =
  | Pmod_ident of Longident.t loc
        (* X *)
  | Pmod_structure of structure
        (* struct ... end *)
  | Pmod_functor of string loc * module_type option * module_expr
        (* functor(X : MT1) -> ME *)
  | Pmod_apply of module_expr * module_expr
        (* ME1(ME2) *)
  | Pmod_constraint of module_expr * module_type
        (* (ME : MT) *)
  | Pmod_unpack of expression
        (* (val E) *)
  | Pmod_extension of extension
        (* [%id] *)

and structure = structure_item list

and structure_item =
    {
     pstr_desc: structure_item_desc;
     pstr_loc: Location.t;
    }

and structure_item_desc =
  | Pstr_eval of expression * attributes
        (* E *)
  | Pstr_value of rec_flag * value_binding list
        (* let P1 = E1 and ... and Pn = EN       (flag = Nonrecursive)
           let rec P1 = E1 and ... and Pn = EN   (flag = Recursive)
         *)
  | Pstr_primitive of value_description
        (* external x: T = "s1" ... "sn" *)
  | Pstr_type of type_declaration list
        (* type t1 = ... and ... and tn = ... *)
  | Pstr_typext of type_extension
        (* type t1 += ... *)
  | Pstr_exception of extension_constructor
        (* exception C of T
           exception C = M.X *)
  | Pstr_module of module_binding
        (* module X = ME *)
  | Pstr_recmodule of module_binding list
        (* module rec X1 = ME1 and ... and Xn = MEn *)
  | Pstr_modtype of module_type_declaration
        (* module type S = MT *)
  | Pstr_open of open_description
        (* open X *)
  | Pstr_class of class_declaration list
        (* class c1 = ... and ... and cn = ... *)
  | Pstr_class_type of class_type_declaration list
        (* class type ct1 = ... and ... and ctn = ... *)
  | Pstr_include of include_declaration
        (* include ME *)
  | Pstr_attribute of attribute
        (* [@@@id] *)
  | Pstr_extension of extension * attributes
        (* [%%id] *)

and value_binding =
  {
    pvb_pat: pattern;
    pvb_expr: expression;
    pvb_attributes: attributes;
    pvb_loc: Location.t;
  }

and module_binding =
    {
     pmb_name: string loc;
     pmb_expr: module_expr;
     pmb_attributes: attributes;
     pmb_loc: Location.t;
    }
(* X = ME *)

(** {2 Toplevel} *)

(* Toplevel phrases *)

type toplevel_phrase =
  | Ptop_def of structure
  | Ptop_dir of string * directive_argument
     (* #use, #load ... *)

and directive_argument =
  | Pdir_none
  | Pdir_string of string
  | Pdir_int of int
  | Pdir_ident of Longident.t
  | Pdir_bool of bool

end
module Docstrings : sig
#1 "docstrings.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                              Leo White                              *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(** (Re)Initialise all docstring state *)
val init : unit -> unit

(** Emit warnings for unattached and ambiguous docstrings *)
val warn_bad_docstrings : unit -> unit

(** {3 Docstrings} *)

(** Documentation comments *)
type docstring

(** Create a docstring *)
val docstring : string -> Location.t -> docstring

(** Get the text of a docstring *)
val docstring_body : docstring -> string

(** Get the location of a docstring *)
val docstring_loc : docstring -> Location.t

(** {3 Set functions}

   These functions are used by the lexer to associate docstrings to
   the locations of tokens. *)

(** Docstrings immediately preceding a token *)
val set_pre_docstrings : Lexing.position -> docstring list -> unit

(** Docstrings immediately following a token *)
val set_post_docstrings : Lexing.position -> docstring list -> unit

(** Docstrings not immediately adjacent to a token *)
val set_floating_docstrings : Lexing.position -> docstring list -> unit

(** Docstrings immediately following the token which precedes this one *)
val set_pre_extra_docstrings : Lexing.position -> docstring list -> unit

(** Docstrings immediately preceding the token which follows this one *)
val set_post_extra_docstrings : Lexing.position -> docstring list -> unit

(** {3 Items}

    The {!docs} type represents documentation attached to an item. *)

type docs =
  { docs_pre: docstring option;
    docs_post: docstring option; }

val empty_docs : docs

val docs_attr : docstring -> Parsetree.attribute

(** Convert item documentation to attributes and add them to an
    attribute list *)
val add_docs_attrs : docs -> Parsetree.attributes -> Parsetree.attributes

(** Fetch the item documentation for the current symbol. This also
    marks this documentation (for ambiguity warnings). *)
val symbol_docs : unit -> docs
val symbol_docs_lazy : unit -> docs Lazy.t

(** Fetch the item documentation for the symbols between two
    positions. This also marks this documentation (for ambiguity
    warnings). *)
val rhs_docs : int -> int -> docs
val rhs_docs_lazy : int -> int -> docs Lazy.t

(** Mark the item documentation for the current symbol (for ambiguity
    warnings). *)
val mark_symbol_docs : unit -> unit

(** Mark as associated the item documentation for the symbols between
    two positions (for ambiguity warnings) *)
val mark_rhs_docs : int -> int -> unit

(** {3 Fields and constructors}

    The {!info} type represents documentation attached to a field or
    constructor. *)

type info = docstring option

val empty_info : info

val info_attr : docstring -> Parsetree.attribute

(** Convert field info to attributes and add them to an
    attribute list *)
val add_info_attrs : info -> Parsetree.attributes -> Parsetree.attributes

(** Fetch the field info for the current symbol. *)
val symbol_info : unit -> info

(** Fetch the field info following the symbol at a given position. *)
val rhs_info : int -> info

(** {3 Unattached comments}

    The {!text} type represents documentation which is not attached to
    anything. *)

type text = docstring list

val empty_text : text

val text_attr : docstring -> Parsetree.attribute

(** Convert text to attributes and add them to an attribute list *)
val add_text_attrs : text -> Parsetree.attributes -> Parsetree.attributes

(** Fetch the text preceding the current symbol. *)
val symbol_text : unit -> text
val symbol_text_lazy : unit -> text Lazy.t

(** Fetch the text preceding the symbol at the given position. *)
val rhs_text : int -> text
val rhs_text_lazy : int -> text Lazy.t

(** {3 Extra text}

    There may be additional text attached to the delimiters of a block
    (e.g. [struct] and [end]). This is fetched by the following
    functions, which are applied to the contents of the block rather
    than the delimiters. *)

(** Fetch additional text preceding the current symbol *)
val symbol_pre_extra_text : unit -> text

(** Fetch additional text following the current symbol *)
val symbol_post_extra_text : unit -> text

(** Fetch additional text preceding the symbol at the given position *)
val rhs_pre_extra_text : int -> text

(** Fetch additional text following the symbol at the given position *)
val rhs_post_extra_text : int -> text

end = struct
#1 "docstrings.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                              Leo White                              *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

open Location

(* Docstrings *)

(* A docstring is "attached" if it has been inserted in the AST. This
   is used for generating unexpected docstring warnings. *)
type ds_attached =
  | Unattached   (* Not yet attached anything.*)
  | Info         (* Attached to a field or constructor. *)
  | Docs         (* Attached to an item or as floating text. *)

(* A docstring is "associated" with an item if there are no blank lines between
   them. This is used for generating docstring ambiguity warnings. *)
type ds_associated =
  | Zero             (* Not associated with an item *)
  | One              (* Associated with one item *)
  | Many             (* Associated with multiple items (ambiguity) *)

type docstring =
  { ds_body: string;
    ds_loc: Location.t;
    mutable ds_attached: ds_attached;
    mutable ds_associated: ds_associated; }

(* List of docstrings *)

let docstrings : docstring list ref = ref []

(* Warn for unused and ambiguous docstrings *)

let warn_bad_docstrings () =
  if Warnings.is_active (Warnings.Bad_docstring true) then begin
    List.iter
      (fun ds ->
         match ds.ds_attached with
         | Info -> ()
         | Unattached ->
           prerr_warning ds.ds_loc (Warnings.Bad_docstring true)
         | Docs ->
             match ds.ds_associated with
             | Zero | One -> ()
             | Many ->
               prerr_warning ds.ds_loc (Warnings.Bad_docstring false))
      (List.rev !docstrings)
end

(* Docstring constructors and descturctors *)

let docstring body loc =
  let ds =
    { ds_body = body;
      ds_loc = loc;
      ds_attached = Unattached;
      ds_associated = Zero; }
  in
  docstrings := ds :: !docstrings;
  ds

let docstring_body ds = ds.ds_body

let docstring_loc ds = ds.ds_loc

(* Docstrings attached to items *)

type docs =
  { docs_pre: docstring option;
    docs_post: docstring option; }

let empty_docs = { docs_pre = None; docs_post = None }

let doc_loc = {txt = "ocaml.doc"; loc = Location.none}

let docs_attr ds =
  let open Asttypes in
  let open Parsetree in
  let exp =
    { pexp_desc = Pexp_constant (Const_string(ds.ds_body, None));
      pexp_loc = ds.ds_loc;
      pexp_attributes = []; }
  in
  let item =
    { pstr_desc = Pstr_eval (exp, []); pstr_loc = exp.pexp_loc }
  in
    (doc_loc, PStr [item])

let add_docs_attrs docs attrs =
  let attrs =
    match docs.docs_pre with
    | None -> attrs
    | Some ds -> docs_attr ds :: attrs
  in
  let attrs =
    match docs.docs_post with
    | None -> attrs
    | Some ds -> attrs @ [docs_attr ds]
  in
  attrs

(* Docstrings attached to consturctors or fields *)

type info = docstring option

let empty_info = None

let info_attr = docs_attr

let add_info_attrs info attrs =
  let attrs =
    match info with
    | None -> attrs
    | Some ds -> attrs @ [info_attr ds]
  in
  attrs

(* Docstrings not attached to a specifc item *)

type text = docstring list

let empty_text = []

let text_loc = {txt = "ocaml.text"; loc = Location.none}

let text_attr ds =
  let open Asttypes in
  let open Parsetree in
  let exp =
    { pexp_desc = Pexp_constant (Const_string(ds.ds_body, None));
      pexp_loc = ds.ds_loc;
      pexp_attributes = []; }
  in
  let item =
    { pstr_desc = Pstr_eval (exp, []); pstr_loc = exp.pexp_loc }
  in
    (text_loc, PStr [item])

let add_text_attrs dsl attrs =
  (List.map text_attr dsl) @ attrs

(* Find the first non-info docstring in a list, attach it and return it *)
let get_docstring ~info dsl =
  let rec loop = function
    | [] -> None
    | {ds_attached = Info; _} :: rest -> loop rest
    | ds :: rest ->
        ds.ds_attached <- if info then Info else Docs;
        Some ds
  in
  loop dsl

(* Find all the non-info docstrings in a list, attach them and return them *)
let get_docstrings dsl =
  let rec loop acc = function
    | [] -> List.rev acc
    | {ds_attached = Info; _} :: rest -> loop acc rest
    | ds :: rest ->
        ds.ds_attached <- Docs;
        loop (ds :: acc) rest
  in
    loop [] dsl

(* "Associate" all the docstrings in a list *)
let associate_docstrings dsl =
  List.iter
    (fun ds ->
       match ds.ds_associated with
       | Zero -> ds.ds_associated <- One
       | (One | Many) -> ds.ds_associated <- Many)
    dsl

(* Map from positions to pre docstrings *)

let pre_table : (Lexing.position, docstring list) Hashtbl.t =
  Hashtbl.create 50

let set_pre_docstrings pos dsl =
  if dsl <> [] then Hashtbl.add pre_table pos dsl

let get_pre_docs pos =
  try
    let dsl = Hashtbl.find pre_table pos in
      associate_docstrings dsl;
      get_docstring ~info:false dsl
  with Not_found -> None

let mark_pre_docs pos =
  try
    let dsl = Hashtbl.find pre_table pos in
      associate_docstrings dsl
  with Not_found -> ()

(* Map from positions to post docstrings *)

let post_table : (Lexing.position, docstring list) Hashtbl.t =
  Hashtbl.create 50

let set_post_docstrings pos dsl =
  if dsl <> [] then Hashtbl.add post_table pos dsl

let get_post_docs pos =
  try
    let dsl = Hashtbl.find post_table pos in
      associate_docstrings dsl;
      get_docstring ~info:false dsl
  with Not_found -> None

let mark_post_docs pos =
  try
    let dsl = Hashtbl.find post_table pos in
      associate_docstrings dsl
  with Not_found -> ()

let get_info pos =
  try
    let dsl = Hashtbl.find post_table pos in
      get_docstring ~info:true dsl
  with Not_found -> None

(* Map from positions to floating docstrings *)

let floating_table : (Lexing.position, docstring list) Hashtbl.t =
  Hashtbl.create 50

let set_floating_docstrings pos dsl =
  if dsl <> [] then Hashtbl.add floating_table pos dsl

let get_text pos =
  try
    let dsl = Hashtbl.find floating_table pos in
      get_docstrings dsl
  with Not_found -> []

(* Maps from positions to extra docstrings *)

let pre_extra_table : (Lexing.position, docstring list) Hashtbl.t =
  Hashtbl.create 50

let set_pre_extra_docstrings pos dsl =
  if dsl <> [] then Hashtbl.add pre_extra_table pos dsl

let get_pre_extra_text pos =
  try
    let dsl = Hashtbl.find pre_extra_table pos in
      get_docstrings dsl
  with Not_found -> []

let post_extra_table : (Lexing.position, docstring list) Hashtbl.t =
  Hashtbl.create 50

let set_post_extra_docstrings pos dsl =
  if dsl <> [] then Hashtbl.add post_extra_table pos dsl

let get_post_extra_text pos =
  try
    let dsl = Hashtbl.find post_extra_table pos in
      get_docstrings dsl
  with Not_found -> []

(* Docstrings from parser actions *)

let symbol_docs () =
  { docs_pre = get_pre_docs (Parsing.symbol_start_pos ());
    docs_post = get_post_docs (Parsing.symbol_end_pos ()); }

let symbol_docs_lazy () =
  let p1 = Parsing.symbol_start_pos () in
  let p2 = Parsing.symbol_end_pos () in
    lazy { docs_pre = get_pre_docs p1;
           docs_post = get_post_docs p2; }

let rhs_docs pos1 pos2 =
  { docs_pre = get_pre_docs (Parsing.rhs_start_pos pos1);
    docs_post = get_post_docs (Parsing.rhs_end_pos pos2); }

let rhs_docs_lazy pos1 pos2 =
  let p1 = Parsing.rhs_start_pos pos1 in
  let p2 = Parsing.rhs_end_pos pos2 in
    lazy { docs_pre = get_pre_docs p1;
           docs_post = get_post_docs p2; }

let mark_symbol_docs () =
  mark_pre_docs (Parsing.symbol_start_pos ());
  mark_post_docs (Parsing.symbol_end_pos ())

let mark_rhs_docs pos1 pos2 =
  mark_pre_docs (Parsing.rhs_start_pos pos1);
  mark_post_docs (Parsing.rhs_end_pos pos2)

let symbol_info () =
  get_info (Parsing.symbol_end_pos ())

let rhs_info pos =
  get_info (Parsing.rhs_end_pos pos)

let symbol_text () =
  get_text (Parsing.symbol_start_pos ())

let symbol_text_lazy () =
  let pos = Parsing.symbol_start_pos () in
    lazy (get_text pos)

let rhs_text pos =
  get_text (Parsing.rhs_start_pos pos)

let rhs_text_lazy pos =
  let pos = Parsing.rhs_start_pos pos in
    lazy (get_text pos)

let symbol_pre_extra_text () =
  get_pre_extra_text (Parsing.symbol_start_pos ())

let symbol_post_extra_text () =
  get_post_extra_text (Parsing.symbol_end_pos ())

let rhs_pre_extra_text pos =
  get_pre_extra_text (Parsing.rhs_start_pos pos)

let rhs_post_extra_text pos =
  get_post_extra_text (Parsing.rhs_end_pos pos)


(* (Re)Initialise all comment state *)

let init () =
  docstrings := [];
  Hashtbl.reset pre_table;
  Hashtbl.reset post_table;
  Hashtbl.reset floating_table;
  Hashtbl.reset pre_extra_table;
  Hashtbl.reset post_extra_table




end
module Ast_helper : sig
#1 "ast_helper.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                        Alain Frisch, LexiFi                         *)
(*                                                                     *)
(*  Copyright 2012 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(** Helpers to produce Parsetree fragments *)

open Parsetree
open Asttypes
open Docstrings

type lid = Longident.t loc
type str = string loc
type loc = Location.t
type attrs = attribute list

(** {2 Default locations} *)

val default_loc: loc ref
    (** Default value for all optional location arguments. *)

val with_default_loc: loc -> (unit -> 'a) -> 'a
    (** Set the [default_loc] within the scope of the execution
        of the provided function. *)

(** {2 Core language} *)

(** Type expressions *)
module Typ :
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> core_type_desc -> core_type
    val attr: core_type -> attribute -> core_type

    val any: ?loc:loc -> ?attrs:attrs -> unit -> core_type
    val var: ?loc:loc -> ?attrs:attrs -> string -> core_type
    val arrow: ?loc:loc -> ?attrs:attrs -> label -> core_type -> core_type
               -> core_type
    val tuple: ?loc:loc -> ?attrs:attrs -> core_type list -> core_type
    val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> core_type
    val object_: ?loc:loc -> ?attrs:attrs ->
                  (string * attributes * core_type) list -> closed_flag ->
                  core_type
    val class_: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> core_type
    val alias: ?loc:loc -> ?attrs:attrs -> core_type -> string -> core_type
    val variant: ?loc:loc -> ?attrs:attrs -> row_field list -> closed_flag
                 -> label list option -> core_type
    val poly: ?loc:loc -> ?attrs:attrs -> string list -> core_type -> core_type
    val package: ?loc:loc -> ?attrs:attrs -> lid -> (lid * core_type) list
                 -> core_type
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> core_type

    val force_poly: core_type -> core_type
  end

(** Patterns *)
module Pat:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> pattern_desc -> pattern
    val attr:pattern -> attribute -> pattern

    val any: ?loc:loc -> ?attrs:attrs -> unit -> pattern
    val var: ?loc:loc -> ?attrs:attrs -> str -> pattern
    val alias: ?loc:loc -> ?attrs:attrs -> pattern -> str -> pattern
    val constant: ?loc:loc -> ?attrs:attrs -> constant -> pattern
    val interval: ?loc:loc -> ?attrs:attrs -> constant -> constant -> pattern
    val tuple: ?loc:loc -> ?attrs:attrs -> pattern list -> pattern
    val construct: ?loc:loc -> ?attrs:attrs -> lid -> pattern option -> pattern
    val variant: ?loc:loc -> ?attrs:attrs -> label -> pattern option -> pattern
    val record: ?loc:loc -> ?attrs:attrs -> (lid * pattern) list -> closed_flag
                -> pattern
    val array: ?loc:loc -> ?attrs:attrs -> pattern list -> pattern
    val or_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern -> pattern
    val constraint_: ?loc:loc -> ?attrs:attrs -> pattern -> core_type -> pattern
    val type_: ?loc:loc -> ?attrs:attrs -> lid -> pattern
    val lazy_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern
    val unpack: ?loc:loc -> ?attrs:attrs -> str -> pattern
    val exception_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> pattern
  end

(** Expressions *)
module Exp:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> expression_desc -> expression
    val attr: expression -> attribute -> expression

    val ident: ?loc:loc -> ?attrs:attrs -> lid -> expression
    val constant: ?loc:loc -> ?attrs:attrs -> constant -> expression
    val let_: ?loc:loc -> ?attrs:attrs -> rec_flag -> value_binding list
              -> expression -> expression
    val fun_: ?loc:loc -> ?attrs:attrs -> label -> expression option -> pattern
              -> expression -> expression
    val function_: ?loc:loc -> ?attrs:attrs -> case list -> expression
    val apply: ?loc:loc -> ?attrs:attrs -> expression
               -> (label * expression) list -> expression
    val match_: ?loc:loc -> ?attrs:attrs -> expression -> case list
                -> expression
    val try_: ?loc:loc -> ?attrs:attrs -> expression -> case list -> expression
    val tuple: ?loc:loc -> ?attrs:attrs -> expression list -> expression
    val construct: ?loc:loc -> ?attrs:attrs -> lid -> expression option
                   -> expression
    val variant: ?loc:loc -> ?attrs:attrs -> label -> expression option
                 -> expression
    val record: ?loc:loc -> ?attrs:attrs -> (lid * expression) list
                -> expression option -> expression
    val field: ?loc:loc -> ?attrs:attrs -> expression -> lid -> expression
    val setfield: ?loc:loc -> ?attrs:attrs -> expression -> lid -> expression
                  -> expression
    val array: ?loc:loc -> ?attrs:attrs -> expression list -> expression
    val ifthenelse: ?loc:loc -> ?attrs:attrs -> expression -> expression
                    -> expression option -> expression
    val sequence: ?loc:loc -> ?attrs:attrs -> expression -> expression
                  -> expression
    val while_: ?loc:loc -> ?attrs:attrs -> expression -> expression
                -> expression
    val for_: ?loc:loc -> ?attrs:attrs -> pattern -> expression -> expression
              -> direction_flag -> expression -> expression
    val coerce: ?loc:loc -> ?attrs:attrs -> expression -> core_type option
                -> core_type -> expression
    val constraint_: ?loc:loc -> ?attrs:attrs -> expression -> core_type
                     -> expression
    val send: ?loc:loc -> ?attrs:attrs -> expression -> string -> expression
    val new_: ?loc:loc -> ?attrs:attrs -> lid -> expression
    val setinstvar: ?loc:loc -> ?attrs:attrs -> str -> expression -> expression
    val override: ?loc:loc -> ?attrs:attrs -> (str * expression) list
                  -> expression
    val letmodule: ?loc:loc -> ?attrs:attrs -> str -> module_expr -> expression
                   -> expression
    val assert_: ?loc:loc -> ?attrs:attrs -> expression -> expression
    val lazy_: ?loc:loc -> ?attrs:attrs -> expression -> expression
    val poly: ?loc:loc -> ?attrs:attrs -> expression -> core_type option -> expression
    val object_: ?loc:loc -> ?attrs:attrs -> class_structure -> expression
    val newtype: ?loc:loc -> ?attrs:attrs -> string -> expression -> expression
    val pack: ?loc:loc -> ?attrs:attrs -> module_expr -> expression
    val open_: ?loc:loc -> ?attrs:attrs -> override_flag -> lid -> expression -> expression
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> expression

    val case: pattern -> ?guard:expression -> expression -> case
  end

(** Value declarations *)
module Val:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs ->
      ?prim:string list -> str -> core_type -> value_description
  end

(** Type declarations *)
module Type:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      ?params:(core_type * variance) list -> ?cstrs:(core_type * core_type * loc) list ->
      ?kind:type_kind -> ?priv:private_flag -> ?manifest:core_type -> str ->
      type_declaration

    val constructor: ?loc:loc -> ?attrs:attrs -> ?info:info ->
      ?args:core_type list -> ?res:core_type -> str -> constructor_declaration
    val field: ?loc:loc -> ?attrs:attrs -> ?info:info ->
      ?mut:mutable_flag -> str -> core_type -> label_declaration
  end

(** Type extensions *)
module Te:
  sig
    val mk: ?attrs:attrs -> ?docs:docs ->
      ?params:(core_type * variance) list -> ?priv:private_flag ->
      lid -> extension_constructor list -> type_extension

    val constructor: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
      str -> extension_constructor_kind -> extension_constructor

    val decl: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
      ?args:core_type list -> ?res:core_type -> str -> extension_constructor
    val rebind: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
      str -> lid -> extension_constructor
  end

(** {2 Module language} *)

(** Module type expressions *)
module Mty:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> module_type_desc -> module_type
    val attr: module_type -> attribute -> module_type

    val ident: ?loc:loc -> ?attrs:attrs -> lid -> module_type
    val alias: ?loc:loc -> ?attrs:attrs -> lid -> module_type
    val signature: ?loc:loc -> ?attrs:attrs -> signature -> module_type
    val functor_: ?loc:loc -> ?attrs:attrs ->
      str -> module_type option -> module_type -> module_type
    val with_: ?loc:loc -> ?attrs:attrs -> module_type -> with_constraint list -> module_type
    val typeof_: ?loc:loc -> ?attrs:attrs -> module_expr -> module_type
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> module_type
  end

(** Module expressions *)
module Mod:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> module_expr_desc -> module_expr
    val attr: module_expr -> attribute -> module_expr

    val ident: ?loc:loc -> ?attrs:attrs -> lid -> module_expr
    val structure: ?loc:loc -> ?attrs:attrs -> structure -> module_expr
    val functor_: ?loc:loc -> ?attrs:attrs ->
      str -> module_type option -> module_expr -> module_expr
    val apply: ?loc:loc -> ?attrs:attrs -> module_expr -> module_expr -> module_expr
    val constraint_: ?loc:loc -> ?attrs:attrs -> module_expr -> module_type -> module_expr
    val unpack: ?loc:loc -> ?attrs:attrs -> expression -> module_expr
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> module_expr
  end

(** Signature items *)
module Sig:
  sig
    val mk: ?loc:loc -> signature_item_desc -> signature_item

    val value: ?loc:loc -> value_description -> signature_item
    val type_: ?loc:loc -> type_declaration list -> signature_item
    val type_extension: ?loc:loc -> type_extension -> signature_item
    val exception_: ?loc:loc -> extension_constructor -> signature_item
    val module_: ?loc:loc -> module_declaration -> signature_item
    val rec_module: ?loc:loc -> module_declaration list -> signature_item
    val modtype: ?loc:loc -> module_type_declaration -> signature_item
    val open_: ?loc:loc -> open_description -> signature_item
    val include_: ?loc:loc -> include_description -> signature_item
    val class_: ?loc:loc -> class_description list -> signature_item
    val class_type: ?loc:loc -> class_type_declaration list -> signature_item
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> signature_item
    val attribute: ?loc:loc -> attribute -> signature_item
    val text: text -> signature_item list
  end

(** Structure items *)
module Str:
  sig
    val mk: ?loc:loc -> structure_item_desc -> structure_item

    val eval: ?loc:loc -> ?attrs:attributes -> expression -> structure_item
    val value: ?loc:loc -> rec_flag -> value_binding list -> structure_item
    val primitive: ?loc:loc -> value_description -> structure_item
    val type_: ?loc:loc -> type_declaration list -> structure_item
    val type_extension: ?loc:loc -> type_extension -> structure_item
    val exception_: ?loc:loc -> extension_constructor -> structure_item
    val module_: ?loc:loc -> module_binding -> structure_item
    val rec_module: ?loc:loc -> module_binding list -> structure_item
    val modtype: ?loc:loc -> module_type_declaration -> structure_item
    val open_: ?loc:loc -> open_description -> structure_item
    val class_: ?loc:loc -> class_declaration list -> structure_item
    val class_type: ?loc:loc -> class_type_declaration list -> structure_item
    val include_: ?loc:loc -> include_declaration -> structure_item
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> structure_item
    val attribute: ?loc:loc -> attribute -> structure_item
    val text: text -> structure_item list
  end

(** Module declarations *)
module Md:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      str -> module_type -> module_declaration
  end

(** Module type declarations *)
module Mtd:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      ?typ:module_type -> str -> module_type_declaration
  end

(** Module bindings *)
module Mb:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      str -> module_expr -> module_binding
  end

(* Opens *)
module Opn:
  sig
    val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs ->
      ?override:override_flag -> lid -> open_description
  end

(* Includes *)
module Incl:
  sig
    val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs -> 'a -> 'a include_infos
  end

(** Value bindings *)

module Vb:
  sig
    val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      pattern -> expression -> value_binding
  end


(** {2 Class language} *)

(** Class type expressions *)
module Cty:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> class_type_desc -> class_type
    val attr: class_type -> attribute -> class_type

    val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> class_type
    val signature: ?loc:loc -> ?attrs:attrs -> class_signature -> class_type
    val arrow: ?loc:loc -> ?attrs:attrs -> label -> core_type -> class_type -> class_type
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_type
  end

(** Class type fields *)
module Ctf:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs ->
      class_type_field_desc -> class_type_field
    val attr: class_type_field -> attribute -> class_type_field

    val inherit_: ?loc:loc -> ?attrs:attrs -> class_type -> class_type_field
    val val_: ?loc:loc -> ?attrs:attrs -> string -> mutable_flag -> virtual_flag -> core_type -> class_type_field
    val method_: ?loc:loc -> ?attrs:attrs -> string -> private_flag -> virtual_flag -> core_type -> class_type_field
    val constraint_: ?loc:loc -> ?attrs:attrs -> core_type -> core_type -> class_type_field
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_type_field
    val attribute: ?loc:loc -> attribute -> class_type_field
    val text: text -> class_type_field list
  end

(** Class expressions *)
module Cl:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> class_expr_desc -> class_expr
    val attr: class_expr -> attribute -> class_expr

    val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> class_expr
    val structure: ?loc:loc -> ?attrs:attrs -> class_structure -> class_expr
    val fun_: ?loc:loc -> ?attrs:attrs -> label -> expression option -> pattern -> class_expr -> class_expr
    val apply: ?loc:loc -> ?attrs:attrs -> class_expr -> (label * expression) list -> class_expr
    val let_: ?loc:loc -> ?attrs:attrs -> rec_flag -> value_binding list -> class_expr -> class_expr
    val constraint_: ?loc:loc -> ?attrs:attrs -> class_expr -> class_type -> class_expr
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_expr
  end

(** Class fields *)
module Cf:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> class_field_desc -> class_field
    val attr: class_field -> attribute -> class_field

    val inherit_: ?loc:loc -> ?attrs:attrs -> override_flag -> class_expr -> string option -> class_field
    val val_: ?loc:loc -> ?attrs:attrs -> str -> mutable_flag -> class_field_kind -> class_field
    val method_: ?loc:loc -> ?attrs:attrs -> str -> private_flag -> class_field_kind -> class_field
    val constraint_: ?loc:loc -> ?attrs:attrs -> core_type -> core_type -> class_field
    val initializer_: ?loc:loc -> ?attrs:attrs -> expression -> class_field
    val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_field
    val attribute: ?loc:loc -> attribute -> class_field
    val text: text -> class_field list

    val virtual_: core_type -> class_field_kind
    val concrete: override_flag -> expression -> class_field_kind

  end

(** Classes *)
module Ci:
  sig
    val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
      ?virt:virtual_flag -> ?params:(core_type * variance) list ->
      str -> 'a -> 'a class_infos
  end

(** Class signatures *)
module Csig:
  sig
    val mk: core_type -> class_type_field list -> class_signature
  end

(** Class structures *)
module Cstr:
  sig
    val mk: pattern -> class_field list -> class_structure
  end

end = struct
#1 "ast_helper.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*                        Alain Frisch, LexiFi                         *)
(*                                                                     *)
(*  Copyright 2012 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(** Helpers to produce Parsetree fragments *)

open Asttypes
open Parsetree
open Docstrings

type lid = Longident.t loc
type str = string loc
type loc = Location.t
type attrs = attribute list

let default_loc = ref Location.none

let with_default_loc l f =
  let old = !default_loc in
  default_loc := l;
  try let r = f () in default_loc := old; r
  with exn -> default_loc := old; raise exn

module Typ = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {ptyp_desc = d; ptyp_loc = loc; ptyp_attributes = attrs}
  let attr d a = {d with ptyp_attributes = d.ptyp_attributes @ [a]}

  let any ?loc ?attrs () = mk ?loc ?attrs Ptyp_any
  let var ?loc ?attrs a = mk ?loc ?attrs (Ptyp_var a)
  let arrow ?loc ?attrs a b c = mk ?loc ?attrs (Ptyp_arrow (a, b, c))
  let tuple ?loc ?attrs a = mk ?loc ?attrs (Ptyp_tuple a)
  let constr ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_constr (a, b))
  let object_ ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_object (a, b))
  let class_ ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_class (a, b))
  let alias ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_alias (a, b))
  let variant ?loc ?attrs a b c = mk ?loc ?attrs (Ptyp_variant (a, b, c))
  let poly ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_poly (a, b))
  let package ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_package (a, b))
  let extension ?loc ?attrs a = mk ?loc ?attrs (Ptyp_extension a)

  let force_poly t =
    match t.ptyp_desc with
    | Ptyp_poly _ -> t
    | _ -> poly ~loc:t.ptyp_loc [] t (* -> ghost? *)
end

module Pat = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {ppat_desc = d; ppat_loc = loc; ppat_attributes = attrs}
  let attr d a = {d with ppat_attributes = d.ppat_attributes @ [a]}

  let any ?loc ?attrs () = mk ?loc ?attrs Ppat_any
  let var ?loc ?attrs a = mk ?loc ?attrs (Ppat_var a)
  let alias ?loc ?attrs a b = mk ?loc ?attrs (Ppat_alias (a, b))
  let constant ?loc ?attrs a = mk ?loc ?attrs (Ppat_constant a)
  let interval ?loc ?attrs a b = mk ?loc ?attrs (Ppat_interval (a, b))
  let tuple ?loc ?attrs a = mk ?loc ?attrs (Ppat_tuple a)
  let construct ?loc ?attrs a b = mk ?loc ?attrs (Ppat_construct (a, b))
  let variant ?loc ?attrs a b = mk ?loc ?attrs (Ppat_variant (a, b))
  let record ?loc ?attrs a b = mk ?loc ?attrs (Ppat_record (a, b))
  let array ?loc ?attrs a = mk ?loc ?attrs (Ppat_array a)
  let or_ ?loc ?attrs a b = mk ?loc ?attrs (Ppat_or (a, b))
  let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Ppat_constraint (a, b))
  let type_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_type a)
  let lazy_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_lazy a)
  let unpack ?loc ?attrs a = mk ?loc ?attrs (Ppat_unpack a)
  let exception_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_exception a)
  let extension ?loc ?attrs a = mk ?loc ?attrs (Ppat_extension a)
end

module Exp = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {pexp_desc = d; pexp_loc = loc; pexp_attributes = attrs}
  let attr d a = {d with pexp_attributes = d.pexp_attributes @ [a]}

  let ident ?loc ?attrs a = mk ?loc ?attrs (Pexp_ident a)
  let constant ?loc ?attrs a = mk ?loc ?attrs (Pexp_constant a)
  let let_ ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_let (a, b, c))
  let fun_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pexp_fun (a, b, c, d))
  let function_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_function a)
  let apply ?loc ?attrs a b = mk ?loc ?attrs (Pexp_apply (a, b))
  let match_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_match (a, b))
  let try_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_try (a, b))
  let tuple ?loc ?attrs a = mk ?loc ?attrs (Pexp_tuple a)
  let construct ?loc ?attrs a b = mk ?loc ?attrs (Pexp_construct (a, b))
  let variant ?loc ?attrs a b = mk ?loc ?attrs (Pexp_variant (a, b))
  let record ?loc ?attrs a b = mk ?loc ?attrs (Pexp_record (a, b))
  let field ?loc ?attrs a b = mk ?loc ?attrs (Pexp_field (a, b))
  let setfield ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_setfield (a, b, c))
  let array ?loc ?attrs a = mk ?loc ?attrs (Pexp_array a)
  let ifthenelse ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_ifthenelse (a, b, c))
  let sequence ?loc ?attrs a b = mk ?loc ?attrs (Pexp_sequence (a, b))
  let while_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_while (a, b))
  let for_ ?loc ?attrs a b c d e = mk ?loc ?attrs (Pexp_for (a, b, c, d, e))
  let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_constraint (a, b))
  let coerce ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_coerce (a, b, c))
  let send ?loc ?attrs a b = mk ?loc ?attrs (Pexp_send (a, b))
  let new_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_new a)
  let setinstvar ?loc ?attrs a b = mk ?loc ?attrs (Pexp_setinstvar (a, b))
  let override ?loc ?attrs a = mk ?loc ?attrs (Pexp_override a)
  let letmodule ?loc ?attrs a b c= mk ?loc ?attrs (Pexp_letmodule (a, b, c))
  let assert_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_assert a)
  let lazy_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_lazy a)
  let poly ?loc ?attrs a b = mk ?loc ?attrs (Pexp_poly (a, b))
  let object_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_object a)
  let newtype ?loc ?attrs a b = mk ?loc ?attrs (Pexp_newtype (a, b))
  let pack ?loc ?attrs a = mk ?loc ?attrs (Pexp_pack a)
  let open_ ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_open (a, b, c))
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pexp_extension a)

  let case lhs ?guard rhs =
    {
     pc_lhs = lhs;
     pc_guard = guard;
     pc_rhs = rhs;
    }
end

module Mty = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {pmty_desc = d; pmty_loc = loc; pmty_attributes = attrs}
  let attr d a = {d with pmty_attributes = d.pmty_attributes @ [a]}

  let ident ?loc ?attrs a = mk ?loc ?attrs (Pmty_ident a)
  let alias ?loc ?attrs a = mk ?loc ?attrs (Pmty_alias a)
  let signature ?loc ?attrs a = mk ?loc ?attrs (Pmty_signature a)
  let functor_ ?loc ?attrs a b c = mk ?loc ?attrs (Pmty_functor (a, b, c))
  let with_ ?loc ?attrs a b = mk ?loc ?attrs (Pmty_with (a, b))
  let typeof_ ?loc ?attrs a = mk ?loc ?attrs (Pmty_typeof a)
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pmty_extension a)
end

module Mod = struct
let mk ?(loc = !default_loc) ?(attrs = []) d =
  {pmod_desc = d; pmod_loc = loc; pmod_attributes = attrs}
  let attr d a = {d with pmod_attributes = d.pmod_attributes @ [a]}

  let ident ?loc ?attrs x = mk ?loc ?attrs (Pmod_ident x)
  let structure ?loc ?attrs x = mk ?loc ?attrs (Pmod_structure x)
  let functor_ ?loc ?attrs arg arg_ty body =
    mk ?loc ?attrs (Pmod_functor (arg, arg_ty, body))
  let apply ?loc ?attrs m1 m2 = mk ?loc ?attrs (Pmod_apply (m1, m2))
  let constraint_ ?loc ?attrs m mty = mk ?loc ?attrs (Pmod_constraint (m, mty))
  let unpack ?loc ?attrs e = mk ?loc ?attrs (Pmod_unpack e)
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pmod_extension a)
end

module Sig = struct
  let mk ?(loc = !default_loc) d = {psig_desc = d; psig_loc = loc}

  let value ?loc a = mk ?loc (Psig_value a)
  let type_ ?loc a = mk ?loc (Psig_type a)
  let type_extension ?loc a = mk ?loc (Psig_typext a)
  let exception_ ?loc a = mk ?loc (Psig_exception a)
  let module_ ?loc a = mk ?loc (Psig_module a)
  let rec_module ?loc a = mk ?loc (Psig_recmodule a)
  let modtype ?loc a = mk ?loc (Psig_modtype a)
  let open_ ?loc a = mk ?loc (Psig_open a)
  let include_ ?loc a = mk ?loc (Psig_include a)
  let class_ ?loc a = mk ?loc (Psig_class a)
  let class_type ?loc a = mk ?loc (Psig_class_type a)
  let extension ?loc ?(attrs = []) a = mk ?loc (Psig_extension (a, attrs))
  let attribute ?loc a = mk ?loc (Psig_attribute a)
  let text txt =
    List.map
      (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
      txt
end

module Str = struct
  let mk ?(loc = !default_loc) d = {pstr_desc = d; pstr_loc = loc}

  let eval ?loc ?(attrs = []) a = mk ?loc (Pstr_eval (a, attrs))
  let value ?loc a b = mk ?loc (Pstr_value (a, b))
  let primitive ?loc a = mk ?loc (Pstr_primitive a)
  let type_ ?loc a = mk ?loc (Pstr_type a)
  let type_extension ?loc a = mk ?loc (Pstr_typext a)
  let exception_ ?loc a = mk ?loc (Pstr_exception a)
  let module_ ?loc a = mk ?loc (Pstr_module a)
  let rec_module ?loc a = mk ?loc (Pstr_recmodule a)
  let modtype ?loc a = mk ?loc (Pstr_modtype a)
  let open_ ?loc a = mk ?loc (Pstr_open a)
  let class_ ?loc a = mk ?loc (Pstr_class a)
  let class_type ?loc a = mk ?loc (Pstr_class_type a)
  let include_ ?loc a = mk ?loc (Pstr_include a)
  let extension ?loc ?(attrs = []) a = mk ?loc (Pstr_extension (a, attrs))
  let attribute ?loc a = mk ?loc (Pstr_attribute a)
  let text txt =
    List.map
      (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
      txt
end

module Cl = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {
     pcl_desc = d;
     pcl_loc = loc;
     pcl_attributes = attrs;
    }
  let attr d a = {d with pcl_attributes = d.pcl_attributes @ [a]}

  let constr ?loc ?attrs a b = mk ?loc ?attrs (Pcl_constr (a, b))
  let structure ?loc ?attrs a = mk ?loc ?attrs (Pcl_structure a)
  let fun_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pcl_fun (a, b, c, d))
  let apply ?loc ?attrs a b = mk ?loc ?attrs (Pcl_apply (a, b))
  let let_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcl_let (a, b, c))
  let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pcl_constraint (a, b))
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pcl_extension a)
end

module Cty = struct
  let mk ?(loc = !default_loc) ?(attrs = []) d =
    {
     pcty_desc = d;
     pcty_loc = loc;
     pcty_attributes = attrs;
    }
  let attr d a = {d with pcty_attributes = d.pcty_attributes @ [a]}

  let constr ?loc ?attrs a b = mk ?loc ?attrs (Pcty_constr (a, b))
  let signature ?loc ?attrs a = mk ?loc ?attrs (Pcty_signature a)
  let arrow ?loc ?attrs a b c = mk ?loc ?attrs (Pcty_arrow (a, b, c))
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pcty_extension a)
end

module Ctf = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
           ?(docs = empty_docs) d =
    {
     pctf_desc = d;
     pctf_loc = loc;
     pctf_attributes = add_docs_attrs docs attrs;
    }

  let inherit_ ?loc ?attrs a = mk ?loc ?attrs (Pctf_inherit a)
  let val_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pctf_val (a, b, c, d))
  let method_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pctf_method (a, b, c, d))
  let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pctf_constraint (a, b))
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pctf_extension a)
  let attribute ?loc a = mk ?loc (Pctf_attribute a)
  let text txt =
    List.map
      (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
      txt

  let attr d a = {d with pctf_attributes = d.pctf_attributes @ [a]}

end

module Cf = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) d =
    {
     pcf_desc = d;
     pcf_loc = loc;
     pcf_attributes = add_docs_attrs docs attrs;
    }

  let inherit_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_inherit (a, b, c))
  let val_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_val (a, b, c))
  let method_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_method (a, b, c))
  let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pcf_constraint (a, b))
  let initializer_ ?loc ?attrs a = mk ?loc ?attrs (Pcf_initializer a)
  let extension ?loc ?attrs a = mk ?loc ?attrs (Pcf_extension a)
  let attribute ?loc a = mk ?loc (Pcf_attribute a)
  let text txt =
    List.map
      (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
      txt

  let virtual_ ct = Cfk_virtual ct
  let concrete o e = Cfk_concrete (o, e)

  let attr d a = {d with pcf_attributes = d.pcf_attributes @ [a]}

end

module Val = struct
  let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
        ?(prim = []) name typ =
    {
     pval_name = name;
     pval_type = typ;
     pval_attributes = add_docs_attrs docs attrs;
     pval_loc = loc;
     pval_prim = prim;
    }
end

module Md = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(text = []) name typ =
    {
     pmd_name = name;
     pmd_type = typ;
     pmd_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     pmd_loc = loc;
    }
end

module Mtd = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(text = []) ?typ name =
    {
     pmtd_name = name;
     pmtd_type = typ;
     pmtd_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     pmtd_loc = loc;
    }
end

module Mb = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(text = []) name expr =
    {
     pmb_name = name;
     pmb_expr = expr;
     pmb_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     pmb_loc = loc;
    }
end

module Opn = struct
  let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
        ?(override = Fresh) lid =
    {
     popen_lid = lid;
     popen_override = override;
     popen_loc = loc;
     popen_attributes = add_docs_attrs docs attrs;
    }
end

module Incl = struct
  let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs) mexpr =
    {
     pincl_mod = mexpr;
     pincl_loc = loc;
     pincl_attributes = add_docs_attrs docs attrs;
    }

end

module Vb = struct
  let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
        ?(text = []) pat expr =
    {
     pvb_pat = pat;
     pvb_expr = expr;
     pvb_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     pvb_loc = loc;
    }
end

module Ci = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(text = [])
        ?(virt = Concrete) ?(params = []) name expr =
    {
     pci_virt = virt;
     pci_params = params;
     pci_name = name;
     pci_expr = expr;
     pci_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     pci_loc = loc;
    }
end

module Type = struct
  let mk ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(text = [])
      ?(params = [])
      ?(cstrs = [])
      ?(kind = Ptype_abstract)
      ?(priv = Public)
      ?manifest
      name =
    {
     ptype_name = name;
     ptype_params = params;
     ptype_cstrs = cstrs;
     ptype_kind = kind;
     ptype_private = priv;
     ptype_manifest = manifest;
     ptype_attributes =
       add_text_attrs text (add_docs_attrs docs attrs);
     ptype_loc = loc;
    }

  let constructor ?(loc = !default_loc) ?(attrs = []) ?(info = empty_info)
        ?(args = []) ?res name =
    {
     pcd_name = name;
     pcd_args = args;
     pcd_res = res;
     pcd_loc = loc;
     pcd_attributes = add_info_attrs info attrs;
    }

  let field ?(loc = !default_loc) ?(attrs = []) ?(info = empty_info)
        ?(mut = Immutable) name typ =
    {
     pld_name = name;
     pld_mutable = mut;
     pld_type = typ;
     pld_loc = loc;
     pld_attributes = add_info_attrs info attrs;
    }

end

(** Type extensions *)
module Te = struct
  let mk ?(attrs = []) ?(docs = empty_docs)
        ?(params = []) ?(priv = Public) path constructors =
    {
     ptyext_path = path;
     ptyext_params = params;
     ptyext_constructors = constructors;
     ptyext_private = priv;
     ptyext_attributes = add_docs_attrs docs attrs;
    }

  let constructor ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(info = empty_info) name kind =
    {
     pext_name = name;
     pext_kind = kind;
     pext_loc = loc;
     pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
    }

  let decl ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(info = empty_info) ?(args = []) ?res name =
    {
     pext_name = name;
     pext_kind = Pext_decl(args, res);
     pext_loc = loc;
     pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
    }

  let rebind ?(loc = !default_loc) ?(attrs = [])
        ?(docs = empty_docs) ?(info = empty_info) name lid =
    {
     pext_name = name;
     pext_kind = Pext_rebind lid;
     pext_loc = loc;
     pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
    }

end

module Csig = struct
  let mk self fields =
    {
     pcsig_self = self;
     pcsig_fields = fields;
    }
end

module Cstr = struct
  let mk self fields =
    {
     pcstr_self = self;
     pcstr_fields = fields;
    }
end


end
module Syntaxerr : sig
#1 "syntaxerr.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1997 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Auxiliary type for reporting syntax errors *)

open Format

type error =
    Unclosed of Location.t * string * Location.t * string
  | Expecting of Location.t * string
  | Not_expecting of Location.t * string
  | Applicative_path of Location.t
  | Variable_in_scope of Location.t * string
  | Other of Location.t
  | Ill_formed_ast of Location.t * string

exception Error of error
exception Escape_error

val report_error: formatter -> error -> unit
 (* Deprecated.  Use Location.{error_of_exn, report_error}. *)

val location_of_error: error -> Location.t
val ill_formed_ast: Location.t -> string -> 'a

end = struct
#1 "syntaxerr.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1997 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Auxiliary type for reporting syntax errors *)

type error =
    Unclosed of Location.t * string * Location.t * string
  | Expecting of Location.t * string
  | Not_expecting of Location.t * string
  | Applicative_path of Location.t
  | Variable_in_scope of Location.t * string
  | Other of Location.t
  | Ill_formed_ast of Location.t * string

exception Error of error
exception Escape_error

let prepare_error = function
  | Unclosed(opening_loc, opening, closing_loc, closing) ->
      Location.errorf ~loc:closing_loc
        ~sub:[
          Location.errorf ~loc:opening_loc
            "This '%s' might be unmatched" opening
        ]
        ~if_highlight:
          (Printf.sprintf "Syntax error: '%s' expected, \
                           the highlighted '%s' might be unmatched"
             closing opening)
        "Syntax error: '%s' expected" closing

  | Expecting (loc, nonterm) ->
      Location.errorf ~loc "Syntax error: %s expected." nonterm
  | Not_expecting (loc, nonterm) ->
      Location.errorf ~loc "Syntax error: %s not expected." nonterm
  | Applicative_path loc ->
      Location.errorf ~loc
        "Syntax error: applicative paths of the form F(X).t \
         are not supported when the option -no-app-func is set."
  | Variable_in_scope (loc, var) ->
      Location.errorf ~loc
        "In this scoped type, variable '%s \
         is reserved for the local type %s."
         var var
  | Other loc ->
      Location.errorf ~loc "Syntax error"
  | Ill_formed_ast (loc, s) ->
      Location.errorf ~loc "broken invariant in parsetree: %s" s

let () =
  Location.register_error_of_exn
    (function
      | Error err -> Some (prepare_error err)
      | _ -> None
    )


let report_error ppf err =
  Location.report_error ppf (prepare_error err)

let location_of_error = function
  | Unclosed(l,_,_,_)
  | Applicative_path l
  | Variable_in_scope(l,_)
  | Other l
  | Not_expecting (l, _)
  | Ill_formed_ast (l, _)
  | Expecting (l, _) -> l


let ill_formed_ast loc s =
  raise (Error (Ill_formed_ast (loc, s)))

end
module Parser : sig
#1 "parser.mli"
type token =
  | AMPERAMPER
  | AMPERSAND
  | AND
  | AS
  | ASSERT
  | BACKQUOTE
  | BANG
  | BAR
  | BARBAR
  | BARRBRACKET
  | BEGIN
  | CHAR of (char)
  | CLASS
  | COLON
  | COLONCOLON
  | COLONEQUAL
  | COLONGREATER
  | COMMA
  | CONSTRAINT
  | DO
  | DONE
  | DOT
  | DOTDOT
  | DOWNTO
  | ELSE
  | END
  | EOF
  | EQUAL
  | EXCEPTION
  | EXTERNAL
  | FALSE
  | FLOAT of (string)
  | FOR
  | FUN
  | FUNCTION
  | FUNCTOR
  | GREATER
  | GREATERRBRACE
  | GREATERRBRACKET
  | IF
  | IN
  | INCLUDE
  | INFIXOP0 of (string)
  | INFIXOP1 of (string)
  | INFIXOP2 of (string)
  | INFIXOP3 of (string)
  | INFIXOP4 of (string)
  | INHERIT
  | INITIALIZER
  | INT of (int)
  | INT32 of (int32)
  | INT64 of (int64)
  | LABEL of (string)
  | LAZY
  | LBRACE
  | LBRACELESS
  | LBRACKET
  | LBRACKETBAR
  | LBRACKETLESS
  | LBRACKETGREATER
  | LBRACKETPERCENT
  | LBRACKETPERCENTPERCENT
  | LESS
  | LESSMINUS
  | LET
  | LIDENT of (string)
  | LPAREN
  | LBRACKETAT
  | LBRACKETATAT
  | LBRACKETATATAT
  | MATCH
  | METHOD
  | MINUS
  | MINUSDOT
  | MINUSGREATER
  | MODULE
  | MUTABLE
  | NATIVEINT of (nativeint)
  | NEW
  | NONREC
  | OBJECT
  | OF
  | OPEN
  | OPTLABEL of (string)
  | OR
  | PERCENT
  | PLUS
  | PLUSDOT
  | PLUSEQ
  | PREFIXOP of (string)
  | PRIVATE
  | QUESTION
  | QUOTE
  | RBRACE
  | RBRACKET
  | REC
  | RPAREN
  | SEMI
  | SEMISEMI
  | SHARP
  | SHARPOP of (string)
  | SIG
  | STAR
  | STRING of (string * string option)
  | STRUCT
  | THEN
  | TILDE
  | TO
  | TRUE
  | TRY
  | TYPE
  | UIDENT of (string)
  | UNDERSCORE
  | VAL
  | VIRTUAL
  | WHEN
  | WHILE
  | WITH
  | COMMENT of (string * Location.t)
  | DOCSTRING of (Docstrings.docstring)
  | EOL

val implementation :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.structure
val interface :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.signature
val toplevel_phrase :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.toplevel_phrase
val use_file :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.toplevel_phrase list
val parse_core_type :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.core_type
val parse_expression :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.expression
val parse_pattern :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Parsetree.pattern

end = struct
#1 "parser.ml"
type token =
  | AMPERAMPER
  | AMPERSAND
  | AND
  | AS
  | ASSERT
  | BACKQUOTE
  | BANG
  | BAR
  | BARBAR
  | BARRBRACKET
  | BEGIN
  | CHAR of (char)
  | CLASS
  | COLON
  | COLONCOLON
  | COLONEQUAL
  | COLONGREATER
  | COMMA
  | CONSTRAINT
  | DO
  | DONE
  | DOT
  | DOTDOT
  | DOWNTO
  | ELSE
  | END
  | EOF
  | EQUAL
  | EXCEPTION
  | EXTERNAL
  | FALSE
  | FLOAT of (string)
  | FOR
  | FUN
  | FUNCTION
  | FUNCTOR
  | GREATER
  | GREATERRBRACE
  | GREATERRBRACKET
  | IF
  | IN
  | INCLUDE
  | INFIXOP0 of (string)
  | INFIXOP1 of (string)
  | INFIXOP2 of (string)
  | INFIXOP3 of (string)
  | INFIXOP4 of (string)
  | INHERIT
  | INITIALIZER
  | INT of (int)
  | INT32 of (int32)
  | INT64 of (int64)
  | LABEL of (string)
  | LAZY
  | LBRACE
  | LBRACELESS
  | LBRACKET
  | LBRACKETBAR
  | LBRACKETLESS
  | LBRACKETGREATER
  | LBRACKETPERCENT
  | LBRACKETPERCENTPERCENT
  | LESS
  | LESSMINUS
  | LET
  | LIDENT of (string)
  | LPAREN
  | LBRACKETAT
  | LBRACKETATAT
  | LBRACKETATATAT
  | MATCH
  | METHOD
  | MINUS
  | MINUSDOT
  | MINUSGREATER
  | MODULE
  | MUTABLE
  | NATIVEINT of (nativeint)
  | NEW
  | NONREC
  | OBJECT
  | OF
  | OPEN
  | OPTLABEL of (string)
  | OR
  | PERCENT
  | PLUS
  | PLUSDOT
  | PLUSEQ
  | PREFIXOP of (string)
  | PRIVATE
  | QUESTION
  | QUOTE
  | RBRACE
  | RBRACKET
  | REC
  | RPAREN
  | SEMI
  | SEMISEMI
  | SHARP
  | SHARPOP of (string)
  | SIG
  | STAR
  | STRING of (string * string option)
  | STRUCT
  | THEN
  | TILDE
  | TO
  | TRUE
  | TRY
  | TYPE
  | UIDENT of (string)
  | UNDERSCORE
  | VAL
  | VIRTUAL
  | WHEN
  | WHILE
  | WITH
  | COMMENT of (string * Location.t)
  | DOCSTRING of (Docstrings.docstring)
  | EOL

open Parsing;;
let _ = parse_error;;
# 16 "parsing/parser.mly"
open Location
open Asttypes
open Longident
open Parsetree
open Ast_helper
open Docstrings

let mktyp d = Typ.mk ~loc:(symbol_rloc()) d
let mkpat d = Pat.mk ~loc:(symbol_rloc()) d
let mkexp d = Exp.mk ~loc:(symbol_rloc()) d
let mkmty d = Mty.mk ~loc:(symbol_rloc()) d
let mksig d = Sig.mk ~loc:(symbol_rloc()) d
let mkmod d = Mod.mk ~loc:(symbol_rloc()) d
let mkstr d = Str.mk ~loc:(symbol_rloc()) d
let mkclass d = Cl.mk ~loc:(symbol_rloc()) d
let mkcty d = Cty.mk ~loc:(symbol_rloc()) d
let mkctf ?attrs ?docs d =
  Ctf.mk ~loc:(symbol_rloc()) ?attrs ?docs d
let mkcf ?attrs ?docs d =
  Cf.mk ~loc:(symbol_rloc()) ?attrs ?docs d

let mkrhs rhs pos = mkloc rhs (rhs_loc pos)
let mkoption d =
  let loc = {d.ptyp_loc with loc_ghost = true} in
  Typ.mk ~loc (Ptyp_constr(mkloc (Ldot (Lident "*predef*", "option")) loc,[d]))

let reloc_pat x = { x with ppat_loc = symbol_rloc () };;
let reloc_exp x = { x with pexp_loc = symbol_rloc () };;

let mkoperator name pos =
  let loc = rhs_loc pos in
  Exp.mk ~loc (Pexp_ident(mkloc (Lident name) loc))

let mkpatvar name pos =
  Pat.mk ~loc:(rhs_loc pos) (Ppat_var (mkrhs name pos))

(*
  Ghost expressions and patterns:
  expressions and patterns that do not appear explicitly in the
  source file they have the loc_ghost flag set to true.
  Then the profiler will not try to instrument them and the
  -annot option will not try to display their type.

  Every grammar rule that generates an element with a location must
  make at most one non-ghost element, the topmost one.

  How to tell whether your location must be ghost:
  A location corresponds to a range of characters in the source file.
  If the location contains a piece of code that is syntactically
  valid (according to the documentation), and corresponds to the
  AST node, then the location must be real; in all other cases,
  it must be ghost.
*)
let ghexp d = Exp.mk ~loc:(symbol_gloc ()) d
let ghpat d = Pat.mk ~loc:(symbol_gloc ()) d
let ghtyp d = Typ.mk ~loc:(symbol_gloc ()) d
let ghloc d = { txt = d; loc = symbol_gloc () }
let ghstr d = Str.mk ~loc:(symbol_gloc()) d

let ghunit () =
  ghexp (Pexp_construct (mknoloc (Lident "()"), None))

let mkinfix arg1 name arg2 =
  mkexp(Pexp_apply(mkoperator name 2, ["", arg1; "", arg2]))

let neg_float_string f =
  if String.length f > 0 && f.[0] = '-'
  then String.sub f 1 (String.length f - 1)
  else "-" ^ f

let mkuminus name arg =
  match name, arg.pexp_desc with
  | "-", Pexp_constant(Const_int n) ->
      mkexp(Pexp_constant(Const_int(-n)))
  | "-", Pexp_constant(Const_int32 n) ->
      mkexp(Pexp_constant(Const_int32(Int32.neg n)))
  | "-", Pexp_constant(Const_int64 n) ->
      mkexp(Pexp_constant(Const_int64(Int64.neg n)))
  | "-", Pexp_constant(Const_nativeint n) ->
      mkexp(Pexp_constant(Const_nativeint(Nativeint.neg n)))
  | ("-" | "-."), Pexp_constant(Const_float f) ->
      mkexp(Pexp_constant(Const_float(neg_float_string f)))
  | _ ->
      mkexp(Pexp_apply(mkoperator ("~" ^ name) 1, ["", arg]))

let mkuplus name arg =
  let desc = arg.pexp_desc in
  match name, desc with
  | "+", Pexp_constant(Const_int _)
  | "+", Pexp_constant(Const_int32 _)
  | "+", Pexp_constant(Const_int64 _)
  | "+", Pexp_constant(Const_nativeint _)
  | ("+" | "+."), Pexp_constant(Const_float _) -> mkexp desc
  | _ ->
      mkexp(Pexp_apply(mkoperator ("~" ^ name) 1, ["", arg]))

let mkexp_cons consloc args loc =
  Exp.mk ~loc (Pexp_construct(mkloc (Lident "::") consloc, Some args))

let mkpat_cons consloc args loc =
  Pat.mk ~loc (Ppat_construct(mkloc (Lident "::") consloc, Some args))

let rec mktailexp nilloc = function
    [] ->
      let loc = { nilloc with loc_ghost = true } in
      let nil = { txt = Lident "[]"; loc = loc } in
      Exp.mk ~loc (Pexp_construct (nil, None))
  | e1 :: el ->
      let exp_el = mktailexp nilloc el in
      let loc = {loc_start = e1.pexp_loc.loc_start;
               loc_end = exp_el.pexp_loc.loc_end;
               loc_ghost = true}
      in
      let arg = Exp.mk ~loc (Pexp_tuple [e1; exp_el]) in
      mkexp_cons {loc with loc_ghost = true} arg loc

let rec mktailpat nilloc = function
    [] ->
      let loc = { nilloc with loc_ghost = true } in
      let nil = { txt = Lident "[]"; loc = loc } in
      Pat.mk ~loc (Ppat_construct (nil, None))
  | p1 :: pl ->
      let pat_pl = mktailpat nilloc pl in
      let loc = {loc_start = p1.ppat_loc.loc_start;
               loc_end = pat_pl.ppat_loc.loc_end;
               loc_ghost = true}
      in
      let arg = Pat.mk ~loc (Ppat_tuple [p1; pat_pl]) in
      mkpat_cons {loc with loc_ghost = true} arg loc

let mkstrexp e attrs =
  { pstr_desc = Pstr_eval (e, attrs); pstr_loc = e.pexp_loc }

let mkexp_constraint e (t1, t2) =
  match t1, t2 with
  | Some t, None -> ghexp(Pexp_constraint(e, t))
  | _, Some t -> ghexp(Pexp_coerce(e, t1, t))
  | None, None -> assert false

let array_function str name =
  ghloc (Ldot(Lident str, (if !Clflags.fast then "unsafe_" ^ name else name)))

let syntax_error () =
  raise Syntaxerr.Escape_error

let unclosed opening_name opening_num closing_name closing_num =
  raise(Syntaxerr.Error(Syntaxerr.Unclosed(rhs_loc opening_num, opening_name,
                                           rhs_loc closing_num, closing_name)))

let expecting pos nonterm =
    raise Syntaxerr.(Error(Expecting(rhs_loc pos, nonterm)))

let not_expecting pos nonterm =
    raise Syntaxerr.(Error(Not_expecting(rhs_loc pos, nonterm)))

let bigarray_function str name =
  ghloc (Ldot(Ldot(Lident "Bigarray", str), name))

let bigarray_untuplify = function
    { pexp_desc = Pexp_tuple explist; pexp_loc = _ } -> explist
  | exp -> [exp]

let bigarray_get arr arg =
  let get = if !Clflags.fast then "unsafe_get" else "get" in
  match bigarray_untuplify arg with
    [c1] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array1" get)),
                       ["", arr; "", c1]))
  | [c1;c2] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array2" get)),
                       ["", arr; "", c1; "", c2]))
  | [c1;c2;c3] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array3" get)),
                       ["", arr; "", c1; "", c2; "", c3]))
  | coords ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Genarray" "get")),
                       ["", arr; "", ghexp(Pexp_array coords)]))

let bigarray_set arr arg newval =
  let set = if !Clflags.fast then "unsafe_set" else "set" in
  match bigarray_untuplify arg with
    [c1] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array1" set)),
                       ["", arr; "", c1; "", newval]))
  | [c1;c2] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array2" set)),
                       ["", arr; "", c1; "", c2; "", newval]))
  | [c1;c2;c3] ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Array3" set)),
                       ["", arr; "", c1; "", c2; "", c3; "", newval]))
  | coords ->
      mkexp(Pexp_apply(ghexp(Pexp_ident(bigarray_function "Genarray" "set")),
                       ["", arr;
                        "", ghexp(Pexp_array coords);
                        "", newval]))

let lapply p1 p2 =
  if !Clflags.applicative_functors
  then Lapply(p1, p2)
  else raise (Syntaxerr.Error(Syntaxerr.Applicative_path (symbol_rloc())))

let exp_of_label lbl pos =
  mkexp (Pexp_ident(mkrhs (Lident(Longident.last lbl)) pos))

let pat_of_label lbl pos =
  mkpat (Ppat_var (mkrhs (Longident.last lbl) pos))

let check_variable vl loc v =
  if List.mem v vl then
    raise Syntaxerr.(Error(Variable_in_scope(loc,v)))

let varify_constructors var_names t =
  let rec loop t =
    let desc =
      match t.ptyp_desc with
      | Ptyp_any -> Ptyp_any
      | Ptyp_var x ->
          check_variable var_names t.ptyp_loc x;
          Ptyp_var x
      | Ptyp_arrow (label,core_type,core_type') ->
          Ptyp_arrow(label, loop core_type, loop core_type')
      | Ptyp_tuple lst -> Ptyp_tuple (List.map loop lst)
      | Ptyp_constr( { txt = Lident s }, []) when List.mem s var_names ->
          Ptyp_var s
      | Ptyp_constr(longident, lst) ->
          Ptyp_constr(longident, List.map loop lst)
      | Ptyp_object (lst, o) ->
          Ptyp_object
            (List.map (fun (s, attrs, t) -> (s, attrs, loop t)) lst, o)
      | Ptyp_class (longident, lst) ->
          Ptyp_class (longident, List.map loop lst)
      | Ptyp_alias(core_type, string) ->
          check_variable var_names t.ptyp_loc string;
          Ptyp_alias(loop core_type, string)
      | Ptyp_variant(row_field_list, flag, lbl_lst_option) ->
          Ptyp_variant(List.map loop_row_field row_field_list,
                       flag, lbl_lst_option)
      | Ptyp_poly(string_lst, core_type) ->
          List.iter (check_variable var_names t.ptyp_loc) string_lst;
          Ptyp_poly(string_lst, loop core_type)
      | Ptyp_package(longident,lst) ->
          Ptyp_package(longident,List.map (fun (n,typ) -> (n,loop typ) ) lst)
      | Ptyp_extension (s, arg) ->
          Ptyp_extension (s, arg)
    in
    {t with ptyp_desc = desc}
  and loop_row_field  =
    function
      | Rtag(label,attrs,flag,lst) ->
          Rtag(label,attrs,flag,List.map loop lst)
      | Rinherit t ->
          Rinherit (loop t)
  in
  loop t

let wrap_type_annotation newtypes core_type body =
  let exp = mkexp(Pexp_constraint(body,core_type)) in
  let exp =
    List.fold_right (fun newtype exp -> mkexp (Pexp_newtype (newtype, exp)))
      newtypes exp
  in
  (exp, ghtyp(Ptyp_poly(newtypes,varify_constructors newtypes core_type)))

let wrap_exp_attrs body (ext, attrs) =
  (* todo: keep exact location for the entire attribute *)
  let body = {body with pexp_attributes = attrs @ body.pexp_attributes} in
  match ext with
  | None -> body
  | Some id -> ghexp(Pexp_extension (id, PStr [mkstrexp body []]))

let mkexp_attrs d attrs =
  wrap_exp_attrs (mkexp d) attrs

let text_str pos = Str.text (rhs_text pos)
let text_sig pos = Sig.text (rhs_text pos)
let text_cstr pos = Cf.text (rhs_text pos)
let text_csig pos = Ctf.text (rhs_text pos)
let text_def pos = [Ptop_def (Str.text (rhs_text pos))]

let extra_text text pos items =
  let pre_extras = rhs_pre_extra_text pos in
  let post_extras = rhs_post_extra_text pos in
    text pre_extras @ items @ text post_extras

let extra_str pos items = extra_text Str.text pos items
let extra_sig pos items = extra_text Sig.text pos items
let extra_cstr pos items = extra_text Cf.text pos items
let extra_csig pos items = extra_text Ctf.text pos items
let extra_def pos items =
  extra_text (fun txt -> [Ptop_def (Str.text txt)]) pos items

let add_nonrec rf attrs pos =
  match rf with
  | Recursive -> attrs
  | Nonrecursive ->
      let name = { txt = "nonrec"; loc = rhs_loc pos } in
        (name, PStr []) :: attrs

type let_binding =
  { lb_pattern: pattern;
    lb_expression: expression;
    lb_attributes: attributes;
    lb_docs: docs Lazy.t;
    lb_text: text Lazy.t;
    lb_loc: Location.t; }

type let_bindings =
  { lbs_bindings: let_binding list;
    lbs_rec: rec_flag;
    lbs_extension: string Asttypes.loc option;
    lbs_attributes: attributes;
    lbs_loc: Location.t }

let mklb (p, e) attrs =
  { lb_pattern = p;
    lb_expression = e;
    lb_attributes = attrs;
    lb_docs = symbol_docs_lazy ();
    lb_text = symbol_text_lazy ();
    lb_loc = symbol_rloc (); }

let mklbs (ext, attrs) rf lb =
  { lbs_bindings = [lb];
    lbs_rec = rf;
    lbs_extension = ext ;
    lbs_attributes = attrs;
    lbs_loc = symbol_rloc (); }

let addlb lbs lb =
  { lbs with lbs_bindings = lb :: lbs.lbs_bindings }

let val_of_let_bindings lbs =
  let str =
    match lbs.lbs_bindings with
    | [ {lb_pattern = { ppat_desc = Ppat_any; ppat_loc = _ }; _} as lb ] ->
        let exp = wrap_exp_attrs lb.lb_expression
                    (None, lbs.lbs_attributes) in
        mkstr (Pstr_eval (exp, lb.lb_attributes))
    | bindings ->
        if lbs.lbs_attributes <> [] then
          raise Syntaxerr.(Error(Not_expecting(lbs.lbs_loc, "attributes")));
        let bindings =
          List.map
            (fun lb ->
               Vb.mk ~loc:lb.lb_loc ~attrs:lb.lb_attributes
                 ~docs:(Lazy.force lb.lb_docs)
                 ~text:(Lazy.force lb.lb_text)
                 lb.lb_pattern lb.lb_expression)
            bindings
        in
        mkstr(Pstr_value(lbs.lbs_rec, List.rev bindings))
  in
  match lbs.lbs_extension with
  | None -> str
  | Some id -> ghstr (Pstr_extension((id, PStr [str]), []))

let expr_of_let_bindings lbs body =
  let bindings =
    List.map
      (fun lb ->
         if lb.lb_attributes <> [] then
           raise Syntaxerr.(Error(Not_expecting(lb.lb_loc, "item attribute")));
         Vb.mk ~loc:lb.lb_loc lb.lb_pattern lb.lb_expression)
      lbs.lbs_bindings
  in
    mkexp_attrs (Pexp_let(lbs.lbs_rec, List.rev bindings, body))
      (lbs.lbs_extension, lbs.lbs_attributes)

let class_of_let_bindings lbs body =
  let bindings =
    List.map
      (fun lb ->
         if lb.lb_attributes <> [] then
           raise Syntaxerr.(Error(Not_expecting(lb.lb_loc, "item attribute")));
         Vb.mk ~loc:lb.lb_loc lb.lb_pattern lb.lb_expression)
      lbs.lbs_bindings
  in
    if lbs.lbs_extension <> None then
      raise Syntaxerr.(Error(Not_expecting(lbs.lbs_loc, "extension")));
    if lbs.lbs_attributes <> [] then
      raise Syntaxerr.(Error(Not_expecting(lbs.lbs_loc, "attributes")));
    mkclass(Pcl_let (lbs.lbs_rec, List.rev bindings, body))

# 511 "parsing/parser.ml"
let yytransl_const = [|
  257 (* AMPERAMPER *);
  258 (* AMPERSAND *);
  259 (* AND *);
  260 (* AS *);
  261 (* ASSERT *);
  262 (* BACKQUOTE *);
  263 (* BANG *);
  264 (* BAR *);
  265 (* BARBAR *);
  266 (* BARRBRACKET *);
  267 (* BEGIN *);
  269 (* CLASS *);
  270 (* COLON *);
  271 (* COLONCOLON *);
  272 (* COLONEQUAL *);
  273 (* COLONGREATER *);
  274 (* COMMA *);
  275 (* CONSTRAINT *);
  276 (* DO *);
  277 (* DONE *);
  278 (* DOT *);
  279 (* DOTDOT *);
  280 (* DOWNTO *);
  281 (* ELSE *);
  282 (* END *);
    0 (* EOF *);
  283 (* EQUAL *);
  284 (* EXCEPTION *);
  285 (* EXTERNAL *);
  286 (* FALSE *);
  288 (* FOR *);
  289 (* FUN *);
  290 (* FUNCTION *);
  291 (* FUNCTOR *);
  292 (* GREATER *);
  293 (* GREATERRBRACE *);
  294 (* GREATERRBRACKET *);
  295 (* IF *);
  296 (* IN *);
  297 (* INCLUDE *);
  303 (* INHERIT *);
  304 (* INITIALIZER *);
  309 (* LAZY *);
  310 (* LBRACE *);
  311 (* LBRACELESS *);
  312 (* LBRACKET *);
  313 (* LBRACKETBAR *);
  314 (* LBRACKETLESS *);
  315 (* LBRACKETGREATER *);
  316 (* LBRACKETPERCENT *);
  317 (* LBRACKETPERCENTPERCENT *);
  318 (* LESS *);
  319 (* LESSMINUS *);
  320 (* LET *);
  322 (* LPAREN *);
  323 (* LBRACKETAT *);
  324 (* LBRACKETATAT *);
  325 (* LBRACKETATATAT *);
  326 (* MATCH *);
  327 (* METHOD *);
  328 (* MINUS *);
  329 (* MINUSDOT *);
  330 (* MINUSGREATER *);
  331 (* MODULE *);
  332 (* MUTABLE *);
  334 (* NEW *);
  335 (* NONREC *);
  336 (* OBJECT *);
  337 (* OF *);
  338 (* OPEN *);
  340 (* OR *);
  341 (* PERCENT *);
  342 (* PLUS *);
  343 (* PLUSDOT *);
  344 (* PLUSEQ *);
  346 (* PRIVATE *);
  347 (* QUESTION *);
  348 (* QUOTE *);
  349 (* RBRACE *);
  350 (* RBRACKET *);
  351 (* REC *);
  352 (* RPAREN *);
  353 (* SEMI *);
  354 (* SEMISEMI *);
  355 (* SHARP *);
  357 (* SIG *);
  358 (* STAR *);
  360 (* STRUCT *);
  361 (* THEN *);
  362 (* TILDE *);
  363 (* TO *);
  364 (* TRUE *);
  365 (* TRY *);
  366 (* TYPE *);
  368 (* UNDERSCORE *);
  369 (* VAL *);
  370 (* VIRTUAL *);
  371 (* WHEN *);
  372 (* WHILE *);
  373 (* WITH *);
  376 (* EOL *);
    0|]

let yytransl_block = [|
  268 (* CHAR *);
  287 (* FLOAT *);
  298 (* INFIXOP0 *);
  299 (* INFIXOP1 *);
  300 (* INFIXOP2 *);
  301 (* INFIXOP3 *);
  302 (* INFIXOP4 *);
  305 (* INT *);
  306 (* INT32 *);
  307 (* INT64 *);
  308 (* LABEL *);
  321 (* LIDENT *);
  333 (* NATIVEINT *);
  339 (* OPTLABEL *);
  345 (* PREFIXOP *);
  356 (* SHARPOP *);
  359 (* STRING *);
  367 (* UIDENT *);
  374 (* COMMENT *);
  375 (* DOCSTRING *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\003\000\003\000\003\000\010\000\010\000\014\000\
\014\000\004\000\016\000\016\000\017\000\017\000\017\000\017\000\
\017\000\017\000\017\000\005\000\006\000\007\000\020\000\020\000\
\021\000\021\000\023\000\023\000\024\000\024\000\024\000\024\000\
\024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
\024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
\008\000\008\000\030\000\030\000\030\000\015\000\015\000\015\000\
\015\000\015\000\015\000\015\000\015\000\015\000\015\000\015\000\
\015\000\015\000\015\000\042\000\045\000\045\000\045\000\036\000\
\037\000\037\000\046\000\047\000\022\000\022\000\022\000\022\000\
\022\000\022\000\022\000\022\000\022\000\022\000\009\000\009\000\
\009\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
\050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
\039\000\057\000\060\000\060\000\060\000\054\000\055\000\056\000\
\056\000\061\000\062\000\063\000\063\000\038\000\040\000\040\000\
\065\000\066\000\069\000\069\000\069\000\068\000\068\000\074\000\
\074\000\070\000\070\000\070\000\070\000\070\000\070\000\075\000\
\075\000\075\000\075\000\075\000\075\000\075\000\075\000\079\000\
\080\000\080\000\080\000\081\000\081\000\082\000\082\000\082\000\
\082\000\082\000\082\000\082\000\083\000\083\000\084\000\084\000\
\084\000\084\000\085\000\085\000\085\000\085\000\085\000\071\000\
\071\000\071\000\071\000\071\000\094\000\094\000\094\000\094\000\
\094\000\094\000\097\000\098\000\098\000\099\000\099\000\100\000\
\100\000\100\000\100\000\100\000\100\000\101\000\101\000\101\000\
\103\000\086\000\058\000\058\000\104\000\105\000\041\000\041\000\
\106\000\107\000\012\000\012\000\012\000\072\000\072\000\072\000\
\072\000\072\000\072\000\072\000\072\000\112\000\112\000\109\000\
\109\000\108\000\108\000\110\000\111\000\111\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
\026\000\026\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\114\000\114\000\114\000\114\000\114\000\114\000\
\114\000\114\000\076\000\076\000\132\000\132\000\133\000\133\000\
\133\000\133\000\134\000\093\000\093\000\135\000\135\000\135\000\
\135\000\135\000\031\000\031\000\140\000\141\000\137\000\137\000\
\092\000\092\000\092\000\117\000\117\000\143\000\143\000\118\000\
\118\000\118\000\119\000\119\000\128\000\128\000\144\000\144\000\
\144\000\145\000\145\000\131\000\131\000\129\000\129\000\089\000\
\089\000\089\000\089\000\089\000\019\000\019\000\019\000\019\000\
\019\000\019\000\019\000\019\000\019\000\019\000\019\000\019\000\
\019\000\019\000\019\000\113\000\113\000\139\000\139\000\139\000\
\139\000\139\000\139\000\139\000\139\000\139\000\139\000\139\000\
\139\000\139\000\139\000\139\000\139\000\139\000\139\000\139\000\
\139\000\139\000\139\000\146\000\146\000\146\000\150\000\150\000\
\149\000\149\000\149\000\149\000\151\000\151\000\051\000\152\000\
\152\000\032\000\033\000\033\000\153\000\154\000\158\000\158\000\
\157\000\157\000\157\000\157\000\157\000\157\000\157\000\157\000\
\157\000\157\000\156\000\156\000\156\000\161\000\162\000\162\000\
\164\000\164\000\165\000\165\000\165\000\166\000\163\000\163\000\
\163\000\167\000\073\000\073\000\159\000\159\000\159\000\168\000\
\169\000\035\000\035\000\053\000\171\000\171\000\171\000\171\000\
\160\000\160\000\160\000\175\000\176\000\034\000\052\000\178\000\
\178\000\178\000\178\000\178\000\178\000\179\000\179\000\179\000\
\180\000\181\000\182\000\183\000\049\000\049\000\184\000\184\000\
\184\000\184\000\185\000\185\000\138\000\138\000\090\000\090\000\
\177\000\177\000\018\000\018\000\186\000\186\000\188\000\188\000\
\188\000\188\000\188\000\190\000\190\000\174\000\174\000\191\000\
\191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
\191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
\191\000\191\000\027\000\027\000\198\000\197\000\197\000\194\000\
\194\000\195\000\195\000\193\000\193\000\199\000\199\000\200\000\
\200\000\196\000\196\000\189\000\189\000\095\000\095\000\077\000\
\077\000\201\000\201\000\173\000\173\000\192\000\192\000\192\000\
\202\000\087\000\127\000\127\000\127\000\127\000\127\000\127\000\
\127\000\147\000\147\000\147\000\147\000\147\000\147\000\147\000\
\147\000\147\000\147\000\147\000\064\000\064\000\136\000\136\000\
\136\000\136\000\136\000\203\000\203\000\203\000\203\000\203\000\
\203\000\203\000\203\000\203\000\203\000\203\000\203\000\203\000\
\203\000\203\000\203\000\203\000\203\000\203\000\203\000\203\000\
\203\000\203\000\170\000\170\000\170\000\170\000\170\000\126\000\
\126\000\120\000\120\000\120\000\120\000\120\000\125\000\125\000\
\148\000\148\000\025\000\025\000\187\000\187\000\187\000\048\000\
\048\000\096\000\096\000\078\000\078\000\011\000\011\000\011\000\
\011\000\011\000\011\000\011\000\121\000\142\000\142\000\155\000\
\155\000\122\000\122\000\091\000\091\000\088\000\088\000\067\000\
\067\000\102\000\102\000\102\000\102\000\102\000\059\000\059\000\
\116\000\116\000\130\000\130\000\123\000\123\000\124\000\124\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\205\000\205\000\028\000\207\000\044\000\013\000\
\013\000\172\000\172\000\115\000\115\000\115\000\029\000\043\000\
\206\000\206\000\206\000\206\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000"

let yylen = "\002\000\
\002\000\002\000\002\000\002\000\001\000\002\000\001\000\000\000\
\002\000\001\000\001\000\003\000\001\000\002\000\004\000\003\000\
\003\000\002\000\002\000\002\000\002\000\002\000\002\000\005\000\
\001\000\001\000\002\000\001\000\001\000\003\000\003\000\004\000\
\004\000\003\000\004\000\005\000\005\000\003\000\003\000\004\000\
\006\000\008\000\006\000\005\000\005\000\004\000\002\000\001\000\
\003\000\001\000\000\000\002\000\002\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\002\000\001\000\003\000\002\000\004\000\002\000\004\000\
\001\000\002\000\005\000\004\000\001\000\003\000\003\000\004\000\
\003\000\004\000\003\000\003\000\001\000\002\000\000\000\002\000\
\002\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\002\000\001\000\
\004\000\003\000\002\000\006\000\003\000\004\000\005\000\001\000\
\002\000\006\000\005\000\000\000\002\000\005\000\001\000\002\000\
\006\000\006\000\002\000\004\000\002\000\000\000\003\000\003\000\
\002\000\001\000\002\000\002\000\003\000\002\000\001\000\004\000\
\001\000\003\000\003\000\005\000\005\000\003\000\003\000\002\000\
\003\000\005\000\000\000\000\000\002\000\005\000\003\000\003\000\
\003\000\003\000\002\000\001\000\002\000\000\000\006\000\005\000\
\005\000\006\000\006\000\006\000\004\000\007\000\010\000\001\000\
\006\000\004\000\005\000\003\000\004\000\001\000\003\000\003\000\
\002\000\001\000\002\000\003\000\000\000\000\000\002\000\003\000\
\003\000\006\000\003\000\002\000\001\000\005\000\005\000\003\000\
\003\000\003\000\001\000\002\000\007\000\007\000\001\000\002\000\
\008\000\007\000\001\000\002\000\003\000\005\000\002\000\005\000\
\002\000\004\000\002\000\002\000\001\000\001\000\001\000\000\000\
\002\000\001\000\003\000\001\000\001\000\003\000\001\000\002\000\
\003\000\007\000\007\000\004\000\004\000\007\000\006\000\006\000\
\005\000\001\000\002\000\002\000\007\000\005\000\006\000\010\000\
\003\000\008\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\003\000\003\000\002\000\002\000\
\005\000\007\000\007\000\007\000\003\000\003\000\003\000\004\000\
\004\000\002\000\001\000\001\000\001\000\001\000\003\000\003\000\
\004\000\003\000\004\000\004\000\003\000\005\000\005\000\005\000\
\005\000\005\000\005\000\005\000\005\000\003\000\003\000\005\000\
\005\000\004\000\004\000\002\000\006\000\006\000\004\000\004\000\
\006\000\006\000\002\000\002\000\003\000\004\000\004\000\002\000\
\006\000\006\000\003\000\003\000\004\000\006\000\005\000\008\000\
\007\000\001\000\001\000\002\000\001\000\001\000\002\000\002\000\
\002\000\002\000\001\000\001\000\002\000\002\000\007\000\008\000\
\003\000\005\000\001\000\002\000\005\000\003\000\001\000\003\000\
\002\000\002\000\005\000\001\000\003\000\003\000\005\000\002\000\
\002\000\005\000\003\000\003\000\003\000\001\000\001\000\003\000\
\002\000\003\000\001\000\003\000\005\000\001\000\003\000\002\000\
\004\000\002\000\002\000\002\000\001\000\003\000\003\000\001\000\
\002\000\002\000\003\000\003\000\008\000\008\000\003\000\003\000\
\002\000\002\000\002\000\001\000\001\000\001\000\001\000\003\000\
\001\000\001\000\002\000\003\000\003\000\004\000\004\000\004\000\
\002\000\004\000\003\000\003\000\005\000\005\000\004\000\004\000\
\006\000\006\000\001\000\003\000\003\000\003\000\001\000\003\000\
\001\000\002\000\004\000\003\000\003\000\001\000\005\000\001\000\
\002\000\007\000\001\000\002\000\007\000\006\000\003\000\000\000\
\000\000\002\000\003\000\002\000\003\000\002\000\005\000\005\000\
\004\000\007\000\000\000\001\000\003\000\002\000\001\000\003\000\
\002\000\001\000\000\000\001\000\003\000\002\000\000\000\001\000\
\001\000\002\000\001\000\003\000\001\000\001\000\002\000\003\000\
\004\000\001\000\006\000\005\000\000\000\002\000\004\000\002\000\
\001\000\001\000\002\000\005\000\007\000\008\000\008\000\001\000\
\001\000\001\000\001\000\002\000\002\000\001\000\001\000\002\000\
\003\000\004\000\004\000\005\000\001\000\003\000\006\000\005\000\
\004\000\004\000\001\000\002\000\002\000\003\000\001\000\003\000\
\001\000\003\000\001\000\002\000\001\000\004\000\001\000\006\000\
\004\000\005\000\003\000\001\000\003\000\001\000\003\000\002\000\
\001\000\001\000\002\000\004\000\003\000\002\000\002\000\003\000\
\005\000\003\000\004\000\005\000\004\000\002\000\004\000\006\000\
\004\000\001\000\001\000\003\000\004\000\001\000\003\000\001\000\
\003\000\001\000\001\000\005\000\002\000\001\000\000\000\001\000\
\003\000\001\000\002\000\001\000\003\000\001\000\003\000\001\000\
\003\000\001\000\003\000\001\000\003\000\003\000\002\000\001\000\
\004\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\001\000\001\000\001\000\003\000\
\003\000\002\000\003\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\002\000\001\000\001\000\001\000\001\000\
\003\000\001\000\002\000\002\000\001\000\001\000\001\000\003\000\
\001\000\003\000\001\000\003\000\001\000\003\000\004\000\001\000\
\003\000\001\000\003\000\001\000\003\000\002\000\003\000\003\000\
\003\000\003\000\003\000\003\000\002\000\000\000\001\000\000\000\
\001\000\001\000\001\000\000\000\001\000\000\000\001\000\000\000\
\001\000\000\000\001\000\001\000\002\000\002\000\000\000\001\000\
\000\000\001\000\000\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\001\000\001\000\001\000\001\000\001\000\
\001\000\001\000\001\000\003\000\004\000\004\000\004\000\000\000\
\002\000\000\000\002\000\000\000\002\000\003\000\004\000\004\000\
\001\000\002\000\002\000\004\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\060\002\000\000\000\000\000\000\
\117\002\062\002\000\000\000\000\000\000\000\000\000\000\059\002\
\063\002\064\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\165\002\166\002\
\000\000\065\002\000\000\000\000\000\000\167\002\168\002\000\000\
\000\000\061\002\118\002\000\000\000\000\123\002\000\000\237\002\
\000\000\000\000\000\000\000\000\000\000\066\001\050\000\000\000\
\055\000\000\000\057\000\058\000\059\000\000\000\061\000\062\000\
\000\000\000\000\065\000\000\000\067\000\073\000\210\001\119\000\
\000\000\199\000\000\000\000\000\000\000\000\000\000\000\000\000\
\019\001\020\001\112\002\083\001\171\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\238\002\000\000\091\000\000\000\
\098\000\099\000\000\000\000\000\104\000\000\000\090\000\093\000\
\094\000\095\000\096\000\000\000\100\000\000\000\112\000\195\000\
\005\000\000\000\239\002\000\000\000\000\000\000\007\000\000\000\
\013\000\000\000\240\002\000\000\000\000\000\000\010\000\011\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\125\002\009\002\241\002\000\000\026\002\010\002\
\251\001\000\000\000\000\255\001\000\000\000\000\242\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\079\002\000\000\
\000\000\000\000\000\000\134\001\243\002\000\000\000\000\155\001\
\117\001\000\000\000\000\066\002\132\001\133\001\000\000\000\000\
\000\000\000\000\000\000\000\000\078\002\077\002\141\002\000\000\
\052\001\021\001\022\001\000\000\000\000\153\002\000\000\109\002\
\110\002\000\000\111\002\107\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\048\000\000\000\000\000\000\000\000\000\000\000\000\000\102\001\
\000\000\056\001\058\002\000\000\000\000\115\002\000\000\000\000\
\044\001\000\000\171\002\172\002\173\002\174\002\175\002\176\002\
\177\002\178\002\179\002\180\002\181\002\182\002\183\002\184\002\
\185\002\186\002\187\002\188\002\189\002\190\002\191\002\192\002\
\193\002\194\002\195\002\169\002\196\002\197\002\198\002\199\002\
\200\002\201\002\202\002\203\002\204\002\205\002\206\002\207\002\
\208\002\209\002\210\002\211\002\212\002\213\002\170\002\214\002\
\215\002\216\002\217\002\218\002\000\000\000\000\000\000\000\000\
\000\000\000\000\082\002\103\002\102\002\000\000\101\002\000\000\
\104\002\097\002\099\002\085\002\086\002\087\002\088\002\089\002\
\098\002\000\000\000\000\000\000\100\002\106\002\000\000\000\000\
\105\002\000\000\116\002\090\002\096\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\160\002\000\000\
\051\001\052\000\000\000\145\002\000\000\000\000\001\000\000\000\
\000\000\000\000\000\000\053\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\018\001\000\000\000\000\
\084\001\000\000\172\001\000\000\074\000\000\000\120\000\000\000\
\200\000\066\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\067\001\070\001\000\000\000\000\
\000\000\007\001\008\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\085\000\077\000\128\002\000\000\000\000\
\000\000\088\000\000\000\000\000\002\000\103\000\089\000\000\000\
\113\000\000\000\196\000\000\000\003\000\004\000\006\000\009\000\
\014\000\000\000\000\000\000\000\019\000\000\000\018\000\000\000\
\121\002\000\000\035\002\000\000\000\000\162\002\000\000\022\002\
\000\000\056\002\014\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\008\002\132\002\000\000\015\002\
\020\000\252\001\000\000\000\000\000\000\000\000\000\000\000\000\
\011\002\021\000\130\001\000\000\129\001\137\001\138\001\119\002\
\000\000\000\000\000\000\000\000\000\000\000\000\145\001\000\000\
\091\002\000\000\000\000\095\002\000\000\000\000\093\002\084\002\
\000\000\068\002\067\002\069\002\070\002\071\002\073\002\072\002\
\074\002\075\002\076\002\139\001\000\000\000\000\000\000\000\000\
\022\000\131\001\000\000\121\001\122\001\000\000\000\000\000\000\
\000\000\000\000\229\002\000\000\000\000\026\001\000\000\000\000\
\000\000\000\000\108\002\000\000\000\000\000\000\000\000\094\002\
\000\000\092\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\213\000\000\000\000\000\000\000\028\000\000\000\
\000\000\000\000\000\000\000\000\068\000\047\000\000\000\000\000\
\000\000\000\000\039\001\038\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\233\002\000\000\
\000\000\000\000\000\000\143\002\000\000\000\000\083\002\000\000\
\024\001\000\000\000\000\023\001\000\000\081\002\080\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\053\001\
\000\000\000\000\148\000\000\000\000\000\000\000\201\001\200\001\
\000\000\188\001\000\000\000\000\000\000\049\000\225\002\000\000\
\000\000\000\000\000\000\000\000\124\002\113\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\205\000\000\000\000\000\000\000\000\000\
\000\000\225\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\075\001\073\001\059\001\
\000\000\072\001\068\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\106\000\086\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\139\002\136\002\
\135\002\140\002\000\000\137\002\017\000\000\000\016\000\012\000\
\034\002\000\000\032\002\000\000\037\002\018\002\000\000\000\000\
\000\000\000\000\013\002\000\000\055\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\122\002\126\002\000\000\
\000\000\000\000\050\002\000\000\016\002\000\000\000\000\141\001\
\140\001\000\000\000\000\000\000\000\000\000\000\000\000\148\001\
\000\000\147\001\119\001\118\001\128\001\000\000\124\001\000\000\
\158\001\000\000\000\000\136\001\000\000\230\002\227\002\000\000\
\000\000\000\000\029\001\027\001\025\001\000\000\000\000\000\000\
\203\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\214\001\052\002\000\000\000\000\000\000\212\000\
\000\000\214\000\000\000\215\000\209\000\220\000\000\000\207\000\
\000\000\211\000\000\000\000\000\000\000\229\000\000\000\000\000\
\092\001\000\000\023\000\025\000\026\000\000\000\000\000\027\000\
\000\000\039\000\000\000\038\000\031\000\030\000\034\000\000\000\
\000\000\101\001\000\000\104\001\000\000\000\000\055\001\054\001\
\000\000\048\001\047\001\043\001\042\001\220\002\000\000\000\000\
\231\002\232\002\000\000\000\000\000\000\000\000\000\000\061\001\
\115\001\000\000\116\001\000\000\028\001\223\002\000\000\000\000\
\000\000\000\000\000\000\000\000\071\000\072\000\000\000\017\001\
\016\001\000\000\105\000\000\000\191\001\000\000\000\000\000\000\
\000\000\194\001\190\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\086\001\000\000\000\000\000\000\
\000\000\000\000\087\001\078\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\084\000\083\000\000\000\079\000\078\000\000\000\000\000\000\000\
\237\001\000\000\129\002\000\000\000\000\000\000\000\000\000\000\
\110\000\000\000\000\000\000\000\000\000\000\000\015\000\000\000\
\019\002\038\002\000\000\000\000\000\000\023\002\021\002\000\000\
\000\000\000\000\249\001\054\002\000\000\025\002\000\000\000\000\
\000\000\012\002\000\000\000\000\133\002\000\000\127\002\254\001\
\000\000\120\002\000\000\000\000\164\001\000\000\143\001\142\001\
\146\001\144\001\000\000\000\000\152\001\151\001\000\000\221\002\
\000\000\000\000\000\000\000\000\000\000\127\000\000\000\198\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\212\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\096\001\097\001\000\000\000\000\000\000\000\000\
\000\000\000\000\046\000\000\000\000\000\040\000\000\000\035\000\
\033\000\000\000\000\000\000\000\000\000\085\001\000\000\063\001\
\000\000\000\000\000\000\075\000\000\000\118\000\000\000\000\000\
\145\000\000\000\000\000\000\000\000\000\000\000\000\000\156\000\
\149\000\233\000\000\000\000\000\189\001\000\000\176\001\000\000\
\193\001\000\000\222\002\041\001\040\001\000\000\000\000\000\000\
\000\000\031\001\030\001\081\001\000\000\000\000\089\001\000\000\
\090\001\000\000\000\000\176\001\076\000\000\000\000\000\000\000\
\037\001\035\001\000\000\033\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\196\001\000\000\000\000\
\111\000\109\000\000\000\000\000\167\001\000\000\000\000\033\002\
\040\002\000\000\020\002\042\002\000\000\000\000\000\000\000\000\
\057\002\000\000\000\000\028\002\000\000\017\002\000\000\051\002\
\164\002\163\001\000\000\000\000\150\001\149\001\036\001\034\001\
\032\001\000\000\204\001\202\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\174\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\135\000\000\000\
\000\000\000\000\137\000\121\000\125\000\000\000\215\001\053\002\
\211\001\000\000\000\000\147\002\146\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\210\000\000\000\094\001\000\000\
\093\001\000\000\000\000\044\000\000\000\045\000\000\000\037\000\
\036\000\000\000\236\002\000\000\000\000\000\000\062\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\155\000\000\000\192\001\000\000\
\182\001\000\000\000\000\000\000\000\000\000\000\000\000\205\001\
\206\001\000\000\000\000\149\002\000\000\239\000\058\001\057\001\
\050\001\049\001\046\001\045\001\000\000\000\000\000\000\000\000\
\000\000\088\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\238\001\114\000\000\000\000\000\115\000\000\000\000\000\036\002\
\024\002\043\002\250\001\246\001\000\000\000\000\000\000\000\000\
\154\001\153\001\000\000\130\002\178\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\182\000\000\000\000\000\
\000\000\177\000\000\000\000\000\000\000\000\000\131\000\000\000\
\000\000\000\000\000\000\134\000\000\000\169\001\170\001\000\000\
\230\000\000\000\217\000\208\000\206\000\000\000\000\000\000\000\
\000\000\024\000\000\000\041\000\043\000\226\000\227\000\000\000\
\146\000\000\000\153\000\000\000\154\000\000\000\000\000\000\000\
\152\000\151\002\000\000\000\000\000\000\151\000\000\000\000\000\
\000\000\000\000\000\000\207\001\000\000\000\000\173\001\000\000\
\000\000\000\000\224\001\225\001\226\001\227\001\065\001\000\000\
\077\001\000\000\000\000\000\000\082\001\174\001\122\000\000\000\
\000\000\000\000\000\000\197\000\000\000\000\000\197\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\230\001\231\001\
\000\000\041\002\000\000\031\002\000\000\201\000\000\000\000\000\
\000\000\000\000\000\000\176\000\175\000\000\000\000\000\000\000\
\000\000\172\000\047\002\000\000\000\000\129\000\000\000\143\000\
\000\000\142\000\139\000\138\000\000\000\000\000\098\001\095\001\
\000\000\242\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\185\001\000\000\000\000\000\000\
\217\001\000\000\208\001\000\000\175\001\000\000\000\000\000\000\
\222\001\228\001\229\001\064\001\000\000\000\000\091\001\202\000\
\240\001\244\001\176\001\108\000\000\000\223\001\232\001\198\000\
\000\000\126\001\125\001\131\002\173\000\000\000\180\000\000\000\
\000\000\000\000\000\000\000\000\189\000\183\000\170\000\000\000\
\000\000\136\000\000\000\000\000\042\000\157\000\150\000\000\000\
\000\000\000\000\165\000\000\000\000\000\000\000\000\000\209\001\
\000\000\000\000\000\000\183\001\219\001\000\000\000\000\000\000\
\000\000\233\001\000\000\079\001\000\000\171\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\188\000\
\000\000\141\000\140\000\240\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\161\000\000\000\000\000\000\000\
\000\000\000\000\234\001\235\001\080\001\187\000\184\000\157\002\
\158\002\000\000\000\000\000\000\000\000\185\000\169\000\163\000\
\164\000\000\000\000\000\000\000\000\000\162\000\186\001\000\000\
\236\001\000\000\000\000\000\000\000\000\000\000\166\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\186\000\000\000\
\000\000\000\000\221\001\167\000"

let yydgoto = "\008\000\
\056\000\101\000\123\000\131\000\149\000\159\000\173\000\055\002\
\102\000\124\000\132\000\058\000\081\001\127\000\059\000\135\000\
\136\000\193\001\233\001\078\002\022\003\147\001\032\002\215\000\
\060\000\061\000\191\002\110\001\062\000\063\000\161\000\065\000\
\066\000\067\000\068\000\069\000\070\000\071\000\072\000\073\000\
\074\000\075\000\076\000\077\000\079\002\078\000\117\001\149\001\
\120\003\110\000\111\000\112\000\079\000\114\000\115\000\116\000\
\117\000\118\000\072\001\162\002\119\000\161\001\066\003\150\001\
\080\000\119\001\199\000\010\002\187\003\089\004\076\004\013\003\
\239\002\223\004\090\004\131\001\194\001\091\004\082\002\083\002\
\074\003\241\003\085\005\140\004\137\004\133\004\081\000\095\005\
\098\003\185\005\150\004\099\003\167\004\077\004\078\004\079\004\
\213\004\214\004\062\005\134\005\175\005\171\005\101\005\120\000\
\163\001\082\000\121\001\199\003\106\004\200\003\198\003\005\003\
\177\000\083\000\034\001\183\001\016\003\014\003\084\000\085\000\
\086\000\102\004\087\000\088\000\222\000\089\000\090\000\223\000\
\232\000\048\002\229\000\133\001\134\001\143\002\127\002\091\000\
\100\003\186\005\182\000\092\000\113\001\061\002\017\003\224\000\
\225\000\183\000\184\000\152\000\219\001\222\001\220\001\099\004\
\093\000\115\001\077\001\089\002\247\003\155\004\151\004\096\005\
\090\002\078\003\091\002\083\003\029\004\241\002\184\003\152\004\
\153\004\154\004\015\002\003\002\244\002\080\004\097\005\098\005\
\146\003\018\005\046\005\019\005\020\005\021\005\022\005\121\003\
\042\005\153\000\154\000\155\000\156\000\157\000\158\000\189\001\
\177\002\178\002\179\002\045\004\052\004\053\004\139\003\042\004\
\247\002\190\001\063\001\029\001\030\001\056\002\082\001"

let yysindex = "\020\008\
\217\062\157\006\112\044\005\044\107\015\144\064\150\068\000\000\
\132\004\108\002\087\070\132\004\000\000\202\001\101\000\017\001\
\000\000\000\000\132\004\132\004\132\004\132\004\025\003\000\000\
\000\000\000\000\132\004\150\070\082\255\049\063\139\063\219\058\
\219\058\029\005\000\000\184\055\219\058\132\004\000\000\000\000\
\232\004\000\000\132\004\132\004\142\255\000\000\000\000\087\070\
\217\062\000\000\000\000\132\004\185\255\000\000\132\004\000\000\
\040\001\047\000\155\011\024\000\217\071\000\000\000\000\246\002\
\000\000\056\000\000\000\000\000\000\000\222\001\000\000\000\000\
\034\002\055\002\000\000\047\000\000\000\000\000\000\000\000\000\
\048\002\000\000\217\069\155\000\087\070\087\070\144\064\144\064\
\000\000\000\000\000\000\000\000\000\000\202\001\101\000\024\004\
\066\005\157\006\185\255\017\001\000\000\136\003\000\000\056\000\
\000\000\000\000\055\002\047\000\000\000\157\006\000\000\000\000\
\000\000\000\000\000\000\135\002\000\000\158\002\000\000\000\000\
\000\000\108\002\000\000\060\002\096\002\047\000\000\000\227\002\
\000\000\228\044\000\000\082\004\047\000\082\004\000\000\000\000\
\011\009\213\002\172\255\135\004\010\003\133\073\107\015\140\003\
\108\002\243\002\000\000\000\000\000\000\076\000\000\000\000\000\
\000\000\212\001\019\000\000\000\144\003\182\002\000\000\043\005\
\246\002\150\068\150\069\024\003\135\067\205\067\000\000\144\059\
\102\003\183\003\028\003\000\000\000\000\074\000\036\004\000\000\
\000\000\150\068\150\068\000\000\000\000\000\000\085\004\152\004\
\219\058\219\058\083\004\087\070\000\000\000\000\000\000\040\056\
\000\000\000\000\000\000\226\063\207\003\000\000\126\004\000\000\
\000\000\088\004\000\000\000\000\079\002\152\071\189\004\150\068\
\199\066\213\002\144\064\149\004\111\002\217\062\091\005\036\004\
\000\000\087\070\000\000\217\004\014\001\229\004\145\255\000\000\
\147\004\000\000\000\000\234\004\161\004\000\000\149\072\190\004\
\000\000\190\004\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\016\005\128\062\128\062\132\004\
\142\255\213\004\000\000\000\000\000\000\087\070\000\000\225\004\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\179\000\000\000\000\000\000\000\000\000\
\000\000\087\070\000\000\000\000\000\000\041\000\118\255\128\062\
\144\064\204\004\108\002\193\002\243\002\008\005\000\000\226\004\
\000\000\000\000\144\064\000\000\185\004\144\064\000\000\219\058\
\155\011\047\000\132\004\000\000\087\005\009\006\144\064\144\064\
\144\064\144\064\144\064\144\064\144\064\144\064\144\064\144\064\
\144\064\144\064\144\064\144\064\144\064\144\064\144\064\144\064\
\144\064\144\064\144\064\144\064\144\064\000\000\150\068\144\064\
\000\000\185\004\000\000\250\004\000\000\207\003\000\000\207\003\
\000\000\000\000\144\064\031\004\087\070\087\070\054\005\059\005\
\087\070\054\005\024\070\098\001\000\000\000\000\144\064\098\001\
\098\001\000\000\000\000\126\004\152\001\149\004\024\004\002\005\
\157\006\000\000\059\002\000\000\000\000\000\000\173\002\027\005\
\074\003\000\000\185\004\128\005\000\000\000\000\000\000\051\005\
\000\000\207\003\000\000\066\006\000\000\000\000\000\000\000\000\
\000\000\082\004\047\000\082\004\000\000\082\004\000\000\073\012\
\000\000\025\004\000\000\077\005\165\005\000\000\073\012\000\000\
\073\012\000\000\000\000\171\005\151\005\093\005\107\015\059\003\
\083\004\029\001\123\005\186\005\000\000\000\000\182\005\000\000\
\000\000\000\000\061\003\096\005\120\005\107\015\095\007\243\002\
\000\000\000\000\000\000\084\061\000\000\000\000\000\000\000\000\
\191\005\187\005\064\000\122\005\249\003\125\005\000\000\125\005\
\000\000\134\005\102\003\000\000\135\255\183\003\000\000\000\000\
\129\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\044\002\148\061\212\061\020\062\
\000\000\000\000\139\005\000\000\000\000\150\068\192\002\128\062\
\083\004\083\004\000\000\098\001\208\004\000\000\245\002\126\004\
\042\004\173\005\000\000\003\039\116\001\003\039\083\004\000\000\
\236\005\000\000\107\015\043\003\150\069\001\060\100\002\068\005\
\100\005\071\066\000\000\150\068\149\005\014\005\000\000\011\001\
\144\064\139\001\167\003\214\003\000\000\000\000\098\001\124\006\
\024\003\144\064\000\000\000\000\024\003\144\064\059\005\199\003\
\144\064\187\255\122\255\219\058\107\015\150\068\000\000\164\005\
\166\005\148\005\132\004\000\000\150\068\195\005\000\000\118\001\
\000\000\152\011\214\012\000\000\170\005\000\000\000\000\168\005\
\150\005\193\002\241\005\024\004\025\003\193\002\047\000\000\000\
\150\068\053\004\000\000\108\003\156\005\042\004\000\000\000\000\
\098\003\000\000\239\000\254\005\128\062\000\000\000\000\150\070\
\059\005\144\064\144\064\152\056\000\000\000\000\134\073\134\073\
\081\073\026\007\149\072\081\073\143\012\143\012\143\012\143\012\
\165\002\229\005\229\005\143\012\165\002\165\002\081\073\229\005\
\165\002\165\002\165\002\000\000\229\005\015\005\047\000\062\065\
\006\006\000\000\213\005\193\002\126\004\126\004\149\072\144\064\
\144\064\144\064\217\005\098\001\098\001\000\000\000\000\000\000\
\001\006\000\000\000\000\081\073\221\005\019\005\143\255\201\005\
\072\004\254\003\000\000\000\000\109\003\020\006\024\004\226\004\
\216\002\047\000\098\003\107\015\024\006\126\004\000\000\000\000\
\000\000\000\000\017\006\000\000\000\000\082\004\000\000\000\000\
\000\000\218\000\000\000\041\006\000\000\000\000\073\012\191\000\
\025\001\029\016\000\000\236\001\000\000\226\005\218\005\196\005\
\107\015\047\003\107\015\107\015\117\003\000\000\000\000\187\001\
\108\002\242\005\000\000\215\005\000\000\129\003\150\068\000\000\
\000\000\032\003\150\068\032\000\063\003\004\006\034\001\000\000\
\156\013\000\000\000\000\000\000\000\000\170\002\000\000\052\006\
\000\000\096\255\096\255\000\000\233\005\000\000\000\000\144\064\
\144\064\144\064\000\000\000\000\000\000\007\006\187\000\240\005\
\000\000\196\065\133\073\003\006\000\000\182\002\232\005\244\005\
\239\005\083\004\000\000\000\000\047\000\194\001\144\064\000\000\
\015\006\000\000\150\068\000\000\000\000\000\000\023\006\000\000\
\023\006\000\000\114\060\144\064\071\066\000\000\029\000\081\006\
\000\000\144\064\000\000\000\000\000\000\076\006\025\003\000\000\
\105\071\000\000\024\004\000\000\000\000\000\000\000\000\253\000\
\000\000\000\000\149\072\000\000\149\072\065\006\000\000\000\000\
\149\072\000\000\000\000\000\000\000\000\000\000\083\004\121\255\
\000\000\000\000\193\002\226\004\047\000\144\064\148\255\000\000\
\000\000\016\002\000\000\083\004\000\000\000\000\213\002\047\000\
\024\004\047\000\043\001\112\005\000\000\000\000\053\002\000\000\
\000\000\043\002\000\000\131\005\000\000\056\001\067\006\005\006\
\108\002\000\000\000\000\144\064\011\006\083\000\161\004\190\004\
\190\004\179\000\166\255\144\064\000\000\036\011\144\064\227\060\
\129\065\068\006\000\000\000\000\107\015\067\006\047\000\033\006\
\036\006\249\071\003\005\069\000\174\255\144\064\089\006\024\004\
\000\000\000\000\025\003\000\000\000\000\252\005\194\004\105\006\
\000\000\000\000\000\000\024\004\036\002\108\003\118\002\099\006\
\000\000\026\006\115\005\024\004\056\006\226\255\000\000\073\012\
\000\000\000\000\107\015\064\001\116\006\000\000\000\000\108\002\
\043\000\083\004\000\000\000\000\107\015\000\000\014\006\083\004\
\243\002\000\000\242\005\053\006\000\000\019\006\000\000\000\000\
\095\007\000\000\249\003\038\006\000\000\249\003\000\000\000\000\
\000\000\000\000\150\068\059\003\000\000\000\000\205\255\000\000\
\055\072\182\000\217\255\106\006\042\004\000\000\108\002\000\000\
\097\010\156\004\047\000\196\065\094\001\141\046\003\039\047\000\
\000\000\037\006\007\000\040\006\203\003\114\006\114\006\128\006\
\047\006\079\006\000\000\000\000\144\064\144\064\150\068\087\072\
\024\004\112\005\000\000\156\255\157\255\000\000\160\255\000\000\
\000\000\144\064\144\064\108\006\024\005\000\000\181\072\000\000\
\049\006\107\015\150\068\000\000\036\002\000\000\025\003\107\015\
\000\000\107\015\142\255\144\064\142\255\117\255\047\000\000\000\
\000\000\000\000\150\068\042\004\000\000\227\070\000\000\060\006\
\000\000\130\006\000\000\000\000\000\000\051\004\235\000\062\005\
\085\002\000\000\000\000\000\000\090\006\084\001\000\000\100\006\
\000\000\144\064\163\002\000\000\000\000\196\065\129\006\103\006\
\000\000\000\000\104\006\000\000\109\006\149\072\097\010\036\002\
\112\005\152\006\144\000\042\004\150\003\000\000\254\003\059\002\
\000\000\000\000\024\004\060\006\000\000\059\002\159\006\000\000\
\000\000\046\002\000\000\000\000\065\001\000\000\107\015\108\002\
\000\000\242\005\024\003\000\000\172\006\000\000\107\015\000\000\
\000\000\000\000\037\004\090\000\000\000\000\000\000\000\000\000\
\000\000\012\003\000\000\000\000\114\014\168\006\133\073\118\006\
\141\046\122\006\000\000\161\006\083\004\120\006\000\000\093\006\
\042\003\182\002\007\067\107\015\156\004\008\005\000\000\080\004\
\083\004\024\070\000\000\000\000\000\000\047\003\000\000\000\000\
\000\000\037\006\047\000\000\000\000\000\144\064\071\066\107\015\
\144\064\096\006\101\006\107\015\000\000\107\006\000\000\125\006\
\000\000\144\064\037\255\000\000\079\255\000\000\110\006\000\000\
\000\000\149\072\000\000\144\064\144\064\144\064\000\000\083\004\
\081\006\112\005\059\255\255\002\047\000\156\004\047\000\000\003\
\047\000\133\006\135\006\047\000\000\000\081\006\000\000\101\000\
\000\000\219\048\034\071\000\000\111\003\142\006\192\006\000\000\
\000\000\152\001\001\002\000\000\037\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\169\255\090\006\179\006\107\015\
\119\006\000\000\144\064\001\002\047\000\012\003\144\064\144\064\
\144\064\047\000\096\005\096\005\149\001\000\000\189\006\187\006\
\000\000\000\000\222\002\121\001\000\000\097\010\107\015\000\000\
\000\000\000\000\000\000\000\000\193\006\014\006\242\005\020\062\
\000\000\000\000\107\015\000\000\000\000\115\005\153\003\087\001\
\144\003\141\046\159\001\107\015\137\004\000\000\145\006\207\006\
\156\004\000\000\097\010\003\039\179\003\135\066\000\000\097\001\
\223\255\144\004\156\004\000\000\024\070\000\000\000\000\202\006\
\000\000\083\004\000\000\000\000\000\000\083\004\071\066\144\064\
\149\072\000\000\059\003\000\000\000\000\000\000\000\000\019\073\
\000\000\107\015\000\000\195\001\000\000\113\006\060\006\059\005\
\000\000\000\000\059\005\123\006\059\005\000\000\152\001\083\004\
\192\006\192\001\133\006\000\000\083\004\107\015\000\000\101\000\
\094\002\032\002\000\000\000\000\000\000\000\000\000\000\132\006\
\000\000\107\015\146\003\129\065\000\000\000\000\000\000\115\005\
\149\072\149\072\149\072\000\000\240\003\240\003\000\000\107\015\
\134\006\107\015\118\002\101\000\152\001\071\002\000\000\000\000\
\047\000\000\000\107\015\000\000\031\001\000\000\206\003\208\003\
\156\006\047\003\087\000\000\000\000\000\109\001\097\010\141\046\
\083\004\000\000\000\000\000\000\156\004\000\000\243\002\000\000\
\097\010\000\000\000\000\000\000\083\004\144\064\000\000\000\000\
\138\006\000\000\083\004\171\006\047\000\059\005\059\005\007\066\
\226\006\059\005\012\005\083\004\000\000\207\000\059\005\148\006\
\000\000\133\006\000\000\221\003\000\000\127\002\116\001\083\004\
\000\000\000\000\000\000\000\000\229\003\144\064\000\000\000\000\
\000\000\000\000\000\000\000\000\152\001\000\000\000\000\000\000\
\083\004\000\000\000\000\000\000\000\000\097\010\000\000\107\015\
\012\003\058\004\186\002\047\000\000\000\000\000\000\000\178\006\
\083\004\000\000\108\000\236\006\000\000\000\000\000\000\244\006\
\245\006\189\070\000\000\107\015\248\006\144\064\239\006\000\000\
\133\006\192\006\249\006\000\000\000\000\107\015\116\001\083\004\
\083\004\000\000\144\064\000\000\250\006\000\000\047\000\115\005\
\170\006\181\006\059\005\207\003\133\006\015\007\047\000\000\000\
\097\010\000\000\000\000\000\000\029\016\029\016\090\006\083\004\
\006\007\172\001\083\004\107\015\000\000\144\064\197\006\029\016\
\083\004\083\004\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\021\007\059\005\059\005\107\015\000\000\000\000\000\000\
\000\000\017\007\144\064\107\015\083\004\000\000\000\000\083\004\
\000\000\029\016\028\007\030\007\083\004\107\015\000\000\083\004\
\205\006\047\000\107\015\107\015\004\004\083\004\000\000\083\004\
\083\004\144\064\000\000\000\000"

let yyrindex = "\000\000\
\047\008\048\008\208\006\000\000\000\000\000\000\000\000\000\000\
\213\070\000\000\000\000\057\064\000\000\115\003\000\000\000\000\
\000\000\000\000\214\068\071\067\016\068\231\064\000\000\000\000\
\000\000\000\000\213\070\000\000\000\000\000\000\000\000\000\000\
\000\000\080\068\234\016\000\000\000\000\231\064\000\000\000\000\
\000\000\000\000\247\003\237\001\194\006\000\000\000\000\000\000\
\071\000\000\000\000\000\231\064\212\003\000\000\231\064\000\000\
\000\000\226\009\071\000\102\017\154\038\000\000\000\000\064\054\
\000\000\103\054\000\000\000\000\000\000\147\054\000\000\000\000\
\192\054\214\054\000\000\223\054\000\000\000\000\000\000\000\000\
\000\000\000\000\251\022\115\023\014\022\132\022\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\115\003\000\000\000\000\
\000\000\110\000\212\003\000\000\000\000\000\000\000\000\121\014\
\000\000\000\000\063\049\181\049\000\000\110\000\000\000\000\000\
\000\000\000\000\000\000\240\050\000\000\089\051\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\209\006\000\000\208\006\
\000\000\000\000\000\000\000\000\127\004\000\000\000\000\000\000\
\000\000\060\013\060\013\000\000\010\039\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\037\015\000\000\237\039\082\040\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\086\045\000\000\
\000\000\164\002\032\006\000\000\000\000\000\000\149\006\200\045\
\000\000\000\000\003\057\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\115\003\000\000\252\006\000\000\
\000\000\000\000\000\000\000\000\248\052\000\000\000\000\000\000\
\000\000\022\069\000\000\000\000\000\000\197\004\223\054\243\005\
\000\000\000\000\096\001\155\004\000\000\201\255\000\000\000\000\
\091\000\000\000\000\000\000\000\130\004\000\000\094\000\254\000\
\000\000\092\005\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\067\055\215\006\215\006\199\006\
\034\004\086\069\000\000\000\000\000\000\151\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\117\057\205\057\000\000\000\000\000\000\037\058\125\058\
\000\000\153\000\000\000\000\000\000\000\000\000\000\000\215\006\
\000\000\000\000\000\000\000\000\000\000\091\006\000\000\000\000\
\000\000\000\000\000\000\000\000\248\002\000\000\000\000\000\000\
\071\000\247\047\080\068\000\000\064\054\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\202\031\000\000\000\000\000\000\000\000\
\000\000\050\003\000\000\000\000\000\000\115\003\000\000\115\003\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\224\017\169\020\000\000\000\000\000\000\233\023\
\095\024\000\000\000\000\252\006\138\010\000\000\000\000\000\000\
\214\004\202\007\181\049\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\248\002\000\000\000\000\000\000\000\000\000\000\
\000\000\115\003\000\000\111\007\000\000\000\000\000\000\000\000\
\000\000\000\000\127\004\000\000\000\000\000\000\000\000\000\000\
\000\000\071\001\000\000\048\007\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\027\007\000\000\000\000\
\144\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\202\255\000\000\150\000\168\000\254\000\000\000\092\005\
\000\000\000\000\201\000\000\000\000\000\202\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\215\006\
\003\057\149\043\000\000\215\024\000\000\000\000\000\000\252\006\
\228\006\000\000\000\000\000\000\000\000\000\000\172\011\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\077\025\000\000\
\000\000\000\000\000\000\000\000\015\001\000\000\169\004\000\000\
\161\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\199\006\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\019\039\000\000\000\000\000\000\223\054\000\000\
\000\000\000\000\000\000\122\052\000\000\047\004\000\000\000\000\
\000\000\000\000\000\000\000\000\215\006\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\133\034\244\034\
\080\009\127\005\207\015\094\035\064\032\183\032\046\033\164\033\
\002\029\195\025\058\026\027\034\120\029\239\029\200\035\176\026\
\102\030\220\030\083\031\000\000\039\027\000\000\070\053\175\004\
\105\005\000\000\000\000\000\000\252\006\252\006\090\016\000\000\
\000\000\000\000\087\018\033\021\152\021\000\000\000\000\000\000\
\206\018\000\000\000\000\050\036\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\181\049\000\000\000\000\000\000\252\006\000\000\000\000\
\000\000\000\000\017\012\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\003\054\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\029\007\000\000\000\000\000\000\153\255\
\000\000\183\040\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\131\041\000\000\030\041\000\000\000\000\000\000\000\000\
\000\000\028\001\161\255\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\019\004\000\000\009\010\
\000\000\198\003\043\008\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\046\048\122\048\000\000\000\000\
\000\000\203\053\000\000\000\000\122\052\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\158\027\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\111\001\000\000\219\255\000\000\169\000\000\000\000\000\000\000\
\170\000\000\000\000\000\000\000\000\000\000\000\224\006\229\006\
\000\000\000\000\000\000\000\000\070\053\000\000\000\000\000\000\
\000\000\053\001\000\000\185\001\000\000\000\000\022\069\014\054\
\000\000\122\052\000\000\144\052\000\000\000\000\000\000\000\000\
\000\000\219\004\000\000\022\069\000\000\000\000\205\049\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\130\004\254\000\
\092\005\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\118\050\014\054\000\000\
\000\000\000\000\243\072\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\161\002\128\003\
\000\000\243\010\000\000\000\000\068\013\181\049\000\000\000\000\
\000\000\000\000\181\049\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\027\002\000\000\000\000\000\000\000\000\000\000\153\001\
\000\000\000\000\232\041\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\005\000\044\001\000\000\246\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\228\006\000\000\000\000\000\000\
\000\000\000\000\014\054\000\000\000\000\000\000\000\000\223\054\
\000\000\000\000\000\000\000\000\199\001\234\006\234\006\215\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\125\039\
\000\000\247\006\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\224\051\000\000\000\000\000\000\
\000\000\000\000\245\004\000\000\044\255\231\004\058\008\000\000\
\000\000\000\000\000\000\047\004\000\000\024\007\000\000\008\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\068\019\
\000\000\000\000\188\019\000\000\051\020\151\036\000\000\255\049\
\033\043\114\004\000\000\228\006\000\000\000\000\000\000\233\013\
\000\000\000\000\000\000\008\002\000\000\233\013\000\000\000\000\
\000\000\071\001\000\000\000\000\000\000\065\059\000\000\000\000\
\000\000\079\042\000\000\000\000\172\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\069\047\000\000\216\005\
\000\000\000\000\128\047\000\000\192\008\000\000\000\000\001\007\
\000\000\139\048\000\000\000\000\000\000\091\006\000\000\000\000\
\092\053\020\046\000\000\000\000\000\000\231\048\000\000\000\000\
\000\000\018\052\122\052\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\181\000\000\000\000\000\000\000\000\000\000\000\219\001\
\020\028\189\052\000\000\000\000\058\008\000\000\058\008\014\007\
\058\008\018\007\018\007\058\008\000\000\139\028\000\000\000\000\
\000\000\000\000\032\007\157\046\177\050\000\000\236\050\000\000\
\000\000\131\049\077\052\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\058\007\000\000\000\000\
\000\000\000\000\000\000\077\052\014\054\000\000\000\000\000\000\
\000\000\233\013\000\000\000\000\000\000\052\005\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\180\042\000\000\
\000\000\000\000\000\000\000\000\000\000\077\052\000\000\000\000\
\013\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\079\046\000\000\000\000\000\000\
\000\000\242\001\000\000\000\000\000\000\009\002\000\000\000\000\
\252\036\000\000\000\000\000\000\000\000\000\000\000\000\086\001\
\000\000\000\000\000\000\054\002\000\000\019\007\014\007\000\000\
\000\000\000\000\000\000\037\007\000\000\000\000\131\049\039\051\
\106\051\243\001\018\007\000\000\058\050\000\000\000\000\000\000\
\239\052\223\054\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\077\052\
\102\037\203\037\048\038\000\000\080\012\221\012\000\000\000\000\
\038\065\000\000\000\000\000\000\068\007\181\049\000\000\000\000\
\233\013\000\000\000\000\000\000\250\003\000\000\000\000\000\000\
\000\000\053\049\000\000\000\000\000\000\227\004\000\000\000\000\
\114\053\000\000\000\000\187\047\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\216\046\000\000\000\000\000\000\
\000\000\000\000\009\005\000\000\058\008\000\000\000\000\000\000\
\000\000\000\000\000\000\058\050\000\000\000\000\000\000\000\000\
\000\000\069\002\000\000\000\000\000\000\239\052\000\000\215\051\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\068\007\000\000\000\000\000\000\
\190\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\038\007\000\000\227\009\000\000\000\000\000\000\000\000\
\019\047\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\018\007\165\051\000\000\000\000\000\000\000\000\000\000\215\051\
\193\053\000\000\000\000\000\000\044\014\000\000\227\009\227\009\
\045\007\050\007\000\000\056\007\018\007\000\000\227\009\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\048\003\
\000\000\000\000\047\005\000\000\000\000\000\000\000\000\000\000\
\239\042\193\053\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\180\005\000\000\000\000\155\002\
\000\000\000\000\000\000\000\000\184\005\000\000\000\000\105\004\
\255\006\227\009\000\000\000\000\000\000\159\004\000\000\225\006\
\211\008\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\092\000\
\243\255\000\000\086\000\253\255\232\006\255\007\062\000\000\000\
\204\255\135\000\063\000\091\255\000\000\148\254\000\007\071\255\
\210\007\163\014\243\252\017\000\022\004\014\000\049\000\052\000\
\066\000\000\000\000\000\000\000\000\000\075\000\088\000\000\000\
\097\000\000\000\002\000\004\000\094\254\000\000\000\000\083\254\
\000\000\000\000\000\000\000\000\099\000\000\000\000\000\000\000\
\000\000\000\000\238\254\160\252\000\000\000\000\000\000\006\000\
\000\000\000\000\164\255\207\254\136\254\018\252\114\252\072\255\
\103\004\168\003\000\000\048\004\056\253\115\255\055\004\000\000\
\000\000\000\000\000\000\000\000\000\000\016\003\247\255\204\251\
\201\254\036\254\129\252\057\003\139\251\029\252\010\252\090\003\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\140\005\205\004\168\004\000\000\000\000\
\103\255\030\000\231\000\140\255\005\002\009\253\093\255\190\008\
\049\011\000\000\000\000\000\000\106\255\251\006\142\012\062\006\
\001\000\086\255\073\006\134\254\000\000\034\007\112\006\214\011\
\189\252\088\253\212\254\000\000\000\000\000\000\220\004\076\004\
\000\000\000\000\166\006\119\255\220\005\010\008\000\000\079\004\
\000\000\000\000\080\008\073\002\080\005\045\252\184\251\244\252\
\210\253\000\000\015\254\000\000\000\000\234\255\000\000\000\000\
\235\251\249\255\240\251\105\254\254\253\034\254\000\000\000\000\
\247\002\000\000\000\000\252\003\160\251\000\000\170\003\154\004\
\000\000\115\253\003\012\126\255\000\000\009\000\067\254\010\006\
\136\255\215\254\130\255\000\000\253\003\000\000\000\000\000\000\
\238\006\000\000\000\000\000\000\026\000\053\255\000\000"

let yytablesize = 19189
let yytable = "\126\000\
\133\000\140\001\160\000\108\000\200\001\109\000\069\002\205\000\
\147\002\213\001\181\001\251\002\195\001\218\001\059\002\191\000\
\180\001\145\003\192\002\228\000\209\001\204\003\185\001\240\002\
\026\002\187\000\181\002\034\002\187\000\009\004\034\004\234\000\
\062\001\244\001\151\002\187\000\187\000\187\000\187\000\077\003\
\193\000\225\003\189\003\187\000\147\003\245\002\031\002\252\002\
\025\005\064\000\187\000\064\000\064\000\103\000\187\000\027\002\
\172\004\221\000\031\001\187\000\187\000\050\002\064\001\051\002\
\128\000\134\000\129\002\104\000\187\000\174\000\051\000\187\000\
\084\001\249\001\009\005\201\001\105\000\073\001\246\002\173\001\
\246\002\175\001\215\004\057\002\154\001\003\005\005\005\141\001\
\125\000\106\000\149\002\048\005\057\000\028\002\206\004\243\004\
\159\001\064\000\107\000\108\000\113\000\109\000\225\004\185\000\
\008\002\230\002\231\002\085\001\159\002\087\000\247\001\108\000\
\132\001\109\000\136\001\137\001\072\002\070\002\226\000\253\002\
\157\004\044\003\064\002\071\001\245\001\185\000\171\001\164\001\
\246\001\012\005\188\001\045\003\242\004\159\002\063\002\247\001\
\178\004\013\005\248\001\150\000\074\001\184\002\113\003\185\002\
\043\002\179\001\227\000\224\003\071\001\103\000\197\001\252\004\
\027\002\154\002\249\004\116\004\118\004\159\002\060\004\120\004\
\164\002\103\000\185\000\104\000\188\004\002\004\202\001\064\003\
\023\005\027\002\164\002\069\003\105\000\020\004\244\004\104\000\
\085\001\106\005\064\000\182\001\085\001\006\004\085\001\080\002\
\105\000\106\000\042\003\185\000\062\001\128\000\250\001\172\001\
\007\002\134\000\107\000\134\000\113\000\106\000\117\004\119\004\
\107\001\166\001\032\005\002\002\061\004\119\005\107\000\029\002\
\113\000\185\000\000\002\001\002\189\000\071\002\238\002\170\001\
\020\004\004\002\106\001\057\005\189\000\189\000\072\005\067\003\
\211\001\103\003\185\000\221\001\221\001\139\002\138\004\038\002\
\031\002\189\000\065\005\219\003\073\005\044\002\114\003\188\000\
\252\001\253\001\196\000\012\005\077\005\215\002\092\005\039\002\
\027\002\208\000\209\000\210\000\211\000\041\004\164\002\121\004\
\104\005\218\000\146\001\154\002\165\001\003\004\064\000\076\001\
\000\005\184\001\146\001\146\001\065\001\021\004\020\002\185\000\
\129\002\069\001\070\001\189\002\154\002\154\005\205\001\146\001\
\043\003\133\002\075\001\134\002\104\005\078\001\100\004\167\003\
\245\001\185\000\167\000\206\000\246\001\107\001\166\001\079\001\
\065\002\107\001\166\001\247\001\062\004\086\001\248\001\049\005\
\187\000\035\002\125\003\212\002\229\002\213\002\066\002\106\001\
\065\004\067\002\114\001\106\001\190\002\073\002\074\005\208\002\
\047\004\210\005\205\002\193\000\018\004\166\002\051\000\085\002\
\075\002\136\005\092\002\202\002\066\005\245\001\064\000\064\000\
\101\002\246\001\252\003\104\003\105\003\160\005\137\005\073\001\
\247\001\201\004\103\001\248\001\206\001\110\001\094\002\185\000\
\051\000\165\001\192\003\187\000\160\005\165\001\205\003\110\001\
\124\002\093\002\032\003\178\005\130\002\087\000\235\002\233\004\
\064\000\101\004\080\001\200\000\133\003\173\002\144\002\175\002\
\204\005\176\002\024\003\000\003\208\004\168\003\211\004\087\005\
\027\002\085\001\201\000\153\002\012\005\240\002\048\004\087\000\
\068\002\192\002\094\005\224\004\185\000\140\003\185\000\206\003\
\220\003\085\003\108\000\068\003\109\000\161\001\091\002\024\005\
\084\002\185\000\140\002\141\002\209\002\168\005\145\002\165\005\
\132\001\195\004\019\004\156\002\051\000\251\001\202\000\159\001\
\108\001\111\001\180\004\030\002\135\001\126\002\215\003\253\003\
\135\005\159\001\063\002\111\001\109\001\018\004\127\005\103\001\
\179\001\202\004\139\005\110\001\030\002\029\002\110\001\179\001\
\029\002\179\001\002\002\240\002\103\000\143\004\136\003\097\003\
\094\002\092\002\116\005\179\005\181\003\108\001\029\002\080\003\
\203\000\202\001\104\000\204\000\229\003\212\000\144\004\203\002\
\111\005\109\001\085\001\105\000\085\001\200\000\085\001\095\004\
\096\004\136\003\141\003\250\001\107\003\081\005\027\002\134\000\
\106\000\134\000\161\004\134\000\201\000\250\001\032\000\166\005\
\024\003\107\000\161\001\113\000\213\000\160\001\091\002\079\005\
\084\002\250\001\049\004\082\004\216\003\163\002\192\002\160\001\
\082\004\246\002\208\004\024\004\153\005\159\001\058\002\111\001\
\159\001\108\001\111\001\030\002\250\001\250\001\105\001\032\004\
\202\000\002\002\002\002\064\004\203\002\109\001\203\002\038\004\
\182\003\130\003\214\000\162\001\142\003\029\002\122\005\002\002\
\136\003\054\000\207\005\005\002\250\001\038\003\192\002\192\002\
\094\002\092\002\240\002\163\002\016\005\247\001\193\002\172\003\
\064\000\050\005\038\002\200\000\222\002\224\002\226\002\137\003\
\154\003\188\003\203\000\218\001\227\002\204\000\036\002\185\000\
\155\003\156\003\201\000\093\004\107\003\231\003\010\000\136\003\
\162\004\244\003\081\003\187\000\030\002\046\003\226\002\112\001\
\038\002\167\000\206\000\160\001\023\003\157\005\160\001\228\000\
\027\002\082\004\015\003\163\002\217\003\210\003\082\003\119\002\
\091\003\185\000\088\003\089\003\115\004\100\001\202\000\100\001\
\193\002\168\004\226\002\105\001\209\001\185\000\120\002\193\002\
\128\001\129\001\193\002\027\002\048\003\079\002\143\003\005\002\
\162\001\135\003\119\002\126\002\194\002\221\000\123\005\128\005\
\044\005\173\003\041\002\055\003\079\002\108\003\109\003\200\000\
\163\002\120\002\026\003\082\004\191\005\064\000\250\001\071\003\
\203\000\017\000\192\004\204\000\112\001\173\004\201\000\245\003\
\027\003\254\002\113\005\129\005\115\005\043\004\193\004\154\002\
\001\004\048\002\123\003\137\001\226\002\012\002\181\003\156\002\
\097\003\033\000\049\002\248\002\254\003\255\003\000\004\048\004\
\193\002\037\000\188\001\130\005\056\005\249\002\187\004\036\002\
\185\000\025\004\202\000\047\003\119\002\094\004\071\005\179\001\
\119\002\212\005\079\002\079\002\128\001\129\001\084\005\027\002\
\058\003\060\003\227\003\120\002\036\002\185\000\160\003\120\002\
\158\003\079\002\079\002\114\001\079\002\056\003\093\005\243\003\
\134\004\067\005\136\004\139\004\194\003\131\005\085\001\051\000\
\116\001\221\000\054\000\079\002\203\000\178\003\179\003\204\000\
\014\002\203\001\028\003\134\000\228\002\048\002\250\001\048\002\
\250\001\218\000\250\001\250\001\039\005\113\001\049\002\192\002\
\049\002\058\004\148\002\195\003\204\001\252\002\058\005\228\002\
\082\004\148\002\186\001\188\003\185\000\185\000\228\002\048\004\
\203\003\040\004\002\002\054\004\222\000\163\003\202\001\148\002\
\148\002\166\003\050\004\014\005\082\004\204\001\148\002\145\003\
\114\001\156\004\159\003\228\002\228\002\082\004\246\002\250\001\
\226\003\052\003\027\002\219\000\118\001\148\002\221\000\016\005\
\148\002\228\002\131\003\219\002\227\000\130\004\228\002\191\004\
\038\002\228\002\147\003\228\002\148\002\158\000\218\000\197\000\
\245\001\120\001\113\001\198\000\246\001\234\003\226\002\202\001\
\250\001\197\003\232\003\247\001\080\001\192\002\248\001\152\003\
\158\000\148\002\202\001\239\003\202\001\240\003\044\005\158\000\
\250\003\222\000\185\000\156\002\038\002\188\003\249\003\250\001\
\004\004\235\003\236\003\007\004\012\002\228\002\148\002\175\003\
\030\004\148\002\165\004\080\001\158\000\158\000\185\000\033\000\
\219\000\013\002\147\002\012\002\167\000\206\000\123\001\037\000\
\185\000\237\003\158\000\148\002\027\002\099\005\148\002\185\000\
\103\005\158\000\158\000\226\002\158\000\185\000\080\001\081\000\
\216\002\082\004\082\004\159\002\245\001\150\002\184\004\157\001\
\246\001\160\001\080\001\082\004\012\002\156\002\217\002\247\001\
\179\001\212\000\248\001\202\001\233\003\046\004\036\002\185\000\
\154\002\159\005\222\004\238\003\197\004\165\001\067\004\014\002\
\162\001\218\001\002\002\137\001\002\003\003\003\158\000\137\001\
\202\001\056\004\032\000\137\001\189\000\137\001\014\002\154\002\
\213\000\137\001\137\001\250\001\199\004\137\001\250\001\161\002\
\247\001\027\002\131\002\248\001\068\004\171\004\137\001\202\001\
\082\004\166\001\157\002\185\000\152\005\157\001\181\001\056\004\
\209\001\111\004\112\004\013\000\180\001\027\002\076\002\014\002\
\162\005\098\001\099\001\004\003\154\003\250\001\214\000\123\004\
\208\005\209\005\190\000\077\002\182\001\054\000\018\000\033\002\
\218\002\195\001\038\002\163\002\058\003\185\000\137\001\156\002\
\135\004\059\004\088\004\011\004\185\000\137\001\204\001\014\000\
\024\000\025\000\026\000\082\004\236\002\156\002\177\001\226\002\
\111\001\104\001\227\000\226\002\199\001\226\005\015\000\016\000\
\137\001\137\001\030\002\137\001\137\001\172\005\170\004\169\000\
\195\005\196\005\109\001\023\000\042\000\015\003\237\002\195\001\
\044\002\038\002\127\001\183\004\035\002\170\000\137\001\191\001\
\208\001\250\004\151\000\202\001\176\000\112\001\044\002\033\000\
\185\000\015\003\083\001\151\005\147\000\222\004\050\000\037\000\
\156\002\038\002\217\005\173\005\217\000\041\000\245\001\247\001\
\156\002\015\003\246\001\198\001\045\000\196\004\156\002\127\003\
\187\001\247\001\002\002\212\000\248\001\043\005\169\003\221\004\
\225\005\185\000\247\001\203\004\027\002\255\002\128\003\032\000\
\170\003\247\001\247\001\250\001\204\004\209\004\235\005\044\002\
\053\000\129\000\154\002\199\001\032\000\027\002\044\002\159\002\
\216\001\254\004\213\000\072\004\177\001\218\004\247\001\247\001\
\216\001\054\000\232\004\097\003\160\002\235\004\187\001\199\001\
\128\004\228\004\044\002\204\001\247\001\185\000\131\004\177\001\
\132\004\255\004\187\001\247\001\247\001\148\001\247\001\132\001\
\246\004\247\004\147\000\189\000\149\004\198\002\224\002\081\000\
\214\000\251\001\027\002\156\002\234\001\088\004\054\000\054\000\
\007\005\010\005\147\000\161\002\081\000\199\001\054\000\164\003\
\202\001\153\003\038\002\202\001\202\001\017\005\235\001\236\001\
\237\001\081\000\081\000\081\000\081\000\147\000\151\000\097\003\
\247\001\199\001\079\003\151\000\151\000\202\001\029\003\029\005\
\081\000\146\001\152\002\199\002\110\005\189\000\055\005\080\001\
\154\003\185\000\238\001\152\002\045\005\157\003\088\004\176\000\
\176\000\138\005\176\000\176\000\081\000\176\000\027\002\081\000\
\030\003\162\003\081\000\081\000\081\000\157\001\039\003\176\000\
\176\000\157\001\081\000\156\002\196\001\157\001\245\001\157\001\
\147\000\081\000\246\001\157\001\185\000\239\001\182\004\157\001\
\104\004\247\001\204\001\122\003\248\001\081\000\218\004\081\000\
\157\001\081\000\081\000\101\002\203\002\176\000\176\000\240\001\
\241\001\242\001\217\000\040\003\080\005\081\000\234\004\101\002\
\081\000\228\004\238\004\068\005\081\000\207\001\088\005\158\005\
\212\000\089\005\202\001\091\005\245\001\157\001\202\001\163\005\
\246\001\157\001\132\001\243\001\054\000\158\003\053\005\247\001\
\102\005\088\004\248\001\157\001\228\004\185\000\124\005\157\001\
\204\004\032\000\127\001\088\004\144\002\144\002\127\001\213\000\
\202\001\008\005\127\001\144\002\127\001\002\002\234\005\185\000\
\127\001\199\002\157\001\157\001\117\005\157\001\157\001\185\000\
\245\001\144\002\210\001\202\001\246\001\127\001\027\005\144\002\
\218\004\204\001\159\004\247\001\072\003\031\003\200\004\228\002\
\157\001\251\001\142\001\185\000\199\002\214\000\147\000\132\005\
\198\000\133\005\144\002\144\002\054\000\250\001\185\000\116\003\
\118\003\217\000\140\005\202\001\144\005\145\005\073\003\203\005\
\149\005\228\004\111\001\032\000\136\002\155\005\137\002\160\004\
\189\000\143\001\059\005\185\000\127\001\228\004\014\000\216\001\
\138\002\117\003\144\001\202\001\159\002\228\002\254\001\185\000\
\248\001\180\002\164\005\119\003\002\002\015\000\016\000\127\001\
\127\001\087\002\127\001\127\001\202\001\088\004\159\002\227\004\
\002\002\174\005\023\000\248\001\145\001\202\001\241\000\088\002\
\083\005\163\002\248\001\248\001\176\000\127\001\146\001\123\002\
\060\005\202\001\199\001\224\002\123\002\054\000\033\000\075\005\
\159\002\083\001\189\005\169\005\100\005\185\000\037\000\248\001\
\248\001\228\004\224\002\224\002\041\000\186\001\199\001\197\005\
\109\005\202\005\061\005\045\000\148\001\248\001\163\002\224\002\
\164\002\076\005\187\001\170\005\248\001\248\001\255\001\248\001\
\002\002\002\002\132\001\130\000\122\000\009\002\132\001\011\002\
\218\004\121\005\214\005\224\002\083\004\132\001\224\002\053\000\
\132\001\219\005\220\005\224\002\051\000\151\000\185\000\227\000\
\202\001\224\002\019\002\202\001\151\000\164\002\151\000\223\005\
\224\002\202\001\002\002\084\004\151\000\087\000\030\002\032\000\
\186\000\248\001\144\000\083\001\198\001\085\004\051\000\226\002\
\224\002\224\002\179\000\151\000\151\000\202\001\236\005\129\004\
\002\002\176\000\226\002\086\004\224\002\202\001\040\002\087\000\
\202\001\132\001\029\000\045\002\144\000\202\001\002\002\142\004\
\202\001\202\001\086\002\226\002\179\000\114\002\114\002\042\002\
\087\002\047\002\017\004\028\004\046\002\232\002\132\004\233\002\
\194\000\087\002\054\000\176\000\176\000\176\000\088\002\114\002\
\216\001\234\002\245\001\176\000\135\001\159\002\246\001\088\002\
\184\005\066\002\187\005\194\000\067\002\247\001\049\002\138\001\
\248\001\151\000\194\000\151\000\193\005\052\002\150\005\159\002\
\151\000\092\003\176\000\176\000\159\002\251\001\160\000\176\000\
\159\002\176\000\159\002\060\002\159\002\159\002\159\002\194\000\
\194\000\217\000\074\002\184\005\184\005\163\004\054\000\125\004\
\062\002\160\000\213\005\058\002\159\002\194\000\066\001\164\004\
\160\000\081\002\151\000\176\000\194\000\194\000\119\002\194\000\
\054\000\185\000\176\000\221\005\030\002\067\001\068\001\151\000\
\151\000\111\001\224\005\163\002\112\003\160\000\160\000\185\000\
\184\005\148\001\217\000\159\002\229\005\163\002\176\000\032\001\
\132\002\232\005\233\005\160\000\133\001\019\003\033\001\152\002\
\133\001\186\000\160\000\160\000\034\003\160\000\142\002\133\001\
\036\003\194\000\133\001\227\000\020\003\021\003\241\000\241\000\
\241\000\241\000\242\003\133\001\006\003\007\003\241\000\241\000\
\241\000\158\002\182\001\241\000\241\000\164\002\241\000\241\000\
\241\000\241\000\241\000\241\000\120\001\176\000\241\000\241\000\
\241\000\241\000\241\000\241\000\036\002\185\000\080\001\160\000\
\152\001\165\002\241\000\241\000\006\003\009\003\241\000\241\000\
\241\000\241\000\182\002\133\001\183\002\241\000\241\000\067\001\
\153\001\036\002\185\000\159\000\148\001\185\000\080\001\192\000\
\186\002\151\000\187\002\241\000\241\000\188\002\241\000\008\003\
\010\003\241\000\241\000\241\000\195\002\241\000\159\000\196\002\
\241\000\241\000\192\000\197\002\151\000\159\000\147\000\151\000\
\241\000\192\000\241\000\201\002\206\002\207\002\151\000\181\000\
\151\000\151\000\210\002\241\000\241\000\211\002\241\000\241\000\
\241\000\241\000\159\000\159\000\176\000\214\002\192\000\241\000\
\176\000\241\000\181\000\063\002\241\000\242\002\151\000\241\000\
\159\000\181\000\029\000\241\000\192\000\029\000\032\000\159\000\
\159\000\101\002\159\000\192\000\192\000\018\003\192\000\029\000\
\029\000\049\003\051\003\050\003\054\003\062\003\181\000\176\000\
\151\000\061\003\063\003\065\003\029\000\029\000\029\000\029\000\
\076\003\084\003\099\001\101\003\181\000\102\003\005\002\110\003\
\176\000\115\003\029\000\029\000\181\000\111\003\181\000\138\001\
\176\000\124\003\176\000\138\001\159\000\132\003\134\003\138\001\
\192\000\138\001\138\003\149\003\217\000\138\001\138\001\029\000\
\148\001\138\001\029\000\122\001\029\000\029\000\029\000\029\000\
\151\003\150\003\138\001\206\001\161\003\029\000\096\002\097\002\
\098\002\099\002\247\001\213\001\029\000\171\003\176\003\180\003\
\181\000\167\000\100\002\183\003\190\003\191\003\059\001\196\003\
\029\000\230\000\029\000\158\001\029\000\029\000\148\001\006\003\
\207\003\209\003\147\000\218\003\248\003\246\003\010\004\167\002\
\029\000\014\004\138\001\029\000\015\004\167\001\023\004\029\000\
\251\003\138\001\026\004\031\004\174\001\147\000\134\002\217\000\
\035\004\036\004\168\002\151\000\147\000\176\000\176\000\101\002\
\039\004\010\000\151\000\051\004\138\001\138\001\055\004\138\001\
\138\001\199\002\167\000\206\000\066\004\148\001\057\004\103\004\
\217\000\147\000\147\000\098\004\105\004\108\004\109\004\110\004\
\127\004\148\001\138\001\124\004\120\001\156\004\158\004\147\000\
\120\001\148\001\166\004\174\004\120\001\151\000\120\001\147\000\
\151\000\147\000\120\001\120\001\169\004\175\004\176\004\179\004\
\169\002\094\000\151\000\177\004\190\004\170\002\198\004\120\001\
\054\000\096\002\097\002\098\002\099\002\210\004\151\000\212\004\
\095\000\016\000\216\004\217\004\033\003\100\002\037\002\236\004\
\176\000\219\004\220\004\011\005\237\004\096\000\240\004\144\004\
\026\005\077\002\239\004\147\000\040\005\245\004\075\004\087\004\
\002\005\176\000\004\005\151\000\151\000\041\005\028\005\120\001\
\175\000\033\000\063\005\051\005\064\005\078\005\120\001\114\005\
\191\000\037\000\086\005\108\005\176\000\126\005\148\001\097\000\
\216\000\141\005\101\002\142\005\090\005\220\000\045\000\148\005\
\156\005\120\001\120\001\191\000\120\001\120\001\032\000\151\000\
\176\000\032\000\191\000\177\005\217\000\151\000\098\000\151\000\
\180\005\181\005\182\005\032\000\032\000\188\005\192\005\120\001\
\176\000\190\005\099\000\151\000\014\005\100\000\201\005\191\000\
\032\000\032\000\032\000\032\000\001\000\002\000\003\000\004\000\
\005\000\006\000\007\000\200\005\205\005\191\000\032\000\032\000\
\211\005\215\005\218\005\176\000\191\000\191\000\222\005\191\000\
\090\001\227\005\156\001\228\005\075\004\230\005\051\000\087\000\
\159\002\008\000\224\002\032\000\051\000\228\002\032\000\034\002\
\148\001\095\002\032\000\032\000\126\000\234\002\163\002\199\001\
\164\002\032\000\235\002\213\001\151\000\097\001\098\001\099\001\
\032\000\216\000\046\002\213\001\151\000\148\002\148\002\076\001\
\213\001\191\000\150\002\149\002\032\000\149\002\032\000\205\004\
\032\000\032\000\151\000\220\001\151\000\213\001\151\000\213\001\
\213\001\101\001\102\001\199\001\032\000\151\002\154\002\032\000\
\176\000\151\000\087\004\032\000\213\001\155\002\104\001\105\001\
\106\001\107\001\156\002\175\000\175\000\217\001\175\000\175\000\
\152\002\175\000\155\002\134\002\176\000\151\000\168\001\109\001\
\213\001\151\000\181\004\175\000\175\000\070\005\213\001\213\001\
\213\001\229\004\134\002\134\002\226\004\150\002\213\001\167\005\
\147\005\125\005\174\002\107\004\201\003\213\001\137\000\134\002\
\138\000\139\000\032\000\087\004\140\000\086\003\172\002\177\001\
\142\000\175\000\175\000\146\002\228\002\213\001\216\000\151\000\
\151\000\087\003\113\004\134\002\053\003\165\003\134\002\224\001\
\230\004\213\001\155\001\134\002\213\001\012\004\216\005\047\005\
\185\004\134\002\145\000\107\005\204\002\151\000\000\000\168\000\
\134\002\146\000\052\005\205\004\178\000\148\003\000\000\000\000\
\194\000\077\002\000\000\000\000\077\002\147\000\148\000\000\000\
\134\002\134\002\000\000\075\004\151\000\000\000\077\002\000\000\
\000\000\194\000\077\002\000\000\134\002\176\000\000\000\125\002\
\151\000\000\000\000\000\077\002\077\002\077\002\077\002\151\000\
\000\000\151\000\000\000\000\000\000\000\194\000\087\004\000\000\
\075\004\151\000\077\002\176\000\000\000\000\000\000\000\000\000\
\087\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\176\000\216\000\077\002\000\000\
\000\000\077\002\000\000\125\002\077\002\077\002\077\002\151\000\
\194\000\000\000\194\000\194\000\077\002\000\000\199\001\000\000\
\000\000\084\002\000\000\077\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\151\000\000\000\000\000\000\000\077\002\
\000\000\077\002\156\001\077\002\077\002\000\000\156\001\151\000\
\000\000\176\000\156\001\000\000\156\001\000\000\070\003\077\002\
\156\001\224\002\077\002\075\003\156\001\151\000\077\002\151\000\
\175\000\000\000\000\000\000\000\000\000\156\001\000\000\000\000\
\151\000\000\000\000\000\000\000\224\002\217\001\000\000\003\001\
\000\000\000\000\000\000\224\002\075\004\151\000\000\000\000\000\
\000\000\000\000\087\004\000\000\000\000\000\000\075\004\178\000\
\214\001\000\000\178\000\178\000\000\000\178\000\093\003\000\000\
\224\002\224\002\000\000\000\000\000\000\176\000\000\000\178\000\
\178\000\000\000\000\000\000\000\156\001\171\002\224\002\000\000\
\000\000\194\000\000\000\000\000\000\000\000\000\224\002\000\000\
\224\002\000\000\000\000\000\000\000\000\000\000\000\000\156\001\
\156\001\129\003\156\001\156\001\000\000\178\000\214\001\000\000\
\000\000\000\000\000\000\075\004\000\000\151\000\205\004\194\000\
\000\000\000\000\000\000\000\000\000\000\156\001\000\000\000\000\
\000\000\199\001\000\000\000\000\000\000\175\000\000\000\151\000\
\000\000\151\000\224\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\151\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\168\000\
\000\000\000\000\168\000\000\000\000\000\000\000\075\004\175\000\
\175\000\175\000\151\000\151\000\168\000\000\000\000\000\175\000\
\000\000\151\000\190\000\000\000\000\000\151\000\217\001\000\000\
\000\000\168\000\168\000\168\000\168\000\000\000\175\000\000\000\
\000\000\224\002\151\000\194\000\193\003\190\000\175\000\175\000\
\168\000\151\000\000\000\175\000\190\000\175\000\000\000\151\000\
\000\000\000\000\000\000\151\000\000\000\216\000\000\000\194\000\
\151\000\151\000\217\001\000\000\168\000\000\000\217\001\000\000\
\000\000\190\000\000\000\168\000\168\000\000\000\000\000\175\000\
\123\001\000\000\168\000\000\000\000\000\000\000\175\000\190\000\
\010\000\168\000\176\001\000\000\000\000\000\000\190\000\190\000\
\000\000\190\000\000\000\000\000\222\003\000\000\216\000\168\000\
\000\000\168\000\175\000\000\000\000\000\000\000\000\000\228\003\
\000\000\230\003\000\000\000\000\178\000\168\000\000\000\000\000\
\168\000\220\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\194\000\194\000\000\000\000\000\194\000\000\000\
\194\000\000\000\137\000\190\000\138\000\139\000\032\000\000\000\
\140\000\000\000\000\000\177\001\142\000\000\000\013\004\003\001\
\000\000\175\000\003\001\000\000\000\000\000\000\000\000\003\001\
\000\000\003\001\000\000\000\000\003\001\003\001\000\000\003\001\
\003\001\003\001\003\001\003\001\003\001\033\004\145\000\003\001\
\003\001\003\001\037\004\003\001\003\001\146\000\000\000\000\000\
\000\000\126\003\000\000\000\000\003\001\000\000\000\000\003\001\
\003\001\147\000\148\000\000\000\000\000\000\000\003\001\003\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\213\001\000\000\000\000\003\001\000\000\000\000\003\001\
\000\000\178\000\000\000\003\001\003\001\000\000\003\001\000\000\
\000\000\003\001\003\001\000\000\000\000\000\000\000\000\000\000\
\175\000\003\001\092\004\217\001\175\000\000\000\000\000\097\004\
\000\000\000\000\000\000\000\000\003\001\003\001\000\000\003\001\
\003\001\003\001\003\001\178\000\178\000\178\000\000\000\000\000\
\003\001\000\000\003\001\178\000\000\000\003\001\000\000\000\000\
\003\001\000\000\000\000\175\000\003\001\000\000\000\000\000\000\
\000\000\000\000\250\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\214\001\178\000\175\000\000\000\141\004\214\001\
\000\000\178\000\000\000\000\000\175\000\000\000\175\000\000\000\
\000\000\224\002\224\002\000\000\000\000\000\000\000\000\000\000\
\216\000\000\000\000\000\000\000\000\000\000\000\224\002\000\000\
\000\000\000\000\077\002\178\000\000\000\224\002\000\000\000\000\
\000\000\000\000\178\000\224\002\224\002\224\002\224\002\000\000\
\000\000\000\000\000\000\000\000\000\000\221\003\000\000\186\004\
\123\001\000\000\224\002\000\000\123\001\189\004\178\000\000\000\
\123\001\224\002\123\001\000\000\000\000\000\000\123\001\000\000\
\000\000\000\000\123\001\000\000\000\000\194\000\224\002\224\002\
\000\000\224\002\000\000\123\001\000\000\000\000\224\002\224\002\
\000\000\224\002\000\000\216\000\224\002\000\000\000\000\000\000\
\000\000\175\000\175\000\224\002\000\000\000\000\000\000\179\000\
\000\000\000\000\000\000\195\000\000\000\214\001\000\000\224\002\
\000\000\000\000\000\000\224\002\216\000\000\000\000\000\027\004\
\000\000\000\000\231\004\123\001\195\000\000\000\000\000\224\002\
\000\000\000\000\123\001\224\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\195\000\000\000\000\000\000\000\000\000\123\001\123\001\000\000\
\123\001\123\001\199\001\000\000\251\004\000\000\253\004\000\000\
\001\005\000\000\000\000\006\005\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\123\001\175\000\000\000\000\000\000\000\
\000\000\000\000\015\005\195\000\000\000\195\000\195\000\000\000\
\000\000\213\001\000\000\199\001\178\000\175\000\000\000\000\000\
\178\000\000\000\000\000\030\005\031\005\000\000\213\001\000\000\
\069\004\036\005\138\000\139\000\032\000\000\000\140\000\000\000\
\175\000\070\004\071\004\213\001\000\000\213\001\213\001\000\000\
\000\000\000\000\000\000\226\002\000\000\000\000\000\000\214\001\
\072\004\000\000\213\001\073\004\175\000\054\005\000\000\000\000\
\216\000\178\001\000\000\074\004\145\000\000\000\000\000\000\000\
\178\000\000\000\000\000\146\000\175\000\000\000\213\001\000\000\
\178\000\000\000\214\001\000\000\213\001\213\001\213\001\147\000\
\148\000\000\000\179\000\215\001\213\001\179\000\179\000\000\000\
\179\000\000\000\000\000\213\001\181\000\000\000\000\000\175\000\
\000\000\000\000\179\000\179\000\000\000\207\000\000\000\000\000\
\000\000\000\000\000\000\213\001\195\000\000\000\217\001\000\000\
\000\000\000\000\077\002\000\000\000\000\077\002\000\000\213\001\
\000\000\105\005\213\001\000\000\000\000\000\000\000\000\077\002\
\179\000\215\001\000\000\077\002\217\001\000\000\000\000\112\005\
\126\002\000\000\195\000\000\000\077\002\077\002\077\002\077\002\
\138\002\000\000\000\000\000\000\000\000\118\005\000\000\000\000\
\120\005\000\000\000\000\077\002\000\000\178\000\214\001\000\000\
\000\000\000\000\000\000\057\003\175\000\000\000\199\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\077\002\
\000\000\000\000\077\002\000\000\126\002\077\002\077\002\077\002\
\175\000\156\001\000\000\000\000\143\005\077\002\000\000\000\000\
\000\000\000\000\000\000\000\000\077\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\242\001\
\077\002\000\000\077\002\000\000\077\002\077\002\195\000\199\001\
\000\000\000\000\000\000\137\000\000\000\138\000\139\000\032\000\
\077\002\140\000\151\001\077\002\141\000\142\000\000\000\077\002\
\178\000\000\000\195\000\176\005\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\143\000\181\000\
\181\000\214\001\181\000\181\000\000\000\181\000\144\000\144\003\
\000\000\000\000\000\000\000\000\000\000\000\000\146\000\181\000\
\181\000\000\000\000\000\000\000\178\000\000\000\198\005\199\005\
\000\000\005\004\147\000\148\000\180\000\000\000\206\005\057\003\
\000\000\175\000\000\000\000\000\000\000\000\000\000\000\179\000\
\178\000\000\000\000\000\000\000\000\000\181\000\181\000\014\000\
\000\000\000\000\199\001\226\002\000\000\195\000\195\000\175\000\
\178\000\195\000\000\000\195\000\199\001\000\000\015\000\016\000\
\226\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\175\000\000\000\000\000\023\000\000\000\226\002\000\000\226\002\
\226\002\231\005\000\000\214\001\000\000\000\000\000\000\137\000\
\000\000\138\000\139\000\032\000\226\002\140\000\000\000\033\000\
\141\000\142\000\083\001\000\000\241\001\000\000\000\000\037\000\
\178\001\000\000\000\000\000\000\000\000\041\000\000\000\178\001\
\226\002\178\001\143\000\226\002\045\000\175\000\000\000\226\002\
\226\002\000\000\144\000\145\000\000\000\000\000\226\002\000\000\
\000\000\000\000\146\000\000\000\049\000\226\002\000\000\000\000\
\000\000\000\000\000\000\000\000\179\000\000\000\147\000\148\000\
\053\000\226\002\000\000\000\000\000\000\226\002\226\002\000\000\
\214\001\000\000\000\000\000\000\000\000\000\000\199\001\194\000\
\199\001\226\002\000\000\000\000\226\002\138\002\000\000\000\000\
\000\000\000\000\000\000\000\000\214\001\000\000\179\000\179\000\
\179\000\175\000\000\000\102\002\138\002\138\002\179\000\180\000\
\180\000\000\000\180\000\180\000\000\000\180\000\000\000\000\000\
\175\000\138\002\000\000\000\000\000\000\000\000\000\000\180\000\
\180\000\000\000\000\000\107\000\128\002\215\001\179\000\000\000\
\000\000\000\000\215\001\000\000\179\000\138\002\010\000\242\001\
\138\002\000\000\242\001\000\000\000\000\138\002\000\000\000\000\
\000\000\000\000\000\000\138\002\242\001\180\000\180\000\000\000\
\000\000\000\000\138\002\000\000\000\000\000\000\179\000\000\000\
\000\000\242\001\242\001\242\001\242\001\179\000\000\000\000\000\
\175\000\000\000\138\002\138\002\000\000\000\000\000\000\000\000\
\242\001\000\000\000\000\000\000\000\000\000\000\138\002\000\000\
\137\000\179\000\138\000\139\000\032\000\178\000\140\000\000\000\
\000\000\177\001\142\000\000\000\242\001\000\000\000\000\242\001\
\195\000\151\001\242\001\242\001\242\001\000\000\000\000\000\000\
\000\000\000\000\242\001\214\001\000\000\090\001\000\000\000\000\
\000\000\242\001\194\000\000\000\145\000\000\000\000\000\000\000\
\000\000\181\000\000\000\146\000\214\001\242\001\000\000\242\001\
\215\001\242\001\242\001\000\000\000\000\000\000\000\000\147\000\
\148\000\096\001\097\001\098\001\099\001\242\001\000\000\000\000\
\242\001\000\000\151\001\000\000\242\001\000\000\000\000\000\000\
\000\000\000\000\220\002\181\000\181\000\181\000\200\002\000\000\
\000\000\185\000\000\000\181\000\000\000\059\003\101\001\102\001\
\000\000\214\001\000\000\000\000\241\001\000\000\000\000\241\001\
\000\000\000\000\000\000\104\001\105\001\106\001\107\001\178\001\
\224\002\241\001\181\000\181\000\000\000\000\000\000\000\181\000\
\000\000\181\000\000\000\000\000\109\001\000\000\241\001\241\001\
\241\001\241\001\000\000\000\000\180\000\102\002\000\000\179\000\
\000\000\000\000\000\000\179\000\000\000\241\001\000\000\000\000\
\000\000\000\000\000\000\181\000\000\000\137\000\000\000\138\000\
\139\000\032\000\128\002\140\000\000\000\214\001\141\000\142\000\
\000\000\241\001\000\000\000\000\241\001\000\000\000\000\241\001\
\241\001\241\001\215\001\000\000\161\005\000\000\181\000\241\001\
\143\000\000\000\000\000\239\001\000\000\000\000\241\001\000\000\
\144\000\145\000\000\000\179\000\000\000\000\000\000\000\000\000\
\146\000\000\000\241\001\179\000\241\001\215\001\241\001\241\001\
\000\000\161\002\000\000\107\000\147\000\148\000\000\000\000\000\
\000\000\000\000\241\001\000\000\000\000\241\001\151\001\000\000\
\107\000\241\001\000\000\000\000\000\000\181\000\000\000\000\000\
\000\000\000\000\000\000\000\000\194\005\107\000\000\000\107\000\
\107\000\180\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\107\000\000\000\000\000\000\000\
\000\000\000\000\000\000\161\002\000\000\161\002\161\002\161\002\
\092\000\161\002\000\000\000\000\161\002\161\002\000\000\000\000\
\107\000\000\000\000\000\180\000\180\000\180\000\000\000\107\000\
\107\000\000\000\000\000\180\000\180\000\000\000\107\000\000\000\
\179\000\215\001\000\000\000\000\000\000\107\000\000\000\161\002\
\000\000\000\000\000\000\174\003\000\000\000\000\161\002\000\000\
\000\000\151\001\180\000\180\000\181\000\107\000\000\000\180\000\
\181\000\180\000\161\002\161\002\000\000\000\000\000\000\000\000\
\000\000\107\000\000\000\000\000\107\000\000\000\000\000\000\000\
\178\001\000\000\000\000\000\000\000\000\044\004\000\000\000\000\
\231\000\231\000\000\000\180\000\000\000\000\000\000\000\181\000\
\000\000\000\000\180\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\137\000\000\000\138\000\139\000\032\000\
\181\000\140\000\000\000\179\000\141\000\142\000\180\000\000\000\
\181\000\000\000\181\000\000\000\000\000\000\000\000\000\000\000\
\224\002\000\000\000\000\224\002\215\001\000\000\143\000\000\000\
\000\000\000\000\000\000\000\000\000\000\224\002\144\000\145\000\
\000\000\138\001\139\001\000\000\000\000\000\000\146\000\179\000\
\000\000\000\000\224\002\000\000\224\002\224\002\000\000\000\000\
\000\000\000\000\147\000\148\000\000\000\180\000\000\000\000\000\
\000\000\224\002\000\000\179\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\151\001\000\000\000\000\
\000\000\000\000\000\000\179\000\253\001\224\002\000\000\000\000\
\000\000\000\000\000\000\239\001\000\000\224\002\239\001\000\000\
\000\000\000\000\000\000\224\002\000\000\181\000\181\000\000\000\
\239\001\151\001\224\002\000\000\000\000\000\000\215\001\000\000\
\000\000\000\000\000\000\151\001\000\000\239\001\239\001\239\001\
\239\001\000\000\224\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\239\001\000\000\224\002\000\000\
\000\000\224\002\000\000\102\002\180\000\194\004\000\000\000\000\
\180\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\239\001\000\000\000\000\239\001\000\000\000\000\239\001\239\001\
\239\001\000\000\151\001\000\000\000\000\178\001\239\001\010\000\
\092\000\176\001\000\000\000\000\000\000\239\001\151\001\180\000\
\181\000\000\000\000\000\215\001\000\000\092\000\151\001\000\000\
\000\000\239\001\195\000\239\001\000\000\239\001\239\001\000\000\
\180\000\181\000\092\000\000\000\092\000\092\000\000\000\215\001\
\180\000\239\001\180\000\000\000\239\001\000\000\000\000\000\000\
\239\001\092\000\000\000\000\000\181\000\000\000\000\000\000\000\
\000\000\137\000\000\000\138\000\139\000\032\000\151\001\140\000\
\000\000\000\000\141\000\142\000\000\000\092\000\000\000\000\000\
\181\000\000\000\000\000\081\004\000\000\092\000\000\000\000\000\
\000\000\000\000\000\000\092\000\143\000\000\000\000\000\000\000\
\181\000\000\000\092\000\000\000\144\000\145\000\006\001\000\000\
\000\000\000\000\000\000\151\001\146\000\000\000\151\001\151\001\
\000\000\000\000\092\000\000\000\000\000\000\000\000\000\000\000\
\147\000\148\000\000\000\181\000\000\000\000\000\092\000\000\000\
\000\000\092\000\000\000\000\000\000\000\180\000\180\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\179\000\103\002\104\002\105\002\106\002\107\002\108\002\109\002\
\110\002\111\002\112\002\113\002\114\002\115\002\116\002\117\002\
\118\002\119\002\120\002\121\002\122\002\123\002\215\001\125\002\
\000\000\000\000\000\000\000\000\000\000\195\000\000\000\000\000\
\000\000\081\004\000\000\000\000\000\000\135\002\000\000\215\001\
\000\000\000\000\000\000\000\000\253\001\151\001\253\001\253\001\
\181\000\148\002\000\000\000\000\253\001\000\000\000\000\000\000\
\000\000\253\001\000\000\000\000\000\000\253\001\253\001\253\001\
\180\000\000\000\000\000\000\000\181\000\000\000\253\001\253\001\
\253\001\253\001\000\000\000\000\207\004\000\000\000\000\000\000\
\253\001\180\000\000\000\000\000\215\001\253\001\000\000\000\000\
\000\000\000\000\000\000\253\001\253\001\000\000\000\000\000\000\
\000\000\013\001\000\000\000\000\180\000\000\000\000\000\000\000\
\000\000\253\001\000\000\000\000\253\001\000\000\000\000\253\001\
\253\001\253\001\000\000\253\001\000\000\000\000\000\000\253\001\
\180\000\000\000\000\000\000\000\000\000\000\000\253\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\180\000\253\001\253\001\000\000\253\001\253\001\253\001\253\001\
\215\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\253\001\000\000\000\000\253\001\000\000\000\000\
\000\000\253\001\000\000\180\000\000\000\181\000\000\000\000\000\
\000\000\000\000\137\000\000\000\138\000\139\000\032\000\151\001\
\140\000\000\000\000\000\141\000\142\000\000\000\000\000\000\000\
\207\004\000\000\000\000\181\000\000\000\037\005\038\005\000\000\
\000\000\000\000\000\000\000\000\000\000\143\000\000\000\000\000\
\081\004\000\000\000\000\025\003\181\000\144\000\145\000\000\000\
\000\000\000\000\000\000\000\000\035\003\146\000\006\001\000\000\
\037\003\006\001\000\000\041\003\000\000\000\000\006\001\000\000\
\006\001\147\000\148\000\006\001\006\001\081\004\000\000\006\001\
\180\000\006\001\006\001\006\001\000\000\000\000\006\001\006\001\
\006\001\079\002\006\001\006\001\000\000\000\000\000\000\000\000\
\000\000\181\000\000\000\006\001\180\000\151\001\006\001\006\001\
\000\000\000\000\000\000\000\000\000\000\006\001\006\001\000\000\
\000\000\000\000\000\000\000\000\231\000\231\000\000\000\000\000\
\000\000\000\000\000\000\006\001\000\000\000\000\006\001\000\000\
\000\000\000\000\006\001\006\001\000\000\006\001\000\000\000\000\
\006\001\006\001\000\000\000\000\000\000\000\000\000\000\000\000\
\006\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\106\003\006\001\006\001\181\000\006\001\006\001\
\006\001\006\001\000\000\000\000\000\000\000\000\000\000\006\001\
\000\000\006\001\207\004\000\000\006\001\000\000\000\000\006\001\
\000\000\081\004\000\000\006\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\081\004\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\137\000\180\000\138\000\139\000\
\032\000\013\001\140\000\000\000\013\001\141\000\142\000\000\000\
\000\000\013\001\000\000\013\001\000\000\114\002\013\001\013\001\
\000\000\000\000\013\001\180\000\013\001\013\001\013\001\143\000\
\000\000\013\001\013\001\013\001\000\000\013\001\013\001\144\000\
\144\003\000\000\000\000\000\000\180\000\000\000\013\001\146\000\
\081\004\013\001\013\001\207\004\000\000\000\000\000\000\000\000\
\013\001\013\001\177\003\147\000\148\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\013\001\000\000\
\000\000\013\001\000\000\000\000\000\000\013\001\013\001\000\000\
\013\001\000\000\000\000\013\001\013\001\000\000\000\000\000\000\
\000\000\180\000\000\000\013\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\081\004\208\003\000\000\013\001\013\001\
\000\000\013\001\013\001\013\001\013\001\000\000\000\000\000\000\
\000\000\000\000\013\001\000\000\013\001\000\000\000\000\013\001\
\000\000\000\000\013\001\000\000\000\000\000\000\013\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\223\003\000\000\000\000\000\000\000\000\000\000\000\000\224\000\
\000\000\000\000\000\000\000\000\000\000\180\000\000\000\000\000\
\000\000\079\002\079\002\079\002\079\002\000\000\000\000\079\002\
\079\002\079\002\079\002\079\002\079\002\079\002\079\002\079\002\
\079\002\079\002\079\002\079\002\079\002\079\002\079\002\079\002\
\000\000\079\002\079\002\079\002\079\002\079\002\079\002\079\002\
\079\002\000\000\000\000\000\000\000\000\079\002\079\002\000\000\
\022\004\079\002\079\002\079\002\079\002\079\002\079\002\079\002\
\079\002\079\002\079\002\079\002\079\002\079\002\000\000\079\002\
\079\002\079\002\079\002\000\000\000\000\079\002\079\002\079\002\
\058\002\079\002\079\002\079\002\079\002\079\002\079\002\000\000\
\079\002\079\002\079\002\079\002\079\002\000\000\079\002\079\002\
\000\000\000\000\000\000\079\002\079\002\079\002\079\002\079\002\
\079\002\079\002\079\002\000\000\079\002\000\000\079\002\079\002\
\000\000\079\002\079\002\079\002\079\002\079\002\000\000\079\002\
\079\002\000\000\079\002\079\002\079\002\079\002\029\001\079\002\
\079\002\000\000\079\002\000\000\000\000\000\000\079\002\000\000\
\000\000\000\000\000\000\000\000\000\000\114\002\114\002\114\002\
\114\002\114\002\000\000\114\002\114\002\114\002\114\002\114\002\
\114\002\114\002\114\002\114\002\114\002\114\002\114\002\114\002\
\114\002\114\002\114\002\000\000\122\004\114\002\114\002\114\002\
\114\002\114\002\114\002\114\002\114\002\000\000\000\000\000\000\
\000\000\114\002\114\002\000\000\000\000\114\002\114\002\114\002\
\114\002\114\002\114\002\114\002\114\002\114\002\114\002\114\002\
\114\002\114\002\000\000\114\002\114\002\114\002\114\002\000\000\
\000\000\114\002\114\002\114\002\000\000\114\002\114\002\114\002\
\114\002\114\002\114\002\000\000\114\002\114\002\114\002\114\002\
\114\002\000\000\114\002\114\002\000\000\000\000\000\000\114\002\
\114\002\114\002\114\002\114\002\114\002\114\002\114\002\000\000\
\114\002\000\000\114\002\114\002\000\000\114\002\114\002\114\002\
\114\002\114\002\000\000\114\002\114\002\060\001\114\002\114\002\
\114\002\114\002\000\000\114\002\114\002\000\000\114\002\000\000\
\000\000\000\000\114\002\000\000\000\000\000\000\000\000\224\000\
\224\000\224\000\224\000\000\000\000\000\000\000\000\000\224\000\
\224\000\224\000\000\000\000\000\224\000\224\000\224\000\224\000\
\224\000\224\000\224\000\224\000\224\000\000\000\000\000\224\000\
\224\000\224\000\224\000\224\000\224\000\000\000\000\000\000\000\
\000\000\000\000\000\000\224\000\224\000\000\000\000\000\224\000\
\224\000\224\000\224\000\224\000\224\000\224\000\224\000\224\000\
\000\000\000\000\000\000\000\000\241\004\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\224\000\224\000\000\000\224\000\
\248\004\000\000\224\000\224\000\224\000\000\000\224\000\224\000\
\224\000\224\000\224\000\000\000\000\000\000\000\000\000\000\000\
\000\000\224\000\000\000\224\000\224\000\224\000\224\000\224\000\
\000\000\000\000\000\000\000\000\224\000\224\000\000\000\224\000\
\224\000\224\000\224\000\036\001\000\000\224\000\000\000\000\000\
\224\000\000\000\224\000\000\000\000\000\224\000\000\000\000\000\
\224\000\033\005\034\005\035\005\224\000\000\000\029\001\029\001\
\029\001\029\001\000\000\000\000\029\001\029\001\029\001\029\001\
\029\001\029\001\029\001\029\001\029\001\029\001\029\001\029\001\
\029\001\029\001\029\001\029\001\029\001\000\000\029\001\029\001\
\029\001\029\001\029\001\029\001\029\001\029\001\000\000\000\000\
\000\000\000\000\029\001\029\001\000\000\000\000\029\001\029\001\
\029\001\029\001\029\001\029\001\029\001\029\001\029\001\029\001\
\029\001\029\001\029\001\000\000\029\001\029\001\029\001\029\001\
\000\000\000\000\029\001\029\001\029\001\000\000\029\001\029\001\
\029\001\029\001\029\001\029\001\000\000\029\001\029\001\029\001\
\029\001\029\001\000\000\029\001\029\001\000\000\000\000\000\000\
\029\001\029\001\029\001\029\001\029\001\029\001\029\001\029\001\
\000\000\029\001\000\000\029\001\029\001\000\000\029\001\029\001\
\029\001\029\001\029\001\034\001\029\001\029\001\000\000\029\001\
\029\001\029\001\029\001\000\000\029\001\029\001\000\000\029\001\
\000\000\000\000\000\000\029\001\000\000\060\001\060\001\060\001\
\060\001\060\001\000\000\060\001\060\001\060\001\060\001\060\001\
\060\001\060\001\060\001\060\001\060\001\060\001\060\001\060\001\
\060\001\060\001\060\001\000\000\000\000\060\001\060\001\060\001\
\060\001\060\001\060\001\060\001\060\001\000\000\000\000\000\000\
\000\000\060\001\060\001\000\000\000\000\060\001\060\001\060\001\
\060\001\060\001\060\001\060\001\060\001\060\001\060\001\060\001\
\060\001\060\001\000\000\060\001\060\001\060\001\060\001\000\000\
\000\000\060\001\060\001\060\001\000\000\060\001\060\001\060\001\
\060\001\060\001\060\001\000\000\060\001\060\001\060\001\060\001\
\060\001\000\000\060\001\060\001\000\000\000\000\000\000\060\001\
\060\001\060\001\060\001\060\001\060\001\060\001\060\001\000\000\
\060\001\000\000\060\001\060\001\000\000\060\001\060\001\060\001\
\060\001\060\001\032\001\060\001\060\001\000\000\060\001\060\001\
\060\001\060\001\000\000\060\001\060\001\000\000\060\001\000\000\
\000\000\000\000\060\001\036\001\036\001\036\001\036\001\000\000\
\000\000\036\001\036\001\036\001\036\001\036\001\036\001\036\001\
\036\001\036\001\036\001\036\001\036\001\036\001\036\001\036\001\
\036\001\036\001\000\000\036\001\036\001\036\001\036\001\036\001\
\036\001\036\001\036\001\000\000\000\000\000\000\000\000\036\001\
\036\001\000\000\000\000\036\001\036\001\036\001\036\001\036\001\
\036\001\036\001\036\001\036\001\036\001\036\001\036\001\036\001\
\000\000\036\001\036\001\036\001\036\001\000\000\000\000\036\001\
\036\001\036\001\000\000\036\001\036\001\036\001\036\001\036\001\
\036\001\000\000\036\001\036\001\036\001\036\001\036\001\000\000\
\036\001\036\001\000\000\000\000\000\000\036\001\036\001\036\001\
\036\001\036\001\036\001\036\001\036\001\000\000\036\001\000\000\
\036\001\036\001\000\000\036\001\036\001\036\001\036\001\036\001\
\069\001\036\001\036\001\000\000\036\001\036\001\036\001\036\001\
\000\000\036\001\036\001\000\000\036\001\000\000\000\000\000\000\
\036\001\000\000\000\000\034\001\034\001\034\001\034\001\000\000\
\000\000\034\001\034\001\034\001\034\001\034\001\034\001\034\001\
\034\001\034\001\034\001\034\001\034\001\034\001\034\001\034\001\
\034\001\034\001\000\000\034\001\034\001\034\001\034\001\034\001\
\034\001\034\001\034\001\000\000\000\000\000\000\000\000\034\001\
\034\001\000\000\000\000\034\001\034\001\034\001\034\001\034\001\
\034\001\034\001\034\001\034\001\034\001\034\001\034\001\034\001\
\000\000\034\001\034\001\034\001\034\001\000\000\000\000\034\001\
\034\001\034\001\000\000\034\001\034\001\034\001\034\001\034\001\
\034\001\000\000\034\001\034\001\034\001\034\001\034\001\000\000\
\034\001\034\001\000\000\000\000\000\000\034\001\034\001\034\001\
\034\001\034\001\034\001\034\001\034\001\000\000\034\001\000\000\
\034\001\034\001\000\000\034\001\034\001\034\001\034\001\034\001\
\071\001\034\001\034\001\000\000\034\001\034\001\034\001\034\001\
\000\000\034\001\034\001\000\000\034\001\000\000\000\000\000\000\
\034\001\000\000\032\001\032\001\032\001\032\001\000\000\000\000\
\032\001\032\001\032\001\032\001\032\001\032\001\032\001\032\001\
\032\001\032\001\032\001\032\001\032\001\032\001\032\001\032\001\
\032\001\000\000\032\001\032\001\032\001\032\001\032\001\032\001\
\032\001\032\001\000\000\000\000\000\000\000\000\032\001\032\001\
\000\000\000\000\032\001\032\001\032\001\032\001\032\001\032\001\
\032\001\032\001\032\001\032\001\032\001\032\001\032\001\000\000\
\032\001\032\001\032\001\032\001\000\000\000\000\032\001\032\001\
\032\001\000\000\032\001\032\001\032\001\032\001\032\001\032\001\
\000\000\032\001\032\001\032\001\032\001\032\001\000\000\032\001\
\032\001\000\000\000\000\000\000\032\001\032\001\032\001\032\001\
\032\001\032\001\032\001\032\001\000\000\032\001\000\000\032\001\
\032\001\000\000\032\001\032\001\032\001\032\001\032\001\074\001\
\032\001\032\001\000\000\032\001\032\001\032\001\032\001\000\000\
\032\001\032\001\000\000\032\001\000\000\000\000\000\000\032\001\
\069\001\069\001\069\001\069\001\069\001\000\000\069\001\069\001\
\069\001\069\001\069\001\069\001\069\001\069\001\069\001\069\001\
\069\001\069\001\069\001\069\001\069\001\069\001\000\000\000\000\
\069\001\069\001\069\001\069\001\069\001\069\001\069\001\069\001\
\000\000\000\000\000\000\000\000\069\001\069\001\000\000\000\000\
\069\001\069\001\069\001\069\001\069\001\069\001\069\001\069\001\
\069\001\069\001\069\001\069\001\069\001\000\000\069\001\069\001\
\069\001\069\001\000\000\000\000\069\001\069\001\069\001\000\000\
\069\001\069\001\069\001\069\001\069\001\069\001\000\000\069\001\
\069\001\069\001\069\001\069\001\000\000\069\001\069\001\000\000\
\000\000\000\000\069\001\069\001\069\001\069\001\069\001\069\001\
\069\001\069\001\000\000\069\001\000\000\069\001\069\001\000\000\
\069\001\069\001\069\001\000\000\000\000\021\001\069\001\069\001\
\000\000\069\001\069\001\069\001\069\001\000\000\069\001\069\001\
\000\000\069\001\000\000\000\000\000\000\069\001\000\000\000\000\
\071\001\071\001\071\001\071\001\071\001\000\000\071\001\071\001\
\071\001\071\001\071\001\071\001\071\001\071\001\071\001\071\001\
\071\001\071\001\071\001\071\001\071\001\071\001\000\000\000\000\
\071\001\071\001\071\001\071\001\071\001\071\001\071\001\071\001\
\000\000\000\000\000\000\000\000\071\001\071\001\000\000\000\000\
\071\001\071\001\071\001\071\001\071\001\071\001\071\001\071\001\
\071\001\071\001\071\001\071\001\071\001\000\000\071\001\071\001\
\071\001\071\001\000\000\000\000\071\001\071\001\071\001\000\000\
\071\001\071\001\071\001\071\001\071\001\071\001\000\000\071\001\
\071\001\071\001\071\001\071\001\000\000\071\001\071\001\000\000\
\000\000\000\000\071\001\071\001\071\001\071\001\071\001\071\001\
\071\001\071\001\000\000\071\001\000\000\071\001\071\001\000\000\
\071\001\071\001\071\001\022\001\000\000\000\000\071\001\071\001\
\000\000\071\001\071\001\071\001\071\001\000\000\071\001\071\001\
\000\000\071\001\000\000\000\000\000\000\071\001\000\000\074\001\
\074\001\074\001\074\001\074\001\000\000\074\001\074\001\074\001\
\074\001\074\001\074\001\074\001\074\001\074\001\074\001\074\001\
\074\001\074\001\074\001\074\001\074\001\000\000\000\000\074\001\
\074\001\074\001\074\001\074\001\074\001\074\001\074\001\000\000\
\000\000\000\000\000\000\074\001\074\001\000\000\000\000\074\001\
\074\001\074\001\074\001\074\001\074\001\074\001\074\001\074\001\
\074\001\074\001\074\001\074\001\000\000\074\001\074\001\074\001\
\074\001\000\000\000\000\074\001\074\001\074\001\000\000\074\001\
\074\001\074\001\074\001\074\001\074\001\000\000\074\001\074\001\
\074\001\074\001\074\001\000\000\074\001\074\001\000\000\000\000\
\000\000\074\001\074\001\074\001\074\001\074\001\074\001\074\001\
\074\001\000\000\074\001\000\000\074\001\074\001\000\000\074\001\
\074\001\074\001\223\000\000\000\000\000\074\001\074\001\000\000\
\074\001\074\001\074\001\074\001\000\000\074\001\074\001\000\000\
\074\001\000\000\000\000\000\000\074\001\021\001\021\001\021\001\
\021\001\000\000\000\000\000\000\000\000\021\001\021\001\021\001\
\000\000\000\000\021\001\021\001\021\001\021\001\021\001\021\001\
\021\001\021\001\021\001\021\001\000\000\021\001\021\001\021\001\
\021\001\021\001\021\001\000\000\000\000\000\000\000\000\000\000\
\000\000\021\001\021\001\000\000\000\000\021\001\021\001\021\001\
\021\001\021\001\021\001\021\001\021\001\021\001\000\000\000\000\
\000\000\021\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\021\001\021\001\000\000\021\001\000\000\000\000\
\021\001\021\001\021\001\000\000\021\001\021\001\021\001\021\001\
\021\001\000\000\000\000\000\000\000\000\000\000\000\000\021\001\
\021\001\021\001\021\001\021\001\021\001\021\001\000\000\000\000\
\021\001\000\000\021\001\021\001\000\000\021\001\021\001\021\001\
\021\001\021\001\234\000\021\001\000\000\000\000\021\001\021\001\
\021\001\000\000\000\000\021\001\000\000\000\000\021\001\000\000\
\000\000\000\000\021\001\022\001\022\001\022\001\022\001\000\000\
\000\000\000\000\000\000\022\001\022\001\022\001\000\000\000\000\
\022\001\022\001\022\001\022\001\022\001\022\001\022\001\022\001\
\022\001\022\001\000\000\022\001\022\001\022\001\022\001\022\001\
\022\001\000\000\000\000\000\000\000\000\000\000\000\000\022\001\
\022\001\000\000\000\000\022\001\022\001\022\001\022\001\022\001\
\022\001\022\001\022\001\022\001\000\000\000\000\000\000\022\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\022\001\022\001\000\000\022\001\000\000\000\000\022\001\022\001\
\022\001\000\000\022\001\022\001\022\001\022\001\022\001\000\000\
\000\000\000\000\000\000\000\000\000\000\022\001\022\001\022\001\
\022\001\022\001\022\001\022\001\000\000\000\000\022\001\000\000\
\022\001\022\001\000\000\022\001\022\001\022\001\022\001\022\001\
\235\000\022\001\000\000\000\000\022\001\022\001\022\001\000\000\
\000\000\022\001\000\000\000\000\022\001\000\000\000\000\000\000\
\022\001\000\000\223\000\223\000\223\000\223\000\000\000\000\000\
\000\000\000\000\223\000\223\000\223\000\000\000\000\000\223\000\
\223\000\223\000\223\000\223\000\223\000\223\000\223\000\223\000\
\000\000\000\000\223\000\223\000\223\000\223\000\223\000\223\000\
\000\000\000\000\000\000\000\000\000\000\000\000\223\000\223\000\
\000\000\000\000\223\000\223\000\223\000\223\000\223\000\223\000\
\223\000\223\000\223\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\223\000\
\223\000\000\000\223\000\000\000\000\000\223\000\223\000\223\000\
\000\000\223\000\223\000\223\000\223\000\223\000\000\000\000\000\
\000\000\000\000\000\000\000\000\223\000\000\000\223\000\223\000\
\223\000\223\000\223\000\000\000\000\000\000\000\000\000\223\000\
\223\000\000\000\223\000\223\000\223\000\000\000\236\000\000\000\
\223\000\000\000\000\000\223\000\000\000\223\000\000\000\000\000\
\223\000\000\000\000\000\223\000\000\000\000\000\000\000\223\000\
\000\000\000\000\234\000\234\000\234\000\234\000\000\000\000\000\
\000\000\000\000\234\000\234\000\234\000\000\000\000\000\234\000\
\234\000\234\000\234\000\234\000\000\000\234\000\234\000\234\000\
\000\000\000\000\234\000\234\000\234\000\234\000\234\000\234\000\
\000\000\000\000\000\000\000\000\000\000\000\000\234\000\234\000\
\000\000\000\000\234\000\234\000\234\000\234\000\234\000\234\000\
\234\000\234\000\234\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\234\000\
\234\000\000\000\234\000\000\000\000\000\234\000\234\000\234\000\
\000\000\234\000\234\000\234\000\234\000\234\000\000\000\000\000\
\000\000\000\000\000\000\000\000\234\000\000\000\234\000\234\000\
\234\000\234\000\234\000\000\000\000\000\000\000\000\000\234\000\
\234\000\000\000\234\000\234\000\234\000\234\000\014\001\000\000\
\234\000\000\000\000\000\234\000\000\000\234\000\000\000\000\000\
\234\000\000\000\000\000\234\000\000\000\000\000\000\000\234\000\
\235\000\235\000\235\000\235\000\000\000\000\000\000\000\000\000\
\235\000\235\000\235\000\000\000\000\000\235\000\235\000\235\000\
\235\000\235\000\235\000\235\000\235\000\235\000\000\000\000\000\
\235\000\235\000\235\000\235\000\235\000\235\000\000\000\000\000\
\000\000\000\000\000\000\000\000\235\000\235\000\000\000\000\000\
\235\000\235\000\235\000\235\000\235\000\235\000\235\000\235\000\
\235\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\235\000\235\000\000\000\
\235\000\000\000\000\000\235\000\235\000\235\000\000\000\235\000\
\235\000\235\000\235\000\235\000\000\000\000\000\000\000\000\000\
\000\000\000\000\235\000\000\000\235\000\235\000\235\000\235\000\
\235\000\000\000\000\000\000\000\000\000\235\000\235\000\000\000\
\235\000\235\000\235\000\000\000\015\001\000\000\235\000\000\000\
\000\000\235\000\000\000\235\000\000\000\000\000\235\000\000\000\
\000\000\235\000\000\000\000\000\000\000\235\000\236\000\236\000\
\236\000\236\000\000\000\000\000\000\000\000\000\236\000\236\000\
\236\000\000\000\000\000\236\000\236\000\236\000\236\000\236\000\
\236\000\236\000\236\000\236\000\000\000\000\000\236\000\236\000\
\236\000\236\000\236\000\236\000\000\000\000\000\000\000\000\000\
\000\000\000\000\236\000\236\000\000\000\000\000\236\000\236\000\
\236\000\236\000\236\000\236\000\236\000\236\000\236\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\236\000\236\000\000\000\236\000\000\000\
\000\000\236\000\236\000\236\000\000\000\236\000\236\000\236\000\
\236\000\236\000\000\000\000\000\000\000\000\000\000\000\000\000\
\236\000\000\000\236\000\236\000\236\000\236\000\236\000\000\000\
\000\000\000\000\000\000\236\000\236\000\000\000\236\000\236\000\
\236\000\000\000\246\000\000\000\236\000\000\000\000\000\236\000\
\000\000\236\000\000\000\000\000\236\000\000\000\000\000\236\000\
\000\000\000\000\000\000\236\000\000\000\000\000\014\001\014\001\
\014\001\014\001\000\000\000\000\000\000\000\000\014\001\014\001\
\014\001\000\000\000\000\014\001\014\001\014\001\014\001\014\001\
\014\001\014\001\014\001\014\001\000\000\000\000\014\001\014\001\
\014\001\014\001\014\001\014\001\000\000\000\000\000\000\000\000\
\000\000\000\000\014\001\014\001\000\000\000\000\014\001\014\001\
\014\001\014\001\014\001\014\001\014\001\014\001\014\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\014\001\014\001\000\000\014\001\000\000\
\000\000\014\001\014\001\014\001\000\000\014\001\014\001\014\001\
\014\001\014\001\000\000\000\000\000\000\000\000\000\000\000\000\
\014\001\000\000\014\001\014\001\014\001\014\001\014\001\000\000\
\000\000\000\000\000\000\014\001\014\001\000\000\014\001\014\001\
\014\001\247\000\000\000\000\000\014\001\000\000\000\000\014\001\
\000\000\014\001\000\000\000\000\014\001\000\000\000\000\014\001\
\000\000\000\000\000\000\014\001\015\001\015\001\015\001\015\001\
\000\000\000\000\000\000\000\000\015\001\015\001\015\001\000\000\
\000\000\015\001\015\001\015\001\015\001\015\001\015\001\015\001\
\015\001\015\001\000\000\000\000\015\001\015\001\015\001\015\001\
\015\001\015\001\000\000\000\000\000\000\000\000\000\000\000\000\
\015\001\015\001\000\000\000\000\015\001\015\001\015\001\015\001\
\015\001\015\001\015\001\015\001\015\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\015\001\015\001\000\000\015\001\000\000\000\000\015\001\
\015\001\015\001\000\000\015\001\015\001\015\001\015\001\015\001\
\000\000\000\000\000\000\000\000\000\000\000\000\015\001\000\000\
\015\001\015\001\015\001\015\001\015\001\000\000\000\000\000\000\
\000\000\015\001\015\001\000\000\015\001\015\001\015\001\254\000\
\000\000\000\000\015\001\000\000\000\000\015\001\000\000\015\001\
\000\000\000\000\015\001\000\000\000\000\015\001\000\000\000\000\
\000\000\015\001\246\000\246\000\246\000\246\000\000\000\000\000\
\000\000\000\000\246\000\246\000\246\000\000\000\000\000\246\000\
\246\000\246\000\246\000\246\000\246\000\246\000\246\000\246\000\
\000\000\000\000\246\000\246\000\246\000\246\000\246\000\246\000\
\000\000\000\000\000\000\000\000\000\000\000\000\246\000\246\000\
\000\000\000\000\246\000\246\000\246\000\246\000\246\000\246\000\
\000\000\246\000\246\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\246\000\
\246\000\000\000\246\000\000\000\000\000\246\000\246\000\246\000\
\000\000\246\000\246\000\246\000\246\000\246\000\000\000\000\000\
\000\000\000\000\000\000\000\000\246\000\000\000\246\000\246\000\
\246\000\246\000\246\000\000\000\000\000\000\000\000\000\246\000\
\246\000\000\000\246\000\246\000\246\000\246\000\253\000\000\000\
\246\000\000\000\000\000\246\000\000\000\246\000\000\000\000\000\
\246\000\000\000\000\000\246\000\000\000\000\000\000\000\246\000\
\000\000\247\000\247\000\247\000\247\000\000\000\000\000\000\000\
\000\000\247\000\247\000\247\000\000\000\000\000\247\000\247\000\
\247\000\247\000\247\000\247\000\247\000\247\000\247\000\000\000\
\000\000\247\000\247\000\247\000\247\000\247\000\247\000\000\000\
\000\000\000\000\000\000\000\000\000\000\247\000\247\000\000\000\
\000\000\247\000\247\000\247\000\247\000\247\000\247\000\000\000\
\247\000\247\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\247\000\247\000\
\000\000\247\000\000\000\000\000\247\000\247\000\247\000\000\000\
\247\000\247\000\247\000\247\000\247\000\000\000\000\000\000\000\
\000\000\000\000\000\000\247\000\000\000\247\000\247\000\247\000\
\247\000\247\000\000\000\000\000\000\000\000\000\247\000\247\000\
\000\000\247\000\247\000\247\000\247\000\228\000\000\000\247\000\
\000\000\000\000\247\000\000\000\247\000\000\000\000\000\247\000\
\000\000\000\000\247\000\000\000\000\000\000\000\247\000\254\000\
\254\000\254\000\254\000\000\000\000\000\000\000\000\000\254\000\
\254\000\254\000\000\000\000\000\254\000\254\000\254\000\254\000\
\254\000\254\000\254\000\254\000\254\000\000\000\000\000\254\000\
\254\000\254\000\254\000\254\000\254\000\000\000\000\000\000\000\
\000\000\000\000\000\000\254\000\254\000\000\000\000\000\254\000\
\254\000\254\000\254\000\254\000\254\000\000\000\254\000\254\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\254\000\254\000\000\000\254\000\
\000\000\000\000\254\000\254\000\254\000\000\000\254\000\254\000\
\254\000\254\000\254\000\000\000\000\000\000\000\000\000\000\000\
\000\000\254\000\000\000\254\000\254\000\254\000\254\000\254\000\
\000\000\000\000\000\000\000\000\254\000\254\000\000\000\254\000\
\254\000\254\000\254\000\231\000\000\000\254\000\000\000\000\000\
\254\000\000\000\254\000\000\000\000\000\254\000\000\000\000\000\
\254\000\000\000\000\000\000\000\254\000\000\000\253\000\253\000\
\253\000\253\000\000\000\000\000\000\000\000\000\253\000\253\000\
\253\000\000\000\000\000\253\000\253\000\253\000\253\000\253\000\
\253\000\253\000\253\000\253\000\000\000\000\000\253\000\253\000\
\253\000\253\000\253\000\253\000\000\000\000\000\000\000\000\000\
\000\000\000\000\253\000\253\000\000\000\000\000\253\000\253\000\
\253\000\253\000\253\000\253\000\000\000\253\000\253\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\253\000\253\000\000\000\253\000\000\000\
\000\000\253\000\253\000\253\000\000\000\253\000\253\000\253\000\
\253\000\253\000\000\000\000\000\000\000\000\000\000\000\000\000\
\253\000\000\000\253\000\253\000\253\000\253\000\253\000\000\000\
\000\000\000\000\000\000\253\000\253\000\000\000\253\000\253\000\
\253\000\253\000\232\000\000\000\253\000\000\000\000\000\253\000\
\000\000\253\000\000\000\000\000\253\000\000\000\000\000\253\000\
\000\000\000\000\000\000\253\000\000\000\228\000\228\000\228\000\
\228\000\000\000\000\000\000\000\000\000\000\000\228\000\228\000\
\000\000\000\000\228\000\228\000\228\000\228\000\228\000\228\000\
\228\000\228\000\228\000\000\000\000\000\228\000\228\000\228\000\
\228\000\228\000\228\000\000\000\000\000\000\000\000\000\000\000\
\000\000\228\000\228\000\000\000\000\000\228\000\228\000\228\000\
\228\000\228\000\228\000\228\000\228\000\228\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\228\000\228\000\000\000\228\000\000\000\000\000\
\228\000\228\000\228\000\000\000\228\000\228\000\228\000\228\000\
\228\000\000\000\000\000\000\000\000\000\000\000\000\000\228\000\
\000\000\228\000\228\000\228\000\228\000\228\000\000\000\000\000\
\000\000\000\000\228\000\228\000\000\000\228\000\228\000\228\000\
\228\000\245\000\000\000\228\000\000\000\000\000\228\000\000\000\
\228\000\000\000\000\000\228\000\000\000\000\000\228\000\000\000\
\000\000\000\000\228\000\231\000\231\000\231\000\231\000\000\000\
\000\000\000\000\000\000\000\000\231\000\231\000\000\000\000\000\
\231\000\231\000\231\000\231\000\231\000\231\000\231\000\231\000\
\231\000\000\000\000\000\231\000\231\000\231\000\231\000\231\000\
\231\000\000\000\000\000\000\000\000\000\000\000\000\000\231\000\
\231\000\000\000\000\000\231\000\231\000\231\000\231\000\231\000\
\231\000\231\000\231\000\231\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\231\000\231\000\000\000\231\000\000\000\000\000\231\000\231\000\
\231\000\000\000\231\000\231\000\231\000\231\000\231\000\000\000\
\000\000\000\000\000\000\000\000\000\000\231\000\000\000\231\000\
\231\000\231\000\231\000\231\000\000\000\000\000\000\000\000\000\
\231\000\231\000\000\000\231\000\231\000\231\000\231\000\251\000\
\000\000\231\000\000\000\000\000\231\000\000\000\231\000\000\000\
\000\000\231\000\000\000\000\000\231\000\000\000\000\000\000\000\
\231\000\000\000\232\000\232\000\232\000\232\000\000\000\000\000\
\000\000\000\000\000\000\232\000\232\000\000\000\000\000\232\000\
\232\000\232\000\232\000\232\000\232\000\232\000\232\000\232\000\
\000\000\000\000\232\000\232\000\232\000\232\000\232\000\232\000\
\000\000\000\000\000\000\000\000\000\000\000\000\232\000\232\000\
\000\000\000\000\232\000\232\000\232\000\232\000\232\000\232\000\
\232\000\232\000\232\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\232\000\
\232\000\000\000\232\000\000\000\000\000\232\000\232\000\232\000\
\000\000\232\000\232\000\232\000\232\000\232\000\000\000\000\000\
\000\000\000\000\000\000\000\000\232\000\000\000\232\000\232\000\
\232\000\232\000\232\000\000\000\000\000\000\000\000\000\232\000\
\232\000\000\000\232\000\232\000\232\000\232\000\252\000\000\000\
\232\000\000\000\000\000\232\000\000\000\232\000\000\000\000\000\
\232\000\000\000\000\000\232\000\000\000\000\000\000\000\232\000\
\000\000\245\000\245\000\245\000\245\000\000\000\000\000\000\000\
\000\000\245\000\245\000\245\000\000\000\000\000\245\000\245\000\
\245\000\245\000\245\000\245\000\245\000\245\000\245\000\000\000\
\000\000\245\000\245\000\245\000\245\000\245\000\245\000\000\000\
\000\000\000\000\000\000\000\000\000\000\245\000\245\000\000\000\
\000\000\245\000\245\000\245\000\245\000\245\000\000\000\000\000\
\245\000\245\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\245\000\245\000\
\000\000\245\000\000\000\000\000\245\000\245\000\245\000\000\000\
\245\000\245\000\245\000\245\000\245\000\000\000\000\000\000\000\
\000\000\000\000\000\000\245\000\000\000\245\000\000\000\245\000\
\245\000\245\000\000\000\000\000\000\000\000\000\245\000\245\000\
\000\000\245\000\245\000\245\000\245\000\248\000\000\000\000\000\
\000\000\000\000\245\000\000\000\245\000\000\000\000\000\245\000\
\000\000\000\000\245\000\000\000\000\000\000\000\245\000\251\000\
\251\000\251\000\251\000\000\000\000\000\000\000\000\000\251\000\
\251\000\251\000\000\000\000\000\251\000\251\000\251\000\251\000\
\251\000\251\000\251\000\251\000\251\000\000\000\000\000\251\000\
\251\000\251\000\251\000\251\000\251\000\000\000\000\000\000\000\
\000\000\000\000\000\000\251\000\251\000\000\000\000\000\251\000\
\251\000\251\000\251\000\251\000\000\000\000\000\251\000\251\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\251\000\251\000\000\000\251\000\
\000\000\000\000\251\000\251\000\251\000\000\000\251\000\251\000\
\251\000\251\000\251\000\000\000\000\000\000\000\000\000\000\000\
\000\000\251\000\000\000\251\000\000\000\251\000\251\000\251\000\
\000\000\000\000\000\000\000\000\251\000\251\000\000\000\251\000\
\251\000\251\000\251\000\249\000\000\000\000\000\000\000\000\000\
\251\000\000\000\251\000\000\000\000\000\251\000\000\000\000\000\
\251\000\000\000\000\000\000\000\251\000\000\000\252\000\252\000\
\252\000\252\000\000\000\000\000\000\000\000\000\252\000\252\000\
\252\000\000\000\000\000\252\000\252\000\252\000\252\000\252\000\
\252\000\252\000\252\000\252\000\000\000\000\000\252\000\252\000\
\252\000\252\000\252\000\252\000\000\000\000\000\000\000\000\000\
\000\000\000\000\252\000\252\000\000\000\000\000\252\000\252\000\
\252\000\252\000\252\000\000\000\000\000\252\000\252\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\252\000\252\000\000\000\252\000\000\000\
\000\000\252\000\252\000\252\000\000\000\252\000\252\000\252\000\
\252\000\252\000\000\000\000\000\000\000\000\000\000\000\000\000\
\252\000\000\000\252\000\000\000\252\000\252\000\252\000\000\000\
\000\000\000\000\000\000\252\000\252\000\000\000\252\000\252\000\
\252\000\252\000\250\000\000\000\000\000\000\000\000\000\252\000\
\000\000\252\000\000\000\000\000\252\000\000\000\000\000\252\000\
\000\000\000\000\000\000\252\000\000\000\248\000\248\000\248\000\
\248\000\000\000\000\000\000\000\000\000\248\000\248\000\248\000\
\000\000\000\000\248\000\248\000\248\000\248\000\248\000\248\000\
\248\000\248\000\248\000\000\000\000\000\248\000\248\000\248\000\
\248\000\248\000\248\000\000\000\000\000\000\000\000\000\000\000\
\000\000\248\000\248\000\000\000\000\000\248\000\248\000\248\000\
\248\000\248\000\000\000\000\000\248\000\248\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\248\000\248\000\000\000\248\000\000\000\000\000\
\248\000\248\000\248\000\000\000\248\000\248\000\248\000\248\000\
\248\000\000\000\000\000\000\000\000\000\000\000\000\000\248\000\
\000\000\248\000\000\000\248\000\248\000\248\000\000\000\000\000\
\000\000\000\000\248\000\248\000\000\000\248\000\248\000\248\000\
\248\000\204\000\000\000\000\000\000\000\000\000\248\000\000\000\
\248\000\000\000\000\000\248\000\000\000\000\000\248\000\000\000\
\000\000\000\000\248\000\249\000\249\000\249\000\249\000\000\000\
\000\000\000\000\000\000\249\000\249\000\249\000\000\000\000\000\
\249\000\249\000\249\000\249\000\249\000\249\000\249\000\249\000\
\249\000\000\000\000\000\249\000\249\000\249\000\249\000\249\000\
\249\000\000\000\000\000\000\000\000\000\000\000\000\000\249\000\
\249\000\000\000\000\000\249\000\249\000\249\000\249\000\249\000\
\000\000\000\000\249\000\249\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\249\000\249\000\000\000\249\000\000\000\000\000\249\000\249\000\
\249\000\000\000\249\000\249\000\249\000\249\000\249\000\000\000\
\000\000\000\000\000\000\000\000\000\000\249\000\000\000\249\000\
\000\000\249\000\249\000\249\000\000\000\000\000\000\000\000\000\
\249\000\249\000\000\000\249\000\249\000\249\000\249\000\255\000\
\000\000\000\000\000\000\000\000\249\000\000\000\249\000\000\000\
\000\000\249\000\000\000\000\000\249\000\000\000\000\000\000\000\
\249\000\000\000\250\000\250\000\250\000\250\000\000\000\000\000\
\000\000\000\000\250\000\250\000\250\000\000\000\000\000\250\000\
\250\000\250\000\250\000\250\000\250\000\250\000\250\000\250\000\
\000\000\000\000\250\000\250\000\250\000\250\000\250\000\250\000\
\000\000\000\000\000\000\000\000\000\000\000\000\250\000\250\000\
\000\000\000\000\250\000\250\000\250\000\250\000\250\000\000\000\
\000\000\250\000\250\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\250\000\
\250\000\000\000\250\000\000\000\000\000\250\000\250\000\250\000\
\000\000\250\000\250\000\250\000\250\000\250\000\000\000\000\000\
\000\000\000\000\000\000\000\000\250\000\000\000\250\000\000\000\
\250\000\250\000\250\000\000\000\000\000\000\000\000\000\250\000\
\250\000\000\000\250\000\250\000\250\000\250\000\001\001\000\000\
\000\000\000\000\000\000\250\000\000\000\250\000\000\000\000\000\
\250\000\000\000\000\000\250\000\000\000\000\000\000\000\250\000\
\000\000\204\000\204\000\204\000\204\000\000\000\000\000\000\000\
\000\000\204\000\204\000\204\000\000\000\000\000\204\000\204\000\
\204\000\204\000\204\000\204\000\204\000\204\000\204\000\000\000\
\000\000\204\000\204\000\204\000\204\000\204\000\204\000\000\000\
\000\000\000\000\000\000\000\000\000\000\204\000\204\000\000\000\
\000\000\204\000\204\000\204\000\204\000\204\000\204\000\204\000\
\204\000\204\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\204\000\204\000\
\000\000\000\000\000\000\000\000\204\000\204\000\204\000\000\000\
\204\000\000\000\000\000\204\000\204\000\000\000\000\000\000\000\
\000\000\000\000\000\000\204\000\000\000\204\000\204\000\000\000\
\000\000\204\000\000\000\000\000\000\000\000\000\204\000\204\000\
\000\000\204\000\204\000\204\000\204\000\243\000\000\000\204\000\
\000\000\000\000\204\000\000\000\204\000\000\000\000\000\204\000\
\000\000\000\000\204\000\000\000\000\000\000\000\204\000\255\000\
\255\000\255\000\255\000\000\000\000\000\000\000\000\000\255\000\
\255\000\255\000\000\000\000\000\255\000\255\000\000\000\255\000\
\255\000\255\000\255\000\255\000\255\000\000\000\000\000\255\000\
\255\000\255\000\255\000\255\000\255\000\000\000\000\000\000\000\
\000\000\000\000\000\000\255\000\255\000\000\000\000\000\255\000\
\255\000\255\000\000\000\000\000\000\000\000\000\255\000\255\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\255\000\255\000\000\000\255\000\
\000\000\000\000\000\000\255\000\255\000\000\000\255\000\000\000\
\000\000\255\000\255\000\000\000\000\000\000\000\000\000\000\000\
\000\000\255\000\000\000\255\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\255\000\255\000\000\000\255\000\
\255\000\255\000\255\000\244\000\000\000\000\000\000\000\000\000\
\255\000\000\000\255\000\000\000\000\000\255\000\000\000\000\000\
\255\000\000\000\000\000\000\000\255\000\000\000\001\001\001\001\
\001\001\001\001\000\000\000\000\000\000\000\000\001\001\001\001\
\001\001\000\000\000\000\001\001\001\001\000\000\001\001\001\001\
\001\001\001\001\001\001\001\001\000\000\000\000\001\001\001\001\
\001\001\001\001\001\001\001\001\000\000\000\000\000\000\000\000\
\000\000\000\000\001\001\001\001\000\000\000\000\001\001\001\001\
\001\001\000\000\000\000\000\000\000\000\001\001\001\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\001\001\001\001\000\000\001\001\000\000\
\000\000\000\000\001\001\001\001\000\000\001\001\000\000\000\000\
\001\001\001\001\000\000\000\000\000\000\000\000\000\000\000\000\
\001\001\000\000\001\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\001\001\001\001\000\000\001\001\001\001\
\001\001\001\001\000\001\000\000\000\000\000\000\000\000\001\001\
\000\000\001\001\000\000\000\000\001\001\000\000\000\000\001\001\
\000\000\000\000\000\000\001\001\000\000\243\000\243\000\243\000\
\243\000\000\000\000\000\000\000\000\000\243\000\243\000\243\000\
\000\000\000\000\243\000\243\000\000\000\243\000\243\000\243\000\
\243\000\243\000\243\000\000\000\000\000\243\000\243\000\243\000\
\243\000\243\000\243\000\000\000\000\000\000\000\000\000\000\000\
\000\000\243\000\243\000\000\000\000\000\243\000\243\000\243\000\
\000\000\000\000\000\000\000\000\243\000\243\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\243\000\243\000\000\000\243\000\000\000\000\000\
\000\000\243\000\243\000\000\000\243\000\000\000\000\000\243\000\
\243\000\000\000\000\000\000\000\000\000\000\000\000\000\243\000\
\000\000\243\000\000\000\000\000\005\001\000\000\000\000\000\000\
\000\000\000\000\243\000\243\000\000\000\243\000\243\000\243\000\
\243\000\000\000\000\000\000\000\000\000\000\000\243\000\000\000\
\243\000\000\000\000\000\243\000\000\000\000\000\243\000\000\000\
\000\000\000\000\243\000\244\000\244\000\244\000\244\000\000\000\
\000\000\000\000\000\000\244\000\244\000\244\000\000\000\000\000\
\244\000\244\000\000\000\244\000\244\000\244\000\244\000\244\000\
\244\000\000\000\000\000\244\000\244\000\244\000\244\000\244\000\
\244\000\000\000\000\000\000\000\000\000\000\000\000\000\244\000\
\244\000\000\000\000\000\244\000\244\000\244\000\000\000\000\000\
\000\000\000\000\244\000\244\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\244\000\244\000\000\000\244\000\000\000\000\000\000\000\244\000\
\244\000\000\000\244\000\000\000\000\000\244\000\244\000\000\000\
\000\000\000\000\000\000\004\001\000\000\244\000\000\000\244\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\244\000\244\000\000\000\244\000\244\000\244\000\244\000\000\000\
\000\000\000\000\000\000\000\000\244\000\000\000\244\000\000\000\
\000\000\244\000\000\000\000\000\244\000\000\000\000\000\000\000\
\244\000\000\000\000\001\000\001\000\001\000\001\000\000\000\000\
\000\000\000\000\000\001\000\001\000\001\000\000\000\000\000\001\
\000\001\000\000\000\001\000\001\000\001\000\001\000\001\000\001\
\000\000\000\000\000\001\000\001\000\001\000\001\000\001\000\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\001\000\001\
\000\000\000\000\000\001\000\001\000\001\000\000\000\000\000\000\
\000\000\000\001\000\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\001\
\000\001\000\000\000\001\000\000\000\000\100\001\000\001\000\001\
\000\000\000\001\000\000\000\000\000\001\000\001\000\000\000\000\
\000\000\000\000\000\000\000\000\000\001\000\000\000\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\001\
\000\001\000\000\000\001\000\001\000\001\000\001\000\000\000\000\
\000\000\000\000\000\000\000\001\005\001\000\001\000\000\005\001\
\000\001\000\000\000\000\000\001\005\001\005\001\005\001\000\001\
\000\000\005\001\005\001\000\000\005\001\005\001\005\001\005\001\
\005\001\005\001\000\000\000\000\005\001\005\001\005\001\000\000\
\005\001\005\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\005\001\000\000\000\000\005\001\005\001\000\000\000\000\
\000\000\000\000\000\000\005\001\005\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\005\001\000\000\000\000\005\001\000\000\000\000\002\001\
\005\001\005\001\000\000\005\001\000\000\000\000\005\001\005\001\
\000\000\000\000\000\000\000\000\000\000\000\000\005\001\000\000\
\005\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\005\001\005\001\000\000\005\001\005\001\005\001\005\001\
\000\000\000\000\000\000\000\000\000\000\005\001\000\000\005\001\
\000\000\000\000\005\001\004\001\000\000\005\001\004\001\000\000\
\000\000\005\001\000\000\004\001\004\001\004\001\000\000\000\000\
\004\001\004\001\000\000\004\001\004\001\004\001\004\001\004\001\
\004\001\000\000\000\000\004\001\004\001\004\001\000\000\004\001\
\004\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\004\001\000\000\000\000\004\001\004\001\000\000\000\000\000\000\
\000\000\000\000\004\001\004\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\004\001\099\001\000\000\004\001\000\000\000\000\000\000\004\001\
\004\001\000\000\004\001\000\000\000\000\004\001\004\001\000\000\
\000\000\000\000\000\000\000\000\000\000\004\001\000\000\004\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\004\001\004\001\000\000\004\001\004\001\004\001\004\001\000\000\
\000\000\000\000\000\000\000\000\004\001\100\001\004\001\000\000\
\100\001\004\001\000\000\000\000\004\001\100\001\000\000\100\001\
\004\001\000\000\100\001\100\001\000\000\100\001\100\001\100\001\
\100\001\100\001\100\001\000\000\000\000\100\001\100\001\100\001\
\000\000\100\001\100\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\100\001\000\000\000\000\100\001\100\001\000\000\
\000\000\000\000\000\000\000\000\100\001\100\001\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\009\001\000\000\
\000\000\000\000\100\001\000\000\000\000\100\001\000\000\000\000\
\000\000\100\001\100\001\000\000\100\001\000\000\000\000\100\001\
\100\001\000\000\000\000\000\000\000\000\000\000\000\000\100\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\100\001\100\001\000\000\100\001\100\001\100\001\
\100\001\000\000\000\000\000\000\000\000\000\000\100\001\002\001\
\100\001\000\000\002\001\100\001\000\000\000\000\100\001\002\001\
\000\000\002\001\100\001\000\000\002\001\002\001\000\000\002\001\
\002\001\002\001\002\001\002\001\002\001\000\000\000\000\002\001\
\002\001\002\001\000\000\002\001\002\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\002\001\000\000\000\000\002\001\
\002\001\000\000\000\000\000\000\000\000\000\000\002\001\002\001\
\000\000\000\000\000\000\237\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\002\001\000\000\000\000\002\001\
\000\000\000\000\000\000\002\001\002\001\000\000\002\001\000\000\
\000\000\002\001\002\001\000\000\000\000\000\000\000\000\000\000\
\000\000\002\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\002\001\002\001\000\000\002\001\
\002\001\002\001\002\001\000\000\000\000\000\000\000\000\000\000\
\002\001\099\001\002\001\000\000\099\001\002\001\000\000\000\000\
\002\001\099\001\000\000\099\001\002\001\000\000\099\001\099\001\
\000\000\099\001\099\001\099\001\099\001\099\001\099\001\000\000\
\000\000\099\001\099\001\099\001\000\000\099\001\099\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\099\001\000\000\
\000\000\099\001\099\001\000\000\000\000\000\000\000\000\000\000\
\099\001\099\001\000\000\000\000\000\000\012\001\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\099\001\000\000\
\000\000\099\001\000\000\000\000\000\000\099\001\099\001\000\000\
\099\001\000\000\000\000\099\001\099\001\000\000\000\000\000\000\
\000\000\000\000\000\000\099\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\099\001\099\001\
\000\000\099\001\099\001\099\001\099\001\000\000\009\001\000\000\
\000\000\009\001\099\001\000\000\099\001\000\000\009\001\099\001\
\009\001\000\000\099\001\009\001\009\001\000\000\099\001\009\001\
\000\000\009\001\009\001\009\001\000\000\000\000\009\001\009\001\
\009\001\000\000\009\001\009\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\009\001\000\000\000\000\009\001\009\001\
\000\000\000\000\000\000\000\000\000\000\009\001\009\001\000\000\
\000\000\000\000\011\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\009\001\000\000\000\000\009\001\000\000\
\000\000\000\000\009\001\009\001\000\000\009\001\000\000\000\000\
\009\001\009\001\000\000\000\000\000\000\000\000\000\000\000\000\
\009\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\009\001\009\001\000\000\009\001\009\001\
\009\001\009\001\000\000\237\000\000\000\000\000\237\000\009\001\
\000\000\009\001\000\000\237\000\009\001\237\000\000\000\009\001\
\237\000\237\000\000\000\009\001\237\000\000\000\237\000\237\000\
\237\000\000\000\000\000\237\000\237\000\237\000\000\000\237\000\
\237\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\237\000\000\000\000\000\237\000\237\000\000\000\000\000\000\000\
\000\000\000\000\237\000\237\000\000\000\000\000\000\000\010\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\237\000\000\000\000\000\237\000\000\000\000\000\000\000\237\000\
\237\000\000\000\237\000\000\000\000\000\237\000\237\000\000\000\
\000\000\000\000\000\000\000\000\000\000\237\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\237\000\237\000\000\000\237\000\237\000\237\000\237\000\000\000\
\000\000\000\000\000\000\000\000\237\000\012\001\237\000\000\000\
\012\001\237\000\000\000\000\000\237\000\012\001\000\000\012\001\
\237\000\000\000\012\001\012\001\000\000\000\000\012\001\000\000\
\012\001\012\001\012\001\000\000\000\000\012\001\012\001\012\001\
\000\000\012\001\012\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\012\001\000\000\000\000\012\001\012\001\000\000\
\000\000\000\000\000\000\000\000\012\001\012\001\000\000\000\000\
\000\000\203\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\012\001\000\000\000\000\012\001\000\000\000\000\
\000\000\012\001\012\001\000\000\012\001\000\000\000\000\012\001\
\012\001\000\000\000\000\000\000\000\000\000\000\000\000\012\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\012\001\012\001\000\000\012\001\012\001\012\001\
\012\001\000\000\011\001\000\000\000\000\011\001\012\001\000\000\
\012\001\000\000\011\001\012\001\011\001\000\000\012\001\011\001\
\011\001\000\000\012\001\011\001\000\000\011\001\011\001\011\001\
\000\000\000\000\011\001\011\001\011\001\000\000\011\001\011\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\011\001\
\000\000\000\000\011\001\011\001\000\000\000\000\000\000\000\000\
\000\000\011\001\011\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\011\001\
\000\000\121\002\011\001\000\000\000\000\000\000\011\001\011\001\
\000\000\011\001\116\000\000\000\011\001\011\001\000\000\000\000\
\000\000\000\000\000\000\000\000\011\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\011\001\
\011\001\000\000\011\001\011\001\011\001\011\001\000\000\010\001\
\000\000\000\000\010\001\011\001\000\000\011\001\000\000\010\001\
\011\001\010\001\000\000\011\001\010\001\010\001\000\000\011\001\
\010\001\000\000\010\001\010\001\010\001\000\000\000\000\010\001\
\010\001\010\001\000\000\010\001\010\001\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\010\001\000\000\000\000\010\001\
\010\001\000\000\000\000\000\000\000\000\000\000\010\001\010\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\010\001\000\000\000\000\010\001\
\000\000\000\000\000\000\010\001\010\001\000\000\010\001\000\000\
\000\000\010\001\010\001\000\000\238\000\000\000\000\000\000\000\
\000\000\010\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\010\001\010\001\000\000\010\001\
\010\001\010\001\010\001\000\000\000\000\000\000\000\000\000\000\
\010\001\203\000\010\001\000\000\203\000\010\001\000\000\000\000\
\010\001\203\000\000\000\203\000\010\001\000\000\203\000\203\000\
\000\000\000\000\203\000\000\000\203\000\203\000\203\000\000\000\
\000\000\203\000\203\000\203\000\000\000\203\000\203\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\203\000\000\000\
\000\000\203\000\203\000\000\000\000\000\000\000\000\000\000\000\
\203\000\203\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\203\000\000\000\
\000\000\203\000\000\000\000\000\000\000\203\000\203\000\000\000\
\203\000\000\000\000\000\203\000\203\000\000\000\000\000\000\000\
\000\000\000\000\000\000\203\000\044\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\203\000\203\000\
\000\000\203\000\000\000\203\000\203\000\000\000\000\000\000\000\
\000\000\000\000\203\000\000\000\203\000\000\000\000\000\203\000\
\000\000\121\002\203\000\121\002\121\002\121\002\203\000\000\000\
\000\000\121\002\116\000\000\000\000\000\000\000\121\002\000\000\
\000\000\000\000\121\002\121\002\121\002\000\000\000\000\116\000\
\000\000\000\000\000\000\121\002\121\002\121\002\121\002\000\000\
\000\000\000\000\000\000\000\000\116\000\121\002\116\000\116\000\
\000\000\000\000\121\002\000\000\000\000\000\000\000\000\000\000\
\121\002\121\002\137\000\116\000\138\000\139\000\032\000\000\000\
\140\000\000\000\000\000\177\001\243\002\000\000\121\002\000\000\
\000\000\121\002\121\002\000\000\121\002\121\002\121\002\116\000\
\121\002\004\002\116\000\121\002\121\002\000\000\116\000\116\000\
\000\000\000\000\000\000\121\002\000\000\116\000\145\000\000\000\
\000\000\000\000\000\000\000\000\116\000\146\000\121\002\121\002\
\000\000\121\002\121\002\121\002\121\002\000\000\000\000\121\002\
\116\000\147\000\148\000\000\000\116\000\116\000\000\000\121\002\
\121\002\000\000\121\002\000\000\238\000\000\000\121\002\238\000\
\116\000\000\000\000\000\116\000\238\000\000\000\238\000\000\000\
\000\000\238\000\238\000\000\000\000\000\238\000\000\000\238\000\
\238\000\238\000\000\000\000\000\238\000\000\000\238\000\000\000\
\238\000\238\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\238\000\000\000\000\000\238\000\238\000\000\000\000\000\
\000\000\000\000\000\000\238\000\238\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\005\002\000\000\
\000\000\238\000\000\000\000\000\238\000\000\000\000\000\000\000\
\238\000\238\000\000\000\238\000\000\000\000\000\238\000\238\000\
\000\000\000\000\000\000\000\000\000\000\000\000\238\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\238\000\238\000\000\000\238\000\238\000\238\000\238\000\
\000\000\000\000\000\000\000\000\000\000\238\000\000\000\238\000\
\000\000\000\000\238\000\000\000\044\002\238\000\044\002\044\002\
\044\002\238\000\000\000\000\000\044\002\000\000\000\000\000\000\
\000\000\044\002\000\000\000\000\000\000\044\002\044\002\044\002\
\000\000\000\000\000\000\000\000\000\000\000\000\044\002\044\002\
\044\002\044\002\000\000\000\000\000\000\000\000\000\000\000\000\
\044\002\000\000\000\000\000\000\000\000\044\002\000\000\000\000\
\000\000\000\000\000\000\044\002\044\002\045\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\044\002\000\000\000\000\044\002\000\000\000\000\044\002\
\044\002\044\002\000\000\044\002\000\000\000\000\044\002\044\002\
\000\000\000\000\000\000\000\000\000\000\000\000\044\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\044\002\044\002\000\000\044\002\044\002\044\002\044\002\
\000\000\004\002\000\000\004\002\004\002\004\002\000\000\000\000\
\000\000\004\002\044\002\000\000\000\000\044\002\004\002\000\000\
\000\000\044\002\004\002\004\002\004\002\000\000\000\000\000\000\
\000\000\000\000\000\000\004\002\004\002\004\002\004\002\000\000\
\000\000\000\000\000\000\000\000\000\000\004\002\000\000\000\000\
\000\000\000\000\004\002\000\000\000\000\000\000\000\000\000\000\
\004\002\004\002\003\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\004\002\000\000\
\000\000\004\002\000\000\000\000\004\002\004\002\004\002\000\000\
\004\002\000\000\000\000\004\002\004\002\000\000\000\000\000\000\
\000\000\000\000\000\000\004\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\004\002\004\002\
\000\000\004\002\004\002\004\002\000\000\000\000\005\002\004\002\
\005\002\005\002\005\002\000\000\000\000\000\000\005\002\004\002\
\000\000\000\000\004\002\005\002\000\000\000\000\004\002\005\002\
\005\002\005\002\000\000\000\000\000\000\000\000\000\000\000\000\
\005\002\005\002\005\002\005\002\000\000\000\000\000\000\000\000\
\000\000\000\000\005\002\000\000\000\000\000\000\000\000\005\002\
\000\000\000\000\000\000\000\000\000\000\005\002\005\002\001\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\005\002\000\000\000\000\005\002\000\000\
\000\000\005\002\005\002\005\002\000\000\005\002\000\000\000\000\
\005\002\005\002\000\000\000\000\000\000\000\000\000\000\000\000\
\005\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\005\002\005\002\000\000\005\002\005\002\
\005\002\000\000\000\000\000\000\005\002\045\002\000\000\045\002\
\045\002\045\002\000\000\000\000\005\002\045\002\000\000\005\002\
\000\000\000\000\045\002\005\002\000\000\000\000\045\002\045\002\
\045\002\000\000\000\000\000\000\000\000\000\000\000\000\045\002\
\045\002\045\002\045\002\000\000\000\000\000\000\000\000\000\000\
\000\000\045\002\000\000\000\000\000\000\000\000\045\002\000\000\
\000\000\000\000\000\000\000\000\045\002\045\002\002\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\045\002\000\000\000\000\045\002\000\000\000\000\
\045\002\045\002\045\002\000\000\045\002\000\000\000\000\045\002\
\045\002\000\000\000\000\000\000\000\000\000\000\000\000\045\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\045\002\045\002\000\000\045\002\045\002\045\002\
\045\002\000\000\003\002\000\000\003\002\003\002\003\002\000\000\
\000\000\000\000\003\002\045\002\000\000\000\000\045\002\003\002\
\000\000\000\000\045\002\003\002\003\002\003\002\000\000\000\000\
\000\000\000\000\000\000\000\000\003\002\003\002\003\002\003\002\
\000\000\000\000\000\000\000\000\000\000\000\000\003\002\000\000\
\000\000\000\000\000\000\003\002\000\000\000\000\000\000\000\000\
\000\000\003\002\003\002\000\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\002\
\000\000\000\000\003\002\000\000\000\000\003\002\003\002\003\002\
\000\000\003\002\000\000\000\000\000\000\003\002\000\000\000\000\
\000\000\000\000\000\000\000\000\003\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\003\002\
\003\002\000\000\003\002\003\002\003\002\003\002\000\000\001\002\
\000\000\001\002\001\002\001\002\000\000\000\000\193\000\001\002\
\003\002\000\000\000\000\003\002\001\002\000\000\000\000\003\002\
\001\002\001\002\001\002\000\000\000\000\000\000\000\000\000\000\
\000\000\001\002\001\002\001\002\001\002\000\000\000\000\000\000\
\000\000\000\000\000\000\001\002\000\000\000\000\000\000\000\000\
\001\002\000\000\000\000\000\000\000\000\000\000\001\002\001\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\082\000\000\000\000\000\000\000\001\002\000\000\000\000\001\002\
\000\000\000\000\001\002\001\002\001\002\000\000\001\002\000\000\
\000\000\000\000\001\002\000\000\000\000\000\000\000\000\000\000\
\000\000\001\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\001\002\001\002\000\000\001\002\
\001\002\001\002\001\002\000\000\000\000\000\000\002\002\000\000\
\002\002\002\002\002\002\000\000\000\000\001\002\002\002\000\000\
\001\002\000\000\000\000\002\002\001\002\000\000\000\000\002\002\
\002\002\002\002\000\000\000\000\000\000\000\000\000\000\000\000\
\002\002\002\002\002\002\002\002\000\000\000\000\000\000\000\000\
\000\000\000\000\002\002\000\000\000\000\000\000\000\000\002\002\
\000\000\000\000\000\000\000\000\000\000\002\002\002\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\002\002\000\000\000\000\002\002\000\000\
\000\000\002\002\002\002\002\002\226\002\002\002\000\000\000\000\
\000\000\002\002\000\000\000\000\000\000\000\000\000\000\000\000\
\002\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\002\002\002\002\000\000\002\002\002\002\
\002\002\002\002\000\000\000\002\000\000\000\002\000\002\000\002\
\000\000\000\000\000\000\000\002\002\002\000\000\000\000\002\002\
\000\002\000\000\000\000\002\002\000\002\000\002\000\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\002\000\002\000\002\
\000\002\000\000\000\000\000\000\000\000\000\000\000\000\000\002\
\000\000\000\000\000\000\000\000\000\002\000\000\000\000\000\000\
\000\000\000\000\000\002\000\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\193\000\000\000\
\000\002\193\000\000\000\000\002\000\000\000\000\000\002\000\002\
\000\002\000\000\000\002\193\000\000\000\000\000\000\002\000\000\
\000\000\193\000\000\000\000\000\129\000\000\002\000\000\000\000\
\193\000\193\000\193\000\193\000\000\000\000\000\000\000\000\000\
\000\002\000\002\000\000\000\002\000\002\000\002\000\002\193\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\082\000\000\002\000\000\082\000\000\002\000\000\000\000\000\000\
\000\002\000\000\000\000\193\000\000\000\082\000\193\000\000\000\
\000\000\000\000\193\000\193\000\000\000\000\000\000\000\000\000\
\000\000\193\000\082\000\082\000\082\000\082\000\000\000\000\000\
\193\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\082\000\000\000\000\000\193\000\000\000\193\000\000\000\
\193\000\193\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\193\000\082\000\000\000\193\000\
\082\000\000\000\000\000\193\000\082\000\082\000\000\000\000\000\
\000\000\000\000\000\000\082\000\000\000\000\000\000\000\121\000\
\000\000\000\000\082\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\082\000\000\000\
\082\000\000\000\082\000\082\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\082\000\000\000\
\000\000\082\000\000\000\000\000\226\002\082\000\000\000\226\002\
\000\000\226\002\226\002\226\002\226\002\000\000\000\000\226\002\
\226\002\226\002\000\000\000\000\000\000\000\000\000\000\226\002\
\000\000\000\000\000\000\000\000\000\000\000\000\226\002\000\000\
\226\002\226\002\226\002\226\002\226\002\226\002\226\002\000\000\
\226\002\000\000\000\000\226\002\000\000\226\002\000\000\000\000\
\000\000\000\000\000\000\226\002\226\002\226\002\226\002\226\002\
\226\002\226\002\226\002\226\002\226\002\226\002\000\000\000\000\
\226\002\226\002\000\000\000\000\226\002\226\002\226\002\000\000\
\226\002\226\002\226\002\226\002\226\002\226\002\000\000\226\002\
\226\002\226\002\226\002\169\001\226\002\000\000\226\002\226\002\
\000\000\000\000\226\002\226\002\000\000\226\002\000\000\226\002\
\000\000\226\002\226\002\226\002\000\000\226\002\226\002\226\002\
\000\000\000\000\000\000\226\002\000\000\000\000\226\002\000\000\
\226\002\226\002\226\002\226\002\226\002\226\002\000\000\000\000\
\226\002\009\000\010\000\011\000\000\000\000\000\000\000\012\000\
\013\000\014\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\015\000\016\000\017\000\018\000\019\000\020\000\021\000\000\000\
\000\000\000\000\000\000\022\000\000\000\023\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\024\000\025\000\026\000\
\000\000\027\000\028\000\029\000\030\000\031\000\000\000\000\000\
\032\000\033\000\000\000\000\000\034\000\035\000\036\000\000\000\
\000\000\037\000\038\000\000\000\039\000\040\000\000\000\041\000\
\000\000\042\000\043\000\000\000\044\000\114\002\045\000\000\000\
\000\000\000\000\046\000\047\000\000\000\048\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\130\000\122\000\
\000\000\000\000\000\000\050\000\000\000\000\000\000\000\000\000\
\051\000\052\000\053\000\054\000\009\000\010\000\011\000\000\000\
\055\000\000\000\012\000\013\000\014\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\015\000\016\000\017\000\018\000\019\000\
\020\000\021\000\000\000\000\000\000\000\000\000\022\000\000\000\
\023\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\033\000\000\000\000\000\034\000\
\035\000\036\000\000\000\000\000\037\000\038\000\000\000\039\000\
\040\000\000\000\041\000\000\000\042\000\043\000\000\000\044\000\
\000\000\045\000\000\000\000\000\000\000\046\000\047\000\135\001\
\048\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\122\000\000\000\000\000\000\000\050\000\000\000\
\000\000\000\000\000\000\051\000\052\000\053\000\054\000\000\000\
\000\000\000\000\000\000\055\000\000\000\000\000\000\000\000\000\
\009\000\010\000\011\000\000\000\000\000\000\000\012\000\013\000\
\014\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\015\000\
\016\000\017\000\018\000\019\000\020\000\021\000\000\000\000\000\
\000\000\000\000\022\000\000\000\023\000\000\000\000\000\000\000\
\000\000\000\000\000\000\130\000\024\000\025\000\026\000\000\000\
\027\000\028\000\029\000\030\000\031\000\000\000\000\000\032\000\
\033\000\000\000\000\000\034\000\035\000\036\000\000\000\000\000\
\037\000\038\000\000\000\039\000\040\000\000\000\041\000\000\000\
\042\000\043\000\000\000\044\000\000\000\045\000\000\000\000\000\
\000\000\046\000\047\000\000\000\048\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\122\000\000\000\
\000\000\000\000\050\000\000\000\000\000\000\000\132\000\051\000\
\052\000\053\000\054\000\000\000\000\000\114\002\000\000\055\000\
\000\000\114\002\000\000\114\002\000\000\114\002\000\000\114\002\
\000\000\114\002\114\002\114\002\114\002\000\000\114\002\114\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\114\002\
\114\002\114\002\114\002\114\002\114\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\114\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\114\002\114\002\
\114\002\114\002\114\002\114\002\000\000\114\002\114\002\000\000\
\000\000\114\002\114\002\000\000\000\000\114\002\114\002\114\002\
\114\002\114\002\114\002\000\000\107\002\114\002\000\000\114\002\
\114\002\000\000\114\002\000\000\000\000\000\000\000\000\114\002\
\114\002\000\000\000\000\114\002\000\000\000\000\000\000\000\000\
\114\002\000\000\114\002\114\002\000\000\114\002\114\002\114\002\
\114\002\000\000\000\000\000\000\114\002\000\000\000\000\114\002\
\000\000\114\002\000\000\114\002\114\002\114\002\000\000\135\001\
\114\002\000\000\000\000\135\001\000\000\135\001\000\000\135\001\
\000\000\135\001\000\000\135\001\000\000\135\001\135\001\133\000\
\135\001\135\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\135\001\000\000\000\000\135\001\135\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\135\001\135\001\135\001\135\001\000\000\135\001\000\000\135\001\
\135\001\000\000\000\000\135\001\000\000\000\000\000\000\000\000\
\135\001\135\001\135\001\000\000\000\000\000\000\000\000\135\001\
\000\000\135\001\128\000\130\000\135\001\000\000\130\000\130\000\
\000\000\000\000\135\001\000\000\000\000\135\001\000\000\000\000\
\130\000\130\000\135\001\000\000\135\001\135\001\130\000\135\001\
\135\001\000\000\135\001\000\000\000\000\130\000\135\001\130\000\
\130\000\135\001\000\000\135\001\000\000\000\000\135\001\135\001\
\000\000\000\000\135\001\000\000\130\000\000\000\000\000\000\000\
\000\000\000\000\130\000\130\000\130\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\132\000\000\000\
\130\000\132\000\132\000\130\000\000\000\000\000\130\000\130\000\
\130\000\000\000\130\000\132\000\132\000\000\000\130\000\000\000\
\000\000\132\000\000\000\000\000\000\000\130\000\000\000\000\000\
\132\000\000\000\132\000\132\000\000\000\000\000\000\000\000\000\
\000\000\130\000\000\000\130\000\000\000\130\000\130\000\132\000\
\000\000\000\000\000\000\000\000\000\000\132\000\132\000\178\000\
\000\000\130\000\000\000\000\000\130\000\000\000\000\000\000\000\
\000\000\000\000\000\000\132\000\000\000\000\000\132\000\000\000\
\000\000\132\000\132\000\132\000\000\000\132\000\000\000\000\000\
\000\000\132\000\000\000\000\000\107\002\000\000\000\000\107\002\
\132\000\000\000\000\000\000\000\107\002\000\000\000\000\000\000\
\000\000\107\002\107\002\000\000\132\000\000\000\132\000\107\002\
\132\000\132\000\125\002\000\000\000\000\000\000\107\002\000\000\
\107\002\107\002\131\002\000\000\132\000\000\000\000\000\132\000\
\000\000\000\000\000\000\000\000\137\000\107\002\138\000\139\000\
\032\000\000\000\140\000\000\000\000\000\177\001\071\004\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\133\000\
\000\000\107\002\133\000\133\000\107\002\000\000\125\002\107\002\
\107\002\107\002\000\000\000\000\133\000\133\000\000\000\107\002\
\145\000\000\000\133\000\000\000\000\000\107\002\107\002\146\000\
\000\000\133\000\000\000\133\000\133\000\000\000\224\002\000\000\
\000\000\000\000\107\002\147\000\148\000\000\000\107\002\107\002\
\133\000\000\000\000\000\000\000\000\000\000\000\133\000\133\000\
\000\000\000\000\107\002\000\000\000\000\107\002\000\000\000\000\
\000\000\000\000\128\000\000\000\133\000\128\000\128\000\133\000\
\000\000\000\000\000\000\133\000\133\000\000\000\133\000\128\000\
\128\000\000\000\133\000\000\000\000\000\128\000\000\000\000\000\
\000\000\133\000\000\000\000\000\128\000\216\001\128\000\128\000\
\000\000\000\000\000\000\000\000\000\000\133\000\000\000\133\000\
\000\000\133\000\133\000\128\000\000\000\000\000\000\000\000\000\
\000\000\128\000\128\000\000\000\130\002\133\000\000\000\130\002\
\133\000\000\000\000\000\000\000\000\000\000\000\000\000\128\000\
\000\000\130\002\128\000\000\000\000\000\000\000\128\000\128\000\
\000\000\128\000\000\000\000\000\000\000\128\000\130\002\130\002\
\130\002\130\002\000\000\000\000\128\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\130\002\000\000\000\000\
\128\000\000\000\128\000\000\000\128\000\128\000\000\000\000\000\
\000\000\006\002\000\000\000\000\000\000\000\000\000\000\178\000\
\128\000\130\002\178\000\128\000\000\000\121\002\000\000\130\002\
\130\002\130\002\006\002\000\000\178\000\000\000\121\002\130\002\
\000\000\000\000\000\000\000\000\000\000\000\000\130\002\000\000\
\000\000\178\000\178\000\178\000\178\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\130\002\000\000\130\002\121\002\
\178\000\000\000\121\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\130\002\121\002\000\000\130\002\000\000\000\000\
\000\000\000\000\131\002\000\000\178\000\131\002\000\000\000\000\
\026\002\000\000\178\000\178\000\178\000\000\000\000\000\131\002\
\000\000\026\002\178\000\000\000\000\000\000\000\000\000\000\000\
\000\000\178\000\000\000\000\000\131\002\131\002\131\002\131\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\178\000\
\000\000\178\000\026\002\131\002\000\000\026\002\007\002\000\000\
\000\000\000\000\000\000\000\000\000\000\178\000\026\002\000\000\
\178\000\000\000\000\000\000\000\000\000\000\000\224\002\131\002\
\000\000\224\002\000\000\122\002\000\000\131\002\131\002\131\002\
\000\000\000\000\000\000\224\002\122\002\131\002\000\000\000\000\
\000\000\224\002\000\000\000\000\131\002\000\000\000\000\000\000\
\224\002\000\000\224\002\224\002\000\000\000\000\000\000\000\000\
\000\000\000\000\131\002\000\000\131\002\122\002\224\002\224\002\
\122\002\000\000\000\000\000\000\000\000\224\002\224\002\000\000\
\131\002\122\002\000\000\131\002\000\000\216\001\000\000\000\000\
\216\001\000\000\000\000\224\002\007\002\216\001\224\002\000\000\
\000\000\000\000\216\001\224\002\000\000\224\002\102\000\000\000\
\216\001\224\002\000\000\000\000\000\000\000\000\000\000\216\001\
\224\002\216\001\216\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\224\002\000\000\216\001\000\000\
\224\002\224\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\224\002\000\000\000\000\224\002\
\000\000\000\000\216\001\000\000\000\000\216\001\000\000\000\000\
\216\001\216\001\216\001\000\000\000\000\000\000\000\000\052\002\
\216\001\006\002\000\000\000\000\006\002\000\000\000\000\216\001\
\000\000\006\002\213\001\000\000\000\000\000\000\006\002\000\000\
\000\000\000\000\006\002\216\001\006\002\006\002\000\000\216\001\
\216\001\000\000\006\002\006\002\000\000\006\002\006\002\006\002\
\000\000\000\000\000\000\216\001\000\000\006\002\216\001\000\000\
\000\000\000\000\006\002\000\000\006\002\000\000\006\002\006\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\006\002\224\002\000\000\006\002\000\000\
\000\000\006\002\000\000\000\000\006\002\006\002\006\002\000\000\
\000\000\000\000\000\000\006\002\006\002\000\000\000\000\006\002\
\000\000\000\000\006\002\006\002\177\001\006\002\006\002\006\002\
\000\000\000\000\000\000\000\000\006\002\006\002\000\000\006\002\
\000\000\000\000\000\000\006\002\006\002\000\000\000\000\004\002\
\000\000\000\000\000\000\000\000\000\000\000\000\007\002\006\002\
\006\002\007\002\006\002\000\000\006\002\000\000\007\002\000\000\
\006\002\000\000\000\000\007\002\000\000\000\000\000\000\000\000\
\006\002\007\002\000\000\006\002\000\000\000\000\080\000\000\000\
\007\002\000\000\007\002\007\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\007\002\
\000\000\000\000\137\000\000\000\138\000\139\000\032\000\000\000\
\140\000\000\000\000\000\141\000\142\000\000\000\000\000\000\000\
\000\000\000\000\000\000\007\002\000\000\192\001\007\002\000\000\
\000\000\007\002\007\002\007\002\000\000\143\000\000\000\000\000\
\007\002\007\002\000\000\000\000\007\002\144\000\145\000\007\002\
\007\002\226\002\011\002\000\000\007\002\146\000\102\000\000\000\
\000\000\007\002\000\000\000\000\007\002\000\000\000\000\007\002\
\007\002\147\000\148\000\102\000\005\002\000\000\007\002\000\000\
\007\002\007\002\000\000\000\000\007\002\000\000\000\000\007\002\
\102\000\000\000\102\000\102\000\000\000\007\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\102\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\007\002\000\000\000\000\007\002\177\001\000\000\007\002\
\007\002\007\002\000\000\102\000\000\000\000\000\007\002\007\002\
\000\000\000\000\213\001\102\000\000\000\213\001\007\002\000\000\
\000\000\102\000\213\001\000\000\000\000\000\000\000\000\213\001\
\102\000\000\000\007\002\000\000\000\000\213\001\007\002\000\000\
\000\000\000\000\007\002\000\000\213\001\000\000\213\001\213\001\
\102\000\000\000\007\002\000\000\000\000\007\002\000\000\000\000\
\000\000\000\000\000\000\213\001\102\000\000\000\000\000\102\000\
\178\001\000\000\000\000\000\000\224\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\213\001\
\000\000\224\002\213\001\000\000\000\000\213\001\213\001\213\001\
\000\000\000\000\000\000\000\000\177\001\213\001\224\002\177\001\
\224\002\224\002\000\000\000\000\213\001\000\000\000\000\000\000\
\000\000\177\001\000\000\000\000\000\000\224\002\000\000\177\001\
\213\001\000\000\000\000\000\000\213\001\213\001\177\001\000\000\
\177\001\177\001\000\000\180\001\000\000\000\000\000\000\097\000\
\213\001\224\002\000\000\213\001\000\000\177\001\000\000\000\000\
\000\000\224\002\000\000\000\000\000\000\000\000\080\000\224\002\
\000\000\080\000\000\000\000\000\000\000\000\000\224\002\000\000\
\000\000\177\001\000\000\080\000\177\001\000\000\000\000\000\000\
\177\001\177\001\000\000\000\000\000\000\000\000\224\002\177\001\
\080\000\080\000\080\000\080\000\000\000\000\000\177\001\000\000\
\000\000\000\000\224\002\000\000\121\002\224\002\179\001\080\000\
\000\000\000\000\177\001\000\000\000\000\000\000\177\001\177\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\226\002\177\001\080\000\226\002\177\001\080\000\000\000\
\000\000\226\002\080\000\080\000\000\000\000\000\226\002\000\000\
\000\000\080\000\000\000\000\000\226\002\000\000\000\000\000\000\
\080\000\000\000\000\000\226\002\000\000\226\002\226\002\000\000\
\101\000\000\000\000\000\000\000\080\000\000\000\080\000\000\000\
\080\000\080\000\226\002\000\000\000\000\000\000\000\000\000\000\
\000\000\181\001\000\000\000\000\080\000\000\000\000\000\080\000\
\000\000\000\000\000\000\000\000\000\000\177\001\226\002\000\000\
\177\001\226\002\000\000\000\000\000\000\226\002\226\002\000\000\
\000\000\000\000\177\001\000\000\226\002\000\000\000\000\000\000\
\177\001\000\000\000\000\226\002\000\000\000\000\000\000\177\001\
\000\000\177\001\177\001\000\000\000\000\000\000\000\000\226\002\
\000\000\000\000\000\000\226\002\226\002\000\000\177\001\000\000\
\000\000\000\000\000\000\000\000\184\001\000\000\000\000\226\002\
\000\000\000\000\226\002\000\000\000\000\000\000\000\000\000\000\
\178\001\000\000\177\001\178\001\000\000\177\001\000\000\000\000\
\000\000\177\001\177\001\000\000\000\000\178\001\000\000\000\000\
\177\001\000\000\000\000\178\001\000\000\000\000\000\000\177\001\
\000\000\000\000\178\001\000\000\178\001\178\001\000\000\000\000\
\000\000\000\000\000\000\177\001\000\000\000\000\226\002\177\001\
\177\001\178\001\000\000\000\000\000\000\000\000\000\000\117\000\
\000\000\000\000\000\000\177\001\000\000\000\000\177\001\000\000\
\000\000\000\000\000\000\180\001\000\000\178\001\180\001\097\000\
\178\001\000\000\000\000\000\000\178\001\178\001\000\000\000\000\
\180\001\000\000\000\000\178\001\097\000\000\000\180\001\000\000\
\000\000\000\000\178\001\000\000\000\000\180\001\000\000\180\001\
\180\001\097\000\000\000\097\000\097\000\000\000\178\001\000\000\
\000\000\168\001\178\001\178\001\180\001\000\000\000\000\000\000\
\097\000\000\000\000\000\000\000\000\000\000\000\178\001\000\000\
\000\000\178\001\000\000\000\000\000\000\000\000\179\001\000\000\
\180\001\179\001\000\000\180\001\097\000\000\000\000\000\180\001\
\180\001\000\000\000\000\179\001\097\000\000\000\180\001\000\000\
\000\000\179\001\097\000\000\000\000\000\180\001\000\000\000\000\
\179\001\097\000\179\001\179\001\000\000\000\000\000\000\000\000\
\000\000\180\001\000\000\000\000\224\002\180\001\180\001\179\001\
\000\000\097\000\000\000\000\000\000\000\000\000\000\000\000\000\
\101\000\180\001\000\000\000\000\180\001\097\000\000\000\000\000\
\097\000\000\000\000\000\179\001\000\000\101\000\179\001\000\000\
\000\000\181\001\179\001\179\001\181\001\000\000\000\000\000\000\
\000\000\179\001\101\000\000\000\101\000\101\000\181\001\000\000\
\179\001\224\002\000\000\000\000\181\001\000\000\000\000\000\000\
\000\000\101\000\000\000\181\001\179\001\181\001\181\001\000\000\
\179\001\179\001\000\000\000\000\000\000\000\000\000\000\069\000\
\000\000\000\000\181\001\000\000\179\001\101\000\000\000\179\001\
\000\000\000\000\000\000\000\000\000\000\101\000\000\000\000\000\
\000\000\000\000\000\000\101\000\184\001\000\000\181\001\184\001\
\000\000\181\001\101\000\000\000\000\000\181\001\181\001\000\000\
\000\000\184\001\000\000\000\000\181\001\000\000\000\000\184\001\
\000\000\000\000\101\000\181\001\070\000\000\000\184\001\000\000\
\184\001\184\001\000\000\000\000\000\000\000\000\101\000\181\001\
\000\000\101\000\000\000\181\001\181\001\184\001\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\226\002\181\001\
\000\000\000\000\181\001\000\000\000\000\000\000\226\002\117\000\
\000\000\184\001\000\000\226\002\184\001\000\000\000\000\000\000\
\184\001\184\001\000\000\000\000\117\000\000\000\213\001\184\001\
\226\002\000\000\226\002\226\002\000\000\000\000\184\001\213\001\
\000\000\117\000\000\000\117\000\117\000\000\000\000\000\226\002\
\000\000\000\000\184\001\000\000\000\000\000\000\184\001\184\001\
\117\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\168\001\184\001\226\002\000\000\184\001\226\002\000\000\
\000\000\000\000\226\002\226\002\117\000\000\000\168\001\117\000\
\000\000\226\002\000\000\117\000\117\000\000\000\000\000\000\000\
\226\002\000\000\117\000\168\001\000\000\168\001\168\001\000\000\
\000\000\117\000\000\000\000\000\226\002\000\000\000\000\000\000\
\226\002\226\002\168\001\000\000\000\000\117\000\000\000\000\000\
\000\000\117\000\117\000\000\000\226\002\224\002\000\000\226\002\
\000\000\000\000\000\000\000\000\224\002\117\000\168\001\224\002\
\117\000\168\001\000\000\000\000\000\000\168\001\168\001\000\000\
\000\000\224\002\000\000\123\000\168\001\000\000\000\000\000\000\
\000\000\000\000\000\000\168\001\000\000\000\000\224\002\000\000\
\224\002\224\002\000\000\000\000\000\000\000\000\000\000\168\001\
\000\000\124\000\000\000\168\001\168\001\224\002\000\000\000\000\
\000\000\224\002\000\000\000\000\000\000\000\000\000\000\168\001\
\000\000\000\000\168\001\000\000\000\000\000\000\224\002\000\000\
\000\000\224\002\000\000\000\000\224\002\000\000\000\000\069\000\
\000\000\224\002\069\000\224\002\000\000\224\002\224\002\224\002\
\000\000\000\000\000\000\000\000\069\000\000\000\224\002\000\000\
\000\000\000\000\224\002\000\000\000\000\000\000\000\000\000\000\
\000\000\069\000\224\002\069\000\069\000\000\000\224\002\224\002\
\000\000\000\000\000\000\000\000\000\000\000\000\224\002\069\000\
\069\000\224\002\224\002\000\000\070\000\224\002\224\002\070\000\
\226\002\000\000\000\000\000\000\224\002\000\000\000\000\000\000\
\000\000\070\000\226\002\224\002\069\000\000\000\000\000\069\000\
\000\000\000\000\000\000\069\000\069\000\000\000\070\000\224\002\
\070\000\070\000\069\000\224\002\224\002\000\000\000\000\000\000\
\000\000\069\000\000\000\000\000\070\000\070\000\000\000\224\002\
\000\000\000\000\224\002\000\000\000\000\069\000\213\001\000\000\
\000\000\069\000\069\000\000\000\000\000\000\000\213\001\213\001\
\000\000\070\000\000\000\213\001\070\000\069\000\000\000\000\000\
\070\000\070\000\000\000\000\000\213\001\000\000\000\000\070\000\
\213\001\000\000\213\001\213\001\000\000\224\002\070\000\000\000\
\000\000\213\001\000\000\213\001\213\001\000\000\000\000\213\001\
\000\000\000\000\070\000\000\000\000\000\000\000\070\000\070\000\
\213\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\070\000\213\001\000\000\000\000\213\001\000\000\
\000\000\213\001\213\001\213\001\213\001\000\000\000\000\213\001\
\000\000\213\001\213\001\213\001\213\001\000\000\000\000\054\000\
\213\001\000\000\213\001\000\000\000\000\224\002\000\000\000\000\
\224\002\213\001\000\000\000\000\213\001\000\000\000\000\000\000\
\213\001\213\001\224\002\000\000\000\000\213\001\000\000\000\000\
\000\000\213\001\213\001\123\000\213\001\000\000\123\000\224\002\
\000\000\224\002\224\002\000\000\000\000\213\001\056\000\000\000\
\123\000\000\000\000\000\000\000\000\000\224\002\224\002\000\000\
\000\000\124\000\000\000\000\000\124\000\123\000\000\000\123\000\
\123\000\000\000\000\000\000\000\000\000\000\000\124\000\000\000\
\000\000\000\000\224\002\000\000\123\000\224\002\000\000\000\000\
\000\000\000\000\224\002\124\000\000\000\124\000\124\000\000\000\
\224\002\000\000\060\000\000\000\000\000\000\000\000\000\224\002\
\123\000\000\000\124\000\123\000\000\000\000\000\000\000\123\000\
\123\000\000\000\000\000\224\002\000\000\000\000\123\000\224\002\
\224\002\000\000\000\000\000\000\000\000\123\000\124\000\000\000\
\000\000\124\000\000\000\224\002\000\000\124\000\124\000\000\000\
\000\000\123\000\000\000\000\000\124\000\123\000\123\000\063\000\
\226\002\000\000\000\000\124\000\000\000\000\000\000\000\000\000\
\226\002\123\000\226\002\000\000\000\000\226\002\000\000\124\000\
\000\000\000\000\000\000\124\000\124\000\064\000\000\000\226\002\
\000\000\000\000\226\002\000\000\226\002\226\002\224\002\124\000\
\000\000\000\000\000\000\000\000\226\002\000\000\226\002\226\002\
\000\000\226\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\226\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\226\002\000\000\000\000\
\226\002\000\000\000\000\000\000\226\002\226\002\000\000\226\002\
\000\000\000\000\226\002\226\002\000\000\224\002\226\002\226\002\
\224\002\000\000\226\002\000\000\000\000\226\002\000\000\000\000\
\000\000\000\000\224\002\000\000\226\002\000\000\226\002\000\000\
\000\000\000\000\226\002\226\002\000\000\000\000\000\000\224\002\
\226\002\224\002\224\002\000\000\226\002\226\002\226\002\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\224\002\000\000\
\226\002\000\000\039\002\000\000\039\002\039\002\039\002\054\000\
\039\002\000\000\000\000\039\002\039\002\000\000\000\000\000\000\
\000\000\000\000\224\002\000\000\054\000\224\002\000\000\000\000\
\000\000\000\000\224\002\000\000\000\000\039\002\000\000\000\000\
\224\002\054\000\000\000\054\000\054\000\039\002\039\002\224\002\
\000\000\000\000\000\000\000\000\000\000\039\002\056\000\000\000\
\054\000\000\000\000\000\224\002\000\000\000\000\000\000\224\002\
\224\002\039\002\039\002\056\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\224\002\054\000\000\000\000\000\054\000\
\056\000\000\000\056\000\056\000\054\000\000\000\000\000\000\000\
\000\000\000\000\054\000\000\000\000\000\000\000\000\000\056\000\
\000\000\054\000\060\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\054\000\000\000\060\000\
\000\000\054\000\054\000\056\000\000\000\000\000\056\000\000\000\
\000\000\000\000\000\000\056\000\060\000\054\000\060\000\060\000\
\000\000\056\000\000\000\000\000\000\000\000\000\000\000\000\000\
\056\000\000\000\000\000\060\000\000\000\000\000\000\000\063\000\
\000\000\000\000\000\000\000\000\056\000\000\000\000\000\000\000\
\056\000\056\000\000\000\000\000\063\000\000\000\000\000\060\000\
\000\000\000\000\060\000\000\000\056\000\064\000\000\000\060\000\
\000\000\063\000\000\000\063\000\063\000\060\000\224\002\000\000\
\000\000\000\000\064\000\000\000\060\000\000\000\000\000\000\000\
\063\000\000\000\000\000\224\002\000\000\000\000\000\000\064\000\
\060\000\064\000\064\000\000\000\060\000\060\000\000\000\000\000\
\224\002\000\000\224\002\224\002\063\000\000\000\064\000\063\000\
\060\000\000\000\000\000\000\000\063\000\000\000\000\000\224\002\
\000\000\000\000\063\000\000\000\000\000\000\000\000\000\000\000\
\000\000\063\000\064\000\000\000\000\000\064\000\000\000\000\000\
\000\000\000\000\064\000\224\002\000\000\063\000\224\002\000\000\
\064\000\063\000\063\000\224\002\000\000\000\000\000\000\064\000\
\000\000\224\002\000\000\000\000\000\000\063\000\000\000\000\000\
\224\002\000\000\000\000\064\000\000\000\000\000\000\000\064\000\
\064\000\000\000\000\000\000\000\224\002\000\000\000\000\000\000\
\224\002\224\002\219\002\064\000\000\000\000\000\000\000\219\002\
\219\002\219\002\219\002\000\000\224\002\219\002\219\002\219\002\
\219\002\000\000\000\000\000\000\000\000\219\002\000\000\000\000\
\000\000\000\000\000\000\000\000\219\002\000\000\219\002\219\002\
\219\002\219\002\219\002\219\002\219\002\000\000\000\000\000\000\
\000\000\219\002\000\000\219\002\000\000\000\000\000\000\000\000\
\000\000\219\002\219\002\219\002\219\002\219\002\219\002\219\002\
\219\002\219\002\219\002\219\002\000\000\000\000\219\002\219\002\
\000\000\000\000\219\002\219\002\219\002\219\002\000\000\219\002\
\219\002\219\002\219\002\219\002\000\000\219\002\000\000\219\002\
\219\002\000\000\219\002\000\000\219\002\219\002\000\000\000\000\
\219\002\219\002\000\000\219\002\000\000\219\002\000\000\000\000\
\219\002\219\002\000\000\000\000\219\002\219\002\000\000\000\000\
\000\000\219\002\000\000\000\000\219\002\000\000\219\002\219\002\
\219\002\219\002\219\002\219\002\000\000\000\000\219\002\035\001\
\036\001\037\001\000\000\000\000\009\000\010\000\038\001\000\000\
\039\001\000\000\012\000\013\000\000\000\000\000\040\001\041\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\042\001\000\000\000\000\017\000\018\000\019\000\
\020\000\021\000\000\000\043\001\000\000\000\000\022\000\000\000\
\000\000\044\001\045\001\046\001\047\001\048\001\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\000\000\049\001\000\000\034\000\
\035\000\036\000\000\000\000\000\000\000\038\000\000\000\050\001\
\051\001\000\000\052\001\000\000\042\000\043\000\000\000\044\000\
\000\000\000\000\000\000\053\001\054\001\055\001\056\001\057\001\
\058\001\000\000\000\000\000\000\000\000\000\000\000\000\059\001\
\000\000\000\000\000\000\060\001\000\000\061\001\050\000\000\000\
\000\000\000\000\000\000\051\000\052\000\000\000\054\000\035\001\
\036\001\037\001\000\000\055\000\009\000\010\000\038\001\000\000\
\039\001\000\000\012\000\013\000\000\000\000\000\000\000\041\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\042\001\000\000\000\000\017\000\018\000\019\000\
\020\000\021\000\000\000\043\001\000\000\000\000\022\000\000\000\
\000\000\044\001\045\001\046\001\047\001\048\001\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\000\000\049\001\000\000\034\000\
\035\000\036\000\000\000\000\000\000\000\038\000\000\000\050\001\
\051\001\000\000\052\001\000\000\042\000\043\000\000\000\044\000\
\000\000\000\000\000\000\053\001\054\001\055\001\056\001\057\001\
\058\001\000\000\000\000\000\000\000\000\000\000\000\000\059\001\
\000\000\000\000\000\000\060\001\000\000\061\001\050\000\000\000\
\000\000\000\000\000\000\051\000\052\000\000\000\054\000\035\001\
\036\001\037\001\000\000\055\000\009\000\010\000\038\001\000\000\
\039\001\000\000\012\000\013\000\000\000\000\000\000\000\041\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\042\001\000\000\000\000\017\000\018\000\019\000\
\020\000\021\000\000\000\043\001\000\000\000\000\022\000\000\000\
\000\000\044\001\045\001\046\001\047\001\048\001\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\000\000\049\001\000\000\034\000\
\035\000\036\000\000\000\000\000\000\000\038\000\000\000\050\001\
\051\001\000\000\090\003\000\000\042\000\043\000\000\000\044\000\
\000\000\000\000\000\000\053\001\054\001\055\001\056\001\057\001\
\058\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\060\001\000\000\061\001\050\000\000\000\
\000\000\000\000\226\002\051\000\052\000\000\000\054\000\226\002\
\226\002\226\002\226\002\055\000\000\000\226\002\226\002\000\000\
\000\000\000\000\000\000\000\000\000\000\226\002\000\000\000\000\
\000\000\000\000\000\000\000\000\226\002\000\000\226\002\000\000\
\226\002\226\002\226\002\226\002\226\002\000\000\000\000\000\000\
\000\000\226\002\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\226\002\226\002\226\002\226\002\226\002\226\002\226\002\
\226\002\226\002\226\002\226\002\000\000\000\000\226\002\226\002\
\000\000\000\000\226\002\226\002\226\002\000\000\000\000\226\002\
\226\002\226\002\226\002\226\002\000\000\000\000\000\000\226\002\
\226\002\000\000\226\002\000\000\000\000\226\002\000\000\000\000\
\226\002\226\002\000\000\226\002\000\000\226\002\000\000\000\000\
\000\000\226\002\000\000\000\000\000\000\226\002\000\000\000\000\
\000\000\226\002\000\000\000\000\226\002\000\000\226\002\226\002\
\000\000\226\002\226\002\226\002\094\002\000\000\226\002\000\000\
\000\000\165\002\165\002\165\002\000\000\000\000\000\000\165\002\
\165\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\165\002\165\002\165\002\165\002\165\002\000\000\
\000\000\000\000\000\000\165\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\165\002\165\002\165\002\
\000\000\165\002\165\002\165\002\165\002\165\002\000\000\000\000\
\165\002\000\000\000\000\000\000\165\002\165\002\165\002\000\000\
\000\000\000\000\165\002\000\000\165\002\165\002\000\000\000\000\
\000\000\165\002\165\002\000\000\165\002\000\000\000\000\000\000\
\000\000\000\000\165\002\165\002\095\002\165\002\000\000\000\000\
\000\000\166\002\166\002\166\002\094\002\000\000\000\000\166\002\
\166\002\000\000\000\000\165\002\000\000\000\000\000\000\000\000\
\165\002\165\002\000\000\165\002\000\000\000\000\000\000\000\000\
\165\002\000\000\166\002\166\002\166\002\166\002\166\002\000\000\
\000\000\000\000\000\000\166\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\166\002\166\002\166\002\
\000\000\166\002\166\002\166\002\166\002\166\002\000\000\000\000\
\166\002\000\000\000\000\000\000\166\002\166\002\166\002\000\000\
\000\000\000\000\166\002\000\000\166\002\166\002\000\000\000\000\
\000\000\166\002\166\002\000\000\166\002\000\000\000\000\000\000\
\000\000\000\000\166\002\166\002\092\002\166\002\000\000\000\000\
\000\000\167\002\167\002\167\002\095\002\000\000\000\000\167\002\
\167\002\000\000\000\000\166\002\000\000\000\000\000\000\000\000\
\166\002\166\002\000\000\166\002\000\000\000\000\000\000\000\000\
\166\002\000\000\167\002\167\002\167\002\167\002\167\002\000\000\
\000\000\000\000\000\000\167\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\167\002\167\002\167\002\
\000\000\167\002\167\002\167\002\167\002\167\002\000\000\000\000\
\167\002\000\000\000\000\000\000\167\002\167\002\167\002\000\000\
\000\000\000\000\167\002\000\000\167\002\167\002\000\000\000\000\
\000\000\167\002\167\002\000\000\167\002\000\000\000\000\000\000\
\000\000\000\000\167\002\167\002\093\002\167\002\000\000\000\000\
\000\000\168\002\168\002\168\002\092\002\000\000\000\000\168\002\
\168\002\000\000\000\000\167\002\000\000\000\000\000\000\000\000\
\167\002\167\002\000\000\167\002\000\000\000\000\000\000\000\000\
\167\002\000\000\168\002\168\002\168\002\168\002\168\002\000\000\
\000\000\000\000\000\000\168\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\168\002\168\002\168\002\
\000\000\168\002\168\002\168\002\168\002\168\002\000\000\000\000\
\168\002\000\000\000\000\000\000\168\002\168\002\168\002\000\000\
\000\000\000\000\168\002\000\000\168\002\168\002\000\000\000\000\
\000\000\168\002\168\002\000\000\168\002\000\000\000\000\000\000\
\000\000\000\000\168\002\168\002\000\000\168\002\000\000\000\000\
\000\000\000\000\000\000\000\000\093\002\235\000\236\000\237\000\
\000\000\000\000\000\000\168\002\000\000\238\000\000\000\239\000\
\168\002\168\002\000\000\168\002\000\000\240\000\241\000\242\000\
\168\002\000\000\243\000\244\000\245\000\000\000\246\000\247\000\
\248\000\000\000\249\000\250\000\251\000\252\000\000\000\000\000\
\000\000\253\000\254\000\255\000\000\000\000\000\000\000\000\000\
\000\000\000\001\001\001\000\000\000\000\000\000\000\000\002\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\003\001\004\001\000\000\000\000\000\000\000\000\
\005\001\006\001\000\000\000\000\000\000\007\001\008\001\000\000\
\009\001\000\000\010\001\011\001\012\001\000\000\013\001\000\000\
\000\000\000\000\000\000\000\000\014\001\000\000\000\000\000\000\
\000\000\015\001\000\000\000\000\000\000\000\000\000\000\016\001\
\008\002\000\000\017\001\018\001\008\002\019\001\020\001\021\001\
\022\001\023\001\000\000\024\001\025\001\026\001\027\001\028\001\
\000\000\008\002\000\000\008\002\000\000\000\000\245\001\000\000\
\000\000\000\000\008\002\008\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\008\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\008\002\
\008\002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\008\002\000\000\000\000\
\000\000\008\002\000\000\008\002\008\002\008\002\000\000\008\002\
\000\000\000\000\008\002\000\000\000\000\000\000\000\000\035\001\
\036\001\037\001\000\000\000\000\000\000\010\000\225\001\000\000\
\039\001\000\000\000\000\013\000\245\001\008\002\226\001\041\001\
\000\000\008\002\000\000\008\002\000\000\000\000\008\002\000\000\
\000\000\000\000\042\001\162\000\000\000\017\000\018\000\008\002\
\000\000\008\002\000\000\043\001\000\000\000\000\000\000\000\000\
\000\000\044\001\045\001\046\001\047\001\048\001\000\000\000\000\
\024\000\025\000\026\000\000\000\163\000\164\000\000\000\165\000\
\166\000\000\000\000\000\032\000\000\000\049\001\000\000\000\000\
\167\000\168\000\000\000\000\000\000\000\000\000\000\000\227\001\
\228\001\000\000\229\001\000\000\042\000\000\000\000\000\000\000\
\000\000\000\000\000\000\053\001\054\001\230\001\231\001\057\001\
\232\001\000\000\000\000\000\000\000\000\000\000\000\000\059\001\
\000\000\000\000\171\000\060\001\000\000\061\001\050\000\000\000\
\000\000\000\000\000\000\051\000\000\000\000\000\054\000\172\000\
\035\001\036\001\037\001\000\000\000\000\000\000\010\000\225\001\
\000\000\039\001\000\000\000\000\013\000\000\000\000\000\000\000\
\041\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\042\001\162\000\000\000\017\000\018\000\
\000\000\000\000\000\000\000\000\043\001\000\000\000\000\000\000\
\000\000\000\000\044\001\045\001\046\001\047\001\048\001\000\000\
\000\000\024\000\025\000\026\000\000\000\163\000\164\000\000\000\
\165\000\166\000\000\000\000\000\032\000\000\000\049\001\000\000\
\000\000\167\000\168\000\000\000\000\000\000\000\000\000\000\000\
\227\001\228\001\000\000\229\001\000\000\042\000\000\000\000\000\
\000\000\000\000\000\000\000\000\053\001\054\001\230\001\231\001\
\057\001\232\001\000\000\000\000\000\000\000\000\000\000\000\000\
\059\001\000\000\000\000\171\000\060\001\000\000\061\001\050\000\
\000\000\000\000\000\000\000\000\051\000\000\000\001\003\054\000\
\172\000\035\001\036\001\037\001\000\000\000\000\000\000\010\000\
\225\001\000\000\039\001\000\000\000\000\013\000\000\000\000\000\
\000\000\041\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\042\001\162\000\000\000\017\000\
\018\000\000\000\000\000\000\000\000\000\043\001\000\000\000\000\
\000\000\000\000\000\000\044\001\045\001\046\001\047\001\048\001\
\000\000\000\000\024\000\025\000\026\000\000\000\163\000\164\000\
\000\000\165\000\166\000\000\000\000\000\032\000\000\000\049\001\
\000\000\000\000\167\000\168\000\000\000\000\000\000\000\000\000\
\000\000\227\001\228\001\000\000\229\001\000\000\042\000\000\000\
\000\000\000\000\000\000\000\000\000\000\053\001\054\001\230\001\
\231\001\057\001\232\001\000\000\000\000\000\000\000\000\000\000\
\000\000\059\001\000\000\000\000\171\000\060\001\000\000\061\001\
\050\000\000\000\000\000\000\000\000\000\051\000\000\000\202\003\
\054\000\172\000\035\001\036\001\037\001\000\000\000\000\000\000\
\010\000\225\001\000\000\039\001\000\000\000\000\013\000\000\000\
\000\000\000\000\041\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\042\001\162\000\000\000\
\017\000\018\000\000\000\000\000\000\000\000\000\043\001\000\000\
\000\000\000\000\000\000\000\000\044\001\045\001\046\001\047\001\
\048\001\000\000\000\000\024\000\025\000\026\000\000\000\163\000\
\164\000\000\000\165\000\166\000\000\000\000\000\032\000\000\000\
\049\001\000\000\000\000\167\000\168\000\000\000\000\000\000\000\
\000\000\000\000\227\001\228\001\000\000\229\001\000\000\042\000\
\000\000\000\000\000\000\000\000\000\000\000\000\053\001\054\001\
\230\001\231\001\057\001\232\001\000\000\000\000\000\000\000\000\
\000\000\000\000\059\001\000\000\000\000\171\000\060\001\000\000\
\061\001\050\000\000\000\000\000\000\000\000\000\051\000\000\000\
\008\004\054\000\172\000\035\001\036\001\037\001\000\000\000\000\
\000\000\010\000\225\001\000\000\039\001\000\000\000\000\013\000\
\000\000\000\000\000\000\041\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\042\001\162\000\
\000\000\017\000\018\000\000\000\000\000\000\000\000\000\043\001\
\000\000\000\000\000\000\000\000\000\000\044\001\045\001\046\001\
\047\001\048\001\000\000\000\000\024\000\025\000\026\000\000\000\
\163\000\164\000\000\000\165\000\166\000\000\000\000\000\032\000\
\000\000\049\001\000\000\221\002\167\000\168\000\000\000\000\000\
\000\000\010\000\000\000\227\001\228\001\000\000\229\001\013\000\
\042\000\000\000\000\000\000\000\000\000\000\000\000\000\053\001\
\054\001\230\001\231\001\057\001\232\001\000\000\000\000\162\000\
\000\000\017\000\018\000\059\001\000\000\000\000\171\000\060\001\
\000\000\061\001\050\000\000\000\000\000\000\000\000\000\051\000\
\000\000\000\000\054\000\172\000\024\000\025\000\026\000\000\000\
\163\000\164\000\000\000\165\000\166\000\000\000\000\000\032\000\
\000\000\000\000\000\000\223\002\167\000\168\000\000\000\000\000\
\000\000\010\000\000\000\169\000\000\000\000\000\000\000\013\000\
\042\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\170\000\000\000\000\000\000\000\000\000\000\000\162\000\
\000\000\017\000\018\000\000\000\000\000\000\000\171\000\000\000\
\000\000\000\000\050\000\000\000\000\000\000\000\000\000\051\000\
\000\000\000\000\054\000\172\000\024\000\025\000\026\000\000\000\
\163\000\164\000\000\000\165\000\166\000\000\000\000\000\032\000\
\000\000\000\000\000\000\225\002\167\000\168\000\000\000\000\000\
\000\000\010\000\000\000\169\000\000\000\000\000\000\000\013\000\
\042\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\170\000\000\000\000\000\000\000\000\000\000\000\162\000\
\000\000\017\000\018\000\000\000\000\000\000\000\171\000\000\000\
\000\000\000\000\050\000\000\000\000\000\000\000\000\000\051\000\
\000\000\000\000\054\000\172\000\024\000\025\000\026\000\000\000\
\163\000\164\000\000\000\165\000\166\000\000\000\000\000\032\000\
\000\000\000\000\000\000\000\000\167\000\168\000\000\000\000\000\
\000\000\000\000\000\000\169\000\000\000\000\000\000\000\000\000\
\042\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\170\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\171\000\000\000\
\000\000\000\000\050\000\000\000\000\000\000\000\000\000\051\000\
\000\000\000\000\054\000\172\000\009\000\010\000\011\000\000\000\
\000\000\000\000\012\000\013\000\014\000\053\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\015\000\016\000\017\000\018\000\019\000\
\020\000\021\000\000\000\000\000\000\000\000\000\022\000\000\000\
\023\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\033\000\000\000\000\000\034\000\
\035\000\036\000\000\000\000\000\037\000\038\000\000\000\039\000\
\040\000\000\000\041\000\000\000\042\000\043\000\000\000\044\000\
\000\000\045\000\000\000\000\000\000\000\046\000\047\000\000\000\
\048\000\000\000\054\002\000\000\000\000\009\000\010\000\011\000\
\000\000\049\000\000\000\012\000\013\000\014\000\050\000\000\000\
\000\000\000\000\000\000\051\000\052\000\053\000\054\000\000\000\
\000\000\000\000\000\000\055\000\015\000\016\000\017\000\018\000\
\019\000\020\000\021\000\000\000\000\000\000\000\000\000\022\000\
\000\000\023\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\024\000\025\000\026\000\000\000\027\000\028\000\029\000\
\030\000\031\000\000\000\000\000\032\000\033\000\000\000\000\000\
\034\000\035\000\036\000\000\000\000\000\037\000\038\000\000\000\
\039\000\040\000\000\000\041\000\000\000\042\000\043\000\000\000\
\044\000\000\000\045\000\000\000\000\000\000\000\046\000\047\000\
\000\000\048\000\000\000\000\000\000\000\009\000\010\000\011\000\
\000\000\000\000\049\000\012\000\013\000\000\000\000\000\050\000\
\000\000\000\000\000\000\000\000\051\000\052\000\053\000\054\000\
\000\000\000\000\000\000\000\000\055\000\000\000\017\000\018\000\
\019\000\020\000\021\000\000\000\000\000\000\000\000\000\022\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\024\000\025\000\026\000\000\000\027\000\028\000\029\000\
\030\000\031\000\000\000\000\000\032\000\000\000\000\000\000\000\
\034\000\035\000\036\000\000\000\000\000\000\000\038\000\000\000\
\039\000\040\000\000\000\000\000\000\000\042\000\043\000\000\000\
\044\000\000\000\000\000\000\000\000\000\000\000\046\000\047\000\
\000\000\048\000\000\000\000\000\000\000\000\000\230\000\009\000\
\010\000\011\000\000\000\000\000\233\000\012\000\013\000\050\000\
\000\000\000\000\000\000\000\000\051\000\052\000\000\000\054\000\
\000\000\000\000\000\000\000\000\055\000\000\000\000\000\000\000\
\017\000\018\000\019\000\020\000\021\000\000\000\000\000\000\000\
\000\000\022\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\024\000\025\000\026\000\000\000\027\000\
\028\000\029\000\030\000\031\000\000\000\000\000\032\000\000\000\
\000\000\000\000\034\000\035\000\036\000\000\000\000\000\000\000\
\038\000\000\000\039\000\040\000\000\000\000\000\000\000\042\000\
\043\000\000\000\044\000\000\000\000\000\000\000\000\000\000\000\
\046\000\047\000\000\000\048\000\000\000\000\000\009\000\010\000\
\011\000\000\000\000\000\000\000\012\000\013\000\000\000\000\000\
\000\000\050\000\000\000\000\000\000\000\000\000\051\000\052\000\
\000\000\054\000\000\000\006\002\000\000\000\000\055\000\017\000\
\018\000\019\000\020\000\021\000\000\000\000\000\000\000\000\000\
\022\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\024\000\025\000\026\000\000\000\027\000\028\000\
\029\000\030\000\031\000\000\000\000\000\032\000\000\000\000\000\
\000\000\034\000\035\000\036\000\000\000\000\000\000\000\038\000\
\000\000\039\000\040\000\000\000\000\000\000\000\042\000\043\000\
\000\000\044\000\000\000\000\000\000\000\000\000\000\000\046\000\
\047\000\000\000\048\000\000\000\000\000\228\002\228\002\228\002\
\000\000\000\000\000\000\228\002\228\002\000\000\000\000\000\000\
\050\000\000\000\000\000\000\000\000\000\051\000\052\000\000\000\
\054\000\000\000\228\002\000\000\000\000\055\000\228\002\228\002\
\228\002\228\002\228\002\000\000\000\000\000\000\000\000\228\002\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\228\002\228\002\228\002\000\000\228\002\228\002\228\002\
\228\002\228\002\000\000\000\000\228\002\000\000\000\000\000\000\
\228\002\228\002\228\002\000\000\000\000\000\000\228\002\000\000\
\228\002\228\002\000\000\000\000\000\000\228\002\228\002\000\000\
\228\002\000\000\000\000\000\000\000\000\000\000\228\002\228\002\
\000\000\228\002\000\000\000\000\009\000\010\000\011\000\000\000\
\000\000\000\000\012\000\013\000\000\000\000\000\000\000\228\002\
\000\000\000\000\000\000\000\000\228\002\228\002\000\000\228\002\
\000\000\000\000\000\000\000\000\228\002\017\000\018\000\019\000\
\020\000\021\000\000\000\000\000\000\000\000\000\022\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\024\000\025\000\026\000\000\000\027\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\000\000\000\000\000\000\034\000\
\035\000\036\000\000\000\000\000\000\000\038\000\000\000\039\000\
\040\000\000\000\000\000\000\000\042\000\043\000\000\000\044\000\
\000\000\000\000\000\000\000\000\000\000\046\000\047\000\000\000\
\048\000\000\000\000\000\228\002\228\002\228\002\000\000\000\000\
\000\000\228\002\228\002\000\000\000\000\000\000\050\000\000\000\
\000\000\000\000\000\000\051\000\052\000\000\000\054\000\000\000\
\000\000\000\000\000\000\055\000\228\002\228\002\228\002\228\002\
\228\002\000\000\000\000\000\000\000\000\228\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\228\002\
\228\002\228\002\000\000\228\002\228\002\228\002\228\002\228\002\
\000\000\000\000\228\002\000\000\000\000\000\000\228\002\228\002\
\228\002\000\000\000\000\000\000\228\002\000\000\228\002\228\002\
\000\000\000\000\000\000\228\002\228\002\000\000\228\002\000\000\
\000\000\000\000\000\000\000\000\228\002\228\002\000\000\228\002\
\000\000\000\000\000\000\010\000\000\000\000\000\000\000\000\000\
\000\000\013\000\000\000\094\003\000\000\228\002\067\002\000\000\
\000\000\000\000\228\002\228\002\000\000\228\002\000\000\000\000\
\095\003\000\000\228\002\017\000\018\000\243\001\000\000\243\001\
\243\001\243\001\000\000\243\001\000\000\000\000\243\001\243\001\
\000\000\000\000\000\000\000\000\000\000\000\000\024\000\025\000\
\026\000\021\002\000\000\164\000\000\000\165\000\166\000\000\000\
\243\001\032\000\000\000\000\000\000\000\000\000\167\000\096\003\
\243\001\243\001\000\000\000\000\000\000\169\000\010\000\000\000\
\243\001\000\000\042\000\000\000\013\000\000\000\066\002\000\000\
\023\002\067\002\000\000\170\000\243\001\243\001\000\000\000\000\
\024\002\000\000\000\000\095\003\000\000\000\000\017\000\018\000\
\171\000\000\000\000\000\000\000\050\000\000\000\000\000\025\002\
\000\000\051\000\000\000\000\000\054\000\172\000\000\000\000\000\
\000\000\024\000\025\000\026\000\021\002\000\000\164\000\000\000\
\165\000\166\000\000\000\000\000\032\000\000\000\000\000\000\000\
\000\000\167\000\096\003\000\000\000\000\000\000\000\000\000\000\
\169\000\010\000\000\000\000\000\000\000\042\000\000\000\013\000\
\000\000\185\003\000\000\023\002\000\000\000\000\170\000\000\000\
\000\000\000\000\000\000\024\002\000\000\000\000\186\003\000\000\
\000\000\017\000\018\000\171\000\000\000\000\000\000\000\050\000\
\000\000\000\000\025\002\000\000\051\000\000\000\000\000\054\000\
\172\000\000\000\000\000\000\000\024\000\025\000\026\000\021\002\
\000\000\164\000\000\000\165\000\166\000\000\000\000\000\032\000\
\000\000\000\000\000\000\000\000\167\000\212\001\000\000\000\000\
\000\000\000\000\000\000\169\000\010\000\000\000\000\000\000\000\
\042\000\000\000\013\000\000\000\146\005\000\000\023\002\000\000\
\000\000\170\000\000\000\000\000\000\000\000\000\024\002\000\000\
\000\000\095\003\000\000\000\000\017\000\018\000\171\000\000\000\
\000\000\000\000\050\000\000\000\000\000\025\002\000\000\051\000\
\000\000\000\000\054\000\172\000\000\000\000\000\000\000\024\000\
\025\000\026\000\021\002\000\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\096\003\000\000\000\000\000\000\010\000\000\000\169\000\000\000\
\000\000\000\000\013\000\042\000\000\000\000\000\000\000\000\000\
\000\000\023\002\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\024\002\000\000\000\000\017\000\018\000\000\000\000\000\
\000\000\171\000\000\000\000\000\000\000\050\000\000\000\000\000\
\025\002\000\000\051\000\000\000\000\000\054\000\172\000\024\000\
\025\000\026\000\021\002\000\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\011\003\000\000\000\000\000\000\010\000\000\000\169\000\000\000\
\012\003\000\000\013\000\042\000\000\000\000\000\000\000\000\000\
\000\000\023\002\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\024\002\000\000\000\000\017\000\018\000\000\000\000\000\
\000\000\171\000\000\000\000\000\000\000\050\000\000\000\000\000\
\025\002\000\000\051\000\000\000\000\000\054\000\172\000\024\000\
\025\000\026\000\021\002\000\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\212\001\000\000\000\000\000\000\010\000\000\000\169\000\000\000\
\069\005\000\000\013\000\042\000\000\000\000\000\000\000\000\000\
\000\000\023\002\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\024\002\000\000\000\000\017\000\018\000\000\000\000\000\
\000\000\171\000\000\000\000\000\000\000\050\000\000\000\000\000\
\025\002\000\000\051\000\000\000\000\000\054\000\172\000\024\000\
\025\000\026\000\021\002\000\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\022\002\000\000\000\000\000\000\010\000\000\000\169\000\000\000\
\000\000\000\000\013\000\042\000\000\000\000\000\000\000\000\000\
\000\000\023\002\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\024\002\000\000\000\000\017\000\018\000\000\000\000\000\
\000\000\171\000\000\000\000\000\000\000\050\000\000\000\000\000\
\025\002\000\000\051\000\000\000\000\000\054\000\172\000\024\000\
\025\000\026\000\021\002\000\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\212\001\000\000\000\000\000\000\228\002\000\000\169\000\000\000\
\000\000\000\000\228\002\042\000\000\000\000\000\000\000\000\000\
\000\000\023\002\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\024\002\000\000\000\000\228\002\228\002\000\000\000\000\
\000\000\171\000\000\000\000\000\000\000\050\000\000\000\000\000\
\025\002\000\000\051\000\000\000\000\000\054\000\172\000\228\002\
\228\002\228\002\228\002\000\000\228\002\000\000\228\002\228\002\
\000\000\000\000\228\002\000\000\000\000\000\000\000\000\228\002\
\228\002\000\000\000\000\000\000\010\000\000\000\228\002\000\000\
\000\000\000\000\013\000\228\002\000\000\000\000\000\000\000\000\
\000\000\228\002\000\000\000\000\228\002\000\000\000\000\000\000\
\000\000\228\002\162\000\000\000\017\000\018\000\000\000\000\000\
\000\000\228\002\000\000\000\000\000\000\228\002\000\000\000\000\
\228\002\000\000\228\002\000\000\000\000\228\002\228\002\024\000\
\025\000\026\000\000\000\163\000\164\000\000\000\165\000\166\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\168\000\000\000\000\000\000\000\000\000\000\000\169\000\000\000\
\000\000\000\000\010\000\042\000\000\000\000\000\223\001\000\000\
\013\000\000\000\000\000\000\000\170\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\230\000\000\000\000\000\000\000\
\162\000\171\000\017\000\018\000\000\000\050\000\000\000\000\000\
\000\000\000\000\051\000\000\000\000\000\054\000\172\000\000\000\
\000\000\000\000\000\000\000\000\000\000\024\000\025\000\026\000\
\000\000\163\000\164\000\000\000\165\000\166\000\000\000\000\000\
\032\000\000\000\000\000\000\000\000\000\167\000\168\000\000\000\
\000\000\000\000\000\000\000\000\169\000\228\002\000\000\228\002\
\000\000\042\000\000\000\228\002\000\000\000\000\000\000\000\000\
\000\000\000\000\170\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\228\002\000\000\228\002\228\002\171\000\
\000\000\000\000\000\000\050\000\000\000\000\000\000\000\000\000\
\051\000\000\000\000\000\054\000\172\000\000\000\000\000\000\000\
\228\002\228\002\228\002\000\000\228\002\228\002\000\000\228\002\
\228\002\000\000\000\000\228\002\000\000\000\000\000\000\000\000\
\228\002\228\002\000\000\000\000\000\000\228\002\000\000\228\002\
\000\000\000\000\000\000\228\002\228\002\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\228\002\000\000\000\000\
\000\000\000\000\000\000\228\002\000\000\228\002\228\002\000\000\
\000\000\000\000\228\002\000\000\000\000\000\000\228\002\000\000\
\000\000\000\000\000\000\228\002\000\000\000\000\228\002\228\002\
\228\002\228\002\228\002\000\000\228\002\228\002\000\000\228\002\
\228\002\000\000\000\000\228\002\000\000\000\000\000\000\000\000\
\228\002\228\002\000\000\000\000\000\000\000\000\000\000\228\002\
\000\000\000\000\000\000\010\000\228\002\000\000\000\000\000\000\
\000\000\013\000\000\000\000\000\000\000\228\002\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\228\002\000\000\
\000\000\162\000\228\002\017\000\018\000\000\000\228\002\000\000\
\000\000\000\000\000\000\228\002\000\000\000\000\228\002\228\002\
\000\000\000\000\000\000\000\000\000\000\000\000\024\000\025\000\
\026\000\000\000\163\000\164\000\000\000\165\000\166\000\000\000\
\000\000\032\000\000\000\000\000\000\000\000\000\167\000\168\000\
\000\000\000\000\000\000\228\002\000\000\169\000\000\000\000\000\
\000\000\228\002\042\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\170\000\000\000\000\000\000\000\000\000\
\000\000\228\002\000\000\228\002\228\002\000\000\000\000\000\000\
\171\000\000\000\000\000\000\000\050\000\000\000\000\000\000\000\
\000\000\051\000\000\000\000\000\054\000\172\000\228\002\228\002\
\228\002\000\000\228\002\228\002\000\000\228\002\228\002\000\000\
\000\000\228\002\000\000\000\000\000\000\000\000\228\002\228\002\
\000\000\000\000\000\000\161\002\000\000\228\002\000\000\000\000\
\000\000\161\002\228\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\228\002\000\000\000\000\000\000\000\000\
\000\000\161\002\000\000\161\002\161\002\000\000\000\000\000\000\
\228\002\000\000\000\000\000\000\228\002\000\000\000\000\000\000\
\000\000\228\002\000\000\000\000\228\002\228\002\161\002\161\002\
\161\002\000\000\161\002\161\002\000\000\161\002\161\002\000\000\
\000\000\161\002\000\000\000\000\000\000\000\000\161\002\161\002\
\000\000\000\000\000\000\142\002\000\000\161\002\000\000\000\000\
\000\000\142\002\161\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\161\002\000\000\000\000\000\000\000\000\
\000\000\142\002\000\000\142\002\142\002\000\000\000\000\000\000\
\161\002\000\000\000\000\000\000\161\002\000\000\000\000\000\000\
\000\000\161\002\000\000\000\000\161\002\161\002\142\002\142\002\
\142\002\000\000\142\002\142\002\000\000\142\002\142\002\000\000\
\000\000\142\002\000\000\000\000\000\000\000\000\142\002\142\002\
\000\000\000\000\000\000\010\000\000\000\142\002\000\000\000\000\
\000\000\013\000\142\002\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\142\002\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\017\000\018\000\000\000\000\000\000\000\
\142\002\000\000\000\000\000\000\142\002\000\000\000\000\000\000\
\000\000\142\002\000\000\000\000\142\002\142\002\024\000\025\000\
\026\000\000\000\000\000\164\000\000\000\165\000\166\000\000\000\
\000\000\032\000\000\000\000\000\000\000\000\000\167\000\212\001\
\000\000\000\000\000\000\000\000\000\000\169\000\010\000\011\000\
\000\000\000\000\042\000\012\000\013\000\000\000\000\000\000\000\
\000\000\000\000\000\000\170\000\000\000\000\000\124\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\017\000\018\000\
\171\000\000\000\000\000\000\000\050\000\000\000\000\000\000\000\
\000\000\051\000\000\000\000\000\054\000\172\000\000\000\000\000\
\000\000\024\000\025\000\026\000\125\001\000\000\028\000\029\000\
\030\000\031\000\000\000\000\000\032\000\000\000\000\000\000\000\
\000\000\167\000\192\000\000\000\000\000\010\000\011\000\000\000\
\000\000\000\000\012\000\013\000\000\000\042\000\043\000\000\000\
\000\000\000\000\000\000\126\001\000\000\000\000\000\000\000\000\
\000\000\048\000\000\000\127\001\000\000\017\000\018\000\000\000\
\000\000\000\000\000\000\128\001\129\001\000\000\000\000\050\000\
\000\000\000\000\130\001\000\000\051\000\000\000\000\000\054\000\
\024\000\025\000\026\000\125\001\000\000\028\000\029\000\030\000\
\031\000\000\000\000\000\032\000\000\000\000\000\000\000\000\000\
\167\000\192\000\000\000\000\000\010\000\011\000\000\000\000\000\
\000\000\012\000\013\000\000\000\042\000\043\000\000\000\000\000\
\000\000\000\000\126\001\000\000\000\000\000\000\000\000\000\000\
\048\000\000\000\127\001\000\000\017\000\018\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\050\000\000\000\
\000\000\130\001\000\000\051\000\000\000\000\000\054\000\024\000\
\025\000\026\000\000\000\000\000\028\000\029\000\030\000\031\000\
\000\000\000\000\032\000\000\000\000\000\000\000\000\000\167\000\
\192\000\000\000\000\000\010\000\011\000\000\000\000\000\000\000\
\012\000\013\000\000\000\042\000\043\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\048\000\
\000\000\000\000\000\000\017\000\018\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\050\000\000\000\000\000\
\000\000\000\000\051\000\000\000\000\000\054\000\024\000\025\000\
\026\000\000\000\000\000\028\000\029\000\030\000\031\000\000\000\
\000\000\032\000\000\000\000\000\000\000\000\000\219\000\192\000\
\000\000\000\000\228\002\228\002\000\000\000\000\000\000\228\002\
\228\002\000\000\042\000\043\000\000\000\000\000\000\000\000\000\
\000\000\000\000\144\004\000\000\000\000\000\000\048\000\000\000\
\000\000\200\000\228\002\228\002\137\000\000\000\138\000\139\000\
\032\000\145\004\140\000\000\000\050\000\141\000\142\000\000\000\
\201\000\051\000\000\000\000\000\054\000\228\002\228\002\228\002\
\000\000\000\000\228\002\228\002\228\002\228\002\000\000\143\000\
\228\002\000\000\000\000\000\000\000\000\228\002\228\002\144\000\
\144\003\000\000\137\000\000\000\138\000\139\000\032\000\146\000\
\140\000\228\002\228\002\141\000\146\004\000\000\000\000\000\000\
\000\000\144\004\183\005\147\000\148\000\228\002\000\000\000\000\
\200\000\000\000\000\000\000\000\000\000\143\000\000\000\000\000\
\000\000\000\000\000\000\228\002\147\004\144\000\145\000\201\000\
\228\002\000\000\000\000\228\002\000\000\146\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\203\000\000\000\
\000\000\148\004\148\000\000\000\000\000\000\000\000\000\000\000\
\000\000\137\000\000\000\138\000\139\000\032\000\000\000\140\000\
\000\000\000\000\141\000\146\004\000\000\000\000\000\000\000\000\
\211\003\087\001\088\001\000\000\000\000\000\000\000\000\000\000\
\000\000\089\001\000\000\000\000\143\000\000\000\212\003\090\001\
\091\001\213\003\092\001\000\000\144\000\145\000\000\000\000\000\
\000\000\000\000\000\000\093\001\146\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\094\001\203\000\000\000\000\000\
\148\004\148\000\095\001\096\001\097\001\098\001\099\001\035\001\
\036\001\037\001\000\000\000\000\000\000\000\000\225\001\000\000\
\039\001\000\000\000\000\000\000\000\000\000\000\100\001\041\001\
\000\000\000\000\000\000\185\000\000\000\000\000\000\000\000\000\
\101\001\102\001\042\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\043\001\103\001\104\001\105\001\106\001\
\107\001\044\001\045\001\046\001\047\001\048\001\000\000\000\000\
\214\003\000\000\000\000\000\000\000\000\000\000\109\001\000\000\
\000\000\000\000\000\000\000\000\000\000\049\001\000\000\000\000\
\000\000\087\001\088\001\000\000\000\000\000\000\000\000\016\002\
\228\001\089\001\017\002\000\000\000\000\000\000\000\000\090\001\
\091\001\000\000\092\001\053\001\054\001\018\002\231\001\057\001\
\232\001\000\000\000\000\093\001\000\000\000\000\000\000\000\000\
\000\000\087\001\088\001\060\001\094\001\061\001\000\000\000\000\
\000\000\089\001\095\001\096\001\097\001\098\001\099\001\090\001\
\091\001\000\000\092\001\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\093\001\000\000\000\000\100\001\000\000\
\000\000\000\000\000\000\185\000\094\001\000\000\000\000\000\000\
\101\001\102\001\095\001\096\001\097\001\098\001\099\001\000\000\
\000\000\000\000\000\000\000\000\103\001\104\001\105\001\106\001\
\107\001\000\000\000\000\000\000\000\000\000\000\100\001\087\001\
\088\001\108\001\000\000\185\000\000\000\000\000\109\001\089\001\
\101\001\102\001\000\000\000\000\000\000\090\001\091\001\000\000\
\092\001\000\000\000\000\000\000\103\001\104\001\105\001\106\001\
\107\001\093\001\000\000\000\000\000\000\016\004\000\000\087\001\
\088\001\000\000\094\001\000\000\000\000\000\000\109\001\089\001\
\095\001\096\001\097\001\098\001\099\001\090\001\091\001\000\000\
\092\001\000\000\000\000\000\000\000\000\000\000\000\000\114\004\
\000\000\093\001\000\000\000\000\100\001\000\000\000\000\000\000\
\000\000\185\000\094\001\000\000\000\000\000\000\101\001\102\001\
\095\001\096\001\097\001\098\001\099\001\000\000\000\000\000\000\
\000\000\000\000\103\001\104\001\105\001\106\001\107\001\000\000\
\000\000\000\000\000\000\063\004\100\001\087\001\088\001\000\000\
\000\000\185\000\000\000\000\000\109\001\089\001\101\001\102\001\
\000\000\000\000\000\000\090\001\091\001\000\000\092\001\000\000\
\000\000\000\000\103\001\104\001\105\001\106\001\107\001\093\001\
\000\000\000\000\000\000\000\000\000\000\087\001\088\001\000\000\
\094\001\000\000\000\000\000\000\109\001\089\001\095\001\096\001\
\097\001\098\001\099\001\090\001\091\001\000\000\126\004\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\093\001\
\000\000\000\000\100\001\000\000\000\000\000\000\000\000\185\000\
\094\001\000\000\000\000\000\000\101\001\102\001\095\001\096\001\
\097\001\098\001\099\001\000\000\000\000\000\000\000\000\000\000\
\103\001\104\001\105\001\106\001\107\001\000\000\000\000\000\000\
\000\000\000\000\100\001\234\000\234\000\000\000\000\000\185\000\
\000\000\000\000\109\001\234\000\101\001\102\001\000\000\000\000\
\000\000\234\000\234\000\000\000\000\000\000\000\000\000\000\000\
\103\001\104\001\105\001\106\001\107\001\234\000\000\000\000\000\
\000\000\000\000\000\000\087\001\088\001\000\000\234\000\000\000\
\000\000\000\000\109\001\089\001\234\000\234\000\234\000\234\000\
\234\000\090\001\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\093\001\000\000\000\000\
\234\000\000\000\000\000\000\000\000\000\234\000\094\001\000\000\
\000\000\000\000\234\000\234\000\095\001\096\001\097\001\098\001\
\099\001\000\000\000\000\000\000\000\000\000\000\234\000\234\000\
\234\000\234\000\234\000\000\000\000\000\000\000\000\000\234\000\
\100\001\087\001\088\001\000\000\000\000\185\000\000\000\000\000\
\234\000\089\001\101\001\102\001\000\000\000\000\000\000\090\001\
\000\000\000\000\000\000\000\000\000\000\000\000\103\001\104\001\
\105\001\106\001\107\001\093\001\000\000\000\000\000\000\000\000\
\000\000\000\000\082\005\000\000\094\001\000\000\000\000\000\000\
\109\001\000\000\095\001\096\001\097\001\098\001\099\001\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\087\001\088\001\
\000\000\000\000\000\000\000\000\000\000\000\000\100\001\000\000\
\000\000\000\000\000\000\185\000\090\001\000\000\000\000\000\000\
\101\001\102\001\000\000\000\000\000\000\000\000\000\000\000\000\
\093\001\000\000\000\000\000\000\103\001\104\001\105\001\106\001\
\107\001\094\001\000\000\000\000\000\000\000\000\000\000\095\001\
\096\001\097\001\098\001\099\001\000\000\000\000\109\001\000\000\
\000\000\000\000\000\000\000\000\137\000\000\000\138\000\139\000\
\032\000\000\000\140\000\100\001\000\000\141\000\142\000\000\000\
\185\000\000\000\000\000\000\000\000\000\101\001\102\001\192\001\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\143\000\
\000\000\000\000\104\001\105\001\106\001\107\001\000\000\144\000\
\145\000\000\000\000\000\000\000\000\000\000\000\000\000\146\000\
\000\000\000\000\000\000\109\001\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\147\000\148\000"

let yycheck = "\003\000\
\004\000\094\000\006\000\002\000\146\000\002\000\062\001\015\000\
\131\001\163\000\137\000\014\002\143\000\164\000\033\001\010\000\
\137\000\186\002\192\001\029\000\158\000\013\003\139\000\009\002\
\209\000\009\000\178\001\213\000\012\000\097\003\127\003\031\000\
\036\000\171\000\143\001\019\000\020\000\021\000\022\000\086\002\
\011\000\055\003\243\002\027\000\186\002\012\002\212\000\014\002\
\166\004\001\000\034\000\003\000\004\000\002\000\038\000\209\000\
\012\004\028\000\033\000\043\000\044\000\232\000\037\000\234\000\
\003\000\004\000\111\001\002\000\052\000\007\000\000\000\055\000\
\059\000\000\000\147\004\000\000\002\000\048\000\012\002\132\000\
\014\002\134\000\073\004\031\001\098\000\138\004\139\004\095\000\
\003\000\002\000\140\001\188\004\001\000\210\000\066\004\017\001\
\110\000\049\000\002\000\098\000\002\000\098\000\085\004\067\001\
\197\000\001\002\002\002\059\000\065\001\000\000\015\001\110\000\
\083\000\110\000\085\000\086\000\064\001\000\001\037\001\015\002\
\248\003\000\001\052\001\007\001\004\001\067\001\130\000\122\000\
\008\001\151\004\140\000\010\001\096\001\090\001\000\001\015\001\
\023\004\154\004\018\001\005\000\049\000\183\001\000\001\185\001\
\000\001\137\000\065\001\000\001\007\001\098\000\145\000\134\004\
\000\001\117\001\096\001\000\001\000\001\114\001\172\003\000\001\
\000\001\110\000\067\001\098\000\036\004\000\001\150\000\074\002\
\000\001\017\001\010\001\078\002\098\000\000\001\096\001\110\000\
\128\000\018\005\130\000\008\001\132\000\094\003\134\000\069\001\
\110\000\098\000\000\001\067\001\192\000\128\000\174\000\130\000\
\196\000\132\000\098\000\134\000\098\000\110\000\212\003\213\003\
\000\001\000\001\174\004\187\000\000\001\046\005\110\000\211\000\
\110\000\067\001\185\000\186\000\065\001\096\001\008\002\130\000\
\000\001\188\000\000\001\210\004\065\001\065\001\000\001\076\002\
\162\000\132\002\067\001\165\000\166\000\124\001\114\001\215\000\
\142\001\065\001\217\004\115\001\014\001\093\001\096\001\009\000\
\178\000\179\000\012\000\009\005\227\004\111\001\007\005\218\000\
\096\001\019\000\020\000\021\000\022\000\139\003\094\001\096\001\
\017\005\027\000\111\001\117\001\000\001\096\001\214\000\079\001\
\136\004\094\001\111\001\111\001\038\000\096\001\208\000\067\001\
\061\002\043\000\044\000\190\001\117\001\094\005\004\001\111\001\
\094\001\118\001\052\000\120\001\045\005\055\000\024\001\000\001\
\004\001\067\001\065\001\066\001\008\001\093\001\093\001\000\000\
\000\001\097\001\097\001\015\001\096\001\022\001\018\001\190\004\
\032\001\214\000\159\002\222\001\000\002\224\001\014\001\093\001\
\096\001\017\001\003\001\097\001\191\001\065\001\096\001\000\001\
\022\001\183\005\208\001\038\001\000\001\162\001\000\001\075\001\
\067\001\064\005\078\001\206\001\219\004\004\001\030\001\031\001\
\111\001\008\001\000\001\133\002\134\002\102\005\069\005\058\001\
\015\001\000\001\000\001\018\001\074\001\000\001\081\001\067\001\
\026\001\093\001\250\002\083\001\117\005\097\001\074\001\010\001\
\108\001\080\001\036\002\000\001\112\001\000\001\005\002\103\004\
\064\001\107\001\068\001\015\001\166\002\170\001\128\001\172\001\
\173\005\174\001\032\002\021\002\069\004\094\001\071\004\255\004\
\026\002\081\001\030\001\145\001\154\005\119\003\092\001\026\001\
\096\001\055\003\010\005\084\004\067\001\183\002\067\001\115\001\
\051\003\093\002\145\001\077\002\145\001\000\001\000\001\165\004\
\000\001\067\001\125\001\126\001\093\001\129\005\129\001\115\005\
\131\001\047\004\094\001\147\001\094\001\022\001\066\001\000\001\
\000\001\000\001\027\001\000\001\018\001\111\001\027\003\093\001\
\063\005\010\001\000\001\010\001\000\001\000\001\096\001\093\001\
\176\001\096\001\073\005\094\001\017\001\000\001\097\001\183\001\
\003\001\185\001\178\001\181\003\145\001\244\003\008\001\128\002\
\000\001\000\001\043\005\096\001\018\001\037\001\017\001\089\002\
\108\001\193\001\145\001\111\001\065\003\035\001\008\001\207\001\
\028\005\037\001\170\001\145\001\172\001\015\001\174\001\190\003\
\191\003\008\001\036\001\211\001\136\002\243\004\128\002\170\001\
\145\001\172\001\000\001\174\001\030\001\221\001\060\001\126\005\
\150\002\145\001\093\001\145\001\066\001\000\001\096\001\239\004\
\096\001\233\001\146\003\185\003\000\001\000\001\172\003\010\001\
\190\003\191\003\203\004\112\003\054\001\094\001\032\001\094\001\
\097\001\097\001\097\001\096\001\252\001\253\001\000\001\124\003\
\066\001\001\002\002\002\094\001\012\002\097\001\014\002\132\003\
\094\001\163\002\104\001\000\001\094\001\096\001\000\001\015\002\
\008\001\111\001\177\005\022\001\020\002\047\002\212\003\213\003\
\096\001\096\001\028\004\000\001\008\001\015\001\018\001\014\001\
\000\002\191\004\034\002\015\001\246\001\247\001\248\001\094\001\
\194\002\242\002\108\001\210\002\254\001\111\001\066\001\067\001\
\195\002\196\002\030\001\188\003\232\002\027\001\006\001\008\001\
\094\001\018\001\092\001\059\002\066\001\052\002\008\001\027\001\
\064\002\065\001\066\001\094\001\074\001\098\005\097\001\097\002\
\242\002\023\004\028\002\094\001\096\001\023\003\112\001\000\001\
\100\002\067\001\098\002\099\002\209\003\016\001\066\001\018\001\
\018\001\022\001\036\001\093\001\246\002\067\001\000\001\018\001\
\099\001\100\001\018\001\013\003\054\002\022\001\094\001\022\001\
\093\001\174\002\027\001\061\002\096\001\096\002\096\001\019\001\
\008\001\096\001\117\001\014\001\022\001\137\002\138\002\015\001\
\093\001\027\001\000\001\073\004\153\005\093\002\126\002\081\002\
\108\001\030\001\042\004\111\001\096\001\014\004\030\001\096\001\
\014\001\019\002\040\005\047\001\042\005\094\001\094\001\117\001\
\090\003\018\001\157\002\000\000\094\001\014\001\018\001\151\002\
\097\003\061\001\018\001\056\001\087\003\088\003\089\003\092\001\
\018\001\069\001\188\002\071\001\094\001\066\001\035\004\066\001\
\067\001\115\003\066\001\053\002\093\001\096\001\094\001\183\002\
\097\001\022\001\099\001\100\001\099\001\100\001\004\001\097\003\
\066\002\067\002\063\003\093\001\066\001\067\001\201\002\097\001\
\022\001\099\001\100\001\027\001\117\001\096\001\023\001\076\003\
\235\003\220\004\237\003\238\003\027\001\113\001\174\002\108\001\
\003\001\027\001\111\001\117\001\108\001\233\002\234\002\111\001\
\081\001\022\001\096\001\174\002\000\001\094\001\222\002\096\001\
\224\002\027\001\226\002\227\002\096\001\027\001\094\001\165\004\
\096\001\164\003\008\001\255\002\066\001\220\004\096\001\019\001\
\190\004\015\001\023\001\188\003\067\001\067\001\026\001\092\001\
\012\003\136\003\250\002\153\003\027\001\207\002\254\002\008\001\
\030\001\211\002\149\003\019\001\210\004\066\001\015\001\192\005\
\096\001\090\001\096\001\047\001\048\001\219\004\220\004\015\003\
\017\001\059\002\188\003\027\001\003\001\030\001\096\001\008\001\
\054\001\061\001\164\002\000\001\065\001\231\003\066\001\002\001\
\032\003\069\001\192\005\071\001\066\001\000\001\096\001\110\001\
\004\001\003\001\096\001\114\001\008\001\019\001\036\001\047\003\
\048\003\003\003\014\001\015\001\068\001\243\004\018\001\193\002\
\019\001\066\001\058\003\074\003\060\003\074\003\008\001\026\001\
\084\003\096\001\067\001\067\003\068\003\014\004\081\003\071\003\
\092\003\047\001\048\001\095\003\014\001\113\001\108\001\217\002\
\119\003\111\001\014\001\068\001\047\001\048\001\067\001\061\001\
\096\001\027\001\229\004\014\001\065\001\066\001\063\001\069\001\
\067\001\071\001\061\001\108\001\014\004\013\005\111\001\067\001\
\027\001\068\001\069\001\097\001\071\001\067\001\068\001\000\000\
\000\001\063\005\064\005\014\001\004\001\065\001\029\004\000\000\
\008\001\003\001\068\001\073\005\014\001\125\003\014\001\015\001\
\136\003\035\001\018\001\131\003\096\001\144\003\066\001\067\001\
\117\001\027\001\083\004\113\001\051\004\098\001\181\003\081\001\
\003\001\093\001\146\003\000\001\065\001\066\001\113\001\004\001\
\152\003\161\003\060\001\008\001\065\001\010\001\081\001\117\001\
\066\001\014\001\015\001\163\003\055\004\018\001\166\003\066\001\
\015\001\083\004\114\001\018\001\183\003\027\001\027\001\175\003\
\126\005\098\001\022\001\067\001\092\005\000\000\069\004\191\003\
\082\004\205\003\206\003\012\001\069\004\103\004\014\001\081\001\
\104\005\045\001\046\001\112\001\094\004\197\003\104\001\219\003\
\181\005\182\005\111\001\027\001\008\001\111\001\031\001\113\001\
\096\001\065\001\210\003\155\001\094\003\067\001\067\001\215\003\
\236\003\171\003\186\003\101\003\067\001\074\001\066\001\013\001\
\049\001\050\001\051\001\177\005\000\001\229\003\065\001\093\001\
\003\001\085\001\065\001\097\001\092\001\218\005\028\001\029\001\
\093\001\094\001\066\001\096\001\097\001\076\001\010\004\072\001\
\160\005\161\005\102\001\041\001\077\001\207\003\026\001\111\001\
\004\001\001\004\000\000\029\004\008\001\086\001\115\001\014\001\
\099\001\027\001\005\000\011\004\007\000\040\001\018\001\061\001\
\067\001\227\003\064\001\091\005\111\001\222\004\103\001\069\001\
\024\004\025\004\194\005\114\001\023\000\075\001\004\001\000\001\
\032\004\243\003\008\001\065\001\082\001\048\004\038\004\096\001\
\065\001\015\001\042\004\035\001\018\001\096\001\000\001\022\001\
\216\005\067\001\019\001\056\001\222\004\027\001\111\001\060\001\
\010\001\026\001\027\001\059\004\065\001\069\004\230\005\067\001\
\110\001\000\000\117\001\092\001\060\001\239\004\074\001\014\001\
\065\001\090\001\066\001\080\001\065\001\077\004\047\001\048\001\
\065\001\111\001\102\004\028\005\027\001\105\004\111\001\112\001\
\226\003\089\004\094\001\066\001\061\001\067\001\232\003\065\001\
\234\003\114\001\065\001\068\001\069\001\096\000\071\001\090\004\
\124\004\125\004\111\001\065\001\246\003\065\001\000\000\000\001\
\104\001\022\001\028\005\115\004\031\001\085\004\111\001\111\001\
\144\004\027\001\111\001\066\001\013\001\092\001\111\001\112\001\
\128\004\099\001\130\004\131\004\132\004\157\004\049\001\050\001\
\051\001\026\001\027\001\028\001\029\001\111\001\137\000\088\005\
\113\001\112\001\065\001\142\000\143\000\149\004\000\001\171\004\
\041\001\111\001\056\001\111\001\027\001\065\001\022\001\068\001\
\058\005\067\001\077\001\065\001\188\004\065\001\134\004\162\000\
\163\000\071\005\165\000\166\000\061\001\168\000\088\005\064\001\
\026\001\065\001\067\001\068\001\069\001\000\001\000\001\178\000\
\179\000\004\001\075\001\187\004\065\001\008\001\004\001\010\001\
\111\001\082\001\008\001\014\001\067\001\031\001\065\001\018\001\
\014\001\015\001\066\001\111\001\018\001\094\001\206\004\096\001\
\027\001\098\001\099\001\111\001\220\004\208\000\209\000\049\001\
\050\001\051\001\213\000\037\001\240\004\110\001\104\004\111\001\
\113\001\225\004\108\004\065\001\117\001\102\001\000\005\027\001\
\035\001\003\005\234\004\005\005\004\001\004\001\238\004\027\001\
\008\001\008\001\229\004\077\001\111\001\022\001\200\004\015\001\
\016\005\217\004\018\001\018\001\252\004\067\001\065\001\074\001\
\065\001\060\001\000\001\227\004\065\001\066\001\004\001\066\001\
\008\005\147\004\008\001\072\001\010\001\013\005\027\001\067\001\
\014\001\111\001\093\001\094\001\044\005\096\001\097\001\067\001\
\004\001\086\001\000\000\027\005\008\001\027\001\168\004\092\001\
\032\005\066\001\000\001\015\001\000\001\096\001\018\001\065\001\
\115\001\022\001\035\001\067\001\111\001\104\001\111\001\062\005\
\114\001\062\005\111\001\112\001\111\001\053\005\067\001\000\001\
\075\001\052\001\078\005\059\005\086\005\087\005\026\001\172\005\
\090\005\065\005\003\001\060\001\054\001\095\005\056\001\037\001\
\065\001\066\001\212\004\067\001\074\001\077\005\013\001\065\001\
\066\001\026\001\075\001\083\005\067\001\111\001\018\001\067\001\
\000\001\081\001\110\005\110\001\092\005\028\001\029\001\093\001\
\094\001\072\001\096\001\097\001\100\005\069\005\085\001\040\001\
\104\005\131\005\041\001\019\001\101\001\109\005\000\000\086\001\
\250\004\000\001\026\001\027\001\111\001\115\001\111\001\022\001\
\000\001\121\005\092\001\013\001\027\001\111\001\061\001\000\001\
\111\001\064\001\150\005\090\001\014\005\067\001\069\001\047\001\
\048\001\137\005\028\001\029\001\075\001\023\001\112\001\163\005\
\026\005\171\005\026\001\082\001\143\001\061\001\037\001\041\001\
\000\001\026\001\036\001\114\001\068\001\069\001\023\001\071\001\
\160\005\161\005\004\001\098\001\099\001\056\001\008\001\096\001\
\168\005\051\005\190\005\061\001\033\001\015\001\064\001\110\001\
\018\001\203\005\204\005\069\001\000\001\176\001\067\001\065\001\
\184\005\075\001\014\001\187\005\183\001\037\001\185\001\211\005\
\082\001\193\005\194\005\056\001\191\001\000\001\066\001\060\001\
\085\001\113\001\000\001\064\001\065\001\066\001\026\001\065\001\
\098\001\099\001\000\001\206\001\207\001\213\005\234\005\227\003\
\216\005\212\001\076\001\080\001\110\001\221\005\022\001\026\001\
\224\005\067\001\000\000\097\001\026\001\229\005\230\005\243\003\
\232\005\233\005\066\001\093\001\026\001\099\001\100\001\027\001\
\072\001\097\001\000\001\066\001\027\001\054\001\128\005\056\001\
\000\001\072\001\111\001\246\001\247\001\248\001\086\001\117\001\
\065\001\066\001\004\001\254\001\018\001\033\001\008\001\086\001\
\146\005\014\001\148\005\019\001\017\001\015\001\097\001\000\000\
\018\001\012\002\026\001\014\002\158\005\022\001\027\001\065\001\
\019\002\027\001\021\002\022\002\056\001\022\001\000\001\026\002\
\060\001\028\002\076\001\095\001\064\001\065\001\066\001\047\001\
\048\001\036\002\111\001\181\005\182\005\000\001\111\001\040\001\
\096\001\019\001\188\005\016\001\080\001\061\001\095\001\010\001\
\026\001\066\001\053\002\054\002\068\001\069\001\027\001\071\001\
\111\001\067\001\061\002\205\005\066\001\110\001\111\001\066\002\
\067\002\003\001\212\005\000\001\074\001\047\001\048\001\067\001\
\218\005\076\002\077\002\111\001\222\005\010\001\081\002\075\001\
\111\001\227\005\228\005\061\001\004\001\096\001\082\001\110\001\
\008\001\085\001\068\001\069\001\041\002\071\001\065\001\015\001\
\045\002\113\001\018\001\065\001\111\001\112\001\000\001\001\001\
\002\001\003\001\000\001\027\001\065\001\066\001\008\001\009\001\
\010\001\111\001\008\001\013\001\014\001\014\001\016\001\017\001\
\018\001\019\001\020\001\021\001\000\000\128\002\024\001\025\001\
\026\001\027\001\028\001\029\001\066\001\067\001\068\001\113\001\
\095\001\111\001\036\001\037\001\065\001\066\001\040\001\041\001\
\042\001\043\001\094\001\067\001\008\001\047\001\048\001\110\001\
\111\001\066\001\067\001\000\001\159\002\067\001\068\001\000\001\
\014\001\164\002\036\001\061\001\062\001\097\001\064\001\024\002\
\025\002\067\001\068\001\069\001\074\001\071\001\019\001\014\001\
\074\001\075\001\019\001\022\001\183\002\026\001\111\001\186\002\
\082\001\026\001\084\001\092\001\022\001\027\001\193\002\000\001\
\195\002\196\002\097\001\093\001\094\001\097\001\096\001\097\001\
\098\001\099\001\047\001\048\001\207\002\096\001\047\001\105\001\
\211\002\107\001\019\001\000\001\110\001\065\001\217\002\113\001\
\061\001\026\001\000\001\117\001\061\001\003\001\000\000\068\001\
\069\001\111\001\071\001\068\001\069\001\105\001\071\001\013\001\
\014\001\094\001\111\001\094\001\066\001\094\001\047\001\242\002\
\243\002\096\001\117\001\027\001\026\001\027\001\028\001\029\001\
\117\001\020\001\046\001\014\001\061\001\065\001\022\001\063\001\
\003\003\081\001\040\001\041\001\069\001\065\001\071\001\000\001\
\011\003\014\001\013\003\004\001\113\001\014\001\022\001\008\001\
\113\001\010\001\002\001\074\001\023\003\014\001\015\001\061\001\
\027\003\018\001\064\001\076\000\066\001\067\001\068\001\069\001\
\117\001\096\001\027\001\074\001\102\001\075\001\054\001\055\001\
\056\001\057\001\015\001\000\000\082\001\066\001\094\001\065\001\
\113\001\065\001\066\001\092\001\074\001\102\001\096\001\065\001\
\094\001\094\001\096\001\108\000\098\001\099\001\065\003\065\001\
\008\001\014\001\000\001\027\001\088\001\027\001\027\001\030\001\
\110\001\065\001\067\001\113\001\065\001\126\000\014\001\117\001\
\094\001\074\001\111\001\003\001\133\000\019\001\000\000\090\003\
\014\001\088\001\049\001\094\003\026\001\096\003\097\003\111\001\
\065\001\006\001\101\003\110\001\093\001\094\001\074\001\096\001\
\097\001\111\001\065\001\066\001\027\001\112\003\097\001\096\001\
\115\003\047\001\048\001\103\001\027\001\014\001\096\001\065\001\
\096\001\124\003\115\001\040\001\000\001\090\001\021\001\061\001\
\004\001\132\003\065\001\027\001\008\001\136\003\010\001\069\001\
\139\003\071\001\014\001\015\001\065\001\063\001\063\001\016\001\
\103\001\013\001\149\003\063\001\014\001\108\001\003\001\027\001\
\111\001\054\001\055\001\056\001\057\001\014\001\161\003\066\001\
\028\001\029\001\065\001\027\001\065\001\066\001\215\000\096\001\
\171\003\074\001\102\001\054\001\096\001\041\001\074\001\008\001\
\022\001\000\000\096\001\113\001\016\001\096\001\185\003\186\003\
\076\001\188\003\076\001\190\003\191\003\027\001\096\001\067\001\
\007\000\061\001\074\001\027\001\014\001\020\001\074\001\090\001\
\000\001\069\001\114\001\096\001\207\003\074\001\209\003\075\001\
\023\000\096\001\111\001\065\001\114\001\028\000\082\001\014\001\
\093\001\093\001\094\001\019\001\096\001\097\001\000\001\226\003\
\227\003\003\001\026\001\074\001\231\003\232\003\098\001\234\003\
\021\001\014\001\014\001\013\001\014\001\014\001\014\001\115\001\
\243\003\027\001\110\001\246\003\019\001\113\001\090\001\047\001\
\026\001\027\001\028\001\029\001\001\000\002\000\003\000\004\000\
\005\000\006\000\007\000\114\001\014\001\061\001\040\001\041\001\
\027\001\093\001\014\001\014\004\068\001\069\001\022\001\071\001\
\015\001\014\001\000\000\014\001\023\004\097\001\000\000\000\000\
\111\001\098\001\098\001\061\001\094\001\111\001\064\001\008\001\
\035\004\082\001\068\001\069\001\065\001\094\001\036\001\092\001\
\036\001\075\001\094\001\000\001\047\004\044\001\045\001\046\001\
\082\001\096\001\074\001\008\001\055\004\054\001\065\001\022\001\
\013\001\113\001\065\001\065\001\094\001\054\001\096\001\066\004\
\098\001\099\001\069\004\093\001\071\004\026\001\073\004\028\001\
\029\001\072\001\073\001\146\000\110\001\065\001\065\001\113\001\
\083\004\084\004\085\004\117\001\041\001\065\001\085\001\086\001\
\087\001\088\001\065\001\162\000\163\000\164\000\165\000\166\000\
\065\001\168\000\147\001\013\001\103\004\104\004\128\000\102\001\
\061\001\108\004\028\004\178\000\179\000\222\004\067\001\068\001\
\069\001\090\004\028\001\029\001\086\004\142\001\075\001\128\005\
\088\005\056\005\171\001\199\003\009\003\082\001\056\001\041\001\
\058\001\059\001\060\001\134\004\062\001\096\002\164\001\065\001\
\066\001\208\000\209\000\130\001\255\001\098\001\213\000\146\004\
\147\004\097\002\207\003\061\001\061\002\210\002\064\001\166\000\
\098\004\110\001\099\000\069\001\113\001\102\003\192\005\188\004\
\031\004\075\001\092\001\018\005\207\001\168\004\255\255\000\000\
\082\001\099\001\198\004\174\004\007\000\188\002\255\255\255\255\
\011\000\000\001\255\255\255\255\003\001\111\001\112\001\255\255\
\098\001\099\001\255\255\190\004\191\004\255\255\013\001\255\255\
\255\255\028\000\017\001\255\255\110\001\200\004\255\255\022\001\
\203\004\255\255\255\255\026\001\027\001\028\001\029\001\210\004\
\255\255\212\004\255\255\255\255\255\255\048\000\217\004\255\255\
\219\004\220\004\041\001\222\004\255\255\255\255\255\255\255\255\
\227\004\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\239\004\052\001\061\001\255\255\
\255\255\064\001\255\255\066\001\067\001\068\001\069\001\250\004\
\083\000\255\255\085\000\086\000\075\001\255\255\069\001\255\255\
\255\255\072\001\255\255\082\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\014\005\255\255\255\255\255\255\094\001\
\255\255\096\001\000\001\098\001\099\001\255\255\004\001\026\005\
\255\255\028\005\008\001\255\255\010\001\255\255\079\002\110\001\
\014\001\000\001\113\001\084\002\018\001\040\005\117\001\042\005\
\111\001\255\255\255\255\255\255\255\255\027\001\255\255\255\255\
\051\005\255\255\255\255\255\255\019\001\124\001\255\255\000\000\
\255\255\255\255\255\255\026\001\063\005\064\005\255\255\255\255\
\255\255\255\255\069\005\255\255\255\255\255\255\073\005\162\000\
\163\000\255\255\165\000\166\000\255\255\168\000\127\002\255\255\
\047\001\048\001\255\255\255\255\255\255\088\005\255\255\178\000\
\179\000\255\255\255\255\255\255\074\001\164\001\061\001\255\255\
\255\255\188\000\255\255\255\255\255\255\255\255\069\001\255\255\
\071\001\255\255\255\255\255\255\255\255\255\255\255\255\093\001\
\094\001\162\002\096\001\097\001\255\255\208\000\209\000\255\255\
\255\255\255\255\255\255\126\005\255\255\128\005\129\005\218\000\
\255\255\255\255\255\255\255\255\255\255\115\001\255\255\255\255\
\255\255\208\001\255\255\255\255\255\255\212\001\255\255\146\005\
\255\255\148\005\113\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\158\005\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\001\
\255\255\255\255\003\001\255\255\255\255\255\255\177\005\246\001\
\247\001\248\001\181\005\182\005\013\001\255\255\255\255\254\001\
\255\255\188\005\000\001\255\255\255\255\192\005\005\002\255\255\
\255\255\026\001\027\001\028\001\029\001\255\255\013\002\255\255\
\255\255\000\000\205\005\038\001\253\002\019\001\021\002\022\002\
\041\001\212\005\255\255\026\002\026\001\028\002\255\255\218\005\
\255\255\255\255\255\255\222\005\255\255\036\002\255\255\058\001\
\227\005\228\005\041\002\255\255\061\001\255\255\045\002\255\255\
\255\255\047\001\255\255\068\001\069\001\255\255\255\255\054\002\
\000\000\255\255\075\001\255\255\255\255\255\255\061\002\061\001\
\006\001\082\001\008\001\255\255\255\255\255\255\068\001\069\001\
\255\255\071\001\255\255\255\255\053\003\255\255\077\002\096\001\
\255\255\098\001\081\002\255\255\255\255\255\255\255\255\064\003\
\255\255\066\003\255\255\255\255\111\001\110\001\255\255\255\255\
\113\001\096\002\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\125\001\126\001\255\255\255\255\129\001\255\255\
\131\001\255\255\056\001\113\001\058\001\059\001\060\001\255\255\
\062\001\255\255\255\255\065\001\066\001\255\255\103\003\000\001\
\255\255\128\002\003\001\255\255\255\255\255\255\255\255\008\001\
\255\255\010\001\255\255\255\255\013\001\014\001\255\255\016\001\
\017\001\018\001\019\001\020\001\021\001\126\003\092\001\024\001\
\025\001\026\001\131\003\028\001\029\001\099\001\255\255\255\255\
\255\255\160\002\255\255\255\255\037\001\255\255\255\255\040\001\
\041\001\111\001\112\001\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\000\000\255\255\255\255\061\001\255\255\255\255\064\001\
\255\255\212\001\255\255\068\001\069\001\255\255\071\001\255\255\
\255\255\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\207\002\082\001\187\003\210\002\211\002\255\255\255\255\192\003\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\246\001\247\001\248\001\255\255\255\255\
\105\001\255\255\107\001\254\001\255\255\110\001\255\255\255\255\
\113\001\255\255\255\255\242\002\117\001\255\255\255\255\255\255\
\255\255\255\255\013\002\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\021\002\022\002\003\003\255\255\239\003\026\002\
\255\255\028\002\255\255\255\255\011\003\255\255\013\003\255\255\
\255\255\000\001\000\001\255\255\255\255\255\255\255\255\255\255\
\023\003\255\255\255\255\255\255\255\255\255\255\013\001\255\255\
\255\255\255\255\000\000\054\002\255\255\019\001\255\255\255\255\
\255\255\255\255\061\002\026\001\026\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\052\003\255\255\032\004\
\000\001\255\255\041\001\255\255\004\001\038\004\081\002\255\255\
\008\001\047\001\010\001\255\255\255\255\255\255\014\001\255\255\
\255\255\255\255\018\001\255\255\255\255\096\002\061\001\061\001\
\255\255\064\001\255\255\027\001\255\255\255\255\069\001\069\001\
\255\255\071\001\255\255\090\003\075\001\255\255\255\255\255\255\
\255\255\096\003\097\003\082\001\255\255\255\255\255\255\007\000\
\255\255\255\255\255\255\011\000\255\255\128\002\255\255\094\001\
\255\255\255\255\255\255\098\001\115\003\255\255\255\255\118\003\
\255\255\255\255\099\004\067\001\028\000\255\255\255\255\110\001\
\255\255\255\255\074\001\113\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\048\000\255\255\255\255\255\255\255\255\093\001\094\001\255\255\
\096\001\097\001\153\003\255\255\133\004\255\255\135\004\255\255\
\137\004\255\255\255\255\140\004\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\115\001\171\003\255\255\255\255\255\255\
\255\255\255\255\155\004\083\000\255\255\085\000\086\000\255\255\
\255\255\000\001\255\255\186\003\207\002\188\003\255\255\255\255\
\211\002\255\255\255\255\172\004\173\004\255\255\013\001\255\255\
\056\001\178\004\058\001\059\001\060\001\255\255\062\001\255\255\
\207\003\065\001\066\001\026\001\255\255\028\001\029\001\255\255\
\255\255\255\255\255\255\000\000\255\255\255\255\255\255\242\002\
\080\001\255\255\041\001\083\001\227\003\206\004\255\255\255\255\
\231\003\137\000\255\255\091\001\092\001\255\255\255\255\255\255\
\003\003\255\255\255\255\099\001\243\003\255\255\061\001\255\255\
\011\003\255\255\013\003\255\255\067\001\068\001\069\001\111\001\
\112\001\255\255\162\000\163\000\075\001\165\000\166\000\255\255\
\168\000\255\255\255\255\082\001\007\000\255\255\255\255\014\004\
\255\255\255\255\178\000\179\000\255\255\016\000\255\255\255\255\
\255\255\255\255\255\255\098\001\188\000\255\255\029\004\255\255\
\255\255\255\255\000\001\255\255\255\255\003\001\255\255\110\001\
\255\255\018\005\113\001\255\255\255\255\255\255\255\255\013\001\
\208\000\209\000\255\255\017\001\051\004\255\255\255\255\032\005\
\022\001\255\255\218\000\255\255\026\001\027\001\028\001\029\001\
\000\000\255\255\255\255\255\255\255\255\046\005\255\255\255\255\
\049\005\255\255\255\255\041\001\255\255\096\003\097\003\255\255\
\255\255\255\255\255\255\000\001\083\004\255\255\085\004\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\255\255\255\255\064\001\255\255\066\001\067\001\068\001\069\001\
\103\004\100\000\255\255\255\255\085\005\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\000\
\094\001\255\255\096\001\255\255\098\001\099\001\038\001\134\004\
\255\255\255\255\255\255\056\001\255\255\058\001\059\001\060\001\
\110\001\062\001\096\000\113\001\065\001\066\001\255\255\117\001\
\171\003\255\255\058\001\132\005\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\083\001\162\000\
\163\000\188\003\165\000\166\000\255\255\168\000\091\001\092\001\
\255\255\255\255\255\255\255\255\255\255\255\255\099\001\178\000\
\179\000\255\255\255\255\255\255\207\003\255\255\167\005\168\005\
\255\255\110\001\111\001\112\001\007\000\255\255\175\005\000\001\
\255\255\200\004\255\255\255\255\255\255\255\255\255\255\111\001\
\227\003\255\255\255\255\255\255\255\255\208\000\209\000\013\001\
\255\255\255\255\217\004\000\001\255\255\125\001\126\001\222\004\
\243\003\129\001\255\255\131\001\227\004\255\255\028\001\029\001\
\013\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\239\004\255\255\255\255\041\001\255\255\026\001\255\255\028\001\
\029\001\226\005\255\255\014\004\255\255\255\255\255\255\056\001\
\255\255\058\001\059\001\060\001\041\001\062\001\255\255\061\001\
\065\001\066\001\064\001\255\255\000\000\255\255\255\255\069\001\
\176\001\255\255\255\255\255\255\255\255\075\001\255\255\183\001\
\061\001\185\001\083\001\064\001\082\001\028\005\255\255\068\001\
\069\001\255\255\091\001\092\001\255\255\255\255\075\001\255\255\
\255\255\255\255\099\001\255\255\098\001\082\001\255\255\255\255\
\255\255\255\255\255\255\255\255\212\001\255\255\111\001\112\001\
\110\001\094\001\255\255\255\255\255\255\098\001\099\001\255\255\
\083\004\255\255\255\255\255\255\255\255\255\255\069\005\090\004\
\071\005\110\001\255\255\255\255\113\001\013\001\255\255\255\255\
\255\255\255\255\255\255\255\255\103\004\255\255\246\001\247\001\
\248\001\088\005\255\255\086\001\028\001\029\001\254\001\162\000\
\163\000\255\255\165\000\166\000\255\255\168\000\255\255\255\255\
\103\005\041\001\255\255\255\255\255\255\255\255\255\255\178\000\
\179\000\255\255\255\255\000\000\111\001\021\002\022\002\255\255\
\255\255\255\255\026\002\255\255\028\002\061\001\006\001\000\001\
\064\001\255\255\003\001\255\255\255\255\069\001\255\255\255\255\
\255\255\255\255\255\255\075\001\013\001\208\000\209\000\255\255\
\255\255\255\255\082\001\255\255\255\255\255\255\054\002\255\255\
\255\255\026\001\027\001\028\001\029\001\061\002\255\255\255\255\
\159\005\255\255\098\001\099\001\255\255\255\255\255\255\255\255\
\041\001\255\255\255\255\255\255\255\255\255\255\110\001\255\255\
\056\001\081\002\058\001\059\001\060\001\200\004\062\001\255\255\
\255\255\065\001\066\001\255\255\061\001\255\255\255\255\064\001\
\096\002\143\001\067\001\068\001\069\001\255\255\255\255\255\255\
\255\255\255\255\075\001\222\004\255\255\015\001\255\255\255\255\
\255\255\082\001\229\004\255\255\092\001\255\255\255\255\255\255\
\255\255\212\001\255\255\099\001\239\004\094\001\255\255\096\001\
\128\002\098\001\099\001\255\255\255\255\255\255\255\255\111\001\
\112\001\043\001\044\001\045\001\046\001\110\001\255\255\255\255\
\113\001\255\255\192\001\255\255\117\001\255\255\255\255\255\255\
\255\255\255\255\245\001\246\001\247\001\248\001\204\001\255\255\
\255\255\067\001\255\255\254\001\255\255\000\001\072\001\073\001\
\255\255\028\005\255\255\255\255\000\001\255\255\255\255\003\001\
\255\255\255\255\255\255\085\001\086\001\087\001\088\001\183\002\
\000\000\013\001\021\002\022\002\255\255\255\255\255\255\026\002\
\255\255\028\002\255\255\255\255\102\001\255\255\026\001\027\001\
\028\001\029\001\255\255\255\255\111\001\040\002\255\255\207\002\
\255\255\255\255\255\255\211\002\255\255\041\001\255\255\255\255\
\255\255\255\255\255\255\054\002\255\255\056\001\255\255\058\001\
\059\001\060\001\061\002\062\001\255\255\088\005\065\001\066\001\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\067\001\
\068\001\069\001\242\002\255\255\103\005\255\255\081\002\075\001\
\083\001\255\255\255\255\000\000\255\255\255\255\082\001\255\255\
\091\001\092\001\255\255\003\003\255\255\255\255\255\255\255\255\
\099\001\255\255\094\001\011\003\096\001\013\003\098\001\099\001\
\255\255\006\001\255\255\000\001\111\001\112\001\255\255\255\255\
\255\255\255\255\110\001\255\255\255\255\113\001\076\002\255\255\
\013\001\117\001\255\255\255\255\255\255\128\002\255\255\255\255\
\255\255\255\255\255\255\255\255\159\005\026\001\255\255\028\001\
\029\001\212\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\041\001\255\255\255\255\255\255\
\255\255\255\255\255\255\056\001\255\255\058\001\059\001\060\001\
\000\000\062\001\255\255\255\255\065\001\066\001\255\255\255\255\
\061\001\255\255\255\255\246\001\247\001\248\001\255\255\068\001\
\069\001\255\255\255\255\254\001\255\001\255\255\075\001\255\255\
\096\003\097\003\255\255\255\255\255\255\082\001\255\255\092\001\
\255\255\255\255\255\255\000\001\255\255\255\255\099\001\255\255\
\255\255\159\002\021\002\022\002\207\002\098\001\255\255\026\002\
\211\002\028\002\111\001\112\001\255\255\255\255\255\255\255\255\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\136\003\255\255\255\255\255\255\255\255\141\003\255\255\255\255\
\030\000\031\000\255\255\054\002\255\255\255\255\255\255\242\002\
\255\255\255\255\061\002\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\056\001\255\255\058\001\059\001\060\001\
\003\003\062\001\255\255\171\003\065\001\066\001\081\002\255\255\
\011\003\255\255\013\003\255\255\255\255\255\255\255\255\255\255\
\000\001\255\255\255\255\003\001\188\003\255\255\083\001\255\255\
\255\255\255\255\255\255\255\255\255\255\013\001\091\001\092\001\
\255\255\087\000\088\000\255\255\255\255\255\255\099\001\207\003\
\255\255\255\255\026\001\255\255\028\001\029\001\255\255\255\255\
\255\255\255\255\111\001\112\001\255\255\128\002\255\255\255\255\
\255\255\041\001\255\255\227\003\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\027\003\255\255\255\255\
\255\255\255\255\255\255\243\003\000\000\061\001\255\255\255\255\
\255\255\255\255\255\255\000\001\255\255\069\001\003\001\255\255\
\255\255\255\255\255\255\075\001\255\255\096\003\097\003\255\255\
\013\001\055\003\082\001\255\255\255\255\255\255\014\004\255\255\
\255\255\255\255\255\255\065\003\255\255\026\001\027\001\028\001\
\029\001\255\255\098\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\041\001\255\255\110\001\255\255\
\255\255\113\001\255\255\134\003\207\002\045\004\255\255\255\255\
\211\002\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\255\255\255\255\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\112\003\255\255\255\255\069\004\075\001\006\001\
\000\001\008\001\255\255\255\255\255\255\082\001\124\003\242\002\
\171\003\255\255\255\255\083\004\255\255\013\001\132\003\255\255\
\255\255\094\001\090\004\096\001\255\255\098\001\099\001\255\255\
\003\003\188\003\026\001\255\255\028\001\029\001\255\255\103\004\
\011\003\110\001\013\003\255\255\113\001\255\255\255\255\255\255\
\117\001\041\001\255\255\255\255\207\003\255\255\255\255\255\255\
\255\255\056\001\255\255\058\001\059\001\060\001\172\003\062\001\
\255\255\255\255\065\001\066\001\255\255\061\001\255\255\255\255\
\227\003\255\255\255\255\185\003\255\255\069\001\255\255\255\255\
\255\255\255\255\255\255\075\001\083\001\255\255\255\255\255\255\
\243\003\255\255\082\001\255\255\091\001\092\001\000\000\255\255\
\255\255\255\255\255\255\209\003\099\001\255\255\212\003\213\003\
\255\255\255\255\098\001\255\255\255\255\255\255\255\255\255\255\
\111\001\112\001\255\255\014\004\255\255\255\255\110\001\255\255\
\255\255\113\001\255\255\255\255\255\255\096\003\097\003\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\200\004\087\001\088\001\089\001\090\001\091\001\092\001\093\001\
\094\001\095\001\096\001\097\001\098\001\099\001\100\001\101\001\
\102\001\103\001\104\001\105\001\106\001\107\001\222\004\109\001\
\255\255\255\255\255\255\255\255\255\255\229\004\255\255\255\255\
\255\255\023\004\255\255\255\255\255\255\123\001\255\255\239\004\
\255\255\255\255\255\255\255\255\000\001\035\004\002\001\003\001\
\083\004\135\001\255\255\255\255\008\001\255\255\255\255\255\255\
\255\255\013\001\255\255\255\255\255\255\017\001\018\001\019\001\
\171\003\255\255\255\255\255\255\103\004\255\255\026\001\027\001\
\028\001\029\001\255\255\255\255\066\004\255\255\255\255\255\255\
\036\001\188\003\255\255\255\255\028\005\041\001\255\255\255\255\
\255\255\255\255\255\255\047\001\048\001\255\255\255\255\255\255\
\255\255\000\000\255\255\255\255\207\003\255\255\255\255\255\255\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\067\001\
\068\001\069\001\255\255\071\001\255\255\255\255\255\255\075\001\
\227\003\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\243\003\093\001\094\001\255\255\096\001\097\001\098\001\099\001\
\088\005\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\110\001\255\255\255\255\113\001\255\255\255\255\
\255\255\117\001\255\255\014\004\255\255\200\004\255\255\255\255\
\255\255\255\255\056\001\255\255\058\001\059\001\060\001\165\004\
\062\001\255\255\255\255\065\001\066\001\255\255\255\255\255\255\
\174\004\255\255\255\255\222\004\255\255\179\004\180\004\255\255\
\255\255\255\255\255\255\255\255\255\255\083\001\255\255\255\255\
\190\004\255\255\255\255\033\002\239\004\091\001\092\001\255\255\
\255\255\255\255\255\255\255\255\042\002\099\001\000\001\255\255\
\046\002\003\001\255\255\049\002\255\255\255\255\008\001\255\255\
\010\001\111\001\112\001\013\001\014\001\219\004\255\255\017\001\
\083\004\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\000\000\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\028\005\255\255\037\001\103\004\243\004\040\001\041\001\
\255\255\255\255\255\255\255\255\255\255\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\098\002\099\002\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\255\255\064\001\255\255\
\255\255\255\255\068\001\069\001\255\255\071\001\255\255\255\255\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\136\002\093\001\094\001\088\005\096\001\097\001\
\098\001\099\001\255\255\255\255\255\255\255\255\255\255\105\001\
\255\255\107\001\056\005\255\255\110\001\255\255\255\255\113\001\
\255\255\063\005\255\255\117\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\073\005\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\056\001\200\004\058\001\059\001\
\060\001\000\001\062\001\255\255\003\001\065\001\066\001\255\255\
\255\255\008\001\255\255\010\001\255\255\000\000\013\001\014\001\
\255\255\255\255\017\001\222\004\019\001\020\001\021\001\083\001\
\255\255\024\001\025\001\026\001\255\255\028\001\029\001\091\001\
\092\001\255\255\255\255\255\255\239\004\255\255\037\001\099\001\
\126\005\040\001\041\001\129\005\255\255\255\255\255\255\255\255\
\047\001\048\001\232\002\111\001\112\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\255\255\
\255\255\064\001\255\255\255\255\255\255\068\001\069\001\255\255\
\071\001\255\255\255\255\074\001\075\001\255\255\255\255\255\255\
\255\255\028\005\255\255\082\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\177\005\018\003\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\255\255\255\255\255\255\
\255\255\255\255\105\001\255\255\107\001\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\117\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\054\003\255\255\255\255\255\255\255\255\255\255\255\255\000\000\
\255\255\255\255\255\255\255\255\255\255\088\005\255\255\255\255\
\255\255\000\001\001\001\002\001\003\001\255\255\255\255\006\001\
\007\001\008\001\009\001\010\001\011\001\012\001\013\001\014\001\
\015\001\016\001\017\001\018\001\019\001\020\001\021\001\022\001\
\255\255\024\001\025\001\026\001\027\001\028\001\029\001\030\001\
\031\001\255\255\255\255\255\255\255\255\036\001\037\001\255\255\
\110\003\040\001\041\001\042\001\043\001\044\001\045\001\046\001\
\047\001\048\001\049\001\050\001\051\001\052\001\255\255\054\001\
\055\001\056\001\057\001\255\255\255\255\060\001\061\001\062\001\
\063\001\064\001\065\001\066\001\067\001\068\001\069\001\255\255\
\071\001\072\001\073\001\074\001\075\001\255\255\077\001\078\001\
\255\255\255\255\255\255\082\001\083\001\084\001\085\001\086\001\
\087\001\088\001\089\001\255\255\091\001\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\100\001\255\255\102\001\
\103\001\255\255\105\001\106\001\107\001\108\001\000\000\110\001\
\111\001\255\255\113\001\255\255\255\255\255\255\117\001\255\255\
\255\255\255\255\255\255\255\255\255\255\000\001\001\001\002\001\
\003\001\004\001\255\255\006\001\007\001\008\001\009\001\010\001\
\011\001\012\001\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\218\003\024\001\025\001\026\001\
\027\001\028\001\029\001\030\001\031\001\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\043\001\044\001\045\001\046\001\047\001\048\001\049\001\050\001\
\051\001\052\001\255\255\054\001\055\001\056\001\057\001\255\255\
\255\255\060\001\061\001\062\001\255\255\064\001\065\001\066\001\
\067\001\068\001\069\001\255\255\071\001\072\001\073\001\074\001\
\075\001\255\255\077\001\078\001\255\255\255\255\255\255\082\001\
\083\001\084\001\085\001\086\001\087\001\088\001\089\001\255\255\
\091\001\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\100\001\255\255\102\001\103\001\000\000\105\001\106\001\
\107\001\108\001\255\255\110\001\111\001\255\255\113\001\255\255\
\255\255\255\255\117\001\255\255\255\255\255\255\255\255\000\001\
\001\001\002\001\003\001\255\255\255\255\255\255\255\255\008\001\
\009\001\010\001\255\255\255\255\013\001\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\037\001\255\255\255\255\040\001\
\041\001\042\001\043\001\044\001\045\001\046\001\047\001\048\001\
\255\255\255\255\255\255\255\255\114\004\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\062\001\255\255\064\001\
\126\004\255\255\067\001\068\001\069\001\255\255\071\001\072\001\
\073\001\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\084\001\085\001\086\001\087\001\088\001\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\000\000\255\255\102\001\255\255\255\255\
\105\001\255\255\107\001\255\255\255\255\110\001\255\255\255\255\
\113\001\175\004\176\004\177\004\117\001\255\255\000\001\001\001\
\002\001\003\001\255\255\255\255\006\001\007\001\008\001\009\001\
\010\001\011\001\012\001\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\022\001\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\030\001\031\001\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\043\001\044\001\045\001\046\001\047\001\048\001\049\001\
\050\001\051\001\052\001\255\255\054\001\055\001\056\001\057\001\
\255\255\255\255\060\001\061\001\062\001\255\255\064\001\065\001\
\066\001\067\001\068\001\069\001\255\255\071\001\072\001\073\001\
\074\001\075\001\255\255\077\001\078\001\255\255\255\255\255\255\
\082\001\083\001\084\001\085\001\086\001\087\001\088\001\089\001\
\255\255\091\001\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\100\001\000\000\102\001\103\001\255\255\105\001\
\106\001\107\001\108\001\255\255\110\001\111\001\255\255\113\001\
\255\255\255\255\255\255\117\001\255\255\000\001\001\001\002\001\
\003\001\004\001\255\255\006\001\007\001\008\001\009\001\010\001\
\011\001\012\001\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\027\001\028\001\029\001\030\001\031\001\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\043\001\044\001\045\001\046\001\047\001\048\001\049\001\050\001\
\051\001\052\001\255\255\054\001\055\001\056\001\057\001\255\255\
\255\255\060\001\061\001\062\001\255\255\064\001\065\001\066\001\
\067\001\068\001\069\001\255\255\071\001\072\001\073\001\074\001\
\075\001\255\255\077\001\078\001\255\255\255\255\255\255\082\001\
\083\001\084\001\085\001\086\001\087\001\088\001\089\001\255\255\
\091\001\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\100\001\000\000\102\001\103\001\255\255\105\001\106\001\
\107\001\108\001\255\255\110\001\111\001\255\255\113\001\255\255\
\255\255\255\255\117\001\000\001\001\001\002\001\003\001\255\255\
\255\255\006\001\007\001\008\001\009\001\010\001\011\001\012\001\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\030\001\031\001\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\043\001\044\001\
\045\001\046\001\047\001\048\001\049\001\050\001\051\001\052\001\
\255\255\054\001\055\001\056\001\057\001\255\255\255\255\060\001\
\061\001\062\001\255\255\064\001\065\001\066\001\067\001\068\001\
\069\001\255\255\071\001\072\001\073\001\074\001\075\001\255\255\
\077\001\078\001\255\255\255\255\255\255\082\001\083\001\084\001\
\085\001\086\001\087\001\088\001\089\001\255\255\091\001\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\100\001\
\000\000\102\001\103\001\255\255\105\001\106\001\107\001\108\001\
\255\255\110\001\111\001\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\255\255\000\001\001\001\002\001\003\001\255\255\
\255\255\006\001\007\001\008\001\009\001\010\001\011\001\012\001\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\030\001\031\001\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\043\001\044\001\
\045\001\046\001\047\001\048\001\049\001\050\001\051\001\052\001\
\255\255\054\001\055\001\056\001\057\001\255\255\255\255\060\001\
\061\001\062\001\255\255\064\001\065\001\066\001\067\001\068\001\
\069\001\255\255\071\001\072\001\073\001\074\001\075\001\255\255\
\077\001\078\001\255\255\255\255\255\255\082\001\083\001\084\001\
\085\001\086\001\087\001\088\001\089\001\255\255\091\001\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\100\001\
\000\000\102\001\103\001\255\255\105\001\106\001\107\001\108\001\
\255\255\110\001\111\001\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\006\001\007\001\008\001\009\001\010\001\011\001\012\001\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\030\001\031\001\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\045\001\
\046\001\047\001\048\001\049\001\050\001\051\001\052\001\255\255\
\054\001\055\001\056\001\057\001\255\255\255\255\060\001\061\001\
\062\001\255\255\064\001\065\001\066\001\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\077\001\
\078\001\255\255\255\255\255\255\082\001\083\001\084\001\085\001\
\086\001\087\001\088\001\089\001\255\255\091\001\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\100\001\000\000\
\102\001\103\001\255\255\105\001\106\001\107\001\108\001\255\255\
\110\001\111\001\255\255\113\001\255\255\255\255\255\255\117\001\
\000\001\001\001\002\001\003\001\004\001\255\255\006\001\007\001\
\008\001\009\001\010\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\255\255\255\255\
\024\001\025\001\026\001\027\001\028\001\029\001\030\001\031\001\
\255\255\255\255\255\255\255\255\036\001\037\001\255\255\255\255\
\040\001\041\001\042\001\043\001\044\001\045\001\046\001\047\001\
\048\001\049\001\050\001\051\001\052\001\255\255\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\061\001\062\001\255\255\
\064\001\065\001\066\001\067\001\068\001\069\001\255\255\071\001\
\072\001\073\001\074\001\075\001\255\255\077\001\078\001\255\255\
\255\255\255\255\082\001\083\001\084\001\085\001\086\001\087\001\
\088\001\089\001\255\255\091\001\255\255\093\001\094\001\255\255\
\096\001\097\001\098\001\255\255\255\255\000\000\102\001\103\001\
\255\255\105\001\106\001\107\001\108\001\255\255\110\001\111\001\
\255\255\113\001\255\255\255\255\255\255\117\001\255\255\255\255\
\000\001\001\001\002\001\003\001\004\001\255\255\006\001\007\001\
\008\001\009\001\010\001\011\001\012\001\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\255\255\255\255\
\024\001\025\001\026\001\027\001\028\001\029\001\030\001\031\001\
\255\255\255\255\255\255\255\255\036\001\037\001\255\255\255\255\
\040\001\041\001\042\001\043\001\044\001\045\001\046\001\047\001\
\048\001\049\001\050\001\051\001\052\001\255\255\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\061\001\062\001\255\255\
\064\001\065\001\066\001\067\001\068\001\069\001\255\255\071\001\
\072\001\073\001\074\001\075\001\255\255\077\001\078\001\255\255\
\255\255\255\255\082\001\083\001\084\001\085\001\086\001\087\001\
\088\001\089\001\255\255\091\001\255\255\093\001\094\001\255\255\
\096\001\097\001\098\001\000\000\255\255\255\255\102\001\103\001\
\255\255\105\001\106\001\107\001\108\001\255\255\110\001\111\001\
\255\255\113\001\255\255\255\255\255\255\117\001\255\255\000\001\
\001\001\002\001\003\001\004\001\255\255\006\001\007\001\008\001\
\009\001\010\001\011\001\012\001\013\001\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\027\001\028\001\029\001\030\001\031\001\255\255\
\255\255\255\255\255\255\036\001\037\001\255\255\255\255\040\001\
\041\001\042\001\043\001\044\001\045\001\046\001\047\001\048\001\
\049\001\050\001\051\001\052\001\255\255\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\061\001\062\001\255\255\064\001\
\065\001\066\001\067\001\068\001\069\001\255\255\071\001\072\001\
\073\001\074\001\075\001\255\255\077\001\078\001\255\255\255\255\
\255\255\082\001\083\001\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\091\001\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\000\000\255\255\255\255\102\001\103\001\255\255\
\105\001\106\001\107\001\108\001\255\255\110\001\111\001\255\255\
\113\001\255\255\255\255\255\255\117\001\000\001\001\001\002\001\
\003\001\255\255\255\255\255\255\255\255\008\001\009\001\010\001\
\255\255\255\255\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\255\255\024\001\025\001\026\001\
\027\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\043\001\044\001\045\001\046\001\047\001\048\001\255\255\255\255\
\255\255\052\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\062\001\255\255\064\001\255\255\255\255\
\067\001\068\001\069\001\255\255\071\001\072\001\073\001\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\083\001\084\001\085\001\086\001\087\001\088\001\255\255\255\255\
\091\001\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\100\001\000\000\102\001\255\255\255\255\105\001\106\001\
\107\001\255\255\255\255\110\001\255\255\255\255\113\001\255\255\
\255\255\255\255\117\001\000\001\001\001\002\001\003\001\255\255\
\255\255\255\255\255\255\008\001\009\001\010\001\255\255\255\255\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\043\001\044\001\
\045\001\046\001\047\001\048\001\255\255\255\255\255\255\052\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\062\001\255\255\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\071\001\072\001\073\001\074\001\075\001\255\255\
\255\255\255\255\255\255\255\255\255\255\082\001\083\001\084\001\
\085\001\086\001\087\001\088\001\255\255\255\255\091\001\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\100\001\
\000\000\102\001\255\255\255\255\105\001\106\001\107\001\255\255\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\008\001\009\001\010\001\255\255\255\255\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\045\001\
\046\001\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\085\001\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\255\255\000\000\255\255\
\102\001\255\255\255\255\105\001\255\255\107\001\255\255\255\255\
\110\001\255\255\255\255\113\001\255\255\255\255\255\255\117\001\
\255\255\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\008\001\009\001\010\001\255\255\255\255\013\001\
\014\001\015\001\016\001\017\001\255\255\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\045\001\
\046\001\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\085\001\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\000\000\255\255\
\102\001\255\255\255\255\105\001\255\255\107\001\255\255\255\255\
\110\001\255\255\255\255\113\001\255\255\255\255\255\255\117\001\
\000\001\001\001\002\001\003\001\255\255\255\255\255\255\255\255\
\008\001\009\001\010\001\255\255\255\255\013\001\014\001\015\001\
\016\001\017\001\018\001\019\001\020\001\021\001\255\255\255\255\
\024\001\025\001\026\001\027\001\028\001\029\001\255\255\255\255\
\255\255\255\255\255\255\255\255\036\001\037\001\255\255\255\255\
\040\001\041\001\042\001\043\001\044\001\045\001\046\001\047\001\
\048\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\061\001\062\001\255\255\
\064\001\255\255\255\255\067\001\068\001\069\001\255\255\071\001\
\072\001\073\001\074\001\075\001\255\255\255\255\255\255\255\255\
\255\255\255\255\082\001\255\255\084\001\085\001\086\001\087\001\
\088\001\255\255\255\255\255\255\255\255\093\001\094\001\255\255\
\096\001\097\001\098\001\255\255\000\000\255\255\102\001\255\255\
\255\255\105\001\255\255\107\001\255\255\255\255\110\001\255\255\
\255\255\113\001\255\255\255\255\255\255\117\001\000\001\001\001\
\002\001\003\001\255\255\255\255\255\255\255\255\008\001\009\001\
\010\001\255\255\255\255\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\043\001\044\001\045\001\046\001\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\062\001\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\072\001\073\001\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\084\001\085\001\086\001\087\001\088\001\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\255\255\000\000\255\255\102\001\255\255\255\255\105\001\
\255\255\107\001\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\117\001\255\255\255\255\000\001\001\001\
\002\001\003\001\255\255\255\255\255\255\255\255\008\001\009\001\
\010\001\255\255\255\255\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\043\001\044\001\045\001\046\001\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\062\001\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\072\001\073\001\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\084\001\085\001\086\001\087\001\088\001\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\000\000\255\255\255\255\102\001\255\255\255\255\105\001\
\255\255\107\001\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\117\001\000\001\001\001\002\001\003\001\
\255\255\255\255\255\255\255\255\008\001\009\001\010\001\255\255\
\255\255\013\001\014\001\015\001\016\001\017\001\018\001\019\001\
\020\001\021\001\255\255\255\255\024\001\025\001\026\001\027\001\
\028\001\029\001\255\255\255\255\255\255\255\255\255\255\255\255\
\036\001\037\001\255\255\255\255\040\001\041\001\042\001\043\001\
\044\001\045\001\046\001\047\001\048\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\061\001\062\001\255\255\064\001\255\255\255\255\067\001\
\068\001\069\001\255\255\071\001\072\001\073\001\074\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\084\001\085\001\086\001\087\001\088\001\255\255\255\255\255\255\
\255\255\093\001\094\001\255\255\096\001\097\001\098\001\000\000\
\255\255\255\255\102\001\255\255\255\255\105\001\255\255\107\001\
\255\255\255\255\110\001\255\255\255\255\113\001\255\255\255\255\
\255\255\117\001\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\008\001\009\001\010\001\255\255\255\255\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\045\001\
\255\255\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\085\001\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\000\000\255\255\
\102\001\255\255\255\255\105\001\255\255\107\001\255\255\255\255\
\110\001\255\255\255\255\113\001\255\255\255\255\255\255\117\001\
\255\255\000\001\001\001\002\001\003\001\255\255\255\255\255\255\
\255\255\008\001\009\001\010\001\255\255\255\255\013\001\014\001\
\015\001\016\001\017\001\018\001\019\001\020\001\021\001\255\255\
\255\255\024\001\025\001\026\001\027\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\036\001\037\001\255\255\
\255\255\040\001\041\001\042\001\043\001\044\001\045\001\255\255\
\047\001\048\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\062\001\
\255\255\064\001\255\255\255\255\067\001\068\001\069\001\255\255\
\071\001\072\001\073\001\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\084\001\085\001\086\001\
\087\001\088\001\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\000\000\255\255\102\001\
\255\255\255\255\105\001\255\255\107\001\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\117\001\000\001\
\001\001\002\001\003\001\255\255\255\255\255\255\255\255\008\001\
\009\001\010\001\255\255\255\255\013\001\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\037\001\255\255\255\255\040\001\
\041\001\042\001\043\001\044\001\045\001\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\062\001\255\255\064\001\
\255\255\255\255\067\001\068\001\069\001\255\255\071\001\072\001\
\073\001\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\084\001\085\001\086\001\087\001\088\001\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\000\000\255\255\102\001\255\255\255\255\
\105\001\255\255\107\001\255\255\255\255\110\001\255\255\255\255\
\113\001\255\255\255\255\255\255\117\001\255\255\000\001\001\001\
\002\001\003\001\255\255\255\255\255\255\255\255\008\001\009\001\
\010\001\255\255\255\255\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\043\001\044\001\045\001\255\255\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\062\001\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\072\001\073\001\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\084\001\085\001\086\001\087\001\088\001\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\000\000\255\255\102\001\255\255\255\255\105\001\
\255\255\107\001\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\117\001\255\255\000\001\001\001\002\001\
\003\001\255\255\255\255\255\255\255\255\255\255\009\001\010\001\
\255\255\255\255\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\027\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\043\001\044\001\045\001\046\001\047\001\048\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\062\001\255\255\064\001\255\255\255\255\
\067\001\068\001\069\001\255\255\071\001\072\001\073\001\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\084\001\085\001\086\001\087\001\088\001\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\000\000\255\255\102\001\255\255\255\255\105\001\255\255\
\107\001\255\255\255\255\110\001\255\255\255\255\113\001\255\255\
\255\255\255\255\117\001\000\001\001\001\002\001\003\001\255\255\
\255\255\255\255\255\255\255\255\009\001\010\001\255\255\255\255\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\043\001\044\001\
\045\001\046\001\047\001\048\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\062\001\255\255\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\071\001\072\001\073\001\074\001\075\001\255\255\
\255\255\255\255\255\255\255\255\255\255\082\001\255\255\084\001\
\085\001\086\001\087\001\088\001\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\000\000\
\255\255\102\001\255\255\255\255\105\001\255\255\107\001\255\255\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\255\255\009\001\010\001\255\255\255\255\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\045\001\
\046\001\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\085\001\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\000\000\255\255\
\102\001\255\255\255\255\105\001\255\255\107\001\255\255\255\255\
\110\001\255\255\255\255\113\001\255\255\255\255\255\255\117\001\
\255\255\000\001\001\001\002\001\003\001\255\255\255\255\255\255\
\255\255\008\001\009\001\010\001\255\255\255\255\013\001\014\001\
\015\001\016\001\017\001\018\001\019\001\020\001\021\001\255\255\
\255\255\024\001\025\001\026\001\027\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\036\001\037\001\255\255\
\255\255\040\001\041\001\042\001\043\001\044\001\255\255\255\255\
\047\001\048\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\062\001\
\255\255\064\001\255\255\255\255\067\001\068\001\069\001\255\255\
\071\001\072\001\073\001\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\084\001\255\255\086\001\
\087\001\088\001\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\000\000\255\255\255\255\
\255\255\255\255\105\001\255\255\107\001\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\117\001\000\001\
\001\001\002\001\003\001\255\255\255\255\255\255\255\255\008\001\
\009\001\010\001\255\255\255\255\013\001\014\001\015\001\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\037\001\255\255\255\255\040\001\
\041\001\042\001\043\001\044\001\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\062\001\255\255\064\001\
\255\255\255\255\067\001\068\001\069\001\255\255\071\001\072\001\
\073\001\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\084\001\255\255\086\001\087\001\088\001\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\000\000\255\255\255\255\255\255\255\255\
\105\001\255\255\107\001\255\255\255\255\110\001\255\255\255\255\
\113\001\255\255\255\255\255\255\117\001\255\255\000\001\001\001\
\002\001\003\001\255\255\255\255\255\255\255\255\008\001\009\001\
\010\001\255\255\255\255\013\001\014\001\015\001\016\001\017\001\
\018\001\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\043\001\044\001\255\255\255\255\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\062\001\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\072\001\073\001\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\084\001\255\255\086\001\087\001\088\001\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\000\000\255\255\255\255\255\255\255\255\105\001\
\255\255\107\001\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\117\001\255\255\000\001\001\001\002\001\
\003\001\255\255\255\255\255\255\255\255\008\001\009\001\010\001\
\255\255\255\255\013\001\014\001\015\001\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\027\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\043\001\044\001\255\255\255\255\047\001\048\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\062\001\255\255\064\001\255\255\255\255\
\067\001\068\001\069\001\255\255\071\001\072\001\073\001\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\084\001\255\255\086\001\087\001\088\001\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\000\000\255\255\255\255\255\255\255\255\105\001\255\255\
\107\001\255\255\255\255\110\001\255\255\255\255\113\001\255\255\
\255\255\255\255\117\001\000\001\001\001\002\001\003\001\255\255\
\255\255\255\255\255\255\008\001\009\001\010\001\255\255\255\255\
\013\001\014\001\015\001\016\001\017\001\018\001\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\043\001\044\001\
\255\255\255\255\047\001\048\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\062\001\255\255\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\071\001\072\001\073\001\074\001\075\001\255\255\
\255\255\255\255\255\255\255\255\255\255\082\001\255\255\084\001\
\255\255\086\001\087\001\088\001\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\000\000\
\255\255\255\255\255\255\255\255\105\001\255\255\107\001\255\255\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\008\001\009\001\010\001\255\255\255\255\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\043\001\044\001\255\255\
\255\255\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\072\001\073\001\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\255\255\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\000\000\255\255\
\255\255\255\255\255\255\105\001\255\255\107\001\255\255\255\255\
\110\001\255\255\255\255\113\001\255\255\255\255\255\255\117\001\
\255\255\000\001\001\001\002\001\003\001\255\255\255\255\255\255\
\255\255\008\001\009\001\010\001\255\255\255\255\013\001\014\001\
\015\001\016\001\017\001\018\001\019\001\020\001\021\001\255\255\
\255\255\024\001\025\001\026\001\027\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\036\001\037\001\255\255\
\255\255\040\001\041\001\042\001\043\001\044\001\045\001\046\001\
\047\001\048\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\062\001\
\255\255\255\255\255\255\255\255\067\001\068\001\069\001\255\255\
\071\001\255\255\255\255\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\084\001\085\001\255\255\
\255\255\088\001\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\000\000\255\255\102\001\
\255\255\255\255\105\001\255\255\107\001\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\117\001\000\001\
\001\001\002\001\003\001\255\255\255\255\255\255\255\255\008\001\
\009\001\010\001\255\255\255\255\013\001\014\001\255\255\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\037\001\255\255\255\255\040\001\
\041\001\042\001\255\255\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\062\001\255\255\064\001\
\255\255\255\255\255\255\068\001\069\001\255\255\071\001\255\255\
\255\255\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\084\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\000\000\255\255\255\255\255\255\255\255\
\105\001\255\255\107\001\255\255\255\255\110\001\255\255\255\255\
\113\001\255\255\255\255\255\255\117\001\255\255\000\001\001\001\
\002\001\003\001\255\255\255\255\255\255\255\255\008\001\009\001\
\010\001\255\255\255\255\013\001\014\001\255\255\016\001\017\001\
\018\001\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\037\001\255\255\255\255\040\001\041\001\
\042\001\255\255\255\255\255\255\255\255\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\062\001\255\255\064\001\255\255\
\255\255\255\255\068\001\069\001\255\255\071\001\255\255\255\255\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\084\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\000\000\255\255\255\255\255\255\255\255\105\001\
\255\255\107\001\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\117\001\255\255\000\001\001\001\002\001\
\003\001\255\255\255\255\255\255\255\255\008\001\009\001\010\001\
\255\255\255\255\013\001\014\001\255\255\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\027\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\036\001\037\001\255\255\255\255\040\001\041\001\042\001\
\255\255\255\255\255\255\255\255\047\001\048\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\062\001\255\255\064\001\255\255\255\255\
\255\255\068\001\069\001\255\255\071\001\255\255\255\255\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\084\001\255\255\255\255\000\000\255\255\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\255\255\255\255\255\255\255\255\255\255\105\001\255\255\
\107\001\255\255\255\255\110\001\255\255\255\255\113\001\255\255\
\255\255\255\255\117\001\000\001\001\001\002\001\003\001\255\255\
\255\255\255\255\255\255\008\001\009\001\010\001\255\255\255\255\
\013\001\014\001\255\255\016\001\017\001\018\001\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\026\001\027\001\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\036\001\
\037\001\255\255\255\255\040\001\041\001\042\001\255\255\255\255\
\255\255\255\255\047\001\048\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\062\001\255\255\064\001\255\255\255\255\255\255\068\001\
\069\001\255\255\071\001\255\255\255\255\074\001\075\001\255\255\
\255\255\255\255\255\255\000\000\255\255\082\001\255\255\084\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\255\255\
\255\255\255\255\255\255\255\255\105\001\255\255\107\001\255\255\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\117\001\255\255\000\001\001\001\002\001\003\001\255\255\255\255\
\255\255\255\255\008\001\009\001\010\001\255\255\255\255\013\001\
\014\001\255\255\016\001\017\001\018\001\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\037\001\
\255\255\255\255\040\001\041\001\042\001\255\255\255\255\255\255\
\255\255\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\062\001\255\255\064\001\255\255\255\255\000\000\068\001\069\001\
\255\255\071\001\255\255\255\255\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\084\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\255\255\255\255\
\255\255\255\255\255\255\105\001\000\001\107\001\255\255\003\001\
\110\001\255\255\255\255\113\001\008\001\009\001\010\001\117\001\
\255\255\013\001\014\001\255\255\016\001\017\001\018\001\019\001\
\020\001\021\001\255\255\255\255\024\001\025\001\026\001\255\255\
\028\001\029\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\037\001\255\255\255\255\040\001\041\001\255\255\255\255\
\255\255\255\255\255\255\047\001\048\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\000\000\
\068\001\069\001\255\255\071\001\255\255\255\255\074\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\084\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\093\001\094\001\255\255\096\001\097\001\098\001\099\001\
\255\255\255\255\255\255\255\255\255\255\105\001\255\255\107\001\
\255\255\255\255\110\001\000\001\255\255\113\001\003\001\255\255\
\255\255\117\001\255\255\008\001\009\001\010\001\255\255\255\255\
\013\001\014\001\255\255\016\001\017\001\018\001\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\026\001\255\255\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\037\001\255\255\255\255\040\001\041\001\255\255\255\255\255\255\
\255\255\255\255\047\001\048\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\000\000\255\255\064\001\255\255\255\255\255\255\068\001\
\069\001\255\255\071\001\255\255\255\255\074\001\075\001\255\255\
\255\255\255\255\255\255\255\255\255\255\082\001\255\255\084\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\255\255\
\255\255\255\255\255\255\255\255\105\001\000\001\107\001\255\255\
\003\001\110\001\255\255\255\255\113\001\008\001\255\255\010\001\
\117\001\255\255\013\001\014\001\255\255\016\001\017\001\018\001\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\255\255\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\037\001\255\255\255\255\040\001\041\001\255\255\
\255\255\255\255\255\255\255\255\047\001\048\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\255\255\061\001\255\255\255\255\064\001\255\255\255\255\
\255\255\068\001\069\001\255\255\071\001\255\255\255\255\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\255\255\255\255\255\255\255\255\255\255\105\001\000\001\
\107\001\255\255\003\001\110\001\255\255\255\255\113\001\008\001\
\255\255\010\001\117\001\255\255\013\001\014\001\255\255\016\001\
\017\001\018\001\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\255\255\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\037\001\255\255\255\255\040\001\
\041\001\255\255\255\255\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\000\000\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\255\255\255\255\064\001\
\255\255\255\255\255\255\068\001\069\001\255\255\071\001\255\255\
\255\255\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\255\255\255\255\255\255\255\255\255\255\
\105\001\000\001\107\001\255\255\003\001\110\001\255\255\255\255\
\113\001\008\001\255\255\010\001\117\001\255\255\013\001\014\001\
\255\255\016\001\017\001\018\001\019\001\020\001\021\001\255\255\
\255\255\024\001\025\001\026\001\255\255\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\037\001\255\255\
\255\255\040\001\041\001\255\255\255\255\255\255\255\255\255\255\
\047\001\048\001\255\255\255\255\255\255\000\000\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\255\255\
\255\255\064\001\255\255\255\255\255\255\068\001\069\001\255\255\
\071\001\255\255\255\255\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\255\255\000\001\255\255\
\255\255\003\001\105\001\255\255\107\001\255\255\008\001\110\001\
\010\001\255\255\113\001\013\001\014\001\255\255\117\001\017\001\
\255\255\019\001\020\001\021\001\255\255\255\255\024\001\025\001\
\026\001\255\255\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\037\001\255\255\255\255\040\001\041\001\
\255\255\255\255\255\255\255\255\255\255\047\001\048\001\255\255\
\255\255\255\255\000\000\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\255\255\064\001\255\255\
\255\255\255\255\068\001\069\001\255\255\071\001\255\255\255\255\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\255\255\000\001\255\255\255\255\003\001\105\001\
\255\255\107\001\255\255\008\001\110\001\010\001\255\255\113\001\
\013\001\014\001\255\255\117\001\017\001\255\255\019\001\020\001\
\021\001\255\255\255\255\024\001\025\001\026\001\255\255\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\037\001\255\255\255\255\040\001\041\001\255\255\255\255\255\255\
\255\255\255\255\047\001\048\001\255\255\255\255\255\255\000\000\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\061\001\255\255\255\255\064\001\255\255\255\255\255\255\068\001\
\069\001\255\255\071\001\255\255\255\255\074\001\075\001\255\255\
\255\255\255\255\255\255\255\255\255\255\082\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\255\255\
\255\255\255\255\255\255\255\255\105\001\000\001\107\001\255\255\
\003\001\110\001\255\255\255\255\113\001\008\001\255\255\010\001\
\117\001\255\255\013\001\014\001\255\255\255\255\017\001\255\255\
\019\001\020\001\021\001\255\255\255\255\024\001\025\001\026\001\
\255\255\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\037\001\255\255\255\255\040\001\041\001\255\255\
\255\255\255\255\255\255\255\255\047\001\048\001\255\255\255\255\
\255\255\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\255\255\255\255\064\001\255\255\255\255\
\255\255\068\001\069\001\255\255\071\001\255\255\255\255\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\255\255\000\001\255\255\255\255\003\001\105\001\255\255\
\107\001\255\255\008\001\110\001\010\001\255\255\113\001\013\001\
\014\001\255\255\117\001\017\001\255\255\019\001\020\001\021\001\
\255\255\255\255\024\001\025\001\026\001\255\255\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\037\001\
\255\255\255\255\040\001\041\001\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\255\255\000\000\064\001\255\255\255\255\255\255\068\001\069\001\
\255\255\071\001\000\000\255\255\074\001\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\255\255\000\001\
\255\255\255\255\003\001\105\001\255\255\107\001\255\255\008\001\
\110\001\010\001\255\255\113\001\013\001\014\001\255\255\117\001\
\017\001\255\255\019\001\020\001\021\001\255\255\255\255\024\001\
\025\001\026\001\255\255\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\037\001\255\255\255\255\040\001\
\041\001\255\255\255\255\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\061\001\255\255\255\255\064\001\
\255\255\255\255\255\255\068\001\069\001\255\255\071\001\255\255\
\255\255\074\001\075\001\255\255\000\000\255\255\255\255\255\255\
\255\255\082\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\255\255\255\255\255\255\255\255\255\255\
\105\001\000\001\107\001\255\255\003\001\110\001\255\255\255\255\
\113\001\008\001\255\255\010\001\117\001\255\255\013\001\014\001\
\255\255\255\255\017\001\255\255\019\001\020\001\021\001\255\255\
\255\255\024\001\025\001\026\001\255\255\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\037\001\255\255\
\255\255\040\001\041\001\255\255\255\255\255\255\255\255\255\255\
\047\001\048\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\255\255\
\255\255\064\001\255\255\255\255\255\255\068\001\069\001\255\255\
\071\001\255\255\255\255\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\000\000\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\255\255\098\001\099\001\255\255\255\255\255\255\
\255\255\255\255\105\001\255\255\107\001\255\255\255\255\110\001\
\255\255\000\001\113\001\002\001\003\001\004\001\117\001\255\255\
\255\255\008\001\000\001\255\255\255\255\255\255\013\001\255\255\
\255\255\255\255\017\001\018\001\019\001\255\255\255\255\013\001\
\255\255\255\255\255\255\026\001\027\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\026\001\036\001\028\001\029\001\
\255\255\255\255\041\001\255\255\255\255\255\255\255\255\255\255\
\047\001\048\001\056\001\041\001\058\001\059\001\060\001\255\255\
\062\001\255\255\255\255\065\001\066\001\255\255\061\001\255\255\
\255\255\064\001\065\001\255\255\067\001\068\001\069\001\061\001\
\071\001\000\000\064\001\074\001\075\001\255\255\068\001\069\001\
\255\255\255\255\255\255\082\001\255\255\075\001\092\001\255\255\
\255\255\255\255\255\255\255\255\082\001\099\001\093\001\094\001\
\255\255\096\001\097\001\098\001\099\001\255\255\255\255\102\001\
\094\001\111\001\112\001\255\255\098\001\099\001\255\255\110\001\
\111\001\255\255\113\001\255\255\000\001\255\255\117\001\003\001\
\110\001\255\255\255\255\113\001\008\001\255\255\010\001\255\255\
\255\255\013\001\014\001\255\255\255\255\017\001\255\255\019\001\
\020\001\021\001\255\255\255\255\024\001\255\255\026\001\255\255\
\028\001\029\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\037\001\255\255\255\255\040\001\041\001\255\255\255\255\
\255\255\255\255\255\255\047\001\048\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\255\255\
\068\001\069\001\255\255\071\001\255\255\255\255\074\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\093\001\094\001\255\255\096\001\097\001\098\001\099\001\
\255\255\255\255\255\255\255\255\255\255\105\001\255\255\107\001\
\255\255\255\255\110\001\255\255\000\001\113\001\002\001\003\001\
\004\001\117\001\255\255\255\255\008\001\255\255\255\255\255\255\
\255\255\013\001\255\255\255\255\255\255\017\001\018\001\019\001\
\255\255\255\255\255\255\255\255\255\255\255\255\026\001\027\001\
\028\001\029\001\255\255\255\255\255\255\255\255\255\255\255\255\
\036\001\255\255\255\255\255\255\255\255\041\001\255\255\255\255\
\255\255\255\255\255\255\047\001\048\001\000\000\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\067\001\
\068\001\069\001\255\255\071\001\255\255\255\255\074\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\093\001\094\001\255\255\096\001\097\001\098\001\099\001\
\255\255\000\001\255\255\002\001\003\001\004\001\255\255\255\255\
\255\255\008\001\110\001\255\255\255\255\113\001\013\001\255\255\
\255\255\117\001\017\001\018\001\019\001\255\255\255\255\255\255\
\255\255\255\255\255\255\026\001\027\001\028\001\029\001\255\255\
\255\255\255\255\255\255\255\255\255\255\036\001\255\255\255\255\
\255\255\255\255\041\001\255\255\255\255\255\255\255\255\255\255\
\047\001\048\001\000\000\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\255\255\
\255\255\064\001\255\255\255\255\067\001\068\001\069\001\255\255\
\071\001\255\255\255\255\074\001\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\093\001\094\001\
\255\255\096\001\097\001\098\001\255\255\255\255\000\001\102\001\
\002\001\003\001\004\001\255\255\255\255\255\255\008\001\110\001\
\255\255\255\255\113\001\013\001\255\255\255\255\117\001\017\001\
\018\001\019\001\255\255\255\255\255\255\255\255\255\255\255\255\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\255\255\255\255\255\255\255\255\041\001\
\255\255\255\255\255\255\255\255\255\255\047\001\048\001\000\000\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\255\255\255\255\
\074\001\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\255\255\255\255\255\255\102\001\000\001\255\255\002\001\
\003\001\004\001\255\255\255\255\110\001\008\001\255\255\113\001\
\255\255\255\255\013\001\117\001\255\255\255\255\017\001\018\001\
\019\001\255\255\255\255\255\255\255\255\255\255\255\255\026\001\
\027\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\036\001\255\255\255\255\255\255\255\255\041\001\255\255\
\255\255\255\255\255\255\255\255\047\001\048\001\000\000\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\061\001\255\255\255\255\064\001\255\255\255\255\
\067\001\068\001\069\001\255\255\071\001\255\255\255\255\074\001\
\075\001\255\255\255\255\255\255\255\255\255\255\255\255\082\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\255\255\000\001\255\255\002\001\003\001\004\001\255\255\
\255\255\255\255\008\001\110\001\255\255\255\255\113\001\013\001\
\255\255\255\255\117\001\017\001\018\001\019\001\255\255\255\255\
\255\255\255\255\255\255\255\255\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\036\001\255\255\
\255\255\255\255\255\255\041\001\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\000\000\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\255\255\255\255\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\071\001\255\255\255\255\255\255\075\001\255\255\255\255\
\255\255\255\255\255\255\255\255\082\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\093\001\
\094\001\255\255\096\001\097\001\098\001\099\001\255\255\000\001\
\255\255\002\001\003\001\004\001\255\255\255\255\000\000\008\001\
\110\001\255\255\255\255\113\001\013\001\255\255\255\255\117\001\
\017\001\018\001\019\001\255\255\255\255\255\255\255\255\255\255\
\255\255\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\255\255\255\255\255\255\255\255\
\041\001\255\255\255\255\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\000\000\255\255\255\255\255\255\061\001\255\255\255\255\064\001\
\255\255\255\255\067\001\068\001\069\001\255\255\071\001\255\255\
\255\255\255\255\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\093\001\094\001\255\255\096\001\
\097\001\098\001\099\001\255\255\255\255\255\255\000\001\255\255\
\002\001\003\001\004\001\255\255\255\255\110\001\008\001\255\255\
\113\001\255\255\255\255\013\001\117\001\255\255\255\255\017\001\
\018\001\019\001\255\255\255\255\255\255\255\255\255\255\255\255\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\036\001\255\255\255\255\255\255\255\255\041\001\
\255\255\255\255\255\255\255\255\255\255\047\001\048\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\000\000\071\001\255\255\255\255\
\255\255\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\093\001\094\001\255\255\096\001\097\001\
\098\001\099\001\255\255\000\001\255\255\002\001\003\001\004\001\
\255\255\255\255\255\255\008\001\110\001\255\255\255\255\113\001\
\013\001\255\255\255\255\117\001\017\001\018\001\019\001\255\255\
\255\255\255\255\255\255\255\255\255\255\026\001\027\001\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\255\255\036\001\
\255\255\255\255\255\255\255\255\041\001\255\255\255\255\255\255\
\255\255\255\255\047\001\048\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\001\255\255\
\061\001\003\001\255\255\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\071\001\013\001\255\255\255\255\075\001\255\255\
\255\255\019\001\255\255\255\255\000\000\082\001\255\255\255\255\
\026\001\027\001\028\001\029\001\255\255\255\255\255\255\255\255\
\093\001\094\001\255\255\096\001\097\001\098\001\099\001\041\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\000\001\110\001\255\255\003\001\113\001\255\255\255\255\255\255\
\117\001\255\255\255\255\061\001\255\255\013\001\064\001\255\255\
\255\255\255\255\068\001\069\001\255\255\255\255\255\255\255\255\
\255\255\075\001\026\001\027\001\028\001\029\001\255\255\255\255\
\082\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\041\001\255\255\255\255\094\001\255\255\096\001\255\255\
\098\001\099\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\110\001\061\001\255\255\113\001\
\064\001\255\255\255\255\117\001\068\001\069\001\255\255\255\255\
\255\255\255\255\255\255\075\001\255\255\255\255\255\255\000\000\
\255\255\255\255\082\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\094\001\255\255\
\096\001\255\255\098\001\099\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\110\001\255\255\
\255\255\113\001\255\255\255\255\000\001\117\001\255\255\003\001\
\255\255\005\001\006\001\007\001\008\001\255\255\255\255\011\001\
\012\001\013\001\255\255\255\255\255\255\255\255\255\255\019\001\
\255\255\255\255\255\255\255\255\255\255\255\255\026\001\255\255\
\028\001\029\001\030\001\031\001\032\001\033\001\034\001\255\255\
\036\001\255\255\255\255\039\001\255\255\041\001\255\255\255\255\
\255\255\255\255\255\255\047\001\048\001\049\001\050\001\051\001\
\052\001\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\061\001\255\255\255\255\064\001\065\001\066\001\255\255\
\068\001\069\001\070\001\071\001\072\001\073\001\255\255\075\001\
\076\001\077\001\078\001\000\000\080\001\255\255\082\001\083\001\
\255\255\255\255\086\001\087\001\255\255\089\001\255\255\091\001\
\255\255\093\001\094\001\095\001\255\255\097\001\098\001\099\001\
\255\255\255\255\255\255\103\001\255\255\255\255\106\001\255\255\
\108\001\109\001\110\001\111\001\112\001\113\001\255\255\255\255\
\116\001\005\001\006\001\007\001\255\255\255\255\255\255\011\001\
\012\001\013\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\028\001\029\001\030\001\031\001\032\001\033\001\034\001\255\255\
\255\255\255\255\255\255\039\001\255\255\041\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\061\001\255\255\255\255\064\001\065\001\066\001\255\255\
\255\255\069\001\070\001\255\255\072\001\073\001\255\255\075\001\
\255\255\077\001\078\001\255\255\080\001\000\000\082\001\255\255\
\255\255\255\255\086\001\087\001\255\255\089\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\098\001\099\001\
\255\255\255\255\255\255\103\001\255\255\255\255\255\255\255\255\
\108\001\109\001\110\001\111\001\005\001\006\001\007\001\255\255\
\116\001\255\255\011\001\012\001\013\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\028\001\029\001\030\001\031\001\032\001\
\033\001\034\001\255\255\255\255\255\255\255\255\039\001\255\255\
\041\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\061\001\255\255\255\255\064\001\
\065\001\066\001\255\255\255\255\069\001\070\001\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\078\001\255\255\080\001\
\255\255\082\001\255\255\255\255\255\255\086\001\087\001\000\000\
\089\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\099\001\255\255\255\255\255\255\103\001\255\255\
\255\255\255\255\255\255\108\001\109\001\110\001\111\001\255\255\
\255\255\255\255\255\255\116\001\255\255\255\255\255\255\255\255\
\005\001\006\001\007\001\255\255\255\255\255\255\011\001\012\001\
\013\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\028\001\
\029\001\030\001\031\001\032\001\033\001\034\001\255\255\255\255\
\255\255\255\255\039\001\255\255\041\001\255\255\255\255\255\255\
\255\255\255\255\255\255\000\000\049\001\050\001\051\001\255\255\
\053\001\054\001\055\001\056\001\057\001\255\255\255\255\060\001\
\061\001\255\255\255\255\064\001\065\001\066\001\255\255\255\255\
\069\001\070\001\255\255\072\001\073\001\255\255\075\001\255\255\
\077\001\078\001\255\255\080\001\255\255\082\001\255\255\255\255\
\255\255\086\001\087\001\255\255\089\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\099\001\255\255\
\255\255\255\255\103\001\255\255\255\255\255\255\000\000\108\001\
\109\001\110\001\111\001\255\255\255\255\000\001\255\255\116\001\
\255\255\004\001\255\255\006\001\255\255\008\001\255\255\010\001\
\255\255\012\001\013\001\014\001\015\001\255\255\017\001\018\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\026\001\
\027\001\028\001\029\001\030\001\031\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\041\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\049\001\050\001\
\051\001\052\001\053\001\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\061\001\255\255\255\255\064\001\065\001\066\001\
\067\001\068\001\069\001\255\255\000\000\072\001\255\255\074\001\
\075\001\255\255\077\001\255\255\255\255\255\255\255\255\082\001\
\083\001\255\255\255\255\086\001\255\255\255\255\255\255\255\255\
\091\001\255\255\093\001\094\001\255\255\096\001\097\001\098\001\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\106\001\
\255\255\108\001\255\255\110\001\111\001\112\001\255\255\000\001\
\115\001\255\255\255\255\004\001\255\255\006\001\255\255\008\001\
\255\255\010\001\255\255\012\001\255\255\014\001\015\001\000\000\
\017\001\018\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\027\001\255\255\255\255\030\001\031\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\049\001\050\001\051\001\052\001\255\255\054\001\255\255\056\001\
\057\001\255\255\255\255\060\001\255\255\255\255\255\255\255\255\
\065\001\066\001\067\001\255\255\255\255\255\255\255\255\072\001\
\255\255\074\001\000\000\000\001\077\001\255\255\003\001\004\001\
\255\255\255\255\083\001\255\255\255\255\086\001\255\255\255\255\
\013\001\014\001\091\001\255\255\093\001\094\001\019\001\096\001\
\097\001\255\255\099\001\255\255\255\255\026\001\103\001\028\001\
\029\001\106\001\255\255\108\001\255\255\255\255\111\001\112\001\
\255\255\255\255\115\001\255\255\041\001\255\255\255\255\255\255\
\255\255\255\255\047\001\048\001\000\000\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\001\255\255\
\061\001\003\001\004\001\064\001\255\255\255\255\067\001\068\001\
\069\001\255\255\071\001\013\001\014\001\255\255\075\001\255\255\
\255\255\019\001\255\255\255\255\255\255\082\001\255\255\255\255\
\026\001\255\255\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\094\001\255\255\096\001\255\255\098\001\099\001\041\001\
\255\255\255\255\255\255\255\255\255\255\047\001\048\001\000\000\
\255\255\110\001\255\255\255\255\113\001\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\071\001\255\255\255\255\
\255\255\075\001\255\255\255\255\000\001\255\255\255\255\003\001\
\082\001\255\255\255\255\255\255\008\001\255\255\255\255\255\255\
\255\255\013\001\014\001\255\255\094\001\255\255\096\001\019\001\
\098\001\099\001\022\001\255\255\255\255\255\255\026\001\255\255\
\028\001\029\001\000\000\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\255\255\056\001\041\001\058\001\059\001\
\060\001\255\255\062\001\255\255\255\255\065\001\066\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\001\
\255\255\061\001\003\001\004\001\064\001\255\255\066\001\067\001\
\068\001\069\001\255\255\255\255\013\001\014\001\255\255\075\001\
\092\001\255\255\019\001\255\255\255\255\081\001\082\001\099\001\
\255\255\026\001\255\255\028\001\029\001\255\255\000\000\255\255\
\255\255\255\255\094\001\111\001\112\001\255\255\098\001\099\001\
\041\001\255\255\255\255\255\255\255\255\255\255\047\001\048\001\
\255\255\255\255\110\001\255\255\255\255\113\001\255\255\255\255\
\255\255\255\255\000\001\255\255\061\001\003\001\004\001\064\001\
\255\255\255\255\255\255\068\001\069\001\255\255\071\001\013\001\
\014\001\255\255\075\001\255\255\255\255\019\001\255\255\255\255\
\255\255\082\001\255\255\255\255\026\001\000\000\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\094\001\255\255\096\001\
\255\255\098\001\099\001\041\001\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\255\255\000\001\110\001\255\255\003\001\
\113\001\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\255\255\013\001\064\001\255\255\255\255\255\255\068\001\069\001\
\255\255\071\001\255\255\255\255\255\255\075\001\026\001\027\001\
\028\001\029\001\255\255\255\255\082\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\041\001\255\255\255\255\
\094\001\255\255\096\001\255\255\098\001\099\001\255\255\255\255\
\255\255\000\000\255\255\255\255\255\255\255\255\255\255\000\001\
\110\001\061\001\003\001\113\001\255\255\065\001\255\255\067\001\
\068\001\069\001\000\000\255\255\013\001\255\255\074\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\082\001\255\255\
\255\255\026\001\027\001\028\001\029\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\096\001\255\255\098\001\099\001\
\041\001\255\255\102\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\110\001\111\001\255\255\113\001\255\255\255\255\
\255\255\255\255\000\001\255\255\061\001\003\001\255\255\255\255\
\065\001\255\255\067\001\068\001\069\001\255\255\255\255\013\001\
\255\255\074\001\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\255\255\255\255\026\001\027\001\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\096\001\
\255\255\098\001\099\001\041\001\255\255\102\001\000\000\255\255\
\255\255\255\255\255\255\255\255\255\255\110\001\111\001\255\255\
\113\001\255\255\255\255\255\255\255\255\255\255\000\001\061\001\
\255\255\003\001\255\255\065\001\255\255\067\001\068\001\069\001\
\255\255\255\255\255\255\013\001\074\001\075\001\255\255\255\255\
\255\255\019\001\255\255\255\255\082\001\255\255\255\255\255\255\
\026\001\255\255\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\096\001\255\255\098\001\099\001\040\001\041\001\
\102\001\255\255\255\255\255\255\255\255\047\001\048\001\255\255\
\110\001\111\001\255\255\113\001\255\255\000\001\255\255\255\255\
\003\001\255\255\255\255\061\001\000\000\008\001\064\001\255\255\
\255\255\255\255\013\001\069\001\255\255\071\001\000\000\255\255\
\019\001\075\001\255\255\255\255\255\255\255\255\255\255\026\001\
\082\001\028\001\029\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\094\001\255\255\041\001\255\255\
\098\001\099\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\061\001\255\255\255\255\064\001\255\255\255\255\
\067\001\068\001\069\001\255\255\255\255\255\255\255\255\074\001\
\075\001\000\001\255\255\255\255\003\001\255\255\255\255\082\001\
\255\255\008\001\000\000\255\255\255\255\255\255\013\001\255\255\
\255\255\255\255\000\001\094\001\019\001\003\001\255\255\098\001\
\099\001\255\255\008\001\026\001\255\255\028\001\029\001\013\001\
\255\255\255\255\255\255\110\001\255\255\019\001\113\001\255\255\
\255\255\255\255\041\001\255\255\026\001\255\255\028\001\029\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\041\001\000\000\255\255\061\001\255\255\
\255\255\064\001\255\255\255\255\067\001\068\001\069\001\255\255\
\255\255\255\255\255\255\074\001\075\001\255\255\255\255\061\001\
\255\255\255\255\064\001\082\001\000\000\067\001\068\001\069\001\
\255\255\255\255\255\255\255\255\074\001\075\001\255\255\094\001\
\255\255\255\255\255\255\098\001\082\001\255\255\255\255\102\001\
\255\255\255\255\255\255\255\255\255\255\255\255\000\001\110\001\
\094\001\003\001\113\001\255\255\098\001\255\255\008\001\255\255\
\102\001\255\255\255\255\013\001\255\255\255\255\255\255\255\255\
\110\001\019\001\255\255\113\001\255\255\255\255\000\000\255\255\
\026\001\255\255\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\041\001\
\255\255\255\255\056\001\255\255\058\001\059\001\060\001\255\255\
\062\001\255\255\255\255\065\001\066\001\255\255\255\255\255\255\
\255\255\255\255\255\255\061\001\255\255\075\001\064\001\255\255\
\255\255\067\001\068\001\069\001\255\255\083\001\255\255\255\255\
\074\001\075\001\255\255\255\255\000\001\091\001\092\001\003\001\
\082\001\000\000\096\001\255\255\008\001\099\001\000\001\255\255\
\255\255\013\001\255\255\255\255\094\001\255\255\255\255\019\001\
\098\001\111\001\112\001\013\001\102\001\255\255\026\001\255\255\
\028\001\029\001\255\255\255\255\110\001\255\255\255\255\113\001\
\026\001\255\255\028\001\029\001\255\255\041\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\041\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\061\001\255\255\255\255\064\001\000\000\255\255\067\001\
\068\001\069\001\255\255\061\001\255\255\255\255\074\001\075\001\
\255\255\255\255\000\001\069\001\255\255\003\001\082\001\255\255\
\255\255\075\001\008\001\255\255\255\255\255\255\255\255\013\001\
\082\001\255\255\094\001\255\255\255\255\019\001\098\001\255\255\
\255\255\255\255\102\001\255\255\026\001\255\255\028\001\029\001\
\098\001\255\255\110\001\255\255\255\255\113\001\255\255\255\255\
\255\255\255\255\255\255\041\001\110\001\255\255\255\255\113\001\
\000\000\255\255\255\255\255\255\000\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\061\001\
\255\255\013\001\064\001\255\255\255\255\067\001\068\001\069\001\
\255\255\255\255\255\255\255\255\000\001\075\001\026\001\003\001\
\028\001\029\001\255\255\255\255\082\001\255\255\255\255\255\255\
\255\255\013\001\255\255\255\255\255\255\041\001\255\255\019\001\
\094\001\255\255\255\255\255\255\098\001\099\001\026\001\255\255\
\028\001\029\001\255\255\000\000\255\255\255\255\255\255\000\000\
\110\001\061\001\255\255\113\001\255\255\041\001\255\255\255\255\
\255\255\069\001\255\255\255\255\255\255\255\255\000\001\075\001\
\255\255\003\001\255\255\255\255\255\255\255\255\082\001\255\255\
\255\255\061\001\255\255\013\001\064\001\255\255\255\255\255\255\
\068\001\069\001\255\255\255\255\255\255\255\255\098\001\075\001\
\026\001\027\001\028\001\029\001\255\255\255\255\082\001\255\255\
\255\255\255\255\110\001\255\255\088\001\113\001\000\000\041\001\
\255\255\255\255\094\001\255\255\255\255\255\255\098\001\099\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\000\001\110\001\061\001\003\001\113\001\064\001\255\255\
\255\255\008\001\068\001\069\001\255\255\255\255\013\001\255\255\
\255\255\075\001\255\255\255\255\019\001\255\255\255\255\255\255\
\082\001\255\255\255\255\026\001\255\255\028\001\029\001\255\255\
\000\000\255\255\255\255\255\255\094\001\255\255\096\001\255\255\
\098\001\099\001\041\001\255\255\255\255\255\255\255\255\255\255\
\255\255\000\000\255\255\255\255\110\001\255\255\255\255\113\001\
\255\255\255\255\255\255\255\255\255\255\000\001\061\001\255\255\
\003\001\064\001\255\255\255\255\255\255\068\001\069\001\255\255\
\255\255\255\255\013\001\255\255\075\001\255\255\255\255\255\255\
\019\001\255\255\255\255\082\001\255\255\255\255\255\255\026\001\
\255\255\028\001\029\001\255\255\255\255\255\255\255\255\094\001\
\255\255\255\255\255\255\098\001\099\001\255\255\041\001\255\255\
\255\255\255\255\255\255\255\255\000\000\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\255\255\255\255\
\000\001\255\255\061\001\003\001\255\255\064\001\255\255\255\255\
\255\255\068\001\069\001\255\255\255\255\013\001\255\255\255\255\
\075\001\255\255\255\255\019\001\255\255\255\255\255\255\082\001\
\255\255\255\255\026\001\255\255\028\001\029\001\255\255\255\255\
\255\255\255\255\255\255\094\001\255\255\255\255\000\000\098\001\
\099\001\041\001\255\255\255\255\255\255\255\255\255\255\000\000\
\255\255\255\255\255\255\110\001\255\255\255\255\113\001\255\255\
\255\255\255\255\255\255\000\001\255\255\061\001\003\001\000\001\
\064\001\255\255\255\255\255\255\068\001\069\001\255\255\255\255\
\013\001\255\255\255\255\075\001\013\001\255\255\019\001\255\255\
\255\255\255\255\082\001\255\255\255\255\026\001\255\255\028\001\
\029\001\026\001\255\255\028\001\029\001\255\255\094\001\255\255\
\255\255\000\000\098\001\099\001\041\001\255\255\255\255\255\255\
\041\001\255\255\255\255\255\255\255\255\255\255\110\001\255\255\
\255\255\113\001\255\255\255\255\255\255\255\255\000\001\255\255\
\061\001\003\001\255\255\064\001\061\001\255\255\255\255\068\001\
\069\001\255\255\255\255\013\001\069\001\255\255\075\001\255\255\
\255\255\019\001\075\001\255\255\255\255\082\001\255\255\255\255\
\026\001\082\001\028\001\029\001\255\255\255\255\255\255\255\255\
\255\255\094\001\255\255\255\255\000\000\098\001\099\001\041\001\
\255\255\098\001\255\255\255\255\255\255\255\255\255\255\255\255\
\000\001\110\001\255\255\255\255\113\001\110\001\255\255\255\255\
\113\001\255\255\255\255\061\001\255\255\013\001\064\001\255\255\
\255\255\000\001\068\001\069\001\003\001\255\255\255\255\255\255\
\255\255\075\001\026\001\255\255\028\001\029\001\013\001\255\255\
\082\001\000\000\255\255\255\255\019\001\255\255\255\255\255\255\
\255\255\041\001\255\255\026\001\094\001\028\001\029\001\255\255\
\098\001\099\001\255\255\255\255\255\255\255\255\255\255\000\000\
\255\255\255\255\041\001\255\255\110\001\061\001\255\255\113\001\
\255\255\255\255\255\255\255\255\255\255\069\001\255\255\255\255\
\255\255\255\255\255\255\075\001\000\001\255\255\061\001\003\001\
\255\255\064\001\082\001\255\255\255\255\068\001\069\001\255\255\
\255\255\013\001\255\255\255\255\075\001\255\255\255\255\019\001\
\255\255\255\255\098\001\082\001\000\000\255\255\026\001\255\255\
\028\001\029\001\255\255\255\255\255\255\255\255\110\001\094\001\
\255\255\113\001\255\255\098\001\099\001\041\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\000\001\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\008\001\000\001\
\255\255\061\001\255\255\013\001\064\001\255\255\255\255\255\255\
\068\001\069\001\255\255\255\255\013\001\255\255\000\000\075\001\
\026\001\255\255\028\001\029\001\255\255\255\255\082\001\000\000\
\255\255\026\001\255\255\028\001\029\001\255\255\255\255\041\001\
\255\255\255\255\094\001\255\255\255\255\255\255\098\001\099\001\
\041\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\000\001\110\001\061\001\255\255\113\001\064\001\255\255\
\255\255\255\255\068\001\069\001\061\001\255\255\013\001\064\001\
\255\255\075\001\255\255\068\001\069\001\255\255\255\255\255\255\
\082\001\255\255\075\001\026\001\255\255\028\001\029\001\255\255\
\255\255\082\001\255\255\255\255\094\001\255\255\255\255\255\255\
\098\001\099\001\041\001\255\255\255\255\094\001\255\255\255\255\
\255\255\098\001\099\001\255\255\110\001\000\000\255\255\113\001\
\255\255\255\255\255\255\255\255\000\001\110\001\061\001\003\001\
\113\001\064\001\255\255\255\255\255\255\068\001\069\001\255\255\
\255\255\013\001\255\255\000\000\075\001\255\255\255\255\255\255\
\255\255\255\255\255\255\082\001\255\255\255\255\026\001\255\255\
\028\001\029\001\255\255\255\255\255\255\255\255\255\255\094\001\
\255\255\000\000\255\255\098\001\099\001\041\001\255\255\255\255\
\255\255\000\001\255\255\255\255\255\255\255\255\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\255\255\013\001\255\255\
\255\255\061\001\255\255\255\255\064\001\255\255\255\255\000\001\
\255\255\069\001\003\001\026\001\255\255\028\001\029\001\075\001\
\255\255\255\255\255\255\255\255\013\001\255\255\082\001\255\255\
\255\255\255\255\041\001\255\255\255\255\255\255\255\255\255\255\
\255\255\026\001\094\001\028\001\029\001\255\255\098\001\099\001\
\255\255\255\255\255\255\255\255\255\255\255\255\061\001\040\001\
\041\001\064\001\110\001\255\255\000\001\113\001\069\001\003\001\
\000\000\255\255\255\255\255\255\075\001\255\255\255\255\255\255\
\255\255\013\001\000\000\082\001\061\001\255\255\255\255\064\001\
\255\255\255\255\255\255\068\001\069\001\255\255\026\001\094\001\
\028\001\029\001\075\001\098\001\099\001\255\255\255\255\255\255\
\255\255\082\001\255\255\255\255\040\001\041\001\255\255\110\001\
\255\255\255\255\113\001\255\255\255\255\094\001\000\001\255\255\
\255\255\098\001\099\001\255\255\255\255\255\255\008\001\000\001\
\255\255\061\001\255\255\013\001\064\001\110\001\255\255\255\255\
\068\001\069\001\255\255\255\255\013\001\255\255\255\255\075\001\
\026\001\255\255\028\001\029\001\255\255\000\000\082\001\255\255\
\255\255\026\001\255\255\028\001\029\001\255\255\255\255\041\001\
\255\255\255\255\094\001\255\255\255\255\255\255\098\001\099\001\
\041\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\110\001\061\001\255\255\255\255\064\001\255\255\
\255\255\067\001\068\001\069\001\061\001\255\255\255\255\064\001\
\255\255\075\001\067\001\068\001\069\001\255\255\255\255\000\000\
\082\001\255\255\075\001\255\255\255\255\000\001\255\255\255\255\
\003\001\082\001\255\255\255\255\094\001\255\255\255\255\255\255\
\098\001\099\001\013\001\255\255\255\255\094\001\255\255\255\255\
\255\255\098\001\099\001\000\001\110\001\255\255\003\001\026\001\
\255\255\028\001\029\001\255\255\255\255\110\001\000\000\255\255\
\013\001\255\255\255\255\255\255\255\255\040\001\041\001\255\255\
\255\255\000\001\255\255\255\255\003\001\026\001\255\255\028\001\
\029\001\255\255\255\255\255\255\255\255\255\255\013\001\255\255\
\255\255\255\255\061\001\255\255\041\001\064\001\255\255\255\255\
\255\255\255\255\069\001\026\001\255\255\028\001\029\001\255\255\
\075\001\255\255\000\000\255\255\255\255\255\255\255\255\082\001\
\061\001\255\255\041\001\064\001\255\255\255\255\255\255\068\001\
\069\001\255\255\255\255\094\001\255\255\255\255\075\001\098\001\
\099\001\255\255\255\255\255\255\255\255\082\001\061\001\255\255\
\255\255\064\001\255\255\110\001\255\255\068\001\069\001\255\255\
\255\255\094\001\255\255\255\255\075\001\098\001\099\001\000\000\
\000\001\255\255\255\255\082\001\255\255\255\255\255\255\255\255\
\008\001\110\001\000\001\255\255\255\255\013\001\255\255\094\001\
\255\255\255\255\255\255\098\001\099\001\000\000\255\255\013\001\
\255\255\255\255\026\001\255\255\028\001\029\001\000\000\110\001\
\255\255\255\255\255\255\255\255\026\001\255\255\028\001\029\001\
\255\255\041\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\041\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\061\001\255\255\255\255\
\064\001\255\255\255\255\255\255\068\001\069\001\255\255\061\001\
\255\255\255\255\064\001\075\001\255\255\000\001\068\001\069\001\
\003\001\255\255\082\001\255\255\255\255\075\001\255\255\255\255\
\255\255\255\255\013\001\255\255\082\001\255\255\094\001\255\255\
\255\255\255\255\098\001\099\001\255\255\255\255\255\255\026\001\
\094\001\028\001\029\001\255\255\098\001\099\001\110\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\041\001\255\255\
\110\001\255\255\056\001\255\255\058\001\059\001\060\001\000\001\
\062\001\255\255\255\255\065\001\066\001\255\255\255\255\255\255\
\255\255\255\255\061\001\255\255\013\001\064\001\255\255\255\255\
\255\255\255\255\069\001\255\255\255\255\083\001\255\255\255\255\
\075\001\026\001\255\255\028\001\029\001\091\001\092\001\082\001\
\255\255\255\255\255\255\255\255\255\255\099\001\000\001\255\255\
\041\001\255\255\255\255\094\001\255\255\255\255\255\255\098\001\
\099\001\111\001\112\001\013\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\110\001\061\001\255\255\255\255\064\001\
\026\001\255\255\028\001\029\001\069\001\255\255\255\255\255\255\
\255\255\255\255\075\001\255\255\255\255\255\255\255\255\041\001\
\255\255\082\001\000\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\094\001\255\255\013\001\
\255\255\098\001\099\001\061\001\255\255\255\255\064\001\255\255\
\255\255\255\255\255\255\069\001\026\001\110\001\028\001\029\001\
\255\255\075\001\255\255\255\255\255\255\255\255\255\255\255\255\
\082\001\255\255\255\255\041\001\255\255\255\255\255\255\000\001\
\255\255\255\255\255\255\255\255\094\001\255\255\255\255\255\255\
\098\001\099\001\255\255\255\255\013\001\255\255\255\255\061\001\
\255\255\255\255\064\001\255\255\110\001\000\001\255\255\069\001\
\255\255\026\001\255\255\028\001\029\001\075\001\000\001\255\255\
\255\255\255\255\013\001\255\255\082\001\255\255\255\255\255\255\
\041\001\255\255\255\255\013\001\255\255\255\255\255\255\026\001\
\094\001\028\001\029\001\255\255\098\001\099\001\255\255\255\255\
\026\001\255\255\028\001\029\001\061\001\255\255\041\001\064\001\
\110\001\255\255\255\255\255\255\069\001\255\255\255\255\041\001\
\255\255\255\255\075\001\255\255\255\255\255\255\255\255\255\255\
\255\255\082\001\061\001\255\255\255\255\064\001\255\255\255\255\
\255\255\255\255\069\001\061\001\255\255\094\001\064\001\255\255\
\075\001\098\001\099\001\069\001\255\255\255\255\255\255\082\001\
\255\255\075\001\255\255\255\255\255\255\110\001\255\255\255\255\
\082\001\255\255\255\255\094\001\255\255\255\255\255\255\098\001\
\099\001\255\255\255\255\255\255\094\001\255\255\255\255\255\255\
\098\001\099\001\000\001\110\001\255\255\255\255\255\255\005\001\
\006\001\007\001\008\001\255\255\110\001\011\001\012\001\013\001\
\014\001\255\255\255\255\255\255\255\255\019\001\255\255\255\255\
\255\255\255\255\255\255\255\255\026\001\255\255\028\001\029\001\
\030\001\031\001\032\001\033\001\034\001\255\255\255\255\255\255\
\255\255\039\001\255\255\041\001\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\049\001\050\001\051\001\052\001\053\001\
\054\001\055\001\056\001\057\001\255\255\255\255\060\001\061\001\
\255\255\255\255\064\001\065\001\066\001\067\001\255\255\069\001\
\070\001\071\001\072\001\073\001\255\255\075\001\255\255\077\001\
\078\001\255\255\080\001\255\255\082\001\083\001\255\255\255\255\
\086\001\087\001\255\255\089\001\255\255\091\001\255\255\255\255\
\094\001\095\001\255\255\255\255\098\001\099\001\255\255\255\255\
\255\255\103\001\255\255\255\255\106\001\255\255\108\001\109\001\
\110\001\111\001\112\001\113\001\255\255\255\255\116\001\000\001\
\001\001\002\001\255\255\255\255\005\001\006\001\007\001\255\255\
\009\001\255\255\011\001\012\001\255\255\255\255\015\001\016\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\027\001\255\255\255\255\030\001\031\001\032\001\
\033\001\034\001\255\255\036\001\255\255\255\255\039\001\255\255\
\255\255\042\001\043\001\044\001\045\001\046\001\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\255\255\062\001\255\255\064\001\
\065\001\066\001\255\255\255\255\255\255\070\001\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\078\001\255\255\080\001\
\255\255\255\255\255\255\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\255\255\255\255\255\255\255\255\255\255\096\001\
\255\255\255\255\255\255\100\001\255\255\102\001\103\001\255\255\
\255\255\255\255\255\255\108\001\109\001\255\255\111\001\000\001\
\001\001\002\001\255\255\116\001\005\001\006\001\007\001\255\255\
\009\001\255\255\011\001\012\001\255\255\255\255\255\255\016\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\027\001\255\255\255\255\030\001\031\001\032\001\
\033\001\034\001\255\255\036\001\255\255\255\255\039\001\255\255\
\255\255\042\001\043\001\044\001\045\001\046\001\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\255\255\062\001\255\255\064\001\
\065\001\066\001\255\255\255\255\255\255\070\001\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\078\001\255\255\080\001\
\255\255\255\255\255\255\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\255\255\255\255\255\255\255\255\255\255\096\001\
\255\255\255\255\255\255\100\001\255\255\102\001\103\001\255\255\
\255\255\255\255\255\255\108\001\109\001\255\255\111\001\000\001\
\001\001\002\001\255\255\116\001\005\001\006\001\007\001\255\255\
\009\001\255\255\011\001\012\001\255\255\255\255\255\255\016\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\027\001\255\255\255\255\030\001\031\001\032\001\
\033\001\034\001\255\255\036\001\255\255\255\255\039\001\255\255\
\255\255\042\001\043\001\044\001\045\001\046\001\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\255\255\062\001\255\255\064\001\
\065\001\066\001\255\255\255\255\255\255\070\001\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\078\001\255\255\080\001\
\255\255\255\255\255\255\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\100\001\255\255\102\001\103\001\255\255\
\255\255\255\255\000\001\108\001\109\001\255\255\111\001\005\001\
\006\001\007\001\008\001\116\001\255\255\011\001\012\001\255\255\
\255\255\255\255\255\255\255\255\255\255\019\001\255\255\255\255\
\255\255\255\255\255\255\255\255\026\001\255\255\028\001\255\255\
\030\001\031\001\032\001\033\001\034\001\255\255\255\255\255\255\
\255\255\039\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\049\001\050\001\051\001\052\001\053\001\
\054\001\055\001\056\001\057\001\255\255\255\255\060\001\061\001\
\255\255\255\255\064\001\065\001\066\001\255\255\255\255\069\001\
\070\001\071\001\072\001\073\001\255\255\255\255\255\255\077\001\
\078\001\255\255\080\001\255\255\255\255\083\001\255\255\255\255\
\086\001\087\001\255\255\089\001\255\255\091\001\255\255\255\255\
\255\255\095\001\255\255\255\255\255\255\099\001\255\255\255\255\
\255\255\103\001\255\255\255\255\106\001\255\255\108\001\109\001\
\255\255\111\001\112\001\113\001\000\001\255\255\116\001\255\255\
\255\255\005\001\006\001\007\001\255\255\255\255\255\255\011\001\
\012\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\030\001\031\001\032\001\033\001\034\001\255\255\
\255\255\255\255\255\255\039\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\255\255\255\255\255\255\064\001\065\001\066\001\255\255\
\255\255\255\255\070\001\255\255\072\001\073\001\255\255\255\255\
\255\255\077\001\078\001\255\255\080\001\255\255\255\255\255\255\
\255\255\255\255\086\001\087\001\000\001\089\001\255\255\255\255\
\255\255\005\001\006\001\007\001\096\001\255\255\255\255\011\001\
\012\001\255\255\255\255\103\001\255\255\255\255\255\255\255\255\
\108\001\109\001\255\255\111\001\255\255\255\255\255\255\255\255\
\116\001\255\255\030\001\031\001\032\001\033\001\034\001\255\255\
\255\255\255\255\255\255\039\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\255\255\255\255\255\255\064\001\065\001\066\001\255\255\
\255\255\255\255\070\001\255\255\072\001\073\001\255\255\255\255\
\255\255\077\001\078\001\255\255\080\001\255\255\255\255\255\255\
\255\255\255\255\086\001\087\001\000\001\089\001\255\255\255\255\
\255\255\005\001\006\001\007\001\096\001\255\255\255\255\011\001\
\012\001\255\255\255\255\103\001\255\255\255\255\255\255\255\255\
\108\001\109\001\255\255\111\001\255\255\255\255\255\255\255\255\
\116\001\255\255\030\001\031\001\032\001\033\001\034\001\255\255\
\255\255\255\255\255\255\039\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\255\255\255\255\255\255\064\001\065\001\066\001\255\255\
\255\255\255\255\070\001\255\255\072\001\073\001\255\255\255\255\
\255\255\077\001\078\001\255\255\080\001\255\255\255\255\255\255\
\255\255\255\255\086\001\087\001\000\001\089\001\255\255\255\255\
\255\255\005\001\006\001\007\001\096\001\255\255\255\255\011\001\
\012\001\255\255\255\255\103\001\255\255\255\255\255\255\255\255\
\108\001\109\001\255\255\111\001\255\255\255\255\255\255\255\255\
\116\001\255\255\030\001\031\001\032\001\033\001\034\001\255\255\
\255\255\255\255\255\255\039\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\055\001\056\001\057\001\255\255\255\255\
\060\001\255\255\255\255\255\255\064\001\065\001\066\001\255\255\
\255\255\255\255\070\001\255\255\072\001\073\001\255\255\255\255\
\255\255\077\001\078\001\255\255\080\001\255\255\255\255\255\255\
\255\255\255\255\086\001\087\001\255\255\089\001\255\255\255\255\
\255\255\255\255\255\255\255\255\096\001\003\001\004\001\005\001\
\255\255\255\255\255\255\103\001\255\255\011\001\255\255\013\001\
\108\001\109\001\255\255\111\001\255\255\019\001\020\001\021\001\
\116\001\255\255\024\001\025\001\026\001\255\255\028\001\029\001\
\030\001\255\255\032\001\033\001\034\001\035\001\255\255\255\255\
\255\255\039\001\040\001\041\001\255\255\255\255\255\255\255\255\
\255\255\047\001\048\001\255\255\255\255\255\255\255\255\053\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\064\001\065\001\255\255\255\255\255\255\255\255\
\070\001\071\001\255\255\255\255\255\255\075\001\076\001\255\255\
\078\001\255\255\080\001\081\001\082\001\255\255\084\001\255\255\
\255\255\255\255\255\255\255\255\090\001\255\255\255\255\255\255\
\255\255\095\001\255\255\255\255\255\255\255\255\255\255\101\001\
\000\001\255\255\104\001\105\001\004\001\107\001\108\001\109\001\
\110\001\111\001\255\255\113\001\114\001\115\001\116\001\117\001\
\255\255\017\001\255\255\019\001\255\255\255\255\022\001\255\255\
\255\255\255\255\026\001\027\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\036\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\047\001\
\048\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\061\001\255\255\255\255\
\255\255\065\001\255\255\067\001\068\001\069\001\255\255\071\001\
\255\255\255\255\074\001\255\255\255\255\255\255\255\255\000\001\
\001\001\002\001\255\255\255\255\255\255\006\001\007\001\255\255\
\009\001\255\255\255\255\012\001\092\001\093\001\015\001\016\001\
\255\255\097\001\255\255\099\001\255\255\255\255\102\001\255\255\
\255\255\255\255\027\001\028\001\255\255\030\001\031\001\111\001\
\255\255\113\001\255\255\036\001\255\255\255\255\255\255\255\255\
\255\255\042\001\043\001\044\001\045\001\046\001\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\255\255\056\001\
\057\001\255\255\255\255\060\001\255\255\062\001\255\255\255\255\
\065\001\066\001\255\255\255\255\255\255\255\255\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\255\255\255\255\255\255\
\255\255\255\255\255\255\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\255\255\255\255\255\255\255\255\255\255\096\001\
\255\255\255\255\099\001\100\001\255\255\102\001\103\001\255\255\
\255\255\255\255\255\255\108\001\255\255\255\255\111\001\112\001\
\000\001\001\001\002\001\255\255\255\255\255\255\006\001\007\001\
\255\255\009\001\255\255\255\255\012\001\255\255\255\255\255\255\
\016\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\027\001\028\001\255\255\030\001\031\001\
\255\255\255\255\255\255\255\255\036\001\255\255\255\255\255\255\
\255\255\255\255\042\001\043\001\044\001\045\001\046\001\255\255\
\255\255\049\001\050\001\051\001\255\255\053\001\054\001\255\255\
\056\001\057\001\255\255\255\255\060\001\255\255\062\001\255\255\
\255\255\065\001\066\001\255\255\255\255\255\255\255\255\255\255\
\072\001\073\001\255\255\075\001\255\255\077\001\255\255\255\255\
\255\255\255\255\255\255\255\255\084\001\085\001\086\001\087\001\
\088\001\089\001\255\255\255\255\255\255\255\255\255\255\255\255\
\096\001\255\255\255\255\099\001\100\001\255\255\102\001\103\001\
\255\255\255\255\255\255\255\255\108\001\255\255\110\001\111\001\
\112\001\000\001\001\001\002\001\255\255\255\255\255\255\006\001\
\007\001\255\255\009\001\255\255\255\255\012\001\255\255\255\255\
\255\255\016\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\027\001\028\001\255\255\030\001\
\031\001\255\255\255\255\255\255\255\255\036\001\255\255\255\255\
\255\255\255\255\255\255\042\001\043\001\044\001\045\001\046\001\
\255\255\255\255\049\001\050\001\051\001\255\255\053\001\054\001\
\255\255\056\001\057\001\255\255\255\255\060\001\255\255\062\001\
\255\255\255\255\065\001\066\001\255\255\255\255\255\255\255\255\
\255\255\072\001\073\001\255\255\075\001\255\255\077\001\255\255\
\255\255\255\255\255\255\255\255\255\255\084\001\085\001\086\001\
\087\001\088\001\089\001\255\255\255\255\255\255\255\255\255\255\
\255\255\096\001\255\255\255\255\099\001\100\001\255\255\102\001\
\103\001\255\255\255\255\255\255\255\255\108\001\255\255\110\001\
\111\001\112\001\000\001\001\001\002\001\255\255\255\255\255\255\
\006\001\007\001\255\255\009\001\255\255\255\255\012\001\255\255\
\255\255\255\255\016\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\027\001\028\001\255\255\
\030\001\031\001\255\255\255\255\255\255\255\255\036\001\255\255\
\255\255\255\255\255\255\255\255\042\001\043\001\044\001\045\001\
\046\001\255\255\255\255\049\001\050\001\051\001\255\255\053\001\
\054\001\255\255\056\001\057\001\255\255\255\255\060\001\255\255\
\062\001\255\255\255\255\065\001\066\001\255\255\255\255\255\255\
\255\255\255\255\072\001\073\001\255\255\075\001\255\255\077\001\
\255\255\255\255\255\255\255\255\255\255\255\255\084\001\085\001\
\086\001\087\001\088\001\089\001\255\255\255\255\255\255\255\255\
\255\255\255\255\096\001\255\255\255\255\099\001\100\001\255\255\
\102\001\103\001\255\255\255\255\255\255\255\255\108\001\255\255\
\110\001\111\001\112\001\000\001\001\001\002\001\255\255\255\255\
\255\255\006\001\007\001\255\255\009\001\255\255\255\255\012\001\
\255\255\255\255\255\255\016\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\027\001\028\001\
\255\255\030\001\031\001\255\255\255\255\255\255\255\255\036\001\
\255\255\255\255\255\255\255\255\255\255\042\001\043\001\044\001\
\045\001\046\001\255\255\255\255\049\001\050\001\051\001\255\255\
\053\001\054\001\255\255\056\001\057\001\255\255\255\255\060\001\
\255\255\062\001\255\255\000\001\065\001\066\001\255\255\255\255\
\255\255\006\001\255\255\072\001\073\001\255\255\075\001\012\001\
\077\001\255\255\255\255\255\255\255\255\255\255\255\255\084\001\
\085\001\086\001\087\001\088\001\089\001\255\255\255\255\028\001\
\255\255\030\001\031\001\096\001\255\255\255\255\099\001\100\001\
\255\255\102\001\103\001\255\255\255\255\255\255\255\255\108\001\
\255\255\255\255\111\001\112\001\049\001\050\001\051\001\255\255\
\053\001\054\001\255\255\056\001\057\001\255\255\255\255\060\001\
\255\255\255\255\255\255\000\001\065\001\066\001\255\255\255\255\
\255\255\006\001\255\255\072\001\255\255\255\255\255\255\012\001\
\077\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\086\001\255\255\255\255\255\255\255\255\255\255\028\001\
\255\255\030\001\031\001\255\255\255\255\255\255\099\001\255\255\
\255\255\255\255\103\001\255\255\255\255\255\255\255\255\108\001\
\255\255\255\255\111\001\112\001\049\001\050\001\051\001\255\255\
\053\001\054\001\255\255\056\001\057\001\255\255\255\255\060\001\
\255\255\255\255\255\255\000\001\065\001\066\001\255\255\255\255\
\255\255\006\001\255\255\072\001\255\255\255\255\255\255\012\001\
\077\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\086\001\255\255\255\255\255\255\255\255\255\255\028\001\
\255\255\030\001\031\001\255\255\255\255\255\255\099\001\255\255\
\255\255\255\255\103\001\255\255\255\255\255\255\255\255\108\001\
\255\255\255\255\111\001\112\001\049\001\050\001\051\001\255\255\
\053\001\054\001\255\255\056\001\057\001\255\255\255\255\060\001\
\255\255\255\255\255\255\255\255\065\001\066\001\255\255\255\255\
\255\255\255\255\255\255\072\001\255\255\255\255\255\255\255\255\
\077\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\086\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\099\001\255\255\
\255\255\255\255\103\001\255\255\255\255\255\255\255\255\108\001\
\255\255\255\255\111\001\112\001\005\001\006\001\007\001\255\255\
\255\255\255\255\011\001\012\001\013\001\014\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\028\001\029\001\030\001\031\001\032\001\
\033\001\034\001\255\255\255\255\255\255\255\255\039\001\255\255\
\041\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\061\001\255\255\255\255\064\001\
\065\001\066\001\255\255\255\255\069\001\070\001\255\255\072\001\
\073\001\255\255\075\001\255\255\077\001\078\001\255\255\080\001\
\255\255\082\001\255\255\255\255\255\255\086\001\087\001\255\255\
\089\001\255\255\091\001\255\255\255\255\005\001\006\001\007\001\
\255\255\098\001\255\255\011\001\012\001\013\001\103\001\255\255\
\255\255\255\255\255\255\108\001\109\001\110\001\111\001\255\255\
\255\255\255\255\255\255\116\001\028\001\029\001\030\001\031\001\
\032\001\033\001\034\001\255\255\255\255\255\255\255\255\039\001\
\255\255\041\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\049\001\050\001\051\001\255\255\053\001\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\061\001\255\255\255\255\
\064\001\065\001\066\001\255\255\255\255\069\001\070\001\255\255\
\072\001\073\001\255\255\075\001\255\255\077\001\078\001\255\255\
\080\001\255\255\082\001\255\255\255\255\255\255\086\001\087\001\
\255\255\089\001\255\255\255\255\255\255\005\001\006\001\007\001\
\255\255\255\255\098\001\011\001\012\001\255\255\255\255\103\001\
\255\255\255\255\255\255\255\255\108\001\109\001\110\001\111\001\
\255\255\255\255\255\255\255\255\116\001\255\255\030\001\031\001\
\032\001\033\001\034\001\255\255\255\255\255\255\255\255\039\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\049\001\050\001\051\001\255\255\053\001\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\255\255\255\255\255\255\
\064\001\065\001\066\001\255\255\255\255\255\255\070\001\255\255\
\072\001\073\001\255\255\255\255\255\255\077\001\078\001\255\255\
\080\001\255\255\255\255\255\255\255\255\255\255\086\001\087\001\
\255\255\089\001\255\255\255\255\255\255\255\255\094\001\005\001\
\006\001\007\001\255\255\255\255\010\001\011\001\012\001\103\001\
\255\255\255\255\255\255\255\255\108\001\109\001\255\255\111\001\
\255\255\255\255\255\255\255\255\116\001\255\255\255\255\255\255\
\030\001\031\001\032\001\033\001\034\001\255\255\255\255\255\255\
\255\255\039\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\049\001\050\001\051\001\255\255\053\001\
\054\001\055\001\056\001\057\001\255\255\255\255\060\001\255\255\
\255\255\255\255\064\001\065\001\066\001\255\255\255\255\255\255\
\070\001\255\255\072\001\073\001\255\255\255\255\255\255\077\001\
\078\001\255\255\080\001\255\255\255\255\255\255\255\255\255\255\
\086\001\087\001\255\255\089\001\255\255\255\255\005\001\006\001\
\007\001\255\255\255\255\255\255\011\001\012\001\255\255\255\255\
\255\255\103\001\255\255\255\255\255\255\255\255\108\001\109\001\
\255\255\111\001\255\255\026\001\255\255\255\255\116\001\030\001\
\031\001\032\001\033\001\034\001\255\255\255\255\255\255\255\255\
\039\001\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\049\001\050\001\051\001\255\255\053\001\054\001\
\055\001\056\001\057\001\255\255\255\255\060\001\255\255\255\255\
\255\255\064\001\065\001\066\001\255\255\255\255\255\255\070\001\
\255\255\072\001\073\001\255\255\255\255\255\255\077\001\078\001\
\255\255\080\001\255\255\255\255\255\255\255\255\255\255\086\001\
\087\001\255\255\089\001\255\255\255\255\005\001\006\001\007\001\
\255\255\255\255\255\255\011\001\012\001\255\255\255\255\255\255\
\103\001\255\255\255\255\255\255\255\255\108\001\109\001\255\255\
\111\001\255\255\026\001\255\255\255\255\116\001\030\001\031\001\
\032\001\033\001\034\001\255\255\255\255\255\255\255\255\039\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\049\001\050\001\051\001\255\255\053\001\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\255\255\255\255\255\255\
\064\001\065\001\066\001\255\255\255\255\255\255\070\001\255\255\
\072\001\073\001\255\255\255\255\255\255\077\001\078\001\255\255\
\080\001\255\255\255\255\255\255\255\255\255\255\086\001\087\001\
\255\255\089\001\255\255\255\255\005\001\006\001\007\001\255\255\
\255\255\255\255\011\001\012\001\255\255\255\255\255\255\103\001\
\255\255\255\255\255\255\255\255\108\001\109\001\255\255\111\001\
\255\255\255\255\255\255\255\255\116\001\030\001\031\001\032\001\
\033\001\034\001\255\255\255\255\255\255\255\255\039\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\255\255\255\255\255\255\064\001\
\065\001\066\001\255\255\255\255\255\255\070\001\255\255\072\001\
\073\001\255\255\255\255\255\255\077\001\078\001\255\255\080\001\
\255\255\255\255\255\255\255\255\255\255\086\001\087\001\255\255\
\089\001\255\255\255\255\005\001\006\001\007\001\255\255\255\255\
\255\255\011\001\012\001\255\255\255\255\255\255\103\001\255\255\
\255\255\255\255\255\255\108\001\109\001\255\255\111\001\255\255\
\255\255\255\255\255\255\116\001\030\001\031\001\032\001\033\001\
\034\001\255\255\255\255\255\255\255\255\039\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\049\001\
\050\001\051\001\255\255\053\001\054\001\055\001\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\064\001\065\001\
\066\001\255\255\255\255\255\255\070\001\255\255\072\001\073\001\
\255\255\255\255\255\255\077\001\078\001\255\255\080\001\255\255\
\255\255\255\255\255\255\255\255\086\001\087\001\255\255\089\001\
\255\255\255\255\255\255\006\001\255\255\255\255\255\255\255\255\
\255\255\012\001\255\255\014\001\255\255\103\001\017\001\255\255\
\255\255\255\255\108\001\109\001\255\255\111\001\255\255\255\255\
\027\001\255\255\116\001\030\001\031\001\056\001\255\255\058\001\
\059\001\060\001\255\255\062\001\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\255\255\255\255\255\255\049\001\050\001\
\051\001\052\001\255\255\054\001\255\255\056\001\057\001\255\255\
\083\001\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\091\001\092\001\255\255\255\255\255\255\072\001\006\001\255\255\
\099\001\255\255\077\001\255\255\012\001\255\255\014\001\255\255\
\083\001\017\001\255\255\086\001\111\001\112\001\255\255\255\255\
\091\001\255\255\255\255\027\001\255\255\255\255\030\001\031\001\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\106\001\
\255\255\108\001\255\255\255\255\111\001\112\001\255\255\255\255\
\255\255\049\001\050\001\051\001\052\001\255\255\054\001\255\255\
\056\001\057\001\255\255\255\255\060\001\255\255\255\255\255\255\
\255\255\065\001\066\001\255\255\255\255\255\255\255\255\255\255\
\072\001\006\001\255\255\255\255\255\255\077\001\255\255\012\001\
\255\255\014\001\255\255\083\001\255\255\255\255\086\001\255\255\
\255\255\255\255\255\255\091\001\255\255\255\255\027\001\255\255\
\255\255\030\001\031\001\099\001\255\255\255\255\255\255\103\001\
\255\255\255\255\106\001\255\255\108\001\255\255\255\255\111\001\
\112\001\255\255\255\255\255\255\049\001\050\001\051\001\052\001\
\255\255\054\001\255\255\056\001\057\001\255\255\255\255\060\001\
\255\255\255\255\255\255\255\255\065\001\066\001\255\255\255\255\
\255\255\255\255\255\255\072\001\006\001\255\255\255\255\255\255\
\077\001\255\255\012\001\255\255\014\001\255\255\083\001\255\255\
\255\255\086\001\255\255\255\255\255\255\255\255\091\001\255\255\
\255\255\027\001\255\255\255\255\030\001\031\001\099\001\255\255\
\255\255\255\255\103\001\255\255\255\255\106\001\255\255\108\001\
\255\255\255\255\111\001\112\001\255\255\255\255\255\255\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\255\255\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\255\255\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\074\001\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\255\255\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\074\001\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\255\255\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\255\255\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\255\255\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\255\255\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\255\255\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\052\001\255\255\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\006\001\255\255\072\001\255\255\
\255\255\255\255\012\001\077\001\255\255\255\255\255\255\255\255\
\255\255\083\001\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\091\001\028\001\255\255\030\001\031\001\255\255\255\255\
\255\255\099\001\255\255\255\255\255\255\103\001\255\255\255\255\
\106\001\255\255\108\001\255\255\255\255\111\001\112\001\049\001\
\050\001\051\001\255\255\053\001\054\001\255\255\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\255\255\255\255\255\255\072\001\255\255\
\255\255\255\255\006\001\077\001\255\255\255\255\010\001\255\255\
\012\001\255\255\255\255\255\255\086\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\094\001\255\255\255\255\255\255\
\028\001\099\001\030\001\031\001\255\255\103\001\255\255\255\255\
\255\255\255\255\108\001\255\255\255\255\111\001\112\001\255\255\
\255\255\255\255\255\255\255\255\255\255\049\001\050\001\051\001\
\255\255\053\001\054\001\255\255\056\001\057\001\255\255\255\255\
\060\001\255\255\255\255\255\255\255\255\065\001\066\001\255\255\
\255\255\255\255\255\255\255\255\072\001\006\001\255\255\008\001\
\255\255\077\001\255\255\012\001\255\255\255\255\255\255\255\255\
\255\255\255\255\086\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\028\001\255\255\030\001\031\001\099\001\
\255\255\255\255\255\255\103\001\255\255\255\255\255\255\255\255\
\108\001\255\255\255\255\111\001\112\001\255\255\255\255\255\255\
\049\001\050\001\051\001\255\255\053\001\054\001\255\255\056\001\
\057\001\255\255\255\255\060\001\255\255\255\255\255\255\255\255\
\065\001\066\001\255\255\255\255\255\255\006\001\255\255\072\001\
\255\255\255\255\255\255\012\001\077\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\086\001\255\255\255\255\
\255\255\255\255\255\255\028\001\255\255\030\001\031\001\255\255\
\255\255\255\255\099\001\255\255\255\255\255\255\103\001\255\255\
\255\255\255\255\255\255\108\001\255\255\255\255\111\001\112\001\
\049\001\050\001\051\001\255\255\053\001\054\001\255\255\056\001\
\057\001\255\255\255\255\060\001\255\255\255\255\255\255\255\255\
\065\001\066\001\255\255\255\255\255\255\255\255\255\255\072\001\
\255\255\255\255\255\255\006\001\077\001\255\255\255\255\255\255\
\255\255\012\001\255\255\255\255\255\255\086\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\095\001\255\255\
\255\255\028\001\099\001\030\001\031\001\255\255\103\001\255\255\
\255\255\255\255\255\255\108\001\255\255\255\255\111\001\112\001\
\255\255\255\255\255\255\255\255\255\255\255\255\049\001\050\001\
\051\001\255\255\053\001\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\006\001\255\255\072\001\255\255\255\255\
\255\255\012\001\077\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\086\001\255\255\255\255\255\255\255\255\
\255\255\028\001\255\255\030\001\031\001\255\255\255\255\255\255\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\255\255\
\255\255\108\001\255\255\255\255\111\001\112\001\049\001\050\001\
\051\001\255\255\053\001\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\006\001\255\255\072\001\255\255\255\255\
\255\255\012\001\077\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\086\001\255\255\255\255\255\255\255\255\
\255\255\028\001\255\255\030\001\031\001\255\255\255\255\255\255\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\255\255\
\255\255\108\001\255\255\255\255\111\001\112\001\049\001\050\001\
\051\001\255\255\053\001\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\006\001\255\255\072\001\255\255\255\255\
\255\255\012\001\077\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\086\001\255\255\255\255\255\255\255\255\
\255\255\028\001\255\255\030\001\031\001\255\255\255\255\255\255\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\255\255\
\255\255\108\001\255\255\255\255\111\001\112\001\049\001\050\001\
\051\001\255\255\053\001\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\006\001\255\255\072\001\255\255\255\255\
\255\255\012\001\077\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\086\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\030\001\031\001\255\255\255\255\255\255\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\255\255\
\255\255\108\001\255\255\255\255\111\001\112\001\049\001\050\001\
\051\001\255\255\255\255\054\001\255\255\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\255\255\255\255\255\255\072\001\006\001\007\001\
\255\255\255\255\077\001\011\001\012\001\255\255\255\255\255\255\
\255\255\255\255\255\255\086\001\255\255\255\255\022\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\030\001\031\001\
\099\001\255\255\255\255\255\255\103\001\255\255\255\255\255\255\
\255\255\108\001\255\255\255\255\111\001\112\001\255\255\255\255\
\255\255\049\001\050\001\051\001\052\001\255\255\054\001\055\001\
\056\001\057\001\255\255\255\255\060\001\255\255\255\255\255\255\
\255\255\065\001\066\001\255\255\255\255\006\001\007\001\255\255\
\255\255\255\255\011\001\012\001\255\255\077\001\078\001\255\255\
\255\255\255\255\255\255\083\001\255\255\255\255\255\255\255\255\
\255\255\089\001\255\255\091\001\255\255\030\001\031\001\255\255\
\255\255\255\255\255\255\099\001\100\001\255\255\255\255\103\001\
\255\255\255\255\106\001\255\255\108\001\255\255\255\255\111\001\
\049\001\050\001\051\001\052\001\255\255\054\001\055\001\056\001\
\057\001\255\255\255\255\060\001\255\255\255\255\255\255\255\255\
\065\001\066\001\255\255\255\255\006\001\007\001\255\255\255\255\
\255\255\011\001\012\001\255\255\077\001\078\001\255\255\255\255\
\255\255\255\255\083\001\255\255\255\255\255\255\255\255\255\255\
\089\001\255\255\091\001\255\255\030\001\031\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\103\001\255\255\
\255\255\106\001\255\255\108\001\255\255\255\255\111\001\049\001\
\050\001\051\001\255\255\255\255\054\001\055\001\056\001\057\001\
\255\255\255\255\060\001\255\255\255\255\255\255\255\255\065\001\
\066\001\255\255\255\255\006\001\007\001\255\255\255\255\255\255\
\011\001\012\001\255\255\077\001\078\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\089\001\
\255\255\255\255\255\255\030\001\031\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\103\001\255\255\255\255\
\255\255\255\255\108\001\255\255\255\255\111\001\049\001\050\001\
\051\001\255\255\255\255\054\001\055\001\056\001\057\001\255\255\
\255\255\060\001\255\255\255\255\255\255\255\255\065\001\066\001\
\255\255\255\255\006\001\007\001\255\255\255\255\255\255\011\001\
\012\001\255\255\077\001\078\001\255\255\255\255\255\255\255\255\
\255\255\255\255\008\001\255\255\255\255\255\255\089\001\255\255\
\255\255\015\001\030\001\031\001\056\001\255\255\058\001\059\001\
\060\001\023\001\062\001\255\255\103\001\065\001\066\001\255\255\
\030\001\108\001\255\255\255\255\111\001\049\001\050\001\051\001\
\255\255\255\255\054\001\055\001\056\001\057\001\255\255\083\001\
\060\001\255\255\255\255\255\255\255\255\065\001\066\001\091\001\
\092\001\255\255\056\001\255\255\058\001\059\001\060\001\099\001\
\062\001\077\001\078\001\065\001\066\001\255\255\255\255\255\255\
\255\255\008\001\110\001\111\001\112\001\089\001\255\255\255\255\
\015\001\255\255\255\255\255\255\255\255\083\001\255\255\255\255\
\255\255\255\255\255\255\103\001\090\001\091\001\092\001\030\001\
\108\001\255\255\255\255\111\001\255\255\099\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\108\001\255\255\
\255\255\111\001\112\001\255\255\255\255\255\255\255\255\255\255\
\255\255\056\001\255\255\058\001\059\001\060\001\255\255\062\001\
\255\255\255\255\065\001\066\001\255\255\255\255\255\255\255\255\
\000\001\001\001\002\001\255\255\255\255\255\255\255\255\255\255\
\255\255\009\001\255\255\255\255\083\001\255\255\014\001\015\001\
\016\001\017\001\018\001\255\255\091\001\092\001\255\255\255\255\
\255\255\255\255\255\255\027\001\099\001\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\036\001\108\001\255\255\255\255\
\111\001\112\001\042\001\043\001\044\001\045\001\046\001\000\001\
\001\001\002\001\255\255\255\255\255\255\255\255\007\001\255\255\
\009\001\255\255\255\255\255\255\255\255\255\255\062\001\016\001\
\255\255\255\255\255\255\067\001\255\255\255\255\255\255\255\255\
\072\001\073\001\027\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\036\001\084\001\085\001\086\001\087\001\
\088\001\042\001\043\001\044\001\045\001\046\001\255\255\255\255\
\096\001\255\255\255\255\255\255\255\255\255\255\102\001\255\255\
\255\255\255\255\255\255\255\255\255\255\062\001\255\255\255\255\
\255\255\001\001\002\001\255\255\255\255\255\255\255\255\072\001\
\073\001\009\001\075\001\255\255\255\255\255\255\255\255\015\001\
\016\001\255\255\018\001\084\001\085\001\086\001\087\001\088\001\
\089\001\255\255\255\255\027\001\255\255\255\255\255\255\255\255\
\255\255\001\001\002\001\100\001\036\001\102\001\255\255\255\255\
\255\255\009\001\042\001\043\001\044\001\045\001\046\001\015\001\
\016\001\255\255\018\001\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\027\001\255\255\255\255\062\001\255\255\
\255\255\255\255\255\255\067\001\036\001\255\255\255\255\255\255\
\072\001\073\001\042\001\043\001\044\001\045\001\046\001\255\255\
\255\255\255\255\255\255\255\255\084\001\085\001\086\001\087\001\
\088\001\255\255\255\255\255\255\255\255\255\255\062\001\001\001\
\002\001\097\001\255\255\067\001\255\255\255\255\102\001\009\001\
\072\001\073\001\255\255\255\255\255\255\015\001\016\001\255\255\
\018\001\255\255\255\255\255\255\084\001\085\001\086\001\087\001\
\088\001\027\001\255\255\255\255\255\255\093\001\255\255\001\001\
\002\001\255\255\036\001\255\255\255\255\255\255\102\001\009\001\
\042\001\043\001\044\001\045\001\046\001\015\001\016\001\255\255\
\018\001\255\255\255\255\255\255\255\255\255\255\255\255\025\001\
\255\255\027\001\255\255\255\255\062\001\255\255\255\255\255\255\
\255\255\067\001\036\001\255\255\255\255\255\255\072\001\073\001\
\042\001\043\001\044\001\045\001\046\001\255\255\255\255\255\255\
\255\255\255\255\084\001\085\001\086\001\087\001\088\001\255\255\
\255\255\255\255\255\255\093\001\062\001\001\001\002\001\255\255\
\255\255\067\001\255\255\255\255\102\001\009\001\072\001\073\001\
\255\255\255\255\255\255\015\001\016\001\255\255\018\001\255\255\
\255\255\255\255\084\001\085\001\086\001\087\001\088\001\027\001\
\255\255\255\255\255\255\255\255\255\255\001\001\002\001\255\255\
\036\001\255\255\255\255\255\255\102\001\009\001\042\001\043\001\
\044\001\045\001\046\001\015\001\016\001\255\255\018\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\027\001\
\255\255\255\255\062\001\255\255\255\255\255\255\255\255\067\001\
\036\001\255\255\255\255\255\255\072\001\073\001\042\001\043\001\
\044\001\045\001\046\001\255\255\255\255\255\255\255\255\255\255\
\084\001\085\001\086\001\087\001\088\001\255\255\255\255\255\255\
\255\255\255\255\062\001\001\001\002\001\255\255\255\255\067\001\
\255\255\255\255\102\001\009\001\072\001\073\001\255\255\255\255\
\255\255\015\001\016\001\255\255\255\255\255\255\255\255\255\255\
\084\001\085\001\086\001\087\001\088\001\027\001\255\255\255\255\
\255\255\255\255\255\255\001\001\002\001\255\255\036\001\255\255\
\255\255\255\255\102\001\009\001\042\001\043\001\044\001\045\001\
\046\001\015\001\255\255\255\255\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\027\001\255\255\255\255\
\062\001\255\255\255\255\255\255\255\255\067\001\036\001\255\255\
\255\255\255\255\072\001\073\001\042\001\043\001\044\001\045\001\
\046\001\255\255\255\255\255\255\255\255\255\255\084\001\085\001\
\086\001\087\001\088\001\255\255\255\255\255\255\255\255\093\001\
\062\001\001\001\002\001\255\255\255\255\067\001\255\255\255\255\
\102\001\009\001\072\001\073\001\255\255\255\255\255\255\015\001\
\255\255\255\255\255\255\255\255\255\255\255\255\084\001\085\001\
\086\001\087\001\088\001\027\001\255\255\255\255\255\255\255\255\
\255\255\255\255\096\001\255\255\036\001\255\255\255\255\255\255\
\102\001\255\255\042\001\043\001\044\001\045\001\046\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\001\001\002\001\
\255\255\255\255\255\255\255\255\255\255\255\255\062\001\255\255\
\255\255\255\255\255\255\067\001\015\001\255\255\255\255\255\255\
\072\001\073\001\255\255\255\255\255\255\255\255\255\255\255\255\
\027\001\255\255\255\255\255\255\084\001\085\001\086\001\087\001\
\088\001\036\001\255\255\255\255\255\255\255\255\255\255\042\001\
\043\001\044\001\045\001\046\001\255\255\255\255\102\001\255\255\
\255\255\255\255\255\255\255\255\056\001\255\255\058\001\059\001\
\060\001\255\255\062\001\062\001\255\255\065\001\066\001\255\255\
\067\001\255\255\255\255\255\255\255\255\072\001\073\001\075\001\
\255\255\255\255\255\255\255\255\255\255\255\255\255\255\083\001\
\255\255\255\255\085\001\086\001\087\001\088\001\255\255\091\001\
\092\001\255\255\255\255\255\255\255\255\255\255\255\255\099\001\
\255\255\255\255\255\255\102\001\255\255\255\255\255\255\255\255\
\255\255\255\255\255\255\111\001\112\001"

let yynames_const = "\
  AMPERAMPER\000\
  AMPERSAND\000\
  AND\000\
  AS\000\
  ASSERT\000\
  BACKQUOTE\000\
  BANG\000\
  BAR\000\
  BARBAR\000\
  BARRBRACKET\000\
  BEGIN\000\
  CLASS\000\
  COLON\000\
  COLONCOLON\000\
  COLONEQUAL\000\
  COLONGREATER\000\
  COMMA\000\
  CONSTRAINT\000\
  DO\000\
  DONE\000\
  DOT\000\
  DOTDOT\000\
  DOWNTO\000\
  ELSE\000\
  END\000\
  EOF\000\
  EQUAL\000\
  EXCEPTION\000\
  EXTERNAL\000\
  FALSE\000\
  FOR\000\
  FUN\000\
  FUNCTION\000\
  FUNCTOR\000\
  GREATER\000\
  GREATERRBRACE\000\
  GREATERRBRACKET\000\
  IF\000\
  IN\000\
  INCLUDE\000\
  INHERIT\000\
  INITIALIZER\000\
  LAZY\000\
  LBRACE\000\
  LBRACELESS\000\
  LBRACKET\000\
  LBRACKETBAR\000\
  LBRACKETLESS\000\
  LBRACKETGREATER\000\
  LBRACKETPERCENT\000\
  LBRACKETPERCENTPERCENT\000\
  LESS\000\
  LESSMINUS\000\
  LET\000\
  LPAREN\000\
  LBRACKETAT\000\
  LBRACKETATAT\000\
  LBRACKETATATAT\000\
  MATCH\000\
  METHOD\000\
  MINUS\000\
  MINUSDOT\000\
  MINUSGREATER\000\
  MODULE\000\
  MUTABLE\000\
  NEW\000\
  NONREC\000\
  OBJECT\000\
  OF\000\
  OPEN\000\
  OR\000\
  PERCENT\000\
  PLUS\000\
  PLUSDOT\000\
  PLUSEQ\000\
  PRIVATE\000\
  QUESTION\000\
  QUOTE\000\
  RBRACE\000\
  RBRACKET\000\
  REC\000\
  RPAREN\000\
  SEMI\000\
  SEMISEMI\000\
  SHARP\000\
  SIG\000\
  STAR\000\
  STRUCT\000\
  THEN\000\
  TILDE\000\
  TO\000\
  TRUE\000\
  TRY\000\
  TYPE\000\
  UNDERSCORE\000\
  VAL\000\
  VIRTUAL\000\
  WHEN\000\
  WHILE\000\
  WITH\000\
  EOL\000\
  "

let yynames_block = "\
  CHAR\000\
  FLOAT\000\
  INFIXOP0\000\
  INFIXOP1\000\
  INFIXOP2\000\
  INFIXOP3\000\
  INFIXOP4\000\
  INT\000\
  INT32\000\
  INT64\000\
  LABEL\000\
  LIDENT\000\
  NATIVEINT\000\
  OPTLABEL\000\
  PREFIXOP\000\
  SHARPOP\000\
  STRING\000\
  UIDENT\000\
  COMMENT\000\
  DOCSTRING\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'structure) in
    Obj.repr(
# 614 "parsing/parser.mly"
                                         ( extra_str 1 _1 )
# 6402 "parsing/parser.ml"
               : Parsetree.structure))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'signature) in
    Obj.repr(
# 617 "parsing/parser.mly"
                                         ( extra_sig 1 _1 )
# 6409 "parsing/parser.ml"
               : Parsetree.signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'top_structure) in
    Obj.repr(
# 620 "parsing/parser.mly"
                                         ( Ptop_def (extra_str 1 _1) )
# 6416 "parsing/parser.ml"
               : Parsetree.toplevel_phrase))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'toplevel_directive) in
    Obj.repr(
# 621 "parsing/parser.mly"
                                         ( _1 )
# 6423 "parsing/parser.ml"
               : Parsetree.toplevel_phrase))
; (fun __caml_parser_env ->
    Obj.repr(
# 622 "parsing/parser.mly"
                                         ( raise End_of_file )
# 6429 "parsing/parser.ml"
               : Parsetree.toplevel_phrase))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 626 "parsing/parser.mly"
      ( (text_str 1) @ [mkstrexp _1 _2] )
# 6437 "parsing/parser.ml"
               : 'top_structure))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'top_structure_tail) in
    Obj.repr(
# 628 "parsing/parser.mly"
      ( _1 )
# 6444 "parsing/parser.ml"
               : 'top_structure))
; (fun __caml_parser_env ->
    Obj.repr(
# 631 "parsing/parser.mly"
                                         ( [] )
# 6450 "parsing/parser.ml"
               : 'top_structure_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'structure_item) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'top_structure_tail) in
    Obj.repr(
# 632 "parsing/parser.mly"
                                         ( (text_str 1) @ _1 :: _2 )
# 6458 "parsing/parser.ml"
               : 'top_structure_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_body) in
    Obj.repr(
# 635 "parsing/parser.mly"
                                         ( extra_def 1 _1 )
# 6465 "parsing/parser.ml"
               : Parsetree.toplevel_phrase list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 638 "parsing/parser.mly"
                                         ( _1 )
# 6472 "parsing/parser.ml"
               : 'use_file_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'post_item_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 640 "parsing/parser.mly"
      ( (text_def 1) @ Ptop_def[mkstrexp _1 _2] :: _3 )
# 6481 "parsing/parser.ml"
               : 'use_file_body))
; (fun __caml_parser_env ->
    Obj.repr(
# 644 "parsing/parser.mly"
      ( [] )
# 6487 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    Obj.repr(
# 646 "parsing/parser.mly"
      ( text_def 1 )
# 6493 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'post_item_attributes) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 648 "parsing/parser.mly"
      (  mark_rhs_docs 2 3;
        (text_def 1) @ (text_def 2) @ Ptop_def[mkstrexp _2 _3] :: _4 )
# 6503 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'structure_item) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 651 "parsing/parser.mly"
      ( (text_def 1) @ (text_def 2) @ Ptop_def[_2] :: _3 )
# 6511 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'toplevel_directive) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 653 "parsing/parser.mly"
      (  mark_rhs_docs 2 3;
        (text_def 1) @ (text_def 2) @ _2 :: _3 )
# 6520 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'structure_item) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 656 "parsing/parser.mly"
      ( (text_def 1) @ Ptop_def[_1] :: _2 )
# 6528 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'toplevel_directive) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'use_file_tail) in
    Obj.repr(
# 658 "parsing/parser.mly"
      ( mark_rhs_docs 1 1;
        (text_def 1) @ _1 :: _2 )
# 6537 "parsing/parser.ml"
               : 'use_file_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    Obj.repr(
# 662 "parsing/parser.mly"
                  ( _1 )
# 6544 "parsing/parser.ml"
               : Parsetree.core_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 665 "parsing/parser.mly"
                 ( _1 )
# 6551 "parsing/parser.ml"
               : Parsetree.expression))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 668 "parsing/parser.mly"
                ( _1 )
# 6558 "parsing/parser.ml"
               : Parsetree.pattern))
; (fun __caml_parser_env ->
    Obj.repr(
# 675 "parsing/parser.mly"
      ( mkrhs "*" 2, None )
# 6564 "parsing/parser.ml"
               : 'functor_arg))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'functor_arg_name) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    Obj.repr(
# 677 "parsing/parser.mly"
      ( mkrhs _2 2, Some _4 )
# 6572 "parsing/parser.ml"
               : 'functor_arg))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 681 "parsing/parser.mly"
               ( _1 )
# 6579 "parsing/parser.ml"
               : 'functor_arg_name))
; (fun __caml_parser_env ->
    Obj.repr(
# 682 "parsing/parser.mly"
               ( "_" )
# 6585 "parsing/parser.ml"
               : 'functor_arg_name))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'functor_args) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'functor_arg) in
    Obj.repr(
# 687 "parsing/parser.mly"
      ( _2 :: _1 )
# 6593 "parsing/parser.ml"
               : 'functor_args))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'functor_arg) in
    Obj.repr(
# 689 "parsing/parser.mly"
      ( [ _1 ] )
# 6600 "parsing/parser.ml"
               : 'functor_args))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mod_longident) in
    Obj.repr(
# 694 "parsing/parser.mly"
      ( mkmod(Pmod_ident (mkrhs _1 1)) )
# 6607 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'structure) in
    Obj.repr(
# 696 "parsing/parser.mly"
      ( mkmod(Pmod_structure(extra_str 2 _2)) )
# 6614 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'structure) in
    Obj.repr(
# 698 "parsing/parser.mly"
      ( unclosed "struct" 1 "end" 3 )
# 6621 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'functor_args) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'module_expr) in
    Obj.repr(
# 700 "parsing/parser.mly"
      ( List.fold_left (fun acc (n, t) -> mkmod(Pmod_functor(n, t, acc)))
                       _4 _2 )
# 6630 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    Obj.repr(
# 703 "parsing/parser.mly"
      ( mkmod(Pmod_apply(_1, _3)) )
# 6638 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'module_expr) in
    Obj.repr(
# 705 "parsing/parser.mly"
      ( mkmod(Pmod_apply(_1, mkmod (Pmod_structure []))) )
# 6645 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    Obj.repr(
# 707 "parsing/parser.mly"
      ( unclosed "(" 2 ")" 4 )
# 6653 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    Obj.repr(
# 709 "parsing/parser.mly"
      ( mkmod(Pmod_constraint(_2, _4)) )
# 6661 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    Obj.repr(
# 711 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 6669 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    Obj.repr(
# 713 "parsing/parser.mly"
      ( _2 )
# 6676 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    Obj.repr(
# 715 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 3 )
# 6683 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 717 "parsing/parser.mly"
      ( mkmod(Pmod_unpack _3) )
# 6690 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 719 "parsing/parser.mly"
      ( mkmod(Pmod_unpack(
              ghexp(Pexp_constraint(_3, ghtyp(Ptyp_package _5))))) )
# 6699 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'package_type) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 722 "parsing/parser.mly"
      ( mkmod(Pmod_unpack(
              ghexp(Pexp_coerce(_3, Some(ghtyp(Ptyp_package _5)),
                                    ghtyp(Ptyp_package _7))))) )
# 6710 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 726 "parsing/parser.mly"
      ( mkmod(Pmod_unpack(
              ghexp(Pexp_coerce(_3, None, ghtyp(Ptyp_package _5))))) )
# 6719 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    Obj.repr(
# 729 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 6726 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    Obj.repr(
# 731 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 6733 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 733 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 4 )
# 6740 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 735 "parsing/parser.mly"
      ( Mod.attr _1 _2 )
# 6748 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 737 "parsing/parser.mly"
      ( mkmod(Pmod_extension _1) )
# 6755 "parsing/parser.ml"
               : 'module_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'post_item_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'structure_tail) in
    Obj.repr(
# 742 "parsing/parser.mly"
      ( mark_rhs_docs 1 2;
        (text_str 1) @ mkstrexp _1 _2 :: _3 )
# 6765 "parsing/parser.ml"
               : 'structure))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'structure_tail) in
    Obj.repr(
# 744 "parsing/parser.mly"
                   ( _1 )
# 6772 "parsing/parser.ml"
               : 'structure))
; (fun __caml_parser_env ->
    Obj.repr(
# 747 "parsing/parser.mly"
                         ( [] )
# 6778 "parsing/parser.ml"
               : 'structure_tail))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'structure) in
    Obj.repr(
# 748 "parsing/parser.mly"
                         ( (text_str 1) @ _2 )
# 6785 "parsing/parser.ml"
               : 'structure_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'structure_item) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'structure_tail) in
    Obj.repr(
# 749 "parsing/parser.mly"
                                  ( (text_str 1) @ _1 :: _2 )
# 6793 "parsing/parser.ml"
               : 'structure_tail))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'let_bindings) in
    Obj.repr(
# 753 "parsing/parser.mly"
      ( val_of_let_bindings _1 )
# 6800 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'primitive_declaration) in
    Obj.repr(
# 755 "parsing/parser.mly"
      ( mkstr (Pstr_primitive _1) )
# 6807 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_declarations) in
    Obj.repr(
# 757 "parsing/parser.mly"
      ( mkstr(Pstr_type (List.rev _1)) )
# 6814 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'str_type_extension) in
    Obj.repr(
# 759 "parsing/parser.mly"
      ( mkstr(Pstr_typext _1) )
# 6821 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'str_exception_declaration) in
    Obj.repr(
# 761 "parsing/parser.mly"
      ( mkstr(Pstr_exception _1) )
# 6828 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'module_binding) in
    Obj.repr(
# 763 "parsing/parser.mly"
      ( mkstr(Pstr_module _1) )
# 6835 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rec_module_bindings) in
    Obj.repr(
# 765 "parsing/parser.mly"
      ( mkstr(Pstr_recmodule(List.rev _1)) )
# 6842 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'module_type_declaration) in
    Obj.repr(
# 767 "parsing/parser.mly"
      ( mkstr(Pstr_modtype _1) )
# 6849 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'open_statement) in
    Obj.repr(
# 768 "parsing/parser.mly"
                   ( mkstr(Pstr_open _1) )
# 6856 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_declarations) in
    Obj.repr(
# 770 "parsing/parser.mly"
      ( mkstr(Pstr_class (List.rev _1)) )
# 6863 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_type_declarations) in
    Obj.repr(
# 772 "parsing/parser.mly"
      ( mkstr(Pstr_class_type (List.rev _1)) )
# 6870 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'str_include_statement) in
    Obj.repr(
# 774 "parsing/parser.mly"
      ( mkstr(Pstr_include _1) )
# 6877 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'item_extension) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 776 "parsing/parser.mly"
      ( mkstr(Pstr_extension (_1, (add_docs_attrs (symbol_docs ()) _2))) )
# 6885 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'floating_attribute) in
    Obj.repr(
# 778 "parsing/parser.mly"
      ( mark_symbol_docs ();
        mkstr(Pstr_attribute _1) )
# 6893 "parsing/parser.ml"
               : 'structure_item))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 783 "parsing/parser.mly"
      ( Incl.mk _2 ~attrs:_3
                ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 6902 "parsing/parser.ml"
               : 'str_include_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'module_expr) in
    Obj.repr(
# 788 "parsing/parser.mly"
      ( _2 )
# 6909 "parsing/parser.ml"
               : 'module_binding_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'module_type) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'module_expr) in
    Obj.repr(
# 790 "parsing/parser.mly"
      ( mkmod(Pmod_constraint(_4, _2)) )
# 6917 "parsing/parser.ml"
               : 'module_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'functor_arg) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'module_binding_body) in
    Obj.repr(
# 792 "parsing/parser.mly"
      ( mkmod(Pmod_functor(fst _1, snd _1, _2)) )
# 6925 "parsing/parser.ml"
               : 'module_binding_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_binding_body) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 796 "parsing/parser.mly"
      ( Mb.mk (mkrhs _2 2) _3 ~attrs:_4
              ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 6935 "parsing/parser.ml"
               : 'module_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rec_module_binding) in
    Obj.repr(
# 800 "parsing/parser.mly"
                                                  ( [_1] )
# 6942 "parsing/parser.ml"
               : 'rec_module_bindings))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'rec_module_bindings) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_module_binding) in
    Obj.repr(
# 801 "parsing/parser.mly"
                                                  ( _2 :: _1 )
# 6950 "parsing/parser.ml"
               : 'rec_module_bindings))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_binding_body) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 805 "parsing/parser.mly"
      ( Mb.mk (mkrhs _3 3) _4 ~attrs:_5
              ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 6960 "parsing/parser.ml"
               : 'rec_module_binding))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_binding_body) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 810 "parsing/parser.mly"
      ( Mb.mk (mkrhs _2 2) _3 ~attrs:_4 ~loc:(symbol_rloc ())
               ~text:(symbol_text ()) ~docs:(symbol_docs ()) )
# 6970 "parsing/parser.ml"
               : 'and_module_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mty_longident) in
    Obj.repr(
# 818 "parsing/parser.mly"
      ( mkmty(Pmty_ident (mkrhs _1 1)) )
# 6977 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'signature) in
    Obj.repr(
# 820 "parsing/parser.mly"
      ( mkmty(Pmty_signature (extra_sig 2 _2)) )
# 6984 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'signature) in
    Obj.repr(
# 822 "parsing/parser.mly"
      ( unclosed "sig" 1 "end" 3 )
# 6991 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'functor_args) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'module_type) in
    Obj.repr(
# 825 "parsing/parser.mly"
      ( List.fold_left (fun acc (n, t) -> mkmty(Pmty_functor(n, t, acc)))
                       _4 _2 )
# 7000 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'module_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'with_constraints) in
    Obj.repr(
# 828 "parsing/parser.mly"
      ( mkmty(Pmty_with(_1, List.rev _3)) )
# 7008 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'module_expr) in
    Obj.repr(
# 830 "parsing/parser.mly"
      ( mkmty(Pmty_typeof _4) )
# 7015 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    Obj.repr(
# 834 "parsing/parser.mly"
      ( _2 )
# 7022 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    Obj.repr(
# 836 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 3 )
# 7029 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 838 "parsing/parser.mly"
      ( mkmty(Pmty_extension _1) )
# 7036 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 840 "parsing/parser.mly"
      ( Mty.attr _1 _2 )
# 7044 "parsing/parser.ml"
               : 'module_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 843 "parsing/parser.mly"
                         ( [] )
# 7050 "parsing/parser.ml"
               : 'signature))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'signature) in
    Obj.repr(
# 844 "parsing/parser.mly"
                         ( (text_sig 1) @ _2 )
# 7057 "parsing/parser.ml"
               : 'signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'signature_item) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'signature) in
    Obj.repr(
# 845 "parsing/parser.mly"
                             ( (text_sig 1) @ _1 :: _2 )
# 7065 "parsing/parser.ml"
               : 'signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'value_description) in
    Obj.repr(
# 849 "parsing/parser.mly"
      ( mksig(Psig_value _1) )
# 7072 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'primitive_declaration) in
    Obj.repr(
# 851 "parsing/parser.mly"
      ( mksig(Psig_value _1) )
# 7079 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_declarations) in
    Obj.repr(
# 853 "parsing/parser.mly"
      ( mksig(Psig_type (List.rev _1)) )
# 7086 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'sig_type_extension) in
    Obj.repr(
# 855 "parsing/parser.mly"
      ( mksig(Psig_typext _1) )
# 7093 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'sig_exception_declaration) in
    Obj.repr(
# 857 "parsing/parser.mly"
      ( mksig(Psig_exception _1) )
# 7100 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'module_declaration) in
    Obj.repr(
# 859 "parsing/parser.mly"
      ( mksig(Psig_module _1) )
# 7107 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'module_alias) in
    Obj.repr(
# 861 "parsing/parser.mly"
      ( mksig(Psig_module _1) )
# 7114 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rec_module_declarations) in
    Obj.repr(
# 863 "parsing/parser.mly"
      ( mksig(Psig_recmodule (List.rev _1)) )
# 7121 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'module_type_declaration) in
    Obj.repr(
# 865 "parsing/parser.mly"
      ( mksig(Psig_modtype _1) )
# 7128 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'open_statement) in
    Obj.repr(
# 867 "parsing/parser.mly"
      ( mksig(Psig_open _1) )
# 7135 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'sig_include_statement) in
    Obj.repr(
# 869 "parsing/parser.mly"
      ( mksig(Psig_include _1) )
# 7142 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_descriptions) in
    Obj.repr(
# 871 "parsing/parser.mly"
      ( mksig(Psig_class (List.rev _1)) )
# 7149 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_type_declarations) in
    Obj.repr(
# 873 "parsing/parser.mly"
      ( mksig(Psig_class_type (List.rev _1)) )
# 7156 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'item_extension) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 875 "parsing/parser.mly"
      ( mksig(Psig_extension (_1, (add_docs_attrs (symbol_docs ()) _2))) )
# 7164 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'floating_attribute) in
    Obj.repr(
# 877 "parsing/parser.mly"
      ( mark_symbol_docs ();
        mksig(Psig_attribute _1) )
# 7172 "parsing/parser.ml"
               : 'signature_item))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'override_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 882 "parsing/parser.mly"
      ( Opn.mk (mkrhs _3 3) ~override:_2 ~attrs:_4
          ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7182 "parsing/parser.ml"
               : 'open_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 887 "parsing/parser.mly"
      ( Incl.mk _2 ~attrs:_3
                ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7191 "parsing/parser.ml"
               : 'sig_include_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'module_type) in
    Obj.repr(
# 892 "parsing/parser.mly"
      ( _2 )
# 7198 "parsing/parser.ml"
               : 'module_declaration_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'module_type) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'module_declaration_body) in
    Obj.repr(
# 894 "parsing/parser.mly"
      ( mkmty(Pmty_functor(mkrhs _2 2, Some _4, _6)) )
# 7207 "parsing/parser.ml"
               : 'module_declaration_body))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'module_declaration_body) in
    Obj.repr(
# 896 "parsing/parser.mly"
      ( mkmty(Pmty_functor(mkrhs "*" 1, None, _3)) )
# 7214 "parsing/parser.ml"
               : 'module_declaration_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_declaration_body) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 900 "parsing/parser.mly"
      ( Md.mk (mkrhs _2 2) _3 ~attrs:_4
          ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7224 "parsing/parser.ml"
               : 'module_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'mod_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 905 "parsing/parser.mly"
      ( Md.mk (mkrhs _2 2)
          (Mty.alias ~loc:(rhs_loc 4) (mkrhs _4 4)) ~attrs:_5
             ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7235 "parsing/parser.ml"
               : 'module_alias))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rec_module_declaration) in
    Obj.repr(
# 910 "parsing/parser.mly"
                                                    ( [_1] )
# 7242 "parsing/parser.ml"
               : 'rec_module_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'rec_module_declarations) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_module_declaration) in
    Obj.repr(
# 911 "parsing/parser.mly"
                                                    ( _2 :: _1 )
# 7250 "parsing/parser.ml"
               : 'rec_module_declarations))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 915 "parsing/parser.mly"
      ( Md.mk (mkrhs _3 3) _5 ~attrs:_6
              ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7260 "parsing/parser.ml"
               : 'rec_module_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_type) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 920 "parsing/parser.mly"
      ( Md.mk (mkrhs _2 2) _4 ~attrs:_5 ~loc:(symbol_rloc())
              ~text:(symbol_text()) ~docs:(symbol_docs()) )
# 7270 "parsing/parser.ml"
               : 'and_module_declaration))
; (fun __caml_parser_env ->
    Obj.repr(
# 924 "parsing/parser.mly"
                              ( None )
# 7276 "parsing/parser.ml"
               : 'module_type_declaration_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'module_type) in
    Obj.repr(
# 925 "parsing/parser.mly"
                              ( Some _2 )
# 7283 "parsing/parser.ml"
               : 'module_type_declaration_body))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'module_type_declaration_body) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 929 "parsing/parser.mly"
      ( Mtd.mk (mkrhs _3 3) ?typ:_4 ~attrs:_5
          ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 7293 "parsing/parser.ml"
               : 'module_type_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_declaration) in
    Obj.repr(
# 935 "parsing/parser.mly"
                                                ( [_1] )
# 7300 "parsing/parser.ml"
               : 'class_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_declarations) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_class_declaration) in
    Obj.repr(
# 936 "parsing/parser.mly"
                                                ( _2 :: _1 )
# 7308 "parsing/parser.ml"
               : 'class_declarations))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'class_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'class_fun_binding) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 941 "parsing/parser.mly"
      ( Ci.mk (mkrhs _4 4) _5 ~virt:_2 ~params:_3 ~attrs:_6
              ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 7320 "parsing/parser.ml"
               : 'class_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'class_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'class_fun_binding) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 947 "parsing/parser.mly"
      ( Ci.mk (mkrhs _4 4) _5 ~virt:_2 ~params:_3
         ~attrs:_6 ~loc:(symbol_rloc ())
         ~text:(symbol_text ()) ~docs:(symbol_docs ()) )
# 7333 "parsing/parser.ml"
               : 'and_class_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_expr) in
    Obj.repr(
# 953 "parsing/parser.mly"
      ( _2 )
# 7340 "parsing/parser.ml"
               : 'class_fun_binding))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'class_type) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'class_expr) in
    Obj.repr(
# 955 "parsing/parser.mly"
      ( mkclass(Pcl_constraint(_4, _2)) )
# 7348 "parsing/parser.ml"
               : 'class_fun_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'labeled_simple_pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_fun_binding) in
    Obj.repr(
# 957 "parsing/parser.mly"
      ( let (l,o,p) = _1 in mkclass(Pcl_fun(l, o, p, _2)) )
# 7356 "parsing/parser.ml"
               : 'class_fun_binding))
; (fun __caml_parser_env ->
    Obj.repr(
# 960 "parsing/parser.mly"
                                                ( [] )
# 7362 "parsing/parser.ml"
               : 'class_type_parameters))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'type_parameter_list) in
    Obj.repr(
# 961 "parsing/parser.mly"
                                                ( List.rev _2 )
# 7369 "parsing/parser.ml"
               : 'class_type_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'labeled_simple_pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'class_expr) in
    Obj.repr(
# 965 "parsing/parser.mly"
      ( let (l,o,p) = _1 in mkclass(Pcl_fun(l, o, p, _3)) )
# 7377 "parsing/parser.ml"
               : 'class_fun_def))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'labeled_simple_pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_fun_def) in
    Obj.repr(
# 967 "parsing/parser.mly"
      ( let (l,o,p) = _1 in mkclass(Pcl_fun(l, o, p, _2)) )
# 7385 "parsing/parser.ml"
               : 'class_fun_def))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_simple_expr) in
    Obj.repr(
# 971 "parsing/parser.mly"
      ( _1 )
# 7392 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_fun_def) in
    Obj.repr(
# 973 "parsing/parser.mly"
      ( _2 )
# 7399 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_simple_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_labeled_expr_list) in
    Obj.repr(
# 975 "parsing/parser.mly"
      ( mkclass(Pcl_apply(_1, List.rev _2)) )
# 7407 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'let_bindings) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'class_expr) in
    Obj.repr(
# 977 "parsing/parser.mly"
      ( class_of_let_bindings _1 _3 )
# 7415 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 979 "parsing/parser.mly"
      ( Cl.attr _1 _2 )
# 7423 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 981 "parsing/parser.mly"
      ( mkclass(Pcl_extension _1) )
# 7430 "parsing/parser.ml"
               : 'class_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_comma_list) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 985 "parsing/parser.mly"
      ( mkclass(Pcl_constr(mkloc _4 (rhs_loc 4), List.rev _2)) )
# 7438 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 987 "parsing/parser.mly"
      ( mkclass(Pcl_constr(mkrhs _1 1, [])) )
# 7445 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_structure) in
    Obj.repr(
# 989 "parsing/parser.mly"
      ( mkclass(Pcl_structure _2) )
# 7452 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_structure) in
    Obj.repr(
# 991 "parsing/parser.mly"
      ( unclosed "object" 1 "end" 3 )
# 7459 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'class_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'class_type) in
    Obj.repr(
# 993 "parsing/parser.mly"
      ( mkclass(Pcl_constraint(_2, _4)) )
# 7467 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'class_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'class_type) in
    Obj.repr(
# 995 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 7475 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_expr) in
    Obj.repr(
# 997 "parsing/parser.mly"
      ( _2 )
# 7482 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_expr) in
    Obj.repr(
# 999 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 3 )
# 7489 "parsing/parser.ml"
               : 'class_simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_self_pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_fields) in
    Obj.repr(
# 1003 "parsing/parser.mly"
       ( Cstr.mk _1 (extra_cstr 2 (List.rev _2)) )
# 7497 "parsing/parser.ml"
               : 'class_structure))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 1007 "parsing/parser.mly"
      ( reloc_pat _2 )
# 7504 "parsing/parser.ml"
               : 'class_self_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    Obj.repr(
# 1009 "parsing/parser.mly"
      ( mkpat(Ppat_constraint(_2, _4)) )
# 7512 "parsing/parser.ml"
               : 'class_self_pattern))
; (fun __caml_parser_env ->
    Obj.repr(
# 1011 "parsing/parser.mly"
      ( ghpat(Ppat_any) )
# 7518 "parsing/parser.ml"
               : 'class_self_pattern))
; (fun __caml_parser_env ->
    Obj.repr(
# 1015 "parsing/parser.mly"
      ( [] )
# 7524 "parsing/parser.ml"
               : 'class_fields))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_fields) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_field) in
    Obj.repr(
# 1017 "parsing/parser.mly"
      ( _2 :: (text_cstr 2) @ _1 )
# 7532 "parsing/parser.ml"
               : 'class_fields))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'override_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'class_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'parent_binder) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1021 "parsing/parser.mly"
      ( mkcf (Pcf_inherit (_2, _3, _4)) ~attrs:_5 ~docs:(symbol_docs ()) )
# 7542 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'value) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1023 "parsing/parser.mly"
      ( mkcf (Pcf_val _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7550 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'method_) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1025 "parsing/parser.mly"
      ( mkcf (Pcf_method _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7558 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'constrain_field) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1027 "parsing/parser.mly"
      ( mkcf (Pcf_constraint _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7566 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1029 "parsing/parser.mly"
      ( mkcf (Pcf_initializer _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7574 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'item_extension) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1031 "parsing/parser.mly"
      ( mkcf (Pcf_extension _1) ~attrs:_2 ~docs:(symbol_docs ()) )
# 7582 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'floating_attribute) in
    Obj.repr(
# 1033 "parsing/parser.mly"
      ( mark_symbol_docs ();
        mkcf (Pcf_attribute _1) )
# 7590 "parsing/parser.ml"
               : 'class_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 1038 "parsing/parser.mly"
          ( Some _2 )
# 7597 "parsing/parser.ml"
               : 'parent_binder))
; (fun __caml_parser_env ->
    Obj.repr(
# 1040 "parsing/parser.mly"
          ( None )
# 7603 "parsing/parser.ml"
               : 'parent_binder))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'override_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1045 "parsing/parser.mly"
      ( if _1 = Override then syntax_error ();
        mkloc _4 (rhs_loc 4), Mutable, Cfk_virtual _6 )
# 7613 "parsing/parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'mutable_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1048 "parsing/parser.mly"
      ( mkrhs _3 3, _2, Cfk_virtual _5 )
# 7622 "parsing/parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'override_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'mutable_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1050 "parsing/parser.mly"
      ( mkrhs _3 3, _2, Cfk_concrete (_1, _5) )
# 7632 "parsing/parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'override_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'mutable_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'label) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'type_constraint) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1052 "parsing/parser.mly"
      (
       let e = mkexp_constraint _6 _4 in
       mkrhs _3 3, _2, Cfk_concrete (_1, e)
      )
# 7646 "parsing/parser.ml"
               : 'value))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'override_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'poly_type) in
    Obj.repr(
# 1060 "parsing/parser.mly"
      ( if _1 = Override then syntax_error ();
        mkloc _4 (rhs_loc 4), Private, Cfk_virtual _6 )
# 7656 "parsing/parser.ml"
               : 'method_))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'override_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'private_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'poly_type) in
    Obj.repr(
# 1063 "parsing/parser.mly"
      ( if _1 = Override then syntax_error ();
        mkloc _4 (rhs_loc 4), _3, Cfk_virtual _6 )
# 7667 "parsing/parser.ml"
               : 'method_))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'override_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'private_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'label) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'strict_binding) in
    Obj.repr(
# 1066 "parsing/parser.mly"
      ( mkloc _3 (rhs_loc 3), _2,
        Cfk_concrete (_1, ghexp(Pexp_poly (_4, None))) )
# 7678 "parsing/parser.ml"
               : 'method_))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'override_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'private_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'poly_type) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1069 "parsing/parser.mly"
      ( mkloc _3 (rhs_loc 3), _2,
        Cfk_concrete (_1, ghexp(Pexp_poly(_7, Some _5))) )
# 7690 "parsing/parser.ml"
               : 'method_))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 9 : 'override_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 8 : 'private_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : 'label) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : 'lident_list) in
    let _8 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _10 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1073 "parsing/parser.mly"
      ( let exp, poly = wrap_type_annotation _6 _8 _10 in
        mkloc _3 (rhs_loc 3), _2,
        Cfk_concrete (_1, ghexp(Pexp_poly(exp, Some poly))) )
# 7704 "parsing/parser.ml"
               : 'method_))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_signature) in
    Obj.repr(
# 1082 "parsing/parser.mly"
      ( _1 )
# 7711 "parsing/parser.ml"
               : 'class_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type_or_tuple_no_attr) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'class_type) in
    Obj.repr(
# 1085 "parsing/parser.mly"
      ( mkcty(Pcty_arrow("?" ^ _2 , mkoption _4, _6)) )
# 7720 "parsing/parser.ml"
               : 'class_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type_or_tuple_no_attr) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'class_type) in
    Obj.repr(
# 1087 "parsing/parser.mly"
      ( mkcty(Pcty_arrow("?" ^ _1, mkoption _2, _4)) )
# 7729 "parsing/parser.ml"
               : 'class_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type_or_tuple_no_attr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'class_type) in
    Obj.repr(
# 1089 "parsing/parser.mly"
      ( mkcty(Pcty_arrow(_1, _3, _5)) )
# 7738 "parsing/parser.ml"
               : 'class_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type_or_tuple_no_attr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'class_type) in
    Obj.repr(
# 1091 "parsing/parser.mly"
      ( mkcty(Pcty_arrow("", _1, _3)) )
# 7746 "parsing/parser.ml"
               : 'class_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_comma_list) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'clty_longident) in
    Obj.repr(
# 1095 "parsing/parser.mly"
      ( mkcty(Pcty_constr (mkloc _4 (rhs_loc 4), List.rev _2)) )
# 7754 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'clty_longident) in
    Obj.repr(
# 1097 "parsing/parser.mly"
      ( mkcty(Pcty_constr (mkrhs _1 1, [])) )
# 7761 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_sig_body) in
    Obj.repr(
# 1099 "parsing/parser.mly"
      ( mkcty(Pcty_signature _2) )
# 7768 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_sig_body) in
    Obj.repr(
# 1101 "parsing/parser.mly"
      ( unclosed "object" 1 "end" 3 )
# 7775 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_signature) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 1103 "parsing/parser.mly"
      ( Cty.attr _1 _2 )
# 7783 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 1105 "parsing/parser.mly"
      ( mkcty(Pcty_extension _1) )
# 7790 "parsing/parser.ml"
               : 'class_signature))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_self_type) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_sig_fields) in
    Obj.repr(
# 1109 "parsing/parser.mly"
      ( Csig.mk _1 (extra_csig 2 (List.rev _2)) )
# 7798 "parsing/parser.ml"
               : 'class_sig_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    Obj.repr(
# 1113 "parsing/parser.mly"
      ( _2 )
# 7805 "parsing/parser.ml"
               : 'class_self_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 1115 "parsing/parser.mly"
      ( mktyp(Ptyp_any) )
# 7811 "parsing/parser.ml"
               : 'class_self_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 1118 "parsing/parser.mly"
                                                ( [] )
# 7817 "parsing/parser.ml"
               : 'class_sig_fields))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_sig_fields) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_sig_field) in
    Obj.repr(
# 1119 "parsing/parser.mly"
                                       ( _2 :: (text_csig 2) @ _1 )
# 7825 "parsing/parser.ml"
               : 'class_sig_fields))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'class_signature) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1123 "parsing/parser.mly"
      ( mkctf (Pctf_inherit _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7833 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'value_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1125 "parsing/parser.mly"
      ( mkctf (Pctf_val _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7841 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'private_virtual_flags) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'poly_type) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1127 "parsing/parser.mly"
      (
       let (p, v) = _2 in
       mkctf (Pctf_method (_3, p, v, _5)) ~attrs:_6 ~docs:(symbol_docs ())
      )
# 7854 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'constrain_field) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1132 "parsing/parser.mly"
      ( mkctf (Pctf_constraint _2) ~attrs:_3 ~docs:(symbol_docs ()) )
# 7862 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'item_extension) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1134 "parsing/parser.mly"
      ( mkctf (Pctf_extension _1) ~attrs:_2 ~docs:(symbol_docs ()) )
# 7870 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'floating_attribute) in
    Obj.repr(
# 1136 "parsing/parser.mly"
      ( mark_symbol_docs ();
        mkctf(Pctf_attribute _1) )
# 7878 "parsing/parser.ml"
               : 'class_sig_field))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'mutable_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1141 "parsing/parser.mly"
      ( _3, _2, Virtual, _5 )
# 7887 "parsing/parser.ml"
               : 'value_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1143 "parsing/parser.mly"
      ( _3, Mutable, _2, _5 )
# 7896 "parsing/parser.ml"
               : 'value_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1145 "parsing/parser.mly"
      ( _1, Immutable, Concrete, _3 )
# 7904 "parsing/parser.ml"
               : 'value_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1148 "parsing/parser.mly"
                                           ( _1, _3, symbol_rloc() )
# 7912 "parsing/parser.ml"
               : 'constrain))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1151 "parsing/parser.mly"
                                           ( _1, _3 )
# 7920 "parsing/parser.ml"
               : 'constrain_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_description) in
    Obj.repr(
# 1154 "parsing/parser.mly"
                                                ( [_1] )
# 7927 "parsing/parser.ml"
               : 'class_descriptions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_descriptions) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_class_description) in
    Obj.repr(
# 1155 "parsing/parser.mly"
                                                ( _2 :: _1 )
# 7935 "parsing/parser.ml"
               : 'class_descriptions))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'class_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'class_type) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1160 "parsing/parser.mly"
      ( Ci.mk (mkrhs _4 4) _6 ~virt:_2 ~params:_3 ~attrs:_7
              ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 7947 "parsing/parser.ml"
               : 'class_description))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'class_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'class_type) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1166 "parsing/parser.mly"
      ( Ci.mk (mkrhs _4 4) _6 ~virt:_2 ~params:_3
              ~attrs:_7 ~loc:(symbol_rloc ())
              ~text:(symbol_text ()) ~docs:(symbol_docs ()) )
# 7960 "parsing/parser.ml"
               : 'and_class_description))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'class_type_declaration) in
    Obj.repr(
# 1171 "parsing/parser.mly"
                                                        ( [_1] )
# 7967 "parsing/parser.ml"
               : 'class_type_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'class_type_declarations) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_class_type_declaration) in
    Obj.repr(
# 1172 "parsing/parser.mly"
                                                        ( _2 :: _1 )
# 7975 "parsing/parser.ml"
               : 'class_type_declarations))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 5 : 'virtual_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : 'class_type_parameters) in
    let _5 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'class_signature) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1177 "parsing/parser.mly"
      ( Ci.mk (mkrhs _5 5) _7 ~virt:_3 ~params:_4 ~attrs:_8
              ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 7987 "parsing/parser.ml"
               : 'class_type_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'virtual_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'class_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'class_signature) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1183 "parsing/parser.mly"
      ( Ci.mk (mkrhs _4 4) _6 ~virt:_2 ~params:_3
         ~attrs:_7 ~loc:(symbol_rloc ())
         ~text:(symbol_text ()) ~docs:(symbol_docs ()) )
# 8000 "parsing/parser.ml"
               : 'and_class_type_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1191 "parsing/parser.mly"
                                  ( _1 )
# 8007 "parsing/parser.ml"
               : 'seq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 1192 "parsing/parser.mly"
                                  ( reloc_exp _1 )
# 8014 "parsing/parser.ml"
               : 'seq_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1193 "parsing/parser.mly"
                                  ( mkexp(Pexp_sequence(_1, _3)) )
# 8022 "parsing/parser.ml"
               : 'seq_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label_let_pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'opt_default) in
    Obj.repr(
# 1197 "parsing/parser.mly"
      ( ("?" ^ fst _3, _4, snd _3) )
# 8030 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'label_var) in
    Obj.repr(
# 1199 "parsing/parser.mly"
      ( ("?" ^ fst _2, None, snd _2) )
# 8037 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'let_pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'opt_default) in
    Obj.repr(
# 1201 "parsing/parser.mly"
      ( ("?" ^ _1, _4, _3) )
# 8046 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pattern_var) in
    Obj.repr(
# 1203 "parsing/parser.mly"
      ( ("?" ^ _1, None, _2) )
# 8054 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'label_let_pattern) in
    Obj.repr(
# 1205 "parsing/parser.mly"
      ( (fst _3, None, snd _3) )
# 8061 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'label_var) in
    Obj.repr(
# 1207 "parsing/parser.mly"
      ( (fst _2, None, snd _2) )
# 8068 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_pattern) in
    Obj.repr(
# 1209 "parsing/parser.mly"
      ( (_1, None, _2) )
# 8076 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_pattern) in
    Obj.repr(
# 1211 "parsing/parser.mly"
      ( ("", None, _1) )
# 8083 "parsing/parser.ml"
               : 'labeled_simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 1214 "parsing/parser.mly"
                      ( mkpat(Ppat_var (mkrhs _1 1)) )
# 8090 "parsing/parser.ml"
               : 'pattern_var))
; (fun __caml_parser_env ->
    Obj.repr(
# 1215 "parsing/parser.mly"
                      ( mkpat Ppat_any )
# 8096 "parsing/parser.ml"
               : 'pattern_var))
; (fun __caml_parser_env ->
    Obj.repr(
# 1218 "parsing/parser.mly"
                                        ( None )
# 8102 "parsing/parser.ml"
               : 'opt_default))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1219 "parsing/parser.mly"
                                        ( Some _2 )
# 8109 "parsing/parser.ml"
               : 'opt_default))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_var) in
    Obj.repr(
# 1223 "parsing/parser.mly"
      ( _1 )
# 8116 "parsing/parser.ml"
               : 'label_let_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label_var) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1225 "parsing/parser.mly"
      ( let (lab, pat) = _1 in (lab, mkpat(Ppat_constraint(pat, _3))) )
# 8124 "parsing/parser.ml"
               : 'label_let_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 1228 "parsing/parser.mly"
              ( (_1, mkpat(Ppat_var (mkrhs _1 1))) )
# 8131 "parsing/parser.ml"
               : 'label_var))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1232 "parsing/parser.mly"
      ( _1 )
# 8138 "parsing/parser.ml"
               : 'let_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1234 "parsing/parser.mly"
      ( mkpat(Ppat_constraint(_1, _3)) )
# 8146 "parsing/parser.ml"
               : 'let_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1238 "parsing/parser.mly"
      ( _1 )
# 8153 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'simple_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_labeled_expr_list) in
    Obj.repr(
# 1240 "parsing/parser.mly"
      ( mkexp(Pexp_apply(_1, List.rev _2)) )
# 8161 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'let_bindings) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1242 "parsing/parser.mly"
      ( expr_of_let_bindings _1 _3 )
# 8169 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'ext_attributes) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'module_binding_body) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1244 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_letmodule(mkrhs _4 4, _5, _7)) _3 )
# 8179 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'override_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'ext_attributes) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1246 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_open(_3, mkrhs _5 5, _7)) _4 )
# 8189 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_bar) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'match_cases) in
    Obj.repr(
# 1248 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_function(List.rev _4)) _2 )
# 8198 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'labeled_simple_pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'fun_def) in
    Obj.repr(
# 1250 "parsing/parser.mly"
      ( let (l,o,p) = _3 in
        mkexp_attrs (Pexp_fun(l, o, p, _4)) _2 )
# 8208 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'ext_attributes) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'fun_def) in
    Obj.repr(
# 1253 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_newtype(_5, _7)) _2 )
# 8217 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_bar) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'match_cases) in
    Obj.repr(
# 1255 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_match(_3, List.rev _6)) _2 )
# 8227 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_bar) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'match_cases) in
    Obj.repr(
# 1257 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_try(_3, List.rev _6)) _2 )
# 8237 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    Obj.repr(
# 1259 "parsing/parser.mly"
      ( syntax_error() )
# 8245 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_comma_list) in
    Obj.repr(
# 1261 "parsing/parser.mly"
      ( mkexp(Pexp_tuple(List.rev _1)) )
# 8252 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'constr_longident) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1263 "parsing/parser.mly"
      ( mkexp(Pexp_construct(mkrhs _1 1, Some _2)) )
# 8260 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'name_tag) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1265 "parsing/parser.mly"
      ( mkexp(Pexp_variant(_1, Some _2)) )
# 8268 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1267 "parsing/parser.mly"
      ( mkexp_attrs(Pexp_ifthenelse(_3, _5, Some _7)) _2 )
# 8278 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1269 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_ifthenelse(_3, _5, None)) _2 )
# 8287 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1271 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_while(_3, _5)) _2 )
# 8296 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 8 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 7 : 'pattern) in
    let _5 = (Parsing.peek_val __caml_parser_env 5 : 'seq_expr) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : 'direction_flag) in
    let _7 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1274 "parsing/parser.mly"
      ( mkexp_attrs(Pexp_for(_3, _5, _7, _6, _9)) _2 )
# 8308 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1276 "parsing/parser.mly"
      ( mkexp_cons (rhs_loc 2) (ghexp(Pexp_tuple[_1;_3])) (symbol_rloc()) )
# 8316 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 1278 "parsing/parser.mly"
      ( mkexp_cons (rhs_loc 2) (ghexp(Pexp_tuple[_5;_7])) (symbol_rloc()) )
# 8324 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1280 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8333 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1282 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8342 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1284 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8351 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1286 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8360 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1288 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8369 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1290 "parsing/parser.mly"
      ( mkinfix _1 "+" _3 )
# 8377 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1292 "parsing/parser.mly"
      ( mkinfix _1 "+." _3 )
# 8385 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1294 "parsing/parser.mly"
      ( mkinfix _1 "+=" _3 )
# 8393 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1296 "parsing/parser.mly"
      ( mkinfix _1 "-" _3 )
# 8401 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1298 "parsing/parser.mly"
      ( mkinfix _1 "-." _3 )
# 8409 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1300 "parsing/parser.mly"
      ( mkinfix _1 "*" _3 )
# 8417 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1302 "parsing/parser.mly"
      ( mkinfix _1 "%" _3 )
# 8425 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1304 "parsing/parser.mly"
      ( mkinfix _1 "=" _3 )
# 8433 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1306 "parsing/parser.mly"
      ( mkinfix _1 "<" _3 )
# 8441 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1308 "parsing/parser.mly"
      ( mkinfix _1 ">" _3 )
# 8449 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1310 "parsing/parser.mly"
      ( mkinfix _1 "or" _3 )
# 8457 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1312 "parsing/parser.mly"
      ( mkinfix _1 "||" _3 )
# 8465 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1314 "parsing/parser.mly"
      ( mkinfix _1 "&" _3 )
# 8473 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1316 "parsing/parser.mly"
      ( mkinfix _1 "&&" _3 )
# 8481 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1318 "parsing/parser.mly"
      ( mkinfix _1 ":=" _3 )
# 8489 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'subtractive) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1320 "parsing/parser.mly"
      ( mkuminus _1 _2 )
# 8497 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'additive) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1322 "parsing/parser.mly"
      ( mkuplus _1 _2 )
# 8505 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1324 "parsing/parser.mly"
      ( mkexp(Pexp_setfield(_1, mkrhs _3 3, _5)) )
# 8514 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1326 "parsing/parser.mly"
      ( mkexp(Pexp_apply(ghexp(Pexp_ident(array_function "Array" "set")),
                         ["",_1; "",_4; "",_7])) )
# 8524 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'seq_expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1329 "parsing/parser.mly"
      ( mkexp(Pexp_apply(ghexp(Pexp_ident(array_function "String" "set")),
                         ["",_1; "",_4; "",_7])) )
# 8534 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1332 "parsing/parser.mly"
      ( bigarray_set _1 _4 _7 )
# 8543 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1334 "parsing/parser.mly"
      ( mkexp(Pexp_setinstvar(mkrhs _1 1, _3)) )
# 8551 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1336 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_assert _3) _2 )
# 8559 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1338 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_lazy _3) _2 )
# 8567 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'class_structure) in
    Obj.repr(
# 1340 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_object _3) _2 )
# 8575 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'class_structure) in
    Obj.repr(
# 1342 "parsing/parser.mly"
      ( unclosed "object" 1 "end" 4 )
# 8583 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 1344 "parsing/parser.mly"
      ( Exp.attr _1 _2 )
# 8591 "parsing/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'val_longident) in
    Obj.repr(
# 1348 "parsing/parser.mly"
      ( mkexp(Pexp_ident (mkrhs _1 1)) )
# 8598 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'constant) in
    Obj.repr(
# 1350 "parsing/parser.mly"
      ( mkexp(Pexp_constant _1) )
# 8605 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'constr_longident) in
    Obj.repr(
# 1352 "parsing/parser.mly"
      ( mkexp(Pexp_construct(mkrhs _1 1, None)) )
# 8612 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name_tag) in
    Obj.repr(
# 1354 "parsing/parser.mly"
      ( mkexp(Pexp_variant(_1, None)) )
# 8619 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1356 "parsing/parser.mly"
      ( reloc_exp _2 )
# 8626 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1358 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 3 )
# 8633 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1360 "parsing/parser.mly"
      ( wrap_exp_attrs (reloc_exp _3) _2 (* check location *) )
# 8641 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ext_attributes) in
    Obj.repr(
# 1362 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_construct (mkloc (Lident "()") (symbol_rloc ()),
                               None)) _2 )
# 8649 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1365 "parsing/parser.mly"
      ( unclosed "begin" 1 "end" 3 )
# 8657 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'type_constraint) in
    Obj.repr(
# 1367 "parsing/parser.mly"
      ( mkexp_constraint _2 _3 )
# 8665 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'label_longident) in
    Obj.repr(
# 1369 "parsing/parser.mly"
      ( mkexp(Pexp_field(_1, mkrhs _3 3)) )
# 8673 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1371 "parsing/parser.mly"
      ( mkexp(Pexp_open(Fresh, mkrhs _1 1, _4)) )
# 8681 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1373 "parsing/parser.mly"
      ( unclosed "(" 3 ")" 5 )
# 8689 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1375 "parsing/parser.mly"
      ( mkexp(Pexp_apply(ghexp(Pexp_ident(array_function "Array" "get")),
                         ["",_1; "",_4])) )
# 8698 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1378 "parsing/parser.mly"
      ( unclosed "(" 3 ")" 5 )
# 8706 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1380 "parsing/parser.mly"
      ( mkexp(Pexp_apply(ghexp(Pexp_ident(array_function "String" "get")),
                         ["",_1; "",_4])) )
# 8715 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'seq_expr) in
    Obj.repr(
# 1383 "parsing/parser.mly"
      ( unclosed "[" 3 "]" 5 )
# 8723 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 1385 "parsing/parser.mly"
      ( bigarray_get _1 _4 )
# 8731 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'expr_comma_list) in
    Obj.repr(
# 1387 "parsing/parser.mly"
      ( unclosed "{" 3 "}" 5 )
# 8739 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'record_expr) in
    Obj.repr(
# 1389 "parsing/parser.mly"
      ( let (exten, fields) = _2 in mkexp (Pexp_record(fields, exten)) )
# 8746 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'record_expr) in
    Obj.repr(
# 1391 "parsing/parser.mly"
      ( unclosed "{" 1 "}" 3 )
# 8753 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'record_expr) in
    Obj.repr(
# 1393 "parsing/parser.mly"
      ( let (exten, fields) = _4 in
        let rec_exp = mkexp(Pexp_record(fields, exten)) in
        mkexp(Pexp_open(Fresh, mkrhs _1 1, rec_exp)) )
# 8763 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'record_expr) in
    Obj.repr(
# 1397 "parsing/parser.mly"
      ( unclosed "{" 3 "}" 5 )
# 8771 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1399 "parsing/parser.mly"
      ( mkexp (Pexp_array(List.rev _2)) )
# 8779 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1401 "parsing/parser.mly"
      ( unclosed "[|" 1 "|]" 4 )
# 8787 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 1403 "parsing/parser.mly"
      ( mkexp (Pexp_array []) )
# 8793 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1405 "parsing/parser.mly"
      ( mkexp(Pexp_open(Fresh, mkrhs _1 1, mkexp(Pexp_array(List.rev _4)))) )
# 8802 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1407 "parsing/parser.mly"
      ( unclosed "[|" 3 "|]" 6 )
# 8811 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1409 "parsing/parser.mly"
      ( reloc_exp (mktailexp (rhs_loc 4) (List.rev _2)) )
# 8819 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1411 "parsing/parser.mly"
      ( unclosed "[" 1 "]" 4 )
# 8827 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1413 "parsing/parser.mly"
      ( let list_exp = reloc_exp (mktailexp (rhs_loc 6) (List.rev _4)) in
        mkexp(Pexp_open(Fresh, mkrhs _1 1, list_exp)) )
# 8837 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1416 "parsing/parser.mly"
      ( unclosed "[" 3 "]" 6 )
# 8846 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1418 "parsing/parser.mly"
      ( mkexp(Pexp_apply(mkoperator _1 1, ["",_2])) )
# 8854 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1420 "parsing/parser.mly"
      ( mkexp(Pexp_apply(mkoperator "!" 1, ["",_2])) )
# 8861 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 1422 "parsing/parser.mly"
      ( mkexp_attrs (Pexp_new(mkrhs _3 3)) _2 )
# 8869 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'field_expr_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1424 "parsing/parser.mly"
      ( mkexp (Pexp_override(List.rev _2)) )
# 8877 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'field_expr_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1426 "parsing/parser.mly"
      ( unclosed "{<" 1 ">}" 4 )
# 8885 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 1428 "parsing/parser.mly"
      ( mkexp (Pexp_override []))
# 8891 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'field_expr_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1430 "parsing/parser.mly"
      ( mkexp(Pexp_open(Fresh, mkrhs _1 1, mkexp (Pexp_override(List.rev _4)))))
# 8900 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'field_expr_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1432 "parsing/parser.mly"
      ( unclosed "{<" 3 ">}" 6 )
# 8909 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'label) in
    Obj.repr(
# 1434 "parsing/parser.mly"
      ( mkexp(Pexp_send(_1, _3)) )
# 8917 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1436 "parsing/parser.mly"
      ( mkinfix _1 _2 _3 )
# 8926 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'module_expr) in
    Obj.repr(
# 1438 "parsing/parser.mly"
      ( mkexp (Pexp_pack _3) )
# 8933 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 1440 "parsing/parser.mly"
      ( mkexp (Pexp_constraint (ghexp (Pexp_pack _3),
                                ghtyp (Ptyp_package _5))) )
# 8942 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'module_expr) in
    Obj.repr(
# 1443 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 8949 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 7 : 'mod_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'module_expr) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 1445 "parsing/parser.mly"
      ( mkexp(Pexp_open(Fresh, mkrhs _1 1,
        mkexp (Pexp_constraint (ghexp (Pexp_pack _5),
                                ghtyp (Ptyp_package _7))))) )
# 8960 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'mod_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'module_expr) in
    Obj.repr(
# 1449 "parsing/parser.mly"
      ( unclosed "(" 3 ")" 7 )
# 8968 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 1451 "parsing/parser.mly"
      ( mkexp (Pexp_extension _1) )
# 8975 "parsing/parser.ml"
               : 'simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'labeled_simple_expr) in
    Obj.repr(
# 1455 "parsing/parser.mly"
      ( [_1] )
# 8982 "parsing/parser.ml"
               : 'simple_labeled_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'simple_labeled_expr_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'labeled_simple_expr) in
    Obj.repr(
# 1457 "parsing/parser.mly"
      ( _2 :: _1 )
# 8990 "parsing/parser.ml"
               : 'simple_labeled_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1461 "parsing/parser.mly"
      ( ("", _1) )
# 8997 "parsing/parser.ml"
               : 'labeled_simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_expr) in
    Obj.repr(
# 1463 "parsing/parser.mly"
      ( _1 )
# 9004 "parsing/parser.ml"
               : 'labeled_simple_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1467 "parsing/parser.mly"
      ( (_1, _2) )
# 9012 "parsing/parser.ml"
               : 'label_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'label_ident) in
    Obj.repr(
# 1469 "parsing/parser.mly"
      ( _2 )
# 9019 "parsing/parser.ml"
               : 'label_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'label_ident) in
    Obj.repr(
# 1471 "parsing/parser.mly"
      ( ("?" ^ fst _2, snd _2) )
# 9026 "parsing/parser.ml"
               : 'label_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_expr) in
    Obj.repr(
# 1473 "parsing/parser.mly"
      ( ("?" ^ _1, _2) )
# 9034 "parsing/parser.ml"
               : 'label_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 1476 "parsing/parser.mly"
             ( (_1, mkexp(Pexp_ident(mkrhs (Lident _1) 1))) )
# 9041 "parsing/parser.ml"
               : 'label_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 1479 "parsing/parser.mly"
                                      ( [_1] )
# 9048 "parsing/parser.ml"
               : 'lident_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'lident_list) in
    Obj.repr(
# 1480 "parsing/parser.mly"
                                      ( _1 :: _2 )
# 9056 "parsing/parser.ml"
               : 'lident_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'val_ident) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fun_binding) in
    Obj.repr(
# 1484 "parsing/parser.mly"
      ( (mkpatvar _1 1, _2) )
# 9064 "parsing/parser.ml"
               : 'let_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'val_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'typevar_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1486 "parsing/parser.mly"
      ( (ghpat(Ppat_constraint(mkpatvar _1 1,
                               ghtyp(Ptyp_poly(List.rev _3,_5)))),
         _7) )
# 9076 "parsing/parser.ml"
               : 'let_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 7 : 'val_ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : 'lident_list) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1490 "parsing/parser.mly"
      ( let exp, poly = wrap_type_annotation _4 _6 _8 in
        (ghpat(Ppat_constraint(mkpatvar _1 1, poly)), exp) )
# 9087 "parsing/parser.ml"
               : 'let_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1493 "parsing/parser.mly"
      ( (_1, _3) )
# 9095 "parsing/parser.ml"
               : 'let_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'simple_pattern_not_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1495 "parsing/parser.mly"
      ( (ghpat(Ppat_constraint(_1, _3)), _5) )
# 9104 "parsing/parser.ml"
               : 'let_binding_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'let_binding) in
    Obj.repr(
# 1498 "parsing/parser.mly"
                                                ( _1 )
# 9111 "parsing/parser.ml"
               : 'let_bindings))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'let_bindings) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_let_binding) in
    Obj.repr(
# 1499 "parsing/parser.mly"
                                                ( addlb _1 _2 )
# 9119 "parsing/parser.ml"
               : 'let_bindings))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'ext_attributes) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'rec_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'let_binding_body) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1503 "parsing/parser.mly"
      ( mklbs _2 _3 (mklb _4 _5) )
# 9129 "parsing/parser.ml"
               : 'let_binding))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'let_binding_body) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1507 "parsing/parser.mly"
      ( mklb _2 _3 )
# 9137 "parsing/parser.ml"
               : 'and_let_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'strict_binding) in
    Obj.repr(
# 1511 "parsing/parser.mly"
      ( _1 )
# 9144 "parsing/parser.ml"
               : 'fun_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'type_constraint) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1513 "parsing/parser.mly"
      ( mkexp_constraint _3 _1 )
# 9152 "parsing/parser.ml"
               : 'fun_binding))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1517 "parsing/parser.mly"
      ( _2 )
# 9159 "parsing/parser.ml"
               : 'strict_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'labeled_simple_pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fun_binding) in
    Obj.repr(
# 1519 "parsing/parser.mly"
      ( let (l, o, p) = _1 in ghexp(Pexp_fun(l, o, p, _2)) )
# 9167 "parsing/parser.ml"
               : 'strict_binding))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'fun_binding) in
    Obj.repr(
# 1521 "parsing/parser.mly"
      ( mkexp(Pexp_newtype(_3, _5)) )
# 9175 "parsing/parser.ml"
               : 'strict_binding))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'match_case) in
    Obj.repr(
# 1524 "parsing/parser.mly"
               ( [_1] )
# 9182 "parsing/parser.ml"
               : 'match_cases))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'match_cases) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'match_case) in
    Obj.repr(
# 1525 "parsing/parser.mly"
                               ( _3 :: _1 )
# 9190 "parsing/parser.ml"
               : 'match_cases))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1529 "parsing/parser.mly"
      ( Exp.case _1 _3 )
# 9198 "parsing/parser.ml"
               : 'match_case))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'seq_expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1531 "parsing/parser.mly"
      ( Exp.case _1 ~guard:_3 _5 )
# 9207 "parsing/parser.ml"
               : 'match_case))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 1534 "parsing/parser.mly"
                                                ( _2 )
# 9214 "parsing/parser.ml"
               : 'fun_def))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'labeled_simple_pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fun_def) in
    Obj.repr(
# 1537 "parsing/parser.mly"
      (
       let (l,o,p) = _1 in
       ghexp(Pexp_fun(l, o, p, _2))
      )
# 9225 "parsing/parser.ml"
               : 'fun_def))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'fun_def) in
    Obj.repr(
# 1542 "parsing/parser.mly"
      ( mkexp(Pexp_newtype(_3, _5)) )
# 9233 "parsing/parser.ml"
               : 'fun_def))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr_comma_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1545 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 9241 "parsing/parser.ml"
               : 'expr_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1546 "parsing/parser.mly"
                                                ( [_3; _1] )
# 9249 "parsing/parser.ml"
               : 'expr_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_expr_list) in
    Obj.repr(
# 1549 "parsing/parser.mly"
                                                ( (Some _1, _3) )
# 9257 "parsing/parser.ml"
               : 'record_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_expr_list) in
    Obj.repr(
# 1550 "parsing/parser.mly"
                                                ( (None, _1) )
# 9264 "parsing/parser.ml"
               : 'record_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_expr) in
    Obj.repr(
# 1553 "parsing/parser.mly"
              ( [_1] )
# 9271 "parsing/parser.ml"
               : 'lbl_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lbl_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_expr_list) in
    Obj.repr(
# 1554 "parsing/parser.mly"
                                 ( _1 :: _3 )
# 9279 "parsing/parser.ml"
               : 'lbl_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'lbl_expr) in
    Obj.repr(
# 1555 "parsing/parser.mly"
                   ( [_1] )
# 9286 "parsing/parser.ml"
               : 'lbl_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1559 "parsing/parser.mly"
      ( (mkrhs _1 1,_3) )
# 9294 "parsing/parser.ml"
               : 'lbl_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_longident) in
    Obj.repr(
# 1561 "parsing/parser.mly"
      ( (mkrhs _1 1, exp_of_label _1 1) )
# 9301 "parsing/parser.ml"
               : 'lbl_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1565 "parsing/parser.mly"
      ( [mkrhs _1 1,_3] )
# 9309 "parsing/parser.ml"
               : 'field_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'field_expr_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1567 "parsing/parser.mly"
      ( (mkrhs _3 3, _5) :: _1 )
# 9318 "parsing/parser.ml"
               : 'field_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1570 "parsing/parser.mly"
                                                ( [_1] )
# 9325 "parsing/parser.ml"
               : 'expr_semi_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 1571 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 9333 "parsing/parser.ml"
               : 'expr_semi_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1574 "parsing/parser.mly"
                                                ( (Some _2, None) )
# 9340 "parsing/parser.ml"
               : 'type_constraint))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1575 "parsing/parser.mly"
                                                ( (Some _2, Some _4) )
# 9348 "parsing/parser.ml"
               : 'type_constraint))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1576 "parsing/parser.mly"
                                                ( (None, Some _2) )
# 9355 "parsing/parser.ml"
               : 'type_constraint))
; (fun __caml_parser_env ->
    Obj.repr(
# 1577 "parsing/parser.mly"
                                                ( syntax_error() )
# 9361 "parsing/parser.ml"
               : 'type_constraint))
; (fun __caml_parser_env ->
    Obj.repr(
# 1578 "parsing/parser.mly"
                                                ( syntax_error() )
# 9367 "parsing/parser.ml"
               : 'type_constraint))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_pattern) in
    Obj.repr(
# 1585 "parsing/parser.mly"
      ( _1 )
# 9374 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'val_ident) in
    Obj.repr(
# 1587 "parsing/parser.mly"
      ( mkpat(Ppat_alias(_1, mkrhs _3 3)) )
# 9382 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    Obj.repr(
# 1589 "parsing/parser.mly"
      ( expecting 3 "identifier" )
# 9389 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'pattern_comma_list) in
    Obj.repr(
# 1591 "parsing/parser.mly"
      ( mkpat(Ppat_tuple(List.rev _1)) )
# 9396 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'constr_longident) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1593 "parsing/parser.mly"
      ( mkpat(Ppat_construct(mkrhs _1 1, Some _2)) )
# 9404 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'name_tag) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1595 "parsing/parser.mly"
      ( mkpat(Ppat_variant(_1, Some _2)) )
# 9412 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1597 "parsing/parser.mly"
      ( mkpat_cons (rhs_loc 2) (ghpat(Ppat_tuple[_1;_3])) (symbol_rloc()) )
# 9420 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    Obj.repr(
# 1599 "parsing/parser.mly"
      ( expecting 3 "pattern" )
# 9427 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'pattern) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 1601 "parsing/parser.mly"
      ( mkpat_cons (rhs_loc 2) (ghpat(Ppat_tuple[_5;_7])) (symbol_rloc()) )
# 9435 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'pattern) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 1603 "parsing/parser.mly"
      ( unclosed "(" 4 ")" 8 )
# 9443 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1605 "parsing/parser.mly"
      ( mkpat(Ppat_or(_1, _3)) )
# 9451 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    Obj.repr(
# 1607 "parsing/parser.mly"
      ( expecting 3 "pattern" )
# 9458 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_pattern) in
    Obj.repr(
# 1609 "parsing/parser.mly"
      ( mkpat(Ppat_lazy _2) )
# 9465 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1611 "parsing/parser.mly"
      ( mkpat(Ppat_exception _2) )
# 9472 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 1613 "parsing/parser.mly"
      ( Pat.attr _1 _2 )
# 9480 "parsing/parser.ml"
               : 'pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'val_ident) in
    Obj.repr(
# 1617 "parsing/parser.mly"
      ( mkpat(Ppat_var (mkrhs _1 1)) )
# 9487 "parsing/parser.ml"
               : 'simple_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_pattern_not_ident) in
    Obj.repr(
# 1618 "parsing/parser.mly"
                             ( _1 )
# 9494 "parsing/parser.ml"
               : 'simple_pattern))
; (fun __caml_parser_env ->
    Obj.repr(
# 1622 "parsing/parser.mly"
      ( mkpat(Ppat_any) )
# 9500 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'signed_constant) in
    Obj.repr(
# 1624 "parsing/parser.mly"
      ( mkpat(Ppat_constant _1) )
# 9507 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'signed_constant) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'signed_constant) in
    Obj.repr(
# 1626 "parsing/parser.mly"
      ( mkpat(Ppat_interval (_1, _3)) )
# 9515 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'constr_longident) in
    Obj.repr(
# 1628 "parsing/parser.mly"
      ( mkpat(Ppat_construct(mkrhs _1 1, None)) )
# 9522 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name_tag) in
    Obj.repr(
# 1630 "parsing/parser.mly"
      ( mkpat(Ppat_variant(_1, None)) )
# 9529 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'type_longident) in
    Obj.repr(
# 1632 "parsing/parser.mly"
      ( mkpat(Ppat_type (mkrhs _2 2)) )
# 9536 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'lbl_pattern_list) in
    Obj.repr(
# 1634 "parsing/parser.mly"
      ( let (fields, closed) = _2 in mkpat(Ppat_record(fields, closed)) )
# 9543 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'lbl_pattern_list) in
    Obj.repr(
# 1636 "parsing/parser.mly"
      ( unclosed "{" 1 "}" 3 )
# 9550 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1638 "parsing/parser.mly"
      ( reloc_pat (mktailpat (rhs_loc 4) (List.rev _2)) )
# 9558 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1640 "parsing/parser.mly"
      ( unclosed "[" 1 "]" 4 )
# 9566 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1642 "parsing/parser.mly"
      ( mkpat(Ppat_array(List.rev _2)) )
# 9574 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 1644 "parsing/parser.mly"
      ( mkpat(Ppat_array []) )
# 9580 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'opt_semi) in
    Obj.repr(
# 1646 "parsing/parser.mly"
      ( unclosed "[|" 1 "|]" 4 )
# 9588 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 1648 "parsing/parser.mly"
      ( reloc_pat _2 )
# 9595 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'pattern) in
    Obj.repr(
# 1650 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 3 )
# 9602 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    Obj.repr(
# 1652 "parsing/parser.mly"
      ( mkpat(Ppat_constraint(_2, _4)) )
# 9610 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    Obj.repr(
# 1654 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 5 )
# 9618 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    Obj.repr(
# 1656 "parsing/parser.mly"
      ( expecting 4 "type" )
# 9625 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : string) in
    Obj.repr(
# 1658 "parsing/parser.mly"
      ( mkpat(Ppat_unpack (mkrhs _3 3)) )
# 9632 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 1660 "parsing/parser.mly"
      ( mkpat(Ppat_constraint(mkpat(Ppat_unpack (mkrhs _3 3)),
                              ghtyp(Ptyp_package _5))) )
# 9641 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 1663 "parsing/parser.mly"
      ( unclosed "(" 1 ")" 6 )
# 9649 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 1665 "parsing/parser.mly"
      ( mkpat(Ppat_extension _1) )
# 9656 "parsing/parser.ml"
               : 'simple_pattern_not_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_comma_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1669 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 9664 "parsing/parser.ml"
               : 'pattern_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1670 "parsing/parser.mly"
                                                ( [_3; _1] )
# 9672 "parsing/parser.ml"
               : 'pattern_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    Obj.repr(
# 1671 "parsing/parser.mly"
                                                ( expecting 3 "pattern" )
# 9679 "parsing/parser.ml"
               : 'pattern_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1674 "parsing/parser.mly"
                                                ( [_1] )
# 9686 "parsing/parser.ml"
               : 'pattern_semi_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'pattern_semi_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1675 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 9694 "parsing/parser.ml"
               : 'pattern_semi_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_pattern) in
    Obj.repr(
# 1678 "parsing/parser.mly"
                ( [_1], Closed )
# 9701 "parsing/parser.ml"
               : 'lbl_pattern_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'lbl_pattern) in
    Obj.repr(
# 1679 "parsing/parser.mly"
                     ( [_1], Closed )
# 9708 "parsing/parser.ml"
               : 'lbl_pattern_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'lbl_pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'opt_semi) in
    Obj.repr(
# 1680 "parsing/parser.mly"
                                         ( [_1], Open )
# 9716 "parsing/parser.ml"
               : 'lbl_pattern_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lbl_pattern) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'lbl_pattern_list) in
    Obj.repr(
# 1682 "parsing/parser.mly"
      ( let (fields, closed) = _3 in _1 :: fields, closed )
# 9724 "parsing/parser.ml"
               : 'lbl_pattern_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'label_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 1686 "parsing/parser.mly"
      ( (mkrhs _1 1,_3) )
# 9732 "parsing/parser.ml"
               : 'lbl_pattern))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_longident) in
    Obj.repr(
# 1688 "parsing/parser.mly"
      ( (mkrhs _1 1, pat_of_label _1 1) )
# 9739 "parsing/parser.ml"
               : 'lbl_pattern))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'val_ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1695 "parsing/parser.mly"
      ( Val.mk (mkrhs _2 2) _4 ~attrs:_5
               ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 9749 "parsing/parser.ml"
               : 'value_description))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string * string option) in
    Obj.repr(
# 1702 "parsing/parser.mly"
                                                ( [fst _1] )
# 9756 "parsing/parser.ml"
               : 'primitive_declaration_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string * string option) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'primitive_declaration_body) in
    Obj.repr(
# 1703 "parsing/parser.mly"
                                                ( fst _1 :: _2 )
# 9764 "parsing/parser.ml"
               : 'primitive_declaration_body))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'val_ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'core_type) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'primitive_declaration_body) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1708 "parsing/parser.mly"
      ( Val.mk (mkrhs _2 2) _4 ~prim:_6 ~attrs:_7
               ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 9775 "parsing/parser.ml"
               : 'primitive_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_declaration) in
    Obj.repr(
# 1715 "parsing/parser.mly"
                                                ( [_1] )
# 9782 "parsing/parser.ml"
               : 'type_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'type_declarations) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'and_type_declaration) in
    Obj.repr(
# 1716 "parsing/parser.mly"
                                                ( _2 :: _1 )
# 9790 "parsing/parser.ml"
               : 'type_declarations))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'nonrec_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'optional_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'type_kind) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'constraints) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1722 "parsing/parser.mly"
      ( let (kind, priv, manifest) = _5 in
          Type.mk (mkrhs _4 4) ~params:_3 ~cstrs:(List.rev _6) ~kind
            ~priv ?manifest ~attrs:(add_nonrec _2 _7 2)
            ~loc:(symbol_rloc ()) ~docs:(symbol_docs ()) )
# 9805 "parsing/parser.ml"
               : 'type_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'optional_type_parameters) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'type_kind) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'constraints) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1730 "parsing/parser.mly"
      ( let (kind, priv, manifest) = _4 in
          Type.mk (mkrhs _3 3) ~params:_2 ~cstrs:(List.rev _5)
            ~kind ~priv ?manifest ~attrs:_6 ~loc:(symbol_rloc ())
            ~text:(symbol_text ()) ~docs:(symbol_docs ()) )
# 9819 "parsing/parser.ml"
               : 'and_type_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'constraints) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'constrain) in
    Obj.repr(
# 1736 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 9827 "parsing/parser.ml"
               : 'constraints))
; (fun __caml_parser_env ->
    Obj.repr(
# 1737 "parsing/parser.mly"
                                                ( [] )
# 9833 "parsing/parser.ml"
               : 'constraints))
; (fun __caml_parser_env ->
    Obj.repr(
# 1741 "parsing/parser.mly"
      ( (Ptype_abstract, Public, None) )
# 9839 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1743 "parsing/parser.mly"
      ( (Ptype_abstract, Public, Some _2) )
# 9846 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1745 "parsing/parser.mly"
      ( (Ptype_abstract, Private, Some _3) )
# 9853 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'constructor_declarations) in
    Obj.repr(
# 1747 "parsing/parser.mly"
      ( (Ptype_variant(List.rev _2), Public, None) )
# 9860 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'constructor_declarations) in
    Obj.repr(
# 1749 "parsing/parser.mly"
      ( (Ptype_variant(List.rev _3), Private, None) )
# 9867 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    Obj.repr(
# 1751 "parsing/parser.mly"
      ( (Ptype_open, Public, None) )
# 9873 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'private_flag) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'label_declarations) in
    Obj.repr(
# 1753 "parsing/parser.mly"
      ( (Ptype_record _4, _2, None) )
# 9881 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'core_type) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'private_flag) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'constructor_declarations) in
    Obj.repr(
# 1755 "parsing/parser.mly"
      ( (Ptype_variant(List.rev _5), _4, Some _2) )
# 9890 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type) in
    Obj.repr(
# 1757 "parsing/parser.mly"
      ( (Ptype_open, Public, Some _2) )
# 9897 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'core_type) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'private_flag) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'label_declarations) in
    Obj.repr(
# 1759 "parsing/parser.mly"
      ( (Ptype_record _6, _4, Some _2) )
# 9906 "parsing/parser.ml"
               : 'type_kind))
; (fun __caml_parser_env ->
    Obj.repr(
# 1762 "parsing/parser.mly"
                                                ( [] )
# 9912 "parsing/parser.ml"
               : 'optional_type_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'optional_type_parameter) in
    Obj.repr(
# 1763 "parsing/parser.mly"
                                                ( [_1] )
# 9919 "parsing/parser.ml"
               : 'optional_type_parameters))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'optional_type_parameter_list) in
    Obj.repr(
# 1764 "parsing/parser.mly"
                                                ( List.rev _2 )
# 9926 "parsing/parser.ml"
               : 'optional_type_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'type_variance) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'optional_type_variable) in
    Obj.repr(
# 1767 "parsing/parser.mly"
                                                ( _2, _1 )
# 9934 "parsing/parser.ml"
               : 'optional_type_parameter))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'optional_type_parameter) in
    Obj.repr(
# 1770 "parsing/parser.mly"
                                                         ( [_1] )
# 9941 "parsing/parser.ml"
               : 'optional_type_parameter_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'optional_type_parameter_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'optional_type_parameter) in
    Obj.repr(
# 1771 "parsing/parser.mly"
                                                                  ( _3 :: _1 )
# 9949 "parsing/parser.ml"
               : 'optional_type_parameter_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 1774 "parsing/parser.mly"
                                                ( mktyp(Ptyp_var _2) )
# 9956 "parsing/parser.ml"
               : 'optional_type_variable))
; (fun __caml_parser_env ->
    Obj.repr(
# 1775 "parsing/parser.mly"
                                                ( mktyp(Ptyp_any) )
# 9962 "parsing/parser.ml"
               : 'optional_type_variable))
; (fun __caml_parser_env ->
    Obj.repr(
# 1780 "parsing/parser.mly"
                                                ( [] )
# 9968 "parsing/parser.ml"
               : 'type_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_parameter) in
    Obj.repr(
# 1781 "parsing/parser.mly"
                                                ( [_1] )
# 9975 "parsing/parser.ml"
               : 'type_parameters))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'type_parameter_list) in
    Obj.repr(
# 1782 "parsing/parser.mly"
                                                ( List.rev _2 )
# 9982 "parsing/parser.ml"
               : 'type_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'type_variance) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'type_variable) in
    Obj.repr(
# 1785 "parsing/parser.mly"
                                                  ( _2, _1 )
# 9990 "parsing/parser.ml"
               : 'type_parameter))
; (fun __caml_parser_env ->
    Obj.repr(
# 1788 "parsing/parser.mly"
                                                ( Invariant )
# 9996 "parsing/parser.ml"
               : 'type_variance))
; (fun __caml_parser_env ->
    Obj.repr(
# 1789 "parsing/parser.mly"
                                                ( Covariant )
# 10002 "parsing/parser.ml"
               : 'type_variance))
; (fun __caml_parser_env ->
    Obj.repr(
# 1790 "parsing/parser.mly"
                                                ( Contravariant )
# 10008 "parsing/parser.ml"
               : 'type_variance))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 1793 "parsing/parser.mly"
                                                ( mktyp(Ptyp_var _2) )
# 10015 "parsing/parser.ml"
               : 'type_variable))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_parameter) in
    Obj.repr(
# 1796 "parsing/parser.mly"
                                                ( [_1] )
# 10022 "parsing/parser.ml"
               : 'type_parameter_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'type_parameter_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'type_parameter) in
    Obj.repr(
# 1797 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10030 "parsing/parser.ml"
               : 'type_parameter_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'constructor_declaration) in
    Obj.repr(
# 1800 "parsing/parser.mly"
                                                         ( [_1] )
# 10037 "parsing/parser.ml"
               : 'constructor_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'bar_constructor_declaration) in
    Obj.repr(
# 1801 "parsing/parser.mly"
                                                         ( [_1] )
# 10044 "parsing/parser.ml"
               : 'constructor_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'constructor_declarations) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'bar_constructor_declaration) in
    Obj.repr(
# 1802 "parsing/parser.mly"
                                                         ( _2 :: _1 )
# 10052 "parsing/parser.ml"
               : 'constructor_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'constr_ident) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'generalized_constructor_arguments) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1806 "parsing/parser.mly"
      (
       let args,res = _2 in
       Type.constructor (mkrhs _1 1) ~args ?res ~attrs:_3
         ~loc:(symbol_rloc()) ~info:(symbol_info ())
      )
# 10065 "parsing/parser.ml"
               : 'constructor_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'constr_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'generalized_constructor_arguments) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1814 "parsing/parser.mly"
      (
       let args,res = _3 in
       Type.constructor (mkrhs _2 2) ~args ?res ~attrs:_4
         ~loc:(symbol_rloc()) ~info:(symbol_info ())
      )
# 10078 "parsing/parser.ml"
               : 'bar_constructor_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'sig_exception_declaration) in
    Obj.repr(
# 1821 "parsing/parser.mly"
                                                 ( _1 )
# 10085 "parsing/parser.ml"
               : 'str_exception_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'constr_ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'constr_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'attributes) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1824 "parsing/parser.mly"
      ( Te.rebind (mkrhs _2 2) (mkrhs _4 4) ~attrs:(_5 @ _6)
          ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 10096 "parsing/parser.ml"
               : 'str_exception_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'constr_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'generalized_constructor_arguments) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'attributes) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1830 "parsing/parser.mly"
      ( let args, res = _3 in
          Te.decl (mkrhs _2 2) ~args ?res ~attrs:(_4 @ _5)
            ~loc:(symbol_rloc()) ~docs:(symbol_docs ()) )
# 10108 "parsing/parser.ml"
               : 'sig_exception_declaration))
; (fun __caml_parser_env ->
    Obj.repr(
# 1835 "parsing/parser.mly"
                                                ( ([],None) )
# 10114 "parsing/parser.ml"
               : 'generalized_constructor_arguments))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_list_no_attr) in
    Obj.repr(
# 1836 "parsing/parser.mly"
                                                ( (List.rev _2,None) )
# 10121 "parsing/parser.ml"
               : 'generalized_constructor_arguments))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_list_no_attr) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_no_attr) in
    Obj.repr(
# 1838 "parsing/parser.mly"
                                                ( (List.rev _2,Some _4) )
# 10129 "parsing/parser.ml"
               : 'generalized_constructor_arguments))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_no_attr) in
    Obj.repr(
# 1840 "parsing/parser.mly"
                                                ( ([],Some _2) )
# 10136 "parsing/parser.ml"
               : 'generalized_constructor_arguments))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_declaration) in
    Obj.repr(
# 1846 "parsing/parser.mly"
                                                ( [_1] )
# 10143 "parsing/parser.ml"
               : 'label_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'label_declaration_semi) in
    Obj.repr(
# 1847 "parsing/parser.mly"
                                                ( [_1] )
# 10150 "parsing/parser.ml"
               : 'label_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'label_declaration_semi) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'label_declarations) in
    Obj.repr(
# 1848 "parsing/parser.mly"
                                                ( _1 :: _2 )
# 10158 "parsing/parser.ml"
               : 'label_declarations))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'mutable_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'label) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'poly_type_no_attr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1852 "parsing/parser.mly"
      (
       Type.field (mkrhs _2 2) _4 ~mut:_1 ~attrs:_5
         ~loc:(symbol_rloc()) ~info:(symbol_info ())
      )
# 10171 "parsing/parser.ml"
               : 'label_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 6 : 'mutable_flag) in
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'label) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'poly_type_no_attr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'attributes) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1859 "parsing/parser.mly"
      (
       let info =
         match rhs_info 5 with
         | Some _ as info_before_semi -> info_before_semi
         | None -> symbol_info ()
       in
       Type.field (mkrhs _2 2) _4 ~mut:_1 ~attrs:(_5 @ _7)
         ~loc:(symbol_rloc()) ~info
      )
# 10190 "parsing/parser.ml"
               : 'label_declaration_semi))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 6 : 'nonrec_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 5 : 'optional_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : 'type_longident) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : 'private_flag) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'str_extension_constructors) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1875 "parsing/parser.mly"
      ( if _2 <> Recursive then not_expecting 2 "nonrec flag";
        Te.mk (mkrhs _4 4) (List.rev _7) ~params:_3 ~priv:_6
          ~attrs:_8 ~docs:(symbol_docs ()) )
# 10204 "parsing/parser.ml"
               : 'str_type_extension))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 6 : 'nonrec_flag) in
    let _3 = (Parsing.peek_val __caml_parser_env 5 : 'optional_type_parameters) in
    let _4 = (Parsing.peek_val __caml_parser_env 4 : 'type_longident) in
    let _6 = (Parsing.peek_val __caml_parser_env 2 : 'private_flag) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'sig_extension_constructors) in
    let _8 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 1882 "parsing/parser.mly"
      ( if _2 <> Recursive then not_expecting 2 "nonrec flag";
        Te.mk (mkrhs _4 4) (List.rev _7) ~params:_3 ~priv:_6
          ~attrs:_8 ~docs:(symbol_docs ()) )
# 10218 "parsing/parser.ml"
               : 'sig_type_extension))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension_constructor_declaration) in
    Obj.repr(
# 1887 "parsing/parser.mly"
                                                          ( [_1] )
# 10225 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_declaration) in
    Obj.repr(
# 1888 "parsing/parser.mly"
                                                          ( [_1] )
# 10232 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension_constructor_rebind) in
    Obj.repr(
# 1889 "parsing/parser.mly"
                                                          ( [_1] )
# 10239 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_rebind) in
    Obj.repr(
# 1890 "parsing/parser.mly"
                                                          ( [_1] )
# 10246 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'str_extension_constructors) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_declaration) in
    Obj.repr(
# 1892 "parsing/parser.mly"
      ( _2 :: _1 )
# 10254 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'str_extension_constructors) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_rebind) in
    Obj.repr(
# 1894 "parsing/parser.mly"
      ( _2 :: _1 )
# 10262 "parsing/parser.ml"
               : 'str_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension_constructor_declaration) in
    Obj.repr(
# 1897 "parsing/parser.mly"
                                                          ( [_1] )
# 10269 "parsing/parser.ml"
               : 'sig_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_declaration) in
    Obj.repr(
# 1898 "parsing/parser.mly"
                                                          ( [_1] )
# 10276 "parsing/parser.ml"
               : 'sig_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'sig_extension_constructors) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'bar_extension_constructor_declaration) in
    Obj.repr(
# 1900 "parsing/parser.mly"
      ( _2 :: _1 )
# 10284 "parsing/parser.ml"
               : 'sig_extension_constructors))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'constr_ident) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'generalized_constructor_arguments) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1904 "parsing/parser.mly"
      ( let args, res = _2 in
        Te.decl (mkrhs _1 1) ~args ?res ~attrs:_3
          ~loc:(symbol_rloc()) ~info:(symbol_info ()) )
# 10295 "parsing/parser.ml"
               : 'extension_constructor_declaration))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'constr_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'generalized_constructor_arguments) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1910 "parsing/parser.mly"
      ( let args, res = _3 in
        Te.decl (mkrhs _2 2) ~args ?res ~attrs:_4
           ~loc:(symbol_rloc()) ~info:(symbol_info ()) )
# 10306 "parsing/parser.ml"
               : 'bar_extension_constructor_declaration))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'constr_ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'constr_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1916 "parsing/parser.mly"
      ( Te.rebind (mkrhs _1 1) (mkrhs _3 3) ~attrs:_4
          ~loc:(symbol_rloc()) ~info:(symbol_info ()) )
# 10316 "parsing/parser.ml"
               : 'extension_constructor_rebind))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'constr_ident) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'constr_longident) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 1921 "parsing/parser.mly"
      ( Te.rebind (mkrhs _2 2) (mkrhs _4 4) ~attrs:_5
          ~loc:(symbol_rloc()) ~info:(symbol_info ()) )
# 10326 "parsing/parser.ml"
               : 'bar_extension_constructor_rebind))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'with_constraint) in
    Obj.repr(
# 1928 "parsing/parser.mly"
                                                ( [_1] )
# 10333 "parsing/parser.ml"
               : 'with_constraints))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'with_constraints) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'with_constraint) in
    Obj.repr(
# 1929 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10341 "parsing/parser.ml"
               : 'with_constraints))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'type_parameters) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'label_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'with_type_binder) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'core_type_no_attr) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'constraints) in
    Obj.repr(
# 1933 "parsing/parser.mly"
      ( Pwith_type
          (mkrhs _3 3,
           (Type.mk (mkrhs (Longident.last _3) 3)
              ~params:_2
              ~cstrs:(List.rev _6)
              ~manifest:_5
              ~priv:_4
              ~loc:(symbol_rloc()))) )
# 10359 "parsing/parser.ml"
               : 'with_constraint))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'type_parameters) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'label) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 1944 "parsing/parser.mly"
      ( Pwith_typesubst
          (Type.mk (mkrhs _3 3)
             ~params:_2
             ~manifest:_5
             ~loc:(symbol_rloc())) )
# 10372 "parsing/parser.ml"
               : 'with_constraint))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'mod_ext_longident) in
    Obj.repr(
# 1950 "parsing/parser.mly"
      ( Pwith_module (mkrhs _2 2, mkrhs _4 4) )
# 10380 "parsing/parser.ml"
               : 'with_constraint))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'mod_ext_longident) in
    Obj.repr(
# 1952 "parsing/parser.mly"
      ( Pwith_modsubst (mkrhs _2 2, mkrhs _4 4) )
# 10388 "parsing/parser.ml"
               : 'with_constraint))
; (fun __caml_parser_env ->
    Obj.repr(
# 1955 "parsing/parser.mly"
                   ( Public )
# 10394 "parsing/parser.ml"
               : 'with_type_binder))
; (fun __caml_parser_env ->
    Obj.repr(
# 1956 "parsing/parser.mly"
                   ( Private )
# 10400 "parsing/parser.ml"
               : 'with_type_binder))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 1962 "parsing/parser.mly"
                                                ( [_2] )
# 10407 "parsing/parser.ml"
               : 'typevar_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'typevar_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 1963 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10415 "parsing/parser.ml"
               : 'typevar_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1967 "parsing/parser.mly"
          ( _1 )
# 10422 "parsing/parser.ml"
               : 'poly_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'typevar_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 1969 "parsing/parser.mly"
          ( mktyp(Ptyp_poly(List.rev _1, _3)) )
# 10430 "parsing/parser.ml"
               : 'poly_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 1973 "parsing/parser.mly"
          ( _1 )
# 10437 "parsing/parser.ml"
               : 'poly_type_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'typevar_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 1975 "parsing/parser.mly"
          ( mktyp(Ptyp_poly(List.rev _1, _3)) )
# 10445 "parsing/parser.ml"
               : 'poly_type_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 1982 "parsing/parser.mly"
      ( _1 )
# 10452 "parsing/parser.ml"
               : 'core_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'core_type) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attribute) in
    Obj.repr(
# 1984 "parsing/parser.mly"
      ( Typ.attr _1 _2 )
# 10460 "parsing/parser.ml"
               : 'core_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type2) in
    Obj.repr(
# 1988 "parsing/parser.mly"
      ( _1 )
# 10467 "parsing/parser.ml"
               : 'core_type_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'core_type2) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 1990 "parsing/parser.mly"
      ( mktyp(Ptyp_alias(_1, _4)) )
# 10475 "parsing/parser.ml"
               : 'core_type_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_or_tuple) in
    Obj.repr(
# 1994 "parsing/parser.mly"
      ( _1 )
# 10482 "parsing/parser.ml"
               : 'core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'core_type2) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'core_type2) in
    Obj.repr(
# 1996 "parsing/parser.mly"
      ( mktyp(Ptyp_arrow("?" ^ _2 , mkoption _4, _6)) )
# 10491 "parsing/parser.ml"
               : 'core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type2) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'core_type2) in
    Obj.repr(
# 1998 "parsing/parser.mly"
      ( mktyp(Ptyp_arrow("?" ^ _1 , mkoption _2, _4)) )
# 10500 "parsing/parser.ml"
               : 'core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'core_type2) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'core_type2) in
    Obj.repr(
# 2000 "parsing/parser.mly"
      ( mktyp(Ptyp_arrow(_1, _3, _5)) )
# 10509 "parsing/parser.ml"
               : 'core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type2) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type2) in
    Obj.repr(
# 2002 "parsing/parser.mly"
      ( mktyp(Ptyp_arrow("", _1, _3)) )
# 10517 "parsing/parser.ml"
               : 'core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type2) in
    Obj.repr(
# 2007 "parsing/parser.mly"
      ( _1 )
# 10524 "parsing/parser.ml"
               : 'simple_core_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'core_type_comma_list) in
    Obj.repr(
# 2009 "parsing/parser.mly"
      ( match _2 with [sty] -> sty | _ -> raise Parse_error )
# 10531 "parsing/parser.ml"
               : 'simple_core_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type2) in
    Obj.repr(
# 2014 "parsing/parser.mly"
      ( _1 )
# 10538 "parsing/parser.ml"
               : 'simple_core_type_no_attr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'core_type_comma_list) in
    Obj.repr(
# 2016 "parsing/parser.mly"
      ( match _2 with [sty] -> sty | _ -> raise Parse_error )
# 10545 "parsing/parser.ml"
               : 'simple_core_type_no_attr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 2021 "parsing/parser.mly"
      ( mktyp(Ptyp_var _2) )
# 10552 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    Obj.repr(
# 2023 "parsing/parser.mly"
      ( mktyp(Ptyp_any) )
# 10558 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'type_longident) in
    Obj.repr(
# 2025 "parsing/parser.mly"
      ( mktyp(Ptyp_constr(mkrhs _1 1, [])) )
# 10565 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'simple_core_type2) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'type_longident) in
    Obj.repr(
# 2027 "parsing/parser.mly"
      ( mktyp(Ptyp_constr(mkrhs _2 2, [_1])) )
# 10573 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_comma_list) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'type_longident) in
    Obj.repr(
# 2029 "parsing/parser.mly"
      ( mktyp(Ptyp_constr(mkrhs _4 4, List.rev _2)) )
# 10581 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'meth_list) in
    Obj.repr(
# 2031 "parsing/parser.mly"
      ( let (f, c) = _2 in mktyp(Ptyp_object (f, c)) )
# 10588 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    Obj.repr(
# 2033 "parsing/parser.mly"
      ( mktyp(Ptyp_object ([], Closed)) )
# 10594 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 2035 "parsing/parser.mly"
      ( mktyp(Ptyp_class(mkrhs _2 2, [])) )
# 10601 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type2) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 2037 "parsing/parser.mly"
      ( mktyp(Ptyp_class(mkrhs _3 3, [_1])) )
# 10609 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'core_type_comma_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'class_longident) in
    Obj.repr(
# 2039 "parsing/parser.mly"
      ( mktyp(Ptyp_class(mkrhs _5 5, List.rev _2)) )
# 10617 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'tag_field) in
    Obj.repr(
# 2041 "parsing/parser.mly"
      ( mktyp(Ptyp_variant([_2], Closed, None)) )
# 10624 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'row_field_list) in
    Obj.repr(
# 2047 "parsing/parser.mly"
      ( mktyp(Ptyp_variant(List.rev _3, Closed, None)) )
# 10631 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'row_field) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'row_field_list) in
    Obj.repr(
# 2049 "parsing/parser.mly"
      ( mktyp(Ptyp_variant(_2 :: List.rev _4, Closed, None)) )
# 10639 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'opt_bar) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'row_field_list) in
    Obj.repr(
# 2051 "parsing/parser.mly"
      ( mktyp(Ptyp_variant(List.rev _3, Open, None)) )
# 10647 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    Obj.repr(
# 2053 "parsing/parser.mly"
      ( mktyp(Ptyp_variant([], Open, None)) )
# 10653 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'opt_bar) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'row_field_list) in
    Obj.repr(
# 2055 "parsing/parser.mly"
      ( mktyp(Ptyp_variant(List.rev _3, Closed, Some [])) )
# 10661 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'opt_bar) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'row_field_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'name_tag_list) in
    Obj.repr(
# 2057 "parsing/parser.mly"
      ( mktyp(Ptyp_variant(List.rev _3, Closed, Some (List.rev _5))) )
# 10670 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'package_type) in
    Obj.repr(
# 2059 "parsing/parser.mly"
      ( mktyp(Ptyp_package _3) )
# 10677 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'extension) in
    Obj.repr(
# 2061 "parsing/parser.mly"
      ( mktyp (Ptyp_extension _1) )
# 10684 "parsing/parser.ml"
               : 'simple_core_type2))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mty_longident) in
    Obj.repr(
# 2064 "parsing/parser.mly"
                  ( (mkrhs _1 1, []) )
# 10691 "parsing/parser.ml"
               : 'package_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mty_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'package_type_cstrs) in
    Obj.repr(
# 2065 "parsing/parser.mly"
                                          ( (mkrhs _1 1, _3) )
# 10699 "parsing/parser.ml"
               : 'package_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'label_longident) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 2068 "parsing/parser.mly"
                                         ( (mkrhs _2 2, _4) )
# 10707 "parsing/parser.ml"
               : 'package_type_cstr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'package_type_cstr) in
    Obj.repr(
# 2071 "parsing/parser.mly"
                      ( [_1] )
# 10714 "parsing/parser.ml"
               : 'package_type_cstrs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'package_type_cstr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'package_type_cstrs) in
    Obj.repr(
# 2072 "parsing/parser.mly"
                                             ( _1::_3 )
# 10722 "parsing/parser.ml"
               : 'package_type_cstrs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'row_field) in
    Obj.repr(
# 2075 "parsing/parser.mly"
                                                ( [_1] )
# 10729 "parsing/parser.ml"
               : 'row_field_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'row_field_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'row_field) in
    Obj.repr(
# 2076 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10737 "parsing/parser.ml"
               : 'row_field_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'tag_field) in
    Obj.repr(
# 2079 "parsing/parser.mly"
                                                ( _1 )
# 10744 "parsing/parser.ml"
               : 'row_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type) in
    Obj.repr(
# 2080 "parsing/parser.mly"
                                                ( Rinherit _1 )
# 10751 "parsing/parser.ml"
               : 'row_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'name_tag) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'opt_ampersand) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'amper_type_list) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2084 "parsing/parser.mly"
      ( Rtag (_1, _5, _3, List.rev _4) )
# 10761 "parsing/parser.ml"
               : 'tag_field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'name_tag) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2086 "parsing/parser.mly"
      ( Rtag (_1, _2, true, []) )
# 10769 "parsing/parser.ml"
               : 'tag_field))
; (fun __caml_parser_env ->
    Obj.repr(
# 2089 "parsing/parser.mly"
                                                ( true )
# 10775 "parsing/parser.ml"
               : 'opt_ampersand))
; (fun __caml_parser_env ->
    Obj.repr(
# 2090 "parsing/parser.mly"
                                                ( false )
# 10781 "parsing/parser.ml"
               : 'opt_ampersand))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 2093 "parsing/parser.mly"
                                                ( [_1] )
# 10788 "parsing/parser.ml"
               : 'amper_type_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'amper_type_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_no_attr) in
    Obj.repr(
# 2094 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10796 "parsing/parser.ml"
               : 'amper_type_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name_tag) in
    Obj.repr(
# 2097 "parsing/parser.mly"
                                                ( [_1] )
# 10803 "parsing/parser.ml"
               : 'name_tag_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'name_tag_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'name_tag) in
    Obj.repr(
# 2098 "parsing/parser.mly"
                                                ( _2 :: _1 )
# 10811 "parsing/parser.ml"
               : 'name_tag_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type) in
    Obj.repr(
# 2101 "parsing/parser.mly"
                                             ( _1 )
# 10818 "parsing/parser.ml"
               : 'simple_core_type_or_tuple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_list) in
    Obj.repr(
# 2103 "parsing/parser.mly"
      ( mktyp(Ptyp_tuple(_1 :: List.rev _3)) )
# 10826 "parsing/parser.ml"
               : 'simple_core_type_or_tuple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_no_attr) in
    Obj.repr(
# 2107 "parsing/parser.mly"
      ( _1 )
# 10833 "parsing/parser.ml"
               : 'simple_core_type_or_tuple_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple_core_type_no_attr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type_list_no_attr) in
    Obj.repr(
# 2109 "parsing/parser.mly"
      ( mktyp(Ptyp_tuple(_1 :: List.rev _3)) )
# 10841 "parsing/parser.ml"
               : 'simple_core_type_or_tuple_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 2112 "parsing/parser.mly"
                                                ( [_1] )
# 10848 "parsing/parser.ml"
               : 'core_type_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_comma_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 2113 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10856 "parsing/parser.ml"
               : 'core_type_comma_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type) in
    Obj.repr(
# 2116 "parsing/parser.mly"
                                             ( [_1] )
# 10863 "parsing/parser.ml"
               : 'core_type_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type) in
    Obj.repr(
# 2117 "parsing/parser.mly"
                                                ( _3 :: _1 )
# 10871 "parsing/parser.ml"
               : 'core_type_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_no_attr) in
    Obj.repr(
# 2120 "parsing/parser.mly"
                                                 ( [_1] )
# 10878 "parsing/parser.ml"
               : 'core_type_list_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'core_type_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple_core_type_no_attr) in
    Obj.repr(
# 2121 "parsing/parser.mly"
                                                 ( _3 :: _1 )
# 10886 "parsing/parser.ml"
               : 'core_type_list_no_attr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'field) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'meth_list) in
    Obj.repr(
# 2124 "parsing/parser.mly"
                                             ( let (f, c) = _3 in (_1 :: f, c) )
# 10894 "parsing/parser.ml"
               : 'meth_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'field) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'opt_semi) in
    Obj.repr(
# 2125 "parsing/parser.mly"
                                                ( [_1], Closed )
# 10902 "parsing/parser.ml"
               : 'meth_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 2126 "parsing/parser.mly"
                                                ( [], Open )
# 10908 "parsing/parser.ml"
               : 'meth_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'label) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'poly_type_no_attr) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2129 "parsing/parser.mly"
                                                ( (_1, _4, _3) )
# 10917 "parsing/parser.ml"
               : 'field))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2132 "parsing/parser.mly"
                                                ( _1 )
# 10924 "parsing/parser.ml"
               : 'label))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 2138 "parsing/parser.mly"
                                      ( Const_int _1 )
# 10931 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : char) in
    Obj.repr(
# 2139 "parsing/parser.mly"
                                      ( Const_char _1 )
# 10938 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string * string option) in
    Obj.repr(
# 2140 "parsing/parser.mly"
                                      ( let (s, d) = _1 in Const_string (s, d) )
# 10945 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2141 "parsing/parser.mly"
                                      ( Const_float _1 )
# 10952 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int32) in
    Obj.repr(
# 2142 "parsing/parser.mly"
                                      ( Const_int32 _1 )
# 10959 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int64) in
    Obj.repr(
# 2143 "parsing/parser.mly"
                                      ( Const_int64 _1 )
# 10966 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : nativeint) in
    Obj.repr(
# 2144 "parsing/parser.mly"
                                      ( Const_nativeint _1 )
# 10973 "parsing/parser.ml"
               : 'constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'constant) in
    Obj.repr(
# 2147 "parsing/parser.mly"
                                           ( _1 )
# 10980 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 2148 "parsing/parser.mly"
                                           ( Const_int(- _2) )
# 10987 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2149 "parsing/parser.mly"
                                           ( Const_float("-" ^ _2) )
# 10994 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int32) in
    Obj.repr(
# 2150 "parsing/parser.mly"
                                           ( Const_int32(Int32.neg _2) )
# 11001 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int64) in
    Obj.repr(
# 2151 "parsing/parser.mly"
                                           ( Const_int64(Int64.neg _2) )
# 11008 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : nativeint) in
    Obj.repr(
# 2152 "parsing/parser.mly"
                                           ( Const_nativeint(Nativeint.neg _2) )
# 11015 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 2153 "parsing/parser.mly"
                                           ( Const_int _2 )
# 11022 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2154 "parsing/parser.mly"
                                           ( Const_float _2 )
# 11029 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int32) in
    Obj.repr(
# 2155 "parsing/parser.mly"
                                           ( Const_int32 _2 )
# 11036 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : int64) in
    Obj.repr(
# 2156 "parsing/parser.mly"
                                           ( Const_int64 _2 )
# 11043 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : nativeint) in
    Obj.repr(
# 2157 "parsing/parser.mly"
                                           ( Const_nativeint _2 )
# 11050 "parsing/parser.ml"
               : 'signed_constant))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2163 "parsing/parser.mly"
                                                ( _1 )
# 11057 "parsing/parser.ml"
               : 'ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2164 "parsing/parser.mly"
                                                ( _1 )
# 11064 "parsing/parser.ml"
               : 'ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2167 "parsing/parser.mly"
                                                ( _1 )
# 11071 "parsing/parser.ml"
               : 'val_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'operator) in
    Obj.repr(
# 2168 "parsing/parser.mly"
                                                ( _2 )
# 11078 "parsing/parser.ml"
               : 'val_ident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'operator) in
    Obj.repr(
# 2169 "parsing/parser.mly"
                                                ( unclosed "(" 1 ")" 3 )
# 11085 "parsing/parser.ml"
               : 'val_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2170 "parsing/parser.mly"
                                                ( expecting 2 "operator" )
# 11091 "parsing/parser.ml"
               : 'val_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2171 "parsing/parser.mly"
                                                ( expecting 3 "module-expr" )
# 11097 "parsing/parser.ml"
               : 'val_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2174 "parsing/parser.mly"
                                                ( _1 )
# 11104 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2175 "parsing/parser.mly"
                                                ( _1 )
# 11111 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2176 "parsing/parser.mly"
                                                ( _1 )
# 11118 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2177 "parsing/parser.mly"
                                                ( _1 )
# 11125 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2178 "parsing/parser.mly"
                                                ( _1 )
# 11132 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2179 "parsing/parser.mly"
                                                ( _1 )
# 11139 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2180 "parsing/parser.mly"
                                                ( _1 )
# 11146 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2181 "parsing/parser.mly"
                                                ( "!" )
# 11152 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2182 "parsing/parser.mly"
                                                ( "+" )
# 11158 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2183 "parsing/parser.mly"
                                                ( "+." )
# 11164 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2184 "parsing/parser.mly"
                                                ( "-" )
# 11170 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2185 "parsing/parser.mly"
                                                ( "-." )
# 11176 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2186 "parsing/parser.mly"
                                                ( "*" )
# 11182 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2187 "parsing/parser.mly"
                                                ( "=" )
# 11188 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2188 "parsing/parser.mly"
                                                ( "<" )
# 11194 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2189 "parsing/parser.mly"
                                                ( ">" )
# 11200 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2190 "parsing/parser.mly"
                                                ( "or" )
# 11206 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2191 "parsing/parser.mly"
                                                ( "||" )
# 11212 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2192 "parsing/parser.mly"
                                                ( "&" )
# 11218 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2193 "parsing/parser.mly"
                                                ( "&&" )
# 11224 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2194 "parsing/parser.mly"
                                                ( ":=" )
# 11230 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2195 "parsing/parser.mly"
                                                ( "+=" )
# 11236 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    Obj.repr(
# 2196 "parsing/parser.mly"
                                                ( "%" )
# 11242 "parsing/parser.ml"
               : 'operator))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2199 "parsing/parser.mly"
                                                ( _1 )
# 11249 "parsing/parser.ml"
               : 'constr_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2201 "parsing/parser.mly"
                                                ( "()" )
# 11255 "parsing/parser.ml"
               : 'constr_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2202 "parsing/parser.mly"
                                                ( "::" )
# 11261 "parsing/parser.ml"
               : 'constr_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2204 "parsing/parser.mly"
                                                ( "false" )
# 11267 "parsing/parser.ml"
               : 'constr_ident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2205 "parsing/parser.mly"
                                                ( "true" )
# 11273 "parsing/parser.ml"
               : 'constr_ident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'val_ident) in
    Obj.repr(
# 2209 "parsing/parser.mly"
                                                ( Lident _1 )
# 11280 "parsing/parser.ml"
               : 'val_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'val_ident) in
    Obj.repr(
# 2210 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11288 "parsing/parser.ml"
               : 'val_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mod_longident) in
    Obj.repr(
# 2213 "parsing/parser.mly"
                                                ( _1 )
# 11295 "parsing/parser.ml"
               : 'constr_longident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2214 "parsing/parser.mly"
                                                ( Lident "[]" )
# 11301 "parsing/parser.ml"
               : 'constr_longident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2215 "parsing/parser.mly"
                                                ( Lident "()" )
# 11307 "parsing/parser.ml"
               : 'constr_longident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2216 "parsing/parser.mly"
                                                ( Lident "false" )
# 11313 "parsing/parser.ml"
               : 'constr_longident))
; (fun __caml_parser_env ->
    Obj.repr(
# 2217 "parsing/parser.mly"
                                                ( Lident "true" )
# 11319 "parsing/parser.ml"
               : 'constr_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2220 "parsing/parser.mly"
                                                ( Lident _1 )
# 11326 "parsing/parser.ml"
               : 'label_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2221 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11334 "parsing/parser.ml"
               : 'label_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2224 "parsing/parser.mly"
                                                ( Lident _1 )
# 11341 "parsing/parser.ml"
               : 'type_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_ext_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2225 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11349 "parsing/parser.ml"
               : 'type_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2228 "parsing/parser.mly"
                                                ( Lident _1 )
# 11356 "parsing/parser.ml"
               : 'mod_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2229 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11364 "parsing/parser.ml"
               : 'mod_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2232 "parsing/parser.mly"
                                                ( Lident _1 )
# 11371 "parsing/parser.ml"
               : 'mod_ext_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_ext_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2233 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11379 "parsing/parser.ml"
               : 'mod_ext_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'mod_ext_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'mod_ext_longident) in
    Obj.repr(
# 2234 "parsing/parser.mly"
                                                      ( lapply _1 _3 )
# 11387 "parsing/parser.ml"
               : 'mod_ext_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 2237 "parsing/parser.mly"
                                                ( Lident _1 )
# 11394 "parsing/parser.ml"
               : 'mty_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_ext_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 2238 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11402 "parsing/parser.ml"
               : 'mty_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2241 "parsing/parser.mly"
                                                ( Lident _1 )
# 11409 "parsing/parser.ml"
               : 'clty_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_ext_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2242 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11417 "parsing/parser.ml"
               : 'clty_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2245 "parsing/parser.mly"
                                                ( Lident _1 )
# 11424 "parsing/parser.ml"
               : 'class_longident))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mod_longident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2246 "parsing/parser.mly"
                                                ( Ldot(_1, _3) )
# 11432 "parsing/parser.ml"
               : 'class_longident))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 2252 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_none) )
# 11439 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : string * string option) in
    Obj.repr(
# 2253 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_string (fst _3)) )
# 11447 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 2254 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_int _3) )
# 11455 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'val_longident) in
    Obj.repr(
# 2255 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_ident _3) )
# 11463 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mod_longident) in
    Obj.repr(
# 2256 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_ident _3) )
# 11471 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    Obj.repr(
# 2257 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_bool false) )
# 11478 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident) in
    Obj.repr(
# 2258 "parsing/parser.mly"
                                ( Ptop_dir(_2, Pdir_bool true) )
# 11485 "parsing/parser.ml"
               : 'toplevel_directive))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'ident) in
    Obj.repr(
# 2264 "parsing/parser.mly"
                                                ( _2 )
# 11492 "parsing/parser.ml"
               : 'name_tag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2267 "parsing/parser.mly"
                                                ( Nonrecursive )
# 11498 "parsing/parser.ml"
               : 'rec_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2268 "parsing/parser.mly"
                                                ( Recursive )
# 11504 "parsing/parser.ml"
               : 'rec_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2271 "parsing/parser.mly"
                                                ( Recursive )
# 11510 "parsing/parser.ml"
               : 'nonrec_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2272 "parsing/parser.mly"
                                                ( Nonrecursive )
# 11516 "parsing/parser.ml"
               : 'nonrec_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2275 "parsing/parser.mly"
                                                ( Upto )
# 11522 "parsing/parser.ml"
               : 'direction_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2276 "parsing/parser.mly"
                                                ( Downto )
# 11528 "parsing/parser.ml"
               : 'direction_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2279 "parsing/parser.mly"
                                                ( Public )
# 11534 "parsing/parser.ml"
               : 'private_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2280 "parsing/parser.mly"
                                                ( Private )
# 11540 "parsing/parser.ml"
               : 'private_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2283 "parsing/parser.mly"
                                                ( Immutable )
# 11546 "parsing/parser.ml"
               : 'mutable_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2284 "parsing/parser.mly"
                                                ( Mutable )
# 11552 "parsing/parser.ml"
               : 'mutable_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2287 "parsing/parser.mly"
                                                ( Concrete )
# 11558 "parsing/parser.ml"
               : 'virtual_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2288 "parsing/parser.mly"
                                                ( Virtual )
# 11564 "parsing/parser.ml"
               : 'virtual_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2291 "parsing/parser.mly"
                 ( Public, Concrete )
# 11570 "parsing/parser.ml"
               : 'private_virtual_flags))
; (fun __caml_parser_env ->
    Obj.repr(
# 2292 "parsing/parser.mly"
            ( Private, Concrete )
# 11576 "parsing/parser.ml"
               : 'private_virtual_flags))
; (fun __caml_parser_env ->
    Obj.repr(
# 2293 "parsing/parser.mly"
            ( Public, Virtual )
# 11582 "parsing/parser.ml"
               : 'private_virtual_flags))
; (fun __caml_parser_env ->
    Obj.repr(
# 2294 "parsing/parser.mly"
                    ( Private, Virtual )
# 11588 "parsing/parser.ml"
               : 'private_virtual_flags))
; (fun __caml_parser_env ->
    Obj.repr(
# 2295 "parsing/parser.mly"
                    ( Private, Virtual )
# 11594 "parsing/parser.ml"
               : 'private_virtual_flags))
; (fun __caml_parser_env ->
    Obj.repr(
# 2298 "parsing/parser.mly"
                                                ( Fresh )
# 11600 "parsing/parser.ml"
               : 'override_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2299 "parsing/parser.mly"
                                                ( Override )
# 11606 "parsing/parser.ml"
               : 'override_flag))
; (fun __caml_parser_env ->
    Obj.repr(
# 2302 "parsing/parser.mly"
                                                ( () )
# 11612 "parsing/parser.ml"
               : 'opt_bar))
; (fun __caml_parser_env ->
    Obj.repr(
# 2303 "parsing/parser.mly"
                                                ( () )
# 11618 "parsing/parser.ml"
               : 'opt_bar))
; (fun __caml_parser_env ->
    Obj.repr(
# 2306 "parsing/parser.mly"
                                                ( () )
# 11624 "parsing/parser.ml"
               : 'opt_semi))
; (fun __caml_parser_env ->
    Obj.repr(
# 2307 "parsing/parser.mly"
                                                ( () )
# 11630 "parsing/parser.ml"
               : 'opt_semi))
; (fun __caml_parser_env ->
    Obj.repr(
# 2310 "parsing/parser.mly"
                                                ( "-" )
# 11636 "parsing/parser.ml"
               : 'subtractive))
; (fun __caml_parser_env ->
    Obj.repr(
# 2311 "parsing/parser.mly"
                                                ( "-." )
# 11642 "parsing/parser.ml"
               : 'subtractive))
; (fun __caml_parser_env ->
    Obj.repr(
# 2314 "parsing/parser.mly"
                                                ( "+" )
# 11648 "parsing/parser.ml"
               : 'additive))
; (fun __caml_parser_env ->
    Obj.repr(
# 2315 "parsing/parser.mly"
                                                ( "+." )
# 11654 "parsing/parser.ml"
               : 'additive))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2321 "parsing/parser.mly"
           ( _1 )
# 11661 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 2322 "parsing/parser.mly"
           ( _1 )
# 11668 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2323 "parsing/parser.mly"
        ( "and" )
# 11674 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2324 "parsing/parser.mly"
       ( "as" )
# 11680 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2325 "parsing/parser.mly"
           ( "assert" )
# 11686 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2326 "parsing/parser.mly"
          ( "begin" )
# 11692 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2327 "parsing/parser.mly"
          ( "class" )
# 11698 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2328 "parsing/parser.mly"
               ( "constraint" )
# 11704 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2329 "parsing/parser.mly"
       ( "do" )
# 11710 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2330 "parsing/parser.mly"
         ( "done" )
# 11716 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2331 "parsing/parser.mly"
           ( "downto" )
# 11722 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2332 "parsing/parser.mly"
         ( "else" )
# 11728 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2333 "parsing/parser.mly"
        ( "end" )
# 11734 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2334 "parsing/parser.mly"
              ( "exception" )
# 11740 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2335 "parsing/parser.mly"
             ( "external" )
# 11746 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2336 "parsing/parser.mly"
          ( "false" )
# 11752 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2337 "parsing/parser.mly"
        ( "for" )
# 11758 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2338 "parsing/parser.mly"
        ( "fun" )
# 11764 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2339 "parsing/parser.mly"
             ( "function" )
# 11770 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2340 "parsing/parser.mly"
            ( "functor" )
# 11776 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2341 "parsing/parser.mly"
       ( "if" )
# 11782 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2342 "parsing/parser.mly"
       ( "in" )
# 11788 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2343 "parsing/parser.mly"
            ( "include" )
# 11794 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2344 "parsing/parser.mly"
            ( "inherit" )
# 11800 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2345 "parsing/parser.mly"
                ( "initializer" )
# 11806 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2346 "parsing/parser.mly"
         ( "lazy" )
# 11812 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2347 "parsing/parser.mly"
        ( "let" )
# 11818 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2348 "parsing/parser.mly"
          ( "match" )
# 11824 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2349 "parsing/parser.mly"
           ( "method" )
# 11830 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2350 "parsing/parser.mly"
           ( "module" )
# 11836 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2351 "parsing/parser.mly"
            ( "mutable" )
# 11842 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2352 "parsing/parser.mly"
        ( "new" )
# 11848 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2353 "parsing/parser.mly"
           ( "object" )
# 11854 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2354 "parsing/parser.mly"
       ( "of" )
# 11860 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2355 "parsing/parser.mly"
         ( "open" )
# 11866 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2356 "parsing/parser.mly"
       ( "or" )
# 11872 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2357 "parsing/parser.mly"
            ( "private" )
# 11878 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2358 "parsing/parser.mly"
        ( "rec" )
# 11884 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2359 "parsing/parser.mly"
        ( "sig" )
# 11890 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2360 "parsing/parser.mly"
           ( "struct" )
# 11896 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2361 "parsing/parser.mly"
         ( "then" )
# 11902 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2362 "parsing/parser.mly"
       ( "to" )
# 11908 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2363 "parsing/parser.mly"
         ( "true" )
# 11914 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2364 "parsing/parser.mly"
        ( "try" )
# 11920 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2365 "parsing/parser.mly"
         ( "type" )
# 11926 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2366 "parsing/parser.mly"
        ( "val" )
# 11932 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2367 "parsing/parser.mly"
            ( "virtual" )
# 11938 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2368 "parsing/parser.mly"
         ( "when" )
# 11944 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2369 "parsing/parser.mly"
          ( "while" )
# 11950 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    Obj.repr(
# 2370 "parsing/parser.mly"
         ( "with" )
# 11956 "parsing/parser.ml"
               : 'single_attr_id))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'single_attr_id) in
    Obj.repr(
# 2375 "parsing/parser.mly"
                   ( mkloc _1 (symbol_rloc()) )
# 11963 "parsing/parser.ml"
               : 'attr_id))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'single_attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attr_id) in
    Obj.repr(
# 2376 "parsing/parser.mly"
                               ( mkloc (_1 ^ "." ^ _3.txt) (symbol_rloc()))
# 11971 "parsing/parser.ml"
               : 'attr_id))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'payload) in
    Obj.repr(
# 2379 "parsing/parser.mly"
                                      ( (_2, _3) )
# 11979 "parsing/parser.ml"
               : 'attribute))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'payload) in
    Obj.repr(
# 2382 "parsing/parser.mly"
                                        ( (_2, _3) )
# 11987 "parsing/parser.ml"
               : 'post_item_attribute))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'payload) in
    Obj.repr(
# 2385 "parsing/parser.mly"
                                          ( (_2, _3) )
# 11995 "parsing/parser.ml"
               : 'floating_attribute))
; (fun __caml_parser_env ->
    Obj.repr(
# 2388 "parsing/parser.mly"
                 ( [] )
# 12001 "parsing/parser.ml"
               : 'post_item_attributes))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'post_item_attribute) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'post_item_attributes) in
    Obj.repr(
# 2389 "parsing/parser.mly"
                                             ( _1 :: _2 )
# 12009 "parsing/parser.ml"
               : 'post_item_attributes))
; (fun __caml_parser_env ->
    Obj.repr(
# 2392 "parsing/parser.mly"
               ( [] )
# 12015 "parsing/parser.ml"
               : 'attributes))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'attribute) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2393 "parsing/parser.mly"
                         ( _1 :: _2 )
# 12023 "parsing/parser.ml"
               : 'attributes))
; (fun __caml_parser_env ->
    Obj.repr(
# 2396 "parsing/parser.mly"
                 ( None, [] )
# 12029 "parsing/parser.ml"
               : 'ext_attributes))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'attribute) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2397 "parsing/parser.mly"
                         ( None, _1 :: _2 )
# 12037 "parsing/parser.ml"
               : 'ext_attributes))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'attributes) in
    Obj.repr(
# 2398 "parsing/parser.mly"
                               ( Some _2, _3 )
# 12045 "parsing/parser.ml"
               : 'ext_attributes))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'payload) in
    Obj.repr(
# 2401 "parsing/parser.mly"
                                           ( (_2, _3) )
# 12053 "parsing/parser.ml"
               : 'extension))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'attr_id) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'payload) in
    Obj.repr(
# 2404 "parsing/parser.mly"
                                                  ( (_2, _3) )
# 12061 "parsing/parser.ml"
               : 'item_extension))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'structure) in
    Obj.repr(
# 2407 "parsing/parser.mly"
              ( PStr _1 )
# 12068 "parsing/parser.ml"
               : 'payload))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'core_type) in
    Obj.repr(
# 2408 "parsing/parser.mly"
                    ( PTyp _2 )
# 12075 "parsing/parser.ml"
               : 'payload))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'pattern) in
    Obj.repr(
# 2409 "parsing/parser.mly"
                     ( PPat (_2, None) )
# 12082 "parsing/parser.ml"
               : 'payload))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'pattern) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'seq_expr) in
    Obj.repr(
# 2410 "parsing/parser.mly"
                                   ( PPat (_2, Some _4) )
# 12090 "parsing/parser.ml"
               : 'payload))
(* Entry implementation *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry interface *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry toplevel_phrase *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry use_file *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry parse_core_type *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry parse_expression *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
(* Entry parse_pattern *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let implementation (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Parsetree.structure)
let interface (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 2 lexfun lexbuf : Parsetree.signature)
let toplevel_phrase (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 3 lexfun lexbuf : Parsetree.toplevel_phrase)
let use_file (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 4 lexfun lexbuf : Parsetree.toplevel_phrase list)
let parse_core_type (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 5 lexfun lexbuf : Parsetree.core_type)
let parse_expression (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 6 lexfun lexbuf : Parsetree.expression)
let parse_pattern (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 7 lexfun lexbuf : Parsetree.pattern)
;;

end
module Lexer : sig
#1 "lexer.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* The lexical analyzer *)

val init : unit -> unit
val token: Lexing.lexbuf -> Parser.token
val skip_sharp_bang: Lexing.lexbuf -> unit

type directive_type

(* type directive_value = *)
(*   | Dir_bool of bool  *)
(*   | Dir_float of float *)
(*   | Dir_int of int *)
(*   | Dir_string of string *)
(*   | Dir_null *)

type error =
  | Illegal_character of char
  | Illegal_escape of string
  | Unterminated_comment of Location.t
  | Unterminated_string
  | Unterminated_string_in_comment of Location.t * Location.t
  | Keyword_as_label of string
  | Literal_overflow of string
  | Unterminated_paren_in_conditional
  | Unterminated_if
  | Unterminated_else
  | Unexpected_token_in_conditional
  | Expect_hash_then_in_conditional
  | Illegal_semver of string
  | Unexpected_directive
  | Conditional_expr_expected_type of directive_type * directive_type
;;

exception Error of error * Location.t

open Format

val report_error: formatter -> error -> unit
 (* Deprecated.  Use Location.{error_of_exn, report_error}. *)

val in_comment : unit -> bool;;
val in_string : unit -> bool;;


val print_warnings : bool ref
val comments : unit -> (string * Location.t) list
val token_with_comments : Lexing.lexbuf -> Parser.token

(*
  [set_preprocessor init preprocessor] registers [init] as the function
to call to initialize the preprocessor when the lexer is initialized,
and [preprocessor] a function that is called when a new token is needed
by the parser, as [preprocessor lexer lexbuf] where [lexer] is the
lexing function.

When a preprocessor is configured by calling [set_preprocessor], the lexer
changes its behavior to accept backslash-newline as a token-separating blank.
*)

val set_preprocessor :
  (unit -> unit) ->
  ((Lexing.lexbuf -> Parser.token) -> Lexing.lexbuf -> Parser.token) ->
  unit


(* val replace_directive_built_in_value :  *)
(*   string ->  directive_value -> unit *)

(** Raises Not_found *)
(* val find_directive_built_in_value : *)
(*   string -> directive_value *)

(* val iter_directive_built_in_value :  *)
(*   (string -> directive_value -> unit) -> unit *)


(** semantic version predicate *)
val semver : Location.t ->   string -> string -> bool

val filter_directive_from_lexbuf : Lexing.lexbuf -> (int * int) list

val replace_directive_int : string -> int -> unit
val replace_directive_string : string -> string -> unit
val replace_directive_bool : string -> bool -> unit
val remove_directive_built_in_value : string -> unit

(** @return false means failed to define *)
val define_key_value : string -> string -> bool
val list_variables : Format.formatter -> unit

end = struct
#1 "lexer.ml"
# 15 "parsing/lexer.mll"

open Lexing
open Misc
open Parser

type directive_value =
  | Dir_bool of bool
  | Dir_float of float
  | Dir_int of int
  | Dir_string of string
  | Dir_null

type directive_type =
  | Dir_type_bool
  | Dir_type_float
  | Dir_type_int
  | Dir_type_string
  | Dir_type_null

let type_of_directive x =
  match x with
  | Dir_bool _ -> Dir_type_bool
  | Dir_float _ -> Dir_type_float
  | Dir_int _ -> Dir_type_int
  | Dir_string _ -> Dir_type_string
  | Dir_null -> Dir_type_null

let string_of_type_directive x =
  match x with
  | Dir_type_bool  -> "bool"
  | Dir_type_float  -> "float"
  | Dir_type_int  -> "int"
  | Dir_type_string  -> "string"
  | Dir_type_null -> "null"

type error =
  | Illegal_character of char
  | Illegal_escape of string
  | Unterminated_comment of Location.t
  | Unterminated_string
  | Unterminated_string_in_comment of Location.t * Location.t
  | Keyword_as_label of string
  | Literal_overflow of string
  | Unterminated_paren_in_conditional
  | Unterminated_if
  | Unterminated_else
  | Unexpected_token_in_conditional
  | Expect_hash_then_in_conditional
  | Illegal_semver of string
  | Unexpected_directive
  | Conditional_expr_expected_type of directive_type * directive_type

;;

exception Error of error * Location.t;;

let assert_same_type  lexbuf x y =
  let lhs = type_of_directive x in let rhs =  type_of_directive y  in
  if lhs <> rhs then
    raise (Error(Conditional_expr_expected_type(lhs,rhs), Location.curr lexbuf))
  else y

let directive_built_in_values  =
  Hashtbl.create 51


let replace_directive_built_in_value k v =
  Hashtbl.replace directive_built_in_values k v

let remove_directive_built_in_value k  =
  Hashtbl.replace directive_built_in_values k Dir_null

let replace_directive_int k v =
  Hashtbl.replace directive_built_in_values k (Dir_int v)

let replace_directive_bool k v =
  Hashtbl.replace directive_built_in_values k (Dir_bool v)

let replace_directive_string k v =
  Hashtbl.replace directive_built_in_values k (Dir_string v)

let () =
  (* Note we use {!Config} instead of {!Sys} becasue
     we want to overwrite in some cases with the
     same stdlib
  *)
  let version =

    Config.version (* so that it can be overridden*)

  in
  replace_directive_built_in_value "OCAML_VERSION"
    (Dir_string version);
  replace_directive_built_in_value "OCAML_PATCH"
    (Dir_string
       (match String.rindex version '+' with
       | exception Not_found -> ""
       | i ->
           String.sub version (i + 1)
             (String.length version - i - 1)))
  ;
  replace_directive_built_in_value "OS_TYPE"
    (Dir_string Sys.os_type);
  replace_directive_built_in_value "BIG_ENDIAN"
    (Dir_bool Sys.big_endian);
  replace_directive_built_in_value "WORD_SIZE"
    (Dir_int Sys.word_size)

let find_directive_built_in_value k =
  Hashtbl.find directive_built_in_values k

let iter_directive_built_in_value f = Hashtbl.iter f directive_built_in_values

(*
   {[
     # semver 0 "12";;
     - : int * int * int * string = (12, 0, 0, "");;
     # semver 0 "12.3";;
     - : int * int * int * string = (12, 3, 0, "");;
       semver 0 "12.3.10";;
     - : int * int * int * string = (12, 3, 10, "");;
     # semver 0 "12.3.10+x";;
     - : int * int * int * string = (12, 3, 10, "+x")
   ]}
*)
let zero = Char.code '0'
let dot = Char.code '.'
let semantic_version_parse str start  last_index =
  let rec aux start  acc last_index =
    if start <= last_index then
      let c = Char.code (String.unsafe_get str start) in
      if c = dot then (acc, start + 1) (* consume [4.] instead of [4]*)
      else
        let v =  c - zero in
        if v >=0 && v <= 9  then
          aux (start + 1) (acc * 10 + v) last_index
        else (acc , start)
    else (acc, start)
  in
  let major, major_end =  aux start 0 last_index  in
  let minor, minor_end = aux major_end 0 last_index in
  let patch, patch_end = aux minor_end 0 last_index in
  let additional = String.sub str patch_end (last_index - patch_end  +1) in
  (major, minor, patch), additional

(**
   {[
     semver Location.none "1.2.3" "~1.3.0" = false;;
     semver Location.none "1.2.3" "^1.3.0" = true ;;
     semver Location.none "1.2.3" ">1.3.0" = false ;;
     semver Location.none "1.2.3" ">=1.3.0" = false ;;
     semver Location.none "1.2.3" "<1.3.0" = true ;;
     semver Location.none "1.2.3" "<=1.3.0" = true ;;
   ]}
*)
let semver loc lhs str =
  let last_index = String.length str - 1 in
  if last_index < 0 then raise (Error(Illegal_semver str, loc))
  else
    let pred, ((major, minor,patch) as version, _) =
      let v = String.unsafe_get str 0 in
      match v with
      | '>' ->
          if last_index = 0 then raise (Error(Illegal_semver str, loc)) else
          if String.unsafe_get str 1 = '=' then
            `Ge, semantic_version_parse str 2 last_index
          else `Gt, semantic_version_parse str 1 last_index
      | '<'
        ->
          if last_index = 0 then raise (Error(Illegal_semver str, loc)) else
          if String.unsafe_get str 1 = '=' then
            `Le, semantic_version_parse str 2 last_index
          else `Lt, semantic_version_parse str 1 last_index
      | '^'
        -> `Compatible, semantic_version_parse str 1 last_index
      | '~' ->  `Approximate, semantic_version_parse str 1 last_index
      | _ -> `Exact, semantic_version_parse str 0 last_index
    in
    let ((l_major, l_minor, l_patch) as lversion,_) =
      semantic_version_parse lhs 0 (String.length lhs - 1) in
    match pred with
    | `Ge -> lversion >= version
    | `Gt -> lversion > version
    | `Le -> lversion <= version
    | `Lt -> lversion < version
    | `Approximate -> major = l_major && minor = l_minor
    |  `Compatible -> major = l_major
    | `Exact -> lversion = version


let pp_directive_value fmt (x : directive_value) =
  match x with
  | Dir_bool b -> Format.pp_print_bool fmt b
  | Dir_int b -> Format.pp_print_int fmt b
  | Dir_float b -> Format.pp_print_float fmt b
  | Dir_string s  -> Format.fprintf fmt "%S" s
  | Dir_null -> Format.pp_print_string fmt "null"

let list_variables fmt =
  iter_directive_built_in_value
    (fun s  dir_value ->
       Format.fprintf
         fmt "@[%s@ %a@]@."
         s pp_directive_value dir_value
    )

let defined str =
  begin match  find_directive_built_in_value str with
  |  Dir_null -> false
  | _ ->  true
  | exception _ ->
      try ignore @@ Sys.getenv str; true with _ ->  false
  end

let query loc str =
  begin match find_directive_built_in_value str with
  | Dir_null -> Dir_bool false
  | v -> v
  | exception Not_found ->
      begin match Sys.getenv str with
      | v ->
          begin
            try Dir_bool (bool_of_string v) with
              _ ->
                begin
                  try Dir_int (int_of_string v )
                  with
                    _ ->
                      begin try (Dir_float (float_of_string v))
                      with _ -> Dir_string v
                      end
                end
          end
      | exception Not_found ->
          Dir_bool false
      end
  end


let define_key_value key v  =
  if String.length key > 0
      && Char.uppercase_ascii (key.[0]) = key.[0] then
    begin
      replace_directive_built_in_value key
      begin
        (* NEED Sync up across {!lexer.mll} {!bspp.ml} and here,
           TODO: put it in {!lexer.mll}
        *)
        try Dir_bool (bool_of_string v) with
          _ ->
          begin
            try Dir_int (int_of_string v )
            with
              _ ->
              begin try (Dir_float (float_of_string v))
                with _ -> Dir_string v
              end
          end
      end;
    true
    end
  else false


let value_of_token loc (t : Parser.token)  =
  match t with
  | INT i -> Dir_int i
  | STRING (s,_) -> Dir_string s
  | FLOAT s  -> Dir_float (float_of_string s)
  | TRUE -> Dir_bool true
  | FALSE -> Dir_bool false
  | UIDENT s -> query loc s
  | _ -> raise (Error (Unexpected_token_in_conditional, loc))


let directive_parse token_with_comments lexbuf =
  let look_ahead = ref None in
  let token () : Parser.token =
    let v = !look_ahead in
    match v with
    | Some v ->
        look_ahead := None ;
        v
    | None ->
       let rec skip () =
        match token_with_comments lexbuf  with
        | COMMENT _ -> skip ()

        | DOCSTRING _ -> skip ()

        | EOL -> skip ()
        | EOF -> raise (Error (Unterminated_if, Location.curr lexbuf))
        | t -> t
        in  skip ()
  in
  let push e =
    (* INVARIANT: only look at most one token *)
    assert (!look_ahead = None);
    look_ahead := Some e
  in
  let rec
    token_op calc   ~no  lhs   =
    match token () with
    | (LESS
    | GREATER
    | INFIXOP0 "<="
    | INFIXOP0 ">="
    | EQUAL
    | INFIXOP0 "<>" as op) ->
        let f =
          match op with
          | LESS -> (<)
          | GREATER -> (>)
          | INFIXOP0 "<=" -> (<=)
          | EQUAL -> (=)
          | INFIXOP0 "<>" -> (<>)
          | _ -> assert false
        in
        let curr_loc = Location.curr lexbuf in
        let rhs = value_of_token curr_loc (token ()) in
        not calc ||
        f lhs (assert_same_type lexbuf lhs rhs)
    | INFIXOP0 "=~" ->
        not calc ||
        begin match lhs with
        | Dir_string s ->
            let curr_loc = Location.curr lexbuf in
            let rhs = value_of_token curr_loc (token ()) in
            begin match rhs with
            | Dir_string rhs ->
                semver curr_loc s rhs
            | _ ->
                raise
                  (Error
                     ( Conditional_expr_expected_type
                         (Dir_type_string, type_of_directive lhs), Location.curr lexbuf))
            end
        | _ -> raise
                 (Error
                    ( Conditional_expr_expected_type
                        (Dir_type_string, type_of_directive lhs), Location.curr lexbuf))
        end
    | e -> no e
  and
    parse_or calc : bool =
    parse_or_aux calc (parse_and calc)
  and  (* a || (b || (c || d))*)
    parse_or_aux calc v : bool =
    (* let l = v  in *)
    match token () with
    | BARBAR ->
        let b =   parse_or (calc && not v)  in
        v || b
    | e -> push e ; v
  and parse_and calc =
    parse_and_aux calc (parse_relation calc)
  and parse_and_aux calc v = (* a && (b && (c && d)) *)
    (* let l = v  in *)
    match token () with
    | AMPERAMPER ->
        let b =  parse_and (calc && v) in
        v && b
    | e -> push e ; v
  and parse_relation (calc : bool) : bool  =
    let curr_token = token () in
    let curr_loc = Location.curr lexbuf in
    match curr_token with
    | TRUE -> true
    | FALSE -> false
    | UIDENT v ->
        let value_v = query curr_loc v in
        token_op calc
          ~no:(fun e -> push e ;
                match value_v with
                | Dir_bool b -> b
                | _ ->
                    let ty = type_of_directive value_v in
                    raise
                      (Error(Conditional_expr_expected_type (Dir_type_bool, ty),
                             curr_loc)))
          value_v
    | INT v ->
        token_op calc
          ~no:(fun e ->
                push e ;
                v <> 0


              )
          (Dir_int v)
    | FLOAT v ->
        token_op calc
          ~no:(fun e ->
              raise (Error(Conditional_expr_expected_type(Dir_type_bool, Dir_type_float),
                           curr_loc)))
          (Dir_float (float_of_string v))
    | STRING (v,_) ->
        token_op calc
          ~no:(fun e ->
              raise (Error
                       (Conditional_expr_expected_type(Dir_type_bool, Dir_type_string),
                        curr_loc)))
          (Dir_string v)
    | LIDENT ("defined" | "undefined" as r) ->
        let t = token () in
        let loc = Location.curr lexbuf in
        begin match t with
        | UIDENT s ->
            not calc ||
            if r.[0] = 'u' then
              not @@ defined s
            else defined s
        | _ -> raise (Error (Unexpected_token_in_conditional, loc))
        end
    | LPAREN ->
        let v = parse_or calc in
        begin match token () with
        | RPAREN ->  v
        | _ -> raise (Error(Unterminated_paren_in_conditional, Location.curr lexbuf))
        end

    | _ -> raise (Error (Unexpected_token_in_conditional, curr_loc))
  in
  let v = parse_or true in
  begin match token () with
  | THEN ->  v
  | _ -> raise (Error (Expect_hash_then_in_conditional, Location.curr lexbuf))
  end


type dir_conditional =
  | Dir_if_true
  | Dir_if_false
  | Dir_out

let string_of_dir_conditional (x : dir_conditional) =
  match x with
  | Dir_if_true -> "Dir_if_true"
  | Dir_if_false -> "Dir_if_false"
  | Dir_out -> "Dir_out"

let is_elif (i : Parser.token ) =
  match i with
  | LIDENT "elif" -> true
  | _ -> false (* avoid polymorphic equal *)


(* The table of keywords *)

let keyword_table =
  create_hashtable 149 [
    "and", AND;
    "as", AS;
    "assert", ASSERT;
    "begin", BEGIN;
    "class", CLASS;
    "constraint", CONSTRAINT;
    "do", DO;
    "done", DONE;
    "downto", DOWNTO;
    "else", ELSE;
    "end", END;
    "exception", EXCEPTION;
    "external", EXTERNAL;
    "false", FALSE;
    "for", FOR;
    "fun", FUN;
    "function", FUNCTION;
    "functor", FUNCTOR;
    "if", IF;
    "in", IN;
    "include", INCLUDE;
    "inherit", INHERIT;
    "initializer", INITIALIZER;
    "lazy", LAZY;
    "let", LET;
    "match", MATCH;
    "method", METHOD;
    "module", MODULE;
    "mutable", MUTABLE;
    "new", NEW;
    "nonrec", NONREC;
    "object", OBJECT;
    "of", OF;
    "open", OPEN;
    "or", OR;
(*  "parser", PARSER; *)
    "private", PRIVATE;
    "rec", REC;
    "sig", SIG;
    "struct", STRUCT;
    "then", THEN;
    "to", TO;
    "true", TRUE;
    "try", TRY;
    "type", TYPE;
    "val", VAL;
    "virtual", VIRTUAL;
    "when", WHEN;
    "while", WHILE;
    "with", WITH;

    "mod", INFIXOP3("mod");
    "land", INFIXOP3("land");
    "lor", INFIXOP3("lor");
    "lxor", INFIXOP3("lxor");
    "lsl", INFIXOP4("lsl");
    "lsr", INFIXOP4("lsr");
    "asr", INFIXOP4("asr")
]

(* To buffer string literals *)

let initial_string_buffer = Bytes.create 256
let string_buff = ref initial_string_buffer
let string_index = ref 0

let reset_string_buffer () =
  string_buff := initial_string_buffer;
  string_index := 0

let store_string_char c =
  if !string_index >= Bytes.length !string_buff then begin
    let new_buff = Bytes.create (Bytes.length (!string_buff) * 2) in
    Bytes.blit !string_buff 0 new_buff 0 (Bytes.length !string_buff);
    string_buff := new_buff
  end;
  Bytes.unsafe_set !string_buff !string_index c;
  incr string_index

let store_string s =
  for i = 0 to String.length s - 1 do
    store_string_char s.[i];
  done

let store_lexeme lexbuf =
  store_string (Lexing.lexeme lexbuf)

let get_stored_string () =
  let s = Bytes.sub_string !string_buff 0 !string_index in
  string_buff := initial_string_buffer;
  s

(* To store the position of the beginning of a string and comment *)
let string_start_loc = ref Location.none;;
let comment_start_loc = ref [];;
let in_comment () = !comment_start_loc <> [];;
let is_in_string = ref false
let in_string () = !is_in_string
let print_warnings = ref true
let if_then_else = ref Dir_out
let sharp_look_ahead = ref None
let update_if_then_else v =
  (* Format.fprintf Format.err_formatter "@[update %s \n@]@." (string_of_dir_conditional v); *)
  if_then_else := v

let with_comment_buffer comment lexbuf =
  let start_loc = Location.curr lexbuf  in
  comment_start_loc := [start_loc];
  reset_string_buffer ();
  let end_loc = comment lexbuf in
  let s = get_stored_string () in
  reset_string_buffer ();
  let loc = { start_loc with Location.loc_end = end_loc.Location.loc_end } in
  s, loc

(* To translate escape sequences *)

let char_for_backslash = function
  | 'n' -> '\010'
  | 'r' -> '\013'
  | 'b' -> '\008'
  | 't' -> '\009'
  | c   -> c

let char_for_decimal_code lexbuf i =
  let c = 100 * (Char.code(Lexing.lexeme_char lexbuf i) - 48) +
           10 * (Char.code(Lexing.lexeme_char lexbuf (i+1)) - 48) +
                (Char.code(Lexing.lexeme_char lexbuf (i+2)) - 48) in
  if (c < 0 || c > 255) then
    if in_comment ()
    then 'x'
    else raise (Error(Illegal_escape (Lexing.lexeme lexbuf),
                      Location.curr lexbuf))
  else Char.chr c

let char_for_hexadecimal_code lexbuf i =
  let d1 = Char.code (Lexing.lexeme_char lexbuf i) in
  let val1 = if d1 >= 97 then d1 - 87
             else if d1 >= 65 then d1 - 55
             else d1 - 48
  in
  let d2 = Char.code (Lexing.lexeme_char lexbuf (i+1)) in
  let val2 = if d2 >= 97 then d2 - 87
             else if d2 >= 65 then d2 - 55
             else d2 - 48
  in
  Char.chr (val1 * 16 + val2)

(* To convert integer literals, allowing max_int + 1 (PR#4210) *)

let cvt_int_literal s =
  - int_of_string ("-" ^ s)
let cvt_int32_literal s =
  Int32.neg (Int32.of_string ("-" ^ String.sub s 0 (String.length s - 1)))
let cvt_int64_literal s =
  Int64.neg (Int64.of_string ("-" ^ String.sub s 0 (String.length s - 1)))
let cvt_nativeint_literal s = assert false
  (* Nativeint.neg (Nativeint.of_string ("-" ^ String.sub s 0
                                                       (String.length s - 1))) *)

(* Remove underscores from float literals *)

let remove_underscores s =
  let l = String.length s in
  let b = Bytes.create l in
  let rec remove src dst =
    if src >= l then
      if dst >= l then s else Bytes.sub_string b 0 dst
    else
      match s.[src] with
        '_' -> remove (src + 1) dst
      |  c  -> Bytes.set b dst c; remove (src + 1) (dst + 1)
  in remove 0 0

(* recover the name from a LABEL or OPTLABEL token *)

let get_label_name lexbuf =
  let s = Lexing.lexeme lexbuf in
  let name = String.sub s 1 (String.length s - 2) in
  if Hashtbl.mem keyword_table name then
    raise (Error(Keyword_as_label name, Location.curr lexbuf));
  name
;;

(* Update the current location with file name and line number. *)

let update_loc lexbuf file line absolute chars =
  let pos = lexbuf.lex_curr_p in
  let new_file = match file with
                 | None -> pos.pos_fname
                 | Some s -> s
  in
  lexbuf.lex_curr_p <- { pos with
    pos_fname = new_file;
    pos_lnum = if absolute then line else pos.pos_lnum + line;
    pos_bol = pos.pos_cnum - chars;
  }
;;

let preprocessor = ref None

let escaped_newlines = ref false

(* Warn about Latin-1 characters used in idents *)

let warn_latin1 lexbuf =
  Location.prerr_warning (Location.curr lexbuf)
    (Warnings.Deprecated "ISO-Latin1 characters in identifiers")
;;

let comment_list = ref []

let add_comment com =
  comment_list := com :: !comment_list

let add_docstring_comment ds =

  let com = (Docstrings.docstring_body ds, Docstrings.docstring_loc ds) in
    add_comment com


let comments () = List.rev !comment_list

(* Error report *)

open Format

let report_error ppf = function
  | Illegal_character c ->
      fprintf ppf "Illegal character (%s)" (Char.escaped c)
  | Illegal_escape s ->
      fprintf ppf "Illegal backslash escape in string or character (%s)" s
  | Unterminated_comment _ ->
      fprintf ppf "Comment not terminated"
  | Unterminated_string ->
      fprintf ppf "String literal not terminated"
  | Unterminated_string_in_comment (_, loc) ->
      fprintf ppf "This comment contains an unterminated string literal@.\
                   %aString literal begins here"
              Location.print_error loc
  | Keyword_as_label kwd ->
      fprintf ppf "`%s' is a keyword, it cannot be used as label name" kwd
  | Literal_overflow ty ->
      fprintf ppf "Integer literal exceeds the range of representable \
                   integers of type %s" ty
  | Unterminated_if ->
      fprintf ppf "#if not terminated"
  | Unterminated_else ->
      fprintf ppf "#else not terminated"
  | Unexpected_directive -> fprintf ppf "Unexpected directive"
  | Unexpected_token_in_conditional ->
      fprintf ppf "Unexpected token in conditional predicate"
  | Unterminated_paren_in_conditional ->
    fprintf ppf "Unterminated parens in conditional predicate"
  | Expect_hash_then_in_conditional ->
      fprintf ppf "Expect `then` after conditional predicate"
  | Conditional_expr_expected_type (a,b) ->
      fprintf ppf "Conditional expression type mismatch (%s,%s)"
        (string_of_type_directive a )
        (string_of_type_directive b )
  | Illegal_semver s ->
      fprintf ppf "Illegal semantic version string %s" s
let () =
  Location.register_error_of_exn
    (function
      | Error (err, loc) ->
          Some (Location.error_of_printer loc report_error err)
      | _ ->
          None
    )


# 730 "parsing/lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\164\255\165\255\224\000\003\001\038\001\073\001\108\001\
    \143\001\188\255\178\001\215\001\196\255\091\000\252\001\031\002\
    \068\000\071\000\084\000\066\002\213\255\215\255\218\255\101\002\
    \196\002\231\002\089\000\255\000\005\003\236\255\082\003\115\003\
    \188\003\140\004\092\005\044\006\011\007\103\007\055\008\125\000\
    \254\255\001\000\005\000\255\255\006\000\007\000\022\009\052\009\
    \004\010\250\255\249\255\212\010\164\011\247\255\246\255\237\255\
    \238\255\239\255\093\000\118\002\091\000\110\000\231\002\007\004\
    \215\004\101\002\254\002\118\000\194\255\235\255\120\005\132\012\
    \096\000\113\000\011\000\234\255\233\255\229\255\229\004\128\000\
    \115\000\232\255\224\000\117\000\231\255\119\006\147\000\230\255\
    \146\000\225\255\148\000\224\255\217\000\132\012\223\255\171\012\
    \175\008\174\006\222\255\012\000\024\001\044\001\080\001\045\001\
    \222\255\013\000\217\012\000\013\035\013\073\013\210\255\206\255\
    \207\255\208\255\204\255\108\013\154\000\183\000\197\255\198\255\
    \199\255\199\000\182\255\184\255\191\255\143\013\187\255\189\255\
    \178\013\213\013\248\013\027\014\235\005\243\255\244\255\017\000\
    \245\255\062\002\172\007\253\255\223\000\241\000\255\255\254\255\
    \252\255\200\007\045\014\250\000\252\000\018\000\251\255\250\255\
    \249\255\128\009\030\003\003\001\248\255\092\003\004\001\247\255\
    \079\010\005\001\246\255\043\001\199\001\247\255\248\255\249\255\
    \059\001\118\014\255\255\250\255\031\011\036\004\253\255\038\001\
    \069\001\094\001\252\004\252\255\239\011\251\255\095\001\181\001\
    \252\255\238\006\254\255\255\255\111\001\112\001\253\255\074\007\
    \016\001\019\001\050\001\063\001\026\001\107\001\033\001\019\000\
    \255\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\088\000\087\000\084\000\083\000\076\000\
    \074\000\255\255\065\000\062\000\255\255\055\000\054\000\052\000\
    \050\000\046\000\044\000\079\000\255\255\255\255\255\255\035\000\
    \034\000\041\000\039\000\038\000\060\000\255\255\014\000\014\000\
    \013\000\012\000\011\000\010\000\007\000\004\000\003\000\002\000\
    \255\255\091\000\091\000\255\255\255\255\255\255\082\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\015\000\255\255\255\255\255\255\014\000\
    \014\000\014\000\015\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\026\000\026\000\
    \026\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \027\000\255\255\028\000\255\255\029\000\086\000\255\255\089\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\036\000\085\000\080\000\043\000\255\255\255\255\
    \255\255\255\255\255\255\053\000\070\000\069\000\255\255\255\255\
    \255\255\072\000\255\255\255\255\255\255\063\000\255\255\255\255\
    \081\000\075\000\078\000\077\000\255\255\255\255\255\255\012\000\
    \255\255\012\000\012\000\255\255\012\000\012\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \008\000\008\000\255\255\255\255\005\000\005\000\255\255\001\000\
    \005\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\003\000\255\255\255\255\003\000\255\255\255\255\255\255\
    \002\000\255\255\255\255\001\000\255\255\255\255\255\255\255\255\
    \255\255";
  Lexing.lex_default =
   "\001\000\000\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\000\000\255\255\
    \255\255\255\255\255\255\072\000\255\255\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\000\000\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\255\255\000\000\000\000\000\000\
    \000\000\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\255\255\077\000\
    \255\255\255\255\255\255\000\000\000\000\000\000\255\255\255\255\
    \255\255\000\000\255\255\255\255\000\000\255\255\255\255\000\000\
    \255\255\000\000\255\255\000\000\255\255\255\255\000\000\255\255\
    \100\000\255\255\000\000\255\255\100\000\101\000\100\000\103\000\
    \000\000\255\255\255\255\255\255\255\255\255\255\000\000\000\000\
    \000\000\000\000\000\000\255\255\255\255\255\255\000\000\000\000\
    \000\000\255\255\000\000\000\000\000\000\255\255\000\000\000\000\
    \255\255\255\255\255\255\255\255\133\000\000\000\000\000\255\255\
    \000\000\147\000\255\255\000\000\255\255\255\255\000\000\000\000\
    \000\000\255\255\255\255\255\255\255\255\255\255\000\000\000\000\
    \000\000\255\255\255\255\255\255\000\000\255\255\255\255\000\000\
    \255\255\255\255\000\000\255\255\165\000\000\000\000\000\000\000\
    \255\255\171\000\000\000\000\000\255\255\255\255\000\000\255\255\
    \255\255\255\255\255\255\000\000\255\255\000\000\255\255\184\000\
    \000\000\255\255\000\000\000\000\255\255\255\255\000\000\255\255\
    \255\255\255\255\194\000\197\000\255\255\197\000\255\255\255\255\
    \000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\039\000\040\000\040\000\039\000\041\000\045\000\043\000\
    \043\000\040\000\044\000\044\000\045\000\073\000\098\000\104\000\
    \074\000\099\000\105\000\134\000\148\000\200\000\163\000\149\000\
    \039\000\008\000\029\000\024\000\006\000\004\000\023\000\027\000\
    \026\000\021\000\025\000\007\000\020\000\019\000\018\000\003\000\
    \031\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\017\000\016\000\015\000\014\000\010\000\036\000\
    \005\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\013\000\042\000\012\000\005\000\038\000\
    \022\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\028\000\011\000\009\000\037\000\114\000\
    \116\000\113\000\110\000\088\000\112\000\111\000\039\000\076\000\
    \067\000\039\000\067\000\065\000\065\000\066\000\066\000\066\000\
    \066\000\066\000\066\000\066\000\066\000\066\000\066\000\119\000\
    \075\000\118\000\081\000\117\000\084\000\039\000\064\000\064\000\
    \064\000\064\000\064\000\064\000\064\000\064\000\066\000\066\000\
    \066\000\066\000\066\000\066\000\066\000\066\000\066\000\066\000\
    \082\000\082\000\082\000\082\000\082\000\082\000\082\000\082\000\
    \082\000\082\000\087\000\089\000\090\000\091\000\092\000\123\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\120\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\121\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \002\000\003\000\091\000\092\000\003\000\003\000\003\000\122\000\
    \143\000\073\000\003\000\003\000\074\000\003\000\003\000\003\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \083\000\083\000\003\000\142\000\003\000\003\000\003\000\003\000\
    \003\000\152\000\098\000\151\000\003\000\099\000\255\255\003\000\
    \003\000\003\000\156\000\159\000\162\000\003\000\003\000\175\000\
    \003\000\003\000\003\000\193\000\194\000\134\000\098\000\104\000\
    \163\000\099\000\105\000\198\000\195\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\199\000\167\000\175\000\005\000\
    \182\000\196\000\005\000\005\000\005\000\000\000\103\000\175\000\
    \005\000\005\000\177\000\005\000\005\000\005\000\000\000\000\000\
    \000\000\102\000\098\000\071\000\003\000\099\000\003\000\000\000\
    \005\000\003\000\005\000\005\000\005\000\005\000\005\000\000\000\
    \175\000\167\000\006\000\177\000\182\000\006\000\006\000\006\000\
    \102\000\000\000\101\000\006\000\006\000\196\000\006\000\006\000\
    \006\000\187\000\187\000\000\000\189\000\189\000\000\000\003\000\
    \000\000\003\000\000\000\006\000\005\000\006\000\006\000\006\000\
    \006\000\006\000\000\000\000\000\000\000\107\000\000\000\000\000\
    \107\000\107\000\107\000\000\000\000\000\000\000\107\000\107\000\
    \000\000\107\000\131\000\107\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\005\000\000\000\005\000\000\000\107\000\006\000\
    \107\000\130\000\107\000\107\000\107\000\000\000\000\000\000\000\
    \128\000\000\000\000\000\128\000\128\000\128\000\000\000\000\000\
    \000\000\128\000\128\000\000\000\128\000\128\000\128\000\187\000\
    \000\000\000\000\188\000\000\000\000\000\006\000\000\000\006\000\
    \000\000\128\000\107\000\128\000\129\000\128\000\128\000\128\000\
    \000\000\167\000\000\000\006\000\168\000\000\000\006\000\006\000\
    \006\000\000\000\000\000\000\000\006\000\006\000\000\000\006\000\
    \006\000\006\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \107\000\170\000\107\000\000\000\006\000\128\000\006\000\006\000\
    \006\000\006\000\006\000\000\000\000\000\000\000\000\000\000\000\
    \006\000\000\000\000\000\006\000\006\000\006\000\000\000\255\255\
    \000\000\006\000\006\000\000\000\006\000\006\000\006\000\000\000\
    \000\000\000\000\000\000\128\000\000\000\128\000\000\000\127\000\
    \006\000\006\000\000\000\006\000\006\000\006\000\006\000\006\000\
    \255\255\000\000\000\000\000\000\000\000\006\000\000\000\000\000\
    \006\000\006\000\006\000\169\000\000\000\000\000\006\000\006\000\
    \000\000\006\000\006\000\006\000\255\255\255\255\006\000\126\000\
    \006\000\185\000\255\255\000\000\124\000\006\000\006\000\000\000\
    \006\000\006\000\006\000\006\000\006\000\000\000\000\000\255\255\
    \006\000\000\000\000\000\006\000\006\000\006\000\000\000\000\000\
    \148\000\006\000\006\000\149\000\115\000\006\000\006\000\000\000\
    \255\255\000\000\000\000\125\000\000\000\006\000\000\000\000\000\
    \000\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \000\000\000\000\000\000\107\000\000\000\150\000\107\000\107\000\
    \107\000\000\000\000\000\255\255\107\000\107\000\000\000\107\000\
    \108\000\107\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \006\000\000\000\006\000\000\000\107\000\006\000\107\000\107\000\
    \109\000\107\000\107\000\000\000\000\000\000\000\006\000\000\000\
    \000\000\006\000\006\000\106\000\000\000\000\000\000\000\006\000\
    \006\000\000\000\006\000\006\000\006\000\065\000\065\000\000\000\
    \000\000\000\000\146\000\006\000\000\000\006\000\000\000\006\000\
    \107\000\006\000\006\000\006\000\006\000\006\000\059\000\059\000\
    \059\000\059\000\059\000\059\000\059\000\059\000\059\000\059\000\
    \000\000\056\000\000\000\000\000\000\000\186\000\000\000\000\000\
    \000\000\000\000\000\000\058\000\000\000\000\000\107\000\000\000\
    \107\000\000\000\000\000\006\000\065\000\000\000\000\000\166\000\
    \000\000\000\000\000\000\000\000\000\000\097\000\000\000\000\000\
    \000\000\057\000\000\000\055\000\000\000\059\000\000\000\000\000\
    \000\000\000\000\000\000\058\000\000\000\000\000\000\000\000\000\
    \000\000\006\000\000\000\006\000\097\000\095\000\000\000\095\000\
    \095\000\095\000\095\000\000\000\000\000\000\000\095\000\095\000\
    \000\000\095\000\095\000\095\000\096\000\096\000\096\000\096\000\
    \096\000\096\000\096\000\096\000\096\000\096\000\095\000\000\000\
    \095\000\095\000\095\000\095\000\095\000\000\000\000\000\000\000\
    \003\000\000\000\000\000\003\000\003\000\003\000\000\000\000\000\
    \094\000\093\000\003\000\000\000\003\000\003\000\003\000\063\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\063\000\063\000\
    \063\000\003\000\095\000\003\000\003\000\003\000\003\000\003\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\066\000\066\000\
    \066\000\066\000\066\000\066\000\066\000\066\000\066\000\066\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255\000\000\
    \095\000\068\000\095\000\000\000\000\000\003\000\000\000\000\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\157\000\157\000\
    \157\000\157\000\157\000\157\000\157\000\157\000\157\000\157\000\
    \000\000\000\000\000\000\000\000\000\000\066\000\000\000\000\000\
    \000\000\000\000\000\000\003\000\070\000\003\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \059\000\069\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\158\000\158\000\158\000\158\000\
    \158\000\158\000\158\000\158\000\158\000\158\000\000\000\058\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\056\000\000\000\
    \000\000\059\000\000\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\000\000\000\000\000\000\
    \000\000\030\000\000\000\000\000\000\000\060\000\000\000\058\000\
    \058\000\000\000\000\000\000\000\000\000\000\000\057\000\056\000\
    \055\000\000\000\061\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\062\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\030\000\000\000\000\000\060\000\000\000\000\000\
    \058\000\000\000\000\000\000\000\000\000\000\000\000\000\057\000\
    \000\000\055\000\061\000\032\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\062\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\000\000\
    \000\000\000\000\000\000\032\000\000\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\063\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\063\000\063\000\
    \063\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\000\000\000\000\
    \000\000\000\000\000\000\056\000\178\000\178\000\178\000\178\000\
    \178\000\178\000\178\000\178\000\178\000\178\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\063\000\000\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\000\000\000\000\
    \000\000\000\000\000\000\057\000\000\000\055\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\000\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\033\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\000\000\
    \000\000\000\000\000\000\033\000\000\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\064\000\
    \064\000\064\000\064\000\064\000\064\000\064\000\064\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\085\000\085\000\085\000\
    \085\000\085\000\085\000\085\000\085\000\085\000\085\000\000\000\
    \000\000\000\000\000\000\056\000\000\000\000\000\085\000\085\000\
    \085\000\085\000\085\000\085\000\179\000\179\000\179\000\179\000\
    \179\000\179\000\179\000\179\000\179\000\179\000\064\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\057\000\000\000\055\000\085\000\085\000\
    \085\000\085\000\085\000\085\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\000\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\034\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\000\000\
    \000\000\000\000\000\000\034\000\000\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\070\000\
    \000\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\000\000\069\000\134\000\000\000\000\000\
    \135\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\139\000\000\000\000\000\
    \000\000\000\000\137\000\141\000\000\000\140\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\000\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\035\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\138\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\000\000\
    \000\000\000\000\000\000\035\000\000\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\086\000\
    \086\000\086\000\086\000\086\000\086\000\086\000\086\000\086\000\
    \086\000\000\000\000\000\000\000\000\000\000\000\000\000\097\000\
    \086\000\086\000\086\000\086\000\086\000\086\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\097\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \086\000\086\000\086\000\086\000\086\000\086\000\096\000\096\000\
    \096\000\096\000\096\000\096\000\096\000\096\000\096\000\096\000\
    \000\000\000\000\000\000\136\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\000\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\000\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\046\000\000\000\000\000\046\000\
    \046\000\046\000\000\000\000\000\000\000\046\000\046\000\000\000\
    \046\000\046\000\046\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\046\000\000\000\046\000\
    \046\000\046\000\046\000\046\000\000\000\191\000\000\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\046\000\052\000\190\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\000\000\046\000\
    \046\000\046\000\000\000\046\000\046\000\046\000\000\000\000\000\
    \000\000\046\000\046\000\000\000\046\000\046\000\046\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\046\000\000\000\046\000\046\000\046\000\046\000\046\000\
    \000\000\191\000\000\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\046\000\048\000\190\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\000\000\046\000\000\000\046\000\000\000\000\000\
    \000\000\000\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\000\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\145\000\000\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \144\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\000\000\144\000\000\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\035\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\000\000\000\000\000\000\000\000\035\000\000\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \102\000\098\000\000\000\000\000\099\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\102\000\
    \000\000\101\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\096\000\
    \096\000\096\000\096\000\096\000\096\000\096\000\096\000\096\000\
    \096\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\000\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\000\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\046\000\
    \000\000\000\000\046\000\046\000\046\000\000\000\000\000\000\000\
    \046\000\046\000\000\000\046\000\046\000\046\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \046\000\000\000\046\000\046\000\046\000\046\000\046\000\000\000\
    \000\000\000\000\000\000\047\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\050\000\000\000\
    \000\000\000\000\000\000\000\000\046\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\000\000\
    \000\000\000\000\046\000\047\000\046\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\255\255\
    \160\000\160\000\160\000\160\000\160\000\160\000\160\000\160\000\
    \160\000\160\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\160\000\160\000\160\000\160\000\160\000\160\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\160\000\160\000\160\000\160\000\160\000\160\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\000\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\048\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\049\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\000\000\
    \000\000\000\000\000\000\048\000\000\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\161\000\
    \161\000\161\000\161\000\161\000\161\000\161\000\161\000\161\000\
    \161\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \161\000\161\000\161\000\161\000\161\000\161\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \161\000\161\000\161\000\161\000\161\000\161\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\000\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\051\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\054\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\000\000\
    \000\000\000\000\000\000\051\000\000\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\180\000\
    \180\000\180\000\180\000\180\000\180\000\180\000\180\000\180\000\
    \180\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \180\000\180\000\180\000\180\000\180\000\180\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \180\000\180\000\180\000\180\000\180\000\180\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\000\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\052\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\053\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\000\000\
    \000\000\000\000\000\000\052\000\000\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\181\000\
    \181\000\181\000\181\000\181\000\181\000\181\000\181\000\181\000\
    \181\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \181\000\181\000\181\000\181\000\181\000\181\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \181\000\181\000\181\000\181\000\181\000\181\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\000\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\000\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\080\000\093\000\080\000\000\000\
    \093\000\093\000\093\000\080\000\000\000\000\000\093\000\093\000\
    \000\000\093\000\093\000\093\000\079\000\079\000\079\000\079\000\
    \079\000\079\000\079\000\079\000\079\000\079\000\093\000\000\000\
    \093\000\093\000\093\000\093\000\093\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\095\000\000\000\095\000\095\000\
    \095\000\095\000\000\000\000\000\000\000\095\000\095\000\000\000\
    \095\000\095\000\095\000\000\000\000\000\000\000\000\000\000\000\
    \080\000\000\000\093\000\000\000\000\000\095\000\080\000\095\000\
    \095\000\095\000\095\000\095\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\080\000\000\000\000\000\000\000\080\000\000\000\
    \080\000\000\000\006\000\000\000\078\000\006\000\006\000\006\000\
    \093\000\000\000\093\000\006\000\006\000\000\000\006\000\006\000\
    \006\000\095\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\006\000\000\000\006\000\006\000\006\000\
    \006\000\006\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\107\000\000\000\000\000\107\000\107\000\107\000\095\000\
    \000\000\095\000\107\000\107\000\000\000\107\000\107\000\107\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\006\000\
    \000\000\000\000\107\000\000\000\107\000\107\000\107\000\107\000\
    \107\000\000\000\000\000\000\000\107\000\000\000\000\000\107\000\
    \107\000\107\000\000\000\000\000\000\000\107\000\107\000\000\000\
    \107\000\107\000\107\000\000\000\000\000\006\000\000\000\006\000\
    \000\000\000\000\000\000\000\000\000\000\107\000\107\000\107\000\
    \107\000\107\000\107\000\107\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\107\000\000\000\000\000\107\000\107\000\107\000\
    \000\000\000\000\000\000\107\000\107\000\000\000\107\000\107\000\
    \107\000\000\000\000\000\000\000\107\000\000\000\107\000\000\000\
    \000\000\107\000\000\000\107\000\255\255\107\000\107\000\107\000\
    \107\000\107\000\000\000\000\000\000\000\006\000\000\000\000\000\
    \006\000\006\000\006\000\000\000\000\000\000\000\006\000\006\000\
    \000\000\006\000\006\000\006\000\000\000\000\000\000\000\107\000\
    \000\000\107\000\000\000\000\000\000\000\000\000\006\000\107\000\
    \006\000\006\000\006\000\006\000\006\000\000\000\000\000\000\000\
    \006\000\000\000\000\000\006\000\006\000\006\000\000\000\000\000\
    \000\000\006\000\006\000\000\000\006\000\006\000\006\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\107\000\000\000\107\000\
    \000\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \000\000\000\000\000\000\128\000\000\000\000\000\128\000\128\000\
    \128\000\000\000\000\000\000\000\128\000\128\000\000\000\128\000\
    \128\000\128\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \006\000\000\000\006\000\000\000\128\000\006\000\128\000\128\000\
    \128\000\128\000\128\000\000\000\000\000\000\000\128\000\000\000\
    \000\000\128\000\128\000\128\000\000\000\000\000\000\000\128\000\
    \128\000\000\000\128\000\128\000\128\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\006\000\000\000\006\000\000\000\128\000\
    \128\000\128\000\128\000\128\000\128\000\128\000\000\000\000\000\
    \000\000\107\000\000\000\000\000\107\000\107\000\107\000\000\000\
    \000\000\000\000\107\000\107\000\000\000\107\000\107\000\107\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\128\000\000\000\
    \128\000\000\000\107\000\128\000\107\000\107\000\107\000\107\000\
    \107\000\000\000\000\000\000\000\107\000\000\000\000\000\107\000\
    \107\000\107\000\000\000\000\000\000\000\107\000\107\000\000\000\
    \107\000\107\000\107\000\000\000\000\000\155\000\000\000\155\000\
    \000\000\128\000\000\000\128\000\155\000\107\000\107\000\107\000\
    \107\000\107\000\107\000\107\000\000\000\154\000\154\000\154\000\
    \154\000\154\000\154\000\154\000\154\000\154\000\154\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\107\000\000\000\107\000\000\000\
    \000\000\107\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \175\000\000\000\000\000\176\000\000\000\000\000\000\000\000\000\
    \000\000\155\000\000\000\000\000\000\000\000\000\000\000\155\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\174\000\107\000\
    \174\000\107\000\000\000\155\000\000\000\174\000\000\000\155\000\
    \000\000\155\000\000\000\000\000\000\000\153\000\173\000\173\000\
    \173\000\173\000\173\000\173\000\173\000\173\000\173\000\173\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\174\000\000\000\000\000\000\000\000\000\000\000\
    \174\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\174\000\000\000\000\000\000\000\
    \174\000\000\000\174\000\000\000\000\000\000\000\172\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\255\255";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\041\000\000\000\000\000\041\000\042\000\
    \044\000\045\000\042\000\044\000\045\000\074\000\099\000\105\000\
    \074\000\099\000\105\000\135\000\149\000\199\000\135\000\149\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\016\000\
    \013\000\017\000\018\000\026\000\017\000\017\000\039\000\072\000\
    \058\000\039\000\058\000\060\000\060\000\058\000\058\000\058\000\
    \058\000\058\000\058\000\058\000\058\000\058\000\058\000\013\000\
    \073\000\013\000\080\000\013\000\083\000\039\000\061\000\061\000\
    \061\000\061\000\061\000\061\000\061\000\061\000\067\000\067\000\
    \067\000\067\000\067\000\067\000\067\000\067\000\067\000\067\000\
    \079\000\079\000\079\000\079\000\079\000\079\000\079\000\079\000\
    \079\000\079\000\086\000\088\000\088\000\090\000\090\000\116\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\013\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\117\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\003\000\092\000\092\000\003\000\003\000\003\000\121\000\
    \140\000\027\000\003\000\003\000\027\000\003\000\003\000\003\000\
    \082\000\082\000\082\000\082\000\082\000\082\000\082\000\082\000\
    \082\000\082\000\003\000\141\000\003\000\003\000\003\000\003\000\
    \003\000\147\000\100\000\148\000\004\000\100\000\027\000\004\000\
    \004\000\004\000\155\000\158\000\161\000\004\000\004\000\175\000\
    \004\000\004\000\004\000\192\000\193\000\163\000\101\000\103\000\
    \163\000\101\000\103\000\196\000\194\000\004\000\003\000\004\000\
    \004\000\004\000\004\000\004\000\198\000\168\000\175\000\005\000\
    \168\000\195\000\005\000\005\000\005\000\255\255\101\000\176\000\
    \005\000\005\000\176\000\005\000\005\000\005\000\255\255\255\255\
    \255\255\102\000\102\000\027\000\003\000\102\000\003\000\255\255\
    \005\000\004\000\005\000\005\000\005\000\005\000\005\000\255\255\
    \177\000\182\000\006\000\177\000\182\000\006\000\006\000\006\000\
    \102\000\255\255\102\000\006\000\006\000\197\000\006\000\006\000\
    \006\000\188\000\189\000\255\255\188\000\189\000\255\255\004\000\
    \255\255\004\000\255\255\006\000\005\000\006\000\006\000\006\000\
    \006\000\006\000\255\255\255\255\255\255\007\000\255\255\255\255\
    \007\000\007\000\007\000\255\255\255\255\255\255\007\000\007\000\
    \255\255\007\000\007\000\007\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\005\000\255\255\005\000\255\255\007\000\006\000\
    \007\000\007\000\007\000\007\000\007\000\255\255\255\255\255\255\
    \008\000\255\255\255\255\008\000\008\000\008\000\255\255\255\255\
    \255\255\008\000\008\000\255\255\008\000\008\000\008\000\183\000\
    \255\255\255\255\183\000\255\255\255\255\006\000\255\255\006\000\
    \255\255\008\000\007\000\008\000\008\000\008\000\008\000\008\000\
    \255\255\164\000\255\255\010\000\164\000\255\255\010\000\010\000\
    \010\000\255\255\255\255\255\255\010\000\010\000\255\255\010\000\
    \010\000\010\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \007\000\164\000\007\000\255\255\010\000\008\000\010\000\010\000\
    \010\000\010\000\010\000\255\255\255\255\255\255\255\255\255\255\
    \011\000\255\255\255\255\011\000\011\000\011\000\255\255\027\000\
    \255\255\011\000\011\000\255\255\011\000\011\000\011\000\255\255\
    \255\255\255\255\255\255\008\000\255\255\008\000\255\255\010\000\
    \010\000\011\000\255\255\011\000\011\000\011\000\011\000\011\000\
    \100\000\255\255\255\255\255\255\255\255\014\000\255\255\255\255\
    \014\000\014\000\014\000\164\000\255\255\255\255\014\000\014\000\
    \255\255\014\000\014\000\014\000\101\000\103\000\010\000\010\000\
    \010\000\183\000\194\000\255\255\011\000\011\000\014\000\255\255\
    \014\000\014\000\014\000\014\000\014\000\255\255\255\255\195\000\
    \015\000\255\255\255\255\015\000\015\000\015\000\255\255\255\255\
    \137\000\015\000\015\000\137\000\015\000\015\000\015\000\255\255\
    \102\000\255\255\255\255\011\000\255\255\011\000\255\255\255\255\
    \255\255\015\000\014\000\015\000\015\000\015\000\015\000\015\000\
    \255\255\255\255\255\255\019\000\255\255\137\000\019\000\019\000\
    \019\000\255\255\255\255\197\000\019\000\019\000\255\255\019\000\
    \019\000\019\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \014\000\255\255\014\000\255\255\019\000\015\000\019\000\019\000\
    \019\000\019\000\019\000\255\255\255\255\255\255\023\000\255\255\
    \255\255\023\000\023\000\023\000\255\255\255\255\255\255\023\000\
    \023\000\255\255\023\000\023\000\023\000\065\000\065\000\255\255\
    \255\255\255\255\137\000\015\000\255\255\015\000\255\255\023\000\
    \019\000\023\000\023\000\023\000\023\000\023\000\059\000\059\000\
    \059\000\059\000\059\000\059\000\059\000\059\000\059\000\059\000\
    \255\255\065\000\255\255\255\255\255\255\183\000\255\255\255\255\
    \255\255\255\255\255\255\059\000\255\255\255\255\019\000\255\255\
    \019\000\255\255\255\255\023\000\065\000\255\255\255\255\164\000\
    \255\255\255\255\255\255\255\255\255\255\024\000\255\255\255\255\
    \255\255\065\000\255\255\065\000\255\255\059\000\255\255\255\255\
    \255\255\255\255\255\255\059\000\255\255\255\255\255\255\255\255\
    \255\255\023\000\255\255\023\000\024\000\024\000\255\255\024\000\
    \024\000\024\000\024\000\255\255\255\255\255\255\024\000\024\000\
    \255\255\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\255\255\
    \024\000\024\000\024\000\024\000\024\000\255\255\255\255\255\255\
    \025\000\255\255\255\255\025\000\025\000\025\000\255\255\255\255\
    \025\000\025\000\025\000\255\255\025\000\025\000\025\000\062\000\
    \062\000\062\000\062\000\062\000\062\000\062\000\062\000\062\000\
    \062\000\025\000\024\000\025\000\025\000\025\000\025\000\025\000\
    \062\000\062\000\062\000\062\000\062\000\062\000\066\000\066\000\
    \066\000\066\000\066\000\066\000\066\000\066\000\066\000\066\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\137\000\255\255\
    \024\000\028\000\024\000\255\255\255\255\025\000\255\255\255\255\
    \062\000\062\000\062\000\062\000\062\000\062\000\154\000\154\000\
    \154\000\154\000\154\000\154\000\154\000\154\000\154\000\154\000\
    \255\255\255\255\255\255\255\255\255\255\066\000\255\255\255\255\
    \255\255\255\255\255\255\025\000\028\000\025\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \030\000\028\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\157\000\157\000\157\000\157\000\
    \157\000\157\000\157\000\157\000\157\000\157\000\255\255\030\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\030\000\255\255\
    \255\255\031\000\255\255\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\255\255\255\255\255\255\
    \255\255\030\000\255\255\255\255\255\255\031\000\255\255\030\000\
    \031\000\255\255\255\255\255\255\255\255\255\255\030\000\031\000\
    \030\000\255\255\031\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\031\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\031\000\255\255\255\255\031\000\255\255\255\255\
    \031\000\255\255\255\255\255\255\255\255\255\255\255\255\031\000\
    \255\255\031\000\031\000\032\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\031\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\255\255\
    \255\255\255\255\255\255\032\000\255\255\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\063\000\
    \063\000\063\000\063\000\063\000\063\000\063\000\063\000\063\000\
    \063\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \063\000\063\000\063\000\063\000\063\000\063\000\255\255\255\255\
    \255\255\255\255\255\255\063\000\173\000\173\000\173\000\173\000\
    \173\000\173\000\173\000\173\000\173\000\173\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\063\000\255\255\
    \063\000\063\000\063\000\063\000\063\000\063\000\255\255\255\255\
    \255\255\255\255\255\255\063\000\255\255\063\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\255\255\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\033\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\255\255\
    \255\255\255\255\255\255\033\000\255\255\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\064\000\
    \064\000\064\000\064\000\064\000\064\000\064\000\064\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\078\000\078\000\078\000\
    \078\000\078\000\078\000\078\000\078\000\078\000\078\000\255\255\
    \255\255\255\255\255\255\064\000\255\255\255\255\078\000\078\000\
    \078\000\078\000\078\000\078\000\178\000\178\000\178\000\178\000\
    \178\000\178\000\178\000\178\000\178\000\178\000\064\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\064\000\255\255\064\000\078\000\078\000\
    \078\000\078\000\078\000\078\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\255\255\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\034\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\033\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\255\255\
    \255\255\255\255\255\255\034\000\255\255\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\070\000\
    \255\255\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\070\000\070\000\070\000\070\000\070\000\
    \070\000\070\000\070\000\255\255\070\000\132\000\255\255\255\255\
    \132\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\132\000\255\255\255\255\
    \255\255\255\255\132\000\132\000\255\255\132\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\255\255\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\035\000\034\000\034\000\034\000\034\000\
    \034\000\034\000\034\000\034\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\132\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\255\255\
    \255\255\255\255\255\255\035\000\255\255\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\085\000\
    \085\000\085\000\085\000\085\000\085\000\085\000\085\000\085\000\
    \085\000\255\255\255\255\255\255\255\255\255\255\255\255\097\000\
    \085\000\085\000\085\000\085\000\085\000\085\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\097\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \085\000\085\000\085\000\085\000\085\000\085\000\097\000\097\000\
    \097\000\097\000\097\000\097\000\097\000\097\000\097\000\097\000\
    \255\255\255\255\255\255\132\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\255\255\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\255\255\035\000\035\000\035\000\035\000\
    \035\000\035\000\035\000\035\000\036\000\255\255\255\255\036\000\
    \036\000\036\000\255\255\255\255\255\255\036\000\036\000\255\255\
    \036\000\036\000\036\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\036\000\255\255\036\000\
    \036\000\036\000\036\000\036\000\255\255\185\000\255\255\185\000\
    \185\000\185\000\185\000\185\000\185\000\185\000\185\000\185\000\
    \185\000\185\000\185\000\185\000\185\000\185\000\185\000\185\000\
    \185\000\185\000\185\000\185\000\185\000\185\000\185\000\185\000\
    \185\000\036\000\036\000\185\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\255\255\036\000\
    \037\000\036\000\255\255\037\000\037\000\037\000\255\255\255\255\
    \255\255\037\000\037\000\255\255\037\000\037\000\037\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\037\000\255\255\037\000\037\000\037\000\037\000\037\000\
    \255\255\191\000\255\255\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\191\000\191\000\191\000\
    \191\000\191\000\191\000\191\000\191\000\037\000\037\000\191\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
    \037\000\037\000\255\255\037\000\255\255\037\000\255\255\255\255\
    \255\255\255\255\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\255\255\036\000\036\000\036\000\036\000\036\000\
    \036\000\036\000\036\000\138\000\255\255\138\000\138\000\138\000\
    \138\000\138\000\138\000\138\000\138\000\138\000\138\000\138\000\
    \138\000\138\000\138\000\138\000\138\000\138\000\138\000\138\000\
    \138\000\138\000\138\000\138\000\138\000\138\000\138\000\145\000\
    \138\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\145\000\145\000\145\000\145\000\145\000\
    \145\000\145\000\145\000\255\255\145\000\255\255\037\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\038\000\037\000\
    \037\000\037\000\037\000\037\000\037\000\037\000\037\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\255\255\255\255\255\255\255\255\038\000\255\255\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \096\000\096\000\255\255\255\255\096\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\096\000\
    \255\255\096\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\096\000\
    \096\000\096\000\096\000\096\000\096\000\096\000\096\000\096\000\
    \096\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\255\255\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\255\255\038\000\
    \038\000\038\000\038\000\038\000\038\000\038\000\038\000\046\000\
    \255\255\255\255\046\000\046\000\046\000\255\255\255\255\255\255\
    \046\000\046\000\255\255\046\000\046\000\046\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \046\000\255\255\046\000\046\000\046\000\046\000\046\000\255\255\
    \255\255\255\255\255\255\047\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\255\255\
    \255\255\255\255\255\255\255\255\046\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\255\255\
    \255\255\255\255\046\000\047\000\046\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\096\000\
    \153\000\153\000\153\000\153\000\153\000\153\000\153\000\153\000\
    \153\000\153\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\153\000\153\000\153\000\153\000\153\000\153\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\153\000\153\000\153\000\153\000\153\000\153\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\255\255\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\048\000\047\000\047\000\047\000\047\000\
    \047\000\047\000\047\000\047\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\255\255\
    \255\255\255\255\255\255\048\000\255\255\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\160\000\
    \160\000\160\000\160\000\160\000\160\000\160\000\160\000\160\000\
    \160\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \160\000\160\000\160\000\160\000\160\000\160\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \160\000\160\000\160\000\160\000\160\000\160\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\255\255\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\051\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\048\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\255\255\
    \255\255\255\255\255\255\051\000\255\255\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\172\000\
    \172\000\172\000\172\000\172\000\172\000\172\000\172\000\172\000\
    \172\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \172\000\172\000\172\000\172\000\172\000\172\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \172\000\172\000\172\000\172\000\172\000\172\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\255\255\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\052\000\051\000\051\000\051\000\051\000\
    \051\000\051\000\051\000\051\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\255\255\
    \255\255\255\255\255\255\052\000\255\255\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\180\000\
    \180\000\180\000\180\000\180\000\180\000\180\000\180\000\180\000\
    \180\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \180\000\180\000\180\000\180\000\180\000\180\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \180\000\180\000\180\000\180\000\180\000\180\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\255\255\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\255\255\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\071\000\093\000\071\000\255\255\
    \093\000\093\000\093\000\071\000\255\255\255\255\093\000\093\000\
    \255\255\093\000\093\000\093\000\071\000\071\000\071\000\071\000\
    \071\000\071\000\071\000\071\000\071\000\071\000\093\000\255\255\
    \093\000\093\000\093\000\093\000\093\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\095\000\255\255\095\000\095\000\
    \095\000\095\000\255\255\255\255\255\255\095\000\095\000\255\255\
    \095\000\095\000\095\000\255\255\255\255\255\255\255\255\255\255\
    \071\000\255\255\093\000\255\255\255\255\095\000\071\000\095\000\
    \095\000\095\000\095\000\095\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\071\000\255\255\255\255\255\255\071\000\255\255\
    \071\000\255\255\106\000\255\255\071\000\106\000\106\000\106\000\
    \093\000\255\255\093\000\106\000\106\000\255\255\106\000\106\000\
    \106\000\095\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\106\000\255\255\106\000\106\000\106\000\
    \106\000\106\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\107\000\255\255\255\255\107\000\107\000\107\000\095\000\
    \255\255\095\000\107\000\107\000\255\255\107\000\107\000\107\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\106\000\
    \255\255\255\255\107\000\255\255\107\000\107\000\107\000\107\000\
    \107\000\255\255\255\255\255\255\108\000\255\255\255\255\108\000\
    \108\000\108\000\255\255\255\255\255\255\108\000\108\000\255\255\
    \108\000\108\000\108\000\255\255\255\255\106\000\255\255\106\000\
    \255\255\255\255\255\255\255\255\255\255\108\000\107\000\108\000\
    \108\000\108\000\108\000\108\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\109\000\255\255\255\255\109\000\109\000\109\000\
    \255\255\255\255\255\255\109\000\109\000\255\255\109\000\109\000\
    \109\000\255\255\255\255\255\255\107\000\255\255\107\000\255\255\
    \255\255\108\000\255\255\109\000\071\000\109\000\109\000\109\000\
    \109\000\109\000\255\255\255\255\255\255\115\000\255\255\255\255\
    \115\000\115\000\115\000\255\255\255\255\255\255\115\000\115\000\
    \255\255\115\000\115\000\115\000\255\255\255\255\255\255\108\000\
    \255\255\108\000\255\255\255\255\255\255\255\255\115\000\109\000\
    \115\000\115\000\115\000\115\000\115\000\255\255\255\255\255\255\
    \125\000\255\255\255\255\125\000\125\000\125\000\255\255\255\255\
    \255\255\125\000\125\000\255\255\125\000\125\000\125\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\109\000\255\255\109\000\
    \255\255\125\000\115\000\125\000\125\000\125\000\125\000\125\000\
    \255\255\255\255\255\255\128\000\255\255\255\255\128\000\128\000\
    \128\000\255\255\255\255\255\255\128\000\128\000\255\255\128\000\
    \128\000\128\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \115\000\255\255\115\000\255\255\128\000\125\000\128\000\128\000\
    \128\000\128\000\128\000\255\255\255\255\255\255\129\000\255\255\
    \255\255\129\000\129\000\129\000\255\255\255\255\255\255\129\000\
    \129\000\255\255\129\000\129\000\129\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\125\000\255\255\125\000\255\255\129\000\
    \128\000\129\000\129\000\129\000\129\000\129\000\255\255\255\255\
    \255\255\130\000\255\255\255\255\130\000\130\000\130\000\255\255\
    \255\255\255\255\130\000\130\000\255\255\130\000\130\000\130\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\128\000\255\255\
    \128\000\255\255\130\000\129\000\130\000\130\000\130\000\130\000\
    \130\000\255\255\255\255\255\255\131\000\255\255\255\255\131\000\
    \131\000\131\000\255\255\255\255\255\255\131\000\131\000\255\255\
    \131\000\131\000\131\000\255\255\255\255\146\000\255\255\146\000\
    \255\255\129\000\255\255\129\000\146\000\131\000\130\000\131\000\
    \131\000\131\000\131\000\131\000\255\255\146\000\146\000\146\000\
    \146\000\146\000\146\000\146\000\146\000\146\000\146\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\130\000\255\255\130\000\255\255\
    \255\255\131\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \169\000\255\255\255\255\169\000\255\255\255\255\255\255\255\255\
    \255\255\146\000\255\255\255\255\255\255\255\255\255\255\146\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\169\000\131\000\
    \169\000\131\000\255\255\146\000\255\255\169\000\255\255\146\000\
    \255\255\146\000\255\255\255\255\255\255\146\000\169\000\169\000\
    \169\000\169\000\169\000\169\000\169\000\169\000\169\000\169\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\169\000\255\255\255\255\255\255\255\255\255\255\
    \169\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\169\000\255\255\255\255\255\255\
    \169\000\255\255\169\000\255\255\255\255\255\255\169\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\169\000";
  Lexing.lex_base_code =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \010\000\036\000\012\000\000\000\000\000\000\000\002\000\000\000\
    \027\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\001\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000";
  Lexing.lex_backtrk_code =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\039\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000";
  Lexing.lex_default_code =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\019\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000";
  Lexing.lex_trans_code =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\001\000\000\000\036\000\036\000\000\000\036\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \001\000\000\000\000\000\001\000\022\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\007\000\001\000\000\000\000\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\001\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000";
  Lexing.lex_check_code =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\024\000\101\000\169\000\176\000\101\000\177\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \024\000\255\255\101\000\000\000\102\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\096\000\097\000\255\255\255\255\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\096\000\096\000\096\000\096\000\096\000\096\000\
    \096\000\096\000\096\000\096\000\097\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\097\000\097\000\097\000\097\000\
    \097\000\097\000\097\000\097\000\097\000\097\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \101\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255";
  Lexing.lex_code =
   "\255\004\255\255\005\255\255\007\255\006\255\255\003\255\000\004\
    \001\005\255\007\255\255\006\255\007\255\255\000\004\001\005\003\
    \006\002\007\255\001\255\255\000\001\255";
}

let rec token lexbuf =
  lexbuf.Lexing.lex_mem <- Array.make 8 (-1) ;   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.new_engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 770 "parsing/lexer.mll"
                 (
      if not !escaped_newlines then
        raise (Error(Illegal_character (Lexing.lexeme_char lexbuf 0),
                     Location.curr lexbuf));
      update_loc lexbuf None 1 false 0;
      token lexbuf )
# 1980 "parsing/lexer.ml"

  | 1 ->
# 777 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        EOL )
# 1986 "parsing/lexer.ml"

  | 2 ->
# 780 "parsing/lexer.mll"
      ( token lexbuf )
# 1991 "parsing/lexer.ml"

  | 3 ->
# 782 "parsing/lexer.mll"
      ( UNDERSCORE )
# 1996 "parsing/lexer.ml"

  | 4 ->
# 784 "parsing/lexer.mll"
      ( TILDE )
# 2001 "parsing/lexer.ml"

  | 5 ->
# 786 "parsing/lexer.mll"
      ( LABEL (get_label_name lexbuf) )
# 2006 "parsing/lexer.ml"

  | 6 ->
# 788 "parsing/lexer.mll"
      ( warn_latin1 lexbuf; LABEL (get_label_name lexbuf) )
# 2011 "parsing/lexer.ml"

  | 7 ->
# 790 "parsing/lexer.mll"
      ( QUESTION )
# 2016 "parsing/lexer.ml"

  | 8 ->
# 792 "parsing/lexer.mll"
      ( OPTLABEL (get_label_name lexbuf) )
# 2021 "parsing/lexer.ml"

  | 9 ->
# 794 "parsing/lexer.mll"
      ( warn_latin1 lexbuf; OPTLABEL (get_label_name lexbuf) )
# 2026 "parsing/lexer.ml"

  | 10 ->
# 796 "parsing/lexer.mll"
      ( let s = Lexing.lexeme lexbuf in
        try Hashtbl.find keyword_table s
        with Not_found -> LIDENT s )
# 2033 "parsing/lexer.ml"

  | 11 ->
# 800 "parsing/lexer.mll"
      ( warn_latin1 lexbuf; LIDENT (Lexing.lexeme lexbuf) )
# 2038 "parsing/lexer.ml"

  | 12 ->
# 802 "parsing/lexer.mll"
      ( UIDENT(Lexing.lexeme lexbuf) )
# 2043 "parsing/lexer.ml"

  | 13 ->
# 804 "parsing/lexer.mll"
      ( warn_latin1 lexbuf; UIDENT(Lexing.lexeme lexbuf) )
# 2048 "parsing/lexer.ml"

  | 14 ->
# 806 "parsing/lexer.mll"
      ( try
          INT (cvt_int_literal (Lexing.lexeme lexbuf))
        with Failure _ ->
          raise (Error(Literal_overflow "int", Location.curr lexbuf))
      )
# 2057 "parsing/lexer.ml"

  | 15 ->
# 812 "parsing/lexer.mll"
      ( FLOAT (remove_underscores(Lexing.lexeme lexbuf)) )
# 2062 "parsing/lexer.ml"

  | 16 ->
# 814 "parsing/lexer.mll"
      ( try
          INT32 (cvt_int32_literal (Lexing.lexeme lexbuf))
        with Failure _ ->
          raise (Error(Literal_overflow "int32", Location.curr lexbuf)) )
# 2070 "parsing/lexer.ml"

  | 17 ->
# 819 "parsing/lexer.mll"
      ( try
          INT64 (cvt_int64_literal (Lexing.lexeme lexbuf))
        with Failure _ ->
          raise (Error(Literal_overflow "int64", Location.curr lexbuf)) )
# 2078 "parsing/lexer.ml"

  | 18 ->
# 824 "parsing/lexer.mll"
      ( try
          NATIVEINT (cvt_nativeint_literal (Lexing.lexeme lexbuf))
        with Failure _ ->
          raise (Error(Literal_overflow "nativeint", Location.curr lexbuf)) )
# 2086 "parsing/lexer.ml"

  | 19 ->
# 829 "parsing/lexer.mll"
      ( reset_string_buffer();
        is_in_string := true;
        let string_start = lexbuf.lex_start_p in
        string_start_loc := Location.curr lexbuf;
        string lexbuf;
        is_in_string := false;
        lexbuf.lex_start_p <- string_start;
        STRING (get_stored_string(), None) )
# 2098 "parsing/lexer.ml"

  | 20 ->
# 838 "parsing/lexer.mll"
      ( reset_string_buffer();
        let delim = Lexing.lexeme lexbuf in
        let delim = String.sub delim 1 (String.length delim - 2) in
        is_in_string := true;
        let string_start = lexbuf.lex_start_p in
        string_start_loc := Location.curr lexbuf;
        quoted_string delim lexbuf;
        is_in_string := false;
        lexbuf.lex_start_p <- string_start;
        STRING (get_stored_string(), Some delim) )
# 2112 "parsing/lexer.ml"

  | 21 ->
# 849 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false 1;
        CHAR (Lexing.lexeme_char lexbuf 1) )
# 2118 "parsing/lexer.ml"

  | 22 ->
# 852 "parsing/lexer.mll"
      ( CHAR(Lexing.lexeme_char lexbuf 1) )
# 2123 "parsing/lexer.ml"

  | 23 ->
# 854 "parsing/lexer.mll"
      ( CHAR(char_for_backslash (Lexing.lexeme_char lexbuf 2)) )
# 2128 "parsing/lexer.ml"

  | 24 ->
# 856 "parsing/lexer.mll"
      ( CHAR(char_for_decimal_code lexbuf 2) )
# 2133 "parsing/lexer.ml"

  | 25 ->
# 858 "parsing/lexer.mll"
      ( CHAR(char_for_hexadecimal_code lexbuf 3) )
# 2138 "parsing/lexer.ml"

  | 26 ->
# 860 "parsing/lexer.mll"
      ( let l = Lexing.lexeme lexbuf in
        let esc = String.sub l 1 (String.length l - 1) in
        raise (Error(Illegal_escape esc, Location.curr lexbuf))
      )
# 2146 "parsing/lexer.ml"

  | 27 ->
# 865 "parsing/lexer.mll"
      ( let s, loc = with_comment_buffer comment lexbuf in
        COMMENT (s, loc) )
# 2152 "parsing/lexer.ml"

  | 28 ->
# 868 "parsing/lexer.mll"
      ( let s, loc = with_comment_buffer comment lexbuf in

        DOCSTRING (Docstrings.docstring s loc)

)
# 2163 "parsing/lexer.ml"

  | 29 ->
let
# 875 "parsing/lexer.mll"
                    stars
# 2169 "parsing/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 876 "parsing/lexer.mll"
      ( let s, loc =
          with_comment_buffer
            (fun lexbuf ->
               store_string ("*" ^ stars);
               comment lexbuf)
            lexbuf
        in
        COMMENT (s, loc) )
# 2180 "parsing/lexer.ml"

  | 30 ->
# 885 "parsing/lexer.mll"
      ( if !print_warnings then
          Location.prerr_warning (Location.curr lexbuf) Warnings.Comment_start;
        let s, loc = with_comment_buffer comment lexbuf in
        COMMENT (s, loc) )
# 2188 "parsing/lexer.ml"

  | 31 ->
let
# 889 "parsing/lexer.mll"
                   stars
# 2194 "parsing/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos (lexbuf.Lexing.lex_curr_pos + -2) in
# 890 "parsing/lexer.mll"
      ( COMMENT (stars, Location.curr lexbuf) )
# 2198 "parsing/lexer.ml"

  | 32 ->
# 892 "parsing/lexer.mll"
      ( let loc = Location.curr lexbuf in
        Location.prerr_warning loc Warnings.Comment_not_end;
        lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_curr_pos - 1;
        let curpos = lexbuf.lex_curr_p in
        lexbuf.lex_curr_p <- { curpos with pos_cnum = curpos.pos_cnum - 1 };
        STAR
      )
# 2209 "parsing/lexer.ml"

  | 33 ->
let
# 899 "parsing/lexer.mll"
                                   num
# 2215 "parsing/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_mem.(0) lexbuf.Lexing.lex_mem.(1)
and
# 900 "parsing/lexer.mll"
                                           name
# 2220 "parsing/lexer.ml"
= Lexing.sub_lexeme_opt lexbuf lexbuf.Lexing.lex_mem.(3) lexbuf.Lexing.lex_mem.(2) in
# 902 "parsing/lexer.mll"
      ( update_loc lexbuf name (int_of_string num) true 0;
        token lexbuf
      )
# 2226 "parsing/lexer.ml"

  | 34 ->
# 905 "parsing/lexer.mll"
         ( SHARP )
# 2231 "parsing/lexer.ml"

  | 35 ->
# 906 "parsing/lexer.mll"
         ( AMPERSAND )
# 2236 "parsing/lexer.ml"

  | 36 ->
# 907 "parsing/lexer.mll"
         ( AMPERAMPER )
# 2241 "parsing/lexer.ml"

  | 37 ->
# 908 "parsing/lexer.mll"
         ( BACKQUOTE )
# 2246 "parsing/lexer.ml"

  | 38 ->
# 909 "parsing/lexer.mll"
         ( QUOTE )
# 2251 "parsing/lexer.ml"

  | 39 ->
# 910 "parsing/lexer.mll"
         ( LPAREN )
# 2256 "parsing/lexer.ml"

  | 40 ->
# 911 "parsing/lexer.mll"
         ( RPAREN )
# 2261 "parsing/lexer.ml"

  | 41 ->
# 912 "parsing/lexer.mll"
         ( STAR )
# 2266 "parsing/lexer.ml"

  | 42 ->
# 913 "parsing/lexer.mll"
         ( COMMA )
# 2271 "parsing/lexer.ml"

  | 43 ->
# 914 "parsing/lexer.mll"
         ( MINUSGREATER )
# 2276 "parsing/lexer.ml"

  | 44 ->
# 915 "parsing/lexer.mll"
         ( DOT )
# 2281 "parsing/lexer.ml"

  | 45 ->
# 916 "parsing/lexer.mll"
         ( DOTDOT )
# 2286 "parsing/lexer.ml"

  | 46 ->
# 917 "parsing/lexer.mll"
         ( COLON )
# 2291 "parsing/lexer.ml"

  | 47 ->
# 918 "parsing/lexer.mll"
         ( COLONCOLON )
# 2296 "parsing/lexer.ml"

  | 48 ->
# 919 "parsing/lexer.mll"
         ( COLONEQUAL )
# 2301 "parsing/lexer.ml"

  | 49 ->
# 920 "parsing/lexer.mll"
         ( COLONGREATER )
# 2306 "parsing/lexer.ml"

  | 50 ->
# 921 "parsing/lexer.mll"
         ( SEMI )
# 2311 "parsing/lexer.ml"

  | 51 ->
# 922 "parsing/lexer.mll"
         ( SEMISEMI )
# 2316 "parsing/lexer.ml"

  | 52 ->
# 923 "parsing/lexer.mll"
         ( LESS )
# 2321 "parsing/lexer.ml"

  | 53 ->
# 924 "parsing/lexer.mll"
         ( LESSMINUS )
# 2326 "parsing/lexer.ml"

  | 54 ->
# 925 "parsing/lexer.mll"
         ( EQUAL )
# 2331 "parsing/lexer.ml"

  | 55 ->
# 926 "parsing/lexer.mll"
         ( LBRACKET )
# 2336 "parsing/lexer.ml"

  | 56 ->
# 927 "parsing/lexer.mll"
         ( LBRACKETBAR )
# 2341 "parsing/lexer.ml"

  | 57 ->
# 928 "parsing/lexer.mll"
         ( LBRACKETLESS )
# 2346 "parsing/lexer.ml"

  | 58 ->
# 929 "parsing/lexer.mll"
         ( LBRACKETGREATER )
# 2351 "parsing/lexer.ml"

  | 59 ->
# 930 "parsing/lexer.mll"
         ( RBRACKET )
# 2356 "parsing/lexer.ml"

  | 60 ->
# 931 "parsing/lexer.mll"
         ( LBRACE )
# 2361 "parsing/lexer.ml"

  | 61 ->
# 932 "parsing/lexer.mll"
         ( LBRACELESS )
# 2366 "parsing/lexer.ml"

  | 62 ->
# 933 "parsing/lexer.mll"
         ( BAR )
# 2371 "parsing/lexer.ml"

  | 63 ->
# 934 "parsing/lexer.mll"
         ( BARBAR )
# 2376 "parsing/lexer.ml"

  | 64 ->
# 935 "parsing/lexer.mll"
         ( BARRBRACKET )
# 2381 "parsing/lexer.ml"

  | 65 ->
# 936 "parsing/lexer.mll"
         ( GREATER )
# 2386 "parsing/lexer.ml"

  | 66 ->
# 937 "parsing/lexer.mll"
         ( GREATERRBRACKET )
# 2391 "parsing/lexer.ml"

  | 67 ->
# 938 "parsing/lexer.mll"
         ( RBRACE )
# 2396 "parsing/lexer.ml"

  | 68 ->
# 939 "parsing/lexer.mll"
         ( GREATERRBRACE )
# 2401 "parsing/lexer.ml"

  | 69 ->
# 940 "parsing/lexer.mll"
         ( LBRACKETAT )
# 2406 "parsing/lexer.ml"

  | 70 ->
# 941 "parsing/lexer.mll"
         ( LBRACKETPERCENT )
# 2411 "parsing/lexer.ml"

  | 71 ->
# 942 "parsing/lexer.mll"
          ( LBRACKETPERCENTPERCENT )
# 2416 "parsing/lexer.ml"

  | 72 ->
# 943 "parsing/lexer.mll"
          ( LBRACKETATAT )
# 2421 "parsing/lexer.ml"

  | 73 ->
# 944 "parsing/lexer.mll"
           ( LBRACKETATATAT )
# 2426 "parsing/lexer.ml"

  | 74 ->
# 945 "parsing/lexer.mll"
         ( BANG )
# 2431 "parsing/lexer.ml"

  | 75 ->
# 946 "parsing/lexer.mll"
         ( INFIXOP0 "!=" )
# 2436 "parsing/lexer.ml"

  | 76 ->
# 947 "parsing/lexer.mll"
         ( PLUS )
# 2441 "parsing/lexer.ml"

  | 77 ->
# 948 "parsing/lexer.mll"
         ( PLUSDOT )
# 2446 "parsing/lexer.ml"

  | 78 ->
# 949 "parsing/lexer.mll"
         ( PLUSEQ )
# 2451 "parsing/lexer.ml"

  | 79 ->
# 950 "parsing/lexer.mll"
         ( MINUS )
# 2456 "parsing/lexer.ml"

  | 80 ->
# 951 "parsing/lexer.mll"
         ( MINUSDOT )
# 2461 "parsing/lexer.ml"

  | 81 ->
# 954 "parsing/lexer.mll"
            ( PREFIXOP(Lexing.lexeme lexbuf) )
# 2466 "parsing/lexer.ml"

  | 82 ->
# 956 "parsing/lexer.mll"
            ( PREFIXOP(Lexing.lexeme lexbuf) )
# 2471 "parsing/lexer.ml"

  | 83 ->
# 958 "parsing/lexer.mll"
            ( INFIXOP0(Lexing.lexeme lexbuf) )
# 2476 "parsing/lexer.ml"

  | 84 ->
# 960 "parsing/lexer.mll"
            ( INFIXOP1(Lexing.lexeme lexbuf) )
# 2481 "parsing/lexer.ml"

  | 85 ->
# 962 "parsing/lexer.mll"
            ( INFIXOP2(Lexing.lexeme lexbuf) )
# 2486 "parsing/lexer.ml"

  | 86 ->
# 964 "parsing/lexer.mll"
            ( INFIXOP4(Lexing.lexeme lexbuf) )
# 2491 "parsing/lexer.ml"

  | 87 ->
# 965 "parsing/lexer.mll"
            ( PERCENT )
# 2496 "parsing/lexer.ml"

  | 88 ->
# 967 "parsing/lexer.mll"
            ( INFIXOP3(Lexing.lexeme lexbuf) )
# 2501 "parsing/lexer.ml"

  | 89 ->
# 969 "parsing/lexer.mll"
            ( SHARPOP(Lexing.lexeme lexbuf) )
# 2506 "parsing/lexer.ml"

  | 90 ->
# 970 "parsing/lexer.mll"
        (
      if !if_then_else <> Dir_out then
        if !if_then_else = Dir_if_true then
          raise (Error (Unterminated_if, Location.curr lexbuf))
        else raise (Error(Unterminated_else, Location.curr lexbuf))
      else
        EOF

    )
# 2519 "parsing/lexer.ml"

  | 91 ->
# 980 "parsing/lexer.mll"
      ( raise (Error(Illegal_character (Lexing.lexeme_char lexbuf 0),
                     Location.curr lexbuf))
      )
# 2526 "parsing/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 132
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 986 "parsing/lexer.mll"
      ( comment_start_loc := (Location.curr lexbuf) :: !comment_start_loc;
        store_lexeme lexbuf;
        comment lexbuf;
      )
# 2541 "parsing/lexer.ml"

  | 1 ->
# 991 "parsing/lexer.mll"
      ( match !comment_start_loc with
        | [] -> assert false
        | [_] -> comment_start_loc := []; Location.curr lexbuf
        | _ :: l -> comment_start_loc := l;
                  store_lexeme lexbuf;
                  comment lexbuf;
       )
# 2552 "parsing/lexer.ml"

  | 2 ->
# 999 "parsing/lexer.mll"
      (
        string_start_loc := Location.curr lexbuf;
        store_string_char '"';
        is_in_string := true;
        begin try string lexbuf
        with Error (Unterminated_string, str_start) ->
          match !comment_start_loc with
          | [] -> assert false
          | loc :: _ ->
            let start = List.hd (List.rev !comment_start_loc) in
            comment_start_loc := [];
            raise (Error (Unterminated_string_in_comment (start, str_start),
                          loc))
        end;
        is_in_string := false;
        store_string_char '"';
        comment lexbuf )
# 2573 "parsing/lexer.ml"

  | 3 ->
# 1017 "parsing/lexer.mll"
      (
        let delim = Lexing.lexeme lexbuf in
        let delim = String.sub delim 1 (String.length delim - 2) in
        string_start_loc := Location.curr lexbuf;
        store_lexeme lexbuf;
        is_in_string := true;
        begin try quoted_string delim lexbuf
        with Error (Unterminated_string, str_start) ->
          match !comment_start_loc with
          | [] -> assert false
          | loc :: _ ->
            let start = List.hd (List.rev !comment_start_loc) in
            comment_start_loc := [];
            raise (Error (Unterminated_string_in_comment (start, str_start),
                          loc))
        end;
        is_in_string := false;
        store_string_char '|';
        store_string delim;
        store_string_char '}';
        comment lexbuf )
# 2598 "parsing/lexer.ml"

  | 4 ->
# 1040 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2603 "parsing/lexer.ml"

  | 5 ->
# 1042 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false 1;
        store_lexeme lexbuf;
        comment lexbuf
      )
# 2611 "parsing/lexer.ml"

  | 6 ->
# 1047 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2616 "parsing/lexer.ml"

  | 7 ->
# 1049 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2621 "parsing/lexer.ml"

  | 8 ->
# 1051 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2626 "parsing/lexer.ml"

  | 9 ->
# 1053 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2631 "parsing/lexer.ml"

  | 10 ->
# 1055 "parsing/lexer.mll"
      ( match !comment_start_loc with
        | [] -> assert false
        | loc :: _ ->
          let start = List.hd (List.rev !comment_start_loc) in
          comment_start_loc := [];
          raise (Error (Unterminated_comment start, loc))
      )
# 2642 "parsing/lexer.ml"

  | 11 ->
# 1063 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        store_lexeme lexbuf;
        comment lexbuf
      )
# 2650 "parsing/lexer.ml"

  | 12 ->
# 1068 "parsing/lexer.mll"
      ( store_lexeme lexbuf; comment lexbuf )
# 2655 "parsing/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and string lexbuf =
  lexbuf.Lexing.lex_mem <- Array.make 2 (-1) ;   __ocaml_lex_string_rec lexbuf 164
and __ocaml_lex_string_rec lexbuf __ocaml_lex_state =
  match Lexing.new_engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 1072 "parsing/lexer.mll"
      ( () )
# 2667 "parsing/lexer.ml"

  | 1 ->
let
# 1073 "parsing/lexer.mll"
                                  space
# 2673 "parsing/lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_mem.(0) lexbuf.Lexing.lex_curr_pos in
# 1074 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false (String.length space);
        string lexbuf
      )
# 2679 "parsing/lexer.ml"

  | 2 ->
# 1078 "parsing/lexer.mll"
      ( store_string_char(char_for_backslash(Lexing.lexeme_char lexbuf 1));
        string lexbuf )
# 2685 "parsing/lexer.ml"

  | 3 ->
# 1081 "parsing/lexer.mll"
      ( store_string_char(char_for_decimal_code lexbuf 1);
         string lexbuf )
# 2691 "parsing/lexer.ml"

  | 4 ->
# 1084 "parsing/lexer.mll"
      ( store_string_char(char_for_hexadecimal_code lexbuf 2);
         string lexbuf )
# 2697 "parsing/lexer.ml"

  | 5 ->
# 1087 "parsing/lexer.mll"
      ( if in_comment ()
        then string lexbuf
        else begin
(*  Should be an error, but we are very lax.
          raise (Error (Illegal_escape (Lexing.lexeme lexbuf),
                        Location.curr lexbuf))
*)
          let loc = Location.curr lexbuf in
          Location.prerr_warning loc Warnings.Illegal_backslash;
          store_string_char (Lexing.lexeme_char lexbuf 0);
          store_string_char (Lexing.lexeme_char lexbuf 1);
          string lexbuf
        end
      )
# 2715 "parsing/lexer.ml"

  | 6 ->
# 1102 "parsing/lexer.mll"
      ( if not (in_comment ()) then
          Location.prerr_warning (Location.curr lexbuf) Warnings.Eol_in_string;
        update_loc lexbuf None 1 false 0;
        store_lexeme lexbuf;
        string lexbuf
      )
# 2725 "parsing/lexer.ml"

  | 7 ->
# 1109 "parsing/lexer.mll"
      ( is_in_string := false;
        raise (Error (Unterminated_string, !string_start_loc)) )
# 2731 "parsing/lexer.ml"

  | 8 ->
# 1112 "parsing/lexer.mll"
      ( store_string_char(Lexing.lexeme_char lexbuf 0);
        string lexbuf )
# 2737 "parsing/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_string_rec lexbuf __ocaml_lex_state

and quoted_string delim lexbuf =
    __ocaml_lex_quoted_string_rec delim lexbuf 183
and __ocaml_lex_quoted_string_rec delim lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 1117 "parsing/lexer.mll"
      ( update_loc lexbuf None 1 false 0;
        store_lexeme lexbuf;
        quoted_string delim lexbuf
      )
# 2752 "parsing/lexer.ml"

  | 1 ->
# 1122 "parsing/lexer.mll"
      ( is_in_string := false;
        raise (Error (Unterminated_string, !string_start_loc)) )
# 2758 "parsing/lexer.ml"

  | 2 ->
# 1125 "parsing/lexer.mll"
      (
        let edelim = Lexing.lexeme lexbuf in
        let edelim = String.sub edelim 1 (String.length edelim - 2) in
        if delim = edelim then ()
        else (store_lexeme lexbuf; quoted_string delim lexbuf)
      )
# 2768 "parsing/lexer.ml"

  | 3 ->
# 1132 "parsing/lexer.mll"
      ( store_string_char(Lexing.lexeme_char lexbuf 0);
        quoted_string delim lexbuf )
# 2774 "parsing/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_quoted_string_rec delim lexbuf __ocaml_lex_state

and skip_sharp_bang lexbuf =
    __ocaml_lex_skip_sharp_bang_rec lexbuf 192
and __ocaml_lex_skip_sharp_bang_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 1137 "parsing/lexer.mll"
       ( update_loc lexbuf None 3 false 0 )
# 2786 "parsing/lexer.ml"

  | 1 ->
# 1139 "parsing/lexer.mll"
       ( update_loc lexbuf None 1 false 0 )
# 2791 "parsing/lexer.ml"

  | 2 ->
# 1140 "parsing/lexer.mll"
       ( () )
# 2796 "parsing/lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_skip_sharp_bang_rec lexbuf __ocaml_lex_state

;;

# 1142 "parsing/lexer.mll"


  let at_bol lexbuf =
    let pos = Lexing.lexeme_start_p lexbuf in
    pos.pos_cnum = pos.pos_bol

  let token_with_comments lexbuf =
    match !preprocessor with
    | None -> token lexbuf
    | Some (_init, preprocess) -> preprocess token lexbuf

  type newline_state =
    | NoLine (* There have been no blank lines yet. *)
    | NewLine
        (* There have been no blank lines, and the previous
           token was a newline. *)
    | BlankLine (* There have been blank lines. *)

  type doc_state =
    | Initial  (* There have been no docstrings yet *)

    | After of docstring list
        (* There have been docstrings, none of which were
           preceeded by a blank line *)
    | Before of docstring list * docstring list * docstring list
        (* There have been docstrings, some of which were
           preceeded by a blank line *)

  and docstring = Docstrings.docstring

  let interpret_directive lexbuf cont look_ahead =
    let if_then_else = !if_then_else in
    begin match token_with_comments lexbuf, if_then_else with
    |  IF, Dir_out  ->
        let rec skip_from_if_false () =
          let token = token_with_comments lexbuf in
          if token = EOF then
            raise (Error (Unterminated_if, Location.curr lexbuf)) else
          if token = SHARP && at_bol lexbuf then
            begin
              let token = token_with_comments lexbuf in
              match token with
              | END ->
                  begin
                    update_if_then_else Dir_out;
                    cont lexbuf
                  end
              | ELSE ->
                  begin
                    update_if_then_else Dir_if_false;
                    cont lexbuf
                  end
              | IF ->
                  raise (Error (Unexpected_directive, Location.curr lexbuf))
              | _ ->
                  if is_elif token &&
                     directive_parse token_with_comments lexbuf then
                    begin
                      update_if_then_else Dir_if_true;
                      cont lexbuf
                    end
                  else skip_from_if_false ()
            end
          else skip_from_if_false () in
        if directive_parse token_with_comments lexbuf then
          begin
            update_if_then_else Dir_if_true (* Next state: ELSE *);
            cont lexbuf
          end
        else
          skip_from_if_false ()
    | IF,  (Dir_if_false | Dir_if_true)->
        raise (Error(Unexpected_directive, Location.curr lexbuf))
    | LIDENT "elif", (Dir_if_false | Dir_out)
      -> (* when the predicate is false, it will continue eating `elif` *)
        raise (Error(Unexpected_directive, Location.curr lexbuf))
    | (LIDENT "elif" | ELSE as token), Dir_if_true ->
        (* looking for #end, however, it can not see #if anymore *)
        let rec skip_from_if_true else_seen =
          let token = token_with_comments lexbuf in
          if token = EOF then
            raise (Error (Unterminated_else, Location.curr lexbuf)) else
          if token = SHARP && at_bol lexbuf then
            begin
              let token = token_with_comments lexbuf in
              match token with
              | END ->
                  begin
                    update_if_then_else Dir_out;
                    cont lexbuf
                  end
              | IF ->
                  raise (Error (Unexpected_directive, Location.curr lexbuf))
              | ELSE ->
                  if else_seen then
                    raise (Error (Unexpected_directive, Location.curr lexbuf))
                  else
                    skip_from_if_true true
              | _ ->
                  if else_seen && is_elif token then
                    raise (Error (Unexpected_directive, Location.curr lexbuf))
                  else
                    skip_from_if_true else_seen
            end
          else skip_from_if_true else_seen in
        skip_from_if_true (token = ELSE)
    | ELSE, Dir_if_false
    | ELSE, Dir_out ->
        raise (Error(Unexpected_directive, Location.curr lexbuf))
    | END, (Dir_if_false | Dir_if_true ) ->
        update_if_then_else  Dir_out;
        cont lexbuf
    | END,  Dir_out  ->
        raise (Error(Unexpected_directive, Location.curr lexbuf))
    | token, (Dir_if_true | Dir_if_false | Dir_out) ->
        look_ahead token
    end

  let token lexbuf =
    let post_pos = lexeme_end_p lexbuf in

    let attach lines docs pre_pos =
      let open Docstrings in
        match docs, lines with
        | Initial, _ -> ()
        | After a, (NoLine | NewLine) ->
            set_post_docstrings post_pos (List.rev a);
            set_pre_docstrings pre_pos a;
        | After a, BlankLine ->
            set_post_docstrings post_pos (List.rev a);
            set_pre_extra_docstrings pre_pos (List.rev a)
        | Before(a, f, b), (NoLine | NewLine) ->
            set_post_docstrings post_pos (List.rev a);
            set_post_extra_docstrings post_pos
              (List.rev_append f (List.rev b));
            set_floating_docstrings pre_pos (List.rev f);
            set_pre_extra_docstrings pre_pos (List.rev a);
            set_pre_docstrings pre_pos b
        | Before(a, f, b), BlankLine ->
            set_post_docstrings post_pos (List.rev a);
            set_post_extra_docstrings post_pos
              (List.rev_append f (List.rev b));
            set_floating_docstrings pre_pos
              (List.rev_append f (List.rev b));
            set_pre_extra_docstrings pre_pos (List.rev a)
    in

    let rec loop lines docs lexbuf : Parser.token =
      match token_with_comments lexbuf with
      | COMMENT (s, loc) ->
          add_comment (s, loc);
          let lines' =
            match lines with
            | NoLine -> NoLine
            | NewLine -> NoLine
            | BlankLine -> BlankLine
          in
          loop lines' docs lexbuf
      | EOL ->
          let lines' =
            match lines with
            | NoLine -> NewLine
            | NewLine -> BlankLine
            | BlankLine -> BlankLine
          in
          loop lines' docs lexbuf
      | SHARP when at_bol lexbuf ->
          interpret_directive lexbuf
            (fun lexbuf -> loop lines docs lexbuf)
            (fun token -> sharp_look_ahead := Some token; SHARP)

      | DOCSTRING doc ->
          add_docstring_comment doc;
          let docs' =
            match docs, lines with
            | Initial, (NoLine | NewLine) -> After [doc]
            | Initial, BlankLine -> Before([], [], [doc])
            | After a, (NoLine | NewLine) -> After (doc :: a)
            | After a, BlankLine -> Before (a, [], [doc])
            | Before(a, f, b), (NoLine | NewLine) -> Before(a, f, doc :: b)
            | Before(a, f, b), BlankLine -> Before(a, b @ f, [doc])
          in
          loop NoLine docs' lexbuf

      | tok ->

          attach lines docs (lexeme_start_p lexbuf);

          tok


    in
      match !sharp_look_ahead with
      | None ->
           loop NoLine Initial lexbuf
      | Some token ->
           sharp_look_ahead := None ;
           token

  let init () =
    sharp_look_ahead := None;
    update_if_then_else  Dir_out;
    is_in_string := false;
    comment_start_loc := [];
    comment_list := [];
    match !preprocessor with
    | None -> ()
    | Some (init, _preprocess) -> init ()

  let rec filter_directive pos   acc lexbuf : (int * int ) list =
    match token_with_comments lexbuf with
    | SHARP when at_bol lexbuf ->
        (* ^[start_pos]#if ... #then^[end_pos] *)
        let start_pos = Lexing.lexeme_start lexbuf in
        interpret_directive lexbuf
          (fun lexbuf ->
             filter_directive
               (Lexing.lexeme_end lexbuf)
               ((pos, start_pos) :: acc)
               lexbuf

          )
          (fun _token -> filter_directive pos acc lexbuf  )
    | EOF -> (pos, Lexing.lexeme_end lexbuf) :: acc
    | _ -> filter_directive pos  acc lexbuf

  let filter_directive_from_lexbuf lexbuf =
    List.rev (filter_directive 0 [] lexbuf )

  let set_preprocessor init preprocess =
    escaped_newlines := true;
    preprocessor := Some (init, preprocess)


# 3038 "parsing/lexer.ml"

end
module Parse : sig
#1 "parse.mli"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Entry points in the parser *)

val implementation : Lexing.lexbuf -> Parsetree.structure
val interface : Lexing.lexbuf -> Parsetree.signature
val toplevel_phrase : Lexing.lexbuf -> Parsetree.toplevel_phrase
val use_file : Lexing.lexbuf -> Parsetree.toplevel_phrase list
val core_type : Lexing.lexbuf -> Parsetree.core_type
val expression : Lexing.lexbuf -> Parsetree.expression
val pattern : Lexing.lexbuf -> Parsetree.pattern

end = struct
#1 "parse.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0.               *)
(*                                                                     *)
(***********************************************************************)

(* Entry points in the parser *)

(* Skip tokens to the end of the phrase *)

let rec skip_phrase lexbuf =
  try
    match Lexer.token lexbuf with
      Parser.SEMISEMI | Parser.EOF -> ()
    | _ -> skip_phrase lexbuf
  with
    | Lexer.Error (Lexer.Unterminated_comment _, _)
    | Lexer.Error (Lexer.Unterminated_string, _)
    | Lexer.Error (Lexer.Unterminated_string_in_comment _, _)
    | Lexer.Error (Lexer.Illegal_character _, _) -> skip_phrase lexbuf
;;

let maybe_skip_phrase lexbuf =
  if Parsing.is_current_lookahead Parser.SEMISEMI
  || Parsing.is_current_lookahead Parser.EOF
  then ()
  else skip_phrase lexbuf

let wrap parsing_fun lexbuf =
  try
    Docstrings.init ();
    Lexer.init ();
    let ast = parsing_fun Lexer.token lexbuf in
    Parsing.clear_parser();
    Docstrings.warn_bad_docstrings ();
    ast
  with
  | Lexer.Error(Lexer.Illegal_character _, _) as err
    when !Location.input_name = "//toplevel//"->
      skip_phrase lexbuf;
      raise err
  | Syntaxerr.Error _ as err
    when !Location.input_name = "//toplevel//" ->
      maybe_skip_phrase lexbuf;
      raise err
  | Parsing.Parse_error | Syntaxerr.Escape_error ->
      let loc = Location.curr lexbuf in
      if !Location.input_name = "//toplevel//"
      then maybe_skip_phrase lexbuf;
      raise(Syntaxerr.Error(Syntaxerr.Other loc))

let implementation = wrap Parser.implementation
and interface = wrap Parser.interface
and toplevel_phrase = wrap Parser.toplevel_phrase
and use_file = wrap Parser.use_file
and core_type = wrap Parser.parse_core_type
and expression = wrap Parser.parse_expression
and pattern = wrap Parser.parse_pattern

end
#1 "parser_api_main_bspack.ml"



let from_string : string -> Lexing.lexbuf = Lexing.from_string
let implementation : Lexing.lexbuf -> Parsetree.structure =
    Parse.implementation
