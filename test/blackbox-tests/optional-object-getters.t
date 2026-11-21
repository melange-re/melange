Optional object fields must read their getter once, including nested options.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let source : 'a option -> < > Js.t = [%mel.raw {|value => ({
  >   reads: 0, get x() { return ++this.reads === 1 ? value : undefined; }
  > })|}]
  > external get : < > Js.t -> 'a option = "x" [@@mel.get]
  > external reads : < > Js.t -> int = "reads" [@@mel.get]
  > external make : ?x:'a -> unit -> _ = "" [@@mel.obj]
  > let describe : 'a -> string = [%mel.raw {|o =>
  >   !Object.hasOwn(o, 'x') ? 'absent' :
  >   o.x === undefined ? 'undefined' :
  >   o.x === null ? 'null' : typeof o.x|}]
  > let test value =
  >   let s = source value in
  >   let result = try describe (make ?x:(get s) ()) with _ -> "threw" in
  >   Printf.printf "%s %d\n" result (reads s)
  > let () = test None; test (Some 5); test (Some None);
  >   test (Some (Some None)); test (Some Js.null)
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ node _build/default/out/input.js
  absent 1
  threw 2
  threw 2
  threw 2
  threw 2
