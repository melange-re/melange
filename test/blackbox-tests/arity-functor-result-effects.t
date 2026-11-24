Functor result metadata must preserve curried effects and exceptions, and must
not assume an arity for functions forwarded from the functor argument. Disable
cross-module inlining so the calls use the exported metadata.

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
  $ cat > provider.ml <<'EOF'
  > exception Stop
  > module type S = sig val f : int -> int -> int end
  > module Make (X : S) = struct
  >   let effects = ref 0
  >   let staged x =
  >     incr effects;
  >     if x < 0 then raise Stop;
  >     fun y -> incr effects; x + y
  >   let forwarded = X.f
  >   module Nested = struct
  >     let forwarded = X.f
  >   end
  >   let effect_count () = !effects
  > end
  > EOF
  $ cat > input.ml <<'EOF'
  > let calls = ref 0
  > module Curried = Provider.Make (struct
  >   let f x = incr calls; fun y -> x + y
  > end)
  > module Binary = Provider.Make (struct
  >   let f x y = x - y
  > end)
  > let pending = Curried.staged 40
  > let before = Curried.effect_count ()
  > let value = pending 2
  > let after = Curried.effect_count ()
  > let forwarded = Curried.forwarded 40 2
  > let nested = Curried.Nested.forwarded 40 2
  > let binary = Binary.forwarded 40 2
  > let exception_now =
  >   match (try Some (Curried.staged (-1)) with Provider.Stop -> None) with
  >   | None -> true
  >   | Some _ -> false
  > let result =
  >   before, value, after, forwarded, nested, binary, !calls,
  >   exception_now, Curried.effect_count ()
  > EOF
  $ dune build @melange
  $ node --input-type=module <<'EOF'
  > for (const ext of ['js', 'mjs']) {
  >   const t = await import('./_build/default/out/input.' + ext);
  >   console.log(ext, JSON.stringify(t.result));
  > }
  > EOF
  js [1,42,2,42,42,38,2,true,3]
  mjs [1,42,2,42,42,38,2,true,3]
