Variant interfaces must agree with implementations on runtime representation.
ReScript #6513. Baseline characterizes incorrectly accepted mismatches.

  $ . ./setup.sh
  $ node <<'EOF'
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
  >   console.log(name+': '+(p.status===0?'accepted':'rejected'));
  > }
  > const valid=[
  >   ['type t = A [@mel.as "a"] | B','type t = A [@mel.as "a"] | B'],
  >   ['type t = A [@mel.as 0] | B','type t = A | B'],
  >   ['type t = A [@mel.as 0x0] | B','type t = A [@mel.as 0] | B'],
  >   ['type t = A of int | B of int [@@mel.tag "TAG"]','type t = A of int | B of int'],
  >   ['type t','type t = A [@mel.as "private"] | B'],
  > ];
  > for(let i=0;i<valid.length;i++) {
  >   const [sig,impl]=valid[i];
  >   fs.writeFileSync('valid.ml',`module M : sig ${sig} end = struct ${impl} end`);
  >   const p=spawnSync('melc',['-alert','-unused','-ppx','melppx','valid.ml'],{encoding:'utf8'});
  >   assert.equal(p.status,0,p.stderr);
  > }
  > EOF
  string_tag: accepted
  integer_tag: accepted
  boolean_tag: accepted
  null_tag: accepted
  undefined_tag: accepted
  block_tag: accepted
  tag_field: accepted
  inline_record: accepted
