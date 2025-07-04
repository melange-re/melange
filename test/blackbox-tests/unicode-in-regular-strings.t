Showcase usage of escaped and literal unicode text in regular strings

  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel))
  > EOF

Using UTF-8 encoded Unicode text is not compatible with OCaml

  $ cat > x.ml <<EOF
  > let s = "\u{1F42B}"
  > let () = print_endline s
  > EOF

  $ ocaml x.ml
  🐫

  $ dune build @mel
  $ cat _build/default/output/x.js
  // Generated by Melange
  'use strict';
  
  
  const s = "\xf0\x9f\x90\xab";
  
  console.log(s);
  
  module.exports = {
    s,
  }
  /*  Not a pure module */
  $ node _build/default/output/x.js
  ð«

Using emojis in text is not compatible with OCaml

  $ cat > x.ml <<EOF
  > let s = "🐫"
  > let () = print_endline s
  > EOF

  $ ocaml x.ml
  🐫

  $ dune build @mel
  $ cat _build/default/output/x.js
  // Generated by Melange
  'use strict';
  
  
  const s = "\xf0\x9f\x90\xab";
  
  console.log(s);
  
  module.exports = {
    s,
  }
  /*  Not a pure module */
  $ node _build/default/output/x.js
  ð«

Locations are broken when using emojis (this is also the case in OCaml)

  $ cat > x.ml <<EOF
  > let q = "💩💩💩💩💩💩💩💩💩💩" ^ ("a" ^ 3 ^ "b")
  > EOF

  $ ocaml -color never x.ml
  File "./x.ml", line 1, characters 60-61:
  1 | let q = "💩💩💩💩💩💩💩💩💩💩" ^ ("a" ^ 3 ^ "b")
                                                                  ^
  Error: The constant 3 has type int but an expression was expected of type
           string
  [2]

  $ dune build @mel
  File "x.ml", line 1, characters 60-61:
  1 | let q = "💩💩💩💩💩💩💩💩💩💩" ^ ("a" ^ 3 ^ "b")
                                                                  ^
  Error: The constant 3 has type int but an expression was expected of type
           string
  [1]

Exercise matching over unicode strings

  $ cat > x.ml <<EOF
  > let y = "\xf0\x9f\x90\xab"
  > 
  > let t = match y with | "\xf0\x9f\x90\xab" -> "true" | _ -> "false"
  > 
  > let () = print_endline t
  > let u = match y with | "🐫" -> "true" | _ -> "false"
  > 
  > let () = print_endline u
  > let z = "🐫"
  > 
  > let t = match z with | "\xf0\x9f\x90\xab" -> "true" | _ -> "false"
  > 
  > let () = print_endline t
  > let u = match z with | "🐫" -> "true" | _ -> "false"
  > 
  > let () = print_endline u
  > EOF

  $ dune build @mel
  $ cat _build/default/output/x.js
  // Generated by Melange
  'use strict';
  
  
  console.log("true");
  
  console.log("true");
  
  const t = "true";
  
  console.log(t);
  
  const u = "true";
  
  console.log(u);
  
  const y = "\xf0\x9f\x90\xab";
  
  const z = "\xf0\x9f\x90\xab";
  
  module.exports = {
    y,
    z,
    t,
    u,
  }
  /*  Not a pure module */

  $ node _build/default/output/x.js
  true
  true
  true
  true

Matching over bytes read from a binary stream works like in OCaml.
This and the tests below show the main reason why `j` and `js` quoted strings
exist, and using unicode literals like emojis in regular strings does not
produce the expected result in the generated JavaScript code

  $ cat > x.ml <<EOF
  > let bytes =
  >   Bytes.init 4 (function
  >     | 0 -> '\xf0'
  >     | 1 -> '\x9f'
  >     | 2 -> '\x90'
  >     | 3 -> '\xab'
  >     (* Should never happen since the length is 4 *)
  >     | _ -> assert false)
  > 
  > let () =
  >   Format.eprintf "%B@."
  >     (match Bytes.to_string bytes with "\xf0\x9f\x90\xab" -> true | _ -> false)
  > EOF

  $ ocaml x.ml
  true

  $ dune build @mel
  $ node _build/default/output/x.js
  true

Check the length of the string

  $ cat > x.ml <<EOF
  > let camel = "🐫"
  > 
  > let () =
  >   let length = String.length camel in
  >   Printf.printf "Length of the string in bytes: %d\n" length
  > EOF

  $ ocaml x.ml
  Length of the string in bytes: 4

  $ dune build @mel
  $ node _build/default/output/x.js
  Length of the string in bytes: 4

Index into the string at the byte level

  $ cat > x.ml <<EOF
  > let camel = "🐫"
  > 
  > let print_bytes s =
  >   for i = 0 to String.length s - 1 do
  >     Printf.printf "Byte %d: 0x%X\n" i (Char.code (String.get s i))
  >   done
  > 
  > let () = print_bytes camel
  > EOF

  $ ocaml x.ml
  Byte 0: 0xF0
  Byte 1: 0x9F
  Byte 2: 0x90
  Byte 3: 0xAB

  $ dune build @mel
  $ node _build/default/output/x.js
  Byte 0: 0xF0
  Byte 1: 0x9F
  Byte 2: 0x90
  Byte 3: 0xAB
