
  $ . ./setup.sh

  $ cat > json.ml <<\EOF
  > module Decode = struct
  >   type error = Json_error of string | Unexpected_variant of string
  >   let error_to_string = function
  >     | Json_error msg -> msg
  >     | Unexpected_variant tag -> "unexpected variant: " ^ tag
  >   
  >   exception DecodeError of error
  > end

  $ cat > ppx_deriving_json_runtime.ml <<\EOF
  > type t = Js.Json.t
  > 
  > let to_json t = t
  > let of_json t = t
  > let to_string t = Js.Json.stringify t
  > 
  > exception Of_string_error of string
  > 
  > let of_string s =
  >   try Js.Json.parseExn s
  >   with exn ->
  >     let msg =
  >       match Js.Exn.asJsExn exn with
  >       | Some jsexn -> Js.Exn.message jsexn
  >       | None -> None
  >     in
  >     let msg =
  >       (* msg really cannot be None in browser or any sane JS runtime *)
  >       Option.value msg ~default:"JSON error"
  >     in
  >     raise (Of_string_error msg)
  > 
  > type error = Json.Decode.error =
  >   | Json_error of string
  >   | Unexpected_variant of string
  > 
  > exception Of_json_error = Json.Decode.DecodeError
  > 
  > let of_json_error msg = raise (Of_json_error (Json_error msg))
  > 
  > let unexpected_variant_error tag =
  >   raise (Of_json_error (Unexpected_variant tag))
  > 
  > module To_json = struct
  >   external string_to_json : string -> t = "%identity"
  >   external bool_to_json : bool -> t = "%identity"
  >   external int_to_json : int -> t = "%identity"
  >   external float_to_json : float -> t = "%identity"
  > 
  >   let unit_to_json () : t = Obj.magic Js.null
  > 
  >   let array_to_json v_to_json vs : t =
  >     let vs : Js.Json.t array = Js.Array.map ~f:v_to_json vs in
  >     Obj.magic vs
  > 
  >   let list_to_json v_to_json vs : t =
  >     let vs = Array.of_list vs in
  >     array_to_json v_to_json vs
  > 
  >   let option_to_json v_to_json v : t =
  >     match v with None -> Obj.magic Js.null | Some v -> v_to_json v
  > 
  >   let result_to_json a_to_json b_to_json v : t =
  >     match v with
  >     | Ok x -> Obj.magic [| string_to_json "Ok"; a_to_json x |]
  >     | Error x -> Obj.magic [| string_to_json "Error"; b_to_json x |]
  > end
  > 
  > module Of_json = struct
  >   let string_of_json (json : t) : string =
  >     if Js.typeof json = "string" then (Obj.magic json : string)
  >     else of_json_error "expected a string"
  > 
  >   let bool_of_json (json : t) : bool =
  >     if Js.typeof json = "boolean" then (Obj.magic json : bool)
  >     else of_json_error "expected a boolean"
  > 
  >   let is_int value =
  >     Js.Float.isFinite value && Js.Math.floor_float value == value
  > 
  >   let int_of_json (json : t) : int =
  >     if Js.typeof json = "number" then
  >       let v = (Obj.magic json : float) in
  >       if is_int v then (Obj.magic v : int)
  >       else of_json_error "expected an integer"
  >     else of_json_error "expected an integer"
  > 
  >   let float_of_json (json : t) : float =
  >     if Js.typeof json = "number" then (Obj.magic json : float)
  >     else of_json_error "expected a float"
  > 
  >   let unit_of_json (json : t) =
  >     if (Obj.magic json : 'a Js.null) == Js.null then ()
  >     else of_json_error "expected null"
  > 
  >   let array_of_json v_of_json (json : t) =
  >     if Js.Array.isArray json then
  >       let json = (Obj.magic json : Js.Json.t array) in
  >       Js.Array.map ~f:v_of_json json
  >     else of_json_error "expected a JSON array"
  > 
  >   let list_of_json v_of_json (json : t) =
  >     array_of_json v_of_json json |> Array.to_list
  > 
  >   let option_of_json v_of_json (json : t) =
  >     if (Obj.magic json : 'a Js.null) == Js.null then None
  >     else Some (v_of_json json)
  > 
  >   let result_of_json ok_of_json err_of_json (json : t) =
  >     if Js.Array.isArray json then
  >       let array = (Obj.magic json : Js.Json.t array) in
  >       let len = Js.Array.length array in
  >       if Stdlib.( > ) len 0 then
  >         let tag = Js.Array.unsafe_get array 0 in
  >         if Stdlib.( = ) (Js.typeof tag) "string" then
  >           let tag = (Obj.magic tag : string) in
  >           if Stdlib.( = ) tag "Ok" then (
  >             if Stdlib.( <> ) len 2 then
  >               of_json_error "expected a JSON array of length 2";
  >             Ok (ok_of_json (Js.Array.unsafe_get array 1)))
  >           else if Stdlib.( = ) tag "Error" then (
  >             if Stdlib.( <> ) len 2 then
  >               of_json_error "expected a JSON array of length 2";
  >             Error (err_of_json (Js.Array.unsafe_get array 1)))
  >           else of_json_error "invalid JSON"
  >         else
  >           of_json_error
  >             "expected a non empty JSON array with element being a string"
  >       else of_json_error "expected a non empty JSON array"
  >     else of_json_error "expected a non empty JSON array"
  > end
  > 
  > module Primitives = struct
  >   include Of_json
  >   include To_json
  > end
  > 
  > module Classify = struct
  >   let classify :
  >       t ->
  >       [ `Null
  >       | `String of string
  >       | `Float of float
  >       | `Int of int
  >       | `Bool of bool
  >       | `List of t list
  >       | `Assoc of (string * t) list ] =
  >    fun json ->
  >     if (Obj.magic json : 'a Js.null) == Js.null then `Null
  >     else
  >       match Js.typeof json with
  >       | "string" -> `String (Obj.magic json : string)
  >       | "number" ->
  >           let v = (Obj.magic json : float) in
  >           if Of_json.is_int v then `Int (Obj.magic v : int) else `Float v
  >       | "boolean" -> `Bool (Obj.magic json : bool)
  >       | "object" ->
  >           if Js.Array.isArray json then
  >             let xs = Array.to_list (Obj.magic json : t array) in
  >             `List xs
  >           else
  >             let xs = Js.Dict.entries (Obj.magic json : t Js.Dict.t) in
  >             `Assoc (Array.to_list xs)
  >       | typ -> failwith ("unknown JSON value type: " ^ typ)
  > end

  $ cat > x.ml <<\EOF
  > type t = [ `A  | `B ][@@deriving json]
  > include
  >   struct
  >     let _ = fun (_ : t) -> ()
  >     [@@@ocaml.warning "-39-11-27"]
  >     let rec of_json =
  >       (fun x ->
  >          if Js.Array.isArray x
  >          then
  >            let array = (Obj.magic x : Js.Json.t array) in
  >            let len = Js.Array.length array in
  >            (if Stdlib.(>) len 0
  >             then
  >               let tag = Js.Array.unsafe_get array 0 in
  >               (if Stdlib.(=) (Js.typeof tag) "string"
  >                then
  >                  let tag = (Obj.magic tag : string) in
  >                  (if Stdlib.(=) tag "A"
  >                   then
  >                     (if Stdlib.(<>) len 1
  >                      then
  >                        Ppx_deriving_json_runtime.of_json_error
  >                          "expected a JSON array of length 1";
  >                      `A)
  >                   else
  >                     if Stdlib.(=) tag "B"
  >                     then
  >                       (if Stdlib.(<>) len 1
  >                        then
  >                          Ppx_deriving_json_runtime.of_json_error
  >                            "expected a JSON array of length 1";
  >                        `B)
  >                     else
  >                       raise
  >                         (Ppx_deriving_json_runtime.Of_json_error
  >                            (Ppx_deriving_json_runtime.Unexpected_variant
  >                               "unexpected variant")))
  >                else
  >                  Ppx_deriving_json_runtime.of_json_error
  >                    "expected a non empty JSON array with element being a string")
  >             else
  >               Ppx_deriving_json_runtime.of_json_error
  >                 "expected a non empty JSON array")
  >          else
  >            Ppx_deriving_json_runtime.of_json_error
  >              "expected a non empty JSON array" : Js.Json.t -> t)
  >     let _ = of_json
  >     [@@@ocaml.warning "-39-11-27"]
  >     let rec to_json =
  >       (fun x ->
  >          match x with
  >          | `A -> (Obj.magic [|(string_to_json "A")|] : Js.Json.t)
  >          | `B -> (Obj.magic [|(string_to_json "B")|] : Js.Json.t) : t ->
  >                                                                     Js.Json.t)
  >     let _ = to_json
  >   end[@@ocaml.doc "@inline"][@@merlin.hide ]
  > type u = t[@@deriving json]
  > include
  >   struct
  >     let _ = fun (_ : u) -> ()
  >     [@@@ocaml.warning "-39-11-27"]
  >     let rec u_of_json = (fun x -> of_json x : Js.Json.t -> u)
  >     let _ = u_of_json
  >     [@@@ocaml.warning "-39-11-27"]
  >     let rec u_to_json = (fun x -> to_json x : u -> Js.Json.t)
  >     let _ = u_to_json
  >   end[@@ocaml.doc "@inline"][@@merlin.hide ]
  > let () = print_endline (Ppx_deriving_json_runtime.to_string (u_to_json `A))
  > let () =
  >   assert ((u_of_json (Ppx_deriving_json_runtime.of_string {|["B"]|})) = `B)
  > EOF

  $ melc -w @1..3@5..28@30..39@43@46..47@49..57@61..62@67@69-40 -strict-sequence -strict-formats -short-paths -keep-locs -w -37-69 -g -bin-annot -bin-annot-occurrences --bs-stop-after-cmj --bs-package-output . --bs-module-name json -no-alias-deps -opaque -o json.cmj -c -impl json.ml

  $ melc -w @1..3@5..28@30..39@43@46..47@49..57@61..62@67@69-40 -strict-sequence -strict-formats -short-paths -keep-locs -w -37-69 -g -bin-annot -bin-annot-occurrences --bs-stop-after-cmj -I . --bs-package-output . --bs-module-name ppx_deriving_json_runtime -no-alias-deps -opaque -o ppx_deriving_json_runtime.cmj -c -impl ppx_deriving_json_runtime.ml

  $ melc -w @1..3@5..28@30..39@43@46..47@49..57@61..62@67@69-40 -strict-sequence -strict-formats -short-paths -keep-locs -w -37-69 -g -bin-annot -bin-annot-occurrences -open Ppx_deriving_json_runtime.Primitives -I . x.ml
  // Generated by Melange
  'use strict';
  
  const Caml_js_exceptions = require("melange.js/caml_js_exceptions.js");
  const Ppx_deriving_json_runtime = require("ppx_deriving_json_runtime.js");
  
  function of_json(x) {
    if (!Array.isArray(x)) {
      return Ppx_deriving_json_runtime.of_json_error("expected a non empty JSON array");
    }
    const len = x.length;
    if (len <= 0) {
      return Ppx_deriving_json_runtime.of_json_error("expected a non empty JSON array");
    }
    const tag = x[0];
    if (typeof tag !== "string") {
      return Ppx_deriving_json_runtime.of_json_error("expected a non empty JSON array with element being a string");
    }
    if (tag === "A") {
      if (len !== 1) {
        Ppx_deriving_json_runtime.of_json_error("expected a JSON array of length 1");
      }
      return "A";
    }
    if (tag === "B") {
      if (len !== 1) {
        Ppx_deriving_json_runtime.of_json_error("expected a JSON array of length 1");
      }
      return "B";
    }
    throw new Caml_js_exceptions.MelangeError(Ppx_deriving_json_runtime.Of_json_error, {
              MEL_EXN_ID: Ppx_deriving_json_runtime.Of_json_error,
              _1: {
                TAG: /* Unexpected_variant */1,
                _0: "unexpected variant"
              }
            });
  }
  
  function to_json(x) {
    if (x === "B") {
      return ["B"];
    } else {
      return ["A"];
    }
  }
  
  const u_of_json = of_json;
  
  const u_to_json = to_json;
  
  console.log(Ppx_deriving_json_runtime.to_string(["A"]));
  
  if (of_json(Ppx_deriving_json_runtime.of_string("[\"B\"]")) !== "B") {
    throw new Caml_js_exceptions.MelangeError("Assert_failure", {
              MEL_EXN_ID: "Assert_failure",
              _1: [
                "x.ml",
                70,
                2
              ]
            });
  }
  
  exports.of_json = of_json;
  exports.to_json = to_json;
  exports.u_of_json = u_of_json;
  exports.u_to_json = u_to_json;
  /*  Not a pure module */
