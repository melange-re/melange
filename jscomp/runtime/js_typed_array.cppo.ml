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

  external slice : ?start:int -> ?end_:int  -> array_buffer = "slice"
  [@@mel.send.pipe: t]
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
  external setArray : elt array -> unit = "set" [@@mel.send.pipe: t]\
  external setArrayOffset : elt array -> int -> unit = "set" [@@mel.send.pipe: t]\
  (* There's also an overload for typed arrays, but don't know how to model that without subtyping *)\
  \
  (* Array interface(-ish) *)\
  external length : t -> int = "length" [@@mel.get]\
  \
  (* Mutator functions *)\
  external copyWithin : to_:int -> ?start:int -> ?end_:int -> t = "copyWithin" [@@mel.send.pipe: t]\
  \
  external fill : elt -> ?start:int -> ?end_:int -> t = "fill" [@@mel.send.pipe: t]\
  \
  external reverseInPlace : t -> t = "reverse" [@@mel.send]\
  \
  external sortInPlace : t -> t = "sort" [@@mel.send]\
  external sortInPlaceWith : f:(elt -> elt -> int [@mel.uncurry]) -> t = "sort" [@@mel.send.pipe: t]\
  \
  (* Accessor functions *)\
  external includes : value:elt -> bool = "includes" [@@mel.send.pipe: t] (* ES2016 *)\
  \
  external indexOf : value:elt -> ?start:int -> int = "indexOf" [@@mel.send.pipe: t]\
  \
  external join : ?sep:string -> string = "join" [@@mel.send.pipe: t]\
  \
  external lastIndexOf : value:elt -> int = "lastIndexOf" [@@mel.send.pipe: t]\
  external lastIndexOfFrom : value:elt -> from:int -> int = "lastIndexOf" [@@mel.send.pipe: t]\
  \
  external slice : ?start:int -> ?end_:int -> t = "slice" [@@mel.send.pipe: t]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external copy : t -> t = "slice" [@@mel.send]\
  \
  external subarray : ?start:int -> ?end_:int -> t = "subarray" [@@mel.send.pipe: t]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external toString : t -> string = "toString" [@@mel.send]\
  external toLocaleString : t -> string = "toLocaleString" [@@mel.send]\
  \
  (* Iteration functions *)\
  (* commented out until bs has a plan for iterators
  external entries : t -> (int * elt) array_iter = "" [@@mel.send]
  *)\
  external every : f:(elt  -> bool [@mel.uncurry]) -> bool = "every" [@@mel.send.pipe: t]\
  external everyi : f:(elt -> int -> bool [@mel.uncurry]) -> bool = "every" [@@mel.send.pipe: t]\
  \
  \
  external filter : f:(elt -> bool [@mel.uncurry]) -> t = "filter" [@@mel.send.pipe: t]\
  external filteri : f:(elt -> int  -> bool [@mel.uncurry]) -> t = "filter" [@@mel.send.pipe: t]\
  \
  external find : f:(elt -> bool [@mel.uncurry]) -> elt Js_internal.undefined = "find" [@@mel.send.pipe: t]\
  external findi : f:(elt -> int -> bool [@mel.uncurry]) -> elt Js_internal.undefined  = "find" [@@mel.send.pipe: t]\
  \
  external findIndex : f:(elt -> bool [@mel.uncurry]) -> int = "findIndex" [@@mel.send.pipe: t]\
  external findIndexi : f:(elt -> int -> bool [@mel.uncurry]) -> int = "findIndex" [@@mel.send.pipe: t]\
  \
  external forEach : f:(elt -> unit [@mel.uncurry]) -> unit = "forEach" [@@mel.send.pipe: t]\
  external forEachi : f:(elt -> int -> unit [@mel.uncurry]) -> unit  = "forEach" [@@mel.send.pipe: t]\
  \
  (* commented out until bs has a plan for iterators
  external keys : t -> int array_iter = "" [@@mel.send]
  *)\
  \
  external map : f:(elt  -> 'b [@mel.uncurry]) -> 'b typed_array = "map" [@@mel.send.pipe: t]\
  external mapi : f:(elt -> int ->  'b [@mel.uncurry]) -> 'b typed_array = "map" [@@mel.send.pipe: t]\
  \
  external reduce : f:('b -> elt  -> 'b [@mel.uncurry]) -> init:'b -> 'b = "reduce" [@@mel.send.pipe: t]\
  external reducei : f:('b -> elt -> int -> 'b [@mel.uncurry]) -> init:'b -> 'b = "reduce" [@@mel.send.pipe: t]\
  \
  external reduceRight : f:('b -> elt  -> 'b [@mel.uncurry]) -> init:'b -> 'b = "reduceRight" [@@mel.send.pipe: t]\
  external reduceRighti : f:('b -> elt -> int -> 'b [@mel.uncurry]) -> init:'b -> 'b = "reduceRight" [@@mel.send.pipe: t]\
  \
  external some : f:(elt  -> bool [@mel.uncurry]) -> bool = "some" [@@mel.send.pipe: t]\
  external somei : f:(elt  -> int -> bool [@mel.uncurry]) -> bool = "some" [@@mel.send.pipe: t]\
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

  external getInt8 : int -> int = "getInt8" [@@mel.send.pipe: t]
  external getUint8 : int -> int = "getUint8" [@@mel.send.pipe: t]

  external getInt16: int -> int = "getInt16" [@@mel.send.pipe: t]
  external getInt16LittleEndian : int -> (_ [@mel.as 1]) -> int = "getInt16"
  [@@mel.send.pipe: t]

  external getUint16: int -> int = "getUint16" [@@mel.send.pipe: t]
  external getUint16LittleEndian : int -> (_ [@mel.as 1]) -> int =
    "getUint16" [@@mel.send.pipe: t]

  external getInt32: int -> int = "getInt32" [@@mel.send.pipe: t]
  external getInt32LittleEndian : int -> (_ [@mel.as 1]) -> int =
    "getInt32" [@@mel.send.pipe: t]

  external getUint32: int -> int = "getUint32" [@@mel.send.pipe: t]
  external getUint32LittleEndian : int -> (_ [@mel.as 1]) -> int =
    "getUint32" [@@mel.send.pipe: t]

  external getFloat32: int -> float = "getFloat32" [@@mel.send.pipe: t]
  external getFloat32LittleEndian : int -> (_ [@mel.as 1]) -> float =
    "getFloat32" [@@mel.send.pipe: t]

  external getFloat64: int -> float = "getFloat64" [@@mel.send.pipe: t]
  external getFloat64LittleEndian : int -> (_ [@mel.as 1]) -> float =
    "getFloat64" [@@mel.send.pipe: t]

  external setInt8 : int -> int -> unit = "setInt8" [@@mel.send.pipe: t]
  external setUint8 : int -> int -> unit = "setUint8" [@@mel.send.pipe: t]

  external setInt16: int -> int -> unit = "setInt16" [@@mel.send.pipe: t]
  external setInt16LittleEndian : int -> int -> (_ [@mel.as 1]) -> unit =
    "setInt16" [@@mel.send.pipe: t]

  external setUint16: int -> int -> unit = "setUint16" [@@mel.send.pipe: t]
  external setUint16LittleEndian : int -> int -> (_ [@mel.as 1]) -> unit =
    "setUint16" [@@mel.send.pipe: t]

  external setInt32: int -> int -> unit = "setInt32" [@@mel.send.pipe: t]
  external setInt32LittleEndian : int -> int -> (_ [@mel.as 1]) -> unit =
    "setInt32" [@@mel.send.pipe: t]

  external setUint32: int -> int -> unit = "setUint32" [@@mel.send.pipe: t]
  external setUint32LittleEndian : int -> int -> (_ [@mel.as 1]) -> unit =
    "setUint32" [@@mel.send.pipe: t]

  external setFloat32: int -> float -> unit = "setFloat32" [@@mel.send.pipe: t]
  external setFloat32LittleEndian : int -> float -> (_ [@mel.as 1]) -> unit =
    "setFloat32" [@@mel.send.pipe: t]

  external setFloat64: int -> float -> unit = "setFloat64" [@@mel.send.pipe: t]
  external setFloat64LittleEndian : int -> float -> (_ [@mel.as 1]) -> unit =
    "setFloat64" [@@mel.send.pipe: t]
end
