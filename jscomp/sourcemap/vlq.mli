(**
 * Copyright (c) 2018-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

exception Unexpected_eof
exception Invalid_base64 of char

module Stream : sig
  type t
  exception Failure
  val of_string : string -> t
  val peek : t -> char option
  val junk : t -> unit
  val next : t -> char
end

module type S = sig
  val encode: Buffer.t -> int -> unit
  val decode: Stream.t -> int
end

module Base64 : S
