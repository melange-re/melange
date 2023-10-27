module React = struct
type element = unit
type ('a,'b) componentLike = 'a -> 'b
let null = ()
end

module Foo :
  sig
    val make : ?htmlAttributes:float array -> React.element[@@react.component]
  end =
  struct let make ?htmlAttributes:_  = React.null[@@react.component ] end
