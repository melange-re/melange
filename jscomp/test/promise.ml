type t

external catch : t -> 'a -> 'b = "catch" [@@mel.send]

let f p =
  catch p 3

class type ['b] promise =
  object [@u]
    method _then : 'a -> 'b promise Js.t
    method catch : 'a -> 'b
  end

external new_promise : unit -> _ promise Js.t =
  "Promise" [@@mel.new] [@@mel.module "sys-bluebird"]

let () =
  let p = new_promise() in
  (p##_then(fun x -> x + 3))##catch(fun reason -> reason)


let u =
  [%mel.obj{ _then = 3 ;
    catch  = 32
  }]


let uu = [%mel.obj{
  _'x = 3
}]


let hh = uu##_'x
