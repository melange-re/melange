
  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx)))
  > EOF

  $ cat > x.ml <<EOF
  > external mk : int -> ([ \`a | \`b ][@mel.string]) = ""
  > EOF

Alerts enabled

  $ dune build @melange 2>&1 | grep Alert
  Alert fragile: mk : the external name is inferred from val name is unsafe from refactoring when changing value name
  Alert unused: Unused attribute [@mel.string]


Disabling alerts with `-alert -[ALERT_NAME]`

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (preprocess (pps melange.ppx -alert -unused -alert -fragile)))
  > EOF

  $ dune build @melange

