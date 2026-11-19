Escaped constructor tags must compare by their emitted string values.
The identity external below maps tags shared by two nominal variant types.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type t = A [@mel.as "\x41"] | Slash [@mel.as "\\u0041"]
  >   | Snow [@mel.as "\u{2603}"] | Newline [@mel.as "\n"]
  > type u = Padding | Alias [@mel.as "\u{0041}"] | Literal [@mel.as "\\u0041"]
  > external cast : u -> t = "%identity"
  > external repr : t -> string = "%identity"
  > let strings = [| repr A; repr Slash; repr Snow; repr Newline |]
  > let folded = [| repr A = "\065"; repr A = "\u{0041}";
  >   repr A = "\\u0041"; repr Slash = {|\u0041|}; repr Snow = "☃";
  >   repr Newline = "\x0a"; cast Alias = A; cast Literal = Slash;
  >   cast Alias <> Slash; cast Literal = A |]
  > let name = function A -> "A" | Slash -> "slash" | Snow -> "snow" | Newline -> "newline"
  > let names = [| name A; name Slash; name Snow; name Newline |]
  > let same (a : t) b = a = b
  > let equal (a : string) b = a = b
  > let aliases = [| cast Alias; cast Literal |]
  > EOF
  $ melc -ppx melppx -o input.js input.ml
  $ node <<'EOF'
  > const m = require('./input.js');
  > const [a, slash, snow, newline] = m.strings;
  > const [alias, literal] = m.aliases;
  > console.log('bytes', JSON.stringify(m.strings.map(s => [...s].map(c => c.charCodeAt(0)))));
  > console.log('folded', ...m.folded);
  > console.log('runtime', m.equal(a, 'A'), m.equal(a, '\u0041'),
  >   m.equal(a, '\\u0041'), m.equal(slash, '\\u0041'), m.equal(snow, '\xe2\x98\x83'),
  >   m.equal(newline, '\n'), m.same(alias, a), m.same(literal, slash),
  >   !m.same(alias, slash), m.same(literal, a));
  > console.log('matches', m.names.join(','), m.strings.map(m.name).join(','));
  > EOF
  bytes [[65],[92,117,48,48,52,49],[226,152,131],[10]]
  folded true true false true true true true true true false
  runtime true true false true true true true true true false
  matches A,slash,snow,newline A,slash,snow,newline
