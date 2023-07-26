let test_id, suites  =  ref 0, ref []
let eq loc = Mt_global.collect_eq test_id suites loc
let approx loc = Mt_global.collect_approx  test_id suites loc

let epsilon_float =
  Int64.float_of_bits 0x3C_B0_00_00_00_00_00_00L

let results =
  Array.append
    [| log10 2., 0.301029995663981198;
       ldexp 1. 6, 64.; (* 1. * 2. ^ 6*)
       ldexp 1. 5, 32.;
       ldexp (1.e-5) 1024, 1.79769313486231605e+303;
       ldexp 1. (-1024), 5.56268464626800346e-309;
       hypot 3. 4. , 5. ;
       hypot 4. 3. , 5. ;
       hypot 5. 12., 13.;
       hypot 12. 5., 13. ;
       copysign 22.3 (-1.), -22.3;
       copysign 22.3 (1.), 22.3;
       expm1 1e-15, 1.00000000000000067e-15;
       log1p 1e-10, 9.9999999995000007e-11;
    |]
    (let a,b = frexp 12.0 in
     let c,d = frexp 0. in
     let e,f = frexp (-12.0) in
     [| c, 0.;
        float_of_int d, 0. ;
       a , 0.75 ;
        float_of_int b, 4.;
        e, -0.75;
        float_of_int f, 4.
     |]
    )

let from_pairs ps =
  ps
  |> Array.mapi (fun i (a,b) -> Printf.sprintf "pair %d" i , (fun _ -> Mt.Approx(a,b)))
  |> Array.to_list

;;
let float_compare (x : float) y = Stdlib.compare x y
let generic_compare = Stdlib.compare
let float_equal (x : float) y = x = y
let generic_equal = (=)
let float_notequal (x : float) y = x <> y
let generic_notequal = (<>)
let float_lessthan (x: float) y = x < y
let generic_lessthan = (<)
let float_greaterthan (x: float) y = x > y
let generic_greaterthan = (>)
let float_lessequal (x: float) y = x <= y
let generic_lessequal = (<=)
let float_greaterequal (x: float) y = x >= y
let generic_greaterequal = (>=)

let () =
  eq __LOC__ (classify_float 3. ) FP_normal;
  eq __LOC__ (modf (-3.125)) (-0.125, -3.);
  eq __LOC__ (let a,b = modf nan in Js.Float.isNaN a,
                                    Js.Float.isNaN b) (true,true);
  (* modf nan => (nan,nan) *)
  eq __LOC__
    (Array.map (fun (x,y) -> float_compare x y) [|1., 3. ; 2., 1. ; 3., 2. |]
  |> Array.map (fun x -> if x > 0 then 1 else if x <0 then -1 else 0 ))
    [|-1; 1; 1|];
  eq __LOC__ (copysign (-3.) (0.)) 3.;
  eq __LOC__  (copysign (3.) (0.)) 3.;
  eq __LOC__ (log10 10.) 1.;
  eq __LOC__ (expm1 0.) 0. ;
  eq __LOC__ (Js.Float.fromString "3.0") 3.0;
  approx __LOC__ (expm1 2.) 6.38905609893065;
  eq __LOC__ (float_compare Js.Float._NaN Js.Float._NaN) 0;
  eq __LOC__ (generic_compare Js.Float._NaN Js.Float._NaN) 0;
  eq __LOC__ (float_compare Js.Float._NaN neg_infinity) (-1);
  eq __LOC__ (generic_compare Js.Float._NaN neg_infinity) (-1);
  eq __LOC__ (float_compare neg_infinity Js.Float._NaN) 1;
  eq __LOC__ (generic_compare neg_infinity Js.Float._NaN) 1;
  eq __LOC__ (float_equal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (generic_equal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (float_equal 4.2 Js.Float._NaN) false;
  eq __LOC__ (generic_equal 4.2 Js.Float._NaN) false;
  eq __LOC__ (float_equal Js.Float._NaN 4.2) false;
  eq __LOC__ (generic_equal Js.Float._NaN 4.2) false;
  eq __LOC__ (float_notequal Js.Float._NaN Js.Float._NaN) true;
  eq __LOC__ (generic_notequal Js.Float._NaN Js.Float._NaN) true;
  eq __LOC__ (float_notequal 4.2 Js.Float._NaN) true;
  eq __LOC__ (generic_notequal 4.2 Js.Float._NaN) true;
  eq __LOC__ (float_notequal Js.Float._NaN 4.2) true;
  eq __LOC__ (generic_notequal Js.Float._NaN 4.2) true;
  eq __LOC__ (float_lessthan Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (generic_lessthan Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (float_lessthan 4.2 Js.Float._NaN) false;
  eq __LOC__ (generic_lessthan 4.2 Js.Float._NaN) false;
  eq __LOC__ (float_lessthan Js.Float._NaN 4.2) false;
  eq __LOC__ (generic_lessthan Js.Float._NaN 4.2) false;
  eq __LOC__ (float_greaterthan Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (generic_greaterthan Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (float_greaterthan 4.2 Js.Float._NaN) false;
  eq __LOC__ (generic_greaterthan 4.2 Js.Float._NaN) false;
  eq __LOC__ (float_greaterthan Js.Float._NaN 4.2) false;
  eq __LOC__ (generic_greaterthan Js.Float._NaN 4.2) false;
  eq __LOC__ (float_lessequal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (generic_lessequal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (float_lessequal 4.2 Js.Float._NaN) false;
  eq __LOC__ (generic_lessequal 4.2 Js.Float._NaN) false;
  eq __LOC__ (float_lessequal Js.Float._NaN 4.2) false;
  eq __LOC__ (generic_lessequal Js.Float._NaN 4.2) false;
  eq __LOC__ (float_greaterequal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (generic_greaterequal Js.Float._NaN Js.Float._NaN) false;
  eq __LOC__ (float_greaterequal 4.2 Js.Float._NaN) false;
  eq __LOC__ (generic_greaterequal 4.2 Js.Float._NaN) false;
  eq __LOC__ (float_greaterequal Js.Float._NaN 4.2) false;
  eq __LOC__ (generic_greaterequal Js.Float._NaN 4.2) false;
;;



let () =
  let a,b = modf 32.3 in
  Mt.from_pair_suites __MODULE__ @@ Mt.[
      "mod_float" ,
      (fun _ ->
         Approx( (mod_float 3.2 0.5), 0.200000000000000178 ))
      ;


      "modf_float1", (fun _ ->

          Approx (a,0.299999999999997158)
        );
      "modf_float2", (fun _ ->
          Approx (b, 32.)
        );
      "int_of_float", (fun _ -> Eq(int_of_float 3.2, 3))
    ] @ from_pairs results @ !suites
