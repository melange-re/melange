A functor can capture a recursive module's function during initialization.
The module must have its fields before the functor reads them, even when
the captured function refers back to the functor result.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (compile_flags :standard --mel-no-cross-module-opt)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > capture.ml <<'EOF'
  > module type S = sig
  >   type t
  >   val compare : t -> t -> int
  >   val identity : int -> int
  > end
  > module Make (X : S) = struct
  >   type t = X.t
  >   let empty = 0
  >   let compare = X.compare
  > end
  > EOF
  $ cat > input.ml <<'EOF'
  > module rec A : sig
  >   type t = Leaf of string | Node of ASet.t
  >   val compare : t -> t -> int
  >   val identity : int -> int
  > end = struct
  >   type t = Leaf of string | Node of ASet.t
  >   let compare x y =
  >     match x, y with
  >     | Leaf _, Leaf _ -> 42
  >     | Node a, Node b -> ASet.compare a b
  >     | _ -> 0
  >   let identity x = x
  > end
  > and ASet : sig
  >   type t = A.t
  >   val empty : int
  >   val compare : t -> t -> int
  > end = Capture.Make(A)
  > let result = ASet.compare (A.Leaf "a") (A.Leaf "b")
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > for (const ext of ['js', 'mjs']) {
  >   try {
  >     const t = await import('./_build/default/out/input.' + ext);
  >     console.log(ext, t.result);
  >   } catch (e) {
  >     console.log(ext, e.name, e.message);
  >   }
  > }
  > EOF
  js 42
  mjs 42
