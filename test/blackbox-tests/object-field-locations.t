  $ . ./setup.sh
  $ cat > x.ml <<'EOF'
  > type t =
  >   < bark : string -> unit
  >   ; value : int [@mel.get] >
  >   Js.t
  > EOF

Generated object fields satisfy the ppxlib location invariant.

  $ melc -ppx 'melppx -locations-check' -c x.ml > /dev/null

Object literal expansion keeps source and generated locations disjoint.

  $ cat > literal.ml <<'EOF'
  > let value = [%obj { first = 1; second = "two" }]
  > EOF
  $ melc -ppx 'melppx -locations-check' -c literal.ml > /dev/null

External object creation keeps source and generated locations disjoint.

  $ cat > external.ml <<'EOF'
  > external make :
  >   required:int ->
  >   ?optional:string ->
  >   unit ->
  >   _ = "" [@@mel.obj]
  > EOF
  $ melc -ppx 'melppx -locations-check' -c external.ml > /dev/null

Object expression expansion keeps source and generated locations disjoint.

  $ cat > object.ml <<'EOF'
  > let value =
  >   object
  >     val immutable_field = 1
  >     val mutable mutable_field = 2
  >     method add x y = x + y
  >     method private identity x = x
  >   end [@u]
  > EOF
  $ melc -ppx 'melppx -locations-check' -c object.ml > /dev/null
