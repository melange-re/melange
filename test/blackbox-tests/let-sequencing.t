Explicit lets evaluate their right-hand sides before effectful callees and FFI lookups.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type counter = { mutable n : int }
  > type handler = { mutable f : int -> int }
  > type snap = { mutable unused : int; saved : int }
  > let c = { n = 0 }
  > let next () = c.n <- c.n + 1; (fun x -> x)
  > let direct () = c.n <- 0; let before = c.n in (next ()) before
  > let inlined () = c.n <- 0; let call x = (next ()) x in call c.n
  > let field () = let r = {f=(fun x -> x)} in let swap () = r.f <- (fun x -> x+10); 1 in let x=swap() in r.f x
  > let saved () = c.n <- 0; let s={unused=0;saved=c.n} in (next ()) s.saved
  > let effects () = let x = print_endline "argument"; 1 in (print_endline "callee"; fun x -> x) x
  > let () = Printf.printf "%d %d %d %d\n" (direct()) (inlined()) (field()) (saved()); ignore(effects())
  > EOF
  $ cat > ffi.ml <<'EOF'
  > [%%mel.raw {|globalThis.hook = x => x; globalThis.install = () => { globalThis.hook = x => x + 10; return 1; };|}]
  > external install : unit -> int = "install" [@@mel.scope "globalThis"]
  > external hook : int -> int = "hook" [@@mel.scope "globalThis"]
  > let test () = let x=install() in hook x
  > let call x = hook x
  > let () = Printf.printf "%d\n" (test())
  > EOF
  $ sed 's/(test())/(call (install()))/' ffi.ml > wrapper.ml
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ ocamlc -o input.exe input.ml
  $ ./input.exe
  0 0 11 0
  argument
  callee
  $ node _build/default/out/input.js
  1 1 1 0
  argument
  callee
  $ node _build/default/out/ffi.js
  1
  $ node _build/default/out/wrapper.js
  1
