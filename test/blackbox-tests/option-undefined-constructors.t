Options must distinguish None from constructors represented by undefined, both
when constructing Some and when unwrapping it before matching.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > type t = U [@mel.as undefined] | N [@mel.as null] | S [@mel.as "a"]
  > type alias = t
  > type record = { field : t option }
  > type carrier = C of t [@@unboxed]
  > let[@inline never] make x = Some x
  > let typed (x : alias) = Some x
  > let explicit = function None -> 0 | Some U -> 1 | Some N -> 2 | Some S -> 3
  > let wildcard = function None -> 0 | Some S -> 3 | Some N -> 2 | Some _ -> 1
  > let default = function Some S -> 3 | Some N -> 2 | _ -> 1
  > let alternatives = function None | Some S -> 3 | Some N | Some U -> 1
  > let field = function
  >   | { field = Some S } -> 3 | { field = Some N } -> 2
  >   | { field = Some _ } -> 1 | _ -> 0
  > let unboxed = function None -> 0 | Some (C U) -> 1 | Some (C N) -> 2 | Some (C S) -> 3
  > let nested = function None -> 0 | Some None -> 1 | Some (Some U) -> 2 | Some (Some _) -> 3
  > let run f xs = print_endline (String.concat " " (List.map (fun x -> string_of_int (f x)) xs))
  > let () =
  >   let cases = [None; Some U; make U; typed U; Some N; Some S] in
  >   List.iter (fun f -> run f cases) [explicit; wildcard; default; alternatives; (fun x -> field {field = x})];
  >   run unboxed [None; Some (C U); make (C U); Some (C N); Some (C S)];
  >   run nested [None; Some None; Some (Some U); make (make U); Some (Some N)]
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ ocamlc -o input.exe input.ml
  $ ./input.exe
  0 1 1 1 2 3
  0 1 1 1 2 3
  1 1 1 1 2 3
  3 1 1 1 1 3
  0 1 1 1 2 3
  0 1 1 2 3
  0 1 2 2 3
  $ node _build/default/out/input.js
  0 0 undefined 0 2 3
  0 0 undefined 0 2 3
  1 1 undefined 1 2 3
  3 3 undefined 3 1 3
  0 0 undefined 0 2 3
  0 0 undefined 2 3
  0 1 0 undefined 3
