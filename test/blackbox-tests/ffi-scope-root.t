The first global scope is emitted as JavaScript source. Invalid roots must not
become keywords or expressions such as subtraction (ReScript #9309 discussion).

  $ . ./setup.sh
  $ for scope in class foo-bar 'foo bar' 1foo await '\u0063lass'; do
  >   printf 'external value : int = "value" [@@mel.scope {|%s|}]\nlet value = value\n' "$scope" > invalid.ml
  >   melc -alert -unprocessed -ppx melppx invalid.ml -o invalid.js && sed -n '/^const value = /p' invalid.js
  > done
  const value = class.value;
  const value = foo-bar.value;
  const value = foo bar.value;
  const value = 1foo.value;
  const value = await.value;
  const value = \u0063lass.value;

Module scopes, receiver scopes, and later global scopes are property names.
Keywords, punctuation and byte-string keys must keep working there.

  $ cat > fixture.cjs <<'EOF'
  > const leaf = {value: 42, call() { return this.value; }, Ctor: class { constructor() { this.value = 43; } }};
  > exports['foo-bar'] = {class: {'a b': {'1st': {'\xce\xbb': leaf}}}};
  > EOF
  $ cat > valid.ml <<'EOF'
  > external global : int = "value"
  >   [@@mel.scope "globalThis", "scopeFixture", "foo-bar", "class", "a b", "1st", "λ"]
  > external imported : int = "value"
  >   [@@mel.scope "foo-bar", "class", "a b", "1st", "λ"] [@@mel.module "./fixture.cjs"]
  > external get : 'a -> int = "value" [@@mel.get]
  >   [@@mel.scope "foo-bar", "class", "a b", "1st", "λ"]
  > external call : 'a -> unit -> int = "call" [@@mel.send]
  >   [@@mel.scope "foo-bar", "class", "a b", "1st", "λ"]
  > external make : unit -> 'a = "Ctor" [@@mel.new] [@@mel.module "./fixture.cjs"]
  >   [@@mel.scope "foo-bar", "class", "a b", "1st", "λ"]
  > external unicode : int = "value" [@@mel.scope "λ"]
  > external dotted : int = "value" [@@mel.scope "scopeFixture.foo"]
  > external floor : float -> int = "floor" [@@mel.scope "Math"]
  > let read obj = global, imported, get obj, call obj (), unicode, dotted, floor 3.5
  > let make () = make ()
  > EOF
  $ melc -ppx melppx valid.ml -o valid.js
  $ melc -ppx melppx -bs-module-type es6 valid.ml -o valid.mjs
  $ node --input-type=module <<'EOF'
  > import fixture from './fixture.cjs';
  > globalThis.scopeFixture = {...fixture, foo: {value: 44}};
  > globalThis.λ = {value: 45};
  > for (const ext of ['js', 'mjs']) {
  >   const m = await import('./valid.' + ext);
  >   console.log(m.read(fixture).join(','), m.make().value);
  > }
  > EOF
  42,42,42,42,45,44,3 43
  42,42,42,42,45,44,3 43
