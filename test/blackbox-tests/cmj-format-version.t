  $ . ./setup.sh

  $ cat > input.ml <<'EOF'
  > module Nested = struct
  >   let identity x = x
  > end
  > EOF

  $ melc $MEL_STDLIB_FLAGS --mel-stop-after-cmj input.ml

The header identifies the serialized CMJ schema.

  $ dd if=input.cmj bs=1 count=13 2>/dev/null; echo
  MelangeCMJ001

Removing the versioned magic simulates an artifact written using the previous
unversioned format. It must be rejected before unmarshalling.

  $ dd if=input.cmj of=stale.cmj bs=1 skip=13 2>/dev/null
  $ melc stale.cmj
  File "_none_", line 1:
  Error: stale.cmj has an incompatible or corrupt .cmj format; rebuild it with the current Melange compiler
  [2]

The digest catches damage to an otherwise version-compatible artifact.

  $ cp input.cmj corrupt.cmj
  $ printf x >> corrupt.cmj
  $ melc corrupt.cmj
  File "_none_", line 1:
  Error: corrupt.cmj has an incompatible or corrupt .cmj format; rebuild it with the current Melange compiler
  [2]
