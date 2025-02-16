

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target js-out)
  >  (preprocess (pps melange.ppx))
  >  (emit_stdlib false))
  > EOF

  $ cat > x.ml <<EOF
  > type a = A | B [@mel.as "as-string"] | C
  > let f x = match x with A -> "a" | _ -> "other"
  > let g x = match x with B -> "as-string" | _ -> "other"
  > EOF

  $ dune build @melange
  $ cat ./_build/default/js-out/x.js
  // Generated by Melange
  'use strict';
  
  
  function f(x) {
    switch (x) {
      case /* A */ 0 :
        return "a";
      case /* B */ "as-string" :
      case /* C */ 2 :
        return "other";
    }
  }
  
  function g(x) {
    switch (x) {
      case /* B */ "as-string" :
        return "as-string";
      case /* A */ 0 :
      case /* C */ 2 :
        return "other";
    }
  }
  
  module.exports = {
    f,
    g,
  }
  /* No side effect */

  $ cat > x.ml <<EOF
  > type x = A [@mel.as "A"] | B
  > let f x = match x with A -> "a" | B -> "b"
  > EOF

  $ dune build @melange
  $ cat ./_build/default/js-out/x.js
  // Generated by Melange
  'use strict';
  
  
  function f(x) {
    if (x === /* A */ "A") {
      return "a";
    } else {
      return "b";
    }
  }
  
  module.exports = {
    f,
  }
  /* No side effect */
