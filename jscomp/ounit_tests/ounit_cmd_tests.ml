let ( // ) = Filename.concat
let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal

(* let output_of_exec_command command args =
    let readme, writeme = Unix.pipe () in
    let pid = Unix.create_process command args Unix.stdin writeme Unix.stderr in
    let in_chan = Unix.in_channel_of_descr readme *)

let perform_bsc = Ounit_cmd_util.perform_bsc
let bsc_check_eval = Ounit_cmd_util.bsc_check_eval

let ok b output =
  if not b then Ounit_cmd_util.debug_output output;
  OUnit.assert_bool __LOC__ b

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           let v_output = perform_bsc [| "-v" |] in
           OUnit.assert_bool __LOC__ ((perform_bsc [| "-h" |]).exit_code = 0);
           OUnit.assert_bool __LOC__ (v_output.exit_code = 0)
           (* Printf.printf "\n*>%s" v_output.stdout; *)
           (* Printf.printf "\n*>%s" v_output.stderr ; *) );
         ( __LOC__ >:: fun _ ->
           let v_output = perform_bsc [| "-bs-eval"; {|let str = "'a'" |} |] in
           ok (v_output.exit_code = 0) v_output );
         ( __LOC__ >:: fun _ ->
           let v_output =
             perform_bsc
               [|
                 "-bs-eval";
                 {|type 'a arra = 'a array
    external
      f :
      int -> int -> int arra -> unit
      = ""
      [@@bs.send.pipe:int]
      [@@bs.splice]|};
               |]
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring v_output.stderr "variadic") );
         ( __LOC__ >:: fun _ ->
           let v_output =
             perform_bsc
               [|
                 "-bs-eval";
                 {|external
  f2 :
  int -> int -> ?y:int array -> unit
  = ""
  [@@bs.send.pipe:int]
  [@@bs.splice]  |};
               |]
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring v_output.stderr "variadic") );
         ( __LOC__ >:: fun _ ->
           let should_be_warning =
             bsc_check_eval {|let bla4 foo x y= foo##(method1 x y [@bs]) |}
           in
           (* debug_output should_be_warning; *)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_be_warning.stderr "Unused") );
         ( __LOC__ >:: fun _ ->
           let should_be_warning =
             bsc_check_eval
               {| external mk : int -> ([`a|`b [@bs.string]]) = "mk" [@@bs.val] |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_be_warning.stderr "Unused") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
external ff :
    resp -> (_ [@bs.as "x"]) -> int -> unit =
    "x" [@@bs.set]
      |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "Ill defined") );
         ( __LOC__ >:: fun _ ->
           (* used in return value
               This should fail, we did not
               support uncurry return value yet
           *)
           let should_err =
             bsc_check_eval
               {|
    external v3 :
    int -> int -> (int -> int -> int [@bs.uncurry])
    = "v3"[@@bs.val]

    |}
           in
           (* Ounit_cmd_util.debug_output should_err;*)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "bs.uncurry") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
    external v4 :
    (int -> int -> int [@bs.uncurry]) = ""
    [@@bs.val]

    |}
           in
           (* Ounit_cmd_util.debug_output should_err ; *)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "uncurry") );
         ( __LOC__ >:: fun _ ->
           let should_err = bsc_check_eval {|
      {js| \uFFF|js}
      |} in
           OUnit.assert_bool __LOC__
             (not @@ Ext_string.is_empty should_err.stderr) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      external mk : int -> ([`a|`b] [@bs.string]) = "" [@@bs.val]
      |}
           in
           OUnit.assert_bool __LOC__
             (not @@ Ext_string.is_empty should_err.stderr) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      external mk : int -> ([`a|`b] ) = "mk" [@@bs.val]
      |}
           in
           OUnit.assert_bool __LOC__ (Ext_string.is_empty should_err.stderr)
           (* give a warning or ?
              ( [`a | `b ] [@bs.string] )
              (* auto-convert to ocaml poly-variant *)
           *) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      type t
      external mk : int -> (_ [@bs.as {json| { x : 3 } |json}]) ->  t = "mk" [@@bs.val]
      |}
           in
           OUnit.assert_bool __LOC__ (Ext_string.is_empty should_err.stderr) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      type t
      external mk : int -> (_ [@bs.as {json| { "x" : 3 } |json}]) ->  t = "mk" [@@bs.val]
      |}
           in
           OUnit.assert_bool __LOC__ (Ext_string.is_empty should_err.stderr) );
         (* #1510 *)
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
       let should_fail = fun [@bs.this] (Some x) y u -> y + u
      |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "simple") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
       let should_fail = fun [@bs.this] (Some x as v) y u -> y + u
      |}
           in
           (* Ounit_cmd_util.debug_output should_err; *)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "simple") );
         (* __LOC__ >:: begin fun _ ->
            let should_err = bsc_check_eval {|
            external f : string -> unit -> unit = "x.y" [@@bs.send]
            |} in
            OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "Not a valid method name")
            end; *)
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      (* let rec must be rejected *)
type t10 = A of t10 [@@ocaml.unboxed];;
let rec x = A x;;
      |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr
                "This kind of expression is not allowed") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      type t = {x: int64} [@@unboxed];;
