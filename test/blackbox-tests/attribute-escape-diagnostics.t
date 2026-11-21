Malformed attribute strings must retain their source locations in diagnostics.

  $ . ./setup.sh
  $ cat > field.ml <<'EOF'
  > type t = { x : int [@mel.as "\u{110000}"] }
  > EOF
  $ melc --color=never -ppx melppx -c field.ml
  melc: System error: Illegal backslash escape in string or character
        (\u{110000}): 110000 is not a Unicode scalar value
  [124]
  $ cat > module.mli <<'EOF'
  > external value : int = "value" [@@mel.module "\u{110000}"]
  > EOF
  $ melc --color=never -ppx melppx -c module.mli
  melc: System error: Illegal backslash escape in string or character
        (\u{110000}): 110000 is not a Unicode scalar value
  [124]
  $ cat > variant.ml <<'EOF'
  > type t = A [@mel.as "\999"]
  > EOF
  $ melc --color=never -ppx melppx -c variant.ml
  melc: System error: Illegal backslash escape in string or character (\999):
        999 is outside the range of legal characters (0-255).
  [124]
  $ cat > plain.ml <<'EOF'
  > let s = "\u{110000}"
  > EOF
  $ melc --color=never -ppx melppx -c plain.ml
  melc: System error: Illegal backslash escape in string or character
        (\u{110000}): 110000 is not a Unicode scalar value
  [124]
  $ cat > valid.ml <<'EOF'
  > type t = { x : int [@mel.as "\u{0041}"] }
  > type quoted = { x : int [@mel.as {|\xZZ|}] }
  > let get (r : t) = r.x
  > let get_quoted (r : quoted) = r.x
  > EOF
  $ melc --color=never -ppx melppx -o valid.js valid.ml
  $ node -e 'const t = require("./valid.js"); console.log(t.get({A: 7}), t.get_quoted({"\\xZZ": 8}));'
  7 8
