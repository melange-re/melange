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

(** JavaScript Date API *)

type t

external valueOf : t -> float = "valueOf"
[@@mel.send]
(** returns the primitive value of this date, equivalent to getTime *)

external fromFloat : float -> t = "Date" [@@mel.new]
external fromString : string -> t = "Date" [@@mel.new]

external make :
  ?year:float ->
  ?month:float ->
  ?date:float ->
  ?hours:float ->
  ?minutes:float ->
  ?seconds:float ->
  unit ->
  t = "Date"
[@@mel.new]
(** [make ()] returns a date representing the current time. *)

external utc :
  year:float ->
  ?month:float ->
  ?date:float ->
  ?hours:float ->
  ?minutes:float ->
  ?seconds:float ->
  unit ->
  float = "UTC"
[@@mel.scope "Date"]

external now : unit -> float = "now"
[@@mel.scope "Date"]
(** returns the number of milliseconds since Unix epoch *)

external parseAsFloat : string -> float = "parse"
[@@mel.scope "Date"]
(** returns NaN if passed invalid date string *)

external getDate : t -> float = "getDate"
[@@mel.send]
(** return the day of the month (1-31) *)

external getDay : t -> float = "getDay"
[@@mel.send]
(** returns the day of the week (0-6) *)

external getFullYear : t -> float = "getFullYear" [@@mel.send]
external getHours : t -> float = "getHours" [@@mel.send]
external getMilliseconds : t -> float = "getMilliseconds" [@@mel.send]
external getMinutes : t -> float = "getMinutes" [@@mel.send]

external getMonth : t -> float = "getMonth"
[@@mel.send]
(** returns the month (0-11) *)

external getSeconds : t -> float = "getSeconds" [@@mel.send]

external getTime : t -> float = "getTime"
[@@mel.send]
(** returns the number of milliseconds since Unix epoch *)

external getTimezoneOffset : t -> float = "getTimezoneOffset" [@@mel.send]

external getUTCDate : t -> float = "getUTCDate"
[@@mel.send]
(** return the day of the month (1-31) *)

external getUTCDay : t -> float = "getUTCDay"
[@@mel.send]
(** returns the day of the week (0-6) *)

external getUTCFullYear : t -> float = "getUTCFullYear" [@@mel.send]
external getUTCHours : t -> float = "getUTCHours" [@@mel.send]
external getUTCMilliseconds : t -> float = "getUTCMilliseconds" [@@mel.send]
external getUTCMinutes : t -> float = "getUTCMinutes" [@@mel.send]

external getUTCMonth : t -> float = "getUTCMonth"
[@@mel.send]
(** returns the month (0-11) *)

external getUTCSeconds : t -> float = "getUTCSeconds" [@@mel.send]

external setDate : date:float -> (t[@mel.this]) -> float = "setDate"
[@@mel.send]

external setFullYear :
  year:float -> ?month:float -> ?date:float -> (t[@mel.this]) -> float
  = "setFullYear"
[@@mel.send]

external setHours :
  hours:float ->
  ?minutes:float ->
  ?seconds:float ->
  ?milliseconds:float ->
  (t[@mel.this]) ->
  float = "setHours"
[@@mel.send]

external setMilliseconds : milliseconds:float -> (t[@mel.this]) -> float
  = "setMilliseconds"
[@@mel.send]

external setMinutes :
  minutes:float ->
  ?seconds:float ->
  ?milliseconds:float ->
  (t[@mel.this]) ->
  float = "setMinutes"
[@@mel.send]

external setMonth : month:float -> ?date:float -> (t[@mel.this]) -> float
  = "setMonth"
[@@mel.send]

external setSeconds :
  seconds:float -> ?milliseconds:float -> (t[@mel.this]) -> float = "setSeconds"
[@@mel.send]

external setTime : time:float -> (t[@mel.this]) -> float = "setTime"
[@@mel.send]

external setUTCDate : date:float -> (t[@mel.this]) -> float = "setUTCDate"
[@@mel.send]

external setUTCFullYear :
  year:float -> ?month:float -> ?date:float -> (t[@mel.this]) -> float
  = "setUTCFullYear"
[@@mel.send]

external setUTCHours :
  hours:float ->
  ?minutes:float ->
  ?seconds:float ->
  ?milliseconds:float ->
  (t[@mel.this]) ->
  float = "setUTCHours"
[@@mel.send]

external setUTCMilliseconds : milliseconds:float -> (t[@mel.this]) -> float
  = "setUTCMilliseconds"
[@@mel.send]

external setUTCMinutes :
  minutes:float ->
  ?seconds:float ->
  ?milliseconds:float ->
  (t[@mel.this]) ->
  float = "setUTCMinutes"
[@@mel.send]

external setUTCMonth : month:float -> ?date:float -> (t[@mel.this]) -> float
  = "setUTCMonth"
[@@mel.send]

external setUTCSeconds :
  seconds:float -> ?milliseconds:float -> (t[@mel.this]) -> float
  = "setUTCSeconds"
[@@mel.send]

external setUTCTime : time:float -> (t[@mel.this]) -> float = "setTime"
[@@mel.send]

external toDateString : t -> string = "toDateString" [@@mel.send]
external toISOString : t -> string = "toISOString" [@@mel.send]

external toJSON : t -> string option = "toJSON"
[@@mel.send] [@@mel.return undefined_to_opt]

external toJSONUnsafe : t -> string = "toJSON" [@@mel.send]
external toLocaleDateString : t -> string = "toLocaleDateString" [@@mel.send]

(* TODO: has overloads with somewhat poor browser support *)
external toLocaleString : t -> string = "toLocaleString" [@@mel.send]

(* TODO: has overloads with somewhat poor browser support *)
external toLocaleTimeString : t -> string = "toLocaleTimeString" [@@mel.send]

(* TODO: has overloads with somewhat poor browser support *)
external toString : t -> string = "toString" [@@mel.send]
external toTimeString : t -> string = "toTimeString" [@@mel.send]
external toUTCString : t -> string = "toUTCString" [@@mel.send]
