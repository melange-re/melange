(**
function g() { error; }
function f() { g(); }
function rethrow(e) { throw e; }
function test() {
  try {
    f();
  } catch (e) {
    rethrow(e);
  }
}
try { test() } catch (e) { console.log(e.stack) }
*)


let g () = 
  ignore [%raw {|"no inlining"|} ];
  raise Not_found  

let f () = 

  ignore [%raw {|"no inlining"|} ];
  g ()  

let rethrow e = raise e 


let test () = 
  try 
    f ()
  with 
    e -> raise e 
    
let () = 
    try test ()    
    with exn ->
      Js.log ((Obj.magic exn)##stack) 