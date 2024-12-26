
let form_data_append () =
  let fd = Js.FormData.make () in
  Js.FormData.append ~name:"a" ~value:(`String "foo") fd;
  Js.FormData.append ~name:"b" ~value:(`String "bar") fd;
  Mt.Eq ((Js.FormData.get ~name:"a" fd |> Option.get |> Obj.magic), "foo")
;;

let form_data_not_found () =
  let fd = Js.FormData.make () in
  Mt.Eq (Js.FormData.get fd ~name:"doesn't exist", None)
;;

let form_data_append_blob () =
  let fd = Js.FormData.make () in
  let blob = Js.Blob.make (Js.Array.values [|"hello"|]) () in
  Js.FormData.appendBlob ~name:"b" ~value:(`Blob blob) ~filename:"foo.txt" fd;
  let got_blob: Js.Blob.t =
    Js.FormData.get ~name:"b" fd |> Option.get |> Obj.magic
  in
  Js.Blob.text got_blob |> Js.Promise.then_ (fun x ->
    Js.Promise.resolve (Mt.Eq (x, "hello"))
  )
;;

let form_data_append_file () =
  let fd = Js.FormData.make () in
  let file = Js.File.make (Js.Array.values [|"hello"|]) ~filename:"foo.txt" in
  Js.FormData.appendBlob ~name:"b" ~value:(`File file) ~filename:"foo.txt" fd;
  let got_file: Js.Blob.t =
    Js.FormData.get ~name:"b" fd |> Option.get |> Obj.magic
  in
  Js.Blob.text got_file |> Js.Promise.then_ (fun x ->
    Js.Promise.resolve (Mt.Eq (x, "hello"))
  )
;;

;; Mt.from_pair_suites __MODULE__ [
    "append", form_data_append;
    "not found", form_data_not_found
]

;;

Mt.from_promise_suites __MODULE__
  [
    ("append blob", form_data_append_blob ());
    ("append file", form_data_append_file ());
  ]



