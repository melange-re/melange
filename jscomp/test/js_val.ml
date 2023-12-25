

external u: int = "u"

external vv : int = "vv"  [@@mel.module "x"]

external vvv : int = "vv"  [@@mel.module "x", "U"]
external vvvv : int = "vvvv"  [@@mel.module "x", "U"]

(* TODO: unify all [bs.module] name, here ideally,
   we should have only one [require("x")] here *)
let h = u
let hh = vv
let hhh = vvv
let hhhh = vvvv
