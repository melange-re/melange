external log1 :
  (
    [ `Pair of string * int
    | `Int of int
    | `String of string
    ] [@mel.unwrap]
  )
  -> unit = "console.log"

let _ = log1 (`Pair ("hello world", 1))
let _ = log1 (`Int 1337)
let _ = log1 (`String "hello world")

let arg_string = `String "hi runtime"
let _ = log1 arg_string

let arg_pair = `Pair ("hi", 1)
let _ = log1 arg_pair

external log2 :
  (
    [ `Unit of unit
    ] [@mel.unwrap]
  )
  -> unit = "console.log"

let _ = log2 (`Unit ())

external log3 :
  req:([
    `String of string
       | `Int of int
       ] [@mel.unwrap])
  -> ?opt:([ `String of string
           | `Bool of bool
           ] [@mel.unwrap])
  -> unit
  -> unit = "console.log"

let _ = log3 ~req:(`Int 1) ()
let _ = log3 ~req:(`Int 2) ~opt:(`String "hi") ()
let _ = log3 ~req:(`Int 3) ?opt:(Some (`String "hi")) ()
let _ = log3 ~req:(`Int 4) ?opt:None ()

(* static optional arg as variable *)
let some_arg = Some (`Bool true)
let _ = log3 ~req:(`Int 5) ?opt:some_arg ()

let none_arg = None
let _ = log3 ~req:(`Int 6) ?opt:none_arg ()

(* static optional arg as complex side-effectful expression *)
let _ = log3
    ~req:(`Int 7)
    ?opt:(
      ((fun _ ->
           print_endline "trace";
           None
        )
         ()
      )
    )
    ()

(* expose the external as a function in generated module*)
let dyn_log3 = log3

(* call the dynamically reassigned external *)
let _ = dyn_log3 ~req:(`Int 8) ~opt:(`Bool true) ()

external log4 :
  ([ `String of string
   | `Options of  < foo : int > Js.t
   ] [@mel.unwrap])
  -> unit = "console.log"

(* Make sure [@mel.unwrap] plays nicely with [%mel.obj] *)
let _ = log4 (`String "foo")
let _ = log4 (`Options [%mel.obj { foo = 1 }])

let dyn_log4 = log4
let _ = dyn_log4 (`Options [%mel.obj { foo = 2 }])


let f x = dyn_log4 x

external log5: ?h:([`A of int | `B of string] [@mel.unwrap]) -> int -> unit = "console.log"


let ff0 x p = log5 ?h:x p

let ff1 x p = log5 ?h:(x ()) p


external ff : a:int -> b:int-> x: unit  -> _ = "" [@@mel.obj]


let test00 () = ff  ~a:1 ~b:2 ~x:()
