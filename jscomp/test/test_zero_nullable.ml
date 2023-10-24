let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


module Test_null = struct
let f1 x =
  match Js.Null.toOption x with
  | None ->
    let sum x y = x + y in
    sum 1 2
  | Some x ->
    let sum x y = x + y in
    sum x 1

let f2 x =
  let u = Js.Null.toOption x in
  match  u with
  | None ->
    let sum x y = x + y in
    sum 1 2
  | Some x ->
    let sum x y = x + y in
    sum x 1



let f5 h x =
  let u = Js.Null.toOption @@ h 32 in
  match  u with
  | None ->
    let sum x y = x + y in
    sum 1 2
  | Some x ->
    let sum x y = x + y in
    sum x 1

let f4 h x =
  let u = Js.Null.toOption @@ h 32 in
  let v = 32 + x  in
  match  u with
  | None ->
    let sum x y = x + y in
    sum 1 v
  | Some x ->
    let sum x y = x + y in
    sum x 1

let f6 x y = x == y

let f7 x =
  match Some x with
  | None -> None
  | Some x -> x

(* can [from_opt x ]  generate [Some None] which has type ['a Js.opt Js.opt] ?
   No, if [x] is [null] then None else [Some x]
*)
let f8 (x : 'a Js.Null.t Js.Null.t)=
  match Js.Null.toOption x with
  | Some x ->
    (match Js.Null.toOption x with
    | Some _ -> 0
    | None -> 1 )
  | None -> 2

let u = f8 (Js.Null.return (Js.Null.return None))

let f9 x = Js.Null.toOption x

let f10 x = x = Js.null

let f11 =  (Js.Null.return 3 = Js.null)

end

module Test_def = struct



  let f1 x =
    match Js.Undefined.toOption x with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f2 x =
    let u = Js.Undefined.toOption x in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1



  let f5 h x =
    let u = Js.Undefined.toOption @@ h 32 in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f4 h x =
    let u = Js.Undefined.toOption @@ h 32 in
    let v = 32 + x  in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 v
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f6 x y = x == y

  let f7 x =
    match Some x with
    | None -> None
    | Some x -> x

  (* can [from_def x ]  generate [Some None] which has type ['a Js.opt Js.opt] ?
     No, if [x] is [null] then None else [Some x]
  *)
  let f8 x =
    match Js.Undefined.toOption x with
    | Some x ->
      (match Js.Undefined.toOption x with
       | Some _ -> 0
       | None -> 1 )
    | None -> 2

  let u = f8 (Js.Undefined.return (Js.Undefined.return None))

  let f9 x = Js.Undefined.toOption x

  let f10 x =  x = Js.undefined
  let f11 = Js.Undefined.return 3 = Js.undefined
end


module Test_null_def = struct
  open Js.Nullable
  let f1 x =
    match toOption x with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f2 x =
    let u = toOption x in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1



  let f5 h x =
    let u = toOption @@ h 32 in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 2
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f4 h x =
    let u = toOption @@ h 32 in
    let v = 32 + x  in
    match  u with
    | None ->
      let sum x y = x + y in
      sum 1 v
    | Some x ->
      let sum x y = x + y in
      sum x 1

  let f6 x y = x == y

  let f7 x =
    match Some x with
    | None -> None
    | Some x -> x

  (* can [from_opt x ]  generate [Some None] which has type ['a Js.opt Js.opt] ?
     No, if [x] is [null] then None else [Some x]
  *)
  let f8 (x : 'a t t)=
    match toOption x with
    | Some x ->
      (match toOption x with
       | Some _ -> 0
       | None -> 1 )
    | None -> 2

  let u = f8 (return (return None))

  let f9 x = toOption x

  let f10 x = isNullable x

  let f11 =  (isNullable @@ return 3)

end

let () =
  begin
    eq __LOC__ (Test_null_def.f1 (Js.Nullable.return 0 )) 1 ;
    eq __LOC__ (Test_null_def.f1 ([%mel.raw "null"])) 3 ;
    eq __LOC__ (Test_null_def.f1 ([%mel.raw "undefined"])) 3 ;

    eq __LOC__ (Test_null.f1 (Js.Null.return 0 )) 1 ;
    eq __LOC__ (Test_null.f1 ([%mel.raw "null"])) 3 ;

    eq __LOC__ (Test_def.f1 (Js.Undefined.return 0 )) 1 ;
    eq __LOC__ (Test_def.f1 ([%mel.raw "undefined"])) 3 ;
  end

let () = Mt.from_pair_suites __MODULE__ !suites
