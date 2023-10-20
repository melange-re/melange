let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y
let b loc x =  Mt.bool_suites ~test_id ~suites loc x
let t loc x = Mt.throw_suites ~test_id ~suites loc x
module N = Belt.Set
module D = Belt.Set.Dict
module I = Array_data_util
module A = Belt.Array
module S = Belt.SortArray
module IntCmp =
  (val Belt.Id.comparable ~cmp:(fun (x:int) y -> compare x y))
module L = Belt.List

let () =
  let u0 = N.fromArray ~id:(module IntCmp) (I.range 0 30) in
  let u1 = N.remove u0 0 in
  let u2 = N.remove u1 0 in
  let u3 = N.remove u2 30 in
  let u4 = N.remove u3 20 in
  let r = I.randomRange 0 30 in

  let u5  = N.add u4 3 in
  let u6 = N.removeMany u5 r in
  let u7 = N.mergeMany u6 [|0;1;2;0|] in
  let u8 = N.removeMany u7 [|0;1;2;3|] in
  let u9 = N.mergeMany u8 (I.randomRange 0 20000)  in
  let u10 = N.mergeMany u9 (I.randomRange 0 200) in
  let u11 = N.removeMany u10 (I.randomRange 0 200) in
  let u12 = N.removeMany u11 (I.randomRange 0 1000) in
  let u13 = N.removeMany u12 (I.randomRange 0 1000) in
  let u14 = N.removeMany u13 (I.randomRange 1000 10000) in
  let u15 = N.removeMany u14 (I.randomRange 10000 (20000 - 1)) in
  let u16 = N.removeMany u15 (I.randomRange 20000 21000) in
  b __LOC__ (u0 != u1);
  b __LOC__ (u2 == u1);
  eq __LOC__ (N.size u4) 28;
  b __LOC__ (Js.eqUndefined 29 (N.maxUndefined u4));
  b __LOC__ (Js.eqUndefined 1 (N.minUndefined u4));
  b __LOC__ (u4 == u5);
  b __LOC__ (N.isEmpty u6);
  eq  __LOC__ (N.size u7) 3 ;
  b __LOC__ (not (N.isEmpty u7));
  b __LOC__ (N.isEmpty u8);
  (* b __LOC__ (u9 == u10); *)
  (* addArray does not get reference equality guarantee *)
  b __LOC__ (N.has u10 20);
  b __LOC__ (N.has u10 21);
  eq __LOC__ (N.size u10) 20001;
  eq __LOC__ (N.size u11) 19800;
  eq __LOC__ (N.size u12) 19000;
  (* b __LOC__ (u12 == u13);   *)
  eq __LOC__ (N.size u13) (N.size u12);
  eq __LOC__ (N.size u14) 10000;
  eq __LOC__ (N.size u15) 1 ;
  b __LOC__ (N.has u15 20000);
  b __LOC__ (not @@ N.has u15 2000);
  b __LOC__ (N.isEmpty u16);
  let u17  = N.fromArray ~id:(module IntCmp) (I.randomRange 0 100) in
  let u18 = N.fromArray ~id:(module IntCmp) (I.randomRange 59 200) in
  let u19 = N.union u17 u18 in
  let u20 = N.fromArray ~id:(module IntCmp) (I.randomRange 0 200) in
  let u21 =  N.intersect u17 u18 in
  let u22 = N.diff u17 u18 in
  let u23 = N.diff u18 u17 in
  let u24 = N.union u18 u17 in
  let u25 = N.add u22 59 in
  let u26 = N.add (N.make ~id:(module IntCmp)) 3 in
  let ss = (A.makeByAndShuffle 100 (fun i -> i * 2 )) in
  let u27 = N.fromArray ~id:(module IntCmp)  ss in
  let u28, u29 = N.union u27 u26, N.union u26 u27 in
  b __LOC__ (N.eq u28 u29);
  b __LOC__ (N.toArray u29 = (S.stableSortBy (A.concat ss [|3|]) compare ));
  b __LOC__ (N.eq u19 u20);
  eq __LOC__ (N.toArray u21) (I.range 59 100);
  eq __LOC__ (N.toArray u22) (I.range 0 58);
  b __LOC__ (N.eq u24 u19);
  eq __LOC__ (N.toArray u23) (I.range 101 200);
  b __LOC__ (N.subset u23 u18);
  b __LOC__ (not (N.subset u18 u23));
  b __LOC__ (N.subset u22 u17);
  b __LOC__ (N.subset u21 u17 && N.subset u21 u18);
  b __LOC__ (Js.eqUndefined 47 (N.getUndefined u22 47));
  b __LOC__ ( Some 47 = (N.get u22 47));
  b __LOC__ ((N.getUndefined u22 59) = Js.undefined);
  b __LOC__ (None = (N.get u22 59));

  eq __LOC__ (N.size u25) 60;
  b __LOC__ (N.minimum (N.make ~id:(module IntCmp)) = None);
  b __LOC__ (N.maximum (N.make ~id:(module IntCmp)) = None);
  b __LOC__ (N.minUndefined (N.make ~id:(module IntCmp)) = Js.undefined);
  b __LOC__ (N.maxUndefined (N.make ~id:(module IntCmp)) = Js.undefined)


