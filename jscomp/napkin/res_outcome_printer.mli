(* For the curious: the outcome printer is a printer to print data
 * from the outcometree.mli file in the ocaml compiler.
 * The outcome tree is used by:
 *  - ocaml's toplevel/repl, print results/errors
 *  - super errors, print nice errors
 *  - editor tooling, e.g. show type on hover
 *
 * In general it represent messages to show results or errors to the user. *)

val parenthesized_ident : string -> bool [@@live]

val setup : unit lazy_t [@@live]
