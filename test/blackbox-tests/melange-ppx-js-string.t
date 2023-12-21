Demonstrate some strange transformation on js quoted strings.

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let str = {js|Hello|js};
  > EOF

The `js` quoted strings are transformed into a `*j` internal delimiter

  $ melc -ppx melppx -dsource -mel-syntax-only x.ml
  let str = {*j|Hello|*j}

This transformation is not done by the PPX, as it can be seen without applying
`-ppx melppx`

  $ melc -dsource -mel-syntax-only x.ml
  let str = {*j|Hello|*j}
