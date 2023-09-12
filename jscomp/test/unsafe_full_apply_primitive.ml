


let rec f = fun [@u] a -> f a [@u]


(* not allowed due to special encoding of unit *)
(* let rec f1 = fun [@u] () -> f1 () [@u] *)
(* let rec f2 = Sys.opaque_identity (fun () -> f2 ()) *)

