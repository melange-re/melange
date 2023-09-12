

type moduleId = < name : string > Js.t

external moduleId : moduleId = "#moduleid" [@@mel.module]


let f () =
  moduleId##name
