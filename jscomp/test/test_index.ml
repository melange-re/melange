class type ['a] case = object
  method case : int -> 'a
  method case__set : int -> 'a -> unit
end[@u]




(* let f (x : [%mel.obj: < case : int ->  'a ;  *)
(*             case__set : int ->  int -> unit ; *)
(*             .. > [@u] ] ) *)
(*  =  *)
(*   x ## case__set 3 2 ; *)
(*   x ## case 3  *)


let ff (x : int case  Js.t)
 =
  x##case__set 3 2 ;
  x##case 3


type 'a return = int -> 'a [@u]

let h (x :
         < cse : int -> 'a return [@u] ; .. >   Js.t) =
   (x#@cse 3) 2 [@u]



type x_obj =
   <
    cse : int ->  int [@u] ;
    cse__st : int -> int -> unit [@u];
  > Js.t

let f_ext
    (x : x_obj)
 =
 x #@ cse__st  3 2;
 x #@ cse  3


type 'a h_obj =
  <
    cse : int ->  'a return [@u]
  > Js.t

let h_ext  (x : 'a h_obj) =
   (x #@cse 3) 2 [@u]
