
(*let skip = "unknown"*)


type t = {
  eta: string;
  beta: (string -> string);
  code: string option;
}



let skip = "unknown"

let skip_obj = {
  eta = skip;
  beta = (fun x -> Format.sprintf "%s %s" skip x);
  code = None
}


let rec mk_body_apply typedef arg =
    let fn = mk_structural_type typedef in 
    match fn.code with
    | Some _ -> fn.beta arg
    | None -> ""

and mk_structural_type (node: Node_types.node) =
  match node.kind with
    | Name("type_constructor_path") -> (
      let supported = Node_types.is_supported node in
      let code = Node_types.get_node_content node in 
      match supported with
      | No -> skip_obj 
      | Yes -> (
          {
            eta= Format.sprintf "fun _self arg -> _self.%s self arg" code;
            beta=(fun x -> Format.sprintf "let st = _self.%s _self st %s in" code x );
            code = Some code
          })
      | Exclude -> (
          {
            eta= Format.sprintf "fun _self arg -> %s self arg" code;
            beta=(fun x -> Format.sprintf "let st = %s _self st %s in" code x );
            code = Some(code)
          }
        )
    )
    | Name("constructed_type") -> (
      let [@warning "-8"] head::base::_ = Option.get node.children  in
      let head_content = Node_types.get_node_content head in
      match head.kind with 
      | Name("option"|"list") -> (
        let inner = mk_structural_type base in
        if inner = skip_obj then
            inner
        else
          let code = match inner.code with
          | Some(code) -> code 
          | None -> Format.sprintf "(%s)" inner.eta 
          in 
          {
            eta= Format.sprintf "fun _self st arg -> %s %s _self st arg" head_content code;
            beta=(fun x -> Format.sprintf "let st = %s %s _self st %s in" head_content code x );
            code = Some(code)
          }
      )
      | _ -> failwith "Unsupported high order type"
    )
   | Name ("tuple_type") -> (
     let children = Option.get node.children in
      let len = children |> List.length in
      let args = List.init len (fun i -> Format.sprintf " _x%i" i) in
      let body = List.mapi (fun i x -> mk_body_apply (Node_types.get_nth_child i node) x ) args in
      let snippet = Format.sprintf "(%s) -> (%s) st " (String.concat "," args) (String.concat " " body) in
      {
        eta=Format.sprintf "fun _self st %s" snippet;
        beta=(fun x -> Format.sprintf "let st = (fun %s) %s in" snippet x);
        code = None
      }
        )
   | _ -> failwith "Unsupported structural type"  



and mk_body (node : Node_types.node) = match node.kind with
  | Name ("type_constructor_path" | "constructed_type" | "tuple_type") -> (mk_structural_type node).eta
  | Name ("record_declaration") -> (
    let children = Option.get node.children in
    let len = List.length children in
    let args = List.init len (fun i -> Format.sprintf " _x%i" i) in
    let pat_exp = List.init len (fun i -> Format.sprintf "%s = %s"
      (Node_types.get_nth_child i node |> Node_types.get_node_content) (List.nth args i)) in
    let body = List.mapi (fun i x -> 
      let ty = node |> Node_types.get_nth_child i |> Node_types.get_nth_child 1 in 
      mk_body_apply ty x ) args in
    Format.sprintf "fun _self st { %s} -> %s st" (String.concat ";" pat_exp ) (String.concat " " body)
  )
  | Name ("variant_declaration") -> (
    let children = Option.get node.children in
    let branches = List.map mk_branch children in
    Format.sprintf "fun _self st -> function \n| %s " (String.concat "\n|" branches)
  )
  | _ -> failwith "Unkown type" 

and mk_branch (branch : Node_types.node) = 
  let [@warning "-8"] head::rest = Option.get branch.children in
  let text = Node_types.node_text head in
  let len = List.length rest in
  if len = 0 then
    Format.sprintf "%s -> st" text
  else
    let args = List.init len (fun i -> Format.sprintf " _x%i" i) in
    let pat_exp = Format.sprintf "%s ( %s)" text (String.concat "," args) in
    let body = List.mapi (fun i x -> 
      let ty = List.nth rest i in
      mk_body_apply ty x
    ) args in
    if List.length body = 0 then
      Format.sprintf "%s _ -> st" text
    else
      Format.sprintf  "%s -> \n %s st" pat_exp (String.concat " " body)


let mk_method (def : Node_types.typedef)  = 
  Format.sprintf "let %s : 'a . ('a, %s) = fn %s" def.name def.name (mk_body def.node)


let make typedef =
  print_endline "here";
  List.iter (fun (x : Node_types.typedef) -> Format.printf "Node in make record_fold:  %a" Node_types.pp_node x.node) typedef;
  let output = List.map mk_method typedef in
  let includes = Node_types.includes in
  let state_iter = List.map (fun x -> Format.sprintf "  %s : ('state,%s) fn" x x ) includes in
  let super = List.map (fun x -> Format.sprintf "    %s" x) includes in
  Format.sprintf {|
open J
let [@inline] unknown _ st _ = st
let [@inline] option sub self st = fun v ->
  match v with
  | None -> st
  | Some v -> sub self st v
let rec list sub self st = fun x  ->
  match x with
  | [] -> st
  | x::xs ->
    let st = sub self st x in
    list sub self st xs
type 'state iter = {
  %s 
}
and ('state,'a) fn = 'state iter -> 'state ->  'a -> 'state
%s
let super : 'state iter = {
  %s
}
  |} (String.concat ";\n" state_iter) (String.concat "output here:\n" output) (String.concat ";\n" super)
