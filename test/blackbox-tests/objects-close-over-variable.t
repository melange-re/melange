Test classes that close over an init variable from the outside scope

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.9)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (preprocess
  >   (pps melange.ppx)))
  > EOF

  $ cat > x.ml <<EOF
  > let fresh () =
  >   let r = 2 in
  >   let dummy = object
  >     val mutable x = r
  >     method get_x = x
  >     method set_x y = x <- y
  >   end in
  >   dummy
  > let () =
  >   let f = (fresh()) in
  >   let x = f#get_x in
  >   Js.log2 "x expect 2" x;
  >   f#set_x 42 ;
  >   let y = f#get_x in
  >   Js.log2 "x expect 42" y;
  > EOF

  $ dune build @melange

  $ node _build/default/out/x.js
  x expect 2 2
  x expect 42 42

  $ cat _build/default/out/x.js
  // Generated by Melange
  'use strict';
  
  const Caml_oo_curry = require("melange.js/caml_oo_curry.js");
  const CamlinternalOO = require("melange/camlinternalOO.js");
  const Curry = require("melange.js/curry.js");
  
  const shared = [
    "set_x",
    "get_x"
  ];
  
  const object_tables = {
    TAG: /* Cons */0,
    key: undefined,
    data: undefined,
    next: undefined
  };
  
  function fresh(param) {
    if (!object_tables.key) {
      const $$class = CamlinternalOO.create_table(shared);
      const ids = CamlinternalOO.new_methods_variables($$class, shared, ["x"]);
      const set_x = ids[0];
      const get_x = ids[1];
      const x = ids[2];
      CamlinternalOO.set_methods($$class, [
            get_x,
            (function (self$1) {
                return self$1[x];
              }),
            set_x,
            (function (self$1, y) {
                self$1[x] = y;
              })
          ]);
      const env_init = function (env) {
        const self = CamlinternalOO.create_object_opt(undefined, $$class);
        self[x] = env[1];
        return self;
      };
      CamlinternalOO.init_class($$class);
      object_tables.key = env_init;
    }
    return Curry._1(object_tables.key, [
                undefined,
                2
              ]);
  }
  
  const f = fresh(undefined);
  
  const x = Caml_oo_curry.js1(291546447, 1, f);
  
  console.log("x expect 2", x);
  
  Caml_oo_curry.js2(-97543333, 2, f, 42);
  
  const y = Caml_oo_curry.js1(291546447, 3, f);
  
  console.log("x expect 42", y);
  
  exports.fresh = fresh;
  /* f Not a pure module */