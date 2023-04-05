
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  >   external mk : int ->
  > (
  >   [\`a|\`b]
  >    [@bs.string]
  > ) = "mk" [@@bs.val]
  > EOF
  $ melc -ppx melppx x.ml 2>&1 | grep -v Command
  File "x.ml", line 4, characters 5-14:
  4 |    [@bs.string]
           ^^^^^^^^^
  Error (warning 101 [unused-bs-attributes]): Unused attribute: bs.string
  This means such annotation is not annotated properly. 
  for example, some annotations is only meaningful in externals 
  
  File "x.ml", line 1:
  Error: Error while running external preprocessor
  


