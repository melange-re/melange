(* Copyright (C) 2024- Authors of Melange
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

(* Bigstring (Bigarray char) multi-byte load/set operations.
   Uses DataView on the underlying TypedArray buffer for endian-aware access.
   The bigarray representation is { kind, layout, dims, data: Uint8Array }.
   All operations are little-endian (matching OCaml's convention on x86). *)

(* 16-bit load/set *)
let caml_bigstring_get16 : 'a -> int -> int =
  [%raw {|function(ba, i) {
    if (i < 0 || i + 1 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    return dv.getInt16(i, true);
  }|}]

let caml_bigstring_get16u : 'a -> int -> int =
  [%raw {|function(ba, i) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    return dv.getInt16(i, true);
  }|}]

let caml_bigstring_set16 : 'a -> int -> int -> unit =
  [%raw {|function(ba, i, v) {
    if (i < 0 || i + 1 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt16(i, v, true);
  }|}]

let caml_bigstring_set16u : 'a -> int -> int -> unit =
  [%raw {|function(ba, i, v) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt16(i, v, true);
  }|}]

(* 32-bit load/set *)
let caml_bigstring_get32 : 'a -> int -> int32 =
  [%raw {|function(ba, i) {
    if (i < 0 || i + 3 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    return dv.getInt32(i, true);
  }|}]

let caml_bigstring_get32u : 'a -> int -> int32 =
  [%raw {|function(ba, i) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    return dv.getInt32(i, true);
  }|}]

let caml_bigstring_set32 : 'a -> int -> int32 -> unit =
  [%raw {|function(ba, i, v) {
    if (i < 0 || i + 3 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt32(i, v, true);
  }|}]

let caml_bigstring_set32u : 'a -> int -> int32 -> unit =
  [%raw {|function(ba, i, v) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt32(i, v, true);
  }|}]

(* 64-bit load/set — returns/takes Melange int64 = [lo, hi] *)
let caml_bigstring_get64 : 'a -> int -> 'b =
  [%raw {|function(ba, i) {
    if (i < 0 || i + 7 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    var lo = dv.getInt32(i, true);
    var hi = dv.getInt32(i + 4, true);
    return [lo, hi];
  }|}]

let caml_bigstring_get64u : 'a -> int -> 'b =
  [%raw {|function(ba, i) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    var lo = dv.getInt32(i, true);
    var hi = dv.getInt32(i + 4, true);
    return [lo, hi];
  }|}]

let caml_bigstring_set64 : 'a -> int -> 'b -> unit =
  [%raw {|function(ba, i, v) {
    if (i < 0 || i + 7 >= ba.dims[0])
      throw [0, -3, "index out of bounds"];
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt32(i, v[0], true);
    dv.setInt32(i + 4, v[1], true);
  }|}]

let caml_bigstring_set64u : 'a -> int -> 'b -> unit =
  [%raw {|function(ba, i, v) {
    var dv = new DataView(ba.data.buffer, ba.data.byteOffset, ba.data.byteLength);
    dv.setInt32(i, v[0], true);
    dv.setInt32(i + 4, v[1], true);
  }|}]

(* Blit operations *)
let caml_bigstring_blit_ba_to_bytes : 'a -> int -> bytes -> int -> int -> unit =
  [%raw {|function(ba, ba_off, bytes, bytes_off, len) {
    for (var i = 0; i < len; i++) {
      bytes[bytes_off + i] = ba.data[ba_off + i];
    }
  }|}]

let caml_bigstring_blit_bytes_to_ba : bytes -> int -> 'a -> int -> int -> unit =
  [%raw {|function(bytes, bytes_off, ba, ba_off, len) {
    for (var i = 0; i < len; i++) {
      ba.data[ba_off + i] = bytes[bytes_off + i];
    }
  }|}]

let caml_bigstring_blit_ba_to_ba : 'a -> int -> 'a -> int -> int -> unit =
  [%raw {|function(src, src_off, dst, dst_off, len) {
    if (src.data === dst.data && dst_off > src_off) {
      for (var i = len - 1; i >= 0; i--) {
        dst.data[dst_off + i] = src.data[src_off + i];
      }
    } else {
      for (var i = 0; i < len; i++) {
        dst.data[dst_off + i] = src.data[src_off + i];
      }
    }
  }|}]
