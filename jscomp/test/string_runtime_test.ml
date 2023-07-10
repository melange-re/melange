module S = Js__Caml_string
module B = Js__Caml_bytes
(** TODO: performance could be improved, however,
    this function is not in critical Path
 *)
let suites = Mt.[
  (* "string_of_char_array", (fun _ ->
    Eq(S.caml_string_of_char_array [|'a';'b';'c'|], "abc")
                          ); *)
  "caml_is_printable", (fun _ ->
    Eq(Test_char.caml_is_printable 'a', true)
                       );
  "caml_string_of_bytes", (fun  _ ->

    let f len =
      let b = Bytes.create len in
      Bytes.fill b 0 len 'c';
      (Bytes.to_string b,  (String.init len (fun _ -> 'c'))) in
    let (a,b) =
      List.split @@ List.map (fun x -> f x ) [1000;1024;1025;4095;4096;5000;10000] in
    Eq(a,b)
                          )

]

;;Mt.from_pair_suites __MODULE__ suites
