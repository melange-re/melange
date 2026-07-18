(* Keep this larger than the cross-module inline threshold so wrappers around
   [choose] are summarized as direct external calls. *)
let choose x y =
  let total = x + y in
  let difference = x - y in
  if total > 10 then total + difference else total - difference

module Tree = struct
  module N = struct
    let add x y = x + y
  end
end
