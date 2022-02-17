# 1 "hashmap.cppo.ml"
(***********************************************************************)
(*                                                                     *)
(*                                OCaml                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)
(**  Adapted by Hongbo Zhang, Authors of ReScript 2017                           *)

# 16 "hashmap.cppo.ml"
type key = string
type seed = int
external caml_hash_mix_string : seed -> string -> seed  = "caml_hash_mix_string"
external final_mix : seed -> seed = "caml_hash_final_mix"
let hash (s : key) =   
  final_mix  (caml_hash_mix_string 0 s )

# 33 "hashmap.cppo.ml"
module N = Belt_internalBuckets
module C = Belt_internalBucketsType
module A = Belt_Array


type 'b t = (unit, unit, key,'b) N.t


let rec copyBucketReHash  ~h_buckets ~ndata_tail  (old_bucket : _ N.bucket  C.opt ) = 
  match C.toOpt old_bucket with 
  | None -> ()
  | Some cell ->
    let nidx = hash cell.key land (A.length h_buckets - 1) in 
    let v = C.return cell in 
    begin match C.toOpt (A.getUnsafe ndata_tail nidx) with
      | None -> 
        A.setUnsafe h_buckets nidx  v
      | Some tail ->
        tail.N.next <- v  (* cell put at the end *)            
    end;          
    A.setUnsafe ndata_tail nidx  v;
    copyBucketReHash  ~h_buckets ~ndata_tail  cell.next


let resize  h =
  let odata = h.C.buckets in
  let osize = A.length odata in
  let nsize = osize * 2 in
  if nsize >= osize then begin (* no overflow *)
    let h_buckets = A.makeUninitialized nsize  in
    let ndata_tail = A.makeUninitialized nsize  in (* keep track of tail *)
    h.C.buckets <- h_buckets;          (* so that indexfun sees the new bucket count *)
    for i = 0 to osize - 1 do
      copyBucketReHash  ~h_buckets ~ndata_tail  (A.getUnsafe odata i)
    done;
    for i = 0 to nsize - 1 do
      match C.toOpt (A.getUnsafe ndata_tail i) with
      | None -> ()
      | Some tail -> tail.next <- C.emptyOpt
    done
  end


let rec replaceInBucket  (key : key) info cell = 
    if  cell.N.key = key 
    then
      begin
        cell.N.value <- info;
        false
      end
    else
    match C.toOpt cell.next with 
    | None -> true 
    | Some cell -> 
      replaceInBucket key info cell

let set  h (key : key) value =
  let h_buckets = h.C.buckets in 
  let buckets_len = A.length h_buckets in 
  let i = hash key land (buckets_len - 1) in 
  let l = A.getUnsafe h_buckets i in  
  (match C.toOpt l with 
  | None -> 
    A.setUnsafe h_buckets i (C.return {N.key; value; next = C.emptyOpt});
    h.C.size <- (h.C.size + 1);
  | Some bucket -> 
      if replaceInBucket key value bucket then begin
        A.setUnsafe h_buckets i (C.return {N.key; value; next = l});
        h.C.size <- (h.C.size + 1);
      end   
    );
    if h.C.size > buckets_len lsl 1 then resize h 



let rec removeInBucket h h_buckets  i (key : key) prec buckets =
  match C.toOpt buckets with
  | None -> ()
  | Some cell  ->
    let cell_next = cell.N.next in 
    if  cell.N.key = key 
    then 
      begin
        prec.N.next <-cell_next;
        h.C.size <- (h.C.size - 1);        
      end
    else removeInBucket  h h_buckets i key cell cell_next

let remove  h key =  
  let h_buckets = h.C.buckets in 
  let i = hash key land (A.length h_buckets - 1) in  
  let bucket = (A.getUnsafe h_buckets i) in 
  match C.toOpt bucket with 
  | None -> ()
  | Some cell -> 
    if cell.N.key = key then 
    begin 
      A.setUnsafe h_buckets i cell.next;
      h.C.size <- (h.C.size - 1)
    end 
    else 
      removeInBucket  h h_buckets i key cell cell.next



let rec getAux  (key : key) buckets = 
  match C.toOpt buckets with 
  | None ->
    None
  | Some cell ->
    if key = cell.N.key  then Some cell.N.value 
    else getAux key  cell.next

let get  h (key : key) =
  let h_buckets = h.C.buckets in 
  let nid = hash key  land (A.length h_buckets - 1) in 
  match C.toOpt (A.getUnsafe h_buckets nid) with
  | None -> None
  | Some cell1 ->
    if key = cell1.N.key  then Some cell1.N.value else
      match C.toOpt cell1.N.next with
      | None -> None
      | Some cell2 ->
        if  key = cell2.N.key  then Some cell2.N.value else
          match C.toOpt cell2.N.next with
          | None -> None
          | Some cell3 ->
            if  key = cell3.N.key  then Some cell3.N.value
            else getAux  key cell3.N.next


let rec memInBucket (key : key) cell = 
    cell.N.key  = key  ||
    (match C.toOpt cell.next with 
    | None -> false
    | Some nextCell -> memInBucket  key nextCell
     )
    
let has h key =
  let h_buckets = h.C.buckets in 
  let nid = hash key land (A.length h_buckets - 1) in 
  let bucket = A.getUnsafe h_buckets nid in 
  match C.toOpt bucket with 
  | None -> false
  | Some bucket -> 
    memInBucket  key bucket


let make ~hintSize = C.make ~hintSize ~hash:() ~eq:()
let clear = C.clear
let size h = h.C.size
let forEachU = N.forEachU 
let forEach = N.forEach
let reduceU = N.reduceU
let reduce = N.reduce               
let logStats = N.logStats
let keepMapInPlaceU = N.keepMapInPlaceU 
let keepMapInPlace = N.keepMapInPlace
let toArray = N.toArray
let copy = N.copy
let keysToArray = N.keysToArray
let valuesToArray = N.valuesToArray
let getBucketHistogram = N.getBucketHistogram 
let isEmpty = C.isEmpty

let fromArray arr = 
  let len = A.length arr in 
  let v = make ~hintSize:len in 
  for i = 0 to len - 1 do 
    let k,value = (A.getUnsafe arr i) in
    set v k value
  done ;
  v

(* TOOD: optimize heuristics for resizing *)  
let mergeMany h arr =   
  let len = A.length arr in 
  for i = 0 to len - 1 do 
    let k,v = (A.getUnsafe arr i) in
    set h k v 
  done

