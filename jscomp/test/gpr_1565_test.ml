

external f : (_ [@bs.as 3]) -> unit = "" [@@bs.val]


let h = f

external f2: 
  (_ [@bs.as 3]) -> unit -> unit = "" [@@bs.val]


let h = f2  