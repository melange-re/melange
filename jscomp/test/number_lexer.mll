{
external log : string -> unit = "console.log"
let l = log

}

rule  token l = parse
    [' ' '\t' '\r' '\n']  { l "new line" ; token l lexbuf}
  | ['0'-'9']+  { l "number"; l (Lexing.lexeme lexbuf); token l lexbuf }
  | ['a'-'z''A'-'Z']+ {l "ident"; l (Lexing.lexeme lexbuf); token l lexbuf}
  | '+'         { l "+" ; token l lexbuf }
  | '-'         { l "-" ; token l lexbuf}
  | '*'         { l "*" ; token l lexbuf}
  | '/'         { l "/" ; token l lexbuf}
  | '('         { l "(" ; token l lexbuf }
  | ')'         { l ")"; token l lexbuf }
  | eof         { l "eof" }

{
(* token l (Lexing.from_string "32 + 32 ( ) * / ") *)
(* token (Lexing.from_string "32") *)
}

(* local variables: *)
(* compile-command: "ocamlbuild number_lexer.byte --" *)
(* end: *)
