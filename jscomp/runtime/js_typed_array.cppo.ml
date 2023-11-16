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

(** JavaScript Typed Array API

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray> MDN
*)

type array_buffer
type 'a array_like (* should be shared with js_array *)

module ArrayBuffer = struct
  (** The underlying buffer that the typed arrays provide views of

    @see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer> MDN
  *)

  type t = array_buffer

  external make : int -> t = "ArrayBuffer" [@@mel.new]
  (** takes length. initializes elements to 0 *)

  (* ArrayBuffer.isView: seems pointless with a type system *)
  (* experimental
  external transfer : array_buffer -> t = "ArrayBuffer.transfer"
  external transferWithLength : array_buffer -> int -> t = "ArrayBuffer.transfer"
  *)

  external byteLength : t -> int = "byteLength" [@@mel.get]

  external slice : t -> ?start:int -> ?end_:int -> unit -> array_buffer = "slice" [@@mel.send]
end

open struct
  module Js = Js_internal
end

#define COMMON_EXTERNALS(moduleName, eltType)\
  (** *)\
  type elt = eltType\
  type 'a typed_array\
  type t = elt typed_array\
  \
  external unsafe_get : t -> int -> elt  = "" [@@mel.get_index]\
  external unsafe_set : t -> int -> elt -> unit = "" [@@mel.set_index]\
  \
  external buffer : t -> array_buffer = "buffer" [@@mel.get]\
  external byteLength : t -> int = "byteLength" [@@mel.get]\
  external byteOffset : t -> int = "byteOffset" [@@mel.get]\
  \
  external setArray : t -> elt array -> unit = "set" [@@mel.send]\
  external setArrayOffset : t -> elt array -> int -> unit = "set" [@@mel.send]\
  (* There's also an overload for typed arrays, but don't know how to model that without subtyping *)\
  \
  (* Array interface(-ish) *)\
  external length : t -> int = "length" [@@mel.get]\
  \
  (* Mutator functions *)\
  external copyWithin : t -> to_:int -> ?start:int -> ?end_:int -> unit -> t = "copyWithin" [@@mel.send]\
  \
  external fill : t -> elt -> ?start:int -> ?end_:int -> unit -> t = "fill" [@@mel.send]\
  \
  external reverseInPlace : t -> t = "reverse" [@@mel.send]\
  \
  external sortInPlace : t -> t = "sort" [@@mel.send]\
  external sortInPlaceWith : t -> f:(elt -> elt -> int [@u]) -> t = "sort" [@@mel.send]\
  \
  (* Accessor functions *)\
  external includes : t -> value:elt -> bool = "includes" [@@mel.send] (* ES2016 *)\
  \
  external indexOf : t -> value:elt -> ?start:int -> unit -> int = "indexOf" [@@mel.send]\
  \
  external join : t -> ?sep:string -> unit -> string = "join" [@@mel.send]\
  \
  external lastIndexOf : t -> value:elt -> int = "lastIndexOf" [@@mel.send]\
  external lastIndexOfFrom : t -> value:elt -> from:int -> int = "lastIndexOf" [@@mel.send]\
  \
  external slice : t -> ?start:int -> ?end_:int -> unit -> t = "slice" [@@mel.send]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external copy : t -> t = "slice" [@@mel.send]\
  \
  external subarray : t -> start:int -> ?end_:int -> unit -> t = "subarray" [@@mel.send]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external toString : t -> string = "toString" [@@mel.send]\
  external toLocaleString : t -> string = "toLocaleString" [@@mel.send]\
  \
  (* Iteration functions *)\
  (* commented out until bs has a plan for iterators
  external entries : t -> (int * elt) array_iter = "" [@@mel.send]
  *)\
  external every : t -> f:(elt  -> bool [@u]) -> bool = "every" [@@mel.send]\
  external everyi : t -> f:(elt -> int -> bool [@u]) -> bool = "every" [@@mel.send]\
  \
  \
  external filter : t -> f:(elt -> bool [@u]) -> t = "filter" [@@mel.send]\
  external filteri : t -> f:(elt -> int  -> bool [@u]) -> t = "filter" [@@mel.send]\
  \
  external find : t -> f:(elt -> bool [@u]) -> elt Js_internal.undefined = "find" [@@mel.send]\
  external findi : t -> f:(elt -> int -> bool [@u]) -> elt Js_internal.undefined  = "find" [@@mel.send]\
  \
  external findIndex : t -> f:(elt -> bool [@u]) -> int = "findIndex" [@@mel.send]\
  external findIndexi : t -> f:(elt -> int -> bool [@u]) -> int = "findIndex" [@@mel.send]\
  \
  external forEach : t -> f:(elt -> unit [@u]) -> unit = "forEach" [@@mel.send]\
  external forEachi : t -> f:(elt -> int -> unit [@u]) -> unit  = "forEach" [@@mel.send]\
  \
  (* commented out until bs has a plan for iterators
  external keys : t -> int array_iter = "" [@@mel.send]
  *)\
  \
  external map : t -> f:(elt  -> 'b [@u]) -> 'b typed_array = "map" [@@mel.send]\
  external mapi : t -> f:(elt -> int ->  'b [@u]) -> 'b typed_array = "map" [@@mel.send]\
  \
  external reduce : t ->  f:('b -> elt  -> 'b [@u]) -> init:'b -> 'b = "reduce" [@@mel.send]\
  external reducei : t -> f:('b -> elt -> int -> 'b [@u]) -> init:'b -> 'b = "reduce" [@@mel.send]\
  \
  external reduceRight : t ->  f:('b -> elt  -> 'b [@u]) -> init:'b -> 'b = "reduceRight" [@@mel.send]\
  external reduceRighti : t -> f:('b -> elt -> int -> 'b [@u]) -> init:'b -> 'b = "reduceRight" [@@mel.send]\
  \
  external some : t -> f:(elt  -> bool [@u]) -> bool = "some" [@@mel.send]\
  external somei : t -> f:(elt  -> int -> bool [@u]) -> bool = "some" [@@mel.send]\
  \
  external _BYTES_PER_ELEMENT: int = STRINGIFY(moduleName.BYTES_PER_ELEMENT) \
  \
  external make : elt array -> t = STRINGIFY(moduleName) [@@mel.new]\
  external fromBuffer : array_buffer -> ?off:int -> ?len:int -> unit -> t = STRINGIFY(moduleName) [@@mel.new]\
  (** @raise Js.Exn.Error raises Js exception
      @param offset is in bytes, length in elements *)\
  \
  external fromLength : int -> t = STRINGIFY(moduleName) [@@mel.new]\
  external from : elt array_like -> t = STRINGIFY(moduleName.from) \
  (* *Array.of is redundant, use make *)

  (* commented out until bs has a plan for iterators
  external values : t -> elt array_iter = "" [@@mel.send]
  *)

module Int8Array = struct
  COMMON_EXTERNALS(Int8Array,int)
end


module Uint8Array = struct
  COMMON_EXTERNALS(Uint8Array,int)
end

module Uint8ClampedArray = struct
  COMMON_EXTERNALS(Uint8ClampedArray,int)
end

module Int16Array = struct
  COMMON_EXTERNALS(Int16Array,int)
end

module Uint16Array = struct
  COMMON_EXTERNALS(Uint16Array,int)
end

module Int32Array = struct
  COMMON_EXTERNALS(Int32Array,int32)
end

module Uint32Array = struct
  COMMON_EXTERNALS(Uint32Array,int)
end

(*
 it still return number, [float] in this case
*)
module Float32Array = struct
  COMMON_EXTERNALS(Float32Array,float)
end

module Float64Array = struct
  COMMON_EXTERNALS(Float64Array,float)
end


(** The DataView view provides a low-level interface for reading and writing
      multiple number types in an ArrayBuffer irrespective of the platform's endianness.

    @see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView> MDN
*)
module DataView = struct


  type t

  external make : array_buffer -> t = "DataView" [@@mel.new]
  external fromBuffer : array_buffer -> ?off:int -> ?len:int -> unit -> t = "DataView" [@@mel.new]

  external buffer : t -> array_buffer = "buffer" [@@mel.get]
  external byteLength : t -> int = "byteLength" [@@mel.get]
  external byteOffset : t -> int = "byteOffset" [@@mel.get]

  external getInt8 : t -> int -> int = "getInt8" [@@mel.send]
  external getUint8 : t -> int -> int = "getUint8" [@@mel.send]

  external getInt16: t -> int -> int = "getInt16" [@@mel.send]
  external getInt16LittleEndian : t -> int -> (_ [@mel.as 1]) -> int =
    "getInt16" [@@mel.send]

  external getUint16: t -> int -> int = "getUint16" [@@mel.send]
  external getUint16LittleEndian : t -> int -> (_ [@mel.as 1]) -> int =
    "getUint16" [@@mel.send]

  external getInt32: t -> int -> int = "getInt32" [@@mel.send]
  external getInt32LittleEndian : t -> int -> (_ [@mel.as 1]) -> int =
    "getInt32" [@@mel.send]

  external getUint32: t -> int -> int = "getUint32" [@@mel.send]
  external getUint32LittleEndian : t -> int -> (_ [@mel.as 1]) -> int =
    "getUint32" [@@mel.send]

  external getFloat32: t -> int -> float = "getFloat32" [@@mel.send]
  external getFloat32LittleEndian : t -> int -> (_ [@mel.as 1]) -> float =
    "getFloat32" [@@mel.send]

  external getFloat64: t -> int -> float = "getFloat64" [@@mel.send]
  external getFloat64LittleEndian : t -> int -> (_ [@mel.as 1]) -> float =
    "getFloat64" [@@mel.send]

  external setInt8 : t -> int -> int -> unit = "setInt8" [@@mel.send]
  external setUint8 : t -> int -> int -> unit = "setUint8" [@@mel.send]

  external setInt16: t -> int -> int -> unit = "setInt16" [@@mel.send]
  external setInt16LittleEndian : t -> int -> int -> (_ [@mel.as 1]) -> unit =
    "setInt16" [@@mel.send]

  external setUint16: t -> int -> int -> unit = "setUint16" [@@mel.send]
  external setUint16LittleEndian : t -> int -> int -> (_ [@mel.as 1]) -> unit =
    "setUint16" [@@mel.send]

  external setInt32: t -> int -> int -> unit = "setInt32" [@@mel.send]
  external setInt32LittleEndian : t -> int -> int -> (_ [@mel.as 1]) -> unit =
    "setInt32" [@@mel.send]

  external setUint32: t -> int -> int -> unit = "setUint32" [@@mel.send]
  external setUint32LittleEndian : t -> int -> int -> (_ [@mel.as 1]) -> unit =
    "setUint32" [@@mel.send]

  external setFloat32: t -> int -> float -> unit = "setFloat32" [@@mel.send]
  external setFloat32LittleEndian : t -> int -> float -> (_ [@mel.as 1]) -> unit =
    "setFloat32" [@@mel.send]

  external setFloat64: t -> int -> float -> unit = "setFloat64" [@@mel.send]
  external setFloat64LittleEndian : t -> int -> float -> (_ [@mel.as 1]) -> unit =
    "setFloat64" [@@mel.send]
end
