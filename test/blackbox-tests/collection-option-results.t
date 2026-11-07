Collection lookups must distinguish absent elements from stored None values.

  $ . ./setup.sh
  $ cat > input.ml <<'EOF'
  > let show = function
  >   | None -> print_endline "missing"
  >   | Some None -> print_endline "present: None"
  >   | Some (Some n) -> Printf.printf "present: %d\n" n
  > let () =
  >   List.iter (fun take ->
  >     let a = [|Some 1; None|] in
  >     show (take a); show (take a); show (take a);
  >     print_int (Array.length a); print_newline ()) [Js.Array.pop; Js.Array.shift];
  >   let a = [|None; Some 2|] in
  >   List.iter (fun index -> show(Js.Array.at ~index a)) [0; -1; 2; -3];
  >   show(Js.Array.find ~f:(fun _ -> true) a);
  >   show(Js.Array.findi ~f:(fun _ i -> i=0) a);
  >   show(Js.Array.findLast ~f:(fun _ -> true) [|None|]);
  >   show(Js.Array.findLasti ~f:(fun _ i -> i=0) a);
  >   show(Js.Array.find ~f:(fun _ -> false) a);
  >   let m=Js.Map.make() in
  >   ignore(Js.Map.set ~key:"x" ~value:None m);
  >   show(Js.Map.get ~key:"x" m); show(Js.Map.get ~key:"missing" m);
  >   let w=Js.WeakMap.make() and key=Js.Dict.empty() in
  >   ignore(Js.WeakMap.set ~key ~value:None w);
  >   show(Js.WeakMap.get ~key w); show(Js.WeakMap.get ~key:(Js.Dict.empty()) w);
  >   let w=Js.WeakMap.make() in
  >   ignore(Js.WeakMap.set ~key ~value:(Some 3) w);
  >   show(Js.WeakMap.get ~key w);
  >   show(Js.Dict.get (Js.Dict.fromList ["x",None]) "x");
  >   let calls=ref 0 in
  >   let a=[|Some 4;Some 5|] in
  >   show(Js.Array.find ~f:(fun _ -> incr calls; a.(0)<-Some 9; true) a);
  >   Printf.printf "callbacks: %d\n" !calls;
  >   let nulls=[|Js.null|] in
  >   print_endline (match Js.Array.pop nulls with Some x when x = Js.null -> "present: null" | _ -> "wrong")
  > EOF
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ echo '(melange.emit (target out) (libraries melange) (preprocess (pps melange.ppx)))' > dune
  $ dune build @melange
  $ node _build/default/out/input.js
  missing
  present: 1
  missing
  0
  present: 1
  missing
  missing
  0
  missing
  present: 2
  missing
  missing
  missing
  missing
  missing
  missing
  missing
  missing
  missing
  missing
  missing
  present: 3
  present: None
  present: 4
  callbacks: 1
  present: null
