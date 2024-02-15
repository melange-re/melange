[@@@ocaml.warning "-3"]

let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc (x, y) =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


let v5  =
  object(self)
    val  x = 3
    val mutable y = 3
    method private setY v  =
      self##y #= 2 ;
      self##y, v
    method say () =
      self##x + self##y
    method private hihi u =
      self##x + self##say ()
    method private bark () =
      Js.log "bark"
    method xz () =  3
  end [@u]

let v =
  object(self)
    val x = 3
    val mutable y = 0
    method private reset () =
      self##y#= 0
    method  incr () =
      self##y #= (self##y + 1)
    (* TODO: the error message is confusing
       {[
         self##y #= self##y + 1
       ]}
       will be parsed as
       {[
         (self##y #= self##y) + 1
       ]}
       if we change `#=` into `:=` then
       it will not work if `self##y` is indeed a reference
       we need document this behavior
    *)
    method getY () = self##y
    method say () = self##x + self##y
  end[@u]


let u =
  object (self)
    method incr () = Js.log "hey"
    method getY () = 3
    method say () = 7
  end [@u]

let test_type = [u ; v]

let z : < getX : (unit -> int [@mel.meth]); setX : (int -> unit [@mel.meth]) > Js.t  =
  object (self)
    val x = ref 3
    method setX x = self##x := x
    method getX () =  ! (self##x)
  end [@u]

let eventObj  : <
  empty : (unit -> unit [@mel.meth]);
    needRebuild : (unit -> bool [@mel.meth]);
    push : string  * string -> unit [@mel.meth]
  >
  Js.t
  =
  object (self)
    val events : (string * string) array = [||]
    method empty () = Js.Array.removeFromInPlace (self##events) ~start:0 |. ignore
    method push a = (Js.Array.push (self##events) ~value:a |. ignore : unit )
    method needRebuild () = Array.length self##events <> 0
    (* method currentEvents () = self##events *)
  end [@u]

let test__ x = eventObj##push   x
let zz : < getX : (unit -> int [@mel.meth]); setX : (int -> unit [@mel.meth]) > Js.t=
  object (self)
    val mutable x =  3
    method setX x = self##x #= x
    method getX () =   (self##x)
  end [@u]

let test_type2 = [z;zz]

let () =
  eq __LOC__ (6, v5##say ());
  let a = v##say () in
  v##incr ();
  let b = v##say () in
  v##incr ();
  let c = v##say () in
  v##incr ();
  eq __LOC__ ((3,4,5) , (a,b,c));
  let aa = z##getX () in
  let () = z##setX 32 in
  let bb = z##getX () in
  eq __LOC__ ((3, 32), (aa,bb))

let () =
  Mt.from_pair_suites __MODULE__ !suites
