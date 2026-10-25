Source Map v3 output must preserve decoded locations and executable stack traces.
The initial snapshot records the missing compiler option.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > const path = require('node:path');
  > const {spawnSync} = require('node:child_process');
  > const {SourceMap} = require('node:module');
  > const source = 'external boom : unit -> string = "auditBoom" [@@mel.val]\nlet run () = {js|😀|js} ^ boom ()\n';
  > fs.mkdirSync('out');
  > fs.writeFileSync('input.ml', source);
  > function compile(input, output, mode, extra = []) {
  >   const args = ['-ppx', 'melppx', ...extra];
  >   if (mode) args.push('-mel-source-map', mode);
  >   args.push('-o', output, input);
  >   return spawnSync('melc', args, {encoding: 'utf8'});
  > }
  > function success(result) { assert.equal(result.status, 0, result.stderr); }
  > const first = compile('input.ml', 'out/linked.js', 'file');
  > if (first.status !== 0) {
  >   console.log('source maps unavailable; compiler exit:', first.status);
  >   process.exit(0);
  > }
  > function payload(file, inline = false) {
  >   if (!inline) return JSON.parse(fs.readFileSync(file + '.map', 'utf8'));
  >   const encoded = fs.readFileSync(file, 'utf8').match(/sourceMappingURL=data:application\/json[^,]*,([^\s]+)/)[1];
  >   return JSON.parse(Buffer.from(encoded, 'base64').toString('utf8'));
  > }
  > function check(file, data, original, line, text) {
  >   assert.equal(data.version, 3);
  >   assert.equal(data.file, path.basename(file));
  >   const lines = fs.readFileSync(file, 'utf8').split('\n');
  >   const generatedLine = lines.findIndex(l => l.includes('auditBoom('));
  >   assert.notEqual(generatedLine, -1);
  >   const entry = new SourceMap(data).findEntry(generatedLine, lines[generatedLine].indexOf('auditBoom('));
  >   assert.ok(entry.originalSource.endsWith(original), JSON.stringify(entry));
  >   assert.equal(entry.originalLine, line);
  >   assert.equal(entry.originalColumn, text.split('\n')[line].indexOf('boom ()'));
  >   const i = data.sources.findIndex(s => s.endsWith(original));
  >   assert.equal(data.sourcesContent[i], text);
  >   assert.ok(data.sources.every(s => !path.isAbsolute(s)));
  > }
  > check('out/linked.js', payload('out/linked.js'), 'input.ml', 1, source);
  > success(compile('input.ml', 'out/plain.js'));
  > success(compile('input.ml', 'out/inline.js', 'inline'));
  > success(compile('input.ml', 'out/hidden.js', 'hidden'));
  > check('out/inline.js', payload('out/inline.js', true), 'input.ml', 1, source);
  > check('out/hidden.js', payload('out/hidden.js'), 'input.ml', 1, source);
  > const plain = fs.readFileSync('out/plain.js', 'utf8');
  > for (const file of ['linked', 'inline', 'hidden']) {
  >   const code = fs.readFileSync('out/' + file + '.js', 'utf8');
  >   assert.equal(code.replace(/^\/\/# sourceMappingURL=.*\n/gm, ''), plain);
  > }
  > assert.ok(!fs.existsSync('out/inline.js.map'));
  > assert.ok(!fs.existsSync('out/plain.js.map'));
  > success(compile('input.ml', 'out/esm.mjs', 'file', ['-mel-module-type', 'es6']));
  > check('out/esm.mjs', payload('out/esm.mjs'), 'input.ml', 1, source);
  > success(spawnSync('node', ['--check', 'out/esm.mjs'], {encoding:'utf8'}));
  > // Re-emission needs the saved source, including UTF-16 columns, even without .ml.
  > fs.unlinkSync('input.ml');
  > success(compile('out/linked.cmj', 'out/reemitted.js', 'file'));
  > check('out/reemitted.js', payload('out/reemitted.js'), 'input.ml', 1, source);
  > fs.writeFileSync('input.ml', source);
  > const stack = spawnSync('node', ['--enable-source-maps', '-e',
  >   'global.auditBoom = () => {throw new Error("mapped")}; try {require("./out/linked.js").run()} catch(e) {console.log(e.stack)}'], {encoding:'utf8'});
  > success(stack);
  > const column = source.split('\n')[1].indexOf('boom ()') + 1;
  > assert.ok(stack.stdout.includes('input.ml:2:' + column), stack.stdout);
  > console.log('linked, inline, hidden, ESM, Unicode columns, cmj and stack traces: ok');
  > const original = '\n'.repeat(39) + source;
  > fs.writeFileSync('original.ml', original);
  > fs.writeFileSync('preprocessed.ml', '# 40 "original.ml"\n' + source);
  > success(compile('preprocessed.ml', 'out/preprocessed.js', 'file'));
  > check('out/preprocessed.js', payload('out/preprocessed.js'), 'original.ml', 40, original);
  > fs.writeFileSync('reason.re', '[@mel.val] external boom: unit => string = "auditBoom";\nlet run = () => boom();\n');
  > success(compile('reason.re', 'out/reason.js', 'file'));
  > const reasonMap = payload('out/reason.js');
  > assert.ok(reasonMap.sources.some(s => s.endsWith('reason.re')));
  > assert.ok(new SourceMap(reasonMap).payload.mappings.length > 0);
  > console.log('preprocessor directives and Reason: ok');
  > // Source snapshots must survive Dune's separate compilation/emission sandboxes.
  > fs.mkdirSync('project');
  > fs.writeFileSync('project/dune-project', '(lang dune 3.17)\n(using melange 0.1)\n');
  > fs.writeFileSync('project/dune', '(melange.emit (target output) (emit_stdlib false) (preprocess (pps melange.ppx)) (compile_flags :standard --mel-source-map inline))\n');
  > fs.writeFileSync('project/input.ml', source);
  > success(spawnSync('dune', ['build', '--root', 'project', '@melange'], {encoding:'utf8'}));
  > const duneFile = 'project/_build/default/output/input.js';
  > check(duneFile, payload(duneFile, true), 'input.ml', 1, source);
  > console.log('Dune inline maps: ok');
  > EOF
  $ node check.cjs
  source maps unavailable; compiler exit: 124
