type valid_input =
  | Ml
  | Mli
  | Intf_ast
  | Impl_ast
  | Mlmap
  | Cmi
  | Cmj
  | Unknown

(** This is per-file based,
    when [ocamlc] [-c -o another_dir/xx.cmi]
    it will return (another_dir/xx)
*)

let classify_input ext =
  match () with
  | _ when ext = Literals.suffix_ml -> Ml
  | _ when ext = !Config.interface_suffix -> Mli
  | _ when ext = Literals.suffix_ast -> Impl_ast
  | _ when ext = Literals.suffix_iast -> Intf_ast
  | _ when ext = Literals.suffix_mlmap -> Mlmap
  | _ when ext = Literals.suffix_cmi -> Cmi
  | _ when ext = Literals.suffix_cmj -> Cmj
  | _ -> Unknown
