Melange can add compiler phases and artifact sizes to Dune's action trace.
Tracing is opt-in, so normal compiler invocations avoid event construction.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.24)
  > (using melange 1.0)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target output)
  >  (emit_stdlib false)
  >  (module_systems (commonjs cjs) (esm mjs))
  >  (compile_flags :standard --mel-action-trace))
  > EOF
  $ cat > main.ml <<'EOF'
  > let identity x = x
  > let answer = identity 42
  > EOF

  $ dune build --trace-file=trace.csexp @melange
  $ dune trace cat --trace-file=trace.csexp --chrome-trace > trace.json

The event names are deliberately stable; timestamps and durations are not.

  $ jq -r '
  >   [(if type == "array" then . else .traceEvents end)[]
  >    | select(.cat | startswith("melange."))
  >    | [.cat, .name]
  >    | @tsv]
  >   | unique | sort | .[]' trace.json
  melange.artifact	cmj
  melange.artifact	javascript
  melange.frontend	builtin-ppx
  melange.frontend	parse
  melange.frontend	ppx
  melange.frontend	typecheck
  melange.io	cmj-read
  melange.io	cmj-write
  melange.io	js-print
  melange.js	dependencies
  melange.js	flatten
  melange.js	flatten-and-mark-dead
  melange.js	optimize
  melange.js	scope
  melange.js	shake
  melange.js	tailcall-inline
  melange.lambda	convert
  melange.lambda	optimize
  melange.lambda	to-js
  melange.lambda	translate

One delayed CMJ is optimized independently for both requested module systems.
This count makes that cost visible in benchmark traces.

  $ jq '[(if type == "array" then . else .traceEvents end)[] | select(.cat == "melange.js" and .name == "optimize")] | length' trace.json
  2

The Dune-provided rule digest lets consumers attribute every optimizer span to
the JavaScript emission actions rather than the CMJ action.

  $ jq -e '
  >   (if type == "array" then . else .traceEvents end) as $events
  >   | [$events[]
  >      | select(.cat == "melange.artifact" and .name == "javascript")
  >      | .args.digest] as $javascript_rules
  >   | [$events[]
  >      | select(.cat == "melange.js" and .name == "optimize")
  >      | .args.digest] as $optimizer_rules
  >   | all($optimizer_rules[]; . as $digest
  >       | $javascript_rules | index($digest) != null)' trace.json >/dev/null

Artifact events expose machine-readable byte counts and all spans are complete.

  $ jq -e '
  >   ([(if type == "array" then . else .traceEvents end)[]
  >     | select(.cat == "melange.artifact")
  >     | .args.bytes
  >     | tonumber] | length == 3)
  >   and
  >   ([(if type == "array" then . else .traceEvents end)[]
  >     | select(.cat | startswith("melange."))
  >     | select(.ph == "X")
  >     | .dur >= 0] | all)' trace.json >/dev/null

Without the compiler flag, the same traced Dune build contains no Melange
custom events.

  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target output)
  >  (emit_stdlib false)
  >  (module_systems (commonjs cjs) (esm mjs)))
  > EOF
  $ dune clean
  $ dune build --trace-file=unannotated.csexp @melange
  $ dune trace cat --trace-file=unannotated.csexp --chrome-trace > unannotated.json
  $ jq '[(if type == "array" then . else .traceEvents end)[] | select(.cat | startswith("melange."))] | length' unannotated.json
  0
