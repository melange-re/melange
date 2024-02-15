external of_int : int -> int64 = "%int64_of_int"
external add : int64 -> int64 -> int64 = "%int64_add"
external sub : int64 -> int64 -> int64 = "%int64_sub"
external mul : int64 -> int64 -> int64 = "%int64_mul"
external div : int64 -> int64 -> int64 = "%int64_div"
external logor : int64 -> int64 -> int64 = "%int64_or"
external neg : int64 -> int64 = "%int64_neg"
external to_int : int64 -> int = "%int64_to_int"

type t = { hi : int; [@mel.as "0"] lo : int [@mel.as "1"] }
