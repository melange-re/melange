A functor must capture initialized fields from a recursive module, even when
the captured function refers back to the functor result. The second function
in A is needed to trigger lifting of the module's local bindings.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (compile_flags :standard --mel-no-cross-module-opt)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > capture.ml <<'EOF'
  > module type S = sig
  >   val f : int -> int
  >   val identity : int -> int
  > end
  > module Make (X : S) = struct
  >   let empty = 0
  >   let f = X.f
  > end
  > EOF
  $ cat > input.ml <<'EOF'
  > module rec A : Capture.S = struct
  >   let f n = if n = 0 then 42 else B.f (n - 1)
  >   let identity x = x
  > end
  > and B : sig
  >   val empty : int
  >   val f : int -> int
  > end = Capture.Make(A)
  > let () = assert (B.f 1 = 42)
  > EOF
  $ dune build @melange
  $ node _build/default/out/input.js
  $ node _build/default/out/input.mjs
