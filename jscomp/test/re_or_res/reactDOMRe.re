/* First time reading an OCaml/Reason/BuckleScript file? */
/* `external` is the foreign function call in OCaml. */
/* here we're saying `I guarantee that on the JS side, we have a `render` function in the module "react-dom"
   that takes in a reactElement, a dom element, and returns unit (nothing) */
/* It's like `let`, except you're pointing the implementation to the JS side. The compiler will inline these
   calls and add the appropriate `require("react-dom")` in the file calling this `render` */
[@bs.val] [@bs.module "react-dom"]
external render: (React.element, Dom.element) => unit = "render";

[@bs.val]
external _getElementsByClassName: string => array(Dom.element) =
  "document.getElementsByClassName";

[@bs.val] [@bs.return nullable]
external _getElementById: string => option(Dom.element) =
  "document.getElementById";

let renderToElementWithClassName = (reactElement, className) =>
  switch (_getElementsByClassName(className)) {
  | [||] =>
    Js.Console.error(
      "ReactDOMRe.renderToElementWithClassName: no element of class "
      ++ className
      ++ " found in the HTML.",
    )
  | elements => render(reactElement, Array.unsafe_get(elements, 0))
  };

let renderToElementWithId = (reactElement, id) =>
  switch (_getElementById(id)) {
  | None =>
    Js.Console.error(
      "ReactDOMRe.renderToElementWithId : no element of id "
      ++ id
      ++ " found in the HTML.",
    )
  | Some(element) => render(reactElement, element)
  };

module Experimental = {
  type root;

  [@bs.module "react-dom"]
  external createRoot: Dom.element => root = "createRoot";

  [@bs.send] external render: (root, React.element) => unit = "render";

  let createRootWithClassName = className =>
    switch (_getElementsByClassName(className)) {
    | [||] =>
      Error(
        "ReactDOMRe.Unstable.createRootWithClassName: no element of class "
        ++ className
        ++ " found in the HTML.",
      )
    | elements => Ok(createRoot(Array.unsafe_get(elements, 0)))
    };

  let createRootWithId = id =>
    switch (_getElementById(id)) {
    | None =>
      Error(
        "ReactDOMRe.Unstable.createRootWithId: no element of id "
        ++ id
        ++ " found in the HTML.",
      )
    | Some(element) => Ok(createRoot(element))
    };
};

[@bs.val] [@bs.module "react-dom"]
external hydrate: (React.element, Dom.element) => unit = "hydrate";

let hydrateToElementWithClassName = (reactElement, className) =>
  switch (_getElementsByClassName(className)) {
  | [||] =>
    Js.Console.error(
      "ReactDOMRe.hydrateToElementWithClassName: no element of class "
      ++ className
      ++ " found in the HTML.",
    )
  | elements => hydrate(reactElement, Array.unsafe_get(elements, 0))
  };

let hydrateToElementWithId = (reactElement, id) =>
  switch (_getElementById(id)) {
  | None =>
    raise(
      Invalid_argument(
        "ReactDOMRe.hydrateToElementWithId : no element of id "
        ++ id
        ++ " found in the HTML.",
      ),
    )
  | Some(element) => hydrate(reactElement, element)
  };

[@bs.val] [@bs.module "react-dom"]
external createPortal: (React.element, Dom.element) => React.element =
  "createPortal";

[@bs.val] [@bs.module "react-dom"]
external unmountComponentAtNode: Dom.element => unit =
  "unmountComponentAtNode";

[@bs.val] [@bs.module "react-dom"]
external findDOMNode: ReasonReact.reactRef => Dom.element = "findDOMNode";

external domElementToObj: Dom.element => Js.t({..}) = "%identity";

type style;

type domRef;

module Ref = {
  type t = domRef;
  type currentDomRef = React.ref(Js.nullable(Dom.element));
  type callbackDomRef = Js.nullable(Dom.element) => unit;

  external domRef: currentDomRef => domRef = "%identity";
  external callbackDomRef: callbackDomRef => domRef = "%identity";
};

/* This list isn't exhaustive. We'll add more as we go. */
/*
 * Watch out! There are two props types and the only difference is the type of ref.
 * Please keep in sync.
 */
