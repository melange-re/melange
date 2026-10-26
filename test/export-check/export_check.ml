open Types

let module_ name md_type =
  Sig_module
    ( Ident.create_local name,
      Mp_present,
      {
        md_type;
        md_attributes = [];
        md_loc = Location.none;
        md_uid = Uid.internal_not_actually_unique;
      },
      Trec_not,
      Exported )

let parameter_signature id mtd_type =
  Mty_signature
    [
      Sig_modtype
        ( id,
          {
            mtd_type = Some mtd_type;
            mtd_attributes = [];
            mtd_loc = Location.none;
            mtd_uid = Uid.internal_not_actually_unique;
          },
          Hidden );
    ]

let rebound_parameter () =
  let parameter = Ident.create_local "X" in
  let signature = Ident.create_local "S" in
  let result = Mty_ident (Path.Pdot (Pident parameter, "S")) in
  let functor_ body =
    Mty_functor
      (Named (Some parameter, parameter_signature signature body), result)
  in
  let valid = Mty_signature [ module_ "Unique" (Mty_signature []) ] in
  let collision =
    Mty_signature
      [ module_ "Café" (Mty_signature []); module_ "Cafè" (Mty_signature []) ]
  in
  (* Reusing X.S under another parameter binding must not reuse validation
     of its old expansion. The hidden declaration becomes visible in the
     result, so checking only parameter declarations cannot catch this. *)
  let sg =
    [ module_ "First" (functor_ valid); module_ "Second" (functor_ collision) ]
  in
  match Js_export_check.signature ~top:true Env.empty sg with
  | () -> Alcotest.fail "rebound module type hid an export collision"
  | exception Location.Error _ -> ()

let () =
  Alcotest.run "Export validation"
    [ ("scope", [ ("rebound functor parameter", `Quick, rebound_parameter) ]) ]
