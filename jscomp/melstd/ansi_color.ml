(*
 * Copyright (c) 2016 Jane Street Group, LLC opensource@janestreet.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *)

module RGB8 : sig
  type t

  val of_int : int -> t
  val to_int : t -> int
  val of_char : char -> t
  val to_char : t -> char
  val compare : t -> t -> int

  (* This is only used internally. *)
  val write_to_buffer : Buffer.t -> t -> unit
end = struct
  type t = char

  let of_char t = t
  let to_char t = t
  let of_int t = char_of_int (t land 0xFF)
  let to_int t = int_of_char t
  let compare t1 t2 = Char.compare t1 t2

  let write_to_buffer buf c =
    Buffer.add_string buf "38;5;";
    int_of_char c |> Int.to_string |> Buffer.add_string buf
end

module RGB24 : sig
  type t

  val red : t -> int
  val green : t -> int
  val blue : t -> int
  val make : red:int -> green:int -> blue:int -> t
  val to_int : t -> int
  val of_int : int -> t
  val compare : t -> t -> int

  (* This is only used internally. *)
  val write_to_buffer : Buffer.t -> t -> unit
end = struct
  type t = int

  let compare = Int.compare
  let red t = Int.shift_right t 16 land 0xFF
  let green t = Int.shift_right t 8 land 0xFF
  let blue t = t land 0xFF
  let to_int t = t
  let of_int t = t

  let make ~red ~green ~blue =
    ((red land 0xFF) lsl 16) lor ((green land 0xFF) lsl 8) lor (blue land 0xFF)

  let write_to_buffer buf t =
    Buffer.add_string buf "38;2;";
    red t |> Int.to_string |> Buffer.add_string buf;
    Buffer.add_char buf ';';
    green t |> Int.to_string |> Buffer.add_string buf;
    Buffer.add_char buf ';';
    blue t |> Int.to_string |> Buffer.add_string buf
end

