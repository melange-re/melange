include module type of struct
  include Stdlib.Option
end

val bind : 'a option -> f:('a -> 'b option) -> 'b option
val map : f:('a -> 'b) -> 'a option -> 'b option
val iter : f:('a -> unit) -> 'a option -> unit
val equal : eq:('a -> 'a -> bool) -> 'a option -> 'a option -> bool
val compare : cmp:('a -> 'a -> int) -> 'a option -> 'a option -> int
