external _NaN : float = "NaN" [@@bs.val]
external isNaN : float -> bool = "isNaN" [@@bs.val]
external isFinite : float -> bool = "isFinite" [@@bs.val]

external toExponentialWithPrecision : float -> digits:int -> string
  = "toExponential"
  [@@bs.send]

external toFixed : float -> string = "toFixed" [@@bs.send]

external toFixedWithPrecision : float -> digits:int -> string = "toFixed"
  [@@bs.send]

external fromString : string -> float = "Number" [@@bs.val]
