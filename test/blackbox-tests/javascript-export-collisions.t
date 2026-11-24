JavaScript export names must be unique after mangling, including nested modules.
The initial snapshots expose overwritten properties and duplicate ESM exports.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.8)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit (target runtime) (alias runtime) (modules) (libraries melange.js))
  > EOF
  $ dune build @runtime
  $ export NODE_PATH="$PWD/_build/default/runtime/node_modules"
  $ test -f "$NODE_PATH/melange.js/caml_exceptions.js"
  $ cat > unicode.ml <<'EOF'
  > let café = 1
  > let cafè = 2
  > EOF
  $ melc unicode.ml -o unicode.js
  $ if test -f unicode.js; then node -p 'JSON.stringify(Object.values(require("./unicode.js")))'; fi
  [2]
  $ melc -mel-module-type es6 unicode.ml -o unicode.mjs
  $ if test -f unicode.mjs; then node --check unicode.mjs >/dev/null 2>&1; echo "ESM syntax status: $?"; fi
  ESM syntax status: 1

  $ cat > nested.ml <<'EOF'
  > module Nested = struct
  >   exception M of int
  >   module M = struct let value = 3 end
  > end
  > EOF
  $ melc nested.ml -o nested.js
  $ if test -f nested.js; then node -p 'typeof require("./nested.js").Nested.M'; fi
  object

  $ cat > contract.mli <<'EOF'
  > val café : int
  > val cafè : int
  > EOF
  $ melc -c contract.mli

  $ cat > module_type.ml <<'EOF'
  > module type S = sig
  >   val café : int
  >   val cafè : int
  > end
  > EOF
  $ melc module_type.ml -o module_type.js

  $ cat > functor_exports.ml <<'EOF'
  > module F (X : sig end) = struct
  >   let café = 1
  >   let cafè = 2
  > end
  > EOF
  $ melc functor_exports.ml -o functor_exports.js

  $ cat > default_marker.ml <<'EOF'
  > let default = 1
  > let __esModule = 2
  > EOF
  $ melc default_marker.ml -o default_marker.js
  $ if test -f default_marker.js; then node -p 'require("./default_marker.js").__esModule'; fi
  true

Shadowing, nonemitted primitives, and interface-hidden bindings remain valid.

  $ cat > safe.ml <<'EOF'
  > let value = 1
  > let value = value + 1
  > external café : int -> int = "%identity"
  > let cafè = café value
  > let __esModule = 2
  > module Nested : sig module M : sig val value : int end end = struct
  >   exception M of int
  >   module M = struct let value = 3 end
  > end
  > EOF
  $ melc -w -38 safe.ml -o safe.js
  $ cat > hidden.mli <<'EOF'
  > val café : int
  > EOF
  $ cat > hidden.ml <<'EOF'
  > let café = 1
  > let cafè = 2
  > EOF
  $ melc -c hidden.mli
  $ melc -I . -w -32 hidden.ml -o hidden.js
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const safe = require('./safe.js');
  > assert.equal(safe.value, 2);
  > assert.equal(safe.Nested.M.value, 3);
  > assert.equal(safe.$$__esModule, 2);
  > assert.deepEqual(Object.values(require('./hidden.js')), [1]);
  > EOF
