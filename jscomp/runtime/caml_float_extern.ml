external _NaN : float = "NaN"
external isNaN : float -> bool = "isNaN"
external isFinite : float -> bool = "isFinite"

external toExponentialWithPrecision : float -> digits:int -> string
  = "toExponential"
[@@mel.send]

external toFixed : float -> string = "toFixed" [@@mel.send]

external toFixedWithPrecision : float -> digits:int -> string = "toFixed"
[@@mel.send]

external fromString : string -> float = "Number"
