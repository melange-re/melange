
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
  Error: @obj label hi_should_error does not support such arg type
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
  Error: @obj label hi_should_error does not support such arg type
  [2]

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b of string ] [@mel.string]) ->
  >   unit -> unit = "err"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", lines 1-3, characters 0-22:
  1 | external err :
  2 |   ?hi_should_error:([`a of int | `b of string ] [@mel.string]) ->
  3 |   unit -> unit = "err"
  Error: @mel.string does not work with optional when it has arities in label
         hi_should_error
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

