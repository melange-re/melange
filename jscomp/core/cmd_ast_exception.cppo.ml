type error = CannotRun of string | WrongMagic of string

exception Error of error

let report_error ppf = function
  | CannotRun cmd ->
      Format.fprintf ppf
        "Error while running external preprocessor@.Command line: %s@." cmd
  | WrongMagic cmd ->
      Format.fprintf ppf
        "External preprocessor does not produce a valid file@.Command line: \
         %s@."
        cmd

let () =
  Location.register_error_of_exn (function
    | Error err ->
#if OCAML_VERSION >= (5, 3, 0)
        let f (fmt : Format_doc.formatter) err =
          let doc_f =
            Format_doc.deprecated_printer (fun fmt ->
                Format.fprintf fmt "%a" report_error err)
          in
          doc_f fmt
        in
        Some (Location.error_of_printer_file f err)
#else
        Some (Location.error_of_printer_file report_error err)
#endif
    | _ -> None)

let cannot_run comm = raise (Error (CannotRun comm))
let wrong_magic magic = raise (Error (WrongMagic magic))
