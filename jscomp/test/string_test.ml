

let ff x =
  let a =
    match x with
    | "0"
    |"1"
    |"2" -> 3
    | "3" -> 4
    | "4" -> 6
    | "7" -> 7
    | _ -> 8
  in a + 3


let gg x =
  let a =
    match x with
    | 0
    | 1
    | 2 -> 3
    | 3 -> 4
    | 4 -> 6
    | 8 -> 7
    | _ -> 8
  in a + 3

let rev_split_by_char c s =
  let rec loop i l =
    try
      let i' = String.index_from s i c  in
      let s' = String.sub s i (i' - i)  in
      loop (i'+1) (if s' = "" then l else s'::l)
    with Not_found -> (String.sub s i (String.length s - i) ):: l
  in
  loop 0 []

let xsplit ~delim s =
  let rec loop l = function
    | 0 -> l
    | i -> (
        match String.rindex_from s (i-1) delim  with
        | i' ->
          let l  = String.sub s (i'+1) (i - i'- 1) :: l in
          let l  = if i' = 0 then  ""::l else l in
          loop l i'
        | exception Not_found -> String.sub s 0 i :: l
      )
  in
  let len = String.length s in
  match len with
  | 0 -> []
  | _ -> loop [] len


external string_of_char : char -> string = "String.fromCharCode"

let string_of_chars  x = String.concat "" @@ List.map string_of_char  x



;; Mt.from_pair_suites __MODULE__ [
  "mutliple switch", (fun _ ->
      Eq(9, ff "4"));
  "int switch", (fun _ ->
      Eq(9, gg 4));
  "escape_normal", (fun _ -> Eq("haha", String.escaped "haha"));
  "escape_bytes", (fun _ -> Eq( Bytes.of_string "haha", Bytes.escaped (Bytes.of_string "haha")));
  (* FIXME it used char pattern match *)
  "escape_quote", (fun _ ->
      Eq ("\\\"\\\"", String.escaped {|""|}));
  "rev_split_by_char", (fun _ ->
      Eq ([""; "bbbb"; "bbbb"], rev_split_by_char 'a' "bbbbabbbba"));
  __LOC__, (fun _ ->
    Eq(["aaaa"], rev_split_by_char ',' "aaaa")
  )    ;
  "xsplit", (fun _ -> Eq(["a";"b";"c"], xsplit ~delim:'.' "a.b.c") );
  "split_empty", (fun _ -> Eq([], Ext_string_test.split "" '_') );
  "split_empty2", (fun _ ->
      Eq(["test_unsafe_obj_ffi_ppx.cmi"],
         Ext_string_test.split " test_unsafe_obj_ffi_ppx.cmi" ~keep_empty:false ' ') );
  "rfind", (fun _ -> Eq( 7, Ext_string_test.rfind "__index__js" ~sub:"__"));
  "rfind_2", (fun _ -> Eq( 0, Ext_string_test.rfind "__index_js" ~sub:"__"));
  "rfind_3", (fun _ -> Eq( -1, Ext_string_test.rfind "_index_js" ~sub:"__"));
  "find", (fun _ -> Eq( 0, Ext_string_test.find "__index__js" ~sub:"__"));
  "find_2", (fun _ -> Eq( 6, Ext_string_test.find "_index__js" ~sub:"__"));
  "find_3", (fun _ -> Eq( -1, Ext_string_test.find "_index_js" ~sub:"__"));
  "of_char", (fun _ -> Eq( string_of_char '0', String.make 1 '0'));
  "of_chars", (fun _ -> Eq( string_of_chars ['0' ;'1'; '2'], "012"));
  "sub_ranges", (fun _ ->
      Eq (["abc"; "a"; "b"; "bc"; ""; ""; ""],
          List.map (fun (ofs, len) -> String.sub "abc" ofs len)
            [0, 3; 0, 1; 1, 1; 1, 2; 0, 0; 1, 0; 3, 0]));
  "sub_empty", (fun _ -> Eq ("", String.sub "" 0 0));
  "sub_binary", (fun _ ->
      Eq ("\000\127\128\255", String.sub "x\000\127\128\255y" 1 4));
  "sub_utf16", (fun _ ->
      let s = {js|a😺b|js} in
      Eq ([{js|😺|js}; Js.String.fromCharCode 0xd83d;
           Js.String.fromCharCode 0xde3a; "b"],
          [String.sub s 1 2; String.sub s 1 1;
           String.sub s 2 1; String.sub s 3 1]));
  "sub_invalid_ranges", (fun _ ->
      Ok (List.for_all (fun (s, ofs, len) ->
        match String.sub s ofs len with
        | _ -> false
        | exception Invalid_argument msg -> msg = "String.sub / Bytes.sub")
        ["", 0, 1; "", 1, 0;
         "abc", -1, 1; "abc", 0, -1; "abc", 4, 0; "abc", 2, 2;
         "abc", max_int, 1; "abc", 1, max_int;
         "abc", max_int, max_int; "abc", min_int, 0; "abc", 0, min_int]));
  "split_on_char", (fun _ ->
      Eq ([[""]; ["abc"]; [""; ""]; [""; "a"; ""; "b"; ""]],
          List.map (String.split_on_char '\n') [""; "abc"; "\n"; "\na\n\nb\n"]));
  "hash", (fun _ -> Eq( String.hash "hello", 840920576))
]
