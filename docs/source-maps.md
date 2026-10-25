# Source maps

Pass `--mel-source-map file` to `melc` to write `<output>.js.map` and link it
from the generated JavaScript. `inline` embeds the map in the JavaScript;
`hidden` writes the sidecar without a `sourceMappingURL` comment.

```sh
melc --mel-source-map file -o app.js app.ml
node --enable-source-maps app.js
```

Maps contain source text and use relative, URI-encoded source paths. Columns
follow Source Map v3's UTF-16 convention, including Unicode before a call.
Locations preserved by the compiler identify calls and primitive expressions;
optimized-away expressions and generated scaffolding have no independent source
location. PPX and preprocessors must preserve locations to obtain useful maps.

Enable the option when compiling to `.cmj` **and** when emitting JavaScript.
Source snapshots stored with `.cmj` files preserve mapping coordinates when the
original source is unavailable during emission. Compiling without the option
keeps the existing `.cmj` format and JavaScript output. Earlier `.cmj` files can
still be loaded but do not contain the new location coverage or source snapshots.

With Dune 3.17 or later, use inline maps so that the build has no additional
undeclared sidecar target:

```lisp
(melange.emit
 (target output)
 (compile_flags :standard --mel-source-map inline))
```

For separate Melange libraries, also pass `--mel-source-map inline` through their
`melange.compile_flags`. Rebuild dependencies whose source locations are needed
for inlined code. Separate map files require a custom build rule declaring both
outputs; automatic sidecar handling in `melange.emit` is not provided here.

File and hidden maps require a named JavaScript output (`-o`). Inline maps also
work when JavaScript is printed to stdout.
