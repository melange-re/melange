type 'a terminal =
  | T_error : unit terminal
[@@deriving accessors]



type 'a terminal2 =
  | T_error2 : unit terminal2
[@@deriving accessors]



type 'a terminal3 =
  | T_error3 : int -> int terminal3
[@@deriving accessors]
