Partially applying an uninitialized recursive-module function must raise before
the module is updated, including functions in nested modules.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (module_systems (commonjs js) (esm mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let partial_before_init () =
  >   try
  >     let module R = struct
  >       module rec M : sig
  >         val f : int -> int -> int
  >         val g : int -> int
  >       end = struct
  >         let g = M.f 1
  >         let f x y = x + y
  >       end
  >     end in
  >     ignore (R.M.g 41);
  >     false
  >   with Undefined_recursive_module _ -> true
  > let nested_before_init () =
  >   try
  >     let module R = struct
  >       module rec M : sig
  >         module N : sig val f : int -> int -> int end
  >         val g : int -> int
  >       end = struct
  >         let g = M.N.f 1
  >         module N = struct let f x y = x + y end
  >       end
  >     end in
  >     ignore (R.M.g 41);
  >     false
  >   with Undefined_recursive_module _ -> true
  > let initialized () =
  >   let module R = struct
  >     module rec M : sig
  >       module N : sig val f : int -> int -> int end
  >       val g : int -> int
  >     end = struct
  >       module N = struct let f x y = x + y end
  >       let g x = M.N.f x 2
  >     end
  >   end in
  >   let f = R.M.N.f 40 in
  >   f 2 + R.M.g 40
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > for (const ext of ['js', 'mjs']) {
  >   const t = await import('./_build/default/out/input.' + ext);
  >   console.log(ext, t.partial_before_init(), t.nested_before_init(), t.initialized());
  > }
  > EOF
  js true true 84
  mjs true true 84
