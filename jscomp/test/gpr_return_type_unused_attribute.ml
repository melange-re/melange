(* [@@@ocaml.warning "-101"] *)

external mk : int ->
  (
    [`a|`b]
    (* [@mel.string] *)
  ) = "mk"



let v = mk 2


(* let h () = v = "x" *)
