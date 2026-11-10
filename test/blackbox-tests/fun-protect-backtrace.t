Fun.protect must preserve exceptions from work and wrap exceptions from finally.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.20)
  > (using melange 1.0)
  > EOF
  $ echo '(melange.emit (target out))' > dune
  $ cat > input.ml <<'EOF'
  > let check ~finally work =
  >   try Fun.protect ~finally work; print_endline "returned" with
  >   | Failure s -> print_endline ("Failure " ^ s)
  >   | Fun.Finally_raised (Failure s) ->
  >       print_endline ("Finally_raised (Failure " ^ s ^ ")")
  >   | _ -> print_endline "unexpected exception"
  > let[@inline never] reraise get_backtrace =
  >   Printexc.raise_with_backtrace (Failure "direct") (get_backtrace ())
  > let () =
  >   check ~finally:(fun () -> print_endline "finally")
  >     (fun () -> failwith "work");
  >   check ~finally:(fun () -> failwith "finally") (fun () -> ());
  >   check ~finally:(fun () -> failwith "finally") (fun () -> failwith "work");
  >   check ~finally:(fun () -> ()) (fun () ->
  >     reraise (fun () -> print_endline "backtrace"; failwith "backtrace"))
  > EOF
  $ ocaml input.ml
  finally
  Failure work
  Finally_raised (Failure finally)
  Finally_raised (Failure finally)
  backtrace
  Failure backtrace

Melange must preserve the same exceptions and backtrace-argument effects.

  $ dune build @melange
  $ node _build/default/out/input.js
  finally
  Failure work
  Finally_raised (Failure finally)
  Finally_raised (Failure finally)
  backtrace
  Failure backtrace
