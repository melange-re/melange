type synthetic('a) = ReactEvent.synthetic('a);

module MakeSyntheticWrapper = (Type: {type t;}) => {
  [@mel.get] external bubbles: Type.t => bool = "bubbles";
  [@mel.get] external cancelable: Type.t => bool = "cancelable";
  [@mel.get] external currentTarget: Type.t => Dom.element = "currentTarget"; /* Should return Dom.evetTarget */
  [@mel.get] external defaultPrevented: Type.t => bool = "defaultPrevented";
  [@mel.get] external eventPhase: Type.t => int = "eventPhase";
  [@mel.get] external isTrusted: Type.t => bool = "isTrusted";
  [@mel.get] external nativeEvent: Type.t => Js.t({..}) = "nativeEvent"; /* Should return Dom.event */
  [@mel.send.pipe: Type.t] external preventDefault: unit = "preventDefault";
  [@mel.send.pipe: Type.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@mel.send.pipe: Type.t] external stopPropagation: unit = "stopPropagation";
  [@mel.send.pipe: Type.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@mel.get] external target: Type.t => Dom.element = "target"; /* Should return Dom.evetTarget */
  [@mel.get] external timeStamp: Type.t => float = "timeStamp";
  [@mel.get] external _type: Type.t => string = "type";
  [@mel.send.pipe: Type.t] external persist: unit = "persist";
};

