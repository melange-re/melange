Test showing unused record fields error with bs.deriving

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"

  $ cat > main.ml <<EOF
  > type t
  > external clipboardData : t -> < .. > Js.t = "clipboardData" [@@bs.get]
  > let from_event evt = (clipboardData evt)##getData "text"
  > EOF

  $ melc main.ml -o main.cmj
  File "main.ml", line 3, characters 50-56:
  3 | let from_event evt = (clipboardData evt)##getData "text"
                                                        ^^^^^^
  Warning 20 [ignored-extra-argument]: this argument will not be used by the function.
