Tests for deriving `jsProperties, getSet`

  $ . ./setup.sh

`[@@deriving make_opt_keys]` just derives the constructor

  $ cat > x.ml <<EOF
  > type chartDataItemType =
  >   { height : int
  >   ; foo : string [@mel.as "width"]
  >   } [@@deriving jsProperties]
  > 
  > let t = chartDataItemType ~height:2 ~foo:"bar"
  > EOF
  $ melc -ppx melppx -dsource x.ml
  type chartDataItemType = {
    height: int ;
    foo: string [@mel.as "width"]}[@@deriving jsProperties]
  include
    struct
      let _ = fun (_ : chartDataItemType) -> ()
      external chartDataItemType :
        height:int -> foo:string -> chartDataItemType = "" ""[@@ocaml.warning
                                                               "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\023\000\000\000\t\000\000\000\024\000\000\000\022\145\160\160A\144&height\160\160A\144%width@"]
      [@@ocaml.warning "-unboxable-type-in-prim-decl"]
    end[@@ocaml.doc "@inline"][@@merlin.hide ]
  let t = chartDataItemType ~height:2 ~foo:"bar"
  // Generated by Melange
  'use strict';
  
  
  const t = {
    height: 2,
    width: "bar"
  };
  
  module.exports = {
    t,
  }
  /* No side effect */

`[@@deriving getSet]` just derives the getters / setters

  $ cat > x.ml <<EOF
  > type chartDataItemType =
  >   { height : int
  >   ; foo : string [@mel.as "width"]
  >   } [@@deriving getSet]
  > 
  > EOF
  $ melc -ppx melppx -dsource x.ml
  type chartDataItemType = {
    height: int ;
    foo: string [@mel.as "width"]}[@@deriving getSet]
  include
    struct
      let _ = fun (_ : chartDataItemType) -> ()
      external heightGet : chartDataItemType -> int = "" ""[@@ocaml.warning
                                                             "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\r\000\000\000\004\000\000\000\012\000\000\000\011\176\145AA\168&height@"]
      [@@internal.arity 1][@@ocaml.warning "-unboxable-type-in-prim-decl"]
      external fooGet : chartDataItemType -> string = "" ""[@@ocaml.warning
                                                             "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\012\000\000\000\004\000\000\000\012\000\000\000\011\176\145AA\168%width@"]
      [@@internal.arity 1][@@ocaml.warning "-unboxable-type-in-prim-decl"]
    end[@@ocaml.doc "@inline"][@@merlin.hide ]
  // Generated by Melange
  /* This output is empty. Its source's type definitions, externals and/or unused code got optimized away. */


`[@@deriving jsProperties, getSet]` derives both

  $ cat > x.ml <<EOF
  > type chartDataItemType =
  >   { height : int
  >   ; foo : string [@mel.as "width"]
  >   } [@@deriving jsProperties, getSet]
  > EOF
  $ melc -ppx melppx -dsource x.ml
  type chartDataItemType = {
    height: int ;
    foo: string [@mel.as "width"]}[@@deriving (jsProperties, getSet)]
  include
    struct
      let _ = fun (_ : chartDataItemType) -> ()
      external chartDataItemType :
        height:int -> foo:string -> chartDataItemType = "" ""[@@ocaml.warning
                                                               "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\023\000\000\000\t\000\000\000\024\000\000\000\022\145\160\160A\144&height\160\160A\144%width@"]
      [@@ocaml.warning "-unboxable-type-in-prim-decl"]
      external heightGet : chartDataItemType -> int = "" ""[@@ocaml.warning
                                                             "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\r\000\000\000\004\000\000\000\012\000\000\000\011\176\145AA\168&height@"]
      [@@internal.arity 1][@@ocaml.warning "-unboxable-type-in-prim-decl"]
      external fooGet : chartDataItemType -> string = "" ""[@@ocaml.warning
                                                             "-unboxable-type-in-prim-decl"]
      [@@mel.internal.ffi
        "\132\149\166\190\000\000\000\012\000\000\000\004\000\000\000\012\000\000\000\011\176\145AA\168%width@"]
      [@@internal.arity 1][@@ocaml.warning "-unboxable-type-in-prim-decl"]
    end[@@ocaml.doc "@inline"][@@merlin.hide ]
  // Generated by Melange
  /* This output is empty. Its source's type definitions, externals and/or unused code got optimized away. */


