module X = struct
  type t = { id : int }
end

(* builds in ocamlc *)
let fails_in_melange =
  let { X.id } = { id = 0 } in
  id
