
(* Implementation of the command, we just print the args. *)

(* Command line interface *)

open Cmdliner
open Tree_sitter_ocaml


let unwrap input error_message= match input with
  | Some(input) -> input 
  | None -> failwith error_message 


let ocaml_tree mode input output = 
    let _mode = unwrap mode "Please insert the mode" in
    let input = unwrap input "Please insert the input file" in 
    let output = unwrap output "Please insert the output file" in
    let oc = open_out output in
    let input_tree = Parse.parse_source_string input in
    let typedefs = Node_types.get_typedefs input_tree.root in
    let make_fn = Record_fold.make in
    Printf.fprintf oc "escreveu";
    Format.printf "conteudo arquivo: %s" (Node_types.maker make_fn typedefs);
    flush oc;
    close_out oc


let mode = Arg.(value & opt (some string) None & info ["mode"] ~docv: "MODE")

let input = Arg.(value & pos 0 (some file) None  & info [] ~docv: "INPUT")

let output = Arg.(value & pos 1 (some file) None  & info [] ~docv: "OUTPUT")

let cmd =
  let doc = "You know what" in
  Term.(const ocaml_tree $ mode $ input $ output ),
  Term.info "ocaml_tree" ~doc ~exits:Term.default_exits 

let () = Term.(exit @@ eval cmd) 
