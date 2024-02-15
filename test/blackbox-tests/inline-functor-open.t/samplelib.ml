module MonadOps (M : sig
  type _ t

  val return : 'x -> 'x t
  val bind : 'x t -> ('x -> 'y t) -> 'y t
end) =
struct
  let return = M.return
  let ( >>= ) = M.bind
end

module Promise = struct
  type 'x t = 'x Js.Promise.t

  let return x : _ t = Js.Promise.resolve x
  let bind : 'x t -> ('x -> 'y t) -> 'y t = fun m af -> Js.Promise.then_ af m
end
