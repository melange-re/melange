Source Map v3 output must preserve decoded locations and executable stack traces.
Maps retain exact locations through preprocessing and separate compilation.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert = require('node:assert/strict');
  > const fs = require('node:fs');
  > const path = require('node:path');
  > const {spawnSync} = require('node:child_process');
  > const {SourceMap} = require('node:module');
  > const source = 'external boom : unit -> string = "auditBoom"\nlet run () = {js|😀|js} ^ boom ()\n';
  > fs.mkdirSync('out');
  > fs.writeFileSync('input.ml', source);
  > function compile(input, output, mode, extra = []) {
  >   const args = ['-ppx', 'melppx', ...extra];
  >   if (mode) args.push('-mel-source-map', mode);
  >   args.push('-o', output);
  >   if (input.endsWith('.re')) args.push('-pp', 'refmt --print=binary', '-impl', input);
  >   else args.push(input);
  >   return spawnSync('melc', args, {encoding: 'utf8'});
  > }
  > function success(result) { assert.equal(result.status, 0, result.stderr); }
  > const first = compile('input.ml', 'out/linked.js', 'file');
  > success(first);
  > function payload(file, inline = false) {
  >   if (!inline) return JSON.parse(fs.readFileSync(file + '.map', 'utf8'));
  >   const encoded = fs.readFileSync(file, 'utf8').match(/sourceMappingURL=data:application\/json[^,]*,([^\s]+)/)[1];
  >   return JSON.parse(Buffer.from(encoded, 'base64').toString('utf8'));
  > }
  > function check(file, data, original, line, text, needle = 'boom ()') {
  >   assert.equal(data.version, 3);
  >   assert.equal(data.file, path.basename(file));
  >   const lines = fs.readFileSync(file, 'utf8').split('\n');
  >   const generatedLine = lines.findIndex(l => l.includes('auditBoom('));
  >   assert.notEqual(generatedLine, -1);
  >   const entry = new SourceMap(data).findEntry(generatedLine, lines[generatedLine].indexOf('auditBoom('));
  >   assert.ok(entry.originalSource.endsWith(original), JSON.stringify(entry));
  >   assert.equal(entry.originalLine, line);
  >   assert.equal(entry.originalColumn, text.split('\n')[line].indexOf(needle));
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
  > fs.writeFileSync('reason.re', 'external boom: unit => string = "auditBoom";\nlet run = () => boom();\n');
  > success(compile('reason.re', 'out/reason.js', 'file'));
  > const reasonMap = payload('out/reason.js');
  > check('out/reason.js', reasonMap, 'reason.re', 1, fs.readFileSync('reason.re', 'utf8'), 'boom()');
  > console.log('preprocessor directives and Reason: ok');
  > // An inlined call keeps the producer's source after separate compilation.
  > fs.writeFileSync('producer.ml', source);
  > success(compile('producer.ml', 'out/producer.js', 'file', ['-mel-cross-module-opt']));
  > fs.unlinkSync('producer.ml');
  > fs.writeFileSync('consumer.ml', 'let run () = Producer.run ()\n');
  > success(compile('consumer.ml', 'out/consumer.js', 'file', ['-mel-cross-module-opt', '-I', 'out']));
  > check('out/consumer.js', payload('out/consumer.js'), 'producer.ml', 1, source);
  > console.log('cross-module inlining with a saved source snapshot: ok');
  > const crlf = source.replaceAll('\n', '\r\n');
  > fs.writeFileSync('crlf.ml', crlf);
  > success(compile('crlf.ml', 'out/crlf.js', 'file', ['-preamble', '// 😀\r\n// second line']));
  > check('out/crlf.js', payload('out/crlf.js'), 'crlf.ml', 1, crlf);
  > // Two #line sources exercise source-index deltas and URI escaping.
  > const a = 'let a () = boom ()\n', b = 'let b () = boom ()\n';
  > fs.writeFileSync('a space.ml', a); fs.writeFileSync('b.ml', b);
  > fs.writeFileSync('multiple.ml', 'external boom : unit -> string = "auditBoom"\n# 1 "a space.ml"\n' + a + '# 1 "b.ml"\n' + b);
  > success(compile('multiple.ml', 'out/multiple.js', 'file'));
  > const multi = payload('out/multiple.js'), decoded = new SourceMap(multi);
  > const entries = fs.readFileSync('out/multiple.js', 'utf8').split('\n').flatMap((l, n) =>
  >   l.includes('auditBoom(') ? [decoded.findEntry(n, l.indexOf('auditBoom('))] : []);
  > assert.deepEqual(entries.map(e => e.originalSource), ['../a%20space.ml', '../b.ml']);
  > assert.ok(entries.every(e => e.originalLine === 0 && e.originalColumn === a.indexOf('boom ()')));
  > assert.deepEqual(multi.sourcesContent, [a, b]);
  > fs.writeFileSync('empty.ml', '');
  > success(compile('empty.ml', 'out/empty.js', 'file'));
  > assert.equal(payload('out/empty.js').mappings, '');
  > assert.match(fs.readFileSync('out/empty.js', 'utf8'), /\n\/\/# sourceMappingURL=empty.js.map\n$/);
  > console.log('CRLF, preambles, multiple sources, escaped paths and empty modules: ok');
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
  linked, inline, hidden, ESM, Unicode columns, cmj and stack traces: ok
  preprocessor directives and Reason: ok
  cross-module inlining with a saved source snapshot: ok
  CRLF, preambles, multiple sources, escaped paths and empty modules: ok
  Dune inline maps: ok
