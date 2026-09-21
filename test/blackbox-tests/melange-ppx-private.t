Test to showcase errors when using %%private extensions with melange ppx

  $ . ./setup.sh
  $ cat > main.ml <<EOF
  > (**
  >   Hey
  > *)
  > [%%private
  >   external fromMouseEvent :
  >     Webapi.Dom.MouseEvent.t -> Webapi.Dom.Event.t = "%identity"]
  > EOF
  $ melc -ppx melppx main.ml
  File "main.ml", lines 1-3, characters 0-2:
  1 | (**
  2 |   Hey
  3 | *)
  Error: Attributes not allowed here
  [2]

An empty private extension is accepted.

  $ cat > empty.ml <<EOF
  > [%%private]
  > EOF
  $ melc -w -32 --mel-stop-after-cmj \
  >   -ppx 'melppx -locations-check' empty.ml

The generated module spans every item in the private extension.

  $ cat > multiple.ml <<EOF
  > [%%private
  >   let first = 1
  >   let second = 2]
  > EOF
  $ melc -w -32 --mel-stop-after-cmj \
  >   -ppx 'melppx -locations-check' multiple.ml
