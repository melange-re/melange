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

external to_int : int32 -> int = "%int32_to_int"
external add : int32 -> int32 -> int32 = "%int32_add"
external shift_left : int32 -> int -> int32 = "%int32_lsl"
external shift_right_logical : int32 -> int -> int32 = "%int32_lsr"
external shift_right : int32 -> int -> int32 = "%int32_asr"
external logand : int32 -> int32 -> int32 = "%int32_and"
external logxor : int32 -> int32 -> int32 = "%int32_xor"
external logor : int32 -> int32 -> int32 = "%int32_or"
external of_int : int -> int32 = "%int32_of_int"
external mul : int32 -> int32 -> int32 = "%int32_mul"

module Ops = struct
  external ( +~ ) : int32 -> int32 -> int32 = "%int32_add"
  external ( <<~ ) : int32 -> int -> int32 = "%int32_lsl"
  external ( >>>~ ) : int32 -> int -> int32 = "%int32_lsr"
  external ( >>~ ) : int32 -> int -> int32 = "%int32_asr"
  external ( &~ ) : int32 -> int32 -> int32 = "%int32_and"
  external ( ^~ ) : int32 -> int32 -> int32 = "%int32_xor"
  external ( |~ ) : int32 -> int32 -> int32 = "%int32_or"
  external ( *~ ) : int32 -> int32 -> int32 = "%int32_mul"
end
