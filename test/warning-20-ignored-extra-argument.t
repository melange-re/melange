Test showing "ignored extra argument" warning

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"

  $ cat > main.ml <<EOF
  > type t
  > external clipboardData : t -> < .. > Js.t = "clipboardData" [@@bs.get]
  > let from_event evt = (clipboardData evt)##getData "text"
  > EOF

  $ melc main.ml -o main.cmj
