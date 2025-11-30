let test_rindex_neg () =
  Alcotest.(check bool) "not found " true (String.rindex_neg "hello" 'x' < 0);
  Alcotest.(check int) __LOC__ (String.rindex_neg "hello" 'h') 0;
  Alcotest.(check int) __LOC__ (String.rindex_neg "hello" 'e') 1;
  Alcotest.(check int) __LOC__ (String.rindex_neg "hello" 'l') 3;
  Alcotest.(check int) __LOC__ (String.rindex_neg "hello" 'l') 3;
  Alcotest.(check int) __LOC__ (String.rindex_neg "hello" 'o') 4;
  Alcotest.(check bool) "empty string" true (String.rindex_neg "" 'x' < 0)

let test_for_all_from () =
  Alcotest.(check bool)
    __LOC__ false
    (String.for_all_from "xABc" ~from:1 ~f:(function
      | 'A' .. 'Z' -> true
      | _ -> false));
  Alcotest.(check bool)
    __LOC__ true
    (String.for_all_from "xABC" ~from:1 ~f:(function
      | 'A' .. 'Z' -> true
      | _ -> false));
  Alcotest.(check bool)
    __LOC__ true
    (String.for_all_from "xABC" ~from:1_000 ~f:(function
      | 'A' .. 'Z' -> true
      | _ -> false))

let test_tail_from () =
  Alcotest.(check string) __LOC__ (String.tail_from "ghsogh" ~from:1) "hsogh";
  Alcotest.(check string) __LOC__ (String.tail_from "ghsogh" ~from:0) "ghsogh"

let test_digest () =
  Alcotest.(check int) __LOC__ (String.length (Digest.string "")) 16

let test_split () =
  Alcotest.(check (list string)) __LOC__ (String.split "" ~sep:':') [];
  Alcotest.(check (list string))
    __LOC__
    (String.split "a:b:" ~sep:':')
    [ "a"; "b" ];
  Alcotest.(check (list string))
    __LOC__
    (String.split "a:b:" ~sep:':' ~keep_empty:true)
    [ "a"; "b"; "" ]

let suite =
  [
    ("rindex_neg", `Quick, test_rindex_neg);
    ("for_all_from", `Quick, test_for_all_from);
    ("tail_from", `Quick, test_tail_from);
    ("digest", `Quick, test_digest);
    ("split", `Quick, test_split);
  ]