[@deriving abstract]
type domProps = {
  [@bs.optional]
  key: option(string),
  [@bs.optional]
  ref: option(domRef),
  /* accessibility */
  /* https://www.w3.org/TR/wai-aria-1.1/ */
  /* https://accessibilityresources.org/<aria-tag> is a great resource for these */
  /* [@bs.optional] [@bs.as "aria-current"] ariaCurrent: page|step|location|date|time|true|false, */
  [@bs.optional] [@bs.as "aria-details"]
  ariaDetails: option(string),
  [@bs.optional] [@bs.as "aria-disabled"]
  ariaDisabled: option(bool),
  [@bs.optional] [@bs.as "aria-hidden"]
  ariaHidden: option(bool),
  /* [@bs.optional] [@bs.as "aria-invalid"] ariaInvalid: grammar|false|spelling|true, */
  [@bs.optional] [@bs.as "aria-keyshortcuts"]
  ariaKeyshortcuts: option(string),
  [@bs.optional] [@bs.as "aria-label"]
  ariaLabel: option(string),
  [@bs.optional] [@bs.as "aria-roledescription"]
  ariaRoledescription: option(string),
  /* Widget Attributes */
  /* [@bs.optional] [@bs.as "aria-autocomplete"] ariaAutocomplete: inline|list|both|none, */
  /* [@bs.optional] [@bs.as "aria-checked"] ariaChecked: true|false|mixed, /* https://www.w3.org/TR/wai-aria-1.1/#valuetype_tristate */ */
  [@bs.optional] [@bs.as "aria-expanded"]
  ariaExpanded: option(bool),
  /* [@bs.optional] [@bs.as "aria-haspopup"] ariaHaspopup: false|true|menu|listbox|tree|grid|dialog, */
  [@bs.optional] [@bs.as "aria-level"]
  ariaLevel: option(int),
  [@bs.optional] [@bs.as "aria-modal"]
  ariaModal: option(bool),
  [@bs.optional] [@bs.as "aria-multiline"]
  ariaMultiline: option(bool),
  [@bs.optional] [@bs.as "aria-multiselectable"]
  ariaMultiselectable: option(bool),
  /* [@bs.optional] [@bs.as "aria-orientation"] ariaOrientation: horizontal|vertical|undefined, */
  [@bs.optional] [@bs.as "aria-placeholder"]
  ariaPlaceholder: option(string),
  /* [@bs.optional] [@bs.as "aria-pressed"] ariaPressed: true|false|mixed, /* https://www.w3.org/TR/wai-aria-1.1/#valuetype_tristate */ */
  [@bs.optional] [@bs.as "aria-readonly"]
  ariaReadonly: option(bool),
  [@bs.optional] [@bs.as "aria-required"]
  ariaRequired: option(bool),
  [@bs.optional] [@bs.as "aria-selected"]
  ariaSelected: option(bool),
  [@bs.optional] [@bs.as "aria-sort"]
  ariaSort: option(string),
  [@bs.optional] [@bs.as "aria-valuemax"]
  ariaValuemax: option(float),
  [@bs.optional] [@bs.as "aria-valuemin"]
  ariaValuemin: option(float),
  [@bs.optional] [@bs.as "aria-valuenow"]
  ariaValuenow: option(float),
  [@bs.optional] [@bs.as "aria-valuetext"]
  ariaValuetext: option(string),
  /* Live Region Attributes */
  [@bs.optional] [@bs.as "aria-atomic"]
  ariaAtomic: option(bool),
  [@bs.optional] [@bs.as "aria-busy"]
  ariaBusy: option(bool),
  /* [@bs.optional] [@bs.as "aria-live"] ariaLive: off|polite|assertive|rude, */
  [@bs.optional] [@bs.as "aria-relevant"]
  ariaRelevant: option(string),
  /* Drag-and-Drop Attributes */
  /* [@bs.optional] [@bs.as "aria-dropeffect"] ariaDropeffect: copy|move|link|execute|popup|none, */
  [@bs.optional] [@bs.as "aria-grabbed"]
  ariaGrabbed: option(bool),
  /* Relationship Attributes */
  [@bs.optional] [@bs.as "aria-activedescendant"]
  ariaActivedescendant: option(string),
  [@bs.optional] [@bs.as "aria-colcount"]
  ariaColcount: option(int),
  [@bs.optional] [@bs.as "aria-colindex"]
  ariaColindex: option(int),
  [@bs.optional] [@bs.as "aria-colspan"]
  ariaColspan: option(int),
  [@bs.optional] [@bs.as "aria-controls"]
  ariaControls: option(string),
  [@bs.optional] [@bs.as "aria-describedby"]
  ariaDescribedby: option(string),
  [@bs.optional] [@bs.as "aria-errormessage"]
  ariaErrormessage: option(string),
  [@bs.optional] [@bs.as "aria-flowto"]
  ariaFlowto: option(string),
  [@bs.optional] [@bs.as "aria-labelledby"]
  ariaLabelledby: option(string),
  [@bs.optional] [@bs.as "aria-owns"]
  ariaOwns: option(string),
  [@bs.optional] [@bs.as "aria-posinset"]
  ariaPosinset: option(int),
  [@bs.optional] [@bs.as "aria-rowcount"]
  ariaRowcount: option(int),
  [@bs.optional] [@bs.as "aria-rowindex"]
  ariaRowindex: option(int),
  [@bs.optional] [@bs.as "aria-rowspan"]
  ariaRowspan: option(int),
  [@bs.optional] [@bs.as "aria-setsize"]
  ariaSetsize: option(int),
  /* react textarea/input */
  [@bs.optional]
  defaultChecked: option(bool),
  [@bs.optional]
  defaultValue: option(string),
  /* global html attributes */
  [@bs.optional]
  accessKey: option(string),
  [@bs.optional]
  className: option(string), /* substitute for "class" */
  [@bs.optional]
  contentEditable: option(bool),
  [@bs.optional]
  contextMenu: option(string),
  [@bs.optional]
  dir: option(string), /* "ltr", "rtl" or "auto" */
  [@bs.optional]
  draggable: option(bool),
  [@bs.optional]
  hidden: option(bool),
  [@bs.optional]
  id: option(string),
  [@bs.optional]
  lang: option(string),
  [@bs.optional]
  role: option(string), /* ARIA role */
  [@bs.optional]
  style: option(style),
  [@bs.optional]
  spellCheck: option(bool),
  [@bs.optional]
  tabIndex: option(int),
  [@bs.optional]
  title: option(string),
  /* html5 microdata */
  [@bs.optional]
  itemID: option(string),
  [@bs.optional]
  itemProp: option(string),
  [@bs.optional]
  itemRef: option(string),
  [@bs.optional]
  itemScope: option(bool),
  [@bs.optional]
  itemType: option(string), /* uri */
  /* tag-specific html attributes */
  [@bs.optional]
  accept: option(string),
  [@bs.optional]
  acceptCharset: option(string),
  [@bs.optional]
  action: option(string), /* uri */
  [@bs.optional]
  allowFullScreen: option(bool),
  [@bs.optional]
  alt: option(string),
  [@bs.optional]
  async: option(bool),
  [@bs.optional]
  autoComplete: option(string), /* has a fixed, but large-ish, set of possible values */
  [@bs.optional]
  autoCapitalize: option(string), /* Mobile Safari specific */
  [@bs.optional]
  autoFocus: option(bool),
  [@bs.optional]
  autoPlay: option(bool),
  [@bs.optional]
  challenge: option(string),
  [@bs.optional]
  charSet: option(string),
  [@bs.optional]
  checked: option(bool),
  [@bs.optional]
  cite: option(string), /* uri */
  [@bs.optional]
  crossOrigin: option(string), /* anonymous, use-credentials */
  [@bs.optional]
  cols: option(int),
  [@bs.optional]
  colSpan: option(int),
  [@bs.optional]
  content: option(string),
  [@bs.optional]
  controls: option(bool),
  [@bs.optional]
  coords: option(string), /* set of values specifying the coordinates of a region */
  [@bs.optional]
  data: option(string), /* uri */
  [@bs.optional]
  dateTime: option(string), /* "valid date string with optional time" */
  [@bs.optional]
  default: option(bool),
  [@bs.optional]
  defer: option(bool),
  [@bs.optional]
  disabled: option(bool),
  [@bs.optional]
  download: option(string), /* should really be either a boolean, signifying presence, or a string */
  [@bs.optional]
  encType: option(string), /* "application/x-www-form-urlencoded", "multipart/form-data" or "text/plain" */
  [@bs.optional]
  form: option(string),
  [@bs.optional]
  formAction: option(string), /* uri */
  [@bs.optional]
  formTarget: option(string), /* "_blank", "_self", etc. */
  [@bs.optional]
  formMethod: option(string), /* "post", "get", "put" */
  [@bs.optional]
  headers: option(string),
  [@bs.optional]
  height: option(string), /* in html5 this can only be a number, but in html4 it can ba a percentage as well */
  [@bs.optional]
  high: option(int),
  [@bs.optional]
  href: option(string), /* uri */
  [@bs.optional]
  hrefLang: option(string),
  [@bs.optional]
  htmlFor: option(string), /* substitute for "for" */
  [@bs.optional]
  httpEquiv: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  icon: option(string), /* uri? */
  [@bs.optional]
  inputMode: option(string), /* "verbatim", "latin", "numeric", etc. */
  [@bs.optional]
  integrity: option(string),
  [@bs.optional]
  keyType: option(string),
  [@bs.optional]
  kind: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  label: option(string),
  [@bs.optional]
  list: option(string),
  [@bs.optional]
  loop: option(bool),
  [@bs.optional]
  low: option(int),
  [@bs.optional]
  manifest: option(string), /* uri */
  [@bs.optional]
  max: option(string), /* should be int or Js.Date.t */
  [@bs.optional]
  maxLength: option(int),
  [@bs.optional]
  media: option(string), /* a valid media query */
  [@bs.optional]
  mediaGroup: option(string),
  [@bs.optional]
  method: option(string), /* "post" or "get" */
  [@bs.optional]
  min: option(string),
  [@bs.optional]
  minLength: option(int),
  [@bs.optional]
  multiple: option(bool),
  [@bs.optional]
  muted: option(bool),
  [@bs.optional]
  name: option(string),
  [@bs.optional]
  nonce: option(string),
  [@bs.optional]
  noValidate: option(bool),
  [@bs.optional] [@bs.as "open"]
  open_: option(bool), /* use this one. Previous one is deprecated */
  [@bs.optional]
  optimum: option(int),
  [@bs.optional]
  pattern: option(string), /* valid Js RegExp */
  [@bs.optional]
  placeholder: option(string),
  [@bs.optional]
  poster: option(string), /* uri */
  [@bs.optional]
  preload: option(string), /* "none", "metadata" or "auto" (and "" as a synonym for "auto") */
  [@bs.optional]
  radioGroup: option(string),
  [@bs.optional]
  readOnly: option(bool),
  [@bs.optional]
  rel: option(string), /* a space- or comma-separated (depending on the element) list of a fixed set of "link types" */
  [@bs.optional]
  required: option(bool),
  [@bs.optional]
  reversed: option(bool),
  [@bs.optional]
  rows: option(int),
  [@bs.optional]
  rowSpan: option(int),
  [@bs.optional]
  sandbox: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  scope: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  scoped: option(bool),
  [@bs.optional]
  scrolling: option(string), /* html4 only, "auto", "yes" or "no" */
  /* seamless - supported by React, but removed from the html5 spec */
  [@bs.optional]
  selected: option(bool),
  [@bs.optional]
  shape: option(string),
  [@bs.optional]
  size: option(int),
  [@bs.optional]
  sizes: option(string),
  [@bs.optional]
  span: option(int),
  [@bs.optional]
  src: option(string), /* uri */
  [@bs.optional]
  srcDoc: option(string),
  [@bs.optional]
  srcLang: option(string),
  [@bs.optional]
  srcSet: option(string),
  [@bs.optional]
  start: option(int),
  [@bs.optional]
  step: option(float),
  [@bs.optional]
  summary: option(string), /* deprecated */
  [@bs.optional]
  target: option(string),
  [@bs.optional] [@bs.as "type"]
  type_: option(string), /* has a fixed but large-ish set of possible values */ /* use this one. Previous one is deprecated */
  [@bs.optional]
  useMap: option(string),
  [@bs.optional]
  value: option(string),
  [@bs.optional]
  width: option(string), /* in html5 this can only be a number, but in html4 it can ba a percentage as well */
  [@bs.optional]
  wrap: option(string), /* "hard" or "soft" */
  /* Clipboard events */
  [@bs.optional]
  onCopy: option(ReactEvent.Clipboard.t => unit),
  [@bs.optional]
  onCut: option(ReactEvent.Clipboard.t => unit),
  [@bs.optional]
  onPaste: option(ReactEvent.Clipboard.t => unit),
  /* Composition events */
  [@bs.optional]
  onCompositionEnd: option(ReactEvent.Composition.t => unit),
  [@bs.optional]
  onCompositionStart: option(ReactEvent.Composition.t => unit),
  [@bs.optional]
  onCompositionUpdate: option(ReactEvent.Composition.t => unit),
  /* Keyboard events */
  [@bs.optional]
  onKeyDown: option(ReactEvent.Keyboard.t => unit),
  [@bs.optional]
  onKeyPress: option(ReactEvent.Keyboard.t => unit),
  [@bs.optional]
  onKeyUp: option(ReactEvent.Keyboard.t => unit),
  /* Focus events */
  [@bs.optional]
  onFocus: option(ReactEvent.Focus.t => unit),
  [@bs.optional]
  onBlur: option(ReactEvent.Focus.t => unit),
  /* Form events */
  [@bs.optional]
  onChange: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onInput: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onSubmit: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onInvalid: option(ReactEvent.Form.t => unit),
  /* Mouse events */
  [@bs.optional]
  onClick: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onContextMenu: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDoubleClick: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDrag: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragEnd: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragEnter: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragExit: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragLeave: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragOver: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragStart: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDrop: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseDown: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseEnter: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseLeave: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseMove: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseOut: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseOver: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseUp: option(ReactEvent.Mouse.t => unit),
  /* Selection events */
  [@bs.optional]
  onSelect: option(ReactEvent.Selection.t => unit),
  /* Touch events */
  [@bs.optional]
  onTouchCancel: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchEnd: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchMove: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchStart: option(ReactEvent.Touch.t => unit),
  /* UI events */
  [@bs.optional]
  onScroll: option(ReactEvent.UI.t => unit),
  /* Wheel events */
  [@bs.optional]
  onWheel: option(ReactEvent.Wheel.t => unit),
  /* Media events */
  [@bs.optional]
  onAbort: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onCanPlay: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onCanPlayThrough: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onDurationChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEmptied: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEncrypetd: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEnded: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onError: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadedData: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadedMetadata: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadStart: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPause: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPlay: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPlaying: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onProgress: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onRateChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSeeked: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSeeking: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onStalled: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSuspend: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onTimeUpdate: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onVolumeChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onWaiting: option(ReactEvent.Media.t => unit),
  /* Image events */
  [@bs.optional]onLoad: option(ReactEvent.Image.t => unit) /* duplicate */, /*~onError: ReactEvent.Image.t => unit=?,*/
  /* Animation events */
  [@bs.optional]
  onAnimationStart: option(ReactEvent.Animation.t => unit),
  [@bs.optional]
  onAnimationEnd: option(ReactEvent.Animation.t => unit),
  [@bs.optional]
  onAnimationIteration: option(ReactEvent.Animation.t => unit),
  /* Transition events */
  [@bs.optional]
  onTransitionEnd: option(ReactEvent.Transition.t => unit),
  /* svg */
  [@bs.optional]
  accentHeight: option(string),
  [@bs.optional]
  accumulate: option(string),
  [@bs.optional]
  additive: option(string),
  [@bs.optional]
  alignmentBaseline: option(string),
  [@bs.optional]
  allowReorder: option(string),
  [@bs.optional]
  alphabetic: option(string),
  [@bs.optional]
  amplitude: option(string),
  [@bs.optional]
  arabicForm: option(string),
  [@bs.optional]
  ascent: option(string),
  [@bs.optional]
  attributeName: option(string),
  [@bs.optional]
  attributeType: option(string),
  [@bs.optional]
  autoReverse: option(string),
  [@bs.optional]
  azimuth: option(string),
  [@bs.optional]
  baseFrequency: option(string),
  [@bs.optional]
  baseProfile: option(string),
  [@bs.optional]
  baselineShift: option(string),
  [@bs.optional]
  bbox: option(string),
  [@bs.optional] [@bs.as "begin"]
  begin_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  bias: option(string),
  [@bs.optional]
  by: option(string),
  [@bs.optional]
  calcMode: option(string),
  [@bs.optional]
  capHeight: option(string),
  [@bs.optional]
  clip: option(string),
  [@bs.optional]
  clipPath: option(string),
  [@bs.optional]
  clipPathUnits: option(string),
  [@bs.optional]
  clipRule: option(string),
  [@bs.optional]
  colorInterpolation: option(string),
  [@bs.optional]
  colorInterpolationFilters: option(string),
  [@bs.optional]
  colorProfile: option(string),
  [@bs.optional]
  colorRendering: option(string),
  [@bs.optional]
  contentScriptType: option(string),
  [@bs.optional]
  contentStyleType: option(string),
  [@bs.optional]
  cursor: option(string),
  [@bs.optional]
  cx: option(string),
  [@bs.optional]
  cy: option(string),
  [@bs.optional]
  d: option(string),
  [@bs.optional]
  decelerate: option(string),
  [@bs.optional]
  descent: option(string),
  [@bs.optional]
  diffuseConstant: option(string),
  [@bs.optional]
  direction: option(string),
  [@bs.optional]
  display: option(string),
  [@bs.optional]
  divisor: option(string),
  [@bs.optional]
  dominantBaseline: option(string),
  [@bs.optional]
  dur: option(string),
  [@bs.optional]
  dx: option(string),
  [@bs.optional]
  dy: option(string),
  [@bs.optional]
  edgeMode: option(string),
  [@bs.optional]
  elevation: option(string),
  [@bs.optional]
  enableBackground: option(string),
  [@bs.optional] [@bs.as "end"]
  end_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  exponent: option(string),
  [@bs.optional]
  externalResourcesRequired: option(string),
  [@bs.optional]
  fill: option(string),
  [@bs.optional]
  fillOpacity: option(string),
  [@bs.optional]
  fillRule: option(string),
  [@bs.optional]
  filter: option(string),
  [@bs.optional]
  filterRes: option(string),
  [@bs.optional]
  filterUnits: option(string),
  [@bs.optional]
  floodColor: option(string),
  [@bs.optional]
  floodOpacity: option(string),
  [@bs.optional]
  focusable: option(string),
  [@bs.optional]
  fontFamily: option(string),
  [@bs.optional]
  fontSize: option(string),
  [@bs.optional]
  fontSizeAdjust: option(string),
  [@bs.optional]
  fontStretch: option(string),
  [@bs.optional]
  fontStyle: option(string),
  [@bs.optional]
  fontVariant: option(string),
  [@bs.optional]
  fontWeight: option(string),
  [@bs.optional]
  fomat: option(string),
  [@bs.optional]
  from: option(string),
  [@bs.optional]
  fx: option(string),
  [@bs.optional]
  fy: option(string),
  [@bs.optional]
  g1: option(string),
  [@bs.optional]
  g2: option(string),
  [@bs.optional]
  glyphName: option(string),
  [@bs.optional]
  glyphOrientationHorizontal: option(string),
  [@bs.optional]
  glyphOrientationVertical: option(string),
  [@bs.optional]
  glyphRef: option(string),
  [@bs.optional]
  gradientTransform: option(string),
  [@bs.optional]
  gradientUnits: option(string),
  [@bs.optional]
  hanging: option(string),
  [@bs.optional]
  horizAdvX: option(string),
  [@bs.optional]
  horizOriginX: option(string),
  [@bs.optional]
  ideographic: option(string),
  [@bs.optional]
  imageRendering: option(string),
  [@bs.optional] [@bs.as "in"]
  in_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  in2: option(string),
  [@bs.optional]
  intercept: option(string),
  [@bs.optional]
  k: option(string),
  [@bs.optional]
  k1: option(string),
  [@bs.optional]
  k2: option(string),
  [@bs.optional]
  k3: option(string),
  [@bs.optional]
  k4: option(string),
  [@bs.optional]
  kernelMatrix: option(string),
  [@bs.optional]
  kernelUnitLength: option(string),
  [@bs.optional]
  kerning: option(string),
  [@bs.optional]
  keyPoints: option(string),
  [@bs.optional]
  keySplines: option(string),
  [@bs.optional]
  keyTimes: option(string),
  [@bs.optional]
  lengthAdjust: option(string),
  [@bs.optional]
  letterSpacing: option(string),
  [@bs.optional]
  lightingColor: option(string),
  [@bs.optional]
  limitingConeAngle: option(string),
  [@bs.optional]
  local: option(string),
  [@bs.optional]
  markerEnd: option(string),
  [@bs.optional]
  markerHeight: option(string),
  [@bs.optional]
  markerMid: option(string),
  [@bs.optional]
  markerStart: option(string),
  [@bs.optional]
  markerUnits: option(string),
  [@bs.optional]
  markerWidth: option(string),
  [@bs.optional]
  mask: option(string),
  [@bs.optional]
  maskContentUnits: option(string),
  [@bs.optional]
  maskUnits: option(string),
  [@bs.optional]
  mathematical: option(string),
  [@bs.optional]
  mode: option(string),
  [@bs.optional]
  numOctaves: option(string),
  [@bs.optional]
  offset: option(string),
  [@bs.optional]
  opacity: option(string),
  [@bs.optional]
  operator: option(string),
  [@bs.optional]
  order: option(string),
  [@bs.optional]
  orient: option(string),
  [@bs.optional]
  orientation: option(string),
  [@bs.optional]
  origin: option(string),
  [@bs.optional]
  overflow: option(string),
  [@bs.optional]
  overflowX: option(string),
  [@bs.optional]
  overflowY: option(string),
  [@bs.optional]
  overlinePosition: option(string),
  [@bs.optional]
  overlineThickness: option(string),
  [@bs.optional]
  paintOrder: option(string),
  [@bs.optional]
  panose1: option(string),
  [@bs.optional]
  pathLength: option(string),
  [@bs.optional]
  patternContentUnits: option(string),
  [@bs.optional]
  patternTransform: option(string),
  [@bs.optional]
  patternUnits: option(string),
  [@bs.optional]
  pointerEvents: option(string),
  [@bs.optional]
  points: option(string),
  [@bs.optional]
  pointsAtX: option(string),
  [@bs.optional]
  pointsAtY: option(string),
  [@bs.optional]
  pointsAtZ: option(string),
  [@bs.optional]
  preserveAlpha: option(string),
  [@bs.optional]
  preserveAspectRatio: option(string),
  [@bs.optional]
  primitiveUnits: option(string),
  [@bs.optional]
  r: option(string),
  [@bs.optional]
  radius: option(string),
  [@bs.optional]
  refX: option(string),
  [@bs.optional]
  refY: option(string),
  [@bs.optional]
  renderingIntent: option(string),
  [@bs.optional]
  repeatCount: option(string),
  [@bs.optional]
  repeatDur: option(string),
  [@bs.optional]
  requiredExtensions: option(string),
  [@bs.optional]
  requiredFeatures: option(string),
  [@bs.optional]
  restart: option(string),
  [@bs.optional]
  result: option(string),
  [@bs.optional]
  rotate: option(string),
  [@bs.optional]
  rx: option(string),
  [@bs.optional]
  ry: option(string),
  [@bs.optional]
  scale: option(string),
  [@bs.optional]
  seed: option(string),
  [@bs.optional]
  shapeRendering: option(string),
  [@bs.optional]
  slope: option(string),
  [@bs.optional]
  spacing: option(string),
  [@bs.optional]
  specularConstant: option(string),
  [@bs.optional]
  specularExponent: option(string),
  [@bs.optional]
  speed: option(string),
  [@bs.optional]
  spreadMethod: option(string),
  [@bs.optional]
  startOffset: option(string),
  [@bs.optional]
  stdDeviation: option(string),
  [@bs.optional]
  stemh: option(string),
  [@bs.optional]
  stemv: option(string),
  [@bs.optional]
  stitchTiles: option(string),
  [@bs.optional]
  stopColor: option(string),
  [@bs.optional]
  stopOpacity: option(string),
  [@bs.optional]
  strikethroughPosition: option(string),
  [@bs.optional]
  strikethroughThickness: option(string),
  [@bs.optional]
  string: option(string),
  [@bs.optional]
  stroke: option(string),
  [@bs.optional]
  strokeDasharray: option(string),
  [@bs.optional]
  strokeDashoffset: option(string),
  [@bs.optional]
  strokeLinecap: option(string),
  [@bs.optional]
  strokeLinejoin: option(string),
  [@bs.optional]
  strokeMiterlimit: option(string),
  [@bs.optional]
  strokeOpacity: option(string),
  [@bs.optional]
  strokeWidth: option(string),
  [@bs.optional]
  surfaceScale: option(string),
  [@bs.optional]
  systemLanguage: option(string),
  [@bs.optional]
  tableValues: option(string),
  [@bs.optional]
  targetX: option(string),
  [@bs.optional]
  targetY: option(string),
  [@bs.optional]
  textAnchor: option(string),
  [@bs.optional]
  textDecoration: option(string),
  [@bs.optional]
  textLength: option(string),
  [@bs.optional]
  textRendering: option(string),
  [@bs.optional] [@bs.as "to"]
  to_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  transform: option(string),
  [@bs.optional]
  u1: option(string),
  [@bs.optional]
  u2: option(string),
  [@bs.optional]
  underlinePosition: option(string),
  [@bs.optional]
  underlineThickness: option(string),
  [@bs.optional]
  unicode: option(string),
  [@bs.optional]
  unicodeBidi: option(string),
  [@bs.optional]
  unicodeRange: option(string),
  [@bs.optional]
  unitsPerEm: option(string),
  [@bs.optional]
  vAlphabetic: option(string),
  [@bs.optional]
  vHanging: option(string),
  [@bs.optional]
  vIdeographic: option(string),
  [@bs.optional]
  vMathematical: option(string),
  [@bs.optional]
  values: option(string),
  [@bs.optional]
  vectorEffect: option(string),
  [@bs.optional]
  version: option(string),
  [@bs.optional]
  vertAdvX: option(string),
  [@bs.optional]
  vertAdvY: option(string),
  [@bs.optional]
  vertOriginX: option(string),
  [@bs.optional]
  vertOriginY: option(string),
  [@bs.optional]
  viewBox: option(string),
  [@bs.optional]
  viewTarget: option(string),
  [@bs.optional]
  visibility: option(string),
  /*width::string? =>*/
  [@bs.optional]
  widths: option(string),
  [@bs.optional]
  wordSpacing: option(string),
  [@bs.optional]
  writingMode: option(string),
  [@bs.optional]
  x: option(string),
  [@bs.optional]
  x1: option(string),
  [@bs.optional]
  x2: option(string),
  [@bs.optional]
  xChannelSelector: option(string),
  [@bs.optional]
  xHeight: option(string),
  [@bs.optional]
  xlinkActuate: option(string),
  [@bs.optional]
  xlinkArcrole: option(string),
  [@bs.optional]
  xlinkHref: option(string),
  [@bs.optional]
  xlinkRole: option(string),
  [@bs.optional]
  xlinkShow: option(string),
  [@bs.optional]
  xlinkTitle: option(string),
  [@bs.optional]
  xlinkType: option(string),
  [@bs.optional]
  xmlns: option(string),
  [@bs.optional]
  xmlnsXlink: option(string),
  [@bs.optional]
  xmlBase: option(string),
  [@bs.optional]
  xmlLang: option(string),
  [@bs.optional]
  xmlSpace: option(string),
  [@bs.optional]
  y: option(string),
  [@bs.optional]
  y1: option(string),
  [@bs.optional]
  y2: option(string),
  [@bs.optional]
  yChannelSelector: option(string),
  [@bs.optional]
  z: option(string),
  [@bs.optional]
  zoomAndPan: option(string),
  /* RDFa */
  [@bs.optional]
  about: option(string),
  [@bs.optional]
  datatype: option(string),
  [@bs.optional]
  inlist: option(string),
  [@bs.optional]
  prefix: option(string),
  [@bs.optional]
  property: option(string),
  [@bs.optional]
  resource: option(string),
  [@bs.optional]
  typeof: option(string),
  [@bs.optional]
  vocab: option(string),
  /* react-specific */
  [@bs.optional]
  dangerouslySetInnerHTML: option({. "__html": string}),
  [@bs.optional]
  suppressContentEditableWarning: option(bool),
};

