Test the interaction between `[@@mel.new]` and `[@@mel.send]`

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > type blue
  > type red
  > external blue : blue = "path/to/blue.js" [@@mel.module]
  > external red : blue -> string -> red = "Red" [@@mel.send] [@@mel.new]
  > let _ = red blue "foo"
  > EOF
  $ melc -ppx melppx x.ml
  File "x.ml", line 4, characters 0-69:
  4 | external red : blue -> string -> red = "Red" [@@mel.send] [@@mel.new]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Error: You used a FFI attribute that can't be used with @send
  [2]

