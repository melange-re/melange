Test an edge of recursive modules with an inner component that is mangled

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out))
  > EOF

`Date` gets mangled to `$$Date` in generated JS

  $ cat > x.ml <<EOF
  > module rec X : sig
  >   module Date : sig
  >     val wow : unit -> string
  >   end
  > end = struct
  >   module Date = struct
  >     let wow () = "string"
  >   end
  > end
  > let () = Js.log (X.Date.wow ())
  > EOF

  $ dune b @melange
  $ node _build/default/out/x.js
  string