[@bs.splice] [@bs.module "react"]
external createDOMElementVariadic:
  (string, ~props: domProps=?, array(React.element)) => React.element =
  "createElement";

/* This list isn't exhaustive. We'll add more as we go. */
/*
 * Watch out! There are two props types and the only difference is the type of ref.
 * Please keep in sync.
 */
[@deriving abstract]
type props = {
  [@bs.optional]
  key: option(string),
  [@bs.optional]
  ref: option(Js.nullable(Dom.element) => unit),
  /* accessibility */
  /* https://www.w3.org/TR/wai-aria-1.1/ */
  /* https://accessibilityresources.org/<aria-tag> is a great resource for these */
  /* [@bs.optional] [@bs.as "aria-current"] ariaCurrent: page|step|location|date|time|true|false, */
  [@bs.optional] [@bs.as "aria-details"]
  ariaDetails: option(string),
  [@bs.optional] [@bs.as "aria-disabled"]
  ariaDisabled: option(bool),
  [@bs.optional] [@bs.as "aria-hidden"]
  ariaHidden: option(bool),
  /* [@bs.optional] [@bs.as "aria-invalid"] ariaInvalid: grammar|false|spelling|true, */
  [@bs.optional] [@bs.as "aria-keyshortcuts"]
  ariaKeyshortcuts: option(string),
  [@bs.optional] [@bs.as "aria-label"]
  ariaLabel: option(string),
  [@bs.optional] [@bs.as "aria-roledescription"]
  ariaRoledescription: option(string),
  /* Widget Attributes */
  /* [@bs.optional] [@bs.as "aria-autocomplete"] ariaAutocomplete: inline|list|both|none, */
  /* [@bs.optional] [@bs.as "aria-checked"] ariaChecked: true|false|mixed, /* https://www.w3.org/TR/wai-aria-1.1/#valuetype_tristate */ */
  [@bs.optional] [@bs.as "aria-expanded"]
  ariaExpanded: option(bool),
  /* [@bs.optional] [@bs.as "aria-haspopup"] ariaHaspopup: false|true|menu|listbox|tree|grid|dialog, */
  [@bs.optional] [@bs.as "aria-level"]
  ariaLevel: option(int),
  [@bs.optional] [@bs.as "aria-modal"]
  ariaModal: option(bool),
  [@bs.optional] [@bs.as "aria-multiline"]
  ariaMultiline: option(bool),
  [@bs.optional] [@bs.as "aria-multiselectable"]
  ariaMultiselectable: option(bool),
  /* [@bs.optional] [@bs.as "aria-orientation"] ariaOrientation: horizontal|vertical|undefined, */
  [@bs.optional] [@bs.as "aria-placeholder"]
  ariaPlaceholder: option(string),
  /* [@bs.optional] [@bs.as "aria-pressed"] ariaPressed: true|false|mixed, /* https://www.w3.org/TR/wai-aria-1.1/#valuetype_tristate */ */
  [@bs.optional] [@bs.as "aria-readonly"]
  ariaReadonly: option(bool),
  [@bs.optional] [@bs.as "aria-required"]
  ariaRequired: option(bool),
  [@bs.optional] [@bs.as "aria-selected"]
  ariaSelected: option(bool),
  [@bs.optional] [@bs.as "aria-sort"]
  ariaSort: option(string),
  [@bs.optional] [@bs.as "aria-valuemax"]
  ariaValuemax: option(float),
  [@bs.optional] [@bs.as "aria-valuemin"]
  ariaValuemin: option(float),
  [@bs.optional] [@bs.as "aria-valuenow"]
  ariaValuenow: option(float),
  [@bs.optional] [@bs.as "aria-valuetext"]
  ariaValuetext: option(string),
  /* Live Region Attributes */
  [@bs.optional] [@bs.as "aria-atomic"]
  ariaAtomic: option(bool),
  [@bs.optional] [@bs.as "aria-busy"]
  ariaBusy: option(bool),
  /* [@bs.optional] [@bs.as "aria-live"] ariaLive: off|polite|assertive|rude, */
  [@bs.optional] [@bs.as "aria-relevant"]
  ariaRelevant: option(string),
  /* Drag-and-Drop Attributes */
  /* [@bs.optional] [@bs.as "aria-dropeffect"] ariaDropeffect: copy|move|link|execute|popup|none, */
  [@bs.optional] [@bs.as "aria-grabbed"]
  ariaGrabbed: option(bool),
  /* Relationship Attributes */
  [@bs.optional] [@bs.as "aria-activedescendant"]
  ariaActivedescendant: option(string),
  [@bs.optional] [@bs.as "aria-colcount"]
  ariaColcount: option(int),
  [@bs.optional] [@bs.as "aria-colindex"]
  ariaColindex: option(int),
  [@bs.optional] [@bs.as "aria-colspan"]
  ariaColspan: option(int),
  [@bs.optional] [@bs.as "aria-controls"]
  ariaControls: option(string),
  [@bs.optional] [@bs.as "aria-describedby"]
  ariaDescribedby: option(string),
  [@bs.optional] [@bs.as "aria-errormessage"]
  ariaErrormessage: option(string),
  [@bs.optional] [@bs.as "aria-flowto"]
  ariaFlowto: option(string),
  [@bs.optional] [@bs.as "aria-labelledby"]
  ariaLabelledby: option(string),
  [@bs.optional] [@bs.as "aria-owns"]
  ariaOwns: option(string),
  [@bs.optional] [@bs.as "aria-posinset"]
  ariaPosinset: option(int),
  [@bs.optional] [@bs.as "aria-rowcount"]
  ariaRowcount: option(int),
  [@bs.optional] [@bs.as "aria-rowindex"]
  ariaRowindex: option(int),
  [@bs.optional] [@bs.as "aria-rowspan"]
  ariaRowspan: option(int),
  [@bs.optional] [@bs.as "aria-setsize"]
  ariaSetsize: option(int),
  /* react textarea/input */
  [@bs.optional]
  defaultChecked: option(bool),
  [@bs.optional]
  defaultValue: option(string),
  /* global html attributes */
  [@bs.optional]
  accessKey: option(string),
  [@bs.optional]
  className: option(string), /* substitute for "class" */
  [@bs.optional]
  contentEditable: option(bool),
  [@bs.optional]
  contextMenu: option(string),
  [@bs.optional]
  dir: option(string), /* "ltr", "rtl" or "auto" */
  [@bs.optional]
  draggable: option(bool),
  [@bs.optional]
  hidden: option(bool),
  [@bs.optional]
  id: option(string),
  [@bs.optional]
  lang: option(string),
  [@bs.optional]
  role: option(string), /* ARIA role */
  [@bs.optional]
  style: option(style),
  [@bs.optional]
  spellCheck: option(bool),
  [@bs.optional]
  tabIndex: option(int),
  [@bs.optional]
  title: option(string),
  /* html5 microdata */
  [@bs.optional]
  itemID: option(string),
  [@bs.optional]
  itemProp: option(string),
  [@bs.optional]
  itemRef: option(string),
  [@bs.optional]
  itemScope: option(bool),
  [@bs.optional]
  itemType: option(string), /* uri */
  /* tag-specific html attributes */
  [@bs.optional]
  accept: option(string),
  [@bs.optional]
  acceptCharset: option(string),
  [@bs.optional]
  action: option(string), /* uri */
  [@bs.optional]
  allowFullScreen: option(bool),
  [@bs.optional]
  alt: option(string),
  [@bs.optional]
  async: option(bool),
  [@bs.optional]
  autoComplete: option(string), /* has a fixed, but large-ish, set of possible values */
  [@bs.optional]
  autoCapitalize: option(string), /* Mobile Safari specific */
  [@bs.optional]
  autoFocus: option(bool),
  [@bs.optional]
  autoPlay: option(bool),
  [@bs.optional]
  challenge: option(string),
  [@bs.optional]
  charSet: option(string),
  [@bs.optional]
  checked: option(bool),
  [@bs.optional]
  cite: option(string), /* uri */
  [@bs.optional]
  crossorigin: option(bool),
  [@bs.optional]
  cols: option(int),
  [@bs.optional]
  colSpan: option(int),
  [@bs.optional]
  content: option(string),
  [@bs.optional]
  controls: option(bool),
  [@bs.optional]
  coords: option(string), /* set of values specifying the coordinates of a region */
  [@bs.optional]
  data: option(string), /* uri */
  [@bs.optional]
  dateTime: option(string), /* "valid date string with optional time" */
  [@bs.optional]
  default: option(bool),
  [@bs.optional]
  defer: option(bool),
  [@bs.optional]
  disabled: option(bool),
  [@bs.optional]
  download: option(string), /* should really be either a boolean, signifying presence, or a string */
  [@bs.optional]
  encType: option(string), /* "application/x-www-form-urlencoded", "multipart/form-data" or "text/plain" */
  [@bs.optional]
  form: option(string),
  [@bs.optional]
  formAction: option(string), /* uri */
  [@bs.optional]
  formTarget: option(string), /* "_blank", "_self", etc. */
  [@bs.optional]
  formMethod: option(string), /* "post", "get", "put" */
  [@bs.optional]
  headers: option(string),
  [@bs.optional]
  height: option(string), /* in html5 this can only be a number, but in html4 it can ba a percentage as well */
  [@bs.optional]
  high: option(int),
  [@bs.optional]
  href: option(string), /* uri */
  [@bs.optional]
  hrefLang: option(string),
  [@bs.optional]
  htmlFor: option(string), /* substitute for "for" */
  [@bs.optional]
  httpEquiv: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  icon: option(string), /* uri? */
  [@bs.optional]
  inputMode: option(string), /* "verbatim", "latin", "numeric", etc. */
  [@bs.optional]
  integrity: option(string),
  [@bs.optional]
  keyType: option(string),
  [@bs.optional]
  kind: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  label: option(string),
  [@bs.optional]
  list: option(string),
  [@bs.optional]
  loop: option(bool),
  [@bs.optional]
  low: option(int),
  [@bs.optional]
  manifest: option(string), /* uri */
  [@bs.optional]
  max: option(string), /* should be int or Js.Date.t */
  [@bs.optional]
  maxLength: option(int),
  [@bs.optional]
  media: option(string), /* a valid media query */
  [@bs.optional]
  mediaGroup: option(string),
  [@bs.optional]
  method: option(string), /* "post" or "get" */
  [@bs.optional]
  min: option(string),
  [@bs.optional]
  minLength: option(int),
  [@bs.optional]
  multiple: option(bool),
  [@bs.optional]
  muted: option(bool),
  [@bs.optional]
  name: option(string),
  [@bs.optional]
  nonce: option(string),
  [@bs.optional]
  noValidate: option(bool),
  [@bs.optional] [@bs.as "open"]
  open_: option(bool), /* use this one. Previous one is deprecated */
  [@bs.optional]
  optimum: option(int),
  [@bs.optional]
  pattern: option(string), /* valid Js RegExp */
  [@bs.optional]
  placeholder: option(string),
  [@bs.optional]
  poster: option(string), /* uri */
  [@bs.optional]
  preload: option(string), /* "none", "metadata" or "auto" (and "" as a synonym for "auto") */
  [@bs.optional]
  radioGroup: option(string),
  [@bs.optional]
  readOnly: option(bool),
  [@bs.optional]
  rel: option(string), /* a space- or comma-separated (depending on the element) list of a fixed set of "link types" */
  [@bs.optional]
  required: option(bool),
  [@bs.optional]
  reversed: option(bool),
  [@bs.optional]
  rows: option(int),
  [@bs.optional]
  rowSpan: option(int),
  [@bs.optional]
  sandbox: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  scope: option(string), /* has a fixed set of possible values */
  [@bs.optional]
  scoped: option(bool),
  [@bs.optional]
  scrolling: option(string), /* html4 only, "auto", "yes" or "no" */
  /* seamless - supported by React, but removed from the html5 spec */
  [@bs.optional]
  selected: option(bool),
  [@bs.optional]
  shape: option(string),
  [@bs.optional]
  size: option(int),
  [@bs.optional]
  sizes: option(string),
  [@bs.optional]
  span: option(int),
  [@bs.optional]
  src: option(string), /* uri */
  [@bs.optional]
  srcDoc: option(string),
  [@bs.optional]
  srcLang: option(string),
  [@bs.optional]
  srcSet: option(string),
  [@bs.optional]
  start: option(int),
  [@bs.optional]
  step: option(float),
  [@bs.optional]
  summary: option(string), /* deprecated */
  [@bs.optional]
  target: option(string),
  [@bs.optional] [@bs.as "type"]
  type_: option(string), /* has a fixed but large-ish set of possible values */ /* use this one. Previous one is deprecated */
  [@bs.optional]
  useMap: option(string),
  [@bs.optional]
  value: option(string),
  [@bs.optional]
  width: option(string), /* in html5 this can only be a number, but in html4 it can ba a percentage as well */
  [@bs.optional]
  wrap: option(string), /* "hard" or "soft" */
  /* Clipboard events */
  [@bs.optional]
  onCopy: option(ReactEvent.Clipboard.t => unit),
  [@bs.optional]
  onCut: option(ReactEvent.Clipboard.t => unit),
  [@bs.optional]
  onPaste: option(ReactEvent.Clipboard.t => unit),
  /* Composition events */
  [@bs.optional]
  onCompositionEnd: option(ReactEvent.Composition.t => unit),
  [@bs.optional]
  onCompositionStart: option(ReactEvent.Composition.t => unit),
  [@bs.optional]
  onCompositionUpdate: option(ReactEvent.Composition.t => unit),
  /* Keyboard events */
  [@bs.optional]
  onKeyDown: option(ReactEvent.Keyboard.t => unit),
  [@bs.optional]
  onKeyPress: option(ReactEvent.Keyboard.t => unit),
  [@bs.optional]
  onKeyUp: option(ReactEvent.Keyboard.t => unit),
  /* Focus events */
  [@bs.optional]
  onFocus: option(ReactEvent.Focus.t => unit),
  [@bs.optional]
  onBlur: option(ReactEvent.Focus.t => unit),
  /* Form events */
  [@bs.optional]
  onChange: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onInput: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onSubmit: option(ReactEvent.Form.t => unit),
  [@bs.optional]
  onInvalid: option(ReactEvent.Form.t => unit),
  /* Mouse events */
  [@bs.optional]
  onClick: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onContextMenu: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDoubleClick: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDrag: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragEnd: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragEnter: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragExit: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragLeave: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragOver: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDragStart: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onDrop: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseDown: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseEnter: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseLeave: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseMove: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseOut: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseOver: option(ReactEvent.Mouse.t => unit),
  [@bs.optional]
  onMouseUp: option(ReactEvent.Mouse.t => unit),
  /* Selection events */
  [@bs.optional]
  onSelect: option(ReactEvent.Selection.t => unit),
  /* Touch events */
  [@bs.optional]
  onTouchCancel: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchEnd: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchMove: option(ReactEvent.Touch.t => unit),
  [@bs.optional]
  onTouchStart: option(ReactEvent.Touch.t => unit),
  /* UI events */
  [@bs.optional]
  onScroll: option(ReactEvent.UI.t => unit),
  /* Wheel events */
  [@bs.optional]
  onWheel: option(ReactEvent.Wheel.t => unit),
  /* Media events */
  [@bs.optional]
  onAbort: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onCanPlay: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onCanPlayThrough: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onDurationChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEmptied: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEncrypetd: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onEnded: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onError: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadedData: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadedMetadata: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onLoadStart: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPause: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPlay: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onPlaying: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onProgress: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onRateChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSeeked: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSeeking: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onStalled: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onSuspend: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onTimeUpdate: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onVolumeChange: option(ReactEvent.Media.t => unit),
  [@bs.optional]
  onWaiting: option(ReactEvent.Media.t => unit),
  /* Image events */
  [@bs.optional]onLoad: option(ReactEvent.Image.t => unit) /* duplicate */, /*~onError: ReactEvent.Image.t => unit=?,*/
  /* Animation events */
  [@bs.optional]
  onAnimationStart: option(ReactEvent.Animation.t => unit),
  [@bs.optional]
  onAnimationEnd: option(ReactEvent.Animation.t => unit),
  [@bs.optional]
  onAnimationIteration: option(ReactEvent.Animation.t => unit),
  /* Transition events */
  [@bs.optional]
  onTransitionEnd: option(ReactEvent.Transition.t => unit),
  /* svg */
  [@bs.optional]
  accentHeight: option(string),
  [@bs.optional]
  accumulate: option(string),
  [@bs.optional]
  additive: option(string),
  [@bs.optional]
  alignmentBaseline: option(string),
  [@bs.optional]
  allowReorder: option(string),
  [@bs.optional]
  alphabetic: option(string),
  [@bs.optional]
  amplitude: option(string),
  [@bs.optional]
  arabicForm: option(string),
  [@bs.optional]
  ascent: option(string),
  [@bs.optional]
  attributeName: option(string),
  [@bs.optional]
  attributeType: option(string),
  [@bs.optional]
  autoReverse: option(string),
  [@bs.optional]
  azimuth: option(string),
  [@bs.optional]
  baseFrequency: option(string),
  [@bs.optional]
  baseProfile: option(string),
  [@bs.optional]
  baselineShift: option(string),
  [@bs.optional]
  bbox: option(string),
  [@bs.optional] [@bs.as "begin"]
  begin_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  bias: option(string),
  [@bs.optional]
  by: option(string),
  [@bs.optional]
  calcMode: option(string),
  [@bs.optional]
  capHeight: option(string),
  [@bs.optional]
  clip: option(string),
  [@bs.optional]
  clipPath: option(string),
  [@bs.optional]
  clipPathUnits: option(string),
  [@bs.optional]
  clipRule: option(string),
  [@bs.optional]
  colorInterpolation: option(string),
  [@bs.optional]
  colorInterpolationFilters: option(string),
  [@bs.optional]
  colorProfile: option(string),
  [@bs.optional]
  colorRendering: option(string),
  [@bs.optional]
  contentScriptType: option(string),
  [@bs.optional]
  contentStyleType: option(string),
  [@bs.optional]
  cursor: option(string),
  [@bs.optional]
  cx: option(string),
  [@bs.optional]
  cy: option(string),
  [@bs.optional]
  d: option(string),
  [@bs.optional]
  decelerate: option(string),
  [@bs.optional]
  descent: option(string),
  [@bs.optional]
  diffuseConstant: option(string),
  [@bs.optional]
  direction: option(string),
  [@bs.optional]
  display: option(string),
  [@bs.optional]
  divisor: option(string),
  [@bs.optional]
  dominantBaseline: option(string),
  [@bs.optional]
  dur: option(string),
  [@bs.optional]
  dx: option(string),
  [@bs.optional]
  dy: option(string),
  [@bs.optional]
  edgeMode: option(string),
  [@bs.optional]
  elevation: option(string),
  [@bs.optional]
  enableBackground: option(string),
  [@bs.optional] [@bs.as "end"]
  end_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  exponent: option(string),
  [@bs.optional]
  externalResourcesRequired: option(string),
  [@bs.optional]
  fill: option(string),
  [@bs.optional]
  fillOpacity: option(string),
  [@bs.optional]
  fillRule: option(string),
  [@bs.optional]
  filter: option(string),
  [@bs.optional]
  filterRes: option(string),
  [@bs.optional]
  filterUnits: option(string),
  [@bs.optional]
  floodColor: option(string),
  [@bs.optional]
  floodOpacity: option(string),
  [@bs.optional]
  focusable: option(string),
  [@bs.optional]
  fontFamily: option(string),
  [@bs.optional]
  fontSize: option(string),
  [@bs.optional]
  fontSizeAdjust: option(string),
  [@bs.optional]
  fontStretch: option(string),
  [@bs.optional]
  fontStyle: option(string),
  [@bs.optional]
  fontVariant: option(string),
  [@bs.optional]
  fontWeight: option(string),
  [@bs.optional]
  fomat: option(string),
  [@bs.optional]
  from: option(string),
  [@bs.optional]
  fx: option(string),
  [@bs.optional]
  fy: option(string),
  [@bs.optional]
  g1: option(string),
  [@bs.optional]
  g2: option(string),
  [@bs.optional]
  glyphName: option(string),
  [@bs.optional]
  glyphOrientationHorizontal: option(string),
  [@bs.optional]
  glyphOrientationVertical: option(string),
  [@bs.optional]
  glyphRef: option(string),
  [@bs.optional]
  gradientTransform: option(string),
  [@bs.optional]
  gradientUnits: option(string),
  [@bs.optional]
  hanging: option(string),
  [@bs.optional]
  horizAdvX: option(string),
  [@bs.optional]
  horizOriginX: option(string),
  [@bs.optional]
  ideographic: option(string),
  [@bs.optional]
  imageRendering: option(string),
  [@bs.optional] [@bs.as "in"]
  in_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  in2: option(string),
  [@bs.optional]
  intercept: option(string),
  [@bs.optional]
  k: option(string),
  [@bs.optional]
  k1: option(string),
  [@bs.optional]
  k2: option(string),
  [@bs.optional]
  k3: option(string),
  [@bs.optional]
  k4: option(string),
  [@bs.optional]
  kernelMatrix: option(string),
  [@bs.optional]
  kernelUnitLength: option(string),
  [@bs.optional]
  kerning: option(string),
  [@bs.optional]
  keyPoints: option(string),
  [@bs.optional]
  keySplines: option(string),
  [@bs.optional]
  keyTimes: option(string),
  [@bs.optional]
  lengthAdjust: option(string),
  [@bs.optional]
  letterSpacing: option(string),
  [@bs.optional]
  lightingColor: option(string),
  [@bs.optional]
  limitingConeAngle: option(string),
  [@bs.optional]
  local: option(string),
  [@bs.optional]
  markerEnd: option(string),
  [@bs.optional]
  markerHeight: option(string),
  [@bs.optional]
  markerMid: option(string),
  [@bs.optional]
  markerStart: option(string),
  [@bs.optional]
  markerUnits: option(string),
  [@bs.optional]
  markerWidth: option(string),
  [@bs.optional]
  mask: option(string),
  [@bs.optional]
  maskContentUnits: option(string),
  [@bs.optional]
  maskUnits: option(string),
  [@bs.optional]
  mathematical: option(string),
  [@bs.optional]
  mode: option(string),
  [@bs.optional]
  numOctaves: option(string),
  [@bs.optional]
  offset: option(string),
  [@bs.optional]
  opacity: option(string),
  [@bs.optional]
  operator: option(string),
  [@bs.optional]
  order: option(string),
  [@bs.optional]
  orient: option(string),
  [@bs.optional]
  orientation: option(string),
  [@bs.optional]
  origin: option(string),
  [@bs.optional]
  overflow: option(string),
  [@bs.optional]
  overflowX: option(string),
  [@bs.optional]
  overflowY: option(string),
  [@bs.optional]
  overlinePosition: option(string),
  [@bs.optional]
  overlineThickness: option(string),
  [@bs.optional]
  paintOrder: option(string),
  [@bs.optional]
  panose1: option(string),
  [@bs.optional]
  pathLength: option(string),
  [@bs.optional]
  patternContentUnits: option(string),
  [@bs.optional]
  patternTransform: option(string),
  [@bs.optional]
  patternUnits: option(string),
  [@bs.optional]
  pointerEvents: option(string),
  [@bs.optional]
  points: option(string),
  [@bs.optional]
  pointsAtX: option(string),
  [@bs.optional]
  pointsAtY: option(string),
  [@bs.optional]
  pointsAtZ: option(string),
  [@bs.optional]
  preserveAlpha: option(string),
  [@bs.optional]
  preserveAspectRatio: option(string),
  [@bs.optional]
  primitiveUnits: option(string),
  [@bs.optional]
  r: option(string),
  [@bs.optional]
  radius: option(string),
  [@bs.optional]
  refX: option(string),
  [@bs.optional]
  refY: option(string),
  [@bs.optional]
  renderingIntent: option(string),
  [@bs.optional]
  repeatCount: option(string),
  [@bs.optional]
  repeatDur: option(string),
  [@bs.optional]
  requiredExtensions: option(string),
  [@bs.optional]
  requiredFeatures: option(string),
  [@bs.optional]
  restart: option(string),
  [@bs.optional]
  result: option(string),
  [@bs.optional]
  rotate: option(string),
  [@bs.optional]
  rx: option(string),
  [@bs.optional]
  ry: option(string),
  [@bs.optional]
  scale: option(string),
  [@bs.optional]
  seed: option(string),
  [@bs.optional]
  shapeRendering: option(string),
  [@bs.optional]
  slope: option(string),
  [@bs.optional]
  spacing: option(string),
  [@bs.optional]
  specularConstant: option(string),
  [@bs.optional]
  specularExponent: option(string),
  [@bs.optional]
  speed: option(string),
  [@bs.optional]
  spreadMethod: option(string),
  [@bs.optional]
  startOffset: option(string),
  [@bs.optional]
  stdDeviation: option(string),
  [@bs.optional]
  stemh: option(string),
  [@bs.optional]
  stemv: option(string),
  [@bs.optional]
  stitchTiles: option(string),
  [@bs.optional]
  stopColor: option(string),
  [@bs.optional]
  stopOpacity: option(string),
  [@bs.optional]
  strikethroughPosition: option(string),
  [@bs.optional]
  strikethroughThickness: option(string),
  [@bs.optional]
  string: option(string),
  [@bs.optional]
  stroke: option(string),
  [@bs.optional]
  strokeDasharray: option(string),
  [@bs.optional]
  strokeDashoffset: option(string),
  [@bs.optional]
  strokeLinecap: option(string),
  [@bs.optional]
  strokeLinejoin: option(string),
  [@bs.optional]
  strokeMiterlimit: option(string),
  [@bs.optional]
  strokeOpacity: option(string),
  [@bs.optional]
  strokeWidth: option(string),
  [@bs.optional]
  surfaceScale: option(string),
  [@bs.optional]
  systemLanguage: option(string),
  [@bs.optional]
  tableValues: option(string),
  [@bs.optional]
  targetX: option(string),
  [@bs.optional]
  targetY: option(string),
  [@bs.optional]
  textAnchor: option(string),
  [@bs.optional]
  textDecoration: option(string),
  [@bs.optional]
  textLength: option(string),
  [@bs.optional]
  textRendering: option(string),
  [@bs.optional] [@bs.as "to"]
  to_: option(string), /* use this one. Previous one is deprecated */
  [@bs.optional]
  transform: option(string),
  [@bs.optional]
  u1: option(string),
  [@bs.optional]
  u2: option(string),
  [@bs.optional]
  underlinePosition: option(string),
  [@bs.optional]
  underlineThickness: option(string),
  [@bs.optional]
  unicode: option(string),
  [@bs.optional]
  unicodeBidi: option(string),
  [@bs.optional]
  unicodeRange: option(string),
  [@bs.optional]
  unitsPerEm: option(string),
  [@bs.optional]
  vAlphabetic: option(string),
  [@bs.optional]
  vHanging: option(string),
  [@bs.optional]
  vIdeographic: option(string),
  [@bs.optional]
  vMathematical: option(string),
  [@bs.optional]
  values: option(string),
  [@bs.optional]
  vectorEffect: option(string),
  [@bs.optional]
  version: option(string),
  [@bs.optional]
  vertAdvX: option(string),
  [@bs.optional]
  vertAdvY: option(string),
  [@bs.optional]
  vertOriginX: option(string),
  [@bs.optional]
  vertOriginY: option(string),
  [@bs.optional]
  viewBox: option(string),
  [@bs.optional]
  viewTarget: option(string),
  [@bs.optional]
  visibility: option(string),
  /*width::string? =>*/
  [@bs.optional]
  widths: option(string),
  [@bs.optional]
  wordSpacing: option(string),
  [@bs.optional]
  writingMode: option(string),
  [@bs.optional]
  x: option(string),
  [@bs.optional]
  x1: option(string),
  [@bs.optional]
  x2: option(string),
  [@bs.optional]
  xChannelSelector: option(string),
  [@bs.optional]
  xHeight: option(string),
  [@bs.optional]
  xlinkActuate: option(string),
  [@bs.optional]
  xlinkArcrole: option(string),
  [@bs.optional]
  xlinkHref: option(string),
  [@bs.optional]
  xlinkRole: option(string),
  [@bs.optional]
  xlinkShow: option(string),
  [@bs.optional]
  xlinkTitle: option(string),
  [@bs.optional]
  xlinkType: option(string),
  [@bs.optional]
  xmlns: option(string),
  [@bs.optional]
  xmlnsXlink: option(string),
  [@bs.optional]
  xmlBase: option(string),
  [@bs.optional]
  xmlLang: option(string),
  [@bs.optional]
  xmlSpace: option(string),
  [@bs.optional]
  y: option(string),
  [@bs.optional]
  y1: option(string),
  [@bs.optional]
  y2: option(string),
  [@bs.optional]
  yChannelSelector: option(string),
  [@bs.optional]
  z: option(string),
  [@bs.optional]
  zoomAndPan: option(string),
  /* RDFa */
  [@bs.optional]
  about: option(string),
  [@bs.optional]
  datatype: option(string),
  [@bs.optional]
  inlist: option(string),
  [@bs.optional]
  prefix: option(string),
  [@bs.optional]
  property: option(string),
  [@bs.optional]
  resource: option(string),
  [@bs.optional]
  typeof: option(string),
  [@bs.optional]
  vocab: option(string),
  /* react-specific */
  [@bs.optional]
  dangerouslySetInnerHTML: option({. "__html": string}),
  [@bs.optional]
  suppressContentEditableWarning: option(bool),
};

