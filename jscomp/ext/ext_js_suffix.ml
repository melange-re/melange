type t = string

let to_string = Fun.id

let of_string (x : string) : t =
  match String.length x with
  | 0 -> raise (Invalid_argument "File extension can not be empty")
  | _ -> (
      let first = String.get x 0 in
      match first with
      | '.' -> (
          let last = String.get x (String.length x - 1) in
          match last with
          | '.' ->
              raise
                (Invalid_argument
                   (Printf.sprintf "File extension %s does not end with '.'" x))
          | _ -> x)
      | _ ->
          raise
            (Invalid_argument
               (Printf.sprintf "File extension %s does not start with '.'" x)))

let default = ".js"
