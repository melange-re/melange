[@@@warning "-45"]
type  u  = A of int | B of int * bool | C of int

let[@ocaml.warning "-52"] function_equal_test = try ((fun x -> x + 1) = (fun x -> x + 2)) with
                         | Invalid_argument "equal: functional value" -> true
                         | _ -> false

let suites = ref Mt.[
    __LOC__ , (fun _ -> Eq(true, None < Some 1));
    "option2", (fun _ -> Eq(true, Some 1 < Some 2));
    __LOC__, (fun _ -> Eq(true, [1] > []));
    "listeq", (fun _ -> Eq(true, [1;2;3] = [1;2;3]));
    "listneq", (fun _ -> Eq(true, [1;2;3] > [1;2;2]));
    "custom_u", (fun _ -> Eq(true, ( A 3  ,  B (2,false) , C 1)  > ( A 3, B (2,false) , C 0 )));
    "custom_u2", (fun _ -> Eq(true, ( A 3  ,  B (2,false) , C 1)  = ( A 3, B (2,false) , C 1 )));
    "function", (fun _ -> Eq(true, function_equal_test));
    __LOC__ , begin fun _ ->
        Eq(true, None < Some 1)
    end;
    (*JS WAT
        {[
            0 < [1]
            true
            0 < [1,30]
            false
        ]}
    *)
    __LOC__, begin fun _ ->
        Eq(true, None < Some [|1;30|] )
    end;
    __LOC__, begin fun _ ->
        Eq(true,  Some [|1;30|] > None  )
    end;
    __LOC__ , begin fun _ ->
        Eq(true, [2;6;1;1;2;1;4;2;1] < [2;6;1;1;2;1;4;2;1;409])
    end;
    __LOC__ , begin fun _ ->
        Eq(true, [1] < [1;409])
    end;
    __LOC__ , begin fun _ ->
        Eq(true, [] < [409])
    end;
    __LOC__ , begin fun _ ->
        Eq(true,  [2;6;1;1;2;1;4;2;1;409] > [2;6;1;1;2;1;4;2;1])
    end;

    __LOC__, begin fun _ ->
        Eq(false, None = Some [|1;30|] )
    end;
    __LOC__, begin fun _ ->
        Eq(false,  Some [|1;30|] = None  )
    end;
    __LOC__ , begin fun _ ->
        Eq(false, [2;6;1;1;2;1;4;2;1] = [2;6;1;1;2;1;4;2;1;409])
    end;
    __LOC__ , begin fun _ ->
        Eq(false,  [2;6;1;1;2;1;4;2;1;409] = [2;6;1;1;2;1;4;2;1])
    end;

    "cmp_id", (fun _ -> Eq (compare [%mel.obj {x=1; y=2}] [%mel.obj {x=1; y=2}], 0));
    "cmp_val", (fun _ -> Eq (compare [%mel.obj {x=1}] [%mel.obj {x=2}], -1));
    "cmp_val2", (fun _ -> Eq (compare [%mel.obj {x=2}] [%mel.obj {x=1}], 1));
    "cmp_empty", (fun _ -> Eq (compare [%mel.raw "{}"] [%mel.raw "{}"], 0));
    "cmp_empty2", (fun _ -> Eq (compare [%mel.raw "{}"] [%mel.raw "{x:1}"], -1));
    "cmp_swap", (fun _ -> Eq (compare [%mel.obj {x=1; y=2}] [%mel.obj {y=2; x=1}], 0));
    "cmp_size", (fun _ -> Eq (compare [%mel.raw "{x:1}"] [%mel.raw "{x:1, y:2}"], -1));
    "cmp_size2", (fun _ -> Eq (compare [%mel.raw "{x:1, y:2}"] [%mel.raw "{x:1}"], 1));
    "cmp_order", (fun _ -> Eq (compare [%mel.obj {x=0; y=1}] [%mel.obj {x=1; y=0}], -1));
    "cmp_order2", (fun _ -> Eq (compare [%mel.obj {x=1; y=0}] [%mel.obj {x=0; y=1}], 1));
    "cmp_in_list", (fun _ -> Eq (compare [[%mel.obj {x=1}]] [[%mel.obj {x=2}]], -1));
    "cmp_in_list2", (fun _ -> Eq (compare [[%mel.obj {x=2}]] [[%mel.obj {x=1}]], 1));
    "cmp_with_list", (fun _ -> Eq (compare [%mel.obj {x=[0]}] [%mel.obj {x=[1]}], -1));
    "cmp_with_list2", (fun _ -> Eq (compare [%mel.obj {x=[1]}] [%mel.obj {x=[0]}], 1));
    "eq_id", (fun _ -> Ok ([%mel.obj {x=1; y=2}] = [%mel.obj {x=1; y=2}]));
    "eq_val", (fun _ -> Eq ([%mel.obj {x=1}] = [%mel.obj {x=2}], false));
    "eq_val2", (fun _ -> Eq ([%mel.obj {x=2}] = [%mel.obj {x=1}], false));
    "eq_empty", (fun _ -> Eq ([%mel.raw "{}"] = [%mel.raw "{}"], true));
    "eq_empty2", (fun _ -> Eq ([%mel.raw "{}"] = [%mel.raw "{x:1}"], false));
    "eq_swap", (fun _ -> Ok ([%mel.obj {x=1; y=2}] = [%mel.obj {y=2; x=1}]));
    "eq_size", (fun _ -> Eq ([%mel.raw "{x:1}"] = [%mel.raw "{x:1, y:2}"], false));
    "eq_size2", (fun _ -> Eq ([%mel.raw "{x:1, y:2}"] = [%mel.raw "{x:1}"], false));
    "eq_in_list", (fun _ -> Eq ([[%mel.obj {x=1}]] = [[%mel.obj {x=2}]], false));
    "eq_in_list2", (fun _ -> Eq ([[%mel.obj {x=2}]] = [[%mel.obj {x=2}]], true));
    "eq_with_list", (fun _ -> Eq ([%mel.obj {x=[0]}] = [%mel.obj {x=[0]}], true));
    "eq_with_list2", (fun _ -> Eq ([%mel.obj {x=[0]}] = [%mel.obj {x=[1]}], false));
    "eq_no_prototype", (fun _ -> Eq ([%mel.raw "{x:1}"] = [%mel.raw "(function(){let o = Object.create(null);o.x = 1;return o;})()"], true));

    __LOC__ , begin fun _ ->
        Eq(compare Js.null (Js.Null.return [3]), -1)
    end;
    __LOC__ , begin fun _ ->
        Eq(compare (Js.Null.return [3]) Js.null, 1)
    end;
    __LOC__ , begin fun _ ->
        Eq(compare Js.null (Js.Null.return 0), -1)
    end;
    __LOC__ , begin fun _ ->
        Eq(compare (Js.Null.return 0) Js.null, 1)
    end;
    __LOC__ , begin fun _ ->
        Eq(compare Js.Nullable.undefined (Js.Nullable.return 0), -1)
    end;
    __LOC__ , begin fun _ ->
        Eq(compare (Js.Nullable.return 0) Js.Nullable.undefined, 1)
    end;
]
;;


let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y

;; eq __LOC__ true (Some 1 > None)
;; eq __LOC__ true ([] < [1])
;; eq __LOC__ false (None > Some 1)
;; eq __LOC__ false (None > Some [|1;30|])
;; eq __LOC__ false (Some [|1;30|] < None)
let () = Mt.from_pair_suites __MODULE__ !suites
