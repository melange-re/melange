let ( >:: ), ( >::: ) = OUnit.(( >:: ), ( >::: ))
let ( =~ ) = OUnit.assert_equal ~printer:Ext_obj.dump

let add_int_3 buf (x : int) =
  Buffer.add_int8 buf (x land 0xff);
  Buffer.add_int16_le buf (x lsr 8)

let suites =
  __FILE__
  >::: [
         ( __LOC__ >:: fun _ ->
           Ext_pervasives.nat_of_string_exn "003" =~ 3;
           (try
              Ext_pervasives.nat_of_string_exn "0a" |> ignore;
              2
            with _ -> -1)
           =~ -1 );
         ( __LOC__ >:: fun _ ->
           let cursor = ref 0 in
           let v = Ext_pervasives.parse_nat_of_string "123a" cursor in
           (v, !cursor) =~ (123, 3);
           cursor := 0;
           let v = Ext_pervasives.parse_nat_of_string "a" cursor in
           (v, !cursor) =~ (0, 0) );
         ( __LOC__ >:: fun _ ->
           for i = 0 to 0xff do
             let buf = Buffer.create 0 in
             Buffer.add_int8 buf i;
             let s = Buffer.contents buf in
             s =~ String.make 1 (Char.chr i);
             Ext_string.get_int_1 s 0 =~ i
           done );
         ( __LOC__ >:: fun _ ->
           for i = 0x100 to 0xff_ff do
             let buf = Buffer.create 0 in
             Buffer.add_int16_le buf i;
             let s = Buffer.contents buf in
             Ext_string.get_int_2 s 0 =~ i
           done;
           let buf = Buffer.create 0 in
           add_int_3 buf 0x1_ff_ff;
           Buffer.length buf =~ 3;
           Ext_string.get_int_3 (Buffer.contents buf) 0 =~ 0x1_ff_ff;
           let buf = Buffer.create 0 in
           Buffer.add_int32_le buf 0x1_ff_ff_ffl;
           Ext_string.get_int_4 (Buffer.contents buf) 0 =~ 0x1_ff_ff_ff );
         ( __LOC__ >:: fun _ ->
           String.length (Digest.to_hex (Digest.string "")) =~ 32 );
       ]
