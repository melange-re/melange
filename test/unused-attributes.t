
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  >   external mk : int ->
  > (
  >   [\`a|\`b]
  >    [@bs.string]
  > ) = "mk" [@@bs.val]
  > EOF
  $ melc -ppx melppx x.ml -dsource
  [%%ocaml.error
    "Unused attribute: bs.string\nThis means such annotation is not annotated properly.\nfor example, some annotations is only meaningful in externals\n"]
  external mk : int -> (([ `a  | `b ])[@bs.string ]) = "mk"[@@bs.val ]
  File "x.ml", line 4, characters 5-14:
  4 |    [@bs.string]
           ^^^^^^^^^
  Error: Unused attribute: bs.string
         This means such annotation is not annotated properly.
         for example, some annotations is only meaningful in externals
         
  [2]
