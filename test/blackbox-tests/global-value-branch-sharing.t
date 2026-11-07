A null/undefined/string match from melange-re/melange#2087.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.20)
  > (using melange 1.0)
  > EOF
  $ echo '(melange.emit (target out) (emit_stdlib false) (preprocess (pps melange.ppx)))' > dune
  $ cat > input.ml <<'EOF'
  > external undefined : Js.Json.t = "undefined"
  > let[@inline never] convert = function
  >   | `Null -> Js.Json.null
  >   | `Undefined -> undefined
  >   | `String value -> Js.Json.string value
  > let () =
  >   Js.log (convert `Null);
  >   Js.log (convert `Undefined);
  >   Js.log (convert (`String "hello"))
  > EOF
  $ dune build --disable-promotion @melange
  $ node _build/default/out/input.js
  null
  undefined
  hello
