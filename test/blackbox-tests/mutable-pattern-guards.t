OCaml #7241 / ReScript #9129: after a guard mutates the scrutinee, later
branches must recheck fields that they read again. A cached read remains valid.
The first four and last matches must raise Match_failure, as OCaml 5.3+ does.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type pair = { a : bool; mutable b : int option * int option }
  > let pair r swap =
  >   match r with
  >   | {a=true; b=(None,_)} -> 1
  >   | {a=true; b=(Some _,_)} when (r.b <- swap; false) -> 0
  >   | {a=false; _} -> 3
  >   | {b=(_,None); _} -> 4
  >   | {b=(Some x,Some _); _} -> x
  > 
  > type flagged = { d : bool; mutable c : int option }
  > let flagged r =
  >   match r with
  >   | {c=None;_} -> 0
  >   | {d=true;_} when (r.c <- None; false) -> 1
  >   | {c=Some x;_} -> x
  > 
  > type 'a cell = { mutable value : 'a }
  > type nested = { enabled : bool; inner : (bool, int) Either.t cell }
  > let nested r =
  >   match r with
  >   | {enabled=false;_} -> false
  >   | {inner={value=Either.Right _};_} -> false
  >   | _ when (r.inner.value <- Either.Right 3; false) -> false
  >   | {enabled=true;inner={value=Either.Left y}} -> y
  > 
  > let deep r =
  >   match Some r with
  >   | Some {contents=((),None)} -> 0
  >   | _ when (r := ((),None); false) -> 1
  >   | Some {contents=((),Some n)} -> n
  >   | None -> 3
  > 
  > let lazy_case r l =
  >   match r, l with
  >   | {contents=None}, _ -> 0
  >   | _, lazy true -> 1
  >   | {contents=Some n}, _ -> n
  > 
  > let lazy_nested r =
  >   let l = lazy (r.inner.value <- Either.Right 3; false) in
  >   match r, l with
  >   | {enabled=false;_}, _ -> false
  >   | {inner={value=Either.Right _};_}, _ -> false
  >   | _, lazy true -> false
  >   | {enabled=true;inner={value=Either.Left y}}, _ -> y
  > 
  > let array_case a =
  >   match a with
  >   | [|None|] -> 0
  >   | _ when (a.(0) <- None; false) -> 1
  >   | [|Some n|] -> n
  >   | _ -> 3
  > 
  > let observe f = try ignore (f ()); false with Match_failure _ -> true
  > let checks () =
  >   let r = ref (Some 5) in
  >   [| observe (fun () -> pair {a=true;b=(Some 1,None)} (None,Some 2));
  >      observe (fun () -> flagged {d=true;c=Some 1});
  >      observe (fun () -> nested {enabled=true;inner={value=Either.Left true}});
  >      observe (fun () -> deep (ref ((),Some 1)));
  >      observe (fun () -> lazy_case r (lazy (r := None; false)));
  >      observe (fun () -> lazy_nested {enabled=true;inner={value=Either.Left true}}) |]
  > 
  > let controls () =
  >   [| pair {a=true;b=(None,None)} (None,None);
  >      pair {a=false;b=(Some 1,None)} (None,None);
  >      pair {a=true;b=(Some 1,None)} (Some 8,Some 2);
  >      pair {a=true;b=(Some 1,Some 2)} (None,None);
  >      flagged {d=false;c=Some 5};
  >      array_case [|Some 1|] |]
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit (target out) (modules input) (libraries melange)
  >  (compile_flags :standard -w -a))
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > assert.deepEqual(m.controls(), [1,3,8,4,5,3]);
  > console.log('Match_failure:', JSON.stringify(m.checks()));
  > EOF
  Match_failure: [false,false,false,false,false,false]
