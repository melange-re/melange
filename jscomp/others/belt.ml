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

(** A stdlib shipped with Melange

    This stdlib is still in {i beta} but we encourage you to try it out and
    give us feedback.

    {b Motivation }

    The motivation for creating such library is to provide Melange users a
    better end-to-end user experience, since the original OCaml stdlib was not
    written with JS in mind. Below is a list of areas this lib aims to
    improve:
    {ol
    {- Consistency in name convention: camlCase, and arguments order}
    {- Exception thrown functions are all suffixed with {i Exn}, e.g, {i getExn}}
    {- Better performance and smaller code size running on JS platform}
    }

    {b Name Convention}

    For higher order functions, it will be suffixed {b U} if it takes uncurried
    callback.

    {[
      val forEach  : 'a t -> ('a -> unit) -> unit
      val forEachU : 'a t -> ('a -> unit [\@u]) -> unit
    ]}

    In general, uncurried version will be faster, but it may be less familiar to
    people who have a background in functional programming.

   {b A special encoding for collection safety}

   When we create a collection library for a custom data type we need a way to provide a comparator
   function. Take {i Set} for example, suppose its element type is a pair of ints,
    it needs a custom {i compare} function that takes two tuples and returns their order.
    The {i Set} could not just be typed as [ Set.t (int * int) ], its customized {i compare} function
    needs to manifest itself in the signature, otherwise, if the user creates another
    customized {i compare} function, the two collection could mix which would result in runtime error.

    The original OCaml stdlib solved the problem using {i functor} which creates a big
    closure at runtime and makes dead code elimination much harder.
    We use a phantom type to solve the problem:

    {[
      module Comparable1 = Belt.Id.MakeComparable(struct
        type t = int * int
        let cmp (a0, a1) (b0, b1) =
          match Pervasives.compare a0 b0 with
          | 0 -> Pervasives.compare a1 b1
          | c -> c
      end)

    let mySet1 = Belt.Set.make ~id:(module Comparable1)

    module Comparable2 = Belt.Id.MakeComparable(struct
      type t = int * int
      let cmp (a0, a1) (b0, b1) =
        match Pervasives.compare a0 b0 with
        | 0 -> Pervasives.compare a1 b1
        | c -> c
    end)

    let mySet2 = Belt.Set.make ~id:(module Comparable2)
    ]}

    Here, the compiler would infer [mySet1] and [mySet2] having different type, so
    e.g. a `merge` operation that tries to merge these two sets will correctly fail.

    {[
      val mySet1 : ((int * int), Comparable1.identity) t
      val mySet2 : ((int * int), Comparable2.identity) t
    ]}

    [Comparable1.identity] and [Comparable2.identity] are not the same using our encoding scheme.

    {b Collection Hierarchy}

    In general, we provide a generic collection module, but also create specialized
    modules for commonly used data type. Take {i Belt.Set} for example, we provide:

    {[
        Belt.Set
        Belt.Set.Int
        Belt.Set.String
    ]}

    The specialized modules {i Belt.Set.Int}, {i Belt.Set.String} are in general more
    efficient.

    Currently, both {i Belt_Set} and {i Belt.Set} are accessible to users for some
    technical reasons,
    we {b strongly recommend} users stick to qualified import, {i Belt.Set}, we may hide
    the internal, {i i.e}, {i Belt_Set} in the future

*)

module Id = Belt_Id
(** {!Belt.Id}

    Provide utilities to create identified comparators or hashes for
    data structures used below.

    It create a unique identifier per module of
    functions so that different data structures with slightly different
    comparison functions won't mix
*)

module Array = Belt_Array
(** {!Belt.Array}

    {b mutable array}: Utilities functions
*)

module SortArray = Belt_SortArray
(** {!Belt.SortArray}

    The top level provides some generic sort related utilities.

    It also has two specialized inner modules
    {!Belt.SortArray.Int} and {!Belt.SortArray.String}
*)

module MutableQueue = Belt_MutableQueue
(** {!Belt.MutableQueue}

    An FIFO(first in first out) queue data structure
*)

module MutableStack = Belt_MutableStack
(** {!Belt.MutableStack}

    An FILO(first in last out) stack data structure
*)

module List = Belt_List
(** {!Belt.List}

    Utilities for List data type
*)

module Range = Belt_Range
(** {!Belt.Range}

    Utilities for a closed range [(from, start)]
*)

module Set = Belt_Set
(** {!Belt.Set}

    The top level provides generic {b immutable} set operations.

    It also has three specialized inner modules
    {!Belt.Set.Int}, {!Belt.Set.String} and

    {!Belt.Set.Dict}: This module separates data from function
    which is more verbose but slightly more efficient

*)

module Map = Belt_Map
(** {!Belt.Map},

    The top level provides generic {b immutable} map operations.

    It also has three specialized inner modules
    {!Belt.Map.Int}, {!Belt.Map.String} and

    {!Belt.Map.Dict}: This module separates data from function
    which  is more verbose but slightly more efficient
*)

module MutableSet = Belt_MutableSet
(** {!Belt.MutableSet}

    The top level provides generic {b mutable} set operations.

    It also has two specialized inner modules
    {!Belt.MutableSet.Int} and {!Belt.MutableSet.String}
*)

module MutableMap = Belt_MutableMap
(** {!Belt.MutableMap}

    The top level provides generic {b mutable} map operations.

    It also has two specialized inner modules
    {!Belt.MutableMap.Int} and {!Belt.MutableMap.String}

*)

module HashSet = Belt_HashSet
(** {!Belt.HashSet}

    The top level provides generic {b mutable} hash set operations.

    It also has two specialized inner modules
    {!Belt.HashSet.Int} and {!Belt.HashSet.String}
*)

module HashMap = Belt_HashMap
(** {!Belt.HashMap}

    The top level provides generic {b mutable} hash map operations.

    It also has two specialized inner modules
    {!Belt.HashMap.Int} and {!Belt.HashMap.String}
*)

module Option = Belt_Option
(** {!Belt.Option}

    Utilities for option data type.
*)

(** {!Belt.Result}

    Utilities for result data type.
*)

module Result = Belt_Result

(** {!Belt.Int}

    Utilities for Int.
*)

module Int = Belt_Int

(** {!Belt.Float}

    Utilities for Float.
*)

module Float = Belt_Float
