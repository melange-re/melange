

let rec map f ls = 
    match ls with 
    | [] -> []
    | x::xs -> f x [@bs] :: map f xs 

let map2 f ls = map (fun [@bs] x -> f x )  ls 


let map3  ls = 
    map (fun [@bs] x -> x + 1 )ls  

let uu f = fun [@bs] () -> f ()     

let small_should_inline x y = x + y 

let a = small_should_inline 1 2 

let small_should_inline2 = fun [@bs] x y -> x  + y

let b = small_should_inline2 1 2 [@bs]

let f x y = 
        Js.log (x,y);
        x + y 



let opt_f ?(x=3) y = f x y 

let v = opt_f 3 

let v = opt_f ~x:2 3 