Constructors must have distinct representations within each tag namespace.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type t = A [@mel.as 1] | B | C
  > let name = function A -> "A" | B -> "B" | C -> "C"
  > let folded = name B
  > let value = B
  > let equal = A = B
  > let runtime_equal (a : t) b = a = b
  > EOF
  $ melc input.ml -o input.js && node <<'EOF'
  > const m = require('./input.js');
  > console.log(m.folded, m.name(m.value), m.equal, m.runtime_equal(1, 1));
  > EOF
  File "input.ml", line 1, characters 25-26:
  1 | type t = A [@mel.as 1] | B | C
                               ^
  Error: Constructors A and B have the same JavaScript representation
  [2]

Explicit aliases also collide, including payload and inline-record tags.
Check both implementations and interfaces without requiring the PPX.

  $ for suffix in ml mli; do
  >   for constructors in \
  >     'A [@mel.as "x"] | B [@mel.as "x"]' \
  >     'A [@mel.as false] | B [@mel.as false]' \
  >     'A [@mel.as null] | B [@mel.as null]' \
  >     'A [@mel.as undefined] | B [@mel.as undefined]' \
  >     'A of int [@mel.as 1] | B of {x : int}'; do
  >     echo "type t = $constructors" > invalid.$suffix
  >     melc --mel-cmi-only invalid.$suffix
  >   done
  > done
  File "invalid.ml", line 1, characters 27-28:
  1 | type t = A [@mel.as "x"] | B [@mel.as "x"]
                                 ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.ml", line 1, characters 29-30:
  1 | type t = A [@mel.as false] | B [@mel.as false]
                                   ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.ml", line 1, characters 28-29:
  1 | type t = A [@mel.as null] | B [@mel.as null]
                                  ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.ml", line 1, characters 33-34:
  1 | type t = A [@mel.as undefined] | B [@mel.as undefined]
                                       ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.ml", line 1, characters 32-33:
  1 | type t = A of int [@mel.as 1] | B of {x : int}
                                      ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.mli", line 1, characters 27-28:
  1 | type t = A [@mel.as "x"] | B [@mel.as "x"]
                                 ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.mli", line 1, characters 29-30:
  1 | type t = A [@mel.as false] | B [@mel.as false]
                                   ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.mli", line 1, characters 28-29:
  1 | type t = A [@mel.as null] | B [@mel.as null]
                                  ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.mli", line 1, characters 33-34:
  1 | type t = A [@mel.as undefined] | B [@mel.as undefined]
                                       ^
  Error: Constructors A and B have the same JavaScript representation
  File "invalid.mli", line 1, characters 32-33:
  1 | type t = A of int [@mel.as 1] | B of {x : int}
                                      ^
  Error: Constructors A and B have the same JavaScript representation
  [2]

Nullary and payload constructors have separate tag namespaces. Integer and
string tags also remain distinct, and swapped integers must still fold correctly.

  $ cat > valid.ml <<'EOF'
  > type t = A [@mel.as 1] | B [@mel.as 0] | C [@mel.as "1"]
  >   | D of int [@mel.as 1] | E of {x:int} [@mel.as 0]
  > let name = function A -> "A" | B -> "B" | C -> "C" | D _ -> "D" | E _ -> "E"
  > let folded = [| name A; name B; name C; name (D 2); name (E {x=3}) |]
  > let values = [| A; B; C; D 2; E {x=3} |]
  > EOF
  $ melc valid.ml -o valid.js
  $ node <<'EOF'
  > const m = require('./valid.js');
  > console.log(m.folded.join(','), m.values.map(m.name).join(','));
  > EOF
  A,B,C,D,E A,B,C,D,E
