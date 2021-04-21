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


let get_nth_child node n = match node.children with
  | Some children -> List.nth children n
  | None -> node

let get_node_content node = match node.kind with
  | Name name -> name
  | Literal literal -> literal
  | Error -> failwith "Something went wrong while parsing"

let get_last_child node = match node.children with
  | Some children -> children |> List.rev |> List.hd
  | None -> node


let find_item_attribute_node node = 
  let last = get_last_child node |> get_last_child in
  last.kind = Name "item_attribute"

let has_deriving_type_definitions nodes = 
  List.filter find_item_attribute_node nodes 


let node_children_length node = 
  match node.children with 
  | Some children -> List.length children
  | None -> 0
  


let is_supported def =
  let is_length_one = node_children_length def = 1 in
  if is_length_one then 
    let content = get_node_content def in
    if List.mem content includes then Yes else 
      if List.mem content excludes then Exclude else No
    else No

let get_typedefs output =
      let deriving_type_definitions = has_deriving_type_definitions (Option.get output.children) in 
      let get_name (typedef : node)= get_nth_child typedef 0 |>  get_node_content  in
      let get_def typedef = get_nth_child typedef 1 in
      List.map (fun typedef -> 
        let name = get_name typedef in
        let node = get_def typedef in
        {name ; node}) deriving_type_definitions




