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

  external make : int -> t = "ArrayBuffer" [@@bs.new]
  (** takes length. initializes elements to 0 *)

  (* ArrayBuffer.isView: seems pointless with a type system *)
  (* experimental
  external transfer : array_buffer -> t = "ArrayBuffer.transfer" [@@bs.val]
  external transferWithLength : array_buffer -> int -> t = "ArrayBuffer.transfer" [@@bs.val]
  *)

  external byteLength : t -> int = "byteLength" [@@bs.get]

  external slice : t -> start:int -> end_:int -> array_buffer = "slice" [@@bs.send]
  external sliceFrom : t -> int -> array_buffer = "slice" [@@bs.send]
end

#define COMMON_EXTERNALS(moduleName, eltType)\
  (** *)\
  type elt = eltType\
  type 'a typed_array\
  type t = elt typed_array\
  \
  external unsafe_get : t -> int -> elt  = "" [@@bs.get_index]\
  external unsafe_set : t -> int -> elt -> unit = "" [@@bs.set_index]\
  \
  external buffer : t -> array_buffer = "buffer" [@@bs.get]\
  external byteLength : t -> int = "byteLength" [@@bs.get]\
  external byteOffset : t -> int = "byteOffset" [@@bs.get]\
  \
  external setArray : t -> elt array -> unit = "set" [@@bs.send]\
  external setArrayOffset : t -> elt array -> int -> unit = "set" [@@bs.send]\
  (* There's also an overload for typed arrays, but don't know how to model that without subtyping *)\
  \
  (* Array interface(-ish) *)\
  external length : t -> int = "length" [@@bs.get]\
  \
  (* Mutator functions *)\
  external copyWithin : t -> to_:int -> t = "copyWithin" [@@bs.send]\
  external copyWithinFrom : t -> to_:int -> from:int -> t = "copyWithin" [@@bs.send]\
  external copyWithinFromRange : t -> to_:int -> start:int -> end_:int -> t = "copyWithin" [@@bs.send]\
  \
  external fillInPlace : t -> elt -> t = "fill" [@@bs.send]\
  external fillFromInPlace : t -> elt -> from:int -> t = "fill" [@@bs.send]\
  external fillRangeInPlace : t -> elt -> start:int -> end_:int -> t = "fill" [@@bs.send]\
  \
  external reverseInPlace : t -> t = "reverse" [@@bs.send]\
  \
  external sortInPlace : t -> t = "sort" [@@bs.send]\
  external sortInPlaceWith : t -> (elt -> elt -> int [@bs]) -> t = "sort" [@@bs.send]\
  \
  (* Accessor functions *)\
  external includes : t -> elt -> bool = "includes" [@@bs.send] (* ES2016 *)\
  \
  external indexOf : t -> elt  -> int = "indexOf" [@@bs.send]\
  external indexOfFrom : t -> elt -> from:int -> int = "indexOf" [@@bs.send]\
  \
  external join : t -> string = "join" [@@bs.send]\
  external joinWith : t -> string -> string = "join" [@@bs.send]\
  \
  external lastIndexOf : t -> elt -> int = "lastIndexOf" [@@bs.send]\
  external lastIndexOfFrom : t -> elt -> from:int -> int = "lastIndexOf" [@@bs.send]\
  \
  external slice : t -> start:int -> end_:int -> t = "slice" [@@bs.send]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external copy : t -> t = "slice" [@@bs.send]\
  external sliceFrom : t -> int -> t = "slice" [@@bs.send]\
  \
  external subarray : t -> start:int -> end_:int -> t = "subarray" [@@bs.send]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external subarrayFrom : t -> int -> t = "subarray" [@@bs.send]\
  \
  external toString : t -> string = "toString" [@@bs.send]\
  external toLocaleString : t -> string = "toLocaleString" [@@bs.send]\
  \
  (* Iteration functions *)\
  (* commented out until bs has a plan for iterators
  external entries : t -> (int * elt) array_iter = "" [@@bs.send]
  *)\
  external every : t -> (elt  -> bool [@bs]) -> bool = "every" [@@bs.send]\
  external everyi : t -> (elt -> int -> bool [@bs]) -> bool = "every" [@@bs.send]\
  \
  \
  external filter : t -> (elt -> bool [@bs]) -> t = "filter" [@@bs.send]\
  external filteri : t -> (elt -> int  -> bool [@bs]) -> t = "filter" [@@bs.send]\
  \
  external find : t -> (elt -> bool [@bs]) -> elt Js.undefined = "find" [@@bs.send]\
  external findi : t -> (elt -> int -> bool [@bs]) -> elt Js.undefined  = "find" [@@bs.send]\
  \
  external findIndex : t -> (elt -> bool [@bs]) -> int = "findIndex" [@@bs.send]\
  external findIndexi : t -> (elt -> int -> bool [@bs]) -> int = "findIndex" [@@bs.send]\
  \
  external forEach : t -> (elt -> unit [@bs]) -> unit = "forEach" [@@bs.send]\
  external forEachi : t -> (elt -> int -> unit [@bs]) -> unit  = "forEach" [@@bs.send]\
  \
  (* commented out until bs has a plan for iterators
  external keys : t -> int array_iter = "" [@@bs.send]
  *)\
  \
  external map : t -> (elt  -> 'b [@bs]) -> 'b typed_array = "map" [@@bs.send]\
  external mapi : t -> (elt -> int ->  'b [@bs]) -> 'b typed_array = "map" [@@bs.send]\
  \
  external reduce : t ->  ('b -> elt  -> 'b [@bs]) -> 'b -> 'b = "reduce" [@@bs.send]\
  external reducei : t -> ('b -> elt -> int -> 'b [@bs]) -> 'b -> 'b = "reduce" [@@bs.send]\
  \
  external reduceRight : t ->  ('b -> elt  -> 'b [@bs]) -> 'b -> 'b = "reduceRight" [@@bs.send]\
  external reduceRighti : t -> ('b -> elt -> int -> 'b [@bs]) -> 'b -> 'b = "reduceRight" [@@bs.send]\
  \
  external some : t -> (elt  -> bool [@bs]) -> bool = "some" [@@bs.send]\
  external somei : t -> (elt  -> int -> bool [@bs]) -> bool = "some" [@@bs.send]\
  \
  external _BYTES_PER_ELEMENT: int = STRINGIFY(moduleName.BYTES_PER_ELEMENT) [@@bs.val]\
  \
  external make : elt array -> t = STRINGIFY(moduleName) [@@bs.new]\
  external fromBuffer : array_buffer -> t = STRINGIFY(moduleName) [@@bs.new]\
  (** can throw *)\
  \
  external fromBufferOffset : array_buffer -> int -> t = STRINGIFY(moduleName) [@@bs.new]\
  (** @raise Js.Exn.Error raise Js exception
      @param offset is in bytes *)\
  \
  external fromBufferRange : array_buffer -> offset:int -> length:int -> t = STRINGIFY(moduleName) [@@bs.new]\
  (** @raise Js.Exn.Error raises Js exception
      @param offset is in bytes, length in elements *)\
  \
  external fromLength : int -> t = STRINGIFY(moduleName) [@@bs.new]\
  external from : elt array_like -> t = STRINGIFY(moduleName.from) [@@bs.val]\
  (* *Array.of is redundant, use make *)

  (* commented out until bs has a plan for iterators
  external values : t -> elt array_iter = "" [@@bs.send]
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

  external make : array_buffer -> t = "DataView" [@@bs.new]
  external fromBuffer : array_buffer -> t = "DataView" [@@bs.new]
  external fromBufferOffset : array_buffer -> int -> t = "DataView" [@@bs.new]
  external fromBufferRange : array_buffer -> offset:int -> length:int -> t = "DataView" [@@bs.new]

  external buffer : t -> array_buffer = "buffer" [@@bs.get]
  external byteLength : t -> int = "byteLength" [@@bs.get]
  external byteOffset : t -> int = "byteOffset" [@@bs.get]

  external getInt8 : t -> int -> int = "getInt8" [@@bs.send]
  external getUint8 : t -> int -> int = "getUint8" [@@bs.send]

  external getInt16: t -> int -> int = "getInt16" [@@bs.send]
  external getInt16LittleEndian : t -> int -> (_ [@bs.as 1]) -> int =
    "getInt16" [@@bs.send]

  external getUint16: t -> int -> int = "getUint16" [@@bs.send]
  external getUint16LittleEndian : t -> int -> (_ [@bs.as 1]) -> int =
    "getUint16" [@@bs.send]

  external getInt32: t -> int -> int = "getInt32" [@@bs.send]
  external getInt32LittleEndian : t -> int -> (_ [@bs.as 1]) -> int =
    "getInt32" [@@bs.send]

  external getUint32: t -> int -> int = "getUint32" [@@bs.send]
  external getUint32LittleEndian : t -> int -> (_ [@bs.as 1]) -> int =
    "getUint32" [@@bs.send]

  external getFloat32: t -> int -> float = "getFloat32" [@@bs.send]
  external getFloat32LittleEndian : t -> int -> (_ [@bs.as 1]) -> float =
    "getFloat32" [@@bs.send]

  external getFloat64: t -> int -> float = "getFloat64" [@@bs.send]
  external getFloat64LittleEndian : t -> int -> (_ [@bs.as 1]) -> float =
    "getFloat64" [@@bs.send]

  external setInt8 : t -> int -> int -> unit = "setInt8" [@@bs.send]
  external setUint8 : t -> int -> int -> unit = "setUint8" [@@bs.send]

  external setInt16: t -> int -> int -> unit = "setInt16" [@@bs.send]
  external setInt16LittleEndian : t -> int -> int -> (_ [@bs.as 1]) -> unit =
    "setInt16" [@@bs.send]

  external setUint16: t -> int -> int -> unit = "setUint16" [@@bs.send]
  external setUint16LittleEndian : t -> int -> int -> (_ [@bs.as 1]) -> unit =
    "setUint16" [@@bs.send]

  external setInt32: t -> int -> int -> unit = "setInt32" [@@bs.send]
  external setInt32LittleEndian : t -> int -> int -> (_ [@bs.as 1]) -> unit =
    "setInt32" [@@bs.send]

  external setUint32: t -> int -> int -> unit = "setUint32" [@@bs.send]
  external setUint32LittleEndian : t -> int -> int -> (_ [@bs.as 1]) -> unit =
    "setUint32" [@@bs.send]

  external setFloat32: t -> int -> float -> unit = "setFloat32" [@@bs.send]
  external setFloat32LittleEndian : t -> int -> float -> (_ [@bs.as 1]) -> unit =
    "setFloat32" [@@bs.send]

  external setFloat64: t -> int -> float -> unit = "setFloat64" [@@bs.send]
  external setFloat64LittleEndian : t -> int -> float -> (_ [@bs.as 1]) -> unit =
    "setFloat64" [@@bs.send]
end
