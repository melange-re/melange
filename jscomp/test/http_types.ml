  (**
     [%bs (req Js.t * resp Js.t => unit ) => server Js.t
     ]

     A syntax extension

     (req Js.t ->  resp Js.t -> unit  [@u] )-> server Js.t [@u]
     type a = [%bs (req Js.t * resp Js.t => unit ) => server Js.t ]
  *)





type req

class type _resp =
  object
    method statusCode : int [@@mel.set]
    method setHeader : string -> string -> unit
    method _end : string -> unit
  end[@u]
type resp = _resp Js.t
class type _server =
  object
    method listen : int ->  string -> (unit -> unit [@u]) -> unit
  end[@u]
type server = _server Js.t
class type _http =
  object
    method createServer : (req  -> resp  -> unit [@u]) ->  server
  end[@u]
type http = _http Js.t




external http : http  = "http"  [@@mel.module ]
