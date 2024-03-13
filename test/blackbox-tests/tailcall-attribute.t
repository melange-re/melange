Test that warning 51 (`wrong-tailcall-expectation`) works in Melange

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let rec fact = function
  >   | 1 -> 1
  >   | n -> n * (fact [@tailcall true]) (n-1)
  > EOF
  $ melc x.ml > /dev/null

  $ cat > x.ml <<EOF
  > let rec fact = function
  >   | 1 -> 1
  >   | n -> n * (fact [@tailcall false]) (n-1)
  > EOF
  $ melc x.ml > /dev/null

  $ cat > x.ml <<EOF
  > let rec fact_tail acc = function
  >   | 1 -> acc
  >   | n -> (fact_tail [@tailcall]) (n * acc) (n - 1)
  > EOF
  $ melc x.ml > /dev/null

  $ cat > x.ml <<EOF
  > let rec fact_tail acc = function
  >   | 1 -> acc
  >   | n -> (fact_tail [@tailcall true]) (n * acc) (n - 1)
  > EOF
  $ melc x.ml > /dev/null

  $ cat > x.ml <<EOF
  > let rec fact_tail acc = function
  >   | 1 -> acc
  >   | n -> (fact_tail [@tailcall false]) (n * acc) (n - 1)
  > EOF
  $ melc x.ml > /dev/null
