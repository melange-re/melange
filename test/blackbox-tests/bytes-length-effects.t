Byte-length folding must preserve construction effects and exceptions.

  $ . ./setup.sh
  $ cat > input.ml <<'ML'
  > external hit : int -> char = "hit"
  > external of_array : char array -> bytes = "%identity"
  > let length () = Bytes.length (of_array [|hit 1; hit 2|])
  > let ignored () = ignore (Bytes.length (of_array [|hit 1; hit 2|]))
  > ML
  $ melc -ppx melppx -o input.js input.ml
  $ node <<'JS'
  > const t = require('./input.js');
  > for (const f of [t.length, t.ignored]) {
  >   const calls = [];
  >   global.hit = i => { calls.push(i); return 65; };
  >   console.log(f(), JSON.stringify(calls));
  >   const error = new Error('byte construction');
  >   global.hit = () => { throw error; };
  >   try { f(); console.log('did not throw'); }
  >   catch (e) { console.log(e === error); }
  > }
  > JS
  2 []
  did not throw
  undefined []
  did not throw
