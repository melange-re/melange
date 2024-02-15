let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~suites ~test_id loc x y
let b loc v  = Mt.bool_suites ~suites ~test_id loc v

type 'a u = 'a option =
  private
   | None
   | Some  of 'a

let f0 x =
   match x with
  | (_, (Some true)) -> 1
  | (_, _ ) -> 2


type x = A of int * int | None

type x0 = Some of int | None
let f1 u = match u with | A _ -> 0 | None -> 1



let f2 ?x ?(y : int option) ?(z = 3)
  ()
   =
   Js.log x ;
   match y with
   | None -> 0
   | Some y ->
    y + z


let f3 x  =
  match x with
  | None -> 0
  | Some _ -> 1

let f4 x =
  match x with
  | None -> 0
  | Some x -> x + 1


type 'a t =
   | None
   | Some of 'a
let f5 a  =
  Some a = None

let f6 a =
  Some a <> None

let f7 =  None

let f8 = Some None

let f9 = Some (Some None)

let f10 = Some (Some (Some (Some None)))

let f11 = Some f10

let f12 = Some (Some (Some (Some [1,2])))

let randomized = ref false

let create ?(random= !randomized) () =
  if random then 2
  else 1

let ff = create ~random:false  ()


let f13 ?(x =3) ?(y=4) () = x + y

let a = f13 ~x:2 ()

let f12  (x : _ list) = Some (x)

module N = Belt.List

let length_8_id : int list = N.makeBy 8 (fun x -> x)
let length_10_id : int list = N.makeBy 10 (fun x -> x)

type 'a xx = 'a option =
   | None
   | Some  of 'a
let f13 () =
  N.take length_10_id 8 = (Some [1;2;3] : _ option)


let () =
  b __LOC__ (None < Some Js.null);
  b __LOC__ (not (None > Some Js.null));
  b __LOC__ ( ( Some Js.null > None));
  b __LOC__ (None < Some Js.undefined);
  b __LOC__ ( Some Js.undefined > None);

external log3 :
  req:([ `String of string
       | `Int of int
       ] [@mel.unwrap])
  -> ?opt:([ `String of string
           | `Bool of bool
           ] [@mel.unwrap])
  -> unit
  -> unit = "console.log"

let none_arg = None
let _ = log3 ~req:(`Int 6) ?opt:none_arg ()


let ltx a b =  a < b && b > a
let gtx a b = a > b && b < a
let eqx a b = a = b && b = a
let neqx a b = a <> b && b <> a

let all_true xs = Belt.List.every xs (fun x -> x)

;; b __LOC__
  @@ all_true
  [
    gtx (Some (Some Js.null)) (Some None)
  ]

;; b __LOC__
  @@ all_true
  [
    ltx (Some None)  (Some (Some 3));
    ltx (Some None) (Some (Some None));
    ltx (Some None) (Some (Some "3"));
    ltx (Some None) (Some (Some true));
    ltx (Some None) (Some (Some false));
    ltx (Some false) (Some (true));
    ltx (Some (Some false)) (Some (Some (true)));
    ltx None (Some None);
    ltx None (Some Js.null);
    ltx None (Some (fun x -> x  ));
    ltx (Some Js.null) (Some (Js.Null.return 3));
  ]

;; b __LOC__
  @@ all_true [
    eqx None None;
    neqx None (Some Js.null);
    eqx (Some None) (Some None);
    eqx (Some (Some None)) (Some (Some None));
    neqx (Some (Some (Some None))) (Some (Some None))
  ]

module N0 = struct
  type record = { x : int ; mutable y : string}
  type t =
    | None
    | Some of record

  let v (x : record) : t  = Some x
  let v0 (x : record) : record option = Some x
  (* [v] and [v0] should be just an identity function *)
end
;; Mt.from_pair_suites __MODULE__ !suites
