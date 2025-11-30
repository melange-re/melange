let test_js_id_name_of_hint_name () =
  let k = Modulename.js_id_name_of_hint_name in
  Alcotest.(check string) __LOC__ (k "xx") "Xx";
  Alcotest.(check string) __LOC__ (k "react-dom") "ReactDom";
  Alcotest.(check string) __LOC__ (k "a/b/react-dom") "ReactDom";
  Alcotest.(check string) __LOC__ (k "a/b") "B";
  Alcotest.(check string) __LOC__ (k "a/") "A/";
  (*TODO: warning?*)
  Alcotest.(check string) __LOC__ (k "#moduleid") "Moduleid";
  Alcotest.(check string) __LOC__ (k "@bundle") "Bundle";
  Alcotest.(check string) __LOC__ (k "xx#bc") "Xxbc";
  Alcotest.(check string) __LOC__ (k "hi@myproj") "Himyproj";
  Alcotest.(check string) __LOC__ (k "ab/c/xx.b.js") "XxBJs";
  (* improve it in the future *)
  Alcotest.(check string) __LOC__ (k "c/d/a--b") "AB";
  Alcotest.(check string) __LOC__ (k "c/d/ac--") "Ac"

let suite =
  [ ("js_id_name_of_hint_name", `Quick, test_js_id_name_of_hint_name) ]
