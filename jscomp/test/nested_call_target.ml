let rec external_target x =
  if x <= 0 then 0 else 1 + external_target (x - 1)

module Tree = struct
  module N = struct
    let add x y = x + y
  end
end
