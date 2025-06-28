Test to showcase errors when using %%private extensions with melange ppx

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > main.ml <<EOF
  > (**
  >   Hey
  > *)
  > [%%private
  >   external fromMouseEvent :
  >     Webapi.Dom.MouseEvent.t -> Webapi.Dom.Event.t = "%identity"]
  > EOF
  $ dune build @mel
  File "main.ml", lines 1-3, characters 0-2:
  Error: Attributes not allowed here
  [1]
