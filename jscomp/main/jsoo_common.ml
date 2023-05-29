module Js = struct
  module Unsafe = struct
    type any

    external inject : 'a -> any = "%identity"
    external get : 'a -> 'b -> 'c = "caml_js_get"
    external set : 'a -> 'b -> 'c -> unit = "caml_js_set"
    external pure_js_expr : string -> 'a = "caml_pure_js_expr"

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

  external string : string -> js_string t = "caml_js_from_string"
  external to_string : js_string t -> string = "caml_js_to_string"
  external create_file : js_string t -> js_string t -> unit = "caml_create_file"
  external to_bytestring : js_string t -> string = "caml_js_to_byte_string"
end

let string_of_formatted ~f x =
  let buffer = Buffer.create 64 in
  let str_fmt = Format.formatter_of_buffer buffer in
  f str_fmt x;
  Format.pp_print_flush str_fmt ();
  Buffer.contents buffer

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
  let txt =
    string_of_formatted
      ~f:(fun fmt -> Format.fprintf fmt "@[%t@]")
      error.main.txt
  in
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
