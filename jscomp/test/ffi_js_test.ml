let keys :  Obj.t -> string array [@bs] = [%mel.raw " function (x){return Object.keys(x)}" ]



[%%mel.raw{|
  function $$higher_order(x){
   return function(y,z){
      return x + y + z
   }
  }
|}]
external higher_order: int -> (int -> int -> int  [@bs]) = "$$higher_order" [@@bs.val]

let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc (x, y) =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites

type _ kind =
  | Int : int kind
  | Str : string kind

external config : kind:('a kind [@bs.ignore] ) -> hi:int -> low:'a ->  _ = "" [@@bs.obj]

let int_config = config ~kind:Int ~hi:3  ~low:32

let string_config = config ~kind:Str ~hi:3  ~low:"32"

let () =
  eq __LOC__ (6, ((higher_order 1 ) 2 3 [@bs]))


let same_type =
  ([int_config; [%obj{hi= 3 ; low = 32}]],
   [string_config ; [%obj{hi = 3 ; low = "32"}]]
  )

let v_obj = object method hi__x () = Js.log "hei" end [@bs]


let () =
  eq __LOC__ (Array.length (Js.Obj.keys int_config), 2 );
  eq __LOC__ (Array.length (Js.Obj.keys string_config), 2 );
  eq __LOC__ (Js.Obj.keys v_obj |. Js.Array2.indexOf "hi_x" , -1 );
  eq __LOC__ (Js.Obj.keys v_obj |. Js.Array2.indexOf "hi", 0 )

let u = ref 3

let side_effect_config = config ~kind:(incr u; Int) ~hi:3 ~low:32

let () =
  eq __LOC__ (!u, 4)

type null_obj

external hh : null_obj   -> int = "hh" [@@bs.send] (* it also work *)
external ff : null_obj -> unit  -> int = "ff" [@@bs.send]
external ff_pipe :  unit  -> int = "ff_pipe" [@@bs.send.pipe: null_obj]
external ff_pipe2 :   int = "ff_pipe2" [@@bs.send.pipe: null_obj] (* FIXME *)
let vv z = hh z

let v z = ff z ()

let vvv z = z |> ff_pipe ()

let vvvv z = z |> ff_pipe2
let create_prim () =  [%obj{ x' = 3 ; x'' = 3; x'''' = 2}]

type t
external setGADT : t -> ('a kind [@bs.ignore]) -> 'a ->  unit = "setGADT" [@@bs.set]
external setGADT2 :
 t ->
 ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore]) ->
 ('a * 'b) ->  unit = "setGADT2" [@@bs.set]

external getGADT : t -> ('a kind [@bs.ignore]) -> 'a  = "getGADT" [@@bs.get]

external getGADT2 :
 t -> ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore])
  -> ('a * 'b)  = "getGADT2" [@@bs.get]

external getGADTI2 :
 t -> ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore]) -> int
  -> ('a * 'b)  = "" [@@bs.get_index]

external getGADTI3 :
 t -> ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore]) -> (_ [@bs.as 3])
  -> ('a * 'b)  = "" [@@bs.get_index]

external setGADTI2 :
 t -> ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore]) -> int
  -> ('a * 'b) -> unit  = "" [@@set_index]

external setGADTI3 :
 t -> ('a kind [@bs.ignore]) ->
 ('b kind [@bs.ignore]) -> (_ [@bs.as 3] )
  -> ('a * 'b) -> unit  = "" [@@set_index]

let ffff x =
  begin
  setGADT x Int 3;
  setGADT2 x Int Str (3,"3");
  setGADT2 x Str Int ("3",3);
  (match getGADTI3 x Int Str with
  | (cc,dd) -> Js.log (cc,dd));
  Js.log @@ getGADT x Int ;
  (match
     getGADT2 x Int Str  with
   |((a : int) ,(b:string)) ->
    Js.log2 a b);
   (match getGADTI2 x Int Str 0  with
   | (a : int), (b:string) ->
    Js.log2 a b);
  (setGADTI2 x Int Str 0 (1,"x")) ;
  setGADTI3 x Int Str (3,"x")
  end
let () = Mt.from_pair_suites __MODULE__ !suites
