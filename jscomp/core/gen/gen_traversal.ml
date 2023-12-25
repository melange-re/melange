let parse fname =
  let module In_ch = struct
    let create ?(binary = true) file =
      let flags = [ Open_rdonly ] in
      let flags = if binary then Open_binary :: flags else flags in
      open_in_gen flags 0o000 file

    let with_file ?binary filename ~f =
      let t = create ?binary filename in
      Fun.protect ~finally:(fun () -> close_in t) (fun () -> f t)
  end in
  In_ch.with_file fname ~f:(fun ch ->
      let lexbuf = Lexing.from_channel ch in
      let ast = Parse.interface lexbuf in
      ast)

let write_ast oc ~input_name ast =
  output_string oc Config.ast_impl_magic_number;
  output_value oc input_name;
  output_value oc (Ppxlib_ast.Selected_ast.To_ocaml.copy_structure ast)

type mode = Record_iter | Record_map | Record_fold

let main mode input =
  let ast = parse input in
  let typedefs = Node_types.get_type_defs ast in
  let new_ast =
    match mode with
    | Record_iter -> Record_iter.make typedefs
    | Record_map -> Record_map.make typedefs
    | Record_fold -> Record_fold.make typedefs
  in
  let oc = stdout in
  write_ast oc ~input_name:input new_ast

let mode =
  let open Cmdliner in
  let mode_conv =
    let parse = function
      | "record-iter" -> Ok Record_iter
      | "record-map" -> Ok Record_map
      | "record-fold" -> Ok Record_fold
      | _ -> Error (`Msg "")
    in
    let print fmt t =
      let s =
        match t with
        | Record_iter -> "record-iter"
        | Record_map -> "record-map"
        | Record_fold -> "record-fold"
      in
      Format.fprintf fmt "%s" s
    in
    Arg.conv ~docv:"mode" (parse, print)
  in
  Arg.(required & opt (some mode_conv) None & info [ "mode" ])

let input =
  let open Cmdliner in
  Arg.(required & opt (some string) None & info [ "input" ] ~docv:"FILE")

let () =
  let open Cmdliner in
  let cmd =
    let doc = "Record iter / map / fold code generator" in
    let info = Cmd.info "main" ~version:"v0.0.0" ~doc in
    let term = Term.(const main $ mode $ input) in
    Cmd.v info term
  in
  exit (Cmd.eval cmd)
