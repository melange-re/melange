Known constant Some values do not need presence guards. Presence must remain distinct from payload truthiness.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let number () = let opt = Some 42 in match opt with Some x -> x | None -> 0
  > let zero () = let opt = Some 0 in match opt with Some x -> x | None -> 42
  > let false_payload () = let opt = Some false in match opt with Some x -> x | None -> true
  > let nested () = let opt = Some None in match opt with Some None -> 1 | Some (Some _) -> 2 | None -> 0
  > let deeper () = let opt = Some (Some None) in match opt with Some (Some None) -> 3 | _ -> 0
  > let absent () = match None with Some _ -> 1 | None -> 2
  > let effects f = let opt = Some 0 in match opt with Some x -> f x | None -> f 42
  > let payload_truthiness val1 val2 =
  >   let a = Some val1 in let b = Some val2 in
  >   match a, b with _, Some true | Some true, _ -> "a" | _ -> "b"
  > EOF
  $ melc input.ml -o input.js
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const t = require('./input.js');
  > for (const [name, expected] of [['number', 42], ['zero', 0], ['false_payload', false], ['nested', 1], ['deeper', 3], ['absent', 2]]) {
  >   assert.equal(t[name](), expected);
  >   console.log(t[name].toString());
  > }
  > let calls = 0;
  > assert.equal(t.effects(x => { calls++; return x; }), 0);
  > assert.equal(calls, 1);
  > for (const a of [false, true]) for (const b of [false, true])
  >   assert.equal(t.payload_truthiness(a, b), a || b ? 'a' : 'b');
  > EOF
  function number(param) {
    const opt = 42;
    if (opt !== undefined) {
      return opt;
    } else {
      return 0;
    }
  }
  function zero(param) {
    const opt = 0;
    if (opt !== undefined) {
      return opt;
    } else {
      return 42;
    }
  }
  function false_payload(param) {
    const opt = false;
    if (opt !== undefined) {
      return opt;
    } else {
      return true;
    }
  }
  function nested(param) {
    const opt = Caml_option.some(undefined);
    if (opt !== undefined) {
      if (Caml_option.valFromOption(opt) !== undefined) {
        return 2;
      } else {
        return 1;
      }
    } else {
      return 0;
    }
  }
  function deeper(param) {
    const opt = Caml_option.some(Caml_option.some(undefined));
    if (opt === undefined) {
      return 0;
    }
    const match = Caml_option.valFromOption(opt);
    if (match !== undefined && Caml_option.valFromOption(match) === undefined) {
      return 3;
    } else {
      return 0;
    }
  }
  function absent(param) {
    return 2;
  }
