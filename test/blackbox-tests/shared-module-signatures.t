Shared module signatures must not cause exponential work during export checking.
The timeout bounds a regression that would otherwise walk over 2^64 signatures.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > const {spawnSync} = require('node:child_process');
  > let source = 'module type S0 = sig val value : int end\n';
  > for (let i = 1; i <= 64; i++)
  >   source += `module type S${i} = sig module A : S${i-1} module B : S${i-1} end\n`;
  > source += 'module type F = functor (X : S4) -> S4\n';
  > fs.writeFileSync('shared.ml', source);
  > fs.writeFileSync('shared_interface.mli', source);
  > for (const file of ['shared_interface.mli', 'shared.ml']) {
  >   const result = spawnSync('melc', ['-c', '-I', '.', file], {encoding:'utf8', timeout:20000});
  >   assert.ifError(result.error);
  >   assert.equal(result.status, 0, result.stderr);
  > }
  > console.log('shared signatures in interfaces, implementations and functors: ok');
  > EOF
  $ node check.cjs
  shared signatures in interfaces, implementations and functors: ok
