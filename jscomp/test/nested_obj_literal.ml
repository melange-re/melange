let structural_obj =
  [%mel.obj { x = [%obj{ y = [%obj{ z = 3 }]}]} ]
(* compiler inferred type :
  val structural_obj : < x : < y : < z : int >  >  > [@mel.obj] *)

type 'a x = {x : 'a }
type 'a y = {y : 'a}
type 'a z = { z : 'a}
let f_record   =  { x = { y = { z = 3 }}}
(* compiler inferred type :
   val f_record : int z y x *)
