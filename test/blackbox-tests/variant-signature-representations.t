Variant interfaces must agree with implementations on runtime representation.
ReScript #6513. Reject mismatches before generating incorrect JavaScript.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert=require('node:assert/strict');
  > const fs=require('node:fs');
  > const {spawnSync}=require('node:child_process');
  > const cases={
  >   string_tag:['type t = A [@mel.as "a"] | B','type t = A | B'],
  >   integer_tag:['type t = A [@mel.as 4] | B','type t = A | B'],
  >   boolean_tag:['type t = A [@mel.as true] | B','type t = A | B'],
  >   null_tag:['type t = A [@mel.as null] | B','type t = A | B'],
  >   undefined_tag:['type t = A [@mel.as undefined] | B','type t = A | B'],
  >   block_tag:['type t = A of int [@mel.as "a"] | B of int','type t = A of int | B of int'],
  >   tag_field:['type t = A of int | B of int [@@mel.tag "kind"]','type t = A of int | B of int'],
  >   inline_record:['type t = A of {x:int} [@mel.as "a"] | B of int','type t = A of {x:int} | B of int'],
  > };
  > for(const [name,[sig,impl]] of Object.entries(cases)) {
  >   fs.writeFileSync(name+'.ml',`module M : sig ${sig} end = struct ${impl} end`);
  >   const p=spawnSync('melc',['-alert','-unused','-ppx','melppx',name+'.ml'],{encoding:'utf8'});
  >   assert.doesNotMatch(p.stderr,/Not_found|Assert_failure|Fatal error/);
  >   assert.equal(p.status,2);
  >   assert.match(p.stderr,/runtime representations/);
  >   console.log(name+': '+(p.status===0?'accepted':'rejected'));
  >   fs.writeFileSync(name+'.ml',`module M : sig ${impl} end = struct ${sig} end`);
  >   const reverse=spawnSync('melc',['-alert','-unused','-ppx','melppx',name+'.ml'],{encoding:'utf8'});
  >   assert.equal(reverse.status,2,reverse.stderr);
  >   assert.match(reverse.stderr,/runtime representations/);
  > }
  > const contexts={
  >   functor:'module type S = sig type t = A [@mel.as "a"] | B end\nmodule F(X:S) = struct end\nmodule M=F(struct type t=A|B end)',
  >   packed:'module type S = sig type t = A [@mel.as "a"] | B end\nmodule M=struct type t=A|B end\nlet value = (module M : S)',
  >   equation:'module M = struct type t = A [@mel.as "a"] | B end\ntype t = M.t = A | B',
  > };
  > for(const [name,source] of Object.entries(contexts)) {
  >   fs.writeFileSync(name+'.ml',source);
  >   const p=spawnSync('melc',['-alert','-unused','-ppx','melppx',name+'.ml'],{encoding:'utf8'});
  >   assert.equal(p.status,2,p.stderr); assert.match(p.stderr,/runtime representations/);
  > }
  > fs.writeFileSync('separate.mli','type t = A [@mel.as "a"] | B');
  > fs.writeFileSync('separate.ml','type t = A | B');
  > assert.equal(spawnSync('melc',['-alert','-unused','-ppx','melppx','separate.mli']).status,0);
  > const separate=spawnSync('melc',['-I','.','-alert','-unused','-ppx','melppx','separate.ml'],{encoding:'utf8'});
  > assert.equal(separate.status,2,separate.stderr); assert.match(separate.stderr,/runtime representations/);
  > const valid=[
  >   ['type t = A [@mel.as "a"] | B','type t = A [@mel.as "a"] | B'],
  >   ['type t = A [@mel.as 0] | B','type t = A | B'],
  >   ['type t = A [@mel.as 0x0] | B','type t = A [@mel.as 0] | B'],
  >   ['type t = A of int | B of int [@@mel.tag "TAG"]','type t = A of int | B of int'],
  >   ['type t','type t = A [@mel.as "private"] | B'],
  >   ['type t = A of int [@@unboxed]','type t = A of int [@@unboxed]'],
  >   ['type t = A [@mel.as 0x100000000] | B','type t = A [@mel.as 0] | B'],
  > ];
  > for(let i=0;i<valid.length;i++) {
  >   const [sig,impl]=valid[i];
  >   fs.writeFileSync('valid.ml',`module M : sig ${sig} end = struct ${impl} end`);
  >   const p=spawnSync('melc',['-alert','-unused','-ppx','melppx','valid.ml'],{encoding:'utf8'});
  >   assert.equal(p.status,0,p.stderr);
  > }
  > console.log('equivalent and abstract signatures: ok');
  > EOF
  $ node check.cjs
  string_tag: rejected
  integer_tag: rejected
  boolean_tag: rejected
  null_tag: rejected
  undefined_tag: rejected
  block_tag: rejected
  tag_field: rejected
  inline_record: rejected
  equivalent and abstract signatures: ok
