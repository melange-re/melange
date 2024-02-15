type explicit_type =
  | Boolean
  | Number
  | String
  | Symbol
  | BigInt [@@deriving ord]
let rec compare_explicit_type :
  explicit_type -> explicit_type -> int =
  ((
      fun lhs ->
        fun rhs ->
          match (lhs, rhs) with
          | (Boolean, Boolean) -> 0
          | (Number, Number) -> 0
          | (String, String) -> 0
          | (Symbol, Symbol) -> 0
          | (BigInt, BigInt) -> 0
          | _ ->
              let to_int =
                function
                | Boolean -> 0
                | Number -> 1
                | String -> 2
                | Symbol -> 3
                | BigInt -> 4 in
              compare (to_int lhs) (to_int rhs))
  [@ocaml.warning "-A"])[@@ocaml.warning "-39"]
let string_of_explicit_type =
  function
  | Boolean -> "boolean"
  | Number -> "number"
  | String -> "string"
  | Symbol -> "symbol"
  | BigInt -> "bigint"
