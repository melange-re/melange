[@@@warning "-22"]

exception Local
exception B of int list
exception C of int * int
exception D of (int * int)
let[@ocaml.warning "-38"] appf g x =
  let module U = struct
    exception A of int
  end in
  try g x with
  | Local -> 3
  | Not_found -> 2
  | U.A 32 -> 3
  | U.A _ -> 3
  | B (_ :: _ :: x :: _) ->  x
  | C (x, _)
  | D (x, _) -> x
  | _ -> 4

(*
TODO:
{[
    else if (exn[0] === B) {
      var match = exn[1];
      if (match) {
        var match$1 = match[1];
        if (match$1) {
          var match$2 = match$1[1];
          if (match$2) {
            return match$2[0];
          }
          else {
            exit = 1;
          }
        }
        else {
          exit = 1;
        }
      }
      else {
        exit = 1;
      }
    }

]}

can be simplified as

{[
var match, match$1, match$2 ;

else if (exn[0] === B) {
  if (match = exn[1] && match$1 = match[1] && match$2 =  match$1[1]) {
      return match$2[0];
    }
  else {
    exit = 1;
  }
}

]}

peepwhole rules like
{[
var x = e ;
if (x) {
 ..
}
]}

can be translated into

{[
var x ;
if (x = e){
}
]}
*)

exception A of int

let f  =
  try [%mel.raw{| function () {throw (new Error ("x"))} ()|}] with
  | A x -> x
  | _ -> 2

let ff  =
  try [%mel.raw{| function () {throw 3} ()|}] with
  | A x -> x
  | _ -> 2

let fff  =
  try [%mel.raw{| function () {throw 2} ()|}] with
  | A x -> x
  | _ -> 2

let a0 =
  try [%mel.raw{| function (){throw 2} () |}] with (* throw is a statement *)
  | A x -> x
  | Js.Exn.Error v -> Obj.magic v
  | _ -> assert false


let a1 : exn  =
  try [%mel.raw{| function (){throw 2} () |}] with (* throw is a statement *)
  | e -> e

let a2 : exn  =
  try [%mel.raw{| function (){throw (new Error("x"))} () |}] with (* throw is a statement *)
  | e -> e

let suites = ref Mt.[
    __LOC__, (fun _ -> Eq ((f,ff,fff,a0), (2,2,2,2)));
    (* __LOC__, (fun _ -> Eq (Js.Exn.Error (Obj.magic 2) , a1)) *)
    __LOC__, (fun _ ->
        match a1 with
        | Js.Exn.Error v -> Eq (Obj.magic  v , 2)
        | _ -> assert false
      )
]


let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y

let () =
  try [%raw{|()=>{throw 2}|}]  () [@u]
  with
  e ->
    eq __LOC__ (Js.Exn.asJsExn e <> None) true


let () =
  try raise Not_found
  with
  e ->
    eq __LOC__ (Js.Exn.asJsExn e <> None) false


let fff0 x g = match x () with | exception _ -> 1 | _ -> g ()

let rec input_lines ic acc =
  match input_line ic with
  | exception _ -> List.rev acc
  | line -> input_lines ic (line::acc)


let () =
  eq __LOC__ (([%raw{|(a,b,c,_) => a + b + c |}] : _ -> _ -> _ -> _ -> _ ) 1 2 3 4) 6
;; Mt.from_pair_suites __MODULE__ !suites
