Record pattern bindings capture their fields before an effectful callee runs.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type view = { x : int }
  > type mutable_view = { mutable y : int }
  > external view : view = "view"
  > external mutable_view : mutable_view = "mutableView"
  > type fn = (int -> int [@u])
  > external next : unit -> fn = "next"
  > let pattern () = let {x} = view in ((next ()) x)[@u]
  > let explicit () = let x = view.x in ((next ()) x)[@u]
  > let mutable_pattern () = let {y} = mutable_view in ((next ()) y)[@u]
  > let closure () = let {x} = view in let f () = x in let _next = next () in f ()
  > let tuple () = let ({x}, _) = (view, 0) in ((next ()) x)[@u]
  > let matching () = match view with {x} -> ((next ()) x)[@u]
  > let unused () = let {x = _} = view in ((next ()) 3)[@u]
  > EOF
  $ melc --color=never -ppx melppx -o input.js input.ml
  $ node <<'EOF'
  > const t = require('./input.js');
  > for (const name of ['pattern', 'explicit', 'mutable_pattern', 'closure', 'tuple', 'matching', 'unused']) {
  >   global.view = {x: 1}; global.mutableView = {y: 1};
  >   global.next = () => { view.x = 2; mutableView.y = 2; return x => x; };
  >   console.log(name, t[name]());
  > }
  > EOF
  pattern 1
  explicit 1
  mutable_pattern 1
  closure 1
  tuple 1
  matching 1
  unused 3
