Demonstrate how to use `melc` with `refmt` and Reason files

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ cat > x.ml <<EOF
  > external mySvg: string = "default" [@@bs.module "./assets/foo.svg"]
  > external css: < .. > Js.t as 'a = "./App.module.scss" [@@bs.module]
  > (* non-relative path, refers to module in node_modules, shouldn't appear
  >  * in assets *)
  > external x : string -> string = "foo" [@@bs.module "some_node_module"]
  > EOF

  $ melassets x.ml
  (4:x.ml(16:./assets/foo.svg17:./App.module.scss))

Works with (Reason) binary AST

  $ cat > x.re <<EOF
  > [@bs.module "./assets/foo.svg"] external mySvg: string = "default";
  > [@bs.module] external css: Js.t({..}) as 'a = "./App.module.scss";
  > EOF

  $ refmt --print=binary x.re > x.re.ml
  $ melassets x.re.ml
  (7:x.re.ml(16:./assets/foo.svg17:./App.module.scss))

