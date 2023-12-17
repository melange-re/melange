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

external make : unit -> t = "Date"
[@@mel.new]
(** returns a date representing the current time *)

external fromFloat : float -> t = "Date" [@@mel.new]
external fromString : string -> t = "Date" [@@mel.new]
external makeWithYM : year:float -> month:float -> t = "Date" [@@mel.new]

external makeWithYMD : year:float -> month:float -> date:float -> t = "Date"
[@@mel.new]

external makeWithYMDH :
  year:float -> month:float -> date:float -> hours:float -> t = "Date"
[@@mel.new]

external makeWithYMDHM :
  year:float -> month:float -> date:float -> hours:float -> minutes:float -> t
  = "Date"
[@@mel.new]

external makeWithYMDHMS :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  seconds:float ->
  t = "Date"
[@@mel.new]

external utcWithYM : year:float -> month:float -> float = "UTC"
[@@mel.scope "Date"]

external utcWithYMD : year:float -> month:float -> date:float -> float = "UTC"
[@@mel.scope "Date"]

external utcWithYMDH :
  year:float -> month:float -> date:float -> hours:float -> float = "UTC"
[@@mel.scope "Date"]

external utcWithYMDHM :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  float = "UTC"
[@@mel.scope "Date"]

external utcWithYMDHMS :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  seconds:float ->
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
external setDate : float -> float = "setDate" [@@mel.send.pipe: t]
external setFullYear : float -> float = "setFullYear" [@@mel.send.pipe: t]

external setFullYearM : year:float -> month:float -> float = "setFullYear"
[@@mel.send.pipe: t]

external setFullYearMD : year:float -> month:float -> date:float -> float
  = "setFullYear"
[@@mel.send.pipe: t]

external setHours : float -> float = "setHours" [@@mel.send.pipe: t]

external setHoursM : hours:float -> minutes:float -> float = "setHours"
[@@mel.send.pipe: t]

external setHoursMS : hours:float -> minutes:float -> seconds:float -> float
  = "setHours"
[@@mel.send.pipe: t]

external setHoursMSMs :
  hours:float -> minutes:float -> seconds:float -> milliseconds:float -> float
  = "setHours"
[@@mel.send.pipe: t]

external setMilliseconds : float -> float = "setMilliseconds"
[@@mel.send.pipe: t]

external setMinutes : float -> float = "setMinutes" [@@mel.send.pipe: t]

external setMinutesS : minutes:float -> seconds:float -> float = "setMinutes"
[@@mel.send.pipe: t]

external setMinutesSMs :
  minutes:float -> seconds:float -> milliseconds:float -> float = "setMinutes"
[@@mel.send.pipe: t]

external setMonth : float -> float = "setMonth" [@@mel.send.pipe: t]

external setMonthD : month:float -> date:float -> float = "setMonth"
[@@mel.send.pipe: t]

external setSeconds : float -> float = "setSeconds" [@@mel.send.pipe: t]

external setSecondsMs : seconds:float -> milliseconds:float -> float
  = "setSeconds"
[@@mel.send.pipe: t]

external setTime : float -> float = "setTime" [@@mel.send.pipe: t]
external setUTCDate : float -> float = "setUTCDate" [@@mel.send.pipe: t]
external setUTCFullYear : float -> float = "setUTCFullYear" [@@mel.send.pipe: t]

external setUTCFullYearM : year:float -> month:float -> float = "setUTCFullYear"
[@@mel.send.pipe: t]

external setUTCFullYearMD : year:float -> month:float -> date:float -> float
  = "setUTCFullYear"
[@@mel.send.pipe: t]

external setUTCHours : float -> float = "setUTCHours" [@@mel.send.pipe: t]

external setUTCHoursM : hours:float -> minutes:float -> float = "setUTCHours"
[@@mel.send.pipe: t]

external setUTCHoursMS : hours:float -> minutes:float -> seconds:float -> float
  = "setUTCHours"
[@@mel.send.pipe: t]

external setUTCHoursMSMs :
  hours:float -> minutes:float -> seconds:float -> milliseconds:float -> float
  = "setUTCHours"
[@@mel.send.pipe: t]

external setUTCMilliseconds : float -> float = "setUTCMilliseconds"
[@@mel.send.pipe: t]

external setUTCMinutes : float -> float = "setUTCMinutes" [@@mel.send.pipe: t]

external setUTCMinutesS : minutes:float -> seconds:float -> float
  = "setUTCMinutes"
[@@mel.send.pipe: t]

external setUTCMinutesSMs :
  minutes:float -> seconds:float -> milliseconds:float -> float
  = "setUTCMinutes"
[@@mel.send.pipe: t]

external setUTCMonth : float -> float = "setUTCMonth" [@@mel.send.pipe: t]

external setUTCMonthD : month:float -> date:float -> float = "setUTCMonth"
[@@mel.send.pipe: t]

external setUTCSeconds : float -> float = "setUTCSeconds" [@@mel.send.pipe: t]

external setUTCSecondsMs : seconds:float -> milliseconds:float -> float
  = "setUTCSeconds"
[@@mel.send.pipe: t]

external setUTCTime : float -> float = "setTime" [@@mel.send.pipe: t]
external toDateString : string = "toDateString" [@@mel.send.pipe: t]
external toISOString : string = "toISOString" [@@mel.send.pipe: t]

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
