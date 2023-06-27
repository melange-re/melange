
  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > x.ml <<EOF
  > external mk : int -> ([ \`a | \`b ][@bs.string]) = "" [@@bs.val]
  > EOF

Alerts enabled

  $ dune build @melange
  File "x.ml", line 1, characters 0-62:
  1 | external mk : int -> ([ `a | `b ][@bs.string]) = "" [@@bs.val]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Alert fragile: mk : the external name is inferred from val name is unsafe from refactoring when changing value name
  File "x.ml", line 1, characters 35-44:
  1 | external mk : int -> ([ `a | `b ][@bs.string]) = "" [@@bs.val]
                                         ^^^^^^^^^
  Alert unused: Unused attribute [@bs.string]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
  

Disabling alerts with `-alert -[ALERT_NAME]`

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (preprocess (pps melange.ppx -alert -unused -alert -fragile)))
  > EOF

  $ dune build @melange

