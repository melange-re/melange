A record field renamed to __proto__ must be an own data property.
Integer and object payloads must survive construction, updates, copies and cycles.

  $ . ./setup.sh
  $ cat > run.ml <<'ML'
  > type 'a record = { p : 'a [@mel.as "__proto__"]; other : int }
  > let make p = { p; other = 1 }
  > let constant = { p = 5; other = 1 }
  > let update r p = { r with p }
  > let preserve r = { r with other = 2 }
  > let duplicate r = Obj.dup r
  > type 'a node = { p : 'a [@mel.as "__proto__"]; next : 'a node }
  > let cycle p = let rec n = { p; next = n } in n
  > let[@inline never] id x = x
  > let backpatched p = let rec n = { p = id p; next = n } in n
  > ML
  $ melc -ppx melppx -o run.js run.ml
  $ cat run.js
  $ node --check run.js
  $ node <<'JS'
  > const m = require('./run.js');
  > const check = (name, r, value) => {
  >   const d = Object.getOwnPropertyDescriptor(r, '__proto__');
  >   console.log(name, Object.hasOwn(r, '__proto__'), r.__proto__ === value,
  >     Object.getPrototypeOf(r) === Object.prototype,
  >     !!d && d.writable && d.enumerable && d.configurable);
  > };
  > check('constant', m.constant, 5);
  > for (const value of [5, {marker:42}]) {
  >   const base = {['__proto__']:value, other:1};
  >   check('make', m.make(value), value);
  >   check('update', m.update(base, value), value);
  >   check('preserve', m.preserve(base), value);
  >   check('duplicate', m.duplicate(base), value);
  >   for (const name of ['cycle', 'backpatched']) {
  >     const r = m[name](value);
  >     check(name, r, value);
  >     console.log('cycle intact', r.next === r);
  >   }
  > }
  > let reads = 0;
  > const getter = {get ['__proto__']() {reads++; return 7}, other:1};
  > check('getter copy', m.duplicate(getter), 7);
  > console.log('reads', reads, 'array', JSON.stringify(m.duplicate([1,2])));
  > JS
