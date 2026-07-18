  $ . ./setup.sh

Classify whether repeated references to the same immutable block duplicate
recursive CMJ summary data.

  $ cat > input.ml <<'EOF'
  > type node = Leaf of (int -> int) | Node of node * node
  > let leaf = Leaf (fun x -> x)
  > let n1 = Node (leaf, leaf)
  > let n2 = Node (n1, n1)
  > let n3 = Node (n2, n2)
  > let n4 = Node (n3, n3)
  > let n5 = Node (n4, n4)
  > let n6 = Node (n5, n5)
  > let n7 = Node (n6, n6)
  > let n8 = Node (n7, n7)
  > let n9 = Node (n8, n8)
  > let n10 = Node (n9, n9)
  > let n11 = Node (n10, n10)
  > let n12 = Node (n11, n11)
  > let n13 = Node (n12, n12)
  > let n14 = Node (n13, n13)
  > let n15 = Node (n14, n14)
  > let n16 = Node (n15, n15)
  > let n17 = Node (n16, n16)
  > let n18 = Node (n17, n17)
  > EOF

  $ melc $MEL_STDLIB_FLAGS --mel-stop-after-cmj input.ml
  $ if test "$(wc -c < input.cmj)" -lt 100000; then echo shared; else echo duplicated; fi
  duplicated
