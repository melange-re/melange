let keys :  Obj.t -> string array [@u] = [%mel.raw " function (x){return Object.keys(x)}" ]



[%%mel.raw{|
  function $$higher_order(x){
   return function(y,z){
      return x + y + z
   }
  }
|}]
external higher_order: int -> (int -> int -> int  [@u]) = "$$higher_order"

let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc (x, y) =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites

type _ kind =
  | Int : int kind
  | Str : string kind

external config : kind:('a kind [@mel.ignore] ) -> hi:int -> low:'a ->  _ = "" [@@mel.obj]

let int_config = config ~kind:Int ~hi:3  ~low:32

let string_config = config ~kind:Str ~hi:3  ~low:"32"

let () =
  eq __LOC__ (6, ((higher_order 1 ) 2 3 [@u]))


let same_type =
  ([int_config; [%obj{hi= 3 ; low = 32}]],
   [string_config ; [%obj{hi = 3 ; low = "32"}]]
  )

let v_obj = object method hi__x () = Js.log "hei" end [@u]


let () =
  eq __LOC__ (Array.length (Js.Obj.keys int_config), 2 );
  eq __LOC__ (Array.length (Js.Obj.keys string_config), 2 );
  eq __LOC__ (Js.Obj.keys v_obj |. Js.Array.indexOf ~value:"hi_x", -1 );
  eq __LOC__ (Js.Obj.keys v_obj |. Js.Array.indexOf ~value:"hi", 0 )

let u = ref 3

let side_effect_config = config ~kind:(incr u; Int) ~hi:3 ~low:32

let () =
  eq __LOC__ (!u, 4)

type null_obj

external hh : null_obj   -> int = "hh" [@@mel.send] (* it also work *)
external ff : null_obj -> unit  -> int = "ff" [@@mel.send]
external ff_pipe :  unit  -> int = "ff_pipe" [@@mel.send.pipe: null_obj]
external ff_pipe2 :   int = "ff_pipe2" [@@mel.send.pipe: null_obj] (* FIXME *)
let vv z = hh z

let v z = ff z ()

let vvv z = z |> ff_pipe ()

let vvvv z = z |> ff_pipe2
let create_prim () =  [%obj{ x' = 3 ; x'' = 3; x'''' = 2}]

type t
external setGADT : t -> ('a kind [@mel.ignore]) -> 'a ->  unit = "setGADT" [@@mel.set]
external setGADT2 :
 t ->
 ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore]) ->
 ('a * 'b) ->  unit = "setGADT2" [@@mel.set]

external getGADT : t -> ('a kind [@mel.ignore]) -> 'a  = "getGADT" [@@mel.get]

external getGADT2 :
 t -> ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore])
  -> ('a * 'b)  = "getGADT2" [@@mel.get]

external getGADTI2 :
 t -> ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore]) -> int
  -> ('a * 'b)  = "" [@@mel.get_index]

external getGADTI3 :
 t -> ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore]) -> (_ [@mel.as 3])
  -> ('a * 'b)  = "" [@@mel.get_index]

external setGADTI2 :
 t -> ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore]) -> int
  -> ('a * 'b) -> unit  = "" [@@mel.set_index]

external setGADTI3 :
 t -> ('a kind [@mel.ignore]) ->
 ('b kind [@mel.ignore]) -> (_ [@mel.as 3] )
  -> ('a * 'b) -> unit  = "" [@@mel.set_index]

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
