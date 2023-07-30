let uux_this : < length : int > Js.t -> int -> int -> int [@bs.this]
  =
  fun[@bs.this] o x y -> o##length + x + y

let  even = fun [@bs.this] o x ->  x + o

let bark () =
  fun [@bs.this] (o : 'self) x y ->
    begin
      Js.log (o##length, o##x, o##y,x,y);
      x + y
    end

let js_obj : 'self =
  [%mel.obj
      {
        bark =
          (fun [@bs.this] (o : 'self) x y ->
            Js.log o;
            x + y
          );

      }
  ]
class type _x = object [@u]
  method onload : _x Js.t -> unit [@this] [@@bs.set]
  method addEventListener : string -> (_x Js.t -> unit [@bs.this]) -> unit
  method response : string
end
type x = _x Js.t

let f (x : x ) =
  begin
    x##onload #=  (fun [@bs.this] o -> Js.log o);
    x##addEventListener "onload" begin fun [@bs.this] o ->
      Js.log o##response
    end
  end

let u = fun [@this] (_ : int) (x : int) -> x
