@obj
type t = {
  @get @set
  "some_prop": unit => unit,
}

let set_onreadystatechange = (cb: unit => unit, x: t): unit =>
  x["some_prop"] = cb
