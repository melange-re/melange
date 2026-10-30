ReScript #6485: cover optional field presence.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > type object_
  > external make : ?x:'a -> unit -> object_ = "" [@@mel.obj]
  > let direct () = make ?x:None ()
  > let dynamic x = make ?x ()
  > let alias x = match x with Some v -> make ~x:v () | None as y -> make ?x:y ()
  > let from_result x = match x with Ok v -> make ?x:v () | Error _ -> make ()
  > let nested_none () = make ~x:None ()
  > let explicit_undefined () = make ~x:Js.undefined ()
  > type properties = { x : int option [@mel.optional] } [@@deriving jsProperties]
  > let derived_direct () = properties ()
  > let derived_dynamic x = properties ?x ()
  > let properties_literal () : properties = { x = None }
  > let properties_literal_dynamic x : properties = { x }
  > type ordinary = { y : int option }
  > let ordinary_direct () = { y = None }
  > let ordinary_dynamic y = { y }
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require('node:assert/strict');
  > const m = require('./_build/default/out/input.js');
  > for (const object of [m.direct(), m.dynamic(undefined), m.alias(undefined),
  >                      m.from_result({TAG:0,_0:undefined}), m.derived_direct(), m.derived_dynamic(undefined)])
  >   assert.deepEqual(Object.keys(object), []);
  > assert.deepEqual(m.dynamic(false), {x:false});
  > assert.deepEqual(m.dynamic(0), {x:0});
  > assert.deepEqual(Object.keys(m.nested_none()), ['x']);
  > assert.deepEqual(Object.keys(m.explicit_undefined()), ['x']);
  > assert.deepEqual([m.ordinary_direct(), m.ordinary_dynamic(undefined)], [{y:undefined},{y:undefined}]);
  > assert.deepEqual([m.properties_literal(), m.properties_literal_dynamic(undefined)], [{x:undefined},{x:undefined}]);
  > EOF
