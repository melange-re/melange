

type v = unit


external log : 'a -> unit = "console.log"

external log2 : 'a -> v = "console.log"


let u = log 3

let v = log2 3 (*FIXME: [unit] here *)
