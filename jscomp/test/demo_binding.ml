class type titlex =
  object
    method title : string [@@mel.set] [@@mel.get {null ; undefined}]
  end[@u]

class type widget =
  object
      method on : string ->  (event -> unit [@u]) -> unit
  end[@u]
and  event =
  object
    method source : widget
    method target : widget
  end[@u]


class type title =
  object
    method title : string [@@mel.set]
  end[@u]

class type text =
  object
    method text : string [@@mel.set]
  end[@u]

class type measure =
    object
      method minHeight : int [@@mel.set]
      method minWidth : int [@@mel.set]
      method maxHeight : int  [@@mel.set]
      method maxWidth : int [@@mel.set]
    end[@u]

class type layout =
    object
      method orientation : string [@@mel.set]
    end[@u]

class type applicationContext =
  object
    method exit : int -> unit
  end[@u]
class type contentable =
  object
    method content : #widget Js.t [@@mel.set]
    method contentWidth : int  [@@mel.set]
  end[@u]

class type hostedWindow =
  object
    inherit widget
    inherit title
    inherit contentable
    method show : unit -> unit
    method hide : unit -> unit
    method focus : unit -> unit
    method appContext : applicationContext [@@mel.set]
  end[@u]

class type hostedContent =
  object
    inherit widget
    inherit contentable
  end[@u]


class type stackPanel =
  object
    inherit measure
    inherit layout
    inherit widget

    method addChild : #widget Js.t -> unit

  end[@u]

class type grid  =
  object
    inherit widget
    inherit measure
    method columns :  <width : int; .. >  Js.t  array [@@mel.set]
    method titleRows :
       <label : <text : string; .. > Js.t   ; ..> Js.t   array [@@mel.set]
    method dataSource :
       <label : <text : string; .. >  Js.t ; ..>  Js.t  array array [@@mel.set]
  end[@u]


class type button =
  object
    inherit widget
    inherit text
    inherit measure
  end[@u]

class type textArea =
  object
    inherit widget
    inherit measure
    inherit text
  end[@u]


external set_interval : (unit -> unit [@u0]) -> float -> unit  =  "setInterval"
     [@@mel.module "@runtime", "Runtime"]

external toFixed : float -> int -> string = "toFixed" [@@mel.send]
