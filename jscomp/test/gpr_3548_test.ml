type orientation = [
 | `Horizontal[@mel.as "horizontal"]
 | `Vertical  [@mel.as "vertical"]
] [@@deriving jsConverter]


let () = Js.log (orientationToJs(`Horizontal))
