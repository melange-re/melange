(* This is used by js_main.ml *)

open Reason_migrate_parsetree

module From_current = Convert(OCaml_current)(OCaml_408)

let wrap f g fmt x = g fmt (f x)

let setup  = lazy begin
    let open From_current in
  Oprint.out_value := wrap copy_out_value Reason_oprint.print_out_value;
  Oprint.out_type := wrap copy_out_type Reason_oprint.print_out_type;
  Oprint.out_class_type := wrap copy_out_class_type Reason_oprint.print_out_class_type;
  Oprint.out_module_type := wrap copy_out_module_type Reason_oprint.print_out_module_type;
  Oprint.out_sig_item := wrap copy_out_sig_item Reason_oprint.print_out_sig_item;
  Oprint.out_signature := wrap (List.map copy_out_sig_item) Reason_oprint.print_out_signature;
  Oprint.out_type_extension := wrap copy_out_type_extension Reason_oprint.print_out_type_extension;
  Oprint.out_phrase := wrap copy_out_phrase Reason_oprint.print_out_phrase
end