let testIterToList  xs =
  let v = ref [] in
  N.forEach xs (fun x -> v := x :: !v ) ;
  L.reverse !v

let testIterToList2  xs =
  let v = ref [] in
  D.forEach (N.getData xs) (fun x -> v := x :: !v ) ;
  L.reverse !v

let () =
  let u0 = N.fromArray ~id:(module IntCmp) (I.randomRange 0 20) in
  let u1 = N.remove u0 17 in
  let u2 = N.add u1 33 in
  b __LOC__ (L.every2 (testIterToList u0) (L.makeBy 21 (fun i -> i)) (fun x y -> x = y));
  b __LOC__ (L.every2 (testIterToList2 u0) (L.makeBy 21 (fun i -> i)) (fun x y -> x = y));
  b __LOC__ (L.every2 (testIterToList u0) (N.toList u0) (fun  x y -> x = y));
  b __LOC__ (N.some u0 (fun  x -> x = 17));
  b __LOC__ (not (N.some u1 (fun x -> x = 17)));
  b __LOC__ (N.every u0 (fun x -> x < 24));
  b __LOC__ (D.every (N.getData u0) (fun x -> x < 24));
  b __LOC__ (not (N.every u2 (fun  x -> x < 24)));
  b __LOC__ ( not @@ N.every (N.fromArray ~id:(module IntCmp) [|1;2;3|]) (fun x -> x = 2));
  b __LOC__ (N.cmp u1 u0 < 0);
  b __LOC__ (N.cmp u0 u1 > 0)

let () =
  let a0 = N.fromArray ~id:(module IntCmp) (I.randomRange 0 1000) in
  let a1,a2 =
    (
      N.keep a0 (fun x -> x mod 2  = 0),
      N.keep a0 (fun x -> x mod 2 <> 0)
    ) in
  let a3, a4 = N.partition a0 (fun x -> x mod 2 = 0) in
  b __LOC__ (N.eq a1 a3);
  b __LOC__ (N.eq a2 a4);
  eq __LOC__ (N.getExn a0 3) 3 ;
  eq __LOC__ (N.getExn a0 4) 4;
  t __LOC__ (fun _ -> ignore @@ N.getExn a0 1002 );
  t __LOC__ (fun _ -> ignore @@ N.getExn a0 (-1) );
  eq __LOC__ (N.size a0 ) 1001;
  b __LOC__ (not @@ N.isEmpty a0);
  let (a5,a6), pres  = N.split a0 200 in
  b __LOC__ pres ;
  eq __LOC__ (N.toArray a5) (A.makeBy 200 (fun i -> i));
  eq __LOC__ (N.toList a6) (L.makeBy 800 (fun i -> i + 201));
  let a7 = N.remove a0 200 in
  let (a8,a9), pres  = N.split a7 200 in
  b __LOC__ (not pres) ;
  eq __LOC__ (N.toArray a8) (A.makeBy 200 (fun i -> i));
  eq __LOC__ (N.toList a9) (L.makeBy 800 (fun i -> i + 201));
  eq __LOC__ (N.minimum a8) (Some 0);
  eq __LOC__ (N.minimum a9) (Some 201);
  L.forEach [a0;a1;a2;a3;a4] (fun  x -> N.checkInvariantInternal x)


let () =
  let a = N.fromArray ~id:(module IntCmp) [||] in
  b __LOC__ (N.isEmpty (N.keep a (fun x -> x mod 2 = 0)))

let () =
  let (aa,bb), pres = N.split (N.make  ~id:(module IntCmp)) 0 in
  b __LOC__ (N.isEmpty aa);
  b __LOC__ (N.isEmpty bb);
  b __LOC__ (not pres)
;; Mt.from_pair_suites __MODULE__ !suites
