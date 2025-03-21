  $ . ./setup.sh

  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >   (target out))
  > EOF

  $ cat > x.ml <<EOF
  > module type Message = sig
  >   val f : unit -> unit
  > end
  > module rec X : sig
  >   val make : unit -> unit
  >   val serialize : unit -> string
  > end = struct
  >   let make x = x
  >   let serialize =
  >     let f =
  >       let (module Msg) = (module Y : Message) in
  >       Msg.f
  >     in
  >     fun () ->
  >       f ();
  >       "x"
  > end
  > and Y : sig
  >   val f : unit -> unit
  > end = struct
  >   let f = fun () -> ()
  > end
  > let () = X.make () |> X.serialize |> print_endline
  > EOF

  $ dune build @melange
  $ node _build/default/out/x.js 2>&1 | grep -v Node | grep -vE '\s+at'
  $TESTCASE_ROOT/_build/default/out/node_modules/melange.js/caml_module.js:9
      throw new Caml_js_exceptions.MelangeError("Undefined_recursive_module", {
      ^
  
  Error [MelangeError]: Undefined_recursive_module
    MEL_EXN_ID: 'Undefined_recursive_module',
    _1: [ 'x.ml', 20, 6 ],
    [cause]: { MEL_EXN_ID: 'Undefined_recursive_module', _1: [ 'x.ml', 20, 6 ] }
  }
  
