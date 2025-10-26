Test an edge of recursive modules with an inner component that is mangled

  $ . ./setup.sh

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

  $ melc x.ml > x.js
  $ node ./x.js
  string

