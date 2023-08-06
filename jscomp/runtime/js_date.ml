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

external makeWithYM : year:float -> month:float -> unit -> t = "Date"
[@@mel.new]

external makeWithYMD : year:float -> month:float -> date:float -> unit -> t
  = "Date"
[@@mel.new]

external makeWithYMDH :
  year:float -> month:float -> date:float -> hours:float -> unit -> t = "Date"
[@@mel.new]

external makeWithYMDHM :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  unit ->
  t = "Date"
[@@mel.new]

external makeWithYMDHMS :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  seconds:float ->
  unit ->
  t = "Date"
[@@mel.new]

external utcWithYM : year:float -> month:float -> unit -> float = "UTC"
[@@mel.scope "Date"]

external utcWithYMD : year:float -> month:float -> date:float -> unit -> float
  = "UTC"
[@@mel.scope "Date"]

external utcWithYMDH :
  year:float -> month:float -> date:float -> hours:float -> unit -> float
  = "UTC"
[@@mel.scope "Date"]

external utcWithYMDHM :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  unit ->
  float = "UTC"
[@@mel.scope "Date"]

external utcWithYMDHMS :
  year:float ->
  month:float ->
  date:float ->
  hours:float ->
  minutes:float ->
  seconds:float ->
  unit ->
  float = "UTC"
[@@mel.scope "Date"]

external now : unit -> float = "now"
[@@mel.scope "Date"]
(** returns the number of milliseconds since Unix epoch *)

external parse : string -> t = "Date"
[@@mel.new] [@@deprecated "Please use `fromString` instead"]

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

external getYear : t -> float = "getYear"
[@@mel.send] [@@deprecated "use `getFullYear` instead"]

external setDate : t -> float -> float = "setDate" [@@mel.send]
external setFullYear : t -> float -> float = "setFullYear" [@@mel.send]

external setFullYearM : t -> year:float -> month:float -> unit -> float
  = "setFullYear"
[@@mel.send]

external setFullYearMD :
  t -> year:float -> month:float -> date:float -> unit -> float = "setFullYear"
[@@mel.send]

external setHours : t -> float -> float = "setHours" [@@mel.send]

external setHoursM : t -> hours:float -> minutes:float -> unit -> float
  = "setHours"
[@@mel.send]

external setHoursMS :
  t -> hours:float -> minutes:float -> seconds:float -> unit -> float
  = "setHours"
[@@mel.send]

external setHoursMSMs :
  t ->
  hours:float ->
  minutes:float ->
  seconds:float ->
  milliseconds:float ->
  unit ->
  float = "setHours"
[@@mel.send]

external setMilliseconds : t -> float -> float = "setMilliseconds" [@@mel.send]
external setMinutes : t -> float -> float = "setMinutes" [@@mel.send]

external setMinutesS : t -> minutes:float -> seconds:float -> unit -> float
  = "setMinutes"
[@@mel.send]

external setMinutesSMs :
  t -> minutes:float -> seconds:float -> milliseconds:float -> unit -> float
  = "setMinutes"
[@@mel.send]

external setMonth : t -> float -> float = "setMonth" [@@mel.send]

external setMonthD : t -> month:float -> date:float -> unit -> float
  = "setMonth"
[@@mel.send]

external setSeconds : t -> float -> float = "setSeconds" [@@mel.send]

external setSecondsMs :
  t -> seconds:float -> milliseconds:float -> unit -> float = "setSeconds"
[@@mel.send]

external setTime : t -> float -> float = "setTime" [@@mel.send]
external setUTCDate : t -> float -> float = "setUTCDate" [@@mel.send]
external setUTCFullYear : t -> float -> float = "setUTCFullYear" [@@mel.send]

external setUTCFullYearM : t -> year:float -> month:float -> unit -> float
  = "setUTCFullYear"
[@@mel.send]

external setUTCFullYearMD :
  t -> year:float -> month:float -> date:float -> unit -> float
  = "setUTCFullYear"
[@@mel.send]

external setUTCHours : t -> float -> float = "setUTCHours" [@@mel.send]

external setUTCHoursM : t -> hours:float -> minutes:float -> unit -> float
  = "setUTCHours"
[@@mel.send]

external setUTCHoursMS :
  t -> hours:float -> minutes:float -> seconds:float -> unit -> float
  = "setUTCHours"
[@@mel.send]

external setUTCHoursMSMs :
  t ->
  hours:float ->
  minutes:float ->
  seconds:float ->
  milliseconds:float ->
  unit ->
  float = "setUTCHours"
[@@mel.send]

external setUTCMilliseconds : t -> float -> float = "setUTCMilliseconds"
[@@mel.send]

external setUTCMinutes : t -> float -> float = "setUTCMinutes" [@@mel.send]

external setUTCMinutesS : t -> minutes:float -> seconds:float -> unit -> float
  = "setUTCMinutes"
[@@mel.send]

external setUTCMinutesSMs :
  t -> minutes:float -> seconds:float -> milliseconds:float -> unit -> float
  = "setUTCMinutes"
[@@mel.send]

external setUTCMonth : t -> float -> float = "setUTCMonth" [@@mel.send]

external setUTCMonthD : t -> month:float -> date:float -> unit -> float
  = "setUTCMonth"
[@@mel.send]

external setUTCSeconds : t -> float -> float = "setUTCSeconds" [@@mel.send]

external setUTCSecondsMs :
  t -> seconds:float -> milliseconds:float -> unit -> float = "setUTCSeconds"
[@@mel.send]

external setUTCTime : t -> float -> float = "setTime" [@@mel.send]

external setYear : t -> float -> float = "setYear"
[@@mel.send] [@@deprecated "use `setFullYear` instead"]

external toDateString : t -> string = "toDateString" [@@mel.send]

external toGMTString : t -> string = "toGMTString"
[@@mel.send] [@@deprecated "use `toUTCString` instead"]

external toISOString : t -> string = "toISOString" [@@mel.send]

external toJSON : t -> string = "toJSON"
[@@mel.send]
[@@deprecated
  "This method is unsafe. It will be changed to return option in a future \
   release. Please use toJSONUnsafe instead."]

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
