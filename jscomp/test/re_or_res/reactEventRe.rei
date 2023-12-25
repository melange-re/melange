/* Old code. See ReactEvent.re for documentation. */
[@deprecated "Please use ReactEvent.synthetic"]
type synthetic('a) = ReactEvent.synthetic('a);

module Synthetic: {
  [@deprecated "Please use ReactEvent.Synthetic.tag"]
  type tag = ReactEvent.Synthetic.tag;
  [@deprecated "Please use ReactEvent.Synthetic.t"]
  type t = ReactEvent.Synthetic.t;
  [@deprecated "Please use ReactEvent.Synthetic.bubbles"] [@mel.get]
  external bubbles: ReactEvent.synthetic('a) => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Synthetic.cancelable"] [@mel.get]
  external cancelable: ReactEvent.synthetic('a) => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Synthetic.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.synthetic('a) => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Synthetic.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.synthetic('a) => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Synthetic.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.synthetic('a) => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Synthetic.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.synthetic('a) => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Synthetic.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.synthetic('a) => Js.t({..}) =
    "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Synthetic.preventDefault"]
  [@mel.send.pipe: ReactEvent.synthetic('a)]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Synthetic.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.synthetic('a)]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Synthetic.stopPropagation"]
  [@mel.send.pipe: ReactEvent.synthetic('a)]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Synthetic.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.synthetic('a)]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Synthetic.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.synthetic('a) => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Synthetic.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.synthetic('a) => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Synthetic.type_"] [@mel.get]
  external _type: ReactEvent.synthetic('a) => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Synthetic.persist"]
  [@mel.send.pipe: ReactEvent.synthetic('a)]
  external persist: unit = "persist";
};

/* Cast any event type to the general synthetic type. This is safe, since synthetic is more general */
[@deprecated "Please use ReactEvent.toSyntheticEvent"]
external toSyntheticEvent: ReactEvent.synthetic('a) => ReactEvent.Synthetic.t =
  "%identity";

module Clipboard: {
  [@deprecated "Please use ReactEvent.Clipboard.tag"]
  type tag = ReactEvent.Clipboard.tag;
  [@deprecated "Please use ReactEvent.Clipboard.tag"]
  type t = ReactEvent.Clipboard.t;
  [@deprecated "Please use ReactEvent.Clipboard.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Clipboard.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Clipboard.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Clipboard.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Clipboard.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Clipboard.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Clipboard.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Clipboard.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Clipboard.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Clipboard.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Clipboard.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Clipboard.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Clipboard.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Clipboard.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Clipboard.preventDefault"]
  [@mel.send.pipe: ReactEvent.Clipboard.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Clipboard.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Clipboard.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Clipboard.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Clipboard.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Clipboard.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Clipboard.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Clipboard.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Clipboard.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Clipboard.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Clipboard.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Clipboard.type_"] [@mel.get]
  external _type: ReactEvent.Clipboard.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Clipboard.persist"]
  [@mel.send.pipe: ReactEvent.Clipboard.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Clipboard.clipboardData"] [@mel.get]
  external clipboardData: ReactEvent.Clipboard.t => Js.t({..}) =
    "clipboardData"; /* Should return Dom.dataTransfer */
};

module Composition: {
  [@deprecated "Please use ReactEvent.Composition.tag"]
  type tag = ReactEvent.Composition.tag;
  [@deprecated "Please use ReactEvent.Composition.t"]
  type t = ReactEvent.Composition.t;
  [@deprecated "Please use ReactEvent.Composition.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Composition.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Composition.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Composition.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Composition.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Composition.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Composition.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Composition.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Composition.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Composition.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Composition.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Composition.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Composition.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Composition.t => Js.t({..}) =
    "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Composition.preventDefault"]
  [@mel.send.pipe: ReactEvent.Composition.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Composition.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Composition.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Composition.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Composition.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated
    "Please use myEvent->ReactEvent.Composition.isPropagationStopped"
  ]
  [@mel.send.pipe: ReactEvent.Composition.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Composition.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Composition.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Composition.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Composition.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Composition.type_"] [@mel.get]
  external _type: ReactEvent.Composition.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Composition.persist"]
  [@mel.send.pipe: ReactEvent.Composition.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Composition.data"] [@mel.get]
  external data: ReactEvent.Composition.t => string = "data";
};

module Keyboard: {
  [@deprecated "Please use ReactEvent.Keyboard.tag"]
  type tag = ReactEvent.Keyboard.tag;
  [@deprecated "Please use ReactEvent.Keyboard.t"]
  type t = ReactEvent.Keyboard.t;
  [@deprecated "Please use ReactEvent.Keyboard.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Keyboard.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Keyboard.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Keyboard.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Keyboard.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Keyboard.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Keyboard.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Keyboard.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Keyboard.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Keyboard.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Keyboard.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Keyboard.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Keyboard.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Keyboard.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.preventDefault"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Keyboard.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Keyboard.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Keyboard.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Keyboard.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Keyboard.type_"] [@mel.get]
  external _type: ReactEvent.Keyboard.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.persist"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Keyboard.altKey"] [@mel.get]
  external altKey: ReactEvent.Keyboard.t => bool = "altKey";
  [@deprecated "Please use ReactEvent.Keyboard.charCode"] [@mel.get]
  external charCode: ReactEvent.Keyboard.t => int = "charCode";
  [@deprecated "Please use ReactEvent.Keyboard.ctrlKey"] [@mel.get]
  external ctrlKey: ReactEvent.Keyboard.t => bool = "ctrlKey";
  [@deprecated "Please use myEvent->ReactEvent.Keyboard.getModifierState"]
  [@mel.send.pipe: ReactEvent.Keyboard.t]
  external getModifierState: string => bool = "getModifierState";
  [@deprecated "Please use ReactEvent.Keyboard.key"] [@mel.get]
  external key: ReactEvent.Keyboard.t => string = "key";
  [@deprecated "Please use ReactEvent.Keyboard.keyCode"] [@mel.get]
  external keyCode: ReactEvent.Keyboard.t => int = "keyCode";
  [@deprecated "Please use ReactEvent.Keyboard.locale"] [@mel.get]
  external locale: ReactEvent.Keyboard.t => string = "locale";
  [@deprecated "Please use ReactEvent.Keyboard.location"] [@mel.get]
  external location: ReactEvent.Keyboard.t => int = "location";
  [@deprecated "Please use ReactEvent.Keyboard.metaKey"] [@mel.get]
  external metaKey: ReactEvent.Keyboard.t => bool = "metaKey";
  [@deprecated "Please use ReactEvent.Keyboard.repeat"] [@mel.get]
  external repeat: ReactEvent.Keyboard.t => bool = "repeat";
  [@deprecated "Please use ReactEvent.Keyboard.shiftKey"] [@mel.get]
  external shiftKey: ReactEvent.Keyboard.t => bool = "shiftKey";
  [@deprecated "Please use ReactEvent.Keyboard.which"] [@mel.get]
  external which: ReactEvent.Keyboard.t => int = "which";
};

module Focus: {
  [@deprecated "Please use ReactEvent.Focus.tag"]
  type tag = ReactEvent.Focus.tag;
  [@deprecated "Please use ReactEvent.Focus.t"]
  type t = ReactEvent.Focus.t;
  [@deprecated "Please use ReactEvent.Focus.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Focus.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Focus.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Focus.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Focus.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Focus.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Focus.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Focus.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Focus.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Focus.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Focus.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Focus.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Focus.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Focus.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Focus.preventDefault"]
  [@mel.send.pipe: ReactEvent.Focus.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Focus.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Focus.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Focus.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Focus.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Focus.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Focus.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Focus.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Focus.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Focus.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Focus.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Focus.type_"] [@mel.get]
  external _type: ReactEvent.Focus.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Focus.persist"]
  [@mel.send.pipe: ReactEvent.Focus.t]
  external persist: unit = "persist";
  [@deprecated
    "Please use ReactEvent.Focus.relatedTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external relatedTarget: ReactEvent.Focus.t => Dom.element = "relatedTarget"; /* Should return Dom.eventTarget */
};

module Form: {
  [@deprecated "Please use ReactEvent.Form.tag"]
  type tag = ReactEvent.Form.tag;
  [@deprecated "Please use ReactEvent.Form.t"]
  type t = ReactEvent.Form.t;
  [@deprecated "Please use ReactEvent.Form.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Form.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Form.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Form.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Form.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Form.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Form.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Form.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Form.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Form.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Form.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Form.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Form.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Form.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Form.preventDefault"]
  [@mel.send.pipe: ReactEvent.Form.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Form.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Form.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Form.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Form.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Form.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Form.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Form.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Form.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Form.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Form.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Form.type_"] [@mel.get]
  external _type: ReactEvent.Form.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Form.persist"]
  [@mel.send.pipe: ReactEvent.Form.t]
  external persist: unit = "persist";
};

module Mouse: {
  [@deprecated "Please use ReactEvent.Mouse.tag"]
  type tag = ReactEvent.Mouse.tag;
  [@deprecated "Please use ReactEvent.Mouse.t"]
  type t = ReactEvent.Mouse.t;
  [@deprecated "Please use ReactEvent.Mouse.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Mouse.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Mouse.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Mouse.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Mouse.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Mouse.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Mouse.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Mouse.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Mouse.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Mouse.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Mouse.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Mouse.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Mouse.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Mouse.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.preventDefault"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Mouse.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Mouse.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Mouse.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Mouse.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Mouse.type_"] [@mel.get]
  external _type: ReactEvent.Mouse.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.persist"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Mouse.altKey"] [@mel.get]
  external altKey: ReactEvent.Mouse.t => bool = "altKey";
  [@deprecated "Please use ReactEvent.Mouse.button"] [@mel.get]
  external button: ReactEvent.Mouse.t => int = "button";
  [@deprecated "Please use ReactEvent.Mouse.buttons"] [@mel.get]
  external buttons: ReactEvent.Mouse.t => int = "buttons";
  [@deprecated "Please use ReactEvent.Mouse.clientX"] [@mel.get]
  external clientX: ReactEvent.Mouse.t => int = "clientX";
  [@deprecated "Please use ReactEvent.Mouse.clientY"] [@mel.get]
  external clientY: ReactEvent.Mouse.t => int = "clientY";
  [@deprecated "Please use ReactEvent.Mouse.ctrlKey"] [@mel.get]
  external ctrlKey: ReactEvent.Mouse.t => bool = "ctrlKey";
  [@deprecated "Please use myEvent->ReactEvent.Mouse.getModifierState"]
  [@mel.send.pipe: ReactEvent.Mouse.t]
  external getModifierState: string => bool = "getModifierState";
  [@deprecated "Please use ReactEvent.Mouse.metaKey"] [@mel.get]
  external metaKey: ReactEvent.Mouse.t => bool = "metaKey";
  [@deprecated "Please use ReactEvent.Mouse.pageX"] [@mel.get]
  external pageX: ReactEvent.Mouse.t => int = "pageX";
  [@deprecated "Please use ReactEvent.Mouse.pageY"] [@mel.get]
  external pageY: ReactEvent.Mouse.t => int = "pageY";
  [@deprecated
    "Please use ReactEvent.Mouse.relatedTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external relatedTarget: ReactEvent.Mouse.t => Dom.element = "relatedTarget"; /* Should return Dom.eventTarget */
  [@deprecated "Please use ReactEvent.Mouse.screenX"] [@mel.get]
  external screenX: ReactEvent.Mouse.t => int = "screenX";
  [@deprecated "Please use ReactEvent.Mouse.screenY"] [@mel.get]
  external screenY: ReactEvent.Mouse.t => int = "screenY";
  [@deprecated "Please use ReactEvent.Mouse.shiftKey"] [@mel.get]
  external shiftKey: ReactEvent.Mouse.t => bool = "shiftKey";
};

module Selection: {
  [@deprecated "Please use ReactEvent.Selection.tag"]
  type tag = ReactEvent.Selection.tag;
  [@deprecated "Please use ReactEvent.Selection.t"]
  type t = ReactEvent.Selection.t;
  [@deprecated "Please use ReactEvent.Selection.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Selection.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Selection.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Selection.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Selection.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Selection.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Selection.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Selection.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Selection.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Selection.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Selection.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Selection.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Selection.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Selection.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Selection.preventDefault"]
  [@mel.send.pipe: ReactEvent.Selection.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Selection.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Selection.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Selection.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Selection.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Selection.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Selection.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Selection.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Selection.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Selection.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Selection.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Selection.type_"] [@mel.get]
  external _type: ReactEvent.Selection.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Selection.persist"]
  [@mel.send.pipe: ReactEvent.Selection.t]
  external persist: unit = "persist";
};

module Touch: {
  [@deprecated "Please use ReactEvent.Touch.tag"]
  type tag = ReactEvent.Touch.tag;
  [@deprecated "Please use ReactEvent.Touch.t"]
  type t = ReactEvent.Touch.t;
  [@deprecated "Please use ReactEvent.Touch.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Touch.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Touch.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Touch.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Touch.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Touch.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Touch.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Touch.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Touch.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Touch.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Touch.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Touch.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Touch.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Touch.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Touch.preventDefault"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Touch.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Touch.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Touch.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Touch.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Touch.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Touch.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Touch.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Touch.type_"] [@mel.get]
  external _type: ReactEvent.Touch.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Touch.persist"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Touch.altKey"] [@mel.get]
  external altKey: ReactEvent.Touch.t => bool = "altKey";
  [@deprecated "Please use ReactEvent.Touch.changedTouches"] [@mel.get]
  external changedTouches: ReactEvent.Touch.t => Js.t({..}) =
    "changedTouches"; /* Should return Dom.touchList */
  [@deprecated "Please use ReactEvent.Touch.ctrlKey"] [@mel.get]
  external ctrlKey: ReactEvent.Touch.t => bool = "ctrlKey";
  [@deprecated "Please use myEvent->ReactEvent.Touch.getModifierState"]
  [@mel.send.pipe: ReactEvent.Touch.t]
  external getModifierState: string => bool = "getModifierState";
  [@deprecated "Please use ReactEvent.Touch.metaKey"] [@mel.get]
  external metaKey: ReactEvent.Touch.t => bool = "metaKey";
  [@deprecated "Please use ReactEvent.Touch.shiftKey"] [@mel.get]
  external shiftKey: ReactEvent.Touch.t => bool = "shiftKey";
  [@deprecated "Please use ReactEvent.Touch.targetTouches"] [@mel.get]
  external targetTouches: ReactEvent.Touch.t => Js.t({..}) = "targetTouches"; /* Should return Dom.touchList */
  [@deprecated "Please use ReactEvent.Touch.touches"] [@mel.get]
  external touches: ReactEvent.Touch.t => Js.t({..}) = "touches"; /* Should return Dom.touchList */
};

module UI: {
  [@deprecated "Please use ReactEvent.UI.tag"]
  type tag = ReactEvent.UI.tag;
  [@deprecated "Please use ReactEvent.UI.t"]
  type t = ReactEvent.UI.t;
  [@deprecated "Please use ReactEvent.UI.bubbles"] [@mel.get]
  external bubbles: ReactEvent.UI.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.UI.cancelable"] [@mel.get]
  external cancelable: ReactEvent.UI.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.UI.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.UI.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.UI.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.UI.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.UI.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.UI.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.UI.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.UI.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.UI.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.UI.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.UI.preventDefault"]
  [@mel.send.pipe: ReactEvent.UI.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.UI.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.UI.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.UI.stopPropagation"]
  [@mel.send.pipe: ReactEvent.UI.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.UI.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.UI.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.UI.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.UI.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.UI.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.UI.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.UI.type_"] [@mel.get]
  external _type: ReactEvent.UI.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.UI.persist"]
  [@mel.send.pipe: ReactEvent.UI.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.UI.detail"] [@mel.get]
  external detail: ReactEvent.UI.t => int = "detail";
  [@deprecated "Please use ReactEvent.UI.view"] [@mel.get]
  external view: ReactEvent.UI.t => Dom.window = "view"; /* Should return DOMAbstractView/WindowProxy */
};

module Wheel: {
  [@deprecated "Please use ReactEvent.Wheel.tag"]
  type tag = ReactEvent.Wheel.tag;
  [@deprecated "Please use ReactEvent.Wheel.t"]
  type t = ReactEvent.Wheel.t;
  [@deprecated "Please use ReactEvent.Wheel.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Wheel.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Wheel.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Wheel.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Wheel.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Wheel.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Wheel.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Wheel.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Wheel.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Wheel.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Wheel.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Wheel.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Wheel.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Wheel.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Wheel.preventDefault"]
  [@mel.send.pipe: ReactEvent.Wheel.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Wheel.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Wheel.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Wheel.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Wheel.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Wheel.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Wheel.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Wheel.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Wheel.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Wheel.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Wheel.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Wheel.type_"] [@mel.get]
  external _type: ReactEvent.Wheel.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Wheel.persist"]
  [@mel.send.pipe: ReactEvent.Wheel.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Wheel.deltaMode"] [@mel.get]
  external deltaMode: ReactEvent.Wheel.t => int = "deltaMode";
  [@deprecated "Please use ReactEvent.Wheel.deltaX"] [@mel.get]
  external deltaX: ReactEvent.Wheel.t => float = "deltaX";
  [@deprecated "Please use ReactEvent.Wheel.deltaY"] [@mel.get]
  external deltaY: ReactEvent.Wheel.t => float = "deltaY";
  [@deprecated "Please use ReactEvent.Wheel.deltaZ"] [@mel.get]
  external deltaZ: ReactEvent.Wheel.t => float = "deltaZ";
};

module Media: {
  [@deprecated "Please use ReactEvent.Media.tag"]
  type tag = ReactEvent.Media.tag;
  [@deprecated "Please use ReactEvent.Media.t"]
  type t = ReactEvent.Media.t;
  [@deprecated "Please use ReactEvent.Media.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Media.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Media.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Media.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Media.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Media.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Media.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Media.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Media.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Media.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Media.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Media.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Media.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Media.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Media.preventDefault"]
  [@mel.send.pipe: ReactEvent.Media.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Media.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Media.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Media.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Media.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Media.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Media.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Media.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Media.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Media.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Media.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Media.type_"] [@mel.get]
  external _type: ReactEvent.Media.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Media.persist"]
  [@mel.send.pipe: ReactEvent.Media.t]
  external persist: unit = "persist";
};

module Image: {
  [@deprecated "Please use ReactEvent.Image.tag"]
  type tag = ReactEvent.Image.tag;
  [@deprecated "Please use ReactEvent.Image.t"]
  type t = ReactEvent.Image.t;
  [@deprecated "Please use ReactEvent.Image.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Image.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Image.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Image.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Image.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Image.t => Dom.element = "currentTarget";
  [@deprecated "Please use ReactEvent.Image.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Image.t => bool = "defaultPrevented";
  [@deprecated "Please use ReactEvent.Image.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Image.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Image.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Image.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Image.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Image.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Image.preventDefault"]
  [@mel.send.pipe: ReactEvent.Image.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Image.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Image.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Image.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Image.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Image.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Image.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Image.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Image.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Image.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Image.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Image.type_"] [@mel.get]
  external _type: ReactEvent.Image.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Image.persist"]
  [@mel.send.pipe: ReactEvent.Image.t]
  external persist: unit = "persist";
};

module Animation: {
  [@deprecated "Please use ReactEvent.Animation.tag"]
  type tag = ReactEvent.Animation.tag;
  [@deprecated "Please use ReactEvent.Animation.t"]
  type t = ReactEvent.Animation.t;
  [@deprecated "Please use ReactEvent.Animation.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Animation.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Animation.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Animation.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Animation.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Animation.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Animation.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Animation.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Animation.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Animation.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Animation.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Animation.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Animation.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Animation.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Animation.preventDefault"]
  [@mel.send.pipe: ReactEvent.Animation.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Animation.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Animation.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Animation.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Animation.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated "Please use myEvent->ReactEvent.Animation.isPropagationStopped"]
  [@mel.send.pipe: ReactEvent.Animation.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Animation.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Animation.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Animation.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Animation.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Animation.type_"] [@mel.get]
  external _type: ReactEvent.Animation.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Animation.persist"]
  [@mel.send.pipe: ReactEvent.Animation.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Animation.animationName"] [@mel.get]
  external animationName: ReactEvent.Animation.t => string = "animationName";
  [@deprecated "Please use ReactEvent.Animation.pseudoElement"] [@mel.get]
  external pseudoElement: ReactEvent.Animation.t => string = "pseudoElement";
  [@deprecated "Please use ReactEvent.Animation.elapsedTime"] [@mel.get]
  external elapsedTime: ReactEvent.Animation.t => float = "elapsedTime";
};

module Transition: {
  [@deprecated "Please use ReactEvent.Transition.tag"]
  type tag = ReactEvent.Transition.tag;
  [@deprecated "Please use ReactEvent.Transition.t"]
  type t = ReactEvent.Transition.t;
  [@deprecated "Please use ReactEvent.Transition.bubbles"] [@mel.get]
  external bubbles: ReactEvent.Transition.t => bool = "bubbles";
  [@deprecated "Please use ReactEvent.Transition.cancelable"] [@mel.get]
  external cancelable: ReactEvent.Transition.t => bool = "cancelable";
  [@deprecated
    "Please use ReactEvent.Transition.currentTarget and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external currentTarget: ReactEvent.Transition.t => Dom.element =
    "currentTarget";
  [@deprecated "Please use ReactEvent.Transition.defaultPrevented"] [@mel.get]
  external defaultPrevented: ReactEvent.Transition.t => bool =
    "defaultPrevented";
  [@deprecated "Please use ReactEvent.Transition.eventPhase"] [@mel.get]
  external eventPhase: ReactEvent.Transition.t => int = "eventPhase";
  [@deprecated "Please use ReactEvent.Transition.isTrusted"] [@mel.get]
  external isTrusted: ReactEvent.Transition.t => bool = "isTrusted";
  [@deprecated "Please use ReactEvent.Transition.nativeEvent"] [@mel.get]
  external nativeEvent: ReactEvent.Transition.t => Js.t({..}) = "nativeEvent";
  [@deprecated "Please use myEvent->ReactEvent.Transition.preventDefault"]
  [@mel.send.pipe: ReactEvent.Transition.t]
  external preventDefault: unit = "preventDefault";
  [@deprecated "Please use myEvent->ReactEvent.Transition.isDefaultPrevented"]
  [@mel.send.pipe: ReactEvent.Transition.t]
  external isDefaultPrevented: bool = "isDefaultPrevented";
  [@deprecated "Please use myEvent->ReactEvent.Transition.stopPropagation"]
  [@mel.send.pipe: ReactEvent.Transition.t]
  external stopPropagation: unit = "stopPropagation";
  [@deprecated
    "Please use myEvent->ReactEvent.Transition.isPropagationStopped"
  ]
  [@mel.send.pipe: ReactEvent.Transition.t]
  external isPropagationStopped: bool = "isPropagationStopped";
  [@deprecated
    "Please use ReactEvent.Transition.target and remove the surrounding ReactDOMRe.domElementToObj wrapper if any (no longer needed)"
  ]
  [@mel.get]
  external target: ReactEvent.Transition.t => Dom.element = "target";
  [@deprecated "Please use ReactEvent.Transition.timeStamp"] [@mel.get]
  external timeStamp: ReactEvent.Transition.t => float = "timeStamp";
  [@deprecated "Please use ReactEvent.Transition.type_"] [@mel.get]
  external _type: ReactEvent.Transition.t => string = "type";
  [@deprecated "Please use myEvent->ReactEvent.Transition.persist"]
  [@mel.send.pipe: ReactEvent.Transition.t]
  external persist: unit = "persist";
  [@deprecated "Please use ReactEvent.Transition.propertyName"] [@mel.get]
  external propertyName: ReactEvent.Transition.t => string = "propertyName";
  [@deprecated "Please use ReactEvent.Transition.pseudoElement"] [@mel.get]
  external pseudoElement: ReactEvent.Transition.t => string = "pseudoElement";
  [@deprecated "Please use ReactEvent.Transition.elapsedTime"] [@mel.get]
  external elapsedTime: ReactEvent.Transition.t => float = "elapsedTime";
};
