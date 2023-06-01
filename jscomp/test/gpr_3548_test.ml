type orientation = [
 | `Horizontal[@bs.as "horizontal"]
 | `Vertical  [@bs.as "vertical"]
] [@@deriving jsConverter]


let () = Js.log (orientationToJs(`Horizontal))
