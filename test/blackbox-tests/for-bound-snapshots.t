Loop bounds are evaluated once, including after local reference elimination.

Every loop below should execute four iterations. The final controls value is 2:
each of the two side-effectful bound expressions runs once.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let global = ref 3
  > let local () =
  >   let n = ref 0 in let r = ref 3 in
  >   for _i = 0 to !r do incr n; decr r done; !n
  > let escaped () =
  >   let n = ref 0 in global := 3;
  >   for _i = 0 to !global do incr n; decr global done; !n
  > let down () =
  >   let n = ref 0 in let r = ref 0 in
  >   for _i = 3 downto !r do incr n; incr r done; !n
  > let lower () =
  >   let n = ref 0 in let r = ref 0 in
  >   for _i = !r to 3 do incr n; incr r done; !n
  > let alias () =
  >   let n = ref 0 in let r = ref 3 in let bound = !r in
  >   for _i = 0 to bound do incr n; decr r done; !n
  > let effects () =
  >   let count = ref 0 in let n = ref 0 in
  >   for _i = (incr count; 0) to (incr count; 3) do incr n done;
  >   (!n, !count)
  > let ref_alias () =
  >   let r = ref 3 in let alias = r in let n = ref 0 in
  >   for _i = 0 to !alias do incr n; decr r done; !n
  > let exclusive () =
  >   let r = ref 4 in let n = ref 0 in
  >   for _i = 0 to !r - 1 do incr n; decr r done; !n
  > let start_down () =
  >   let r = ref 3 in let n = ref 0 in
  >   for _i = !r downto 0 do incr n; decr r done; !n
  > EOF
  $ melc --color=never -o input.js input.ml
  $ sed -n '/^function local(/,/^}/p; /^function down(/,/^}/p' input.js
  function local(param) {
    let n = 0;
    let r = 3;
    for (let _i = 0; _i <= r; ++_i) {
      n = n + 1 | 0;
      r = r - 1 | 0;
    }
    return n;
  }
  function down(param) {
    let n = 0;
    let r = 0;
    for (let _i = 3; _i >= r; --_i) {
      n = n + 1 | 0;
      r = r + 1 | 0;
    }
    return n;
  }
  $ node <<'EOF'
  > const t = require('./input.js');
  > console.log('finish:', t.local(), t.down(), t.ref_alias(), t.exclusive());
  > console.log('controls:', t.escaped(), t.lower(), t.start_down(), t.alias(), ...t.effects());
  > EOF
  finish: 2 2 2 2
  controls: 4 4 4 4 4 2
  $ cp input.ml native.ml
  $ cat > run.ml <<'EOF'
  > let () =
  >   let open Native in
  >   Printf.printf "finish: %d %d %d %d\n" (local()) (down()) (ref_alias()) (exclusive());
  >   let n, calls = effects () in
  >   Printf.printf "controls: %d %d %d %d %d %d\n" (escaped()) (lower()) (start_down()) (alias()) n calls
  > EOF
  $ ocamlc -w -a -o native.exe native.ml run.ml
  $ ./native.exe
  finish: 4 4 4 4
  controls: 4 4 4 4 4 2
