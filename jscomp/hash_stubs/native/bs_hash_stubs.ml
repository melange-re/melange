let hash_string : string -> int = Hashtbl.hash
let hash_string_int s i = Hashtbl.hash (s, i)
let hash_string_small_int : string -> int -> int = hash_string_int
let hash_stamp_and_name (i : int) (s : string) = Hashtbl.hash (i, s)
let hash_int (i : int) = Hashtbl.hash i

let string_length_based_compare (x : string) (y : string) =
  let len1 = String.length x in
  let len2 = String.length y in
  if len1 = len2 then String.compare x y else compare (len1 : int) len2

let int_unsafe_blit : int array -> int -> int array -> int -> int -> unit =
  Array.blit
