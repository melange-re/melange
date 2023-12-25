(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

let verbose = ref false

module Style = struct
  [@@@warning "-37"]

  type t =
    | Loc
    | Error
    | Warning
    | Kwd
    | Prompt
    | Hint
    | Details
    | Ok
    | Debug
    | Success
    | Ansi_styles of Ansi_color.Style.t list

  let to_styles = function
    | Loc -> [ `Bold ]
    | Error -> [ `Bold; `Fg_red ]
    | Warning -> [ `Bold; `Fg_magenta ]
    | Kwd -> [ `Bold; `Fg_blue ]
    | Prompt -> [ `Bold; `Fg_green ]
    | Hint -> [ `Italic; `Fg_white ]
    | Details -> [ `Dim; `Fg_white ]
    | Ok -> [ `Dim; `Fg_green ]
    | Debug -> [ `Underline; `Fg_bright_cyan ]
    | Success -> [ `Bold; `Fg_green ]
    | Ansi_styles l -> l

  let of_string = function
    | "loc" -> Some Loc
    | "error" -> Some Error
    | "warning" -> Some Warning
    | "kwd" -> Some Kwd
    | "prompt" -> Some Prompt
    | "details" -> Some Details
    | "ok" -> Some Ok
    | "debug" -> Some Debug
    | _ -> None
end

let setup_err_formatter_colors =
  let mark_open_stag = function
    | Format.String_tag s -> (
        match Style.of_string s with
        | Some style -> Ansi_color.Style.escape_sequence (Style.to_styles style)
        | None -> if s <> "" && s.[0] = '\027' then s else "")
    | _ -> ""
  in
  fun () ->
    if Lazy.force Ansi_color.stderr_supports_color then (
      let open Format in
      let funcs = pp_get_formatter_stag_functions err_formatter () in
      pp_set_mark_tags err_formatter true;
      pp_set_formatter_stag_functions err_formatter
        {
          funcs with
          mark_close_stag = (fun _ -> Ansi_color.Style.escape_sequence []);
          mark_open_stag;
        })

let () = setup_err_formatter_colors ()

module Level = struct
  type t = Quiet | Verbose
end

let set_level level =
  let is_verbose = match level with Level.Quiet -> false | Verbose -> true in
  verbose := is_verbose

type t = {
  loc : Location.t option;
  paragraphs : Style.t Pp.t list;
  hints : Style.t Pp.t list;
}

let make ?loc ?prefix ?(hints = []) paragraphs =
  let paragraphs =
    match (prefix, paragraphs) with
    | None, l -> l
    | Some p, [] -> [ p ]
    | Some p, x :: l -> Pp.concat ~sep:Pp.space [ p; x ] :: l
  in
  { loc; hints; paragraphs }

let pp { loc; paragraphs; hints } =
  let open Pp.O in
  let paragraphs =
    match hints with
    | [] -> paragraphs
    | _ ->
        List.append paragraphs
          (List.map
             ~f:(fun hint ->
               Pp.tag Style.Hint (Pp.verbatim "Hint:") ++ Pp.space ++ hint)
             hints)
  in
  let paragraphs = List.map ~f:Pp.box paragraphs in
  let paragraphs =
    match loc with
    | None -> paragraphs
    | Some loc ->
        let start = loc.loc_start in
        let end_ = loc.loc_end in
        let start_c = start.pos_cnum - start.pos_bol in
        let end_c = end_.pos_cnum - start.pos_bol in
        Pp.box
          (Pp.tag Style.Loc
             (Pp.textf "File %S, line %d, characters %d-%d:" start.pos_fname
                start.pos_lnum start_c end_c))
        :: paragraphs
  in
  Pp.vbox (Pp.concat_map paragraphs ~sep:Pp.nop ~f:(fun pp -> Pp.seq pp Pp.cut))

let print ?(config = Style.to_styles) t =
  Ansi_color.print (Pp.map_tags (pp t) ~f:config)

let prerr ?(config = Style.to_styles) t =
  Ansi_color.prerr (Pp.map_tags (pp t) ~f:config)

let info ?(loc : Location.t option) f =
  let open Pp.O in
  if !verbose then
    prerr
      (make ?loc
         [ Pp.tag Style.Success (Pp.verbatim "[INFO]") ++ Pp.space ++ f ])

let warn ?(loc : Location.t option) f =
  let open Pp.O in
  if !verbose then
    prerr
      (make ?loc
         [ Pp.tag Style.Warning (Pp.verbatim "[WARN]") ++ Pp.space ++ f ])
