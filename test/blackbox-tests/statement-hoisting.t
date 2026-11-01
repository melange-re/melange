ReScript #9154: unspecified argument order still requires each operand to finish
before evaluating another. Both possible orders below give (1, 2), as native
OCaml confirms. Hoisting the second operand's statements currently gives (2, 2).

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type record = { x : int; y : int }
  > let tuple next =
  >   let r = ref 0 in
  >   ((r := 1; let k = next () in k + k + !r),
  >    (r := 2; let k = next () in k + k + !r))
  > let array next =
  >   let r = ref 0 in
  >   [| (r := 1; let k = next () in k + k + !r);
  >      (r := 2; let k = next () in k + k + !r) |]
  > let record next =
  >   let r = ref 0 in
  >   { x = (r := 1; let k = next () in k + k + !r);
  >     y = (r := 2; let k = next () in k + k + !r) }
  > let call f next =
  >   let r = ref 0 in
  >   f (r := 1; let k = next () in k + k + !r)
  >     (r := 2; let k = next () in k + k + !r)
  > let callee next =
  >   let r = ref 0 in
  >   (r := 1; let k = next () in
  >    if k + k + !r = 1 then (fun x -> x) else (fun x -> -x))
  >     (r := 2; let k = next () in k + k + !r)
  > let bare next =
  >   let r = ref 0 in
  >   ((r := 1; for _i = 1 to next () do () done; !r),
  >    (r := 2; for _i = 1 to next () do () done; !r))
  > let sequenced next =
  >   let r = ref 0 in
  >   let a = r := 1; let k = next () in k + k + !r in
  >   let b = r := 2; let k = next () in k + k + !r in
  >   (a, b)
  > let branching next choose =
  >   let r = ref 0 in
  >   ((r := 1; let k = next () in k + k + !r),
  >    (match choose () with
  >     | 0 -> r := 2; let k = next () in k + k + !r
  >     | 1 -> r := 3; let k = next () in k + k + !r
  >     | _ -> r := 4; let k = next () in k + k + !r))
  > let caught next =
  >   let r = ref 0 in
  >   ((r := 1; let k = next () in k + k + !r),
  >    (try r := 2; let k = next () in k + k + !r
  >     with Exit -> r := 3; !r))
  > EOF
  $ cat > native.ml <<'EOF'
  > let () =
  >   let next () = 0 in
  >   assert (Input.tuple next = (1, 2));
  >   assert (Input.array next = [|1; 2|]);
  >   assert (Input.record next = {x=1; y=2});
  >   assert (Input.call (fun x y -> x,y) next = (1, 2));
  >   assert (Input.callee next = 2);
  >   assert (Input.bare next = (1, 2));
  >   assert (Input.sequenced next = (1, 2));
  >   for n = 0 to 2 do assert (Input.branching next (fun () -> n) = (1, n+2)) done;
  >   assert (Input.caught next = (1, 2))
  > EOF
  $ ocamlc -o native.exe input.ml native.ml
  $ ./native.exe
  $ rm input.cmi input.cmo native.cmi native.cmo
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > ffi.ml <<'EOF'
  > external make : x:int -> y:int -> <x:int;y:int> Js.t = "" [@@mel.obj]
  > let object_ next =
  >   let r = ref 0 in
  >   make ~x:(r := 1; let k = next () in k + k + !r)
  >     ~y:(r := 2; let k = next () in k + k + !r)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit (target out) (modules input ffi) (libraries melange)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > const next = () => 0;
  > for (const name of ['tuple', 'array', 'record', 'caught']) console.log(name, JSON.stringify(m[name](next)));
  > console.log('call', JSON.stringify(m.call((x,y) => [x,y], next)));
  > console.log('callee', m.callee(next), 'bare', JSON.stringify(m.bare(next)));
  > console.log('ffi', JSON.stringify(require('./_build/default/out/ffi.js').object_(next)));
  > for (let n = 0; n < 3; n++) console.log('switch', JSON.stringify(m.branching(next, () => n)));
  > assert.deepEqual(m.sequenced(next), [1,2]);
  > const failure = new Error('operand');
  > for (const name of ['tuple', 'array', 'record', 'sequenced']) {
  >   let calls = 0;
  >   assert.throws(() => m[name](() => { calls++; throw failure; }), e => e === failure);
  >   assert.equal(calls, 1);
  > }
  > EOF
  tuple [2,2]
  array [2,2]
  record {"x":2,"y":2}
  caught [2,2]
  call [2,2]
  callee -2 bare [2,2]
  ffi {"x":2,"y":2}
  switch [2,2]
  switch [3,3]
  switch [4,4]
