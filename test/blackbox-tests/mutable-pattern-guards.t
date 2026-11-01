OCaml #7241: mutable reads must be checked again after a failed guard or lazy
pattern. Each failure check should be true; valid later branches still return 3 and 8.

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
  > let lazy_nested r =
  >   let l = lazy (r.inner.value <- Either.Right 3; false) in
  >   match r, l with
  >   | {enabled=false;_}, _ -> false
  >   | {inner={value=Either.Right _};_}, _ -> false
  >   | _, lazy true -> false
  >   | {enabled=true;inner={value=Either.Left y}}, _ -> y
  > 
  > let observe f = try ignore (f ()); false with Match_failure _ -> true
  > let checks () =
  >   [| observe (fun () -> pair {a=true;b=(Some 1,None)} (None,Some 2));
  >      observe (fun () -> flagged {d=true;c=Some 1});
  >      observe (fun () -> nested {enabled=true;inner={value=Either.Left true}});
  >      observe (fun () -> deep (ref ((),Some 1)));
  >      observe (fun () -> lazy_nested {enabled=true;inner={value=Either.Left true}}) |]
  > 
  > let controls () =
  >   [| pair {a=false;b=(Some 1,None)} (None,None);
  >      pair {a=true;b=(Some 1,None)} (Some 8,Some 2) |]
  > EOF
  $ melc -w -a -o input.js input.ml
  $ node -e 'const m = require("./input.js"); console.log(JSON.stringify(m.checks()), JSON.stringify(m.controls()))'
  [false,false,false,false,false] [3,8]
