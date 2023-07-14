type t = string

let to_string = Fun.id

let of_string (x : string) : t =
  match String.length x with
  | 0 -> raise (Invalid_argument "File extension can not be empty")
  | length -> (
      match String.unsafe_get x 0 with
      | '.' -> (
          match String.unsafe_get x (length - 1) with
          | '.' ->
              raise
                (Invalid_argument
                   (Printf.sprintf "File extension %s cannot end with '.'" x))
          | _ -> x)
      | _ ->
          raise
            (Invalid_argument
               (Printf.sprintf "File extension %s does not start with '.'" x)))

let default = ".js"
