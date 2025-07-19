
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > module X = List
  > EOF
  $ melc --modules ./x.ml
  ./x.ml: List 

  $ cat > x.ml <<EOF
  > module X = List module X0 = List1
  > EOF
  $ melc --modules ./x.ml 
  ./x.ml: List List1 

  $ cat > x.mli <<EOF
  > module X = List module X0 = List1
  > EOF
  $ melc --modules ./x.mli
  ./x.mli: List List1 
