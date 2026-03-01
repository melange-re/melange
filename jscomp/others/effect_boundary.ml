type 'a t =
  | Return of 'a
  | Suspend of (('a -> unit) -> unit)

let return x = Return x
let suspend k = Suspend k

let run_with t resume =
  match t with
  | Return v -> resume v
  | Suspend step -> step resume

let map f t =
  match t with
  | Return v -> Return (f v)
  | Suspend step -> Suspend (fun resume -> step (fun v -> resume (f v)))

let bind t f =
  match t with
  | Return v -> f v
  | Suspend step ->
      Suspend (fun resume -> step (fun v -> run_with (f v) resume))
