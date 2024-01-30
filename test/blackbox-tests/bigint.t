
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
  > let t = Js.Bigint.make "5"
  > let () = Js.log (Js.Bigint.asInt32 t)
  > let () = Js.log (Js.Bigint.asIntN ~precision:64 t)
  > let () =
  >   Js.log3
  >     (Js.Bigint.toString t)
  >     (Js.Bigint.toLocaleString ~locale:"de-DE" t)
  >     (Js.Bigint.toLocaleString
  >       ~locale:"en-US"
  >       ~options:{ style = "currency"; currency = "EUR" }
  >       t)
  > EOF
  $ dune build @melange
  $ node _build/default/out/x.js
  5n
  5n
  5 5 €5.00
