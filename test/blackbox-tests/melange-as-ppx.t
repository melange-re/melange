Demonstrate how to use the `melc -as-ppx` flag

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let _str = {j|Foo|j};
  > EOF

  $ melc --as-pp x.ml > x.pp.ml
  $ melc --as-ppx x.pp.ml x.pp2.ml

  $ refmt --parse=binary x.pp2.ml
  let _str = {*j|Foo|*j};
