Test `Js.Set` code generation

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > x.ml <<EOF
  > let t = Js.Set.make ()
  > let t2 = Js.Set.make ()
  > let () =
  >   Js.Set.(
  >     add ~value:1 t |>
  >     add ~value:2 |>
  >     add ~value:3 |>
  >     add ~value:4 |> ignore
  >   );
  > 
  >   Js.Set.(
  >     add ~value:4 t2 |>
  >     add ~value:5 |>
  >     add ~value:6 |>
  >     add ~value:7 |> ignore
  >   )
  > let () = Js.log (Js.Set.has t ~value:3)
  > let () = Js.log (Js.Set.has t2 ~value:3)
  > 
  > let t_1 = Js.Set.make ()
  > let t_2 = Js.Set.add ~value:1 t_1
  > let () = Js.log (Printf.sprintf "t_1 size = %i; t_2 size = %i" (Js.Set.size t_1) (Js.Set.size t_2))
  > EOF
  $ dune build @melange
  $ node _build/default/out/x.js
  true
  false
  t_1 size = 1; t_2 size = 1
