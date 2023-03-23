
  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > external err :
  >   hi_should_error:([\`a of int | \`b of string ] [@bs.string]) ->
  >   unit -> _ = "" [@@bs.obj]
  > EOF
  $ melc x.ml
  File "x.ml", lines 2-3, characters 2-11:
  2 | ..hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
  3 |   unit -> _................
  Error: @obj label hi_should_error does not support such arg type
  [2]

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b of string ] [@bs.string]) ->
  >   unit -> _ = "" [@@bs.obj]
  > EOF
  $ melc x.ml
  File "x.ml", lines 2-3, characters 2-11:
  2 | ..?hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
  3 |   unit -> _................
  Error: @obj label hi_should_error does not support such arg type
  [2]

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b of string ] [@bs.string]) ->
  >   unit -> unit = "err" [@@bs.val]
  > EOF
  $ melc x.ml
  File "x.ml", lines 1-3, characters 0-33:
  1 | external err :
  2 |   ?hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
  3 |   unit -> unit = "err" [@@bs.val]
  Error: @string does not work with optional when it has arities in label hi_should_error
  [2]

Each [@bs.unwrap] variant constructor requires an argument

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int | \`b] [@bs.unwrap]) ->
  >   unit -> unit = "err" [@@bs.val]
  > EOF
  $ melc x.ml
  File "x.ml", line 2, characters 20-36:
  2 |   ?hi_should_error:([`a of int | `b] [@bs.unwrap]) ->
                          ^^^^^^^^^^^^^^^^
  Error: Not a valid type for %@unwrap. Type must be an inline variant (closed), and
  each constructor must have an argument.
  [2]

[@bs.unwrap] args are not supported in [@@bs.obj] functions

  $ cat > x.ml <<EOF
  > external err :
  >   ?hi_should_error:([\`a of int] [@bs.unwrap]) -> unit -> _ = "" [@@bs.obj]
  > EOF
  $ melc x.ml
  File "x.ml", line 2, characters 2-58:
  2 |   ?hi_should_error:([`a of int] [@bs.unwrap]) -> unit -> _ = "" [@@bs.obj]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: @obj label hi_should_error does not support @unwrap arguments
  [2]

