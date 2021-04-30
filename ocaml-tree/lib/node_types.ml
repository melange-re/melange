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


let excludes = [
    "deps_program";
    "int_clause";
    "string_clause";
    "for_direction";
    "expression_desc";
    "statement_desc";
    "for_ident_expression";
    "label";
    "finish_ident_expression";
    "property_map";
    "length_object";
    "required_modules";
    "case_clause"]

let includes = [
  "ident";
  "module_id";
  "vident";
  "exception_ident";
  "for_ident";
  "expression";
  "statement";
  "variable_declaration";
  "block";
  "program"]

type typedef = {
  name: string;
  node: node;
}


let get_nth_child n node = match node.children with
  | Some children -> List.nth children n
  | None -> node

let get_node_content node = match node.kind with
  | Name name -> name
  | Literal literal -> literal
  | Error -> "Something went wrong while parsing"

let get_last_child node = match node.children with
  | Some [] -> node
  | Some children -> children |> List.rev |> List.hd
  | None -> failwith "No children"

let node_text node = 
  node 
  |> get_nth_child 0 
  |> get_node_content

let node_type node = get_nth_child 1 node

let _has_deriving_type_definitions nodes = 
  List.filter (fun node ->
    let last = node |> get_last_child |> get_last_child in
    last.type_ = "item_attribute"
    ) nodes 

let node_children_length node = 
  match node.children with 
  | Some children -> List.length children
  | None -> 0

let is_supported node =
  let is_length_one = node_children_length node = 1 in
  if is_length_one then 
    let content = get_node_content node in
    if List.mem content includes then Yes else 
      if List.mem content excludes then Exclude else No
    else No

let get_typedefs output =
      List.map (fun typedef -> 
  Format.printf "%a typdefs" pp_node output;
        let name = node_text typedef in
        let node = node_type  typedef in
        {name ; node}) (Option.get output.children)


let maker make typedefs = make typedefs

