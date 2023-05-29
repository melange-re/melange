

let string_or_number (type t) x = 
  let ty   = Js.Types.classify x in
  match  ty with 
  | JSString v   -> Js.log (v ^ "hei") ; true (* type check *)
  | JSNumber v -> Js.log (v +. 3.); true (* type check *)
  | JSUndefined ->  false
  | JSNull ->  false
  | JSFalse | JSTrue -> false
  | JSFunction _ -> Js.log ("Function"); false
  | JSObject _ ->  false
  | JSSymbol _ ->  false
  | JSBigInt _ ->  false

let suites = Mt.[
    "int_type", (fun _ -> Eq(Js.typeof 3, "number") );
    "string_type", (fun _ -> Eq(Js.typeof "x", "string"));

    "number_gadt_test", (fun _ -> Eq(Js.Types.test 3 Number, true ))  ;  
    "boolean_gadt_test", (fun _ -> Eq (Js.Types.test true Boolean, true ))    ;

    (* assert.notDeepEqual(undefined,null) raises ..*)
    "undefined_gadt_test", (fun _ -> Eq (Js.Types.test Js.undefined Undefined, true ))    ;
    (* "null_gadt_test", (fun _ -> Neq (Js.Types.test Js.null  Js.Null, Js.null )); *)
    (* there ['a Js.null] is one case that the value is already null  '*)
    "string_on_number1", (fun _ -> Eq (string_or_number "xx", true)); 
    "string_on_number2", (fun _ -> Eq (string_or_number 3.02, true)); 
    "string_on_number3", (fun _ -> Eq (string_or_number (fun x -> x ), false)); 
    "string_gadt_test", (fun _ -> Eq (Js.Types.test "3" String, true ));    
    "string_gadt_test_neg", (fun _ -> Eq (Js.Types.test 3 String, false ));    
    "function_gadt_test", (fun _ -> Eq (Js.Types.test (fun  x -> x ) Function,  true)) ;
    "object_gadt_test", (fun _ -> Eq (Js.Types.test [%bs.obj{x = 3}] Object, true ))    
]

;; Mt.from_pair_suites __MODULE__ suites 
