A qualified external referring to module-local JavaScript must not be relocated
into another module, even when hidden behind an interface.

  $ . ./setup.sh

  $ cat > dune-project <<'EOF'
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target dist)
  >  (emit_stdlib false)
  >  (compile_flags :standard --mel-cross-module-opt)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > provider.ml <<'EOF'
  > [%%mel.raw {|const Helpers = {run: x => x + 1};|}]
  > external local : int -> int = "Helpers.run"
  > let run x = local x
  > EOF

  $ cat > provider.mli <<'EOF'
  > val run : int -> int
  > EOF

  $ cat > caller.ml <<'EOF'
  > let run x = Provider.run x
  > EOF

  $ cat > check.cjs <<'EOF'
  > console.log(require("./_build/default/dist/provider.js").run(41));
  > try {
  >   console.log(require("./_build/default/dist/caller.js").run(41));
  > } catch (error) {
  >   console.error(error.toString());
  >   process.exitCode = 1;
  > }
  > EOF

Both calls should return 42. Currently, Helpers.run is relocated into the caller,
where the provider's module-local binding Helpers is not available.

  $ dune build @melange
  $ node check.cjs
  42
  ReferenceError: Helpers is not defined
  [1]
