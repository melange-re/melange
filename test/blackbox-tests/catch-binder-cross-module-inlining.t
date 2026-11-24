Exception handler binders currently prevent closed functions from being exported
for cross-module inlining. A genuinely captured module variable must still keep
its function out of the inline exports.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.13)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange)
  >  (compile_flags :standard --mel-cross-module-opt)
  >  (module_systems (commonjs js) (es6 mjs)))
  > EOF
  $ cat > provider.ml <<'EOF'
  > let[@inline always] closed f = try f () with exn -> exn
  > let[@inline always] nested f g =
  >   try f () with outer -> try g outer with inner -> inner
  > let shared = ref 0
  > let[@inline always] captured f =
  >   try f () with exn -> incr shared; exn
  > EOF
  $ cat > main.ml <<'EOF'
  > let closed f x = Provider.closed (fun () -> f x)
  > let nested f g x = Provider.nested (fun () -> f x) g
  > let captured f x = Provider.captured (fun () -> f x)
  > EOF
  $ cat > checks.ml <<'EOF'
  > exception E of int
  > let () =
  >   let outer = E 1 and inner = E 2 in
  >   let calls = ref 0 in
  >   let returns x = incr calls; x in
  >   let throws x = incr calls; raise x in
  >   assert (Main.closed returns outer == outer);
  >   assert (Main.closed throws outer == outer);
  >   assert (!calls = 2);
  >   assert (Main.nested returns (fun _ -> assert false) outer == outer);
  >   assert (Main.nested throws (fun x -> assert (x == outer); inner) outer == inner);
  >   assert (Main.nested throws (fun x -> assert (x == outer); throws inner) outer == inner);
  >   assert (!calls = 6);
  >   assert (Main.captured returns inner == inner);
  >   assert (!(Provider.shared) = 0);
  >   assert (Main.captured throws outer == outer);
  >   assert (!(Provider.shared) = 1);
  >   assert (Main.captured throws inner == inner);
  >   assert (!(Provider.shared) = 2);
  >   assert (!calls = 9)
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const code = require('node:fs').readFileSync('_build/default/out/main.js', 'utf8');
  > const calls = code.match(/Melange__Provider\.\w+/g) || [];
  > console.log([...new Set(calls)].sort().join(', '));
  > EOF
  Melange__Provider.captured, Melange__Provider.closed, Melange__Provider.nested
  $ node _build/default/out/checks.js
  $ node _build/default/out/checks.mjs