module Synthetic = {
  type tag = ReactEvent.Synthetic.tag;
  type t = ReactEvent.Synthetic.t;
  [@mel.get] external bubbles: synthetic('a) => bool = "bubbles";
  [@mel.get] external cancelable: synthetic('a) => bool = "cancelable";
  [@mel.get]
  external currentTarget: synthetic('a) => Dom.element = "currentTarget"; /* Should return Dom.evetTarget */
  [@mel.get]
  external defaultPrevented: synthetic('a) => bool = "defaultPrevented";
  [@mel.get] external eventPhase: synthetic('a) => int = "eventPhase";
  [@mel.get] external isTrusted: synthetic('a) => bool = "isTrusted";
  [@mel.get]
  external nativeEvent: synthetic('a) => Js.t({..}) = "nativeEvent"; /* Should return Dom.event */
  [@mel.send.pipe: synthetic('a)]
  external preventDefault: unit = "preventDefault";
  [@mel.send.pipe: synthetic('a)]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@mel.send.pipe: synthetic('a)]
  external stopPropagation: unit = "stopPropagation";
  [@mel.send.pipe: synthetic('a)]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@mel.get] external target: synthetic('a) => Dom.element = "target"; /* Should return Dom.evetTarget */
  [@mel.get] external timeStamp: synthetic('a) => float = "timeStamp";
  [@mel.get] external _type: synthetic('a) => string = "type";
  [@mel.send.pipe: synthetic('a)] external persist: unit = "persist";
};

/* Cast any event type to the general synthetic type. This is safe, since synthetic is more general */
external toSyntheticEvent: synthetic('a) => Synthetic.t = "%identity";

module Clipboard = {
  type tag = ReactEvent.Clipboard.tag;
  type t = ReactEvent.Clipboard.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external clipboardData: t => Js.t({..}) = "clipboardData"; /* Should return Dom.dataTransfer */
};

module Composition = {
  type tag = ReactEvent.Composition.tag;
  type t = ReactEvent.Composition.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external data: t => string = "data";
};

module Keyboard = {
  type tag = ReactEvent.Keyboard.tag;
  type t = ReactEvent.Keyboard.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external altKey: t => bool = "altKey";
  [@mel.get] external charCode: t => int = "charCode";
  [@mel.get] external ctrlKey: t => bool = "ctrlKey";
  [@mel.send.pipe: t]
  external getModifierState: string => bool = "getModifierState";
  [@mel.get] external key: t => string = "key";
  [@mel.get] external keyCode: t => int = "keyCode";
  [@mel.get] external locale: t => string = "locale";
  [@mel.get] external location: t => int = "location";
  [@mel.get] external metaKey: t => bool = "metaKey";
  [@mel.get] external repeat: t => bool = "repeat";
  [@mel.get] external shiftKey: t => bool = "shiftKey";
  [@mel.get] external which: t => int = "which";
};

module Focus = {
  type tag = ReactEvent.Focus.tag;
  type t = ReactEvent.Focus.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external relatedTarget: t => Dom.element = "relatedTarget"; /* Should return Dom.eventTarget */
};

module Form = {
  type tag = ReactEvent.Form.tag;
  type t = ReactEvent.Form.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
};

module Mouse = {
  type tag = ReactEvent.Mouse.tag;
  type t = ReactEvent.Mouse.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external altKey: t => bool = "altKey";
  [@mel.get] external button: t => int = "button";
  [@mel.get] external buttons: t => int = "buttons";
  [@mel.get] external clientX: t => int = "clientX";
  [@mel.get] external clientY: t => int = "clientY";
  [@mel.get] external ctrlKey: t => bool = "ctrlKey";
  [@mel.send.pipe: t]
  external getModifierState: string => bool = "getModifierState";
  [@mel.get] external metaKey: t => bool = "metaKey";
  [@mel.get] external pageX: t => int = "pageX";
  [@mel.get] external pageY: t => int = "pageY";
  [@mel.get] external relatedTarget: t => Dom.element = "relatedTarget"; /* Should return Dom.eventTarget */
  [@mel.get] external screenX: t => int = "screenX";
  [@mel.get] external screenY: t => int = "screenY";
  [@mel.get] external shiftKey: t => bool = "shiftKey";
};

module Selection = {
  type tag = ReactEvent.Selection.tag;
  type t = ReactEvent.Selection.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
};

module Touch = {
  type tag = ReactEvent.Touch.tag;
  type t = ReactEvent.Touch.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external altKey: t => bool = "altKey";
  [@mel.get] external changedTouches: t => Js.t({..}) = "changedTouches"; /* Should return Dom.touchList */
  [@mel.get] external ctrlKey: t => bool = "ctrlKey";
  [@mel.send.pipe: t]
  external getModifierState: string => bool = "getModifierState";
  [@mel.get] external metaKey: t => bool = "metaKey";
  [@mel.get] external shiftKey: t => bool = "shiftKey";
  [@mel.get] external targetTouches: t => Js.t({..}) = "targetTouches"; /* Should return Dom.touchList */
  [@mel.get] external touches: t => Js.t({..}) = "touches"; /* Should return Dom.touchList */
};

module UI = {
  type tag = ReactEvent.UI.tag;
  type t = ReactEvent.UI.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external detail: t => int = "detail";
  [@mel.get] external view: t => Dom.window = "view"; /* Should return DOMAbstractView/WindowProxy */
};

module Wheel = {
  type tag = ReactEvent.Wheel.tag;
  type t = ReactEvent.Wheel.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external deltaMode: t => int = "deltaMode";
  [@mel.get] external deltaX: t => float = "deltaX";
  [@mel.get] external deltaY: t => float = "deltaY";
  [@mel.get] external deltaZ: t => float = "deltaZ";
};

module Media = {
  type tag = ReactEvent.Media.tag;
  type t = ReactEvent.Media.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
};

module Image = {
  type tag = ReactEvent.Image.tag;
  type t = ReactEvent.Image.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
};

module Animation = {
  type tag = ReactEvent.Animation.tag;
  type t = ReactEvent.Animation.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external animationName: t => string = "animationName";
  [@mel.get] external pseudoElement: t => string = "pseudoElement";
  [@mel.get] external elapsedTime: t => float = "elapsedTime";
};

module Transition = {
  type tag = ReactEvent.Transition.tag;
  type t = ReactEvent.Transition.t;
  include MakeSyntheticWrapper({
    type nonrec t = t;
  });
  [@mel.get] external propertyName: t => string = "propertyName";
  [@mel.get] external pseudoElement: t => string = "pseudoElement";
  [@mel.get] external elapsedTime: t => float = "elapsedTime";
};
