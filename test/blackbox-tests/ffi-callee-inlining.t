Inlining a wrapper must evaluate its arguments before looking up its FFI callee.
Compare inlined calls with the same exported wrappers called from JavaScript.

  $ . ./setup.sh
  $ cat > helper.mjs <<'EOF'
  > export let hook = x => x + 1;
  > export function reset() { hook = x => x + 1; }
  > export function install() { hook = x => x + 100; return 1; }
  > EOF
  $ cat > input.ml <<'EOF'
  > external hook : int -> int = "hook"
  > external install : unit -> int = "install"
  > type obj
  > external run : obj -> int -> int = "run" [@@mel.send]
  > external replace : obj -> int = "replace"
  > external imported : int -> int = "hook" [@@mel.module "./helper.mjs"]
  > external replace_import : unit -> int = "install" [@@mel.module "./helper.mjs"]
  > let call_hook x = hook x
  > let call_run o x = run o x
  > let call_import x = imported x
  > let inlined_global () = call_hook (install ())
  > let inlined_method o = call_run o (replace o)
  > let inlined_import () = call_import (replace_import ())
  > EOF
  $ melc -ppx melppx --mel-module-type es6 -o input.mjs input.ml
  $ node --input-type=module <<'EOF'
  > import * as m from './input.mjs';
  > import * as h from './helper.mjs';
  > globalThis.install = () => { globalThis.hook = x => x + 100; return 1; };
  > globalThis.hook = x => x + 1;
  > const global = m.inlined_global();
  > globalThis.hook = x => x + 1;
  > console.log('global', global, m.call_hook(install()));
  > globalThis.replace = o => { o.run = function(x) { return this.base + x + 100; }; return 1; };
  > const object = () => ({base: 0, run(x) { return this.base + x + 1; }});
  > const a = object(), b = object();
  > console.log('method', m.inlined_method(a), m.call_run(b, replace(b)));
  > const imported = m.inlined_import();
  > h.reset();
  > console.log('import', imported, m.call_import(h.install()));
  > const events = [];
  > const getter = {base: 0, fn: x => x + 1, get run() { events.push('get'); return this.fn; }};
  > globalThis.replace = o => { events.push('arg'); o.fn = function(x) { return this.base + x + 100; }; return 1; };
  > console.log('getter', m.inlined_method(getter), events.join(','));
  > EOF
  global 101 101
  method 101 101
  import 101 101
  getter 101 arg,get
