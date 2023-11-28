
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > external err :
  >   hi_should_error:([\`a of int | \`b of string ] [@mel.string]) ->
  >   unit -> _ = "" [@@mel.obj]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 2-3, characters 2-11:
  2 | ..hi_should_error:([`a of int | `b of string ] [@mel.string]) ->
  3 |   unit -> _.................
  Error: `@mel.obj' must not be used with labelled polymorphic variants
         carrying payloads
  [2]

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b of string ] [@mel.string]) ->
  >   unit -> _ = "" [@@mel.obj]
  > EOF
  $ melc -ppx melppx -alert -unprocessed x.ml
  File "x.ml", lines 2-3, characters 2-11:
  2 | ..?hi_should_error:([`a of int | `b of string ] [@mel.string]) ->
  3 |   unit -> _.................
  Error: `@mel.obj' must not be used with optionally labelled polymorphic
         variants carrying payloads
  [2]

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b of string ] [@mel.string]) ->
  >   unit -> unit = "err"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 20-47:
  2 |   ?hi_should_error:([`a of int | `b of string ] [@mel.string]) ->
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: `[@mel.as ..]' must not be used with an optionally labelled
         polymorphic variant
  [2]

Each [@mel.unwrap] variant constructor requires an argument

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b] [@mel.unwrap]) ->
  >   unit -> unit = "err"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 2, characters 20-36:
  2 |   ?hi_should_error:([`a of int | `b] [@mel.unwrap]) ->
                          ^^^^^^^^^^^^^^^^
  Error: Invalid type for `@mel.unwrap'. Type must be an inline variant
         (closed), and each constructor must have an argument.
  [2]

