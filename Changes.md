Unreleased
---------------

- Update JS reserved keywords
  ([#1338](https://github.com/melange-re/melange/pull/1338))
- Remove errors for `bs.*` and non-namespaced attributes
  ([#1348](https://github.com/melange-re/melange/pull/1348))
    - These attributes haven't been supported since Melange v4, and deprecated
      before that
    - erroring on e.g. attributes like `@as` prevents e.g. universal libraries
      that want to use PPXes supporting `@as` with native semantics.
- remove `@mel.splice` error
  ([#1350](https://github.com/melange-re/melange/pull/1350))
    - `@mel.splice` has been removed in earlier Melange versions and it has
      been producing errors for the last 2 versions. Since ecosystem libraries
      have been keeping up to date with Melange versions, after this change, it
      will be silently ignored.
- allow `@mel.as "constant"` and `@mel.this` to coexist -- marking the constant
  argument as the instance / self argument
  ([#1353](https://github.com/melange-re/melange/pull/1353))
- JS generation: improve indentation of `new` blocks
  ([#1360](https://github.com/melange-re/melange/pull/1360))
- JS generation: improve indentation of blocks with array/string/char accesses
  ([#1361](https://github.com/melange-re/melange/pull/1361))
- runtime: improve the runtime for exceptions / extensible variants to account
  for sharing extensions across contexts
  ([#1326](https://github.com/melange-re/melange/pull/1326))
    - This change moves the exception runtime from a global counter to a
      counter _per module_. This impacts calls to `Printexc.exn_slot_id` and
      `Printexc.exn_slot_name`, which would previously return the global
      identifier at exception creation, and will now return the module-local
      runtime identifier.

5.0.1-414 2025-02-23
---------------

- Fix `[@mel.send]` and `[@mel.this]` interaction in the presence of constant
  `[@mel.as ".."]` arguments
  ([#1328](https://github.com/melange-re/melange/pull/1328))
- Allow skipping over `[@mel.as ".."]` constant arguments in `[@mel.send]` in
  the absence of `@mel.this`
  ([#1328](https://github.com/melange-re/melange/pull/1328))
- core: fix missed function argument fusion optimization on OCaml versions 5.2
  and above, caused by [ocaml/ocaml#12236](https://github.com/ocaml/ocaml/pull/12236) generating
  multiple function nodes for `fun a -> fun b -> ...` in the Lambda IR. This
  issue, while partially fixed in Melange 5.0.0, didn't account for default
  arguments ([#1253](https://github.com/melange-re/melange/issues/1253),
  [#1334](https://github.com/melange-re/melange/issues/1334)).

5.0.0-414 2025-02-09
---------------

- Make the `unprocessed` alert fatal by default
  ([#1135](https://github.com/melange-re/melange/pull/1135))
- support `-H` for hidden include dirs in OCaml 5.2
  ([#1137](https://github.com/melange-re/melange/pull/1137))
- support `[@mel.*]` attributes in uncurried externals
  ([#1140](https://github.com/melange-re/melange/pull/1140))
- add Worker types to `melange.dom`
  ([#1147](https://github.com/melange-re/melange/pull/1147))
- Add support for dynamic `import()`
  ([#1164](https://github.com/melange-re/melange/pull/1164))
- Fix code generation of custom `true` / `false` constructors
  ([#1175](https://github.com/melange-re/melange/pull/1175))
- Fix code generation of OCaml objects that refers to an init variable in scope
  ([#1183](https://github.com/melange-re/melange/pull/1183))
- Support `[@mel.as "string"]` in variant definitions
  ([#884](https://github.com/melange-re/melange/pull/884))
- BREAKING: remove `[@@deriving jsConverter]` for variant definitions
  ([#884](https://github.com/melange-re/melange/pull/884)). Use `[@mel.as
  "string here"]` instead.
- Support OCaml 5.3 ([#1168](https://github.com/melange-re/melange/pull/1168))
- Upgrade Stdlib to the OCaml 5.3 Stdlib
  ([#1182](https://github.com/melange-re/melange/pull/1182))
- Support `[@mel.tag "the_tag"]` in variant definitions
  ([#1189](https://github.com/melange-re/melange/pull/1189))
  - combined with `[@mel.as ..]` in variant definitions and inline record
    payloads, Melange can now express types for discriminated union object
    shapes.
- melange-ppx: don't silence warning 20 (`ignored-extra-argument`) for
  `%mel.raw` application
  ([#1166](https://github.com/melange-re/melange/pull/1166)).
  - This change reverts the behavior introduced in
    ([#915](https://github.com/melange-re/melange/pull/915)).
  - The new recommendation is to annotate `%mel.raw` functions or disable
    warning 20 at the project level.
- ppx,core: propagate internal FFI information via attributes instead of adding
  marshalled data in the native primitive name
  ([#1222](https://github.com/melange-re/melange/pull/1222))
- melange-ppx: allow `@mel.unwrap` polyvariants not to have a payload
  ([#1239](https://github.com/melange-re/melange/pull/1239))
- `melange.node`: fix `Buffer.fromString` and add
  `Buffer.fromStringWithEncoding`
  ([#1246](https://github.com/melange-re/melange/pull/1246))
- `melange.node`: bind to all supported Node.js `Buffer` encodings in
  `Node.Buffer` ([#1246](https://github.com/melange-re/melange/pull/1246))
- `melange.js`: Add `Js.FormData` with bindings to the
  [FormData](https://developer.mozilla.org/en-US/docs/Web/API/FormData) API
  ([#1153](https://github.com/melange-re/melange/pull/1153),
  [#1270](https://github.com/melange-re/melange/pull/1270),
  [#1281](https://github.com/melange-re/melange/pull/1281)
- `melange.js`: Add `Js.Blob` and `Js.File` with bindings to the
  [Blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob) and
  [File](https://developer.mozilla.org/en-US/docs/Web/API/File) APIs
  ([#1218](https://github.com/melange-re/melange/pull/1218))
- `melange.js`: add `TypedArray` types at the toplevel in the `Js` module
  ([#1248](https://github.com/melange-re/melange/pull/1248))
- BREAKING: remove `--mel-g`
  ([#1234](https://github.com/melange-re/melange/pull/1234))
- runtime(`melange.js`): port `[@mel.send.pipe]` functions to `[@mel.send]`,
  taking advantage of the `@mel.send` + labeled argument improvement (see
  above) ([#1260](https://github.com/melange-re/melange/pull/1260),
  [#1264](https://github.com/melange-re/melange/pull/1264),
  [#1265](https://github.com/melange-re/melange/pull/1265),
  [#1266](https://github.com/melange-re/melange/pull/1266),
  [#1280](https://github.com/melange-re/melange/pull/1280),
  [#1278](https://github.com/melange-re/melange/pull/1278))
- core: fix a crash related to finding constructor names in pattern matching triggered by dune's earlier implementation of `(implicit_transitive_deps false)`
  ([#1238](https://github.com/melange-re/melange/pull/1238),
  [#1262](https://github.com/melange-re/melange/pull/1262))
- core: pre-compute the closure param map for functions inlined with
  `--mel-cross-module-opt`
  ([#1219](https://github.com/melange-re/melange/pull/1219))
- BREAKING: ppx: print the `deprecated` alert for `@@deriving abstract` at the
  declaration site rather than at (all) usages
  ([#1269](https://github.com/melange-re/melange/pull/1269))
- JS generation: prettify `for` loops
  ([#1275](https://github.com/melange-re/melange/pull/1275))
- JS generation: improve formatting for `throw` and `return` statements, JS
  objects ([#1286](https://github.com/melange-re/melange/pull/1286),
  [#1289](https://github.com/melange-re/melange/pull/1289))
- JS generation: improve formatting for empty return and continue statements
  ([#1288](https://github.com/melange-re/melange/pull/1288))
- JS generation: remove trailing spaces before commas in `export`
  ([#1287](https://github.com/melange-re/melange/pull/1287))
- JS generation: remove redundant switch cases branches
  ([#1295](https://github.com/melange-re/melange/pull/1295))
- JS generation: move space before comma inside `for` definition
  ([#1296](https://github.com/melange-re/melange/pull/1296))
- JS generation: add space before while loop condition
  ([#1297](https://github.com/melange-re/melange/pull/1297))
- JS generation: improve indentation of parenthesized blocks
  ([#1293](https://github.com/melange-re/melange/pull/1293))
- JS generation: add space after constructor comments
  ([#1294](https://github.com/melange-re/melange/pull/1294))
- JS generation: improve identation of `switch` cases
  ([#1299](https://github.com/melange-re/melange/pull/1299))
- JS generation: don't generate empty `default:` cases in `switch`
  ([#1300](https://github.com/melange-re/melange/pull/1300))
- JS generation: emit `module.exports` in CommonJS instead of `exports.x`
  ([#1314](https://github.com/melange-re/melange/pull/1314))
- JS generation: remove trailing newline after `switch`
  ([#1313](https://github.com/melange-re/melange/pull/1313))
- ffi: allow annotating `@mel.send` FFI with `@mel.this` to specify which
  parameter should represent the "self" argument.
  ([#1303](https://github.com/melange-re/melange/pull/1285),
  [#1310](https://github.com/melange-re/melange/pull/1310))
  - This improvement to the FFI allows expressing more FFI constructs via
    labeled and optionally labeled arguments, e.g. `external foo: value:string
    -> (t [@mel.this]) -> unit = "foo" [@@mel.send]` will now produce
    `t.foo(value)` instead of `value.foo(t)`.
  - It also allows removing usages of `[@mel.send.pipe: t]` in favor of
    `[@mel.send]` with `[@mel.this]`, including when used with `@mel.variadic`.
- ppx: deprecate `[@mel.send.pipe]`
  ([#1321](https://github.com/melange-re/melange/pull/1321))
- core: fix missed optimization on OCaml versions 5.2 and above, caused by
  [ocaml/ocaml#12236](https://github.com/ocaml/ocaml/pull/12236) generating
  multiple function nodes for `fun a -> fun b -> ...` in the Lambda IR
  ([#1253](https://github.com/melange-re/melange/issues/1253),
   [#1323](https://github.com/melange-re/melange/issues/1323)).

4.0.1 2024-06-07
---------------

- Support `-bin-annot-occurrences` on OCaml 5.2
  ([#1132](https://github.com/melange-re/melange/pull/1132))

4.0.0 2024-05-15
---------------

- CLI: passing `--eval` to `melc` now works as expected
  ([#1040](https://github.com/melange-re/melange/pull/1040))
- runtime: add some bindings to `Js.Bigint`
  ([#1044](https://github.com/melange-re/melange/pull/1044))
- core: emit `throw new Error(..)` rather than throwing a JS object with the
  Melange exception payload
  ([#1036](https://github.com/melange-re/melange/pull/1036))
- stdlib: fix runtime primitive for `Float.{min,max}` and related functions
  ([#1050](https://github.com/melange-re/melange/pull/1050))
- core: emit `let` instead of `var` in compiled JS
  ([#1019](https://github.com/melange-re/melange/pull/1019))
- core: in compiled JS, stop generating closures in loops that capture mutable
  variables ([#1020](https://github.com/melange-re/melange/pull/1020))
- runtime: add bindings to `Js.Set`
  ([#1047](https://github.com/melange-re/melange/pull/1047))
- runtime: add minimal bindings for JS iterators ([#1060](https://github.com/melange-re/melange/pull/1060))
- core: in compiled JS, emit `const` for variables that Melange knows aren't
  going to be reassigned
  ([#1019](https://github.com/melange-re/melange/pull/1019),
  [#1059](https://github.com/melange-re/melange/pull/1059)).
- runtime: add minimal bindings for JS iterators
  ([#1060](https://github.com/melange-re/melange/pull/1060))
- core: handle missing `.cmj` when compiling dune virtual libraries
  ([#1067](https://github.com/melange-re/melange/pull/1067), fixes
  [#658](https://github.com/melange-re/melange/issues/658))
- core: print lambda IR after TRMC pass when `--drawlambda` is passed
  ([#1072](https://github.com/melange-re/melange/pull/1072))
- core: remove unnecessary internal code from melange-compiler-libs, slimming
  down the melange executable and speeding up the build
  ([#1075](https://github.com/melange-re/melange/pull/1075))
- core: implement warning 51 in Melange (`wrong-tailcall-expectation`)
    - This warning had previously been disabled entirely in the typechecker
      version that Melange uses. It becomes more important with TRMC support
      added in Melange 2.1.0.
- core: accept `esm{,-global}` in addition to `es6{,-global}` for
  `--mel-module-type`; accept `--mel-module-system` in addition to
  `--mel-module-type` too
  ([#1086](https://github.com/melange-re/melange/pull/1086)).
- core: upgrade the OCaml type checker version to OCaml 5.2
  ([#1074](https://github.com/melange-re/melange/pull/1074))
- core: upgrade the Stdlib to match OCaml 5.2's
  ([#1078](https://github.com/melange-re/melange/pull/1078))
- runtime: add bindings for functions in `WeakMap` and `WeakSet`
  ([#1058](https://github.com/melange-re/melange/pull/1058))
- runtime: add bindings to `Js.Map`
  ([#1101](https://github.com/melange-re/melange/pull/1101))
- core: fix a recursive module code generation bug when submodule names inside
  recursive modules are mangled
  ([#1111](https://github.com/melange-re/melange/pull/1111))

3.0.0 2024-01-28
---------------

- BREAKING: remove `Belt` as a dependency of `Stdlib`
  ([#796](https://github.com/melange-re/melange/pull/796),
  [#797](https://github.com/melange-re/melange/pull/797))
  - Melange no longer includes the `melange.belt` library by default; after
    this release, you need to add `(libraries melange.belt)` to your melange
    stanzas.
- Melange Runtime / Stdlib: remove deprecated modules and functions
  ([#817](https://github.com/melange-re/melange/pull/817)):
    - `Js.List`: use `Stdlib.List` or `Belt.List` instead;
    - `Js.Null_undefined`: use `Js.Nullable` instead;
    - `Js.Option`: use `Stdlib.Option` or `Belt.Option` instead;
    - `Js.Result`: use `Stdlib.Result` or `Belt.Result` instead;
    - `Js.Cast`.
- BREAKING:
    - remove support for `@bs` / `@bs.*` attributes; Melange users should now
      use `[@u]` for uncurried application and `[@mel.*]` as the prefix for the
      FFI attributes ([#818](https://github.com/melange-re/melange/pull/818))
    - remove `[@@mel.val]`, which was redundant in the Melange FFI
      ([#818](https://github.com/melange-re/melange/pull/818))
- BREAKING(runtime): rename a few keys with legacy names
  ([#819](https://github.com/melange-re/melange/pull/819)):
    1. Exception ID `RE_EXN_ID` to `MEL_EXN_ID`
    2. `BS_PRIVATE_NESTED_SOME_NONE` option marker to
       `MEL_PRIVATE_NESTED_SOME_NONE`
- BREAKING(runtime): unify pipe-first / pipe-last libraries in `Js` modules
  ([#731](https://github.com/melange-re/melange/issues/731),
  [#893](https://github.com/melange-re/melange/pull/893),
  [#895](https://github.com/melange-re/melange/pull/895),
  [#899](https://github.com/melange-re/melange/pull/899),
  [#963](https://github.com/melange-re/melange/pull/963),
  [#964](https://github.com/melange-re/melange/pull/964),
  [#965](https://github.com/melange-re/melange/pull/965))
    - Modules ending with `2` (e.g. `Js.String2`, `Js.Array2`,
      `Js.TypedArray2`) are no longer available in Melange
    - The functions in their corresponding modules now take labeled arguments
      and one positional argument, prioritizing the usage of `|>` but still
      allowing `|.` (`->` in Reason) when optionally labeled arguments aren't
      omitted.
- BREAKING(runtime): remove deprecated functions from `Js.*` modules
  ([#897](https://github.com/melange-re/melange/pull/897))
- Consistently handle empty payloads in externals:
  ([#852](https://github.com/melange-re/melange/pull/852))
- Fix crash when pattern matching in the presence of complex constant inlining
  ([#871](https://github.com/melange-re/melange/pull/871))
- Support renaming modules in the output JS with `@mel.as`
  ([#879](https://github.com/melange-re/melange/pull/879))
- Support `@mel.as` in `@mel.obj` labelled arguments
  ([#834](https://github.com/melange-re/melange/pull/834))
- Fix error location for empty string interpolation in `{j| .. |j}`
  ([#888](https://github.com/melange-re/melange/pull/888),
  [#890](https://github.com/melange-re/melange/pull/890))
- Add `Js.Obj.assign` to merge 2 JS objects immutably
  ([#900](https://github.com/melange-re/melange/pull/900),
  [#795](https://github.com/melange-re/melange/pull/795))
- Turn off warning 20 (`ignored-extra-argument`) for `%mel.raw` application
  ([#915](https://github.com/melange-re/melange/pull/915))
- Deprecate non-namespaced FFI attributes such as `@string` or `@obj` in favor
  of e.g. `@mel.string` and `@mel.obj`
  ([#923](https://github.com/melange-re/melange/pull/923))
- Improve error messages returned by `melange.ppx`
  ([#924](https://github.com/melange-re/melange/pull/924),
  [#928](https://github.com/melange-re/melange/pull/928),
  [#931](https://github.com/melange-re/melange/pull/931),
  [#936](https://github.com/melange-re/melange/pull/936))
- Improve error messages in the Melange compiler core
  ([#941](https://github.com/melange-re/melange/pull/941))
- Fix a typo in `Node.node_module` (pa{r,}rent)
  [#929](https://github.com/melange-re/melange/pull/929)
- BREAKING(runtime): Remove `Js.null_undefined` in favor of `Js.nullable`
  ([#930](https://github.com/melange-re/melange/pull/930))
- BREAKING(ppx): disallow attribute payload in `[@mel.new]` in favor of the
  external primitive string
  ([#938](https://github.com/melange-re/melange/pull/938))
- FFI: support `@mel.new` alongisde `@mel.send` / `@mel.send.pipe`
  ([#906](https://github.com/melange-re/melange/pull/906))
- Don't process `[@mel.config]` twice
  ([#940](https://github.com/melange-re/melange/pull/940/))
- BREAKING(ppx): remove `@mel.splice` in favor of `@mel.variadic`
  ([#943](https://github.com/melange-re/melange/pull/943))
- Introduce an `unprocessed` alert to detect unprocessed Melange code, hinting
  users to preprocess with `melange.ppx`
  ([#911](https://github.com/melange-re/melange/pull/911),
  [#945](https://github.com/melange-re/melange/pull/945),
  [#947](https://github.com/melange-re/melange/pull/947))
- Implement more Stdlib functions in modules String, Bytes, Buffer, BytesLabels
  and StringLabels ([#711](https://github.com/melange-re/melange/pull/711),
  [#956](https://github.com/melange-re/melange/pull/956),
  [#958](https://github.com/melange-re/melange/pull/958),
  [#961](https://github.com/melange-re/melange/pull/961))
- BREAKING(runtime): Improve `Js.Int` and change some of its functions to
  pipe-last ([#966](https://github.com/melange-re/melange/pull/966))
- BREAKING(runtime): Improve `Js.Date` and change some of its functions to
  pipe-last ([#967](https://github.com/melange-re/melange/pull/967))
- BREAKING(runtime): Improve `Js.Re` and change some of its functions to
  pipe-last ([#969](https://github.com/melange-re/melange/pull/969),
  [#989](https://github.com/melange-re/melange/pull/989))
- BREAKING(runtime): Improve docstrings in the `Node` library and change some
  of its functions to pipe-last
  ([#970](https://github.com/melange-re/melange/pull/970))
- BREAKING(runtime): Improve `Js.Float` and change some of its functions to
  pipe-last ([#968](https://github.com/melange-re/melange/pull/968))
- BREAKING(runtime): Remove unnecessary `unit` argument from `Js.Math.atan2`
  ([#972](https://github.com/melange-re/melange/pull/972))
- BREAKING(runtime): Add labeled arguments to the callbacks in `Js.Global`
  ([#973](https://github.com/melange-re/melange/pull/973))
- BREAKING(runtime): Add a label to `Js.Dict.map`'s function argument pipe-last
  ([#974](https://github.com/melange-re/melange/pull/974))
- runtime(`Js.String`): deprecate `anchor`, `link` and `substr` functions to
  match the JS standard deprecations
  [#982](https://github.com/melange-re/melange/pull/982)
- Fix error messages related to `[@mel.meth]` arity mismatches
  ([PR](https://github.com/melange-re/melange/pull/986))
- ppx: split `[@@deriving abstract]` into two
  ([#987](https://github.com/melange-re/melange/pull/987)):
    - `[@@deriving jsProperties]` derives a JS object creation function that
      can generate a JS object with optional keys (when using `[@mel.optiona]`)
    - `[@@deriving getSet]` derives getter / setter functions for the JS object
       derived by the underlying record.
- ppx: Deprecate `[@@deriving abstract]`
  ([#979](https://github.com/melange-re/melange/pull/979))
- BREAKING(dom): remove `Dom.Storage2` in favor of `Dom.Storage`
  ([988](https://github.com/melange-re/melange/pull/988))
- playground: fix reporting of PPX alerts
  ([#991](https://github.com/melange-re/melange/pull/991))
- Move the unicode string transformation to the compiler core so that it runs
  after PPX preprocessing
  ([#995](https://github.com/melange-re/melange/pull/995),
  [#1037](https://github.com/melange-re/melange/pull/1037))
    - PPXes will no longer see the internal `*j` delimiter in unicode strings
      and can hook on either `j` or `js`
- Preserve unicode in format strings
  ([#1001](https://github.com/melange-re/melange/pull/1001))
- Support `@mel.as` in `%mel.obj`
  ([#1004](https://github.com/melange-re/melange/pull/1004))
- Upgrade the Melange JS parser to [Flow
  v0.225.1](https://github.com/facebook/flow/releases/tag/v0.225.1)
  ([#1012](https://github.com/melange-re/melange/pull/1012))
- fix: add a newline after `%mel.raw` expressions to avoid breaking JS output
  when they contain single line comments
  ([#1017](https://github.com/melange-re/melange/pull/1017))
- BREAKING(core): only allow strings in `{j| ... |j}` interpolation
  ([#1024](https://github.com/melange-re/melange/pull/1024))

2.2.0 2023-12-05
---------------

- BREAKING(core): require OCaml 5.1.1
  ([#926](https://github.com/melange-re/melange/pull/926))

2.1.0 2023-10-22
---------------

- Add TRMC (Tail Recursion Modulo Cons) support
  ([#743](https://github.com/melange-re/melange/pull/743))
- [playground]: Add `melange.dom` to bundle
  ([#779](https://github.com/melange-re/melange/pull/779))
- Fix `Sys.argv` runtime to match declared type
  ([#791](https://github.com/melange-re/melange/pull/791))
- Make `'a Js.t` abstract (again), fixing a regression when bringing back
  OCaml-style objects BuckleScript
  ([#786](https://github.com/melange-re/melange/pull/786))
- Don't issue "unused attribute" warning for well-formed `@@@mel.config` in
  interface files ([#800](https://github.com/melange-re/melange/pull/800))
- Stop showing `Js__.Js_internal` in types and error messages
  ([#798](https://github.com/melange-re/melange/pull/798))
- Fix printing of OCaml-style objects and uncurried application
  ([#807](https://github.com/melange-re/melange/pull/807))

2.0.0 2023-09-13
---------------

- Build executables for bytecode-only platforms too
  ([#596](https://github.com/melange-re/melange/pull/596))
- Move the entire builtin PPX to `melange.ppx`. Preprocessing with
  `melange.ppx` will needed in most cases going forward, as it's responsible
  for processing `external` declarations, `@deriving` attributes and more,
  compared to the previous release where `melange.ppx` just processed AST
  extension nodes ([#583](https://github.com/melange-re/melange/pull/583))
- Remove old BuckleScript-style conditional compilation
  ([#605](https://github.com/melange-re/melange/pull/605))
- Don't emit JS import / require paths with `foo/./bar.js`
  ([#598](https://github.com/melange-re/melange/issues/598),
  [#612](https://github.com/melange-re/melange/pull/612))
- Wrap the melange runtime
  ([#624](https://github.com/melange-re/melange/pull/624),
  [#637](https://github.com/melange-re/melange/pull/637)). After this change,
  Melange exposes fewer toplevel modules. Melange runtime / stdlib modules are
  now wrapped under:
    - `Caml*` / `Curry` modules are part of the runtime and keep being exposed
      as before
    - `Js.*` contains all the modules previously accessible via `Js_*`, e.g.
      `Js_int` -> `Js.Int`
    - `Belt.*` wraps all the `Belt` modules; `Belt_List` etc. are not exposed
      anymore, but rather nested under `Belt`, e.g. `Belt.List`
    - `Node.*`: we now ship a `melange.node` library that includes the modules
      containing Node.js bindings. After this change, users will have to depend
      on `melange.node` explicitly in order to use the `Node.*` modules
    - `Dom.*`: we now ship a `melange.dom` library that includes the modules
      containing Node.js bindings. This library is included by default so the
      `Dom` module will always be available in Melange projects.
- Disable warning 61 (`unboxable-type-in-prim-decl`) for externals generated by
  Melange ([#641](https://github.com/melange-re/melange/pull/641),
  [#643](https://github.com/melange-re/melange/pull/643))
- Add `--rectypes` ([#644](https://github.com/melange-re/melange/pull/644)) to
  enable [recursive
  types](https://v2.ocaml.org/releases/5.0/htmlman/types.html#sss:typexpr-aliased-recursive)
- [melange.ppx]: Deprecate `bs.*` attributes in favor of `mel.*`
  ([#566](https://github.com/melange-re/melange/issues/566),
  [#662](https://github.com/melange-re/melange/pull/662),
  [#663](https://github.com/melange-re/melange/pull/663))
- [melange]: Fix field access code generation when `open`in inline functor
  applications ([#661](https://github.com/melange-re/melange/pull/661),
  [#664](https://github.com/melange-re/melange/pull/664))
- [melange]: Upgrade the OCaml typechecker version to 5.1
  ([#668](https://github.com/melange-re/melange/pull/668))
- [melange.ppx]: Deprecate `[@@mel.val]` and suggest its removal. This
  attribute is redundant and unnecessary
  ([#675](https://github.com/melange-re/melange/issues/675),
  [#678](https://github.com/melange-re/melange/pull/678))
- [melange]: remove old, unused CLI flags: `-bs-ns`, `-bs-cmi`, `-bs-cmj`,
  `-bs-no-builtin-ppx`, `-bs-super-errors`
  ([#686](https://github.com/melange-re/melange/pull/686)).
- [melange]: generate correct code for types with the `option` shape
  ([#700](https://github.com/melange-re/melange/pull/700)).
- [melange]: stop exporting `$$default` in the generated JavaScript when using
  ES6 default exports `let default = ..`
  ([#708](https://github.com/melange-re/melange/pull/708)).
- [melange]: allow exporting invalid OCaml identifiers in the resulting
  JavaScript with `@mel.as`
  ([#714](https://github.com/melange-re/melange/pull/714), fixes
  [#713](https://github.com/melange-re/melange/pull/713)).
- [melange]: Allow using `@mel.as` in external declarations without explicitly
  annotating `@mel.{string,int}`
  ([#722](https://github.com/melange-re/melange/pull/722), fixes
  [#578](https://github.com/melange-re/melange/issues/578)).
- [melange]: Allow using `@mel.unwrap` in external declarations with `@mel.obj`
  ([#724](https://github.com/melange-re/melange/pull/724), fixes
  [#679](https://github.com/melange-re/melange/issues/679)).
- [melange]: Support renaming fields in inline records / record extensions with
  `@mel.as` ([#732](https://github.com/melange-re/melange/pull/732), fixes
  [#730](https://github.com/melange-re/melange/issues/730)).

1.0.0 2023-05-31
---------------

- melange: print an error message if `$MELANGELIB` is set to a directory that
  doesn't exist ([#449](https://github.com/melange-re/melange/pull/449))
- melange: fix bug where `--bs-module-name` didn't always affect generated JS
  file casing ([#446](https://github.com/melange-re/melange/pull/446))
- melange: fix bug where `-o output.js` didn't always write a JavaScript file
  ([#454](https://github.com/melange-re/melange/pull/454))
- melange: remove the `-bs-read-cmi` flag in favor of the builtin
  `-intf-suffix` flag, standard in OCaml
  ([#458](https://github.com/melange-re/melange/pull/458),
  [#460](https://github.com/melange-re/melange/pull/460))
- melange: return an actionable error message when no output is specified
  with `-impl` / `-intf`
  ([#465](https://github.com/melange-re/melange/pull/465),
  [#466](https://github.com/melange-re/melange/pull/466))
- melange: use `Object.prototype.hasOwnProperty` in the `Caml_obj` runtime
  ([#469](https://github.com/melange-re/melange/pull/469))
- melange: transform
  [`NonEscapeCharacter`](https://tc39.es/ecma262/#prod-NonEscapeCharacter)
  correctly in JS strings (those written using `{js|string here|js}`)
  ([#469](https://github.com/melange-re/melange/pull/469))
- melange: define `MELANGE` conditional compilation variable
  ([#472](https://github.com/melange-re/melange/pull/472))
- melange: Make `Pervasives` exactly match the `Stdlib` behavior
  ([#476](https://github.com/melange-re/melange/pull/476))
- melange: fix unbound error when trying to use `Printexc.exn_slot_id`
  ([#482](https://github.com/melange-re/melange/pull/482))
- melange: fix codegen issue accessing a nested module path that is also
  `include`d ([#487](https://github.com/melange-re/melange/pull/487))
- melange: preserve the correct command-line order for load path directories
  ([#492](https://github.com/melange-re/melange/pull/492))
- melange: respect the `-nostdlib` option; don't add stdlib / runtime to the
  load path in that case
  ([#496](https://github.com/melange-re/melange/pull/496))
- melange: build the Melange runtime / stdlib / runtime tests with the dune
  integration ([#493](https://github.com/melange-re/melange/pull/493)). Thus
  melange now requires Dune 3.8.
- melange: allow shadowing sub-modules of Stdlib in user projects
  ([#512](https://github.com/melange-re/melange/pull/512))
- melange, reactjs-jsx-ppx: introduce a `reactjs-jsx-ppx` package, remove its
  dependency from melange
  ([#517](https://github.com/melange-re/melange/pull/517))
- melange: remove the `--bs-jsx <version>` flag from `melc` now that
  `reactjs-jsx-ppx` is a separate package
  ([#525](https://github.com/melange-re/melange/pull/525))
- melange: add `melpp` executable to preprocess `#if` conditionals with the
  melange parser ([#539](https://github.com/melange-re/melange/pull/539))
- mel: delete the `mel` package. The dune integration is now the only
  officially supported workflow for orchestrating melange builds
  ([#546](https://github.com/melange-re/melange/pull/546))
- melange: Extract `melange.ppx` from the melange package. This preprocessing
  step interprets extensions such as `%bs.obj`, `%bs.raw` and `%bs.re`,
  `[@@deriving {abstract,accessors,jsConverters}]` and `external` declarations.
  ([#534](https://github.com/melange-re/melange/pull/534))
- melange: allow installing melange in more OCaml versions and compiler
  switches. Melange now migrates binary AST to the version it understands
  ([#548](https://github.com/melange-re/melange/pull/548))
- melange: don't run anonymous args function from
  `[@@@bs.config {flags = [| ... |]}]` attributes
  ([#554](https://github.com/melange-re/melange/pull/554))
- melange: add `--preamble` flag to add a preamble to emitted JS. An example is
  `"use client";` in React Server Components, which needs to appear before
  imports ([#545](https://github.com/melange-re/melange/pull/545),
  [#574](https://github.com/melange-re/melange/pull/574))
- melange: turn off warning 20 (`ignore-extra-argument`) by default. This
  warning is rarely useful in Melange due to false positives when invoking
  functions defined with `%bs.raw`
  ([#488](https://github.com/melange-re/melange/pull/488),
  [#576](https://github.com/melange-re/melange/pull/576))

0.3.2 2022-11-19
---------------

- `ppx_rescript_compat` (ReScript compatibility layer): fix conversion for
  cases such as `foo["bar"] = assignment`
  ([#441](https://github.com/melange-re/melange/pull/441)):
  - These are now correctly converted to the OCaml equivalent:
    `foo##bar #= assignment`
- mel: fix merlin generation, broken since `mel` was moved to its own package
  ([#442](https://github.com/melange-re/melange/pull/442))

0.3.1 2022-11-16
---------------

- Disable warning 69 (`unused-field` in record) for the private record
  generated by the `bs.deriving` attribute
  ([#414](https://github.com/melange-re/melange/pull/414))
- Disable warning 20 (`ignored-extra-argument`) when applying
  `foo##fn arg1 arg2`
  ([#416](https://github.com/melange-re/melange/pull/416)):
  - in cases such as `external x : < .. > Js.t = ""`, the typechecker doesn't
    know the arity of the function, even though Melange will emit an uncurried
    function call.
- Disable warning 61 (`unboxable-type-in-prim-decl`) in `external` declarations
  ([#415](https://github.com/melange-re/melange/pull/415)):
  - Melange externals are substantially different from OCaml externals. This
    warning doesn't make sense in a JS runtime.
- melc: introduce `--bs-module-name` flag to specify the original file name for
  the current compilation unit
  ([#413](https://github.com/melange-re/melange/pull/413))
  - Dune's namespacing implementation generates modules such as
    `lib__Original_name`. Passing `--bs-module-name original_name` allows
    melange to issue correct `import` / `require` statements to the unmangled
    JS file names.

0.3.0 2022-11-06
---------------

- melange Introduce 2 explicit modes of JavaScript compilation:
  - "Batch compilation": produces `.cmj` and `.js` files at the same time (this
    is the previous behavior -- using `--bs-package-output
    MODULE_SYSTEM:REL_PATH:JS_EXTENSION`)
  - "Separate emission": produces _only_ `.cmj` files with `--bs-stop-after-cmj
    --bs-package-output REL_PATH_ONLY`, and allows emitting JavaScript files
    separately, with `--bs-module-type MODULE_SYSTEM -o
    TARGET_FILE.JS_EXTENSION`
  ([#384](https://github.com/melange-re/melange/pull/384))
- mel: Fix `mel build --watch` exiting after the first change
  ([#401](https://github.com/melange-re/melange/pull/401))
- melange: Remove dependency on `reason`. Reason syntax users should install`
  reason` from their preferred package manager instead, and Melange / Dune will
  find it in `$PATH` ([#409](https://github.com/melange-re/melange/pull/409))
- melange: Remove dependency on `napkin` (the ReScript syntax parser). Users
  that depend on libraries written in ReScript syntax should install the `mel`
  package and Melange / Dune will find the `rescript_syntax` binary in `$PATH`
  ([#411](https://github.com/melange-re/melange/pull/411))

0.2.0 2022-10-24
--------------

- Initial release supporting OCaml 4.14.

0.1.0 2022-03-08
--------------

- Initial public release

This is the only release of Melange that supports OCaml 4.12.