external objToDOMProps: Js.t({..}) => props = "%identity";

[@deprecated "Please use ReactDOMRe.props instead"]
type reactDOMProps = props;

[@bs.splice] [@bs.val] [@bs.module "react"]
external createElement:
  (string, ~props: props=?, array(React.element)) => React.element =
  "createElement";

/* Only wanna expose createElementVariadic here. Don't wanna write an interface file */
include (
          /* Use varargs to avoid the ReactJS warning for duplicate keys in children */
          {
            [@bs.val] [@bs.module "react"]
            external createElementInternalHack: 'a = "createElement";
            [@bs.send]
            external apply:
              ('theFunction, 'theContext, 'arguments) =>
              'returnTypeOfTheFunction =
              "apply";

            let createElementVariadic = (domClassName, ~props=?, children) => {
              let variadicArguments =
                [|Obj.magic(domClassName), Obj.magic(props)|]
                |> Js.Array.concat(children);
              createElementInternalHack->(
                                           apply(
                                             Js.Nullable.null,
                                             variadicArguments,
                                           )
                                         );
            };
          }: {
            let createElementVariadic:
              (string, ~props: props=?, array(React.element)) => React.element;
          }
        );

module Style = {
  type t = style;
  [@bs.obj]
  external make:
    (
      ~azimuth: string=?,
      ~background: string=?,
      ~backgroundAttachment: string=?,
      ~backgroundColor: string=?,
      ~backgroundImage: string=?,
      ~backgroundPosition: string=?,
      ~backgroundRepeat: string=?,
      ~border: string=?,
      ~borderCollapse: string=?,
      ~borderColor: string=?,
      ~borderSpacing: string=?,
      ~borderStyle: string=?,
      ~borderTop: string=?,
      ~borderRight: string=?,
      ~borderBottom: string=?,
      ~borderLeft: string=?,
      ~borderTopColor: string=?,
      ~borderRightColor: string=?,
      ~borderBottomColor: string=?,
      ~borderLeftColor: string=?,
      ~borderTopStyle: string=?,
      ~borderRightStyle: string=?,
      ~borderBottomStyle: string=?,
      ~borderLeftStyle: string=?,
      ~borderTopWidth: string=?,
      ~borderRightWidth: string=?,
      ~borderBottomWidth: string=?,
      ~borderLeftWidth: string=?,
      ~borderWidth: string=?,
      ~bottom: string=?,
      ~captionSide: string=?,
      ~clear: string=?,
      ~clip: string=?,
      ~color: string=?,
      ~content: string=?,
      ~counterIncrement: string=?,
      ~counterReset: string=?,
      ~cue: string=?,
      ~cueAfter: string=?,
      ~cueBefore: string=?,
      ~cursor: string=?,
      ~direction: string=?,
      ~display: string=?,
      ~elevation: string=?,
      ~emptyCells: string=?,
      ~float: string=?,
      ~font: string=?,
      ~fontFamily: string=?,
      ~fontSize: string=?,
      ~fontSizeAdjust: string=?,
      ~fontStretch: string=?,
      ~fontStyle: string=?,
      ~fontVariant: string=?,
      ~fontWeight: string=?,
      ~height: string=?,
      ~left: string=?,
      ~letterSpacing: string=?,
      ~lineHeight: string=?,
      ~listStyle: string=?,
      ~listStyleImage: string=?,
      ~listStylePosition: string=?,
      ~listStyleType: string=?,
      ~margin: string=?,
      ~marginTop: string=?,
      ~marginRight: string=?,
      ~marginBottom: string=?,
      ~marginLeft: string=?,
      ~markerOffset: string=?,
      ~marks: string=?,
      ~maxHeight: string=?,
      ~maxWidth: string=?,
      ~minHeight: string=?,
      ~minWidth: string=?,
      ~orphans: string=?,
      ~outline: string=?,
      ~outlineColor: string=?,
      ~outlineStyle: string=?,
      ~outlineWidth: string=?,
      ~overflow: string=?,
      ~overflowX: string=?,
      ~overflowY: string=?,
      ~padding: string=?,
      ~paddingTop: string=?,
      ~paddingRight: string=?,
      ~paddingBottom: string=?,
      ~paddingLeft: string=?,
      ~page: string=?,
      ~pageBreakAfter: string=?,
      ~pageBreakBefore: string=?,
      ~pageBreakInside: string=?,
      ~pause: string=?,
      ~pauseAfter: string=?,
      ~pauseBefore: string=?,
      ~pitch: string=?,
      ~pitchRange: string=?,
      ~playDuring: string=?,
      ~position: string=?,
      ~quotes: string=?,
      ~richness: string=?,
      ~right: string=?,
      ~size: string=?,
      ~speak: string=?,
      ~speakHeader: string=?,
      ~speakNumeral: string=?,
      ~speakPunctuation: string=?,
      ~speechRate: string=?,
      ~stress: string=?,
      ~tableLayout: string=?,
      ~textAlign: string=?,
      ~textDecoration: string=?,
      ~textIndent: string=?,
      ~textShadow: string=?,
      ~textTransform: string=?,
      ~top: string=?,
      ~unicodeBidi: string=?,
      ~verticalAlign: string=?,
      ~visibility: string=?,
      ~voiceFamily: string=?,
      ~volume: string=?,
      ~whiteSpace: string=?,
      ~widows: string=?,
      ~width: string=?,
      ~wordSpacing: string=?,
      ~zIndex: string=?,
      /* Below properties based on https://www.w3.org/Style/CSS/all-properties */
      /* Color Level 3 - REC */
      ~opacity: string=?,
      /* Backgrounds and Borders Level 3 - CR */
      /* backgroundRepeat - already defined by CSS2Properties */
      /* backgroundAttachment - already defined by CSS2Properties */
      ~backgroundOrigin: string=?,
      ~backgroundSize: string=?,
      ~backgroundClip: string=?,
      ~borderRadius: string=?,
      ~borderTopLeftRadius: string=?,
      ~borderTopRightRadius: string=?,
      ~borderBottomLeftRadius: string=?,
      ~borderBottomRightRadius: string=?,
      ~borderImage: string=?,
      ~borderImageSource: string=?,
      ~borderImageSlice: string=?,
      ~borderImageWidth: string=?,
      ~borderImageOutset: string=?,
      ~borderImageRepeat: string=?,
      ~boxShadow: string=?,
      /* Multi-column Layout - CR */
      ~columns: string=?,
      ~columnCount: string=?,
      ~columnFill: string=?,
      ~columnGap: string=?,
      ~columnRule: string=?,
      ~columnRuleColor: string=?,
      ~columnRuleStyle: string=?,
      ~columnRuleWidth: string=?,
      ~columnSpan: string=?,
      ~columnWidth: string=?,
      ~breakAfter: string=?,
      ~breakBefore: string=?,
      ~breakInside: string=?,
      /* Speech - CR */
      ~rest: string=?,
      ~restAfter: string=?,
      ~restBefore: string=?,
      ~speakAs: string=?,
      ~voiceBalance: string=?,
      ~voiceDuration: string=?,
      ~voicePitch: string=?,
      ~voiceRange: string=?,
      ~voiceRate: string=?,
      ~voiceStress: string=?,
      ~voiceVolume: string=?,
      /* Image Values and Replaced Content Level 3 - CR */
      ~objectFit: string=?,
      ~objectPosition: string=?,
      ~imageResolution: string=?,
      ~imageOrientation: string=?,
      /* Flexible Box Layout - CR */
      ~alignContent: string=?,
      ~alignItems: string=?,
      ~alignSelf: string=?,
      ~flex: string=?,
      ~flexBasis: string=?,
      ~flexDirection: string=?,
      ~flexFlow: string=?,
      ~flexGrow: string=?,
      ~flexShrink: string=?,
      ~flexWrap: string=?,
      ~justifyContent: string=?,
      ~order: string=?,
      /* Text Decoration Level 3 - CR */
      /* textDecoration - already defined by CSS2Properties */
      ~textDecorationColor: string=?,
      ~textDecorationLine: string=?,
      ~textDecorationSkip: string=?,
      ~textDecorationStyle: string=?,
      ~textEmphasis: string=?,
      ~textEmphasisColor: string=?,
      ~textEmphasisPosition: string=?,
      ~textEmphasisStyle: string=?,
      /* textShadow - already defined by CSS2Properties */
      ~textUnderlinePosition: string=?,
      /* Fonts Level 3 - CR */
      ~fontFeatureSettings: string=?,
      ~fontKerning: string=?,
      ~fontLanguageOverride: string=?,
      /* fontSizeAdjust - already defined by CSS2Properties */
      /* fontStretch - already defined by CSS2Properties */
      ~fontSynthesis: string=?,
      ~forntVariantAlternates: string=?,
      ~fontVariantCaps: string=?,
      ~fontVariantEastAsian: string=?,
      ~fontVariantLigatures: string=?,
      ~fontVariantNumeric: string=?,
      ~fontVariantPosition: string=?,
      /* Cascading and Inheritance Level 3 - CR */
      ~all: string=?,
      /* Writing Modes Level 3 - CR */
      ~glyphOrientationVertical: string=?,
      ~textCombineUpright: string=?,
      ~textOrientation: string=?,
      ~writingMode: string=?,
      /* Shapes Level 1 - CR */
      ~shapeImageThreshold: string=?,
      ~shapeMargin: string=?,
      ~shapeOutside: string=?,
      /* Masking Level 1 - CR */
      ~clipPath: string=?,
      ~clipRule: string=?,
      ~mask: string=?,
      ~maskBorder: string=?,
      ~maskBorderMode: string=?,
      ~maskBorderOutset: string=?,
      ~maskBorderRepeat: string=?,
      ~maskBorderSlice: string=?,
      ~maskBorderSource: string=?,
      ~maskBorderWidth: string=?,
      ~maskClip: string=?,
      ~maskComposite: string=?,
      ~maskImage: string=?,
      ~maskMode: string=?,
      ~maskOrigin: string=?,
      ~maskPosition: string=?,
      ~maskRepeat: string=?,
      ~maskSize: string=?,
      ~maskType: string=?,
      /* Compositing and Blending Level 1 - CR */
      ~backgroundBlendMode: string=?,
      ~isolation: string=?,
      ~mixBlendMode: string=?,
      /* Fragmentation Level 3 - CR */
      ~boxDecorationBreak: string=?,
      /* breakAfter - already defined by Multi-column Layout */
      /* breakBefore - already defined by Multi-column Layout */
      /* breakInside - already defined by Multi-column Layout */
      /* Basic User Interface Level 3 - CR */
      ~boxSizing: string=?,
      ~caretColor: string=?,
      ~navDown: string=?,
      ~navLeft: string=?,
      ~navRight: string=?,
      ~navUp: string=?,
      ~outlineOffset: string=?,
      ~resize: string=?,
      ~textOverflow: string=?,
      /* Grid Layout Level 1 - CR */
      ~grid: string=?,
      ~gridArea: string=?,
      ~gridAutoColumns: string=?,
      ~gridAutoFlow: string=?,
      ~gridAutoRows: string=?,
      ~gridColumn: string=?,
      ~gridColumnEnd: string=?,
      ~gridColumnGap: string=?,
      ~gridColumnStart: string=?,
      ~gridGap: string=?,
      ~gridRow: string=?,
      ~gridRowEnd: string=?,
      ~gridRowGap: string=?,
      ~gridRowStart: string=?,
      ~gridTemplate: string=?,
      ~gridTemplateAreas: string=?,
      ~gridTemplateColumns: string=?,
      ~gridTemplateRows: string=?,
      /* Will Change Level 1 - CR */
      ~willChange: string=?,
      /* Text Level 3 - LC */
      ~hangingPunctuation: string=?,
      ~hyphens: string=?,
      /* letterSpacing - already defined by CSS2Properties */
      ~lineBreak: string=?,
      ~overflowWrap: string=?,
      ~tabSize: string=?,
      /* textAlign - already defined by CSS2Properties */
      ~textAlignLast: string=?,
      ~textJustify: string=?,
      ~wordBreak: string=?,
      ~wordWrap: string=?,
      /* Animations - WD */
      ~animation: string=?,
      ~animationDelay: string=?,
      ~animationDirection: string=?,
      ~animationDuration: string=?,
      ~animationFillMode: string=?,
      ~animationIterationCount: string=?,
      ~animationName: string=?,
      ~animationPlayState: string=?,
      ~animationTimingFunction: string=?,
      /* Transitions - WD */
      ~transition: string=?,
      ~transitionDelay: string=?,
      ~transitionDuration: string=?,
      ~transitionProperty: string=?,
      ~transitionTimingFunction: string=?,
      /* Transforms Level 1 - WD */
      ~backfaceVisibility: string=?,
      ~perspective: string=?,
      ~perspectiveOrigin: string=?,
      ~transform: string=?,
      ~transformOrigin: string=?,
      ~transformStyle: string=?,
      /* Box Alignment Level 3 - WD */
      /* alignContent - already defined by Flexible Box Layout */
      /* alignItems - already defined by Flexible Box Layout */
      ~justifyItems: string=?,
      ~justifySelf: string=?,
      ~placeContent: string=?,
      ~placeItems: string=?,
      ~placeSelf: string=?,
      /* Basic User Interface Level 4 - FPWD */
      ~appearance: string=?,
      ~caret: string=?,
      ~caretAnimation: string=?,
      ~caretShape: string=?,
      ~userSelect: string=?,
      /* Overflow Level 3 - WD */
      ~maxLines: string=?,
      /* Basix Box Model - WD */
      ~marqueeDirection: string=?,
      ~marqueeLoop: string=?,
      ~marqueeSpeed: string=?,
      ~marqueeStyle: string=?,
      ~overflowStyle: string=?,
      ~rotation: string=?,
      ~rotationPoint: string=?,
      /* SVG 1.1 - REC */
      ~alignmentBaseline: string=?,
      ~baselineShift: string=?,
      ~clip: string=?,
      ~clipPath: string=?,
      ~clipRule: string=?,
      ~colorInterpolation: string=?,
      ~colorInterpolationFilters: string=?,
      ~colorProfile: string=?,
      ~colorRendering: string=?,
      ~cursor: string=?,
      ~dominantBaseline: string=?,
      ~fill: string=?,
      ~fillOpacity: string=?,
      ~fillRule: string=?,
      ~filter: string=?,
      ~floodColor: string=?,
      ~floodOpacity: string=?,
      ~glyphOrientationHorizontal: string=?,
      ~glyphOrientationVertical: string=?,
      ~imageRendering: string=?,
      ~kerning: string=?,
      ~lightingColor: string=?,
      ~markerEnd: string=?,
      ~markerMid: string=?,
      ~markerStart: string=?,
      ~pointerEvents: string=?,
      ~shapeRendering: string=?,
      ~stopColor: string=?,
      ~stopOpacity: string=?,
      ~stroke: string=?,
      ~strokeDasharray: string=?,
      ~strokeDashoffset: string=?,
      ~strokeLinecap: string=?,
      ~strokeLinejoin: string=?,
      ~strokeMiterlimit: string=?,
      ~strokeOpacity: string=?,
      ~strokeWidth: string=?,
      ~textAnchor: string=?,
      ~textRendering: string=?,
      /* Ruby Layout Level 1 - WD */
      ~rubyAlign: string=?,
      ~rubyMerge: string=?,
      ~rubyPosition: string=?,
      /* Lists and Counters Level 3 - WD */
      /* listStyle - already defined by CSS2Properties */
      /* listStyleImage - already defined by CSS2Properties */
      /* listStylePosition - already defined by CSS2Properties */
      /* listStyleType - already defined by CSS2Properties */
      /* counterIncrement - already defined by CSS2Properties */
      /* counterReset - already defined by CSS2Properties */
      /* Not added yet
       * -------------
       * Generated Content for Paged Media - WD
       * Generated Content Level 3 - WD
       * Line Grid Level 1 - WD
       * Regions - WD
       * Inline Layout Level 3 - WD
       * Round Display Level 1 - WD
       * Image Values and Replaced Content Level 4 - WD
       * Positioned Layout Level 3 - WD
       * Filter Effects Level 1 -  -WD
       * Exclusions Level 1 - WD
       * Text Level 4 - FPWD
       * SVG Markers - FPWD
       * Motion Path Level 1 - FPWD
       * Color Level 4 - FPWD
       * SVG Strokes - FPWD
       * Table Level 3 - FPWD
       */
      unit
    ) =>
    style;
  /* CSS2Properties: https://www.w3.org/TR/DOM-Level-2-Style/css.html#CSS-CSS2Properties */
  [@bs.val]
  external combine: ([@bs.as {json|{}|json}] _, style, style) => t =
    "Object.assign";

  external _dictToStyle: Js.Dict.t(string) => style = "%identity";

  let unsafeAddProp = (style, key, value) => {
    let dict = Js.Dict.empty();
    Js.Dict.set(dict, key, value);
    combine(style, _dictToStyle(dict));
  };

  [@bs.val]
  external unsafeAddStyle:
    ([@bs.as {json|{}|json}] _, style, Js.t({..})) => style =
    "Object.assign";
};
