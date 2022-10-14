let ( // ) = Filename.concat
let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal
let bsc_eval = Ounit_cmd_util.bsc_check_eval
let debug_output = Ounit_cmd_util.debug_output

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           let output =
             bsc_eval
               {|
external err :
   hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
   unit -> _ = "" [@@bs.obj]
        |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring output.stderr "hi_should_error") );
         ( __LOC__ >:: fun _ ->
           let output =
             bsc_eval
               {|
    external err :
   ?hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
   unit -> _ = "" [@@bs.obj]
        |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring output.stderr "hi_should_error") );
         ( __LOC__ >:: fun _ ->
           let output =
             bsc_eval
               {|
    external err :
   ?hi_should_error:([`a of int | `b of string ] [@bs.string]) ->
   unit -> unit = "err" [@@bs.val]
        |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring output.stderr "hi_should_error") );
         ( __LOC__ >:: fun _ ->
           (*
             Each [@bs.unwrap] variant constructor requires an argument
          *)
           let output =
             bsc_eval
               {|
              external err :
              ?hi_should_error:([`a of int | `b] [@bs.unwrap]) -> unit -> unit = "err" [@@bs.val]
            |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring output.stderr "unwrap") );
         ( __LOC__ >:: fun _ ->
           (*
             [@bs.unwrap] args are not supported in [@@bs.obj] functions
          *)
           let output =
             bsc_eval
               {|
              external err :
              ?hi_should_error:([`a of int] [@bs.unwrap]) -> unit -> _ = "" [@@bs.obj]
            |}
           in
           OUnit.assert_bool __LOC__
             (Ext_string.contain_substring output.stderr "hi_should_error") );
       ]
