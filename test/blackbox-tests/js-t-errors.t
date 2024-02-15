  $ . ./setup.sh

  $ cat > x.ml <<EOF
  > let obj = Js.Obj.empty()
  > let _: string = obj
  > EOF
  $ melc x.ml
  File "x.ml", line 2, characters 16-19:
  2 | let _: string = obj
                      ^^^
  Error: This expression has type < .. > Js.t
         but an expression was expected of type string
  [2]
