Invalid coercions produce type errors rather than internal exceptions.
ReScript #6574.

  $ . ./setup.sh
  $ cat > check.cjs <<'EOF'
  > const assert=require('node:assert/strict');
  > const fs=require('node:fs');
  > const {spawnSync}=require('node:child_process');
  > const cases={
  >   string_to_int:'let _ = ("a" :> int)',
  >   abstract_to_int:'module M : sig type t val x:t end = struct type t = string let x="x" end\nlet _ = (M.x :> int)',
  >   int_to_abstract:'module M : sig type t end = struct type t = string end\nlet _ = (1 :> M.t)',
  > };
  > for(const [name,source] of Object.entries(cases)) {
  >   fs.writeFileSync(name+'.ml',source);
  >   const p=spawnSync('melc',['-ppx','melppx',name+'.ml'],{encoding:'utf8'});
  >   assert.equal(p.status,2); assert.match(p.stderr,/not a subtype|cannot be coerced/);
  >   assert.doesNotMatch(p.stderr,/Not_found|Assert_failure|Fatal error/);
  >   console.log(name+': type error');
  > }
  > fs.writeFileSync('valid.ml','let widen (x : [ `A | `B ]) = (x :> [ `A | `B | `C ])');
  > const p=spawnSync('melc',['-ppx','melppx','valid.ml'],{encoding:'utf8'});
  > assert.equal(p.status,0,p.stderr); console.log('valid coercion: ok');
  > EOF
  $ node check.cjs
  string_to_int: type error
  abstract_to_int: type error
  int_to_abstract: type error
  valid coercion: ok
