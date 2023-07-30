external _NaN : float = "NaN" [@@mel.val]
external isNaN : float -> bool = "isNaN" [@@mel.val]
external isFinite : float -> bool = "isFinite" [@@mel.val]

external toExponentialWithPrecision : float -> digits:int -> string
  = "toExponential"
  [@@mel.send]

external toFixed : float -> string = "toFixed" [@@mel.send]

external toFixedWithPrecision : float -> digits:int -> string = "toFixed"
  [@@mel.send]

external fromString : string -> float = "Number" [@@mel.val]
