
(*
let f x = 
  match x with 
  | 
   { start = 
      { x = sx ; y = sy}; 
      end_  = 
      { x = ex ; y = ey }
      ;
      thickness 
   } -> 
   { start = { x = sx; y = sy};
      end_  =
      { x = ex; y = ey};
      thickness 
   }
*)   

(* let f x= 
  match x with 
  | Some [%map? [ "x", x; "y", y]] 
    ->  x + y *)
(*
in json pattern match, it is a self closed world ,
no need mix with normal patch

naive compilation strategy:
- generate a predicate
- generate path for each bounded variable
- we first apply predicate, then if it matches,
   create freshly bounded variables

- generate a matcher return    
  either Null
  or ([x;y;z])
*)
let ff x =     
  match%json x with 
  | [ "x", ["z", x] ; "y", [|0;1;1|]] -> 
    Some x 
  | _ -> None

(*
a reverse DSL to create JSON object
*)  

let json = [%json [ "x", ["z", x], "y", [|0;1;1;|] ] ]

(*
  if 
    (fun x -> 
     let v0 = x["x"] in  
     if v0 !== undefined &&
        v0["z"] !== undefined &&  
       match x["y"] with 
       (| [|0;1;1;1|] -> true
        | _ -> false
       )) x then 
   let x = x ["x"] ["z"] in 

*)
(* let ff x =     
  match x with 
  | Some v when
    (match Bs.MapString.find "x" v , Bs.MapString.find "y" v with 
    | x, y -> true 
    | _ -> false) ->  *)