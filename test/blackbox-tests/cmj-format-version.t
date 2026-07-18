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

The current format remains readable.

  $ melc input.cmj >/dev/null

Writing the same payload preserves the existing artifact.

  $ cat > check-mtime.ml <<'EOF'
  > let filename = "input.cmj"
  > let sentinel = 946684800.
  > let () =
  >   Unix.utimes filename sentinel sentinel;
  >   if
  >     Sys.command "melc $MEL_STDLIB_FLAGS --mel-stop-after-cmj input.ml" <> 0
  >   then exit 1;
  >   if (Unix.stat filename).st_mtime <> sentinel then exit 1
  > EOF
  $ ocaml -I +unix unix.cma check-mtime.ml

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

Recompiling the producer repairs a corrupt artifact rather than trusting its
digest header.

  $ printf x >> input.cmj
  $ melc $MEL_STDLIB_FLAGS --mel-stop-after-cmj input.ml
  $ melc input.cmj >/dev/null

An interrupted write can leave only a valid header. Recompiling repairs that
case too.

  $ dd if=input.cmj of=header-only.cmj bs=1 count=29 2>/dev/null
  $ mv header-only.cmj input.cmj
  $ melc $MEL_STDLIB_FLAGS --mel-stop-after-cmj input.ml
  $ melc input.cmj >/dev/null
