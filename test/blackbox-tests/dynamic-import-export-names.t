Dynamic imports must use escaped OCaml export names while preserving literal FFI
property names. The three OCaml imports should return 42, 42, and 5.

  $ . ./setup.sh
  $ cat > target.ml <<'ML'
  > let case = 42
  > let value' = 42
  > let (+!) a b = a + b
  > ML
  $ melc --mel-package-output commonjs:.:.js --mel-package-output es6:.:.mjs -o target.js target.ml
  $ mkdir -p node_modules/foreign
  $ echo 'exports.case = 43;' > node_modules/foreign/index.js
  $ cat > input.ml <<'ML'
  > let reserved () = Js.import Target.case
  > let prime () = Js.import Target.value'
  > let operator () = Js.import Target.(+!)
  > external foreign_case : int = "case" [@@mel.module "foreign"]
  > let foreign () = Js.import foreign_case
  > ML
  $ melc -ppx melppx -I . --mel-package-output commonjs:.:.js --mel-package-output es6:.:.mjs -o input.js input.ml
  $ node --input-type=module <<'JS'
  > for (const ext of ['js', 'mjs']) {
  >   const m = await import('./input.' + ext);
  >   const op = await m.operator();
  >   console.log(ext, await m.reserved(), await m.prime(), op?.(2, 3), await m.foreign());
  > }
  > JS
  js undefined undefined undefined 43
  mjs undefined undefined undefined 43
