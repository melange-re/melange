`melange.effect_boundary` provides a separate suspension protocol library.

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (libraries melange.effect_boundary))
  > EOF
  $ cat > x.ml <<EOF
  > let synchronous =
  >   Effect_boundary.bind (Effect_boundary.return 40) (fun x ->
  >       Effect_boundary.return (x + 2))
  > 
  > let suspended =
  >   Effect_boundary.bind
  >     (Effect_boundary.suspend (fun resume -> resume 10))
  >     (fun x -> Effect_boundary.return (x + 1))
  > 
  > let () =
  >   Effect_boundary.run_with synchronous (fun x -> Js.log2 "sync" x);
  >   Effect_boundary.run_with suspended (fun x -> Js.log2 "suspend" x)
  > EOF
  $ dune build @melange
  $ node _build/default/out/x.js
  sync 42
  suspend 11
