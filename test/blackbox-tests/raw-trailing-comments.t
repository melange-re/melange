Trailing line comments must not swallow syntax following raw expressions.

  $ . ./setup.sh
  $ cat > safe.ml <<'EOF'
  > let f : int -> int = [%mel.raw {|x => x + 1 // add one|}]
  > let value : int = [%mel.raw {|1 + 2 // sum|}]
  > let multiline : int = [%mel.raw {|1 +
  > 2
  > // final comment|}]
  > let nested : int = [%mel.raw {|(1 + 2 // inside
  > )|}]
  > let literal : int = [%mel.raw {|3 // literal|}]
  > let fn : int -> int = [%mel.raw {|function(x) { return x + 1; } // function|}]
  > let results () = [|f 1; value; multiline; nested; literal; fn 1|]
  > EOF
  $ melc --color=never -ppx melppx -o safe.js safe.ml
  $ node --check safe.js
  $ node -e "console.log(...require('./safe.js').results())"
  2 3 3 3 3 2
  $ cat > input.ml <<'EOF'
  > let () =
  >   Js.log ([%mel.raw {|3 // number|}] : int);
  >   Js.log ([%mel.raw {|"ok" // string|}] : string);
  >   Js.log ([%mel.raw {|undefined // undefined|}] : unit);
  >   Js.log ([%mel.raw {|{x: 1} // object|}] : < x : int > Js.t);
  >   Js.log ([%mel.raw {|[1, 2] // array|}] : int array)
  > EOF
  $ melc --color=never -ppx melppx -o input.js input.ml
  $ node <<'EOF'
  > try { require('./input.js'); }
  > catch (error) { if (!(error instanceof SyntaxError)) throw error; console.log(error.name); }
  > EOF
  SyntaxError
