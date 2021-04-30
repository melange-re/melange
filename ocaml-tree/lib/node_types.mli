type position = Tree_sitter_bindings.Tree_sitter_output_t.position = {
    row: int;
    column: int;
}
[@@deriving show]

type node_kind = Tree_sitter_bindings.Tree_sitter_output_t.node_kind =
    | Name of string
    | Literal of string
    | Error
[@@deriving show]

type node = Tree_sitter_bindings.Tree_sitter_output_t.node = {
  type_ : string;

  start_pos: position;

  end_pos: position;

  children: node list option;

  kind: node_kind;

  id: int;    
}
[@@deriving show]

type supported = 
  | Yes
  | No
  | Exclude 




type typedef = {
    name: string;
    node: node;
}


val includes: string list

val excludes: string list

val node_text: node -> string

val node_type: node -> node

val get_nth_child: int -> node -> node

val is_supported: node -> supported

val get_node_content: node -> string

val get_typedefs: node -> typedef list

val maker: (typedef list -> string) -> typedef list -> string 

