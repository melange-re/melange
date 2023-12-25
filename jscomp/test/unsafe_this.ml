let u : 'self =

    (
      [%obj{
        x = 3 ;
        y = 32 ;
        bark = (fun [@u] this x y -> Js.log (this##length, this##x, this##y));
        length = 32
      }] :
        <
        x : int ;
      y : int ;
      bark : 'self -> int ->  int -> unit [@u];
      length : int >      Js.t )



let u  = u#@bark u 1 2

let uux_this : < length : int > Js.t -> int -> int -> int [@mel.this]
  =
  fun[@mel.this] o x y -> o##length + x + y


type (-'this, +'tuple) u

(* type 'a fn = (< > Js.t, 'a) u *)

(* doesn't typecheck: no subtype *)
(*
let f (x : 'a fn) =
  (x  : 'a fn :>
     (< l : int ; y :int > Js.t, 'a) u  )
 *)
let h  (u : (< l : int ; y :int > Js.t, int) u) = u

(* let hh (x : 'a fn) = h (x : _ fn :>   (< l : int ; y :int > Js.t, int) u ) *)

(* let m = [%mel.method fun o (x,y) -> o##length < x && o##length > y ] *)

let should_okay = fun [@mel.this] self y u -> self + y + u
let should_okay2 = fun [@mel.this] (self : _ ) y u -> y + u
(* let should_fail = fun [@mel.this] (Some x as v) y u -> y + u *)

(*let f_fail = fun [@mel.this] (Some _ as x ) y u -> y + u*)
let f_okay = fun [@mel.this] ( _ as x ) y u -> y + u + x







let uu : 'self =

    (
      [%obj{
        x = 3 ;
        y = 32 ;
        bark =
          (fun [@mel.this] (o : 'self) (x : int) (y : int) ->
               Js.log (o##length, o##x, o##y,x,y));
        length = 32
      }] :
        <
        x : int ;
      y : int ;
      bark : ('self -> int -> int -> _ [@mel.this]);
      length : int >       Js.t)


let js_obj : 'self =
  [%mel.obj
      {
        x = 3 ;
        y = 32 ;
        bark =
          (fun [@mel.this] (o : 'self) x y ->
            Js.log (o##length, o##x, o##y,x,y);
            x + y
          );
        length = 32
      }
  ]
(* let h = js_obj#.bark(1,2) *)

(* let h = run_method2  uuu##bark uuu 1 2 *)
(* let hh = js_obj#.(bark (1,2)) *)


(*


[%mel.obj{
 x  = 3;
 y  = fun%method (o, x, y) ->
    Js.log (this##length, this##x, this##y)
}]
*)
