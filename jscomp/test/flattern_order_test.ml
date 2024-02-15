(*
let second xs =
    let rec ys = 1 :: ys
    and _zs () = List.hd xs
    (* and us = 3 in  *) in

    xs

let f x =
    let f0 a = a+1 in
    let f1 a  = f0 a + 1  in
    let f2 a = f1 a + 1 in
    f2 x
*)

let rec even =
    let odd = even in
    fun n -> if n == 0 then true else odd (n - 1)


let rec even2 =
    let odd n = if n == 1 then true else even2 (n - 1) in
    fun n -> if n == 0 then true else odd (n - 1)

type t =
    { get : unit -> int ;
      set : int -> unit ;
    }

let v = ref 0
let obj =
    { get = (fun _ -> !v);
      set = (fun i -> v := i )
    }