module Style = struct
  type t =
    [ `Fg_default
    | `Fg_black
    | `Fg_red
    | `Fg_green
    | `Fg_yellow
    | `Fg_blue
    | `Fg_magenta
    | `Fg_cyan
    | `Fg_white
    | `Fg_bright_black
    | `Fg_bright_red
    | `Fg_bright_green
    | `Fg_bright_yellow
    | `Fg_bright_blue
    | `Fg_bright_magenta
    | `Fg_bright_cyan
    | `Fg_bright_white
    | `Fg_8_bit_color of RGB8.t
    | `Fg_24_bit_color of RGB24.t
    | `Bg_default
    | `Bg_black
    | `Bg_red
    | `Bg_green
    | `Bg_yellow
    | `Bg_blue
    | `Bg_magenta
    | `Bg_cyan
    | `Bg_white
    | `Bg_bright_black
    | `Bg_bright_red
    | `Bg_bright_green
    | `Bg_bright_yellow
    | `Bg_bright_blue
    | `Bg_bright_magenta
    | `Bg_bright_cyan
    | `Bg_bright_white
    | `Bg_8_bit_color of RGB8.t
    | `Bg_24_bit_color of RGB24.t
    | `Bold
    | `Dim
    | `Italic
    | `Underline ]

  let write_to_buffer buf : t -> unit = function
    | `Fg_default -> Buffer.add_string buf "39"
    | `Fg_black -> Buffer.add_string buf "30"
    | `Fg_red -> Buffer.add_string buf "31"
    | `Fg_green -> Buffer.add_string buf "32"
    | `Fg_yellow -> Buffer.add_string buf "33"
    | `Fg_blue -> Buffer.add_string buf "34"
    | `Fg_magenta -> Buffer.add_string buf "35"
    | `Fg_cyan -> Buffer.add_string buf "36"
    | `Fg_white -> Buffer.add_string buf "37"
    | `Fg_bright_black -> Buffer.add_string buf "90"
    | `Fg_bright_red -> Buffer.add_string buf "91"
    | `Fg_bright_green -> Buffer.add_string buf "92"
    | `Fg_bright_yellow -> Buffer.add_string buf "93"
    | `Fg_bright_blue -> Buffer.add_string buf "94"
    | `Fg_bright_magenta -> Buffer.add_string buf "95"
    | `Fg_bright_cyan -> Buffer.add_string buf "96"
    | `Fg_bright_white -> Buffer.add_string buf "97"
    | `Fg_8_bit_color c -> RGB8.write_to_buffer buf c
    | `Fg_24_bit_color rgb -> RGB24.write_to_buffer buf rgb
    | `Bg_default -> Buffer.add_string buf "49"
    | `Bg_black -> Buffer.add_string buf "40"
    | `Bg_red -> Buffer.add_string buf "41"
    | `Bg_green -> Buffer.add_string buf "42"
    | `Bg_yellow -> Buffer.add_string buf "43"
    | `Bg_blue -> Buffer.add_string buf "44"
    | `Bg_magenta -> Buffer.add_string buf "45"
    | `Bg_cyan -> Buffer.add_string buf "46"
    | `Bg_white -> Buffer.add_string buf "47"
    | `Bg_bright_black -> Buffer.add_string buf "100"
    | `Bg_bright_red -> Buffer.add_string buf "101"
    | `Bg_bright_green -> Buffer.add_string buf "102"
    | `Bg_bright_yellow -> Buffer.add_string buf "103"
    | `Bg_bright_blue -> Buffer.add_string buf "104"
    | `Bg_bright_magenta -> Buffer.add_string buf "105"
    | `Bg_bright_cyan -> Buffer.add_string buf "106"
    | `Bg_bright_white -> Buffer.add_string buf "107"
    | `Bg_8_bit_color c -> RGB8.write_to_buffer buf c
    | `Bg_24_bit_color rgb -> RGB24.write_to_buffer buf rgb
    | `Bold -> Buffer.add_string buf "1"
    | `Dim -> Buffer.add_string buf "2"
    | `Italic -> Buffer.add_string buf "3"
    | `Underline -> Buffer.add_string buf "4"

  module Of_ansi_code = struct
    type code = t
    type nonrec t = [ `Clear | `Unknown | code ]

    let write_to_buffer (buf : Buffer.t) = function
      | `Clear -> Buffer.add_char buf '0'
      | `Unknown -> Buffer.add_char buf '0'
      | #code as t -> write_to_buffer buf (t :> code)
  end

  let rec write_codes buf = function
    | [] -> ()
    | [ t ] -> Of_ansi_code.write_to_buffer buf t
    | t :: ts ->
        Of_ansi_code.write_to_buffer buf t;
        Buffer.add_char buf ';';
        write_codes buf ts

  let escape_sequence_no_reset buf l =
    Buffer.add_string buf "\027[";
    write_codes buf l;
    Buffer.add_char buf 'm';
    let res = Buffer.contents buf in
    Buffer.clear buf;
    res

  let escape_sequence_buf buf l =
    escape_sequence_no_reset buf (`Clear :: (l :> Of_ansi_code.t list))

  let escape_sequence (l : t list) =
    escape_sequence_buf (Buffer.create 16) (l :> Of_ansi_code.t list)
end

let supports_color isatty =
  let is_smart =
    match Sys.getenv "TERM" with
    | "dumb" -> false
    | _ | (exception Not_found) -> true
  and clicolor =
    match Sys.getenv "CLICOLOR" with
    | "0" -> false
    | _ | (exception Not_found) -> true
  and clicolor_force =
    match Sys.getenv "CLICOLOR_FORCE" with
    | (exception Not_found) | "0" -> false
    | _ -> true
  in
  clicolor_force || (is_smart && clicolor && Lazy.force isatty)

let stdout_supports_color =
  lazy (supports_color (lazy (Unix.isatty Unix.stdout)))

let output_is_a_tty = lazy (Unix.isatty Unix.stderr)
let stderr_supports_color = lazy (supports_color output_is_a_tty)

let rec tag_handler buf current_styles ppf (styles : Style.t list) pp =
  Format.pp_print_as ppf 0
    (Style.escape_sequence_no_reset buf (styles :> Style.Of_ansi_code.t list));
  Pp.to_fmt_with_tags ppf pp
    ~tag_handler:(tag_handler buf (current_styles @ styles));
  Format.pp_print_as ppf 0
    (Style.escape_sequence_buf buf (current_styles :> Style.t list))

let make_printer supports_color ppf =
  let f =
    lazy
      (if Lazy.force supports_color then
         let buf = Buffer.create 16 in
         Pp.to_fmt_with_tags ppf ~tag_handler:(tag_handler buf [])
       else Pp.to_fmt ppf)
  in
  fun pp ->
    Lazy.force f pp;
    Format.pp_print_flush ppf ()

let print = make_printer stdout_supports_color Format.std_formatter
let prerr = make_printer stderr_supports_color Format.err_formatter
