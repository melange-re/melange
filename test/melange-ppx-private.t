Test to showcase errors when using %%private extensions with melange ppx

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.7)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target output)
  >  (alias mel)
  >  (emit_stdlib false)
  >  ;(preprocess (pps melange.ppx))
  > )
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
  File "main.ml", line 6, characters 4-27:
  6 |     Webapi.Dom.MouseEvent.t -> Webapi.Dom.Event.t = "%identity"]
          ^^^^^^^^^^^^^^^^^^^^^^^
  Error: Unbound module Webapi
  [1]
