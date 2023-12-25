let uux_this : < length : int > Js.t -> int -> int -> int [@mel.this]
  =
  fun[@mel.this] o x y -> o##length + x + y

let  even = fun [@mel.this] o x ->  x + o

let bark () =
  fun [@mel.this] (o : 'self) x y ->
    begin
      Js.log (o##length, o##x, o##y,x,y);
      x + y
    end

let js_obj : 'self =
  [%mel.obj
      {
        bark =
          (fun [@mel.this] (o : 'self) x y ->
            Js.log o;
            x + y
          );

      }
  ]
class type _x = object [@u]
  method onload : _x Js.t -> unit [@mel.this] [@@mel.set]
  method addEventListener : string -> (_x Js.t -> unit [@mel.this]) -> unit
  method response : string
end
type x = _x Js.t

let f (x : x ) =
  begin
    x##onload #=  (fun [@mel.this] o -> Js.log o);
    x##addEventListener "onload" begin fun [@mel.this] o ->
      Js.log o##response
    end
  end

let u = fun [@mel.this] (_ : int) (x : int) -> x