let rec x = {x = y} and y = 3L;;
      |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr
                "This kind of expression is not allowed") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      type r = A of r [@@unboxed];;
let rec y = A y;;
      |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr
                "This kind of expression is not allowed") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval {|
          external f : int = "%identity"
|}
           in
           OUnit.assert_bool __LOC__
             (not (Ext_string.is_empty should_err.stderr)) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
          external f : int -> int = "%identity"
|}
           in
           OUnit.assert_bool __LOC__ (Ext_string.is_empty should_err.stderr) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
          external f : int -> int -> int = "%identity"
|}
           in
           OUnit.assert_bool __LOC__
             (not (Ext_string.is_empty should_err.stderr)) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
          external f : (int -> int) -> int = "%identity"
|}
           in
           OUnit.assert_bool __LOC__ (Ext_string.is_empty should_err.stderr) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
          external f : int -> (int-> int) = "%identity"
|}
           in
           OUnit.assert_bool __LOC__
             (not (Ext_string.is_empty should_err.stderr)) );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
    external foo_bar :
    (_ [@bs.as "foo"]) ->
    string ->
    string = "bar"
  [@@bs.send]
    |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr
                "Ill defined attribute") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
      let bla4 foo x y = foo##(method1 x y [@bs])
    |}
           in
           (* Ounit_cmd_util.debug_output should_err ;  *)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "Unused") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
    external mk : int ->
  (
    [`a|`b]
     [@bs.string]
  ) = "mk" [@@bs.val]
    |}
           in
           (* Ounit_cmd_util.debug_output should_err ;  *)
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "Unused") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
    type -'a t = {k : 'a } [@@bs.deriving abstract]
    |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "contravariant") );
         ( __LOC__ >:: fun _ ->
           let should_err = bsc_check_eval {|
    let u = [||]
    |} in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr
                "cannot be generalized") );
         ( __LOC__ >:: fun _ ->
           let should_err =
             bsc_check_eval
               {|
external push : 'a array -> 'a -> unit = "push" [@@send]
let a = [||]
let () =
  push a 3 |. ignore ;
  push a "3" |. ignore
  |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring should_err.stderr "has type string")
         )
         (* __LOC__ >:: begin fun _ ->  *)
         (* let should_infer = perform_bsc [| "-i"; "-bs-eval"|] {| *)
            (*      let  f = fun [@bs] x -> let (a,b) = x in a + b  *)
            (* |}  in *)
         (* let infer_type  = bsc_eval (Printf.sprintf {| *)

            (*      let f : %s  = fun [@bs] x -> let (a,b) = x in a + b  *)
            (*  |} should_infer.stdout ) in *)
         (*  begin  *)
         (*    Ounit_cmd_util.debug_output should_infer ; *)
         (*    Ounit_cmd_util.debug_output infer_type ; *)
         (*    OUnit.assert_bool __LOC__  *)
         (*      ((Ext_string.is_empty infer_type.stderr)) *)
         (*  end *)
         (* end *);
       ]
