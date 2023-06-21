module Js = struct
  module Unsafe = struct
    type any

    external inject : 'a -> any = "%identity"
    external get : 'a -> 'b -> 'c = "caml_js_get"
    external set : 'a -> 'b -> 'c -> unit = "caml_js_set"
    external pure_js_expr : string -> 'a = "caml_pure_js_expr"
    external js_expr : string -> 'a = "caml_js_expr"
    external fun_call : 'a -> any array -> 'b = "caml_js_fun_call"

    let global = pure_js_expr "joo_global_object"

    type obj

    external obj : (string * any) array -> obj = "caml_js_object"
  end

  type (-'a, +'b) meth_callback
  type 'a callback = (unit, 'a) meth_callback

  external wrap_callback : ('a -> 'b) -> ('c, 'a -> 'b) meth_callback
    = "caml_js_wrap_callback"

  external wrap_meth_callback : ('a -> 'b) -> ('a, 'b) meth_callback
    = "caml_js_wrap_meth_callback"

  type +'a t
  type js_string
  type number
  type 'a optdef = 'a

  external string : string -> js_string t = "caml_js_from_string"
  external to_string : js_string t -> string = "caml_js_to_string"
  external create_file : js_string t -> js_string t -> unit = "caml_create_file"
  external to_bytestring : js_string t -> string = "caml_js_to_byte_string"
  external number_of_float : float -> number t = "caml_js_from_float"

  let undefined : 'a optdef = Unsafe.pure_js_expr "undefined"
end

module Reason = struct
  (* Adapted from https://github.com/reasonml/reason/blob/da280770cf905502d4b99788d9f3d1462893b53e/js/refmt.ml *)
  module RE = Reason_toolchain.RE
  module ML = Reason_toolchain.ML

  let locationToJsObj (loc : Location.t) =
    let _file, start_line, start_char = Location.get_pos_info loc.loc_start in
    let _, end_line, end_char = Location.get_pos_info loc.loc_end in
    (* The right way of handling ocaml syntax error locations. Do do this at home
       copied over from
       https://github.com/BuckleScript/bucklescript/blob/2ad2310f18567aa13030cdf32adb007d297ee717/jscomp/super_errors/super_location.ml#L73
    *)
    let normalizedRange =
      if start_char == -1 || end_char == -1 then
        (* happens sometimes. Syntax error for example *)
        None
      else if start_line = end_line && start_char >= end_char then
        (* in some errors, starting char and ending char can be the same. But
           since ending char was supposed to be exclusive, here it might end up
           smaller than the starting char if we naively did start_char + 1 to
           just the starting char and forget ending char *)
        let same_char = start_char + 1 in
        Some ((start_line, same_char), (end_line, same_char))
      else
        (* again: end_char is exclusive, so +1-1=0 *)
        Some ((start_line, start_char + 1), (end_line, end_char))
    in
    match normalizedRange with
    | None -> Js.undefined
    | Some ((start_line, start_line_start_char), (end_line, end_line_end_char))
      ->
        let intToJsFloatToAny i =
          i |> float_of_int |> Js.number_of_float |> Js.Unsafe.inject
        in
        Js.Unsafe.obj
          [|
            ("startLine", intToJsFloatToAny start_line);
            ("startLineStartChar", intToJsFloatToAny start_line_start_char);
            ("endLine", intToJsFloatToAny end_line);
            ("endLineEndChar", intToJsFloatToAny end_line_end_char);
          |]

  let parseWith f code =
    (* you can't throw an Error here. jsoo parses the string and turns it
       into something else *)
    let throwAnything = Js.Unsafe.js_expr "function(a) {throw a}" in
    let code =
      (* Add ending new line as otherwise reason parser chokes with inputs such as "//" *)
      Js.to_string code ^ "\n"
    in
    try code |> Lexing.from_string |> f
    with (* from ocaml and reason *)
    | Reason_errors.Reason_error (err, loc) ->
      let jsLocation = locationToJsObj loc in
      Reason_errors.report_error ~loc Format.str_formatter err;
      let errorString = Format.flush_str_formatter () in
      let jsError =
        Js.Unsafe.obj
          [|
            ("message", Js.Unsafe.inject (Js.string errorString));
            ("location", Js.Unsafe.inject jsLocation);
          |]
      in
      Js.Unsafe.fun_call throwAnything [| Js.Unsafe.inject jsError |]

  let parseRE = parseWith RE.implementation_with_comments
  let parseML = parseWith ML.implementation_with_comments
  (* let parseREI = parseWith RE.interface_with_comments *)
  (* let parseMLI = parseWith ML.interface_with_comments *)

  let printWith f structureAndComments =
    f Format.str_formatter structureAndComments;
    Format.flush_str_formatter () |> Js.string

  let printRE = printWith RE.print_implementation_with_comments
  let printML = printWith ML.print_implementation_with_comments
  (* let printREI = printWith RE.print_interface_with_comments *)
  (* let printMLI = printWith ML.print_interface_with_comments *)
end

let mk_js_error (error : Location.report) =
  let kind, type_ =
    match error.kind with
    | Location.Report_error -> ("Error", "error")
    | Report_warning w -> (Printf.sprintf "Warning: %s" w, "warning")
    | Report_warning_as_error w ->
        (Printf.sprintf "Error: (warning %s)" w, "warning_as_error")
    | Report_alert w -> (Printf.sprintf "Alert: %s" w, "alert")
    | Report_alert_as_error w ->
        (Printf.sprintf "Error: (alert %s)" w, "alert_as_error")
  in
  let txt = Format.asprintf "@[%t@]" error.main.txt in
  let loc = error.main.loc in
  let _file, line, startchar = Location.get_pos_info loc.Location.loc_start in
  let _file, endline, endchar = Location.get_pos_info loc.Location.loc_end in
  Js.Unsafe.(
    obj
      [|
        ( "js_error_msg",
          inject
          @@ Js.string
               (Printf.sprintf "Line %d, %d:\n  %s %s" line startchar kind txt)
        );
        ("row", inject (line - 1));
        ("column", inject startchar);
        ("endRow", inject (endline - 1));
        ("endColumn", inject endchar);
        ("text", inject @@ Js.string txt);
        ("type", inject @@ Js.string type_);
      |])
