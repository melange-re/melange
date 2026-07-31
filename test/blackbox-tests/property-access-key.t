Out-of-range integer-like property names are accessed as strings

The key is `min_int` with a trailing zero on 64-bit hosts.

  $ . ./setup.sh
  $ cat > x.ml <<'EOF'
  > type t
  > external get : t -> int = "-46116860184273879040" [@@mel.get]
  > let get_property x = get x
  > EOF
  $ melc -ppx melppx x.ml -o x.js
  $ node <<'EOF'
  > const { get_property } = require("./x.js");
  > const key = "-46116860184273879040";
  > console.log(get_property({ [key]: 42 }));
  > EOF
  42
