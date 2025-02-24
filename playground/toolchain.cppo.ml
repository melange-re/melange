module Js = Jsoo_runtime.Js
module RE = Reason_toolchain.RE
module ML = Reason_toolchain.ML

let intToJsFloat i = Js.number_of_float (float_of_int i)

(* Add ending newline as otherwise the Reason parser takes a while to parse
   inputs that end with newline characters *)
let feed_string_with_newline str =
  let strlen = String.length str in
  let off = ref 0 in
  let f buf n =
    let remaining = strlen + 1 - !off in
    if remaining = 0 then 0
    else if remaining > n then (
      Bytes.blit_string str !off buf 0 n;
      off := !off + n;
      n)
    else (
      Bytes.blit_string str !off buf 0 (remaining - 1);
      Bytes.blit_string "\n" 0 buf (remaining - 1) 1;
      off := !off + remaining;
      remaining)
  in
  Lexing.from_function f

let parseWith =
  (* Adapted from:
     https://github.com/reasonml/reason/blob/da280770c/js/refmt.ml *)
  let locationToJsObj (loc : Location.t) =
    let _file, start_line, start_char = Location.get_pos_info loc.loc_start in
    let _, end_line, end_char = Location.get_pos_info loc.loc_end in
    (* The right way of handling ocaml syntax error locations. Do do this at home
       copied over from
       https://github.com/BuckleScript/bucklescript/blob/2ad2310f1/jscomp/super_errors/super_location.ml#L73
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
    | None -> Js.pure_js_expr "undefined"
    | Some ((start_line, start_line_start_char), (end_line, end_line_end_char))
      ->
        Js.obj
          [|
            ("startLine", intToJsFloat start_line);
            ("startLineStartChar", intToJsFloat start_line_start_char);
            ("endLine", intToJsFloat end_line);
            ("endLineEndChar", intToJsFloat end_line_end_char);
          |]
  in
  fun (f :
        Lexing.lexbuf -> Ppxlib_ast.Parsetree.structure * Reason_comment.t list)
      lexbuf ->
    (* you can't throw an Error here. jsoo parses the string and turns it into
       something else *)
    let throwAnything = Js.js_expr "function(a) {throw a}" in
    try f lexbuf
    with
    | Reason_errors.Reason_error (err, loc) ->
      let jsLocation = locationToJsObj loc in
      let error_buf = Buffer.create 256 in
      let error_fmt = Format.formatter_of_buffer error_buf in
      Reason_errors.report_error ~loc error_fmt err;
      let jsError =
        Js.obj
          [|
            ("message", Js.string (Buffer.contents error_buf));
            ("location", jsLocation);
          |]
      in
      Obj.magic (Js.fun_call throwAnything [| jsError |])

let parseRE s =
  parseWith RE.implementation_with_comments
    (feed_string_with_newline (Js.to_string s))

let parseML s =
  parseWith ML.implementation_with_comments
    (feed_string_with_newline (Js.to_string s))

let printWith ~f structureAndComments =
  Js.string (Format.asprintf "%a" f structureAndComments)

let printRE = printWith ~f:RE.print_implementation_with_comments
let printML = printWith ~f:ML.print_implementation_with_comments

let warning_error_to_js (error : Location.report) : Js.t =
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
#if OCAML_VERSION >= (5,3,0)
  let txt = Format.asprintf "@[%a@]" Format_doc.Doc.format error.main.txt in
#else
  let txt = Format.asprintf "@[%t@]" error.main.txt in
#endif
  let loc = error.main.loc in
  let _file, line, startchar = Location.get_pos_info loc.Location.loc_start in
  let _file, endline, endchar = Location.get_pos_info loc.Location.loc_end in
  Js.obj
    [|
      ( "js_warning_error_msg",
        Js.string
          (Printf.sprintf "Line %d, %d:\n  %s %s" line startchar kind txt) );
      ("row", intToJsFloat (line - 1));
      ("column", intToJsFloat startchar);
      ("endRow", intToJsFloat (endline - 1));
      ("endColumn", intToJsFloat endchar);
      ("text", Js.string txt);
      ("type", Js.string type_);
    |]
