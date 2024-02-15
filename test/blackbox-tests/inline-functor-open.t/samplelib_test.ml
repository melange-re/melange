let test3 () =
  let open Samplelib.MonadOps (Samplelib.Promise) in
  return 2

let _ = test3 ()
