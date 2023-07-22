let test3 () =
  let open Samplelib.MonadOps (Samplelib.Promise) in
  (* let module X = Samplelib.MonadOps (Samplelib.Promise) in *)
  (* let open X in *)
  return 2

let _ = test3 ()
