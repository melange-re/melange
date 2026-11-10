#if OCAML_VERSION >= (5,6,0)
[@@@alert "-todo"]

let eq expected actual = assert (expected = actual)

let () =
  Mt.from_suites __MODULE__
    [ ( "Fun.todo evaluates its argument and reports its call site",
        fun () ->
          let calls = ref 0 in
          let site, info =
            __POS__, (try Fun.todo (incr calls) with Fun.Todo info -> info)
          in
          let file, line, _, _ = site in
          let location = Printf.sprintf "File %S, line %d" file line in
          eq 1 !calls;
          eq ("Fun.Todo\n" ^ location)
            (Printexc.to_string (Fun.Todo info)) );
      ( "Fun.Todo printer escapes the file name",
        fun () ->
          let todo (file : string) (line : int) =
            Fun.Todo (Obj.magic (file, line))
          in
          eq "Fun.Todo\nFile \"-\", line 0" (Printexc.to_string (todo "" 0));
          eq "Fun.Todo\nFile \"a\\\"b\\\\c\\n\\t\\200\", line -1"
            (Printexc.to_string (todo "a\"b\\c\n\t\200" (-1))) );
      ( "Fun.todo can be passed as a function",
        fun () ->
          let call f =
            match f () with
            | _ -> assert false
            | exception Fun.Todo _ -> ()
          in
          call Fun.todo ) ]
#endif
