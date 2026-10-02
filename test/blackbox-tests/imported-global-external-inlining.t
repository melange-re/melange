A JavaScript module import generated for an external must not capture a global
used by a relocated call from another OCaml module.

  $ . ./setup.sh

  $ cat > dune-project <<'EOF'
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target dist)
  >  (emit_stdlib false)
  >  (compile_flags (:include flags.sexp))
  >  (preprocess (pps melange.ppx))
  >  (runtime_deps local.cjs))
  > EOF

  $ echo '(:standard)' > flags.sexp

  $ cat > provider.ml <<'EOF'
  > external global_run : int -> int = "run" [@@mel.scope "Local"]
  > let run x = global_run x
  > EOF

  $ cat > caller.ml <<'EOF'
  > external touch : unit -> unit = "touch" [@@mel.module ("./local.cjs", "Local")]
  > let run x = touch (); Provider.run x
  > EOF

  $ cat > local.cjs <<'EOF'
  > exports.touch = () => {};
  > exports.run = () => 999;
  > EOF

  $ cat > check.cjs <<'EOF'
  > globalThis.Local = {run: x => x + 1};
  > console.log(require("./_build/default/dist/provider.js").run(41));
  > console.log(require("./_build/default/dist/caller.js").run(41));
  > EOF

Both calls should return 42. Currently, the generated Local import in the caller
captures the provider's global reference, returning 999 instead.

  $ dune build @melange
  $ node check.cjs
  42
  999

The same incorrect result occurs with cross-module function inlining enabled.

  $ echo '(:standard --mel-cross-module-opt)' > flags.sexp
  $ dune build @melange
  $ node check.cjs
  42
  999
