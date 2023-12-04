Test the attribute @mel.uncurry at different level of nesting

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

Normal uncurry at first level works fine

  $ cat > x.ml <<EOF
  > external foo : ((unit -> unit)[@mel.uncurry]) -> unit
  >   = "foo"
  > EOF

  $ dune build @melange

Using `mel.uncurry` at 2nd level of callbacks raises some alerts

  $ cat > x.ml <<EOF
  > external foo :
  >   (((unit -> unit)[@mel.uncurry]) -> (unit -> unit[@mel.uncurry])) -> unit
  >   = "foo"
  > EOF
  $ dune build @melange
  File "x.ml", line 2, characters 20-31:
  2 |   (((unit -> unit)[@mel.uncurry]) -> (unit -> unit[@mel.uncurry])) -> unit
                          ^^^^^^^^^^^
  Alert unused: Unused attribute [@mel.uncurry]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
  
  
  File "x.ml", line 2, characters 52-63:
  2 |   (((unit -> unit)[@mel.uncurry]) -> (unit -> unit[@mel.uncurry])) -> unit
                                                          ^^^^^^^^^^^
  Alert unused: Unused attribute [@mel.uncurry]
  This means such annotation is not annotated properly.
  For example, some annotations are only meaningful in externals
  


In the case of uncurry nesting, we have to resort to the `[@u]` attribute

  $ cat > x.ml <<EOF
  > external foo : (((unit -> unit)[@u]) -> unit) -> unit = "foo"
  > let () = foo (fun f -> f () [@u])
  > EOF
  $ dune build @melange

