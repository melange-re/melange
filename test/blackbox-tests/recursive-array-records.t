Recursive records must have the same JavaScript representation as ordinary records.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type array_record = { next : array_record [@mel.as "0"]; value : int [@mel.as "1"] }
  > type object_record = { self : object_record; value : int }
  > type sparse = { self : sparse [@mel.as "0"]; value : int [@mel.as "2"] }
  > let rec a = {next=a;value=1}
  > let rec b = {next=c;value=2} and c = {next=b;value=3}
  > let copy={a with value=4}
  > let rec object_={self=object_;value=5}
  > let rec sparse={self=sparse;value=6}
  > let () =
  >  List.iter (fun r -> Printf.printf "%b %b %d\n" (Js.Array.isArray r) (r.next.next==r) r.value) [a;b;c;copy];
  >  Printf.printf "%b %b %b %b\n" (Js.Array.isArray object_) (object_.self==object_) (Js.Array.isArray sparse) (sparse.self==sparse)
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ node _build/default/out/input.js
  false true 1
  false true 2
  false true 3
  true false 4
  false true false true
