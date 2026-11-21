Member access must apply to the result of typeof. Function receivers are controls.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > external length : 'a -> int = "length" [@@mel.get]
  > external upper : string -> string = "toUpperCase" [@@mel.send]
  > external char : string -> int -> string = "charAt" [@@mel.send]
  > external call : ('a -> 'b) -> unit Js.Nullable.t -> 'a -> 'b = "call" [@@mel.send]
  > let len x = length (Js.typeof x)
  > let up x = upper (Js.typeof x)
  > let nested x = length (upper (Js.typeof x))
  > let index x = char (Js.typeof x) 0
  > let arity () = length (fun x -> x + 1)
  > let called () = call (fun x -> x + 1) Js.Nullable.null 4
  > external next : unit -> string = "next"
  > let effectful () = upper (Js.typeof (next ()))
  > let raw () = length ([%mel.raw {|x => x + 1|}] : int -> int)
  > EOF
  $ melc --color=never -ppx melppx -o input.js input.ml
  $ node --check input.js
  $ node <<'EOF'
  > const t = require('./input.js');
  > console.log('typeof:', t.len('abc'), t.up('abc'), t.nested('abc'), t.index('abc'));
  > console.log('functions:', t.arity(), t.called(), t.raw());
  > let calls = 0;
  > global.next = () => { ++calls; return 'abc'; };
  > console.log('effect:', t.effectful(), calls);
  > EOF
  typeof: number string number string
  functions: 1 5 1
  effect: string 1
