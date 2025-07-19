
  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > module X = List
  > EOF
  $ melc --modules ./x.ml

  $ cat > x.ml <<EOF
  > module X = List module X0 = List1
  > EOF
  $ melc --modules ./x.ml 2>/dev/null

