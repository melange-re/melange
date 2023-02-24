let ( // ) = Filename.concat

let () =
  let dir = Sys.argv.(1) in
  let files =
    Sys.readdir dir |> Array.to_list
    |> List.filter (fun file ->
           not
             (Sys.is_directory (dir // file)
             || Filename.extension (Filename.chop_extension file) = ".pp"))
  in
  (* Format.eprintf "x: %d %s@." (List.length files) (files |> String.concat "; "); *)
  Format.printf "(%a)"
    (Format.pp_print_list (fun fmt f ->
         Format.fprintf fmt "(lib/melange/%s as mel_runtime/melange/%s)" f f))
    files
