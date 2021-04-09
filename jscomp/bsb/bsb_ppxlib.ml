open Bsb_config_types

let generate_rules ppx_config =
  let driver = "let () = Ppxlib.Driver.run_as_ppx_rewriter ()" in
  let ppx_ml =
    Printf.sprintf
      "(rule (with-stdout-to ppx.ml (run echo \"%s\")))"
      driver
    in
  let executable =
    Printf.sprintf
      "(executable (name ppx) (modules ppx) (flags -linkall) (libraries %s))"
      (String.concat " " ppx_config.ppxlib) in
  Printf.sprintf "%s\n%s" ppx_ml executable

let ppxlib buf ~ppx_config =
  if ppx_config.ppxlib <> []
    then Buffer.add_string buf (generate_rules ppx_config)
    else ()
