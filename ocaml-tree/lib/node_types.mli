type position = Tree_sitter_bindings.Tree_sitter_output_t.position = {
    row: int;
    column: int;
}

type node_kind = Tree_sitter_bindings.Tree_sitter_output_t.node_kind =
    | Name of string
    | Literal of string
    | Error

type node = Tree_sitter_bindings.Tree_sitter_output_t.node = {
  type_ : string;

  start_pos: position;

  end_pos: position;

  children: node list option;

  kind: node_kind;

  id: int;    
}

type typedef = {
    name: string;
    node: node;
}



val is_supported: node -> bool

val get_typedefs: node -> typedef list

