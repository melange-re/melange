let () = Js.log "你好"

let () = Js.log {js|你好|js}

let () =
    Js.log [%raw {|"你好"|}]

(* let f = function *)
  (* | {j| hello |j} -> 0 *)
  (* | _ -> 1 *)
