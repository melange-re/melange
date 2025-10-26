
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > external mk : int -> ([ \`a | \`b ][@mel.string]) = ""
  > EOF

Alerts enabled

  $ melc -ppx melppx x.ml 2>&1 | grep Alert
  Alert fragile: mk : the external name is inferred from val name is unsafe from refactoring when changing value name
  Alert unused: Unused attribute [@mel.string]


Disabling alerts with `-alert -[ALERT_NAME]`

  $ melc -ppx 'melppx -alert -unused -alert -fragile' x.ml > x.js

