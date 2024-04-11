Test an edge of recursive modules with an inner component that is mangled

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.13)
  > (using melange 0.1)
  > EOF

  $ cat > dune <<EOF
  > (melange.emit
  >  (target out))
  > EOF

`Date` gets mangled to `$$Date` in generated JS

  $ cat > x.ml <<EOF
  > module rec X : sig
  >   module Date : sig
  >     val wow : unit -> string
  >   end
  > end = struct
  >   module Date = struct
  >     let wow () = "string"
  >   end
  > end
  > EOF

  $ dune b
  $ node _build/default/out/x.js 2>&1 | grep -v Node
  $TESTCASE_ROOT/_build/default/out/node_modules/melange.js/caml_module.js:78
          aux(match[0], o[name], n[name], o, name);
                                  ^
  
  TypeError: Cannot read properties of undefined (reading 'wow')
      at aux ($TESTCASE_ROOT/_build/default/out/node_modules/melange.js/caml_module.js:78:33)
      at Object.update_mod ($TESTCASE_ROOT/_build/default/out/node_modules/melange.js/caml_module.js:98:7)
      at Object.<anonymous> ($TESTCASE_ROOT/_build/default/out/x.js:32:13)
      at Module._compile (node:internal/modules/cjs/loader:1368:14)
      at Module._extensions..js (node:internal/modules/cjs/loader:1426:10)
      at Module.load (node:internal/modules/cjs/loader:1205:32)
      at Module._load (node:internal/modules/cjs/loader:1021:12)
      at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:142:12)
      at node:internal/main/run_main_module:28:49
  
