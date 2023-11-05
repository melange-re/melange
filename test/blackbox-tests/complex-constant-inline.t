
  $ . ./setup.sh
  $ cat >dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF

  $ cat >dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false))
  > EOF

  $ cat > x.ml <<EOF
  > module Test1 = struct
  >   type status = Vacations of int | Sabbatical of int | Sick
  >   type person = Teacher of { age : int } | Student of { status : status }
  > 
  >   let person1 = Teacher { age = 12345 }
  > 
  >   let message =
  >     match person1 with
  >     | Student { status = Vacations _ | Sick } -> "a"
  >     | _ -> "b"
  > end
  > EOF

  $ dune build
  File "dune", line 1, characters 0-49:
  1 | (melange.emit
  2 |  (target out)
  3 |  (emit_stdlib false))
  melc: internal error, uncaught exception:
        Invalid_argument("option is None")
        
  [1]
