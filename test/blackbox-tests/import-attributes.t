Import attributes must survive FFI lowering and dynamic imports.
ReScript #6599. Static and dynamic imports retain their attributes.

  $ . ./setup.sh
  $ cat > fixture.json <<'EOF'
  > {"value":42,"items":[1,2]}
  > EOF
  $ mkdir -p node_modules/audit-json
  $ cp fixture.json node_modules/audit-json/value.json
  $ cat > node_modules/audit-json/package.json <<'EOF'
  > {"name":"audit-json","exports":"./value.json"}
  > EOF
  $ cat > static.ml <<'EOF'
  > external imported : Js.Json.t = "default" [@@mel.module "./fixture.json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > let json = imported
  > EOF
  $ cat > dynamic.ml <<'EOF'
  > external imported : Js.Json.t = "default" [@@mel.module "audit-json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > let load () = Js.import imported
  > external whole : Js.Json.t = "audit-json" [@@mel.module]
  >   [@@mel.import_attributes [("type", "json")]]
  > let load_module () = Js.import whole
  > EOF
  $ cat > provider.ml <<'EOF'
  > external data : Js.Json.t = "default" [@@mel.module "audit-json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > external map : (int -> int [@mel.uncurry]) -> int array = "map"
  >   [@@mel.module "audit-json"] [@@mel.scope ("default", "items")]
  >   [@@mel.import_attributes [("type", "json")]]
  > EOF
  $ cat > consumer.ml <<'EOF'
  > let load () = Js.import Provider.data
  > let mapped () = Provider.map (fun x -> x + 1)
  > EOF
  $ cat > exotic.ml <<'EOF'
  > external data : Js.Json.t = "default" [@@mel.module "audit-json"]
  >   [@@mel.import_attributes [("__proto__", "custom"); ("type", "json")]]
  > let load () = Js.import data
  > EOF
  $ cat > duplicate.ml <<'EOF'
  > external a : string = "default" [@@mel.module "host-module"]
  >   [@@mel.import_attributes [("z", "last"); ("a-b", "first")]]
  > external b : string = "default" [@@mel.module "host-module"]
  >   [@@mel.import_attributes [("a-b", "first"); ("z", "last")]]
  > external c : string = "default" [@@mel.module "host-module"]
  >   [@@mel.import_attributes [("a-b", "different"); ("z", "last")]]
  > let values = [|a;b;c|]
  > EOF
  $ cat > plain.ml <<'EOF'
  > external value : int = "value" [@@mel.module "./fixture.json"]
  >   [@@mel.import_attributes [("type", "json")]]
  > let result = value
  > EOF
  $ cat > check.cjs <<'EOF'
  > const assert=require('node:assert/strict');
  > const fs=require('node:fs');
  > const {spawnSync}=require('node:child_process');
  > function compile(name,ext,fmt) {
  >   const p=spawnSync('melc',['-I','.','-alert','-unused','-ppx','melppx','--mel-cross-module-opt','--mel-module-type',fmt,'-o',name+'.'+ext,name+'.ml'],{encoding:'utf8'});
  >   assert.equal(p.status,0,p.stderr);
  >   return fs.readFileSync(name+'.'+ext,'utf8');
  > }
  > const code=compile('static','mjs','es6');
  > console.log('static attributes:',/with\s*\{/.test(code));
  > (async()=>{
  >   const m=await import('./static.mjs'); assert.equal(m.json.value,42); console.log('static: ok');
  >   for(const [ext,fmt] of [['js','commonjs'],['mjs','es6']]) {
  >     const code=compile('dynamic',ext,fmt);
  >     assert.doesNotMatch(code,/require\("audit-json"\)|from "audit-json"/);
  >     console.log(ext,'dynamic attributes:',/with:/.test(code));
  >     const m=await import('./dynamic.'+ext);
  >     const value=await m.load(); assert.equal(value.value,42); console.log(ext,'dynamic: ok');
  >     assert.equal((await m.load_module()).default.value,42);
  >     compile('provider',ext,fmt);
  >     const consumer=compile('consumer',ext,fmt);
  >     assert.match(consumer,/import\("audit-json"/);
  >     const forwarded=await import('./consumer.'+ext);
  >     assert.equal((await forwarded.load()).value,42);
  >     if(ext==='mjs') assert.deepEqual(forwarded.mapped(),[2,3]);
  >     const exoticCode=compile('exotic',ext,fmt);
  >     assert.equal(spawnSync('node',['--check','exotic.'+ext]).status,0);
  >     if(ext==='js') {
  >       // Capture import options without asking the host to implement a custom attribute.
  >       const module={exports:{}}; let attributes;
  >       require('node:vm').runInNewContext(exoticCode.replace(/\bimport\(/g,'captureImport('),{
  >         module, captureImport: (specifier,options)=>{
  >           assert.equal(specifier,'audit-json'); attributes=options.with;
  >           return Promise.resolve({default:{value:42}});
  >         }
  >       });
  >       assert.equal((await module.exports.load()).value,42);
  >       assert.equal(Object.hasOwn(attributes,'__proto__'),true);
  >       assert.equal(attributes.__proto__,'custom'); assert.equal(attributes.type,'json');
  >     }
  >   }
  >   const duplicate=compile('duplicate','mjs','es6');
  >   assert.equal((duplicate.match(/from "host-module"/g)||[]).length,2);
  >   assert.match(duplicate,/"a-b": "first", "z": "last"/);
  >   const plain=compile('plain','js','commonjs');
  >   assert.doesNotMatch(plain,/with/);
  >   assert.equal(require('./plain.js').result,42);
  >   const invalid={
  >     duplicate_key:'external x : string = "default" [@@mel.module "x"] [@@mel.import_attributes [("type","json");("type","json")]]',
  >     duplicate_annotation:'external x : string = "default" [@@mel.module "x"] [@@mel.import_attributes []] [@@mel.import_attributes []]',
  >     non_string:'external x : string = "default" [@@mel.module "x"] [@@mel.import_attributes [("type",1)]]',
  >     no_module:'external x : string = "x" [@@mel.import_attributes []]',
  >   };
  >   for(const [name,source] of Object.entries(invalid)) {
  >     fs.writeFileSync(name+'.ml',source);
  >     const p=spawnSync('melc',['-ppx','melppx',name+'.ml'],{encoding:'utf8'});
  >     assert.equal(p.status,2); assert.match(p.stderr,/Duplicate|expects a list of string pairs|requires/);
  >   }
  >   console.log('identity, CommonJS, cross-module, and diagnostics: ok');
  > })().catch(e=>{ console.error(e); process.exitCode=1; });
  > EOF
  $ node check.cjs
  static attributes: true
  static: ok
  js dynamic attributes: true
  js dynamic: ok
  mjs dynamic attributes: true
  mjs dynamic: ok
  identity, CommonJS, cross-module, and diagnostics: ok
