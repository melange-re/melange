Local modules named Js resolve normally without compiler crashes.
ReScript #7007.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > module Builtin = Js
  > module Js = struct let f () = 1 end
  > let value = Js.f ()
  > module Nested = struct
  >   module Js = struct let f x = x + 2 end
  >   let value = Js.f 3
  > end
  > let local () = let module Js = struct let f () = 7 end in Js.f ()
  > module Make (Js : sig val f : unit -> int end) = struct let value = Js.f () end
  > module Result = Make (Js)
  > let typ = Builtin.typeof value
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > assert.deepEqual([m.value, m.Nested.value, m.local(), m.Result.value, m.typ], [1,5,7,1,'number']);
  > EOF
