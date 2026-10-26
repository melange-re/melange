Import attributes must survive FFI lowering and dynamic imports.
ReScript #6599. Baseline records missing ESM attributes.

  $ . ./setup.sh
  $ cat > fixture.json <<'EOF'
  > {"value":42}
  > EOF
  $ cat > static.ml <<'EOF'
  > external imported : Js.Json.t = "default" [@@mel.module "./fixture.json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > let json = imported
  > EOF
  $ cat > dynamic.ml <<'EOF'
  > external imported : Js.Json.t = "default" [@@mel.module "./fixture.json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > let load () = Js.import imported
  > EOF
  $ cat > check.cjs <<'EOF'
  > const assert=require('node:assert/strict');
  > const fs=require('node:fs');
  > const {spawnSync}=require('node:child_process');
  > function compile(name,ext,fmt) {
  >   const p=spawnSync('melc',['-alert','-unused','-ppx','melppx','--mel-module-type',fmt,'-o',name+'.'+ext,name+'.ml'],{encoding:'utf8'});
  >   if(p.status!==0) { assert.match(p.stderr,/alert unprocessed/); return null; }
  >   assert.equal(p.status,0,p.stderr);
  >   return fs.readFileSync(name+'.'+ext,'utf8');
  > }
  > const code=compile('static','mjs','es6');
  > if(code===null) { console.log('import attributes: unsupported'); process.exit(0); }
  > console.log('static attributes:',/with\s*\{/.test(code));
  > (async()=>{
  >   try { const m=await import('./static.mjs'); assert.equal(m.json.value,42); console.log('static: ok'); }
  >   catch(e) { assert.equal(e.code,'ERR_IMPORT_ATTRIBUTE_MISSING'); console.log('static:',e.code); }
  >   for(const [ext,fmt] of [['js','commonjs'],['mjs','es6']]) {
  >     const code=compile('dynamic',ext,fmt);
  >     assert.doesNotMatch(code,/require\("\.\/fixture.json"\)|from "\.\/fixture.json"/);
  >     console.log(ext,'dynamic attributes:',/with:/.test(code));
  >     const m=await import('./dynamic.'+ext);
  >     try { const value=await m.load(); assert.equal(value.value,42); console.log(ext,'dynamic: ok'); }
  >     catch(e) { assert.equal(e.code,'ERR_IMPORT_ATTRIBUTE_MISSING'); console.log(ext,'dynamic:',e.code); }
  >   }
  > })().catch(e=>{ console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  import attributes: unsupported
