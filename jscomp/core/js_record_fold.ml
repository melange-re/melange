
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
  ident : ('state,ident) fn;
  module_id : ('state,module_id) fn;
  vident : ('state,vident) fn;
  exception_ident : ('state,exception_ident) fn;
  for_ident : ('state,for_ident) fn;
  expression : ('state,expression) fn;
  statement : ('state,statement) fn;
  variable_declaration : ('state,variable_declaration) fn;
  block : ('state,block) fn;
  program : ('state,program) fn
}
and ('state,'a) fn = 'state iter -> 'state ->  'a -> 'state
let  label : 'a . ('a,label) fn  =  unknown   
let  ident : 'a . ('a,ident) fn  =  unknown   
let  module_id : 'a . ('a,module_id) fn  =  fun _self st { id = _x0;kind = _x1} -> let st = _self.ident _self st _x0 in st   
let  required_modules : 'a . ('a,required_modules) fn  =  fun _self st arg -> list _self.module_id _self st arg   
let  vident : 'a . ('a,vident) fn  =  fun _self st -> function 
| Id ( _x0)  -> 
  let st = _self.ident _self st _x0 in st
|Qualified ( _x0,_x1)  -> 
  let st = _self.module_id _self st _x0 in st   
let  exception_ident : 'a . ('a,exception_ident) fn  =  (fun _self arg -> _self.ident _self arg)   
let  for_ident : 'a . ('a,for_ident) fn  =  (fun _self arg -> _self.ident _self arg)   
let  for_direction : 'a . ('a,for_direction) fn  =  unknown   
let  property_map : 'a . ('a,property_map) fn  =  fun _self st arg -> list ((fun _self st (_x0,_x1) ->  let st = _self.expression _self st _x1 in st )) _self st arg   
let  length_object : 'a . ('a,length_object) fn  =  unknown   
let  expression_desc : 'a . ('a,expression_desc) fn  =  fun _self st -> function 
| Length ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = length_object _self st _x1 in st
|Char_of_int ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Char_to_int ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Is_null_or_undefined ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|String_append ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in st
|Bool _ -> st
|Typeof ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Js_not ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Seq ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in st
|Cond ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in let st = _self.expression _self st _x2 in st
|Bin ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x1 in let st = _self.expression _self st _x2 in st
|FlatCall ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in st
|Call ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in let st = list _self.expression _self st _x1 in st
|String_index ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in st
|Array_index ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = _self.expression _self st _x1 in st
|Static_index ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in st
|New ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in let st = option (fun _self st arg -> list _self.expression _self st arg) _self st _x1 in st
|Var ( _x0)  -> 
  let st = _self.vident _self st _x0 in st
|Fun ( _x0,_x1,_x2,_x3,_x4)  -> 
  let st = list _self.ident _self st _x1 in let st = _self.block _self st _x2 in st
|Str _ -> st
|Unicode _ -> st
|Raw_js_code _ -> st
|Array ( _x0,_x1)  -> 
  let st = list _self.expression _self st _x0 in st
|Optional_block ( _x0,_x1)  -> 
  let st = _self.expression _self st _x0 in st
|Caml_block ( _x0,_x1,_x2,_x3)  -> 
  let st = list _self.expression _self st _x0 in let st = _self.expression _self st _x2 in st
|Caml_block_tag ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Number _ -> st
|Object ( _x0)  -> 
  let st = property_map _self st _x0 in st
|Undefined -> st
|Null -> st   
let  for_ident_expression : 'a . ('a,for_ident_expression) fn  =  (fun _self arg -> _self.expression _self arg)   
let  finish_ident_expression : 'a . ('a,finish_ident_expression) fn  =  (fun _self arg -> _self.expression _self arg)   
let  case_clause : 'a . ('a,case_clause) fn  =  fun _self st { switch_body = _x0;should_break = _x1;comment = _x2} -> let st = _self.block _self st _x0 in st   
let  string_clause : 'a . ('a,string_clause) fn  =  (fun _self st (_x0,_x1) ->  let st = case_clause _self st _x1 in st )   
let  int_clause : 'a . ('a,int_clause) fn  =  (fun _self st (_x0,_x1) ->  let st = case_clause _self st _x1 in st )   
let  statement_desc : 'a . ('a,statement_desc) fn  =  fun _self st -> function 
| Block ( _x0)  -> 
  let st = _self.block _self st _x0 in st
|Variable ( _x0)  -> 
  let st = _self.variable_declaration _self st _x0 in st
|Exp ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|If ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in let st = _self.block _self st _x1 in let st = _self.block _self st _x2 in st
|While ( _x0,_x1,_x2,_x3)  -> 
  let st = option label _self st _x0 in let st = _self.expression _self st _x1 in let st = _self.block _self st _x2 in st
|ForRange ( _x0,_x1,_x2,_x3,_x4,_x5)  -> 
  let st = option for_ident_expression _self st _x0 in let st = finish_ident_expression _self st _x1 in let st = _self.for_ident _self st _x2 in let st = for_direction _self st _x3 in let st = _self.block _self st _x4 in st
|Continue ( _x0)  -> 
  let st = label _self st _x0 in st
|Break -> st
|Return ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Int_switch ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in let st = list int_clause _self st _x1 in let st = option _self.block _self st _x2 in st
|String_switch ( _x0,_x1,_x2)  -> 
  let st = _self.expression _self st _x0 in let st = list string_clause _self st _x1 in let st = option _self.block _self st _x2 in st
|Throw ( _x0)  -> 
  let st = _self.expression _self st _x0 in st
|Try ( _x0,_x1,_x2)  -> 
  let st = _self.block _self st _x0 in let st = option ((fun _self st (_x0,_x1) ->  let st = _self.exception_ident _self st _x0 in let st = _self.block _self st _x1 in st )) _self st _x1 in let st = option _self.block _self st _x2 in st
|Debugger -> st   
let  expression : 'a . ('a,expression) fn  =  fun _self st { expression_desc = _x0;comment = _x1;loc = _x2} -> let st = expression_desc _self st _x0 in st   
let  statement : 'a . ('a,statement) fn  =  fun _self st { statement_desc = _x0;comment = _x1;loc = _x2} -> let st = statement_desc _self st _x0 in st   
let  variable_declaration : 'a . ('a,variable_declaration) fn  =  fun _self st { ident = _x0;value = _x1;property = _x2;ident_info = _x3} -> let st = _self.ident _self st _x0 in let st = option _self.expression _self st _x1 in st   
let  block : 'a . ('a,block) fn  =  fun _self st arg -> list _self.statement _self st arg   
let  program : 'a . ('a,program) fn  =  fun _self st { block = _x0;exports = _x1;export_set = _x2} -> let st = _self.block _self st _x0 in st   
let  deps_program : 'a . ('a,deps_program) fn  =  fun _self st { program = _x0;modules = _x1;side_effect = _x2} -> let st = _self.program _self st _x0 in let st = required_modules _self st _x1 in st   
let super : 'state iter = {
  ident;
  module_id;
  vident;
  exception_ident;
  for_ident;
  expression;
  statement;
  variable_declaration;
  block;
  program
}
    