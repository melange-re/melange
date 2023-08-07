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

type array_buffer = Js_typed_array2.array_buffer
type 'a array_like = 'a Js_typed_array2.array_like

module type Type = sig
  type t
end


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

  external slice : start:int -> end_:int -> array_buffer = "slice" [@@mel.send.pipe: t] (*FIXME*)
  external sliceFrom : int -> array_buffer = "slice" [@@mel.send.pipe: t]
end

open struct
  module Js = Js_internal
end

module type S =  sig
  (** Implements functionality common to all the typed arrays *)

  type elt
  type 'a typed_array
  type t = elt typed_array

  external unsafe_get : t -> int -> elt  = "" [@@mel.get_index]
  external unsafe_set : t -> int -> elt -> unit = "" [@@mel.set_index]

  external buffer : t -> array_buffer = "buffer" [@@mel.get]
  external byteLength : t -> int = "byteLength" [@@mel.get]
  external byteOffset : t -> int = "byteOffset" [@@mel.get]

  external setArray : elt array -> unit = "set" [@@mel.send.pipe: t]
  external setArrayOffset : elt array -> int -> unit = "set" [@@mel.send.pipe: t]
  (* There's also an overload for typed arrays, but don't know how to model that without subtyping *)

  (* Array interface(-ish)
  * ---
  *)
  external length : t -> int = "length" [@@mel.get]

  (* Mutator functions
  *)
  external copyWithin : to_:int -> t = "copyWithin" [@@mel.send.pipe: t]
  external copyWithinFrom : to_:int -> from:int -> t = "copyWithin" [@@mel.send.pipe: t]
  external copyWithinFromRange : to_:int -> start:int -> end_:int -> t = "copyWithin" [@@mel.send.pipe: t]

  external fillInPlace : elt -> t = "fill" [@@mel.send.pipe: t]
  external fillFromInPlace : elt -> from:int -> t = "fill" [@@mel.send.pipe: t]
  external fillRangeInPlace : elt -> start:int -> end_:int -> t = "fill" [@@mel.send.pipe: t]

  external reverseInPlace : t = "reverse" [@@mel.send.pipe: t]

  external sortInPlace : t = "sort" [@@mel.send.pipe: t]
  external sortInPlaceWith : (elt -> elt -> int [@u]) -> t = "sort" [@@mel.send.pipe: t]

  (* Accessor functions
  *)
  external includes : elt -> bool = "includes" [@@mel.send.pipe: t] (** ES2016 *)

  external indexOf : elt  -> int = "indexOf" [@@mel.send.pipe: t]
  external indexOfFrom : elt -> from:int -> int = "indexOf" [@@mel.send.pipe: t]

  external join : string = "join" [@@mel.send.pipe: t]
  external joinWith : string -> string = "join" [@@mel.send.pipe: t]

  external lastIndexOf : elt -> int = "lastIndexOf" [@@mel.send.pipe: t]
  external lastIndexOfFrom : elt -> from:int -> int = "lastIndexOf" [@@mel.send.pipe: t]

  external slice : start:int -> end_:int -> t = "slice" [@@mel.send.pipe: t]
  external copy : t = "slice" [@@mel.send.pipe: t]
  external sliceFrom : int -> t = "slice" [@@mel.send.pipe: t]

  external subarray : start:int -> end_:int -> t = "subarray" [@@mel.send.pipe: t]
  external subarrayFrom : int -> t = "subarray" [@@mel.send.pipe: t]

  external toString : string = "toString" [@@mel.send.pipe: t]
  external toLocaleString : string = "toLocaleString" [@@mel.send.pipe: t]


  (* Iteration functions
  *)
  (* commented out until bs has a plan for iterators
  external entries : (int * elt) array_iter = "" [@@mel.send.pipe: t]
  *)

  external every : (elt  -> bool [@u]) -> bool = "every" [@@mel.send.pipe: t]
  external everyi : (elt -> int -> bool [@u]) -> bool = "every" [@@mel.send.pipe: t]

  (** should we use [bool] or [boolean] seems they are intechangeable here *)
  external filter : (elt -> bool [@u]) -> t = "filter" [@@mel.send.pipe: t]
  external filteri : (elt -> int  -> bool [@u]) -> t = "filter" [@@mel.send.pipe: t]

  external find : (elt -> bool [@u]) -> elt Js_internal.undefined = "find" [@@mel.send.pipe: t]
  external findi : (elt -> int -> bool [@u]) -> elt Js_internal.undefined  = "find" [@@mel.send.pipe: t]

  external findIndex : (elt -> bool [@u]) -> int = "findIndex" [@@mel.send.pipe: t]
  external findIndexi : (elt -> int -> bool [@u]) -> int = "findIndex" [@@mel.send.pipe: t]

  external forEach : (elt -> unit [@u]) -> unit = "forEach" [@@mel.send.pipe: t]
  external forEachi : (elt -> int -> unit [@u]) -> unit  = "forEach" [@@mel.send.pipe: t]

  (* commented out until bs has a plan for iterators
  external keys : int array_iter = "" [@@mel.send.pipe: t]
  *)

  external map : (elt  -> 'b [@u]) -> 'b typed_array = "map" [@@mel.send.pipe: t]
  external mapi : (elt -> int ->  'b [@u]) -> 'b typed_array = "map" [@@mel.send.pipe: t]

  external reduce :  ('b -> elt  -> 'b [@u]) -> 'b -> 'b = "reduce" [@@mel.send.pipe: t]
  external reducei : ('b -> elt -> int -> 'b [@u]) -> 'b -> 'b = "reduce" [@@mel.send.pipe: t]

  external reduceRight :  ('b -> elt  -> 'b [@u]) -> 'b -> 'b = "reduceRight" [@@mel.send.pipe: t]
  external reduceRighti : ('b -> elt -> int -> 'b [@u]) -> 'b -> 'b = "reduceRight" [@@mel.send.pipe: t]

  external some : (elt  -> bool [@u]) -> bool = "some" [@@mel.send.pipe: t]
  external somei : (elt  -> int -> bool [@u]) -> bool = "some" [@@mel.send.pipe: t]

  (* commented out until bs has a plan for iterators
  external values : elt array_iter = "" [@@mel.send.pipe: t]
  *)
end

#define COMMON_EXTERNALS(moduleName, eltType)\
  (** *)\
  type elt = eltType\
  type 'a typed_array = 'a Js_typed_array2.moduleName.typed_array\
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
  external copyWithin : to_:int -> t = "copyWithin" [@@mel.send.pipe: t]\
  external copyWithinFrom : to_:int -> from:int -> t = "copyWithin" [@@mel.send.pipe: t]\
  external copyWithinFromRange : to_:int -> start:int -> end_:int -> t = "copyWithin" [@@mel.send.pipe: t]\
  \
  external fillInPlace : elt -> t = "fill" [@@mel.send.pipe: t]\
  external fillFromInPlace : elt -> from:int -> t = "fill" [@@mel.send.pipe: t]\
  external fillRangeInPlace : elt -> start:int -> end_:int -> t = "fill" [@@mel.send.pipe: t]\
  \
  external reverseInPlace : t = "reverse" [@@mel.send.pipe: t]\
  \
  external sortInPlace : t = "sort" [@@mel.send.pipe: t]\
  external sortInPlaceWith : (elt -> elt -> int [@u]) -> t = "sort" [@@mel.send.pipe: t]\
  \
  (* Accessor functions *)\
  external includes : elt -> bool = "includes" [@@mel.send.pipe: t] (* ES2016 *)\
  \
  external indexOf : elt  -> int = "indexOf" [@@mel.send.pipe: t]\
  external indexOfFrom : elt -> from:int -> int = "indexOf" [@@mel.send.pipe: t]\
  \
  external join : string = "join" [@@mel.send.pipe: t]\
  external joinWith : string -> string = "join" [@@mel.send.pipe: t]\
  \
  external lastIndexOf : elt -> int = "lastIndexOf" [@@mel.send.pipe: t]\
  external lastIndexOfFrom : elt -> from:int -> int = "lastIndexOf" [@@mel.send.pipe: t]\
  \
  external slice : start:int -> end_:int -> t = "slice" [@@mel.send.pipe: t]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external copy : t = "slice" [@@mel.send.pipe: t]\
  external sliceFrom : int -> t = "slice" [@@mel.send.pipe: t]\
  \
  external subarray : start:int -> end_:int -> t = "subarray" [@@mel.send.pipe: t]\
  (** [start] is inclusive, [end_] exclusive *)\
  \
  external subarrayFrom : int -> t = "subarray" [@@mel.send.pipe: t]\
  \
  external toString : string = "toString" [@@mel.send.pipe: t]\
  external toLocaleString : string = "toLocaleString" [@@mel.send.pipe: t]\
  \
  (* Iteration functions *)\
  (* commented out until bs has a plan for iterators
  external entries : (int * elt) array_iter = "" [@@mel.send.pipe: t]
  *)\
  external every : (elt  -> bool [@u]) -> bool = "every" [@@mel.send.pipe: t]\
  external everyi : (elt -> int -> bool [@u]) -> bool = "every" [@@mel.send.pipe: t]\
  \
  \
  external filter : (elt -> bool [@u]) -> t = "filter" [@@mel.send.pipe: t]\
  external filteri : (elt -> int  -> bool [@u]) -> t = "filter" [@@mel.send.pipe: t]\
  \
  external find : (elt -> bool [@u]) -> elt Js_internal.undefined = "find" [@@mel.send.pipe: t]\
  external findi : (elt -> int -> bool [@u]) -> elt Js_internal.undefined  = "find" [@@mel.send.pipe: t]\
  \
  external findIndex : (elt -> bool [@u]) -> int = "findIndex" [@@mel.send.pipe: t]\
  external findIndexi : (elt -> int -> bool [@u]) -> int = "findIndex" [@@mel.send.pipe: t]\
  \
  external forEach : (elt -> unit [@u]) -> unit = "forEach" [@@mel.send.pipe: t]\
  external forEachi : (elt -> int -> unit [@u]) -> unit  = "forEach" [@@mel.send.pipe: t]\
  \
  (* commented out until bs has a plan for iterators
  external keys : int array_iter = "" [@@mel.send.pipe: t]
  *)\
  \
  external map : (elt  -> 'b [@u]) -> 'b typed_array = "map" [@@mel.send.pipe: t]\
  external mapi : (elt -> int ->  'b [@u]) -> 'b typed_array = "map" [@@mel.send.pipe: t]\
  \
  external reduce :  ('b -> elt  -> 'b [@u]) -> 'b -> 'b = "reduce" [@@mel.send.pipe: t]\
  external reducei : ('b -> elt -> int -> 'b [@u]) -> 'b -> 'b = "reduce" [@@mel.send.pipe: t]\
  \
  external reduceRight :  ('b -> elt  -> 'b [@u]) -> 'b -> 'b = "reduceRight" [@@mel.send.pipe: t]\
  external reduceRighti : ('b -> elt -> int -> 'b [@u]) -> 'b -> 'b = "reduceRight" [@@mel.send.pipe: t]\
  \
  external some : (elt  -> bool [@u]) -> bool = "some" [@@mel.send.pipe: t]\
  external somei : (elt  -> int -> bool [@u]) -> bool = "some" [@@mel.send.pipe: t]\
  \
  external _BYTES_PER_ELEMENT: int = STRINGIFY(moduleName.BYTES_PER_ELEMENT) \
  \
  external make : elt array -> t = STRINGIFY(moduleName) [@@mel.new]\
  external fromBuffer : array_buffer -> t = STRINGIFY(moduleName) [@@mel.new]\
  (** can throw *)\
  \
  external fromBufferOffset : array_buffer -> int -> t = STRINGIFY(moduleName) [@@mel.new]\
  (** @raise Js.Exn.Error raise Js exception
      @param offset is in bytes *)\
  \
  external fromBufferRange : array_buffer -> offset:int -> length:int -> t = STRINGIFY(moduleName) [@@mel.new]\
  (** @raise Js.Exn.Error raises Js exception
      @param offset is in bytes, length in elements *)\
  \
  external fromLength : int -> t = STRINGIFY(moduleName) [@@mel.new]\
  external from : elt array_like -> t = STRINGIFY(moduleName.from) \
  (* *Array.of is redundant, use make *)

  (* commented out until bs has a plan for iterators
  external values : elt array_iter = "" [@@mel.send.pipe: t]
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

  external create : int32 array -> t = "Int32Array" [@@mel.new]
  [@@deprecated "use `make` instead"]
  external of_buffer : array_buffer -> t = "Int32Array" [@@mel.new]
  [@@deprecated "use `fromBuffer` instead"]
end
module Int32_array = Int32Array
[@deprecated "use `Int32Array` instead"]


module Uint32Array = struct
  COMMON_EXTERNALS(Uint32Array,int)
end


(*
 it still return number, [float] in this case
*)
module Float32Array = struct
  COMMON_EXTERNALS(Float32Array,float)

  external create : float array -> t = "Float32Array" [@@mel.new]
  [@@deprecated "use `make` instead"]
  external of_buffer : array_buffer -> t = "Float32Array" [@@mel.new]
  [@@deprecated "use `fromBuffer` instead"]
end
module Float32_array = Float32Array
[@deprecated "use `Float32Array` instead"]


module Float64Array = struct
  COMMON_EXTERNALS(Float64Array,float)

  external create : float array -> t = "Float64Array" [@@mel.new]
  [@@deprecated "use `make` instead"]
  external of_buffer : array_buffer -> t = "Float64Array" [@@mel.new]
  [@@deprecated "use `fromBuffer` instead"]
end
module Float64_array = Float64Array
[@deprecated "use `Float64Array` instead"]


(** The DataView view provides a low-level interface for reading and writing
    multiple number types in an ArrayBuffer irrespective of the platform's endianness.

    @see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView> MDN
*)
module DataView = struct

  type t = Js_typed_array2.DataView.t

  external make : array_buffer -> t = "DataView" [@@mel.new]
  external fromBuffer : array_buffer -> t = "DataView" [@@mel.new]
  external fromBufferOffset : array_buffer -> int -> t = "DataView" [@@mel.new]
  external fromBufferRange : array_buffer -> offset:int -> length:int -> t = "DataView" [@@mel.new]

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
