let fprintf = Format.fprintf

(* taken from https://github.com/rescript-lang/ocaml/blob/d4144647d1bf9bc7dc3aadc24c25a7efa3a67915/typing/env.ml#L1842 *)
(* modified branches are commented *)
let report_error ppf = function
  | Persistent_env.Illegal_renaming(name, modname, _filename) ->
      (* modified *)
      fprintf ppf
        "@[You referred to the module %s, but we've found one called %s instead.@ \
          Is the name's casing right?@]"
        name modname
  | Inconsistent_import(name, source1, source2) ->
    (* modified *)
    fprintf ppf "@[<v>\
                 @[@{<info>It's possible that your build is stale.@}@ Try to clean the artifacts and build again?@]@,@,\
                 @[@{<info>Here's the original error message@}@]@,\
                 @]";
    fprintf ppf
      "@[<hov>The files %a@ and %a@ \
       make inconsistent assumptions@ over interface %s@]"
      Location.print_filename source1 Location.print_filename source2 name
  | Need_recursive_types(modname) ->
      fprintf ppf
        "@[<hov>%s uses recursive types.@ %s@]"
        modname "The compilation flag -rectypes is required"
  | Depend_on_unsafe_string_unit modname ->
      fprintf ppf
        "@[<hov>%s was compiled with -unsafe-string.@ %s@]"
        modname "This compiler has been configured in strict \
                       safe-string mode (-force-safe-string)"

(* This will be called in super_main. This is how you'd override the default error printer from the compiler & register new error_of_exn handlers *)
let setup () =
  Location.register_error_of_exn
    (function
      | Persistent_env.Error err -> Some (Super_location.error_of_printer_file report_error err)
      | _ -> None
    )
