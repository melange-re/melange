include struct
  include Astlib

  module Ast_406 = struct
    include Ast_406

    module Docstrings : sig
      (** {3 Docstrings} *)

      (** Documentation comments *)
      type docstring

      (** Create a docstring *)
      val docstring : string -> Location.t -> docstring

      (** Get the text of a docstring *)
      val docstring_body : docstring -> string

      (** Get the location of a docstring *)
      val docstring_loc : docstring -> Location.t

      (** {3 Items}

          The {!docs} type represents documentation attached to an item. *)

      type docs =
        { docs_pre: docstring option;
          docs_post: docstring option; }

      val empty_docs : docs

      val docs_attr : docstring -> Parsetree.attribute

      (** Convert item documentation to attributes and add them to an
          attribute list *)
      val add_docs_attrs : docs -> Parsetree.attributes -> Parsetree.attributes

      (** {3 Fields and constructors}

          The {!info} type represents documentation attached to a field or
          constructor. *)

      type info = docstring option

      val empty_info : info

      val info_attr : docstring -> Parsetree.attribute

      (** Convert field info to attributes and add them to an
          attribute list *)
      val add_info_attrs : info -> Parsetree.attributes -> Parsetree.attributes

      (** {3 Unattached comments}

          The {!text} type represents documentation which is not attached to
          anything. *)

      type text = docstring list

      val empty_text : text

      val text_attr : docstring -> Parsetree.attribute

      (** Convert text to attributes and add them to an attribute list *)
      val add_text_attrs : text -> Parsetree.attributes -> Parsetree.attributes

    end = struct
      open Location

      (* Docstrings *)

      type docstring =
        { ds_body: string;
          ds_loc: Location.t;
        }

      (* Docstring constructors and destructors *)

      let docstring body loc =
        let ds =
          { ds_body = body;
            ds_loc = loc;
          }
        in
        ds

      let docstring_body ds = ds.ds_body

      let docstring_loc ds = ds.ds_loc

      (* Docstrings attached to items *)

      type docs =
        { docs_pre: docstring option;
          docs_post: docstring option; }

      let empty_docs = { docs_pre = None; docs_post = None }

      let doc_loc = {txt = "ocaml.doc"; loc = Location.none}

      let docs_attr ds =
        let open Parsetree in
        let exp =
          { pexp_desc = Pexp_constant (Pconst_string(ds.ds_body, None));
            pexp_loc = ds.ds_loc;
            pexp_attributes = []; }
        in
        let item =
          { pstr_desc = Pstr_eval (exp, []); pstr_loc = exp.pexp_loc }
        in
          (doc_loc, PStr [item])

      let add_docs_attrs docs attrs =
        let attrs =
          match docs.docs_pre with
          | None | Some { ds_body=""; _ } -> attrs
          | Some ds -> docs_attr ds :: attrs
        in
        let attrs =
          match docs.docs_post with
          | None | Some { ds_body=""; _ } -> attrs
          | Some ds -> attrs @ [docs_attr ds]
        in
        attrs

      (* Docstrings attached to constructors or fields *)

      type info = docstring option

      let empty_info = None

      let info_attr = docs_attr

      let add_info_attrs info attrs =
        match info with
        | None | Some {ds_body=""; _} -> attrs
        | Some ds -> attrs @ [info_attr ds]

      (* Docstrings not attached to a specific item *)

      type text = docstring list

      let empty_text = []

      let text_loc = {txt = "ocaml.text"; loc = Location.none}

      let text_attr ds =
        let open Parsetree in
        let exp =
          { pexp_desc = Pexp_constant (Pconst_string(ds.ds_body, None));
            pexp_loc = ds.ds_loc;
            pexp_attributes = []; }
        in
        let item =
          { pstr_desc = Pstr_eval (exp, []); pstr_loc = exp.pexp_loc }
        in
          (text_loc, PStr [item])

      let add_text_attrs dsl attrs =
        let fdsl = List.filter (function {ds_body=""; _} -> false| _ ->true) dsl in
        (List.map text_attr fdsl) @ attrs

    end

    module Ast_helper : sig

      (** Helpers to produce Parsetree fragments *)

      open Asttypes
      open Docstrings
      open Parsetree

      type lid = Longident.t loc
      type str = string loc
      type loc = Location.t
      type attrs = attribute list

      (** {2 Default locations} *)

      val default_loc: loc ref
          (** Default value for all optional location arguments. *)

      val with_default_loc: loc -> (unit -> 'a) -> 'a
          (** Set the [default_loc] within the scope of the execution
              of the provided function. *)

      (** {2 Constants} *)

      module Const : sig
        val char : char -> constant
        val string : ?quotation_delimiter:string -> string -> constant
        val integer : ?suffix:char -> string -> constant
        val int : ?suffix:char -> int -> constant
        val int32 : ?suffix:char -> int32 -> constant
        val int64 : ?suffix:char -> int64 -> constant
        val nativeint : ?suffix:char -> nativeint -> constant
        val float : ?suffix:char -> string -> constant
      end

      (** {2 Core language} *)

      (** Type expressions *)
      module Typ :
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> core_type_desc -> core_type
          val attr: core_type -> attribute -> core_type

          val any: ?loc:loc -> ?attrs:attrs -> unit -> core_type
          val var: ?loc:loc -> ?attrs:attrs -> string -> core_type
          val arrow: ?loc:loc -> ?attrs:attrs -> arg_label -> core_type -> core_type
                     -> core_type
          val tuple: ?loc:loc -> ?attrs:attrs -> core_type list -> core_type
          val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> core_type
          val object_: ?loc:loc -> ?attrs:attrs -> object_field list
                         -> closed_flag -> core_type
          val class_: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> core_type
          val alias: ?loc:loc -> ?attrs:attrs -> core_type -> string -> core_type
          val variant: ?loc:loc -> ?attrs:attrs -> row_field list -> closed_flag
                       -> label list option -> core_type
          val poly: ?loc:loc -> ?attrs:attrs -> str list -> core_type -> core_type
          val package: ?loc:loc -> ?attrs:attrs -> lid -> (lid * core_type) list
                       -> core_type
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> core_type

          val force_poly: core_type -> core_type

          val varify_constructors: str list -> core_type -> core_type
          (** [varify_constructors newtypes te] is type expression [te], of which
              any of nullary type constructor [tc] is replaced by type variable of
              the same name, if [tc]'s name appears in [newtypes].
              Raise [Syntaxerr.Variable_in_scope] if any type variable inside [te]
              appears in [newtypes].
              @since 4.05
           *)
        end

      (** Patterns *)
      module Pat:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> pattern_desc -> pattern
          val attr:pattern -> attribute -> pattern

          val any: ?loc:loc -> ?attrs:attrs -> unit -> pattern
          val var: ?loc:loc -> ?attrs:attrs -> str -> pattern
          val alias: ?loc:loc -> ?attrs:attrs -> pattern -> str -> pattern
          val constant: ?loc:loc -> ?attrs:attrs -> constant -> pattern
          val interval: ?loc:loc -> ?attrs:attrs -> constant -> constant -> pattern
          val tuple: ?loc:loc -> ?attrs:attrs -> pattern list -> pattern
          val construct: ?loc:loc -> ?attrs:attrs -> lid -> pattern option -> pattern
          val variant: ?loc:loc -> ?attrs:attrs -> label -> pattern option -> pattern
          val record: ?loc:loc -> ?attrs:attrs -> (lid * pattern) list -> closed_flag
                      -> pattern
          val array: ?loc:loc -> ?attrs:attrs -> pattern list -> pattern
          val or_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern -> pattern
          val constraint_: ?loc:loc -> ?attrs:attrs -> pattern -> core_type -> pattern
          val type_: ?loc:loc -> ?attrs:attrs -> lid -> pattern
          val lazy_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern
          val unpack: ?loc:loc -> ?attrs:attrs -> str -> pattern
          val open_: ?loc:loc -> ?attrs:attrs  -> lid -> pattern -> pattern
          val exception_: ?loc:loc -> ?attrs:attrs -> pattern -> pattern
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> pattern
        end

      (** Expressions *)
      module Exp:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> expression_desc -> expression
          val attr: expression -> attribute -> expression

          val ident: ?loc:loc -> ?attrs:attrs -> lid -> expression
          val constant: ?loc:loc -> ?attrs:attrs -> constant -> expression
          val let_: ?loc:loc -> ?attrs:attrs -> rec_flag -> value_binding list
                    -> expression -> expression
          val fun_: ?loc:loc -> ?attrs:attrs -> arg_label -> expression option
                    -> pattern -> expression -> expression
          val function_: ?loc:loc -> ?attrs:attrs -> case list -> expression
          val apply: ?loc:loc -> ?attrs:attrs -> expression
                     -> (arg_label * expression) list -> expression
          val match_: ?loc:loc -> ?attrs:attrs -> expression -> case list
                      -> expression
          val try_: ?loc:loc -> ?attrs:attrs -> expression -> case list -> expression
          val tuple: ?loc:loc -> ?attrs:attrs -> expression list -> expression
          val construct: ?loc:loc -> ?attrs:attrs -> lid -> expression option
                         -> expression
          val variant: ?loc:loc -> ?attrs:attrs -> label -> expression option
                       -> expression
          val record: ?loc:loc -> ?attrs:attrs -> (lid * expression) list
                      -> expression option -> expression
          val field: ?loc:loc -> ?attrs:attrs -> expression -> lid -> expression
          val setfield: ?loc:loc -> ?attrs:attrs -> expression -> lid -> expression
                        -> expression
          val array: ?loc:loc -> ?attrs:attrs -> expression list -> expression
          val ifthenelse: ?loc:loc -> ?attrs:attrs -> expression -> expression
                          -> expression option -> expression
          val sequence: ?loc:loc -> ?attrs:attrs -> expression -> expression
                        -> expression
          val while_: ?loc:loc -> ?attrs:attrs -> expression -> expression
                      -> expression
          val for_: ?loc:loc -> ?attrs:attrs -> pattern -> expression -> expression
                    -> direction_flag -> expression -> expression
          val coerce: ?loc:loc -> ?attrs:attrs -> expression -> core_type option
                      -> core_type -> expression
          val constraint_: ?loc:loc -> ?attrs:attrs -> expression -> core_type
                           -> expression
          val send: ?loc:loc -> ?attrs:attrs -> expression -> str -> expression
          val new_: ?loc:loc -> ?attrs:attrs -> lid -> expression
          val setinstvar: ?loc:loc -> ?attrs:attrs -> str -> expression -> expression
          val override: ?loc:loc -> ?attrs:attrs -> (str * expression) list
                        -> expression
          val letmodule: ?loc:loc -> ?attrs:attrs -> str -> module_expr -> expression
                         -> expression
          val letexception:
            ?loc:loc -> ?attrs:attrs -> extension_constructor -> expression
            -> expression
          val assert_: ?loc:loc -> ?attrs:attrs -> expression -> expression
          val lazy_: ?loc:loc -> ?attrs:attrs -> expression -> expression
          val poly: ?loc:loc -> ?attrs:attrs -> expression -> core_type option
                    -> expression
          val object_: ?loc:loc -> ?attrs:attrs -> class_structure -> expression
          val newtype: ?loc:loc -> ?attrs:attrs -> str -> expression -> expression
          val pack: ?loc:loc -> ?attrs:attrs -> module_expr -> expression
          val open_: ?loc:loc -> ?attrs:attrs -> override_flag -> lid -> expression
                     -> expression
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> expression
          val unreachable: ?loc:loc -> ?attrs:attrs -> unit -> expression

          val case: pattern -> ?guard:expression -> expression -> case
        end

      (** Value declarations *)
      module Val:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs ->
            ?prim:string list -> str -> core_type -> value_description
        end

      (** Type declarations *)
      module Type:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            ?params:(core_type * variance) list ->
            ?cstrs:(core_type * core_type * loc) list ->
            ?kind:type_kind -> ?priv:private_flag -> ?manifest:core_type -> str ->
            type_declaration

          val constructor: ?loc:loc -> ?attrs:attrs -> ?info:info ->
            ?args:constructor_arguments -> ?res:core_type -> str ->
            constructor_declaration
          val field: ?loc:loc -> ?attrs:attrs -> ?info:info ->
            ?mut:mutable_flag -> str -> core_type -> label_declaration
        end

      (** Type extensions *)
      module Te:
        sig
          val mk: ?attrs:attrs -> ?docs:docs ->
            ?params:(core_type * variance) list -> ?priv:private_flag ->
            lid -> extension_constructor list -> type_extension

          val constructor: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
            str -> extension_constructor_kind -> extension_constructor

          val decl: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
            ?args:constructor_arguments -> ?res:core_type -> str ->
            extension_constructor
          val rebind: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?info:info ->
            str -> lid -> extension_constructor
        end

      (** {2 Module language} *)

      (** Module type expressions *)
      module Mty:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> module_type_desc -> module_type
          val attr: module_type -> attribute -> module_type

          val ident: ?loc:loc -> ?attrs:attrs -> lid -> module_type
          val alias: ?loc:loc -> ?attrs:attrs -> lid -> module_type
          val signature: ?loc:loc -> ?attrs:attrs -> signature -> module_type
          val functor_: ?loc:loc -> ?attrs:attrs ->
            str -> module_type option -> module_type -> module_type
          val with_: ?loc:loc -> ?attrs:attrs -> module_type ->
            with_constraint list -> module_type
          val typeof_: ?loc:loc -> ?attrs:attrs -> module_expr -> module_type
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> module_type
        end

      (** Module expressions *)
      module Mod:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> module_expr_desc -> module_expr
          val attr: module_expr -> attribute -> module_expr

          val ident: ?loc:loc -> ?attrs:attrs -> lid -> module_expr
          val structure: ?loc:loc -> ?attrs:attrs -> structure -> module_expr
          val functor_: ?loc:loc -> ?attrs:attrs ->
            str -> module_type option -> module_expr -> module_expr
          val apply: ?loc:loc -> ?attrs:attrs -> module_expr -> module_expr ->
            module_expr
          val constraint_: ?loc:loc -> ?attrs:attrs -> module_expr -> module_type ->
            module_expr
          val unpack: ?loc:loc -> ?attrs:attrs -> expression -> module_expr
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> module_expr
        end

      (** Signature items *)
      module Sig:
        sig
          val mk: ?loc:loc -> signature_item_desc -> signature_item

          val value: ?loc:loc -> value_description -> signature_item
          val type_: ?loc:loc -> rec_flag -> type_declaration list -> signature_item
          val type_extension: ?loc:loc -> type_extension -> signature_item
          val exception_: ?loc:loc -> extension_constructor -> signature_item
          val module_: ?loc:loc -> module_declaration -> signature_item
          val rec_module: ?loc:loc -> module_declaration list -> signature_item
          val modtype: ?loc:loc -> module_type_declaration -> signature_item
          val open_: ?loc:loc -> open_description -> signature_item
          val include_: ?loc:loc -> include_description -> signature_item
          val class_: ?loc:loc -> class_description list -> signature_item
          val class_type: ?loc:loc -> class_type_declaration list -> signature_item
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> signature_item
          val attribute: ?loc:loc -> attribute -> signature_item
          val text: text -> signature_item list
        end

      (** Structure items *)
      module Str:
        sig
          val mk: ?loc:loc -> structure_item_desc -> structure_item

          val eval: ?loc:loc -> ?attrs:attributes -> expression -> structure_item
          val value: ?loc:loc -> rec_flag -> value_binding list -> structure_item
          val primitive: ?loc:loc -> value_description -> structure_item
          val type_: ?loc:loc -> rec_flag -> type_declaration list -> structure_item
          val type_extension: ?loc:loc -> type_extension -> structure_item
          val exception_: ?loc:loc -> extension_constructor -> structure_item
          val module_: ?loc:loc -> module_binding -> structure_item
          val rec_module: ?loc:loc -> module_binding list -> structure_item
          val modtype: ?loc:loc -> module_type_declaration -> structure_item
          val open_: ?loc:loc -> open_description -> structure_item
          val class_: ?loc:loc -> class_declaration list -> structure_item
          val class_type: ?loc:loc -> class_type_declaration list -> structure_item
          val include_: ?loc:loc -> include_declaration -> structure_item
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> structure_item
          val attribute: ?loc:loc -> attribute -> structure_item
          val text: text -> structure_item list
        end

      (** Module declarations *)
      module Md:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            str -> module_type -> module_declaration
        end

      (** Module type declarations *)
      module Mtd:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            ?typ:module_type -> str -> module_type_declaration
        end

      (** Module bindings *)
      module Mb:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            str -> module_expr -> module_binding
        end

      (** Opens *)
      module Opn:
        sig
          val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs ->
            ?override:override_flag -> lid -> open_description
        end

      (** Includes *)
      module Incl:
        sig
          val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs -> 'a -> 'a include_infos
        end

      (** Value bindings *)
      module Vb:
        sig
          val mk: ?loc: loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            pattern -> expression -> value_binding
        end


      (** {2 Class language} *)

      (** Class type expressions *)
      module Cty:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> class_type_desc -> class_type
          val attr: class_type -> attribute -> class_type

          val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> class_type
          val signature: ?loc:loc -> ?attrs:attrs -> class_signature -> class_type
          val arrow: ?loc:loc -> ?attrs:attrs -> arg_label -> core_type ->
            class_type -> class_type
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_type
          val open_: ?loc:loc -> ?attrs:attrs -> override_flag -> lid -> class_type
                     -> class_type
        end

      (** Class type fields *)
      module Ctf:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs ->
            class_type_field_desc -> class_type_field
          val attr: class_type_field -> attribute -> class_type_field

          val inherit_: ?loc:loc -> ?attrs:attrs -> class_type -> class_type_field
          val val_: ?loc:loc -> ?attrs:attrs -> str -> mutable_flag ->
            virtual_flag -> core_type -> class_type_field
          val method_: ?loc:loc -> ?attrs:attrs -> str -> private_flag ->
            virtual_flag -> core_type -> class_type_field
          val constraint_: ?loc:loc -> ?attrs:attrs -> core_type -> core_type ->
            class_type_field
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_type_field
          val attribute: ?loc:loc -> attribute -> class_type_field
          val text: text -> class_type_field list
        end

      (** Class expressions *)
      module Cl:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> class_expr_desc -> class_expr
          val attr: class_expr -> attribute -> class_expr

          val constr: ?loc:loc -> ?attrs:attrs -> lid -> core_type list -> class_expr
          val structure: ?loc:loc -> ?attrs:attrs -> class_structure -> class_expr
          val fun_: ?loc:loc -> ?attrs:attrs -> arg_label -> expression option ->
            pattern -> class_expr -> class_expr
          val apply: ?loc:loc -> ?attrs:attrs -> class_expr ->
            (arg_label * expression) list -> class_expr
          val let_: ?loc:loc -> ?attrs:attrs -> rec_flag -> value_binding list ->
            class_expr -> class_expr
          val constraint_: ?loc:loc -> ?attrs:attrs -> class_expr -> class_type ->
            class_expr
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_expr
          val open_: ?loc:loc -> ?attrs:attrs -> override_flag -> lid -> class_expr
                     -> class_expr
        end

      (** Class fields *)
      module Cf:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> class_field_desc ->
            class_field
          val attr: class_field -> attribute -> class_field

          val inherit_: ?loc:loc -> ?attrs:attrs -> override_flag -> class_expr ->
            str option -> class_field
          val val_: ?loc:loc -> ?attrs:attrs -> str -> mutable_flag ->
            class_field_kind -> class_field
          val method_: ?loc:loc -> ?attrs:attrs -> str -> private_flag ->
            class_field_kind -> class_field
          val constraint_: ?loc:loc -> ?attrs:attrs -> core_type -> core_type ->
            class_field
          val initializer_: ?loc:loc -> ?attrs:attrs -> expression -> class_field
          val extension: ?loc:loc -> ?attrs:attrs -> extension -> class_field
          val attribute: ?loc:loc -> attribute -> class_field
          val text: text -> class_field list

          val virtual_: core_type -> class_field_kind
          val concrete: override_flag -> expression -> class_field_kind

        end

      (** Classes *)
      module Ci:
        sig
          val mk: ?loc:loc -> ?attrs:attrs -> ?docs:docs -> ?text:text ->
            ?virt:virtual_flag -> ?params:(core_type * variance) list ->
            str -> 'a -> 'a class_infos
        end

      (** Class signatures *)
      module Csig:
        sig
          val mk: core_type -> class_type_field list -> class_signature
        end

      (** Class structures *)
      module Cstr:
        sig
          val mk: pattern -> class_field list -> class_structure
        end

    end = struct
      (** Helpers to produce Parsetree fragments *)

      open Asttypes
      open Parsetree
      open Docstrings

      type lid = Longident.t loc
      type str = string loc
      type loc = Location.t
      type attrs = attribute list

      let default_loc = ref Location.none

      let with_default_loc l f =
        let old = !default_loc in
        default_loc := l;
        try let r = f () in default_loc := old; r
        with exn -> default_loc := old; raise exn

      module Const = struct
        let integer ?suffix i = Pconst_integer (i, suffix)
        let int ?suffix i = integer ?suffix (string_of_int i)
        let int32 ?(suffix='l') i = integer ~suffix (Int32.to_string i)
        let int64 ?(suffix='L') i = integer ~suffix (Int64.to_string i)
        let nativeint ?(suffix='n') i = integer ~suffix (Nativeint.to_string i)
        let float ?suffix f = Pconst_float (f, suffix)
        let char c = Pconst_char c
        let string ?quotation_delimiter s = Pconst_string (s, quotation_delimiter)
      end

      module Typ = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {ptyp_desc = d; ptyp_loc = loc; ptyp_attributes = attrs}
        let attr d a = {d with ptyp_attributes = d.ptyp_attributes @ [a]}

        let any ?loc ?attrs () = mk ?loc ?attrs Ptyp_any
        let var ?loc ?attrs a = mk ?loc ?attrs (Ptyp_var a)
        let arrow ?loc ?attrs a b c = mk ?loc ?attrs (Ptyp_arrow (a, b, c))
        let tuple ?loc ?attrs a = mk ?loc ?attrs (Ptyp_tuple a)
        let constr ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_constr (a, b))
        let object_ ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_object (a, b))
        let class_ ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_class (a, b))
        let alias ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_alias (a, b))
        let variant ?loc ?attrs a b c = mk ?loc ?attrs (Ptyp_variant (a, b, c))
        let poly ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_poly (a, b))
        let package ?loc ?attrs a b = mk ?loc ?attrs (Ptyp_package (a, b))
        let extension ?loc ?attrs a = mk ?loc ?attrs (Ptyp_extension a)

        let force_poly t =
          match t.ptyp_desc with
          | Ptyp_poly _ -> t
          | _ -> poly ~loc:t.ptyp_loc [] t (* -> ghost? *)

        let varify_constructors var_names t =
          let check_variable vl loc v =
            if List.mem v vl then
              raise Syntaxerr.(Error(Variable_in_scope(loc,v))) in
          let var_names = List.map (fun v -> v.txt) var_names in
          let rec loop t =
            let desc =
              match t.ptyp_desc with
              | Ptyp_any -> Ptyp_any
              | Ptyp_var x ->
                  check_variable var_names t.ptyp_loc x;
                  Ptyp_var x
              | Ptyp_arrow (label,core_type,core_type') ->
                  Ptyp_arrow(label, loop core_type, loop core_type')
              | Ptyp_tuple lst -> Ptyp_tuple (List.map loop lst)
              | Ptyp_constr( { txt = Longident.Lident s; _ }, [])
                when List.mem s var_names ->
                  Ptyp_var s
              | Ptyp_constr(longident, lst) ->
                  Ptyp_constr(longident, List.map loop lst)
              | Ptyp_object (lst, o) ->
                  Ptyp_object (List.map loop_object_field lst, o)
              | Ptyp_class (longident, lst) ->
                  Ptyp_class (longident, List.map loop lst)
              | Ptyp_alias(core_type, string) ->
                  check_variable var_names t.ptyp_loc string;
                  Ptyp_alias(loop core_type, string)
              | Ptyp_variant(row_field_list, flag, lbl_lst_option) ->
                  Ptyp_variant(List.map loop_row_field row_field_list,
                               flag, lbl_lst_option)
              | Ptyp_poly(string_lst, core_type) ->
                List.iter (fun v ->
                  check_variable var_names t.ptyp_loc v.txt) string_lst;
                  Ptyp_poly(string_lst, loop core_type)
              | Ptyp_package(longident,lst) ->
                  Ptyp_package(longident,List.map (fun (n,typ) -> (n,loop typ) ) lst)
              | Ptyp_extension (s, arg) ->
                  Ptyp_extension (s, arg)
            in
            {t with ptyp_desc = desc}
          and loop_row_field  =
            function
              | Rtag(label,attrs,flag,lst) ->
                  Rtag(label,attrs,flag,List.map loop lst)
              | Rinherit t ->
                  Rinherit (loop t)
          and loop_object_field =
            function
              | Otag(label, attrs, t) ->
                  Otag(label, attrs, loop t)
              | Oinherit t ->
                  Oinherit (loop t)
          in
          loop t

      end

      module Pat = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {ppat_desc = d; ppat_loc = loc; ppat_attributes = attrs}
        let attr d a = {d with ppat_attributes = d.ppat_attributes @ [a]}

        let any ?loc ?attrs () = mk ?loc ?attrs Ppat_any
        let var ?loc ?attrs a = mk ?loc ?attrs (Ppat_var a)
        let alias ?loc ?attrs a b = mk ?loc ?attrs (Ppat_alias (a, b))
        let constant ?loc ?attrs a = mk ?loc ?attrs (Ppat_constant a)
        let interval ?loc ?attrs a b = mk ?loc ?attrs (Ppat_interval (a, b))
        let tuple ?loc ?attrs a = mk ?loc ?attrs (Ppat_tuple a)
        let construct ?loc ?attrs a b = mk ?loc ?attrs (Ppat_construct (a, b))
        let variant ?loc ?attrs a b = mk ?loc ?attrs (Ppat_variant (a, b))
        let record ?loc ?attrs a b = mk ?loc ?attrs (Ppat_record (a, b))
        let array ?loc ?attrs a = mk ?loc ?attrs (Ppat_array a)
        let or_ ?loc ?attrs a b = mk ?loc ?attrs (Ppat_or (a, b))
        let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Ppat_constraint (a, b))
        let type_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_type a)
        let lazy_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_lazy a)
        let unpack ?loc ?attrs a = mk ?loc ?attrs (Ppat_unpack a)
        let open_ ?loc ?attrs a b = mk ?loc ?attrs (Ppat_open (a, b))
        let exception_ ?loc ?attrs a = mk ?loc ?attrs (Ppat_exception a)
        let extension ?loc ?attrs a = mk ?loc ?attrs (Ppat_extension a)
      end

      module Exp = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {pexp_desc = d; pexp_loc = loc; pexp_attributes = attrs}
        let attr d a = {d with pexp_attributes = d.pexp_attributes @ [a]}

        let ident ?loc ?attrs a = mk ?loc ?attrs (Pexp_ident a)
        let constant ?loc ?attrs a = mk ?loc ?attrs (Pexp_constant a)
        let let_ ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_let (a, b, c))
        let fun_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pexp_fun (a, b, c, d))
        let function_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_function a)
        let apply ?loc ?attrs a b = mk ?loc ?attrs (Pexp_apply (a, b))
        let match_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_match (a, b))
        let try_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_try (a, b))
        let tuple ?loc ?attrs a = mk ?loc ?attrs (Pexp_tuple a)
        let construct ?loc ?attrs a b = mk ?loc ?attrs (Pexp_construct (a, b))
        let variant ?loc ?attrs a b = mk ?loc ?attrs (Pexp_variant (a, b))
        let record ?loc ?attrs a b = mk ?loc ?attrs (Pexp_record (a, b))
        let field ?loc ?attrs a b = mk ?loc ?attrs (Pexp_field (a, b))
        let setfield ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_setfield (a, b, c))
        let array ?loc ?attrs a = mk ?loc ?attrs (Pexp_array a)
        let ifthenelse ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_ifthenelse (a, b, c))
        let sequence ?loc ?attrs a b = mk ?loc ?attrs (Pexp_sequence (a, b))
        let while_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_while (a, b))
        let for_ ?loc ?attrs a b c d e = mk ?loc ?attrs (Pexp_for (a, b, c, d, e))
        let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pexp_constraint (a, b))
        let coerce ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_coerce (a, b, c))
        let send ?loc ?attrs a b = mk ?loc ?attrs (Pexp_send (a, b))
        let new_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_new a)
        let setinstvar ?loc ?attrs a b = mk ?loc ?attrs (Pexp_setinstvar (a, b))
        let override ?loc ?attrs a = mk ?loc ?attrs (Pexp_override a)
        let letmodule ?loc ?attrs a b c= mk ?loc ?attrs (Pexp_letmodule (a, b, c))
        let letexception ?loc ?attrs a b = mk ?loc ?attrs (Pexp_letexception (a, b))
        let assert_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_assert a)
        let lazy_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_lazy a)
        let poly ?loc ?attrs a b = mk ?loc ?attrs (Pexp_poly (a, b))
        let object_ ?loc ?attrs a = mk ?loc ?attrs (Pexp_object a)
        let newtype ?loc ?attrs a b = mk ?loc ?attrs (Pexp_newtype (a, b))
        let pack ?loc ?attrs a = mk ?loc ?attrs (Pexp_pack a)
        let open_ ?loc ?attrs a b c = mk ?loc ?attrs (Pexp_open (a, b, c))
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pexp_extension a)
        let unreachable ?loc ?attrs () = mk ?loc ?attrs Pexp_unreachable

        let case lhs ?guard rhs =
          {
           pc_lhs = lhs;
           pc_guard = guard;
           pc_rhs = rhs;
          }
      end

      module Mty = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {pmty_desc = d; pmty_loc = loc; pmty_attributes = attrs}
        let attr d a = {d with pmty_attributes = d.pmty_attributes @ [a]}

        let ident ?loc ?attrs a = mk ?loc ?attrs (Pmty_ident a)
        let alias ?loc ?attrs a = mk ?loc ?attrs (Pmty_alias a)
        let signature ?loc ?attrs a = mk ?loc ?attrs (Pmty_signature a)
        let functor_ ?loc ?attrs a b c = mk ?loc ?attrs (Pmty_functor (a, b, c))
        let with_ ?loc ?attrs a b = mk ?loc ?attrs (Pmty_with (a, b))
        let typeof_ ?loc ?attrs a = mk ?loc ?attrs (Pmty_typeof a)
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pmty_extension a)
      end

      module Mod = struct
      let mk ?(loc = !default_loc) ?(attrs = []) d =
        {pmod_desc = d; pmod_loc = loc; pmod_attributes = attrs}
        let attr d a = {d with pmod_attributes = d.pmod_attributes @ [a]}

        let ident ?loc ?attrs x = mk ?loc ?attrs (Pmod_ident x)
        let structure ?loc ?attrs x = mk ?loc ?attrs (Pmod_structure x)
        let functor_ ?loc ?attrs arg arg_ty body =
          mk ?loc ?attrs (Pmod_functor (arg, arg_ty, body))
        let apply ?loc ?attrs m1 m2 = mk ?loc ?attrs (Pmod_apply (m1, m2))
        let constraint_ ?loc ?attrs m mty = mk ?loc ?attrs (Pmod_constraint (m, mty))
        let unpack ?loc ?attrs e = mk ?loc ?attrs (Pmod_unpack e)
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pmod_extension a)
      end

      module Sig = struct
        let mk ?(loc = !default_loc) d = {psig_desc = d; psig_loc = loc}

        let value ?loc a = mk ?loc (Psig_value a)
        let type_ ?loc rec_flag a = mk ?loc (Psig_type (rec_flag, a))
        let type_extension ?loc a = mk ?loc (Psig_typext a)
        let exception_ ?loc a = mk ?loc (Psig_exception a)
        let module_ ?loc a = mk ?loc (Psig_module a)
        let rec_module ?loc a = mk ?loc (Psig_recmodule a)
        let modtype ?loc a = mk ?loc (Psig_modtype a)
        let open_ ?loc a = mk ?loc (Psig_open a)
        let include_ ?loc a = mk ?loc (Psig_include a)
        let class_ ?loc a = mk ?loc (Psig_class a)
        let class_type ?loc a = mk ?loc (Psig_class_type a)
        let extension ?loc ?(attrs = []) a = mk ?loc (Psig_extension (a, attrs))
        let attribute ?loc a = mk ?loc (Psig_attribute a)
        let text txt =
          let f_txt = List.filter (fun ds -> docstring_body ds <> "") txt in
          List.map
            (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
            f_txt
      end

      module Str = struct
        let mk ?(loc = !default_loc) d = {pstr_desc = d; pstr_loc = loc}

        let eval ?loc ?(attrs = []) a = mk ?loc (Pstr_eval (a, attrs))
        let value ?loc a b = mk ?loc (Pstr_value (a, b))
        let primitive ?loc a = mk ?loc (Pstr_primitive a)
        let type_ ?loc rec_flag a = mk ?loc (Pstr_type (rec_flag, a))
        let type_extension ?loc a = mk ?loc (Pstr_typext a)
        let exception_ ?loc a = mk ?loc (Pstr_exception a)
        let module_ ?loc a = mk ?loc (Pstr_module a)
        let rec_module ?loc a = mk ?loc (Pstr_recmodule a)
        let modtype ?loc a = mk ?loc (Pstr_modtype a)
        let open_ ?loc a = mk ?loc (Pstr_open a)
        let class_ ?loc a = mk ?loc (Pstr_class a)
        let class_type ?loc a = mk ?loc (Pstr_class_type a)
        let include_ ?loc a = mk ?loc (Pstr_include a)
        let extension ?loc ?(attrs = []) a = mk ?loc (Pstr_extension (a, attrs))
        let attribute ?loc a = mk ?loc (Pstr_attribute a)
        let text txt =
          let f_txt = List.filter (fun ds -> docstring_body ds <> "") txt in
          List.map
            (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
            f_txt
      end

      module Cl = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {
           pcl_desc = d;
           pcl_loc = loc;
           pcl_attributes = attrs;
          }
        let attr d a = {d with pcl_attributes = d.pcl_attributes @ [a]}

        let constr ?loc ?attrs a b = mk ?loc ?attrs (Pcl_constr (a, b))
        let structure ?loc ?attrs a = mk ?loc ?attrs (Pcl_structure a)
        let fun_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pcl_fun (a, b, c, d))
        let apply ?loc ?attrs a b = mk ?loc ?attrs (Pcl_apply (a, b))
        let let_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcl_let (a, b, c))
        let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pcl_constraint (a, b))
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pcl_extension a)
        let open_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcl_open (a, b, c))
      end

      module Cty = struct
        let mk ?(loc = !default_loc) ?(attrs = []) d =
          {
           pcty_desc = d;
           pcty_loc = loc;
           pcty_attributes = attrs;
          }
        let attr d a = {d with pcty_attributes = d.pcty_attributes @ [a]}

        let constr ?loc ?attrs a b = mk ?loc ?attrs (Pcty_constr (a, b))
        let signature ?loc ?attrs a = mk ?loc ?attrs (Pcty_signature a)
        let arrow ?loc ?attrs a b c = mk ?loc ?attrs (Pcty_arrow (a, b, c))
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pcty_extension a)
        let open_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcty_open (a, b, c))
      end

      module Ctf = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
                 ?(docs = empty_docs) d =
          {
           pctf_desc = d;
           pctf_loc = loc;
           pctf_attributes = add_docs_attrs docs attrs;
          }

        let inherit_ ?loc ?attrs a = mk ?loc ?attrs (Pctf_inherit a)
        let val_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pctf_val (a, b, c, d))
        let method_ ?loc ?attrs a b c d = mk ?loc ?attrs (Pctf_method (a, b, c, d))
        let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pctf_constraint (a, b))
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pctf_extension a)
        let attribute ?loc a = mk ?loc (Pctf_attribute a)
        let text txt =
         let f_txt = List.filter (fun ds -> docstring_body ds <> "") txt in
           List.map
            (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
            f_txt

        let attr d a = {d with pctf_attributes = d.pctf_attributes @ [a]}

      end

      module Cf = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) d =
          {
           pcf_desc = d;
           pcf_loc = loc;
           pcf_attributes = add_docs_attrs docs attrs;
          }

        let inherit_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_inherit (a, b, c))
        let val_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_val (a, b, c))
        let method_ ?loc ?attrs a b c = mk ?loc ?attrs (Pcf_method (a, b, c))
        let constraint_ ?loc ?attrs a b = mk ?loc ?attrs (Pcf_constraint (a, b))
        let initializer_ ?loc ?attrs a = mk ?loc ?attrs (Pcf_initializer a)
        let extension ?loc ?attrs a = mk ?loc ?attrs (Pcf_extension a)
        let attribute ?loc a = mk ?loc (Pcf_attribute a)
        let text txt =
          let f_txt = List.filter (fun ds -> docstring_body ds <> "") txt in
          List.map
            (fun ds -> attribute ~loc:(docstring_loc ds) (text_attr ds))
            f_txt

        let virtual_ ct = Cfk_virtual ct
        let concrete o e = Cfk_concrete (o, e)

        let attr d a = {d with pcf_attributes = d.pcf_attributes @ [a]}

      end

      module Val = struct
        let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
              ?(prim = []) name typ =
          {
           pval_name = name;
           pval_type = typ;
           pval_attributes = add_docs_attrs docs attrs;
           pval_loc = loc;
           pval_prim = prim;
          }
      end

      module Md = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(text = []) name typ =
          {
           pmd_name = name;
           pmd_type = typ;
           pmd_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           pmd_loc = loc;
          }
      end

      module Mtd = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(text = []) ?typ name =
          {
           pmtd_name = name;
           pmtd_type = typ;
           pmtd_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           pmtd_loc = loc;
          }
      end

      module Mb = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(text = []) name expr =
          {
           pmb_name = name;
           pmb_expr = expr;
           pmb_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           pmb_loc = loc;
          }
      end

      module Opn = struct
        let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
              ?(override = Fresh) lid =
          {
           popen_lid = lid;
           popen_override = override;
           popen_loc = loc;
           popen_attributes = add_docs_attrs docs attrs;
          }
      end

      module Incl = struct
        let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs) mexpr =
          {
           pincl_mod = mexpr;
           pincl_loc = loc;
           pincl_attributes = add_docs_attrs docs attrs;
          }

      end

      module Vb = struct
        let mk ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
              ?(text = []) pat expr =
          {
           pvb_pat = pat;
           pvb_expr = expr;
           pvb_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           pvb_loc = loc;
          }
      end

      module Ci = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(text = [])
              ?(virt = Concrete) ?(params = []) name expr =
          {
           pci_virt = virt;
           pci_params = params;
           pci_name = name;
           pci_expr = expr;
           pci_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           pci_loc = loc;
          }
      end

      module Type = struct
        let mk ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(text = [])
            ?(params = [])
            ?(cstrs = [])
            ?(kind = Ptype_abstract)
            ?(priv = Public)
            ?manifest
            name =
          {
           ptype_name = name;
           ptype_params = params;
           ptype_cstrs = cstrs;
           ptype_kind = kind;
           ptype_private = priv;
           ptype_manifest = manifest;
           ptype_attributes =
             add_text_attrs text (add_docs_attrs docs attrs);
           ptype_loc = loc;
          }

        let constructor ?(loc = !default_loc) ?(attrs = []) ?(info = empty_info)
              ?(args = Pcstr_tuple []) ?res name =
          {
           pcd_name = name;
           pcd_args = args;
           pcd_res = res;
           pcd_loc = loc;
           pcd_attributes = add_info_attrs info attrs;
          }

        let field ?(loc = !default_loc) ?(attrs = []) ?(info = empty_info)
              ?(mut = Immutable) name typ =
          {
           pld_name = name;
           pld_mutable = mut;
           pld_type = typ;
           pld_loc = loc;
           pld_attributes = add_info_attrs info attrs;
          }

      end

      (** Type extensions *)
      module Te = struct
        let mk ?(attrs = []) ?(docs = empty_docs)
              ?(params = []) ?(priv = Public) path constructors =
          {
           ptyext_path = path;
           ptyext_params = params;
           ptyext_constructors = constructors;
           ptyext_private = priv;
           ptyext_attributes = add_docs_attrs docs attrs;
          }

        let constructor ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(info = empty_info) name kind =
          {
           pext_name = name;
           pext_kind = kind;
           pext_loc = loc;
           pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
          }

        let decl ?(loc = !default_loc) ?(attrs = []) ?(docs = empty_docs)
                   ?(info = empty_info) ?(args = Pcstr_tuple []) ?res name =
          {
           pext_name = name;
           pext_kind = Pext_decl(args, res);
           pext_loc = loc;
           pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
          }

        let rebind ?(loc = !default_loc) ?(attrs = [])
              ?(docs = empty_docs) ?(info = empty_info) name lid =
          {
           pext_name = name;
           pext_kind = Pext_rebind lid;
           pext_loc = loc;
           pext_attributes = add_docs_attrs docs (add_info_attrs info attrs);
          }

      end

      module Csig = struct
        let mk self fields =
          {
           pcsig_self = self;
           pcsig_fields = fields;
          }
      end

      module Cstr = struct
        let mk self fields =
          {
           pcstr_self = self;
           pcstr_fields = fields;
          }
      end

    end

    module Ast_mapper : sig
      (** The interface of a -ppx rewriter

        A -ppx rewriter is a program that accepts a serialized abstract syntax
        tree and outputs another, possibly modified, abstract syntax tree.
        This module encapsulates the interface between the compiler and
        the -ppx rewriters, handling such details as the serialization format,
        forwarding of command-line flags, and storing state.

        {!mapper} allows to implement AST rewriting using open recursion.
        A typical mapper would be based on {!default_mapper}, a deep
        identity mapper, and will fall back on it for handling the syntax it
        does not modify. For example:

        {[
      open Asttypes
      open Parsetree
      open Ast_mapper

      let test_mapper argv =
        { default_mapper with
          expr = fun mapper expr ->
            match expr with
            | { pexp_desc = Pexp_extension ({ txt = "test" }, PStr [])} ->
              Ast_helper.Exp.constant (Const_int 42)
            | other -> default_mapper.expr mapper other; }

      let () =
        register "ppx_test" test_mapper]}

        This -ppx rewriter, which replaces [[%test]] in expressions with
        the constant [42], can be compiled using
        [ocamlc -o ppx_test -I +compiler-libs ocamlcommon.cma ppx_test.ml].

        *)

      open Parsetree

      (** {2 A generic Parsetree mapper} *)

      type mapper (*IF_CURRENT = Ast_mapper.mapper*) = {
        attribute: mapper -> attribute -> attribute;
        attributes: mapper -> attribute list -> attribute list;
        case: mapper -> case -> case;
        cases: mapper -> case list -> case list;
        class_declaration: mapper -> class_declaration -> class_declaration;
        class_description: mapper -> class_description -> class_description;
        class_expr: mapper -> class_expr -> class_expr;
        class_field: mapper -> class_field -> class_field;
        class_signature: mapper -> class_signature -> class_signature;
        class_structure: mapper -> class_structure -> class_structure;
        class_type: mapper -> class_type -> class_type;
        class_type_declaration: mapper -> class_type_declaration
                                -> class_type_declaration;
        class_type_field: mapper -> class_type_field -> class_type_field;
        constructor_declaration: mapper -> constructor_declaration
                                 -> constructor_declaration;
        expr: mapper -> expression -> expression;
        extension: mapper -> extension -> extension;
        extension_constructor: mapper -> extension_constructor
                               -> extension_constructor;
        include_declaration: mapper -> include_declaration -> include_declaration;
        include_description: mapper -> include_description -> include_description;
        label_declaration: mapper -> label_declaration -> label_declaration;
        location: mapper -> Location.t -> Location.t;
        module_binding: mapper -> module_binding -> module_binding;
        module_declaration: mapper -> module_declaration -> module_declaration;
        module_expr: mapper -> module_expr -> module_expr;
        module_type: mapper -> module_type -> module_type;
        module_type_declaration: mapper -> module_type_declaration
                                 -> module_type_declaration;
        open_description: mapper -> open_description -> open_description;
        pat: mapper -> pattern -> pattern;
        payload: mapper -> payload -> payload;
        signature: mapper -> signature -> signature;
        signature_item: mapper -> signature_item -> signature_item;
        structure: mapper -> structure -> structure;
        structure_item: mapper -> structure_item -> structure_item;
        typ: mapper -> core_type -> core_type;
        type_declaration: mapper -> type_declaration -> type_declaration;
        type_extension: mapper -> type_extension -> type_extension;
        type_kind: mapper -> type_kind -> type_kind;
        value_binding: mapper -> value_binding -> value_binding;
        value_description: mapper -> value_description -> value_description;
        with_constraint: mapper -> with_constraint -> with_constraint;
      }
      (** A mapper record implements one "method" per syntactic category,
          using an open recursion style: each method takes as its first
          argument the mapper to be applied to children in the syntax
          tree. *)

      val default_mapper: mapper
      (** A default mapper, which implements a "deep identity" mapping. *)

      (** {2 Convenience functions to write mappers} *)

      val map_opt: ('a -> 'b) -> 'a option -> 'b option

      (* val extension_of_error: Locations.location_error -> extension *)
      (** Encode an error into an 'ocaml.error' extension node which can be
          inserted in a generated Parsetree.  The compiler will be
          responsible for reporting the error. *)

      val attribute_of_warning: Location.t -> string -> attribute
      (** Encode a warning message into an 'ocaml.ppwarning' attribute which can be
          inserted in a generated Parsetree.  The compiler will be
          responsible for reporting the warning. *)

      (* include Locations.Helpers_intf *)

    end = struct
      (* A generic Parsetree mapping class *)

      (*
      [@@@ocaml.warning "+9"]
        (* Ensure that record patterns don't miss any field. *)
      *)


      open Parsetree
      open Ast_helper
      open Location

      type mapper (*IF_CURRENT = Ast_mapper.mapper*) = {
        attribute: mapper -> attribute -> attribute;
        attributes: mapper -> attribute list -> attribute list;
        case: mapper -> case -> case;
        cases: mapper -> case list -> case list;
        class_declaration: mapper -> class_declaration -> class_declaration;
        class_description: mapper -> class_description -> class_description;
        class_expr: mapper -> class_expr -> class_expr;
        class_field: mapper -> class_field -> class_field;
        class_signature: mapper -> class_signature -> class_signature;
        class_structure: mapper -> class_structure -> class_structure;
        class_type: mapper -> class_type -> class_type;
        class_type_declaration: mapper -> class_type_declaration
                                -> class_type_declaration;
        class_type_field: mapper -> class_type_field -> class_type_field;
        constructor_declaration: mapper -> constructor_declaration
                                 -> constructor_declaration;
        expr: mapper -> expression -> expression;
        extension: mapper -> extension -> extension;
        extension_constructor: mapper -> extension_constructor
                               -> extension_constructor;
        include_declaration: mapper -> include_declaration -> include_declaration;
        include_description: mapper -> include_description -> include_description;
        label_declaration: mapper -> label_declaration -> label_declaration;
        location: mapper -> Location.t -> Location.t;
        module_binding: mapper -> module_binding -> module_binding;
        module_declaration: mapper -> module_declaration -> module_declaration;
        module_expr: mapper -> module_expr -> module_expr;
        module_type: mapper -> module_type -> module_type;
        module_type_declaration: mapper -> module_type_declaration
                                 -> module_type_declaration;
        open_description: mapper -> open_description -> open_description;
        pat: mapper -> pattern -> pattern;
        payload: mapper -> payload -> payload;
        signature: mapper -> signature -> signature;
        signature_item: mapper -> signature_item -> signature_item;
        structure: mapper -> structure -> structure;
        structure_item: mapper -> structure_item -> structure_item;
        typ: mapper -> core_type -> core_type;
        type_declaration: mapper -> type_declaration -> type_declaration;
        type_extension: mapper -> type_extension -> type_extension;
        type_kind: mapper -> type_kind -> type_kind;
        value_binding: mapper -> value_binding -> value_binding;
        value_description: mapper -> value_description -> value_description;
        with_constraint: mapper -> with_constraint -> with_constraint;
      }

      let map_fst f (x, y) = (f x, y)
      let map_snd f (x, y) = (x, f y)
      let map_tuple f1 f2 (x, y) = (f1 x, f2 y)
      let map_tuple3 f1 f2 f3 (x, y, z) = (f1 x, f2 y, f3 z)
      let map_opt f = function None -> None | Some x -> Some (f x)

      let map_loc sub {loc; txt} = {loc = sub.location sub loc; txt}

      module T = struct
        (* Type expressions for the core language *)

        let row_field sub = function
          | Rtag (l, attrs, b, tl) ->
              Rtag (map_loc sub l, sub.attributes sub attrs,
                    b, List.map (sub.typ sub) tl)
          | Rinherit t -> Rinherit (sub.typ sub t)

        let object_field sub = function
          | Otag (l, attrs, t) ->
              Otag (map_loc sub l, sub.attributes sub attrs, sub.typ sub t)
          | Oinherit t -> Oinherit (sub.typ sub t)

        let map sub {ptyp_desc = desc; ptyp_loc = loc; ptyp_attributes = attrs} =
          let open Typ in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Ptyp_any -> any ~loc ~attrs ()
          | Ptyp_var s -> var ~loc ~attrs s
          | Ptyp_arrow (lab, t1, t2) ->
              arrow ~loc ~attrs lab (sub.typ sub t1) (sub.typ sub t2)
          | Ptyp_tuple tyl -> tuple ~loc ~attrs (List.map (sub.typ sub) tyl)
          | Ptyp_constr (lid, tl) ->
              constr ~loc ~attrs (map_loc sub lid) (List.map (sub.typ sub) tl)
          | Ptyp_object (l, o) ->
              object_ ~loc ~attrs (List.map (object_field sub) l) o
          | Ptyp_class (lid, tl) ->
              class_ ~loc ~attrs (map_loc sub lid) (List.map (sub.typ sub) tl)
          | Ptyp_alias (t, s) -> alias ~loc ~attrs (sub.typ sub t) s
          | Ptyp_variant (rl, b, ll) ->
              variant ~loc ~attrs (List.map (row_field sub) rl) b ll
          | Ptyp_poly (sl, t) -> poly ~loc ~attrs
                                   (List.map (map_loc sub) sl) (sub.typ sub t)
          | Ptyp_package (lid, l) ->
              package ~loc ~attrs (map_loc sub lid)
                (List.map (map_tuple (map_loc sub) (sub.typ sub)) l)
          | Ptyp_extension x -> extension ~loc ~attrs (sub.extension sub x)

        let map_type_declaration sub
            {ptype_name; ptype_params; ptype_cstrs;
             ptype_kind;
             ptype_private;
             ptype_manifest;
             ptype_attributes;
             ptype_loc} =
          Type.mk (map_loc sub ptype_name)
            ~params:(List.map (map_fst (sub.typ sub)) ptype_params)
            ~priv:ptype_private
            ~cstrs:(List.map
                      (map_tuple3 (sub.typ sub) (sub.typ sub) (sub.location sub))
                      ptype_cstrs)
            ~kind:(sub.type_kind sub ptype_kind)
            ?manifest:(map_opt (sub.typ sub) ptype_manifest)
            ~loc:(sub.location sub ptype_loc)
            ~attrs:(sub.attributes sub ptype_attributes)

        let map_type_kind sub = function
          | Ptype_abstract -> Ptype_abstract
          | Ptype_variant l ->
              Ptype_variant (List.map (sub.constructor_declaration sub) l)
          | Ptype_record l -> Ptype_record (List.map (sub.label_declaration sub) l)
          | Ptype_open -> Ptype_open

        let map_constructor_arguments sub = function
          | Pcstr_tuple l -> Pcstr_tuple (List.map (sub.typ sub) l)
          | Pcstr_record l ->
              Pcstr_record (List.map (sub.label_declaration sub) l)

        let map_type_extension sub
            {ptyext_path; ptyext_params;
             ptyext_constructors;
             ptyext_private;
             ptyext_attributes} =
          Te.mk
            (map_loc sub ptyext_path)
            (List.map (sub.extension_constructor sub) ptyext_constructors)
            ~params:(List.map (map_fst (sub.typ sub)) ptyext_params)
            ~priv:ptyext_private
            ~attrs:(sub.attributes sub ptyext_attributes)

        let map_extension_constructor_kind sub = function
            Pext_decl(ctl, cto) ->
              Pext_decl(map_constructor_arguments sub ctl, map_opt (sub.typ sub) cto)
          | Pext_rebind li ->
              Pext_rebind (map_loc sub li)

        let map_extension_constructor sub
            {pext_name;
             pext_kind;
             pext_loc;
             pext_attributes} =
          Te.constructor
            (map_loc sub pext_name)
            (map_extension_constructor_kind sub pext_kind)
            ~loc:(sub.location sub pext_loc)
            ~attrs:(sub.attributes sub pext_attributes)

      end

      module CT = struct
        (* Type expressions for the class language *)

        let map sub {pcty_loc = loc; pcty_desc = desc; pcty_attributes = attrs} =
          let open Cty in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pcty_constr (lid, tys) ->
              constr ~loc ~attrs (map_loc sub lid) (List.map (sub.typ sub) tys)
          | Pcty_signature x -> signature ~loc ~attrs (sub.class_signature sub x)
          | Pcty_arrow (lab, t, ct) ->
              arrow ~loc ~attrs lab (sub.typ sub t) (sub.class_type sub ct)
          | Pcty_extension x -> extension ~loc ~attrs (sub.extension sub x)
          | Pcty_open (ovf, lid, ct) ->
              open_ ~loc ~attrs ovf (map_loc sub lid) (sub.class_type sub ct)

        let map_field sub {pctf_desc = desc; pctf_loc = loc; pctf_attributes = attrs}
          =
          let open Ctf in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pctf_inherit ct -> inherit_ ~loc ~attrs (sub.class_type sub ct)
          | Pctf_val (s, m, v, t) ->
              val_ ~loc ~attrs (map_loc sub s) m v (sub.typ sub t)
          | Pctf_method (s, p, v, t) ->
              method_ ~loc ~attrs (map_loc sub s) p v (sub.typ sub t)
          | Pctf_constraint (t1, t2) ->
              constraint_ ~loc ~attrs (sub.typ sub t1) (sub.typ sub t2)
          | Pctf_attribute x -> attribute ~loc (sub.attribute sub x)
          | Pctf_extension x -> extension ~loc ~attrs (sub.extension sub x)

        let map_signature sub {pcsig_self; pcsig_fields} =
          Csig.mk
            (sub.typ sub pcsig_self)
            (List.map (sub.class_type_field sub) pcsig_fields)
      end

      module MT = struct
        (* Type expressions for the module language *)

        let map sub {pmty_desc = desc; pmty_loc = loc; pmty_attributes = attrs} =
          let open Mty in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pmty_ident s -> ident ~loc ~attrs (map_loc sub s)
          | Pmty_alias s -> alias ~loc ~attrs (map_loc sub s)
          | Pmty_signature sg -> signature ~loc ~attrs (sub.signature sub sg)
          | Pmty_functor (s, mt1, mt2) ->
              functor_ ~loc ~attrs (map_loc sub s)
                (Option.map (sub.module_type sub) mt1)
                (sub.module_type sub mt2)
          | Pmty_with (mt, l) ->
              with_ ~loc ~attrs (sub.module_type sub mt)
                (List.map (sub.with_constraint sub) l)
          | Pmty_typeof me -> typeof_ ~loc ~attrs (sub.module_expr sub me)
          | Pmty_extension x -> extension ~loc ~attrs (sub.extension sub x)

        let map_with_constraint sub = function
          | Pwith_type (lid, d) ->
              Pwith_type (map_loc sub lid, sub.type_declaration sub d)
          | Pwith_module (lid, lid2) ->
              Pwith_module (map_loc sub lid, map_loc sub lid2)
          | Pwith_typesubst (lid, d) ->
              Pwith_typesubst (map_loc sub lid, sub.type_declaration sub d)
          | Pwith_modsubst (s, lid) ->
              Pwith_modsubst (map_loc sub s, map_loc sub lid)

        let map_signature_item sub {psig_desc = desc; psig_loc = loc} =
          let open Sig in
          let loc = sub.location sub loc in
          match desc with
          | Psig_value vd -> value ~loc (sub.value_description sub vd)
          | Psig_type (rf, l) -> type_ ~loc rf (List.map (sub.type_declaration sub) l)
          | Psig_typext te -> type_extension ~loc (sub.type_extension sub te)
          | Psig_exception ed -> exception_ ~loc (sub.extension_constructor sub ed)
          | Psig_module x -> module_ ~loc (sub.module_declaration sub x)
          | Psig_recmodule l ->
              rec_module ~loc (List.map (sub.module_declaration sub) l)
          | Psig_modtype x -> modtype ~loc (sub.module_type_declaration sub x)
          | Psig_open x -> open_ ~loc (sub.open_description sub x)
          | Psig_include x -> include_ ~loc (sub.include_description sub x)
          | Psig_class l -> class_ ~loc (List.map (sub.class_description sub) l)
          | Psig_class_type l ->
              class_type ~loc (List.map (sub.class_type_declaration sub) l)
          | Psig_extension (x, attrs) ->
              extension ~loc (sub.extension sub x) ~attrs:(sub.attributes sub attrs)
          | Psig_attribute x -> attribute ~loc (sub.attribute sub x)
      end


      module M = struct
        (* Value expressions for the module language *)

        let map sub {pmod_loc = loc; pmod_desc = desc; pmod_attributes = attrs} =
          let open Mod in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pmod_ident x -> ident ~loc ~attrs (map_loc sub x)
          | Pmod_structure str -> structure ~loc ~attrs (sub.structure sub str)
          | Pmod_functor (arg, arg_ty, body) ->
              functor_ ~loc ~attrs (map_loc sub arg)
                (Option.map (sub.module_type sub) arg_ty)
                (sub.module_expr sub body)
          | Pmod_apply (m1, m2) ->
              apply ~loc ~attrs (sub.module_expr sub m1) (sub.module_expr sub m2)
          | Pmod_constraint (m, mty) ->
              constraint_ ~loc ~attrs (sub.module_expr sub m)
                          (sub.module_type sub mty)
          | Pmod_unpack e -> unpack ~loc ~attrs (sub.expr sub e)
          | Pmod_extension x -> extension ~loc ~attrs (sub.extension sub x)

        let map_structure_item sub {pstr_loc = loc; pstr_desc = desc} =
          let open Str in
          let loc = sub.location sub loc in
          match desc with
          | Pstr_eval (x, attrs) ->
              eval ~loc ~attrs:(sub.attributes sub attrs) (sub.expr sub x)
          | Pstr_value (r, vbs) -> value ~loc r (List.map (sub.value_binding sub) vbs)
          | Pstr_primitive vd -> primitive ~loc (sub.value_description sub vd)
          | Pstr_type (rf, l) -> type_ ~loc rf (List.map (sub.type_declaration sub) l)
          | Pstr_typext te -> type_extension ~loc (sub.type_extension sub te)
          | Pstr_exception ed -> exception_ ~loc (sub.extension_constructor sub ed)
          | Pstr_module x -> module_ ~loc (sub.module_binding sub x)
          | Pstr_recmodule l -> rec_module ~loc (List.map (sub.module_binding sub) l)
          | Pstr_modtype x -> modtype ~loc (sub.module_type_declaration sub x)
          | Pstr_open x -> open_ ~loc (sub.open_description sub x)
          | Pstr_class l -> class_ ~loc (List.map (sub.class_declaration sub) l)
          | Pstr_class_type l ->
              class_type ~loc (List.map (sub.class_type_declaration sub) l)
          | Pstr_include x -> include_ ~loc (sub.include_declaration sub x)
          | Pstr_extension (x, attrs) ->
              extension ~loc (sub.extension sub x) ~attrs:(sub.attributes sub attrs)
          | Pstr_attribute x -> attribute ~loc (sub.attribute sub x)
      end

      module E = struct
        (* Value expressions for the core language *)

        let map sub {pexp_loc = loc; pexp_desc = desc; pexp_attributes = attrs} =
          let open Exp in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pexp_ident x -> ident ~loc ~attrs (map_loc sub x)
          | Pexp_constant x -> constant ~loc ~attrs x
          | Pexp_let (r, vbs, e) ->
              let_ ~loc ~attrs r (List.map (sub.value_binding sub) vbs)
                (sub.expr sub e)
          | Pexp_fun (lab, def, p, e) ->
              fun_ ~loc ~attrs lab (map_opt (sub.expr sub) def) (sub.pat sub p)
                (sub.expr sub e)
          | Pexp_function pel -> function_ ~loc ~attrs (sub.cases sub pel)
          | Pexp_apply (e, l) ->
              apply ~loc ~attrs (sub.expr sub e) (List.map (map_snd (sub.expr sub)) l)
          | Pexp_match (e, pel) ->
              match_ ~loc ~attrs (sub.expr sub e) (sub.cases sub pel)
          | Pexp_try (e, pel) -> try_ ~loc ~attrs (sub.expr sub e) (sub.cases sub pel)
          | Pexp_tuple el -> tuple ~loc ~attrs (List.map (sub.expr sub) el)
          | Pexp_construct (lid, arg) ->
              construct ~loc ~attrs (map_loc sub lid) (map_opt (sub.expr sub) arg)
          | Pexp_variant (lab, eo) ->
              variant ~loc ~attrs lab (map_opt (sub.expr sub) eo)
          | Pexp_record (l, eo) ->
              record ~loc ~attrs (List.map (map_tuple (map_loc sub) (sub.expr sub)) l)
                (map_opt (sub.expr sub) eo)
          | Pexp_field (e, lid) ->
              field ~loc ~attrs (sub.expr sub e) (map_loc sub lid)
          | Pexp_setfield (e1, lid, e2) ->
              setfield ~loc ~attrs (sub.expr sub e1) (map_loc sub lid)
                (sub.expr sub e2)
          | Pexp_array el -> array ~loc ~attrs (List.map (sub.expr sub) el)
          | Pexp_ifthenelse (e1, e2, e3) ->
              ifthenelse ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
                (map_opt (sub.expr sub) e3)
          | Pexp_sequence (e1, e2) ->
              sequence ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
          | Pexp_while (e1, e2) ->
              while_ ~loc ~attrs (sub.expr sub e1) (sub.expr sub e2)
          | Pexp_for (p, e1, e2, d, e3) ->
              for_ ~loc ~attrs (sub.pat sub p) (sub.expr sub e1) (sub.expr sub e2) d
                (sub.expr sub e3)
          | Pexp_coerce (e, t1, t2) ->
              coerce ~loc ~attrs (sub.expr sub e) (map_opt (sub.typ sub) t1)
                (sub.typ sub t2)
          | Pexp_constraint (e, t) ->
              constraint_ ~loc ~attrs (sub.expr sub e) (sub.typ sub t)
          | Pexp_send (e, s) ->
              send ~loc ~attrs (sub.expr sub e) (map_loc sub s)
          | Pexp_new lid -> new_ ~loc ~attrs (map_loc sub lid)
          | Pexp_setinstvar (s, e) ->
              setinstvar ~loc ~attrs (map_loc sub s) (sub.expr sub e)
          | Pexp_override sel ->
              override ~loc ~attrs
                (List.map (map_tuple (map_loc sub) (sub.expr sub)) sel)
          | Pexp_letmodule (s, me, e) ->
              letmodule ~loc ~attrs (map_loc sub s) (sub.module_expr sub me)
                (sub.expr sub e)
          | Pexp_letexception (cd, e) ->
              letexception ~loc ~attrs
                (sub.extension_constructor sub cd)
                (sub.expr sub e)
          | Pexp_assert e -> assert_ ~loc ~attrs (sub.expr sub e)
          | Pexp_lazy e -> lazy_ ~loc ~attrs (sub.expr sub e)
          | Pexp_poly (e, t) ->
              poly ~loc ~attrs (sub.expr sub e) (map_opt (sub.typ sub) t)
          | Pexp_object cls -> object_ ~loc ~attrs (sub.class_structure sub cls)
          | Pexp_newtype (s, e) ->
              newtype ~loc ~attrs (map_loc sub s) (sub.expr sub e)
          | Pexp_pack me -> pack ~loc ~attrs (sub.module_expr sub me)
          | Pexp_open (ovf, lid, e) ->
              open_ ~loc ~attrs ovf (map_loc sub lid) (sub.expr sub e)
          | Pexp_extension x -> extension ~loc ~attrs (sub.extension sub x)
          | Pexp_unreachable -> unreachable ~loc ~attrs ()
      end

      module P = struct
        (* Patterns *)

        let map sub {ppat_desc = desc; ppat_loc = loc; ppat_attributes = attrs} =
          let open Pat in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Ppat_any -> any ~loc ~attrs ()
          | Ppat_var s -> var ~loc ~attrs (map_loc sub s)
          | Ppat_alias (p, s) -> alias ~loc ~attrs (sub.pat sub p) (map_loc sub s)
          | Ppat_constant c -> constant ~loc ~attrs c
          | Ppat_interval (c1, c2) -> interval ~loc ~attrs c1 c2
          | Ppat_tuple pl -> tuple ~loc ~attrs (List.map (sub.pat sub) pl)
          | Ppat_construct (l, p) ->
              construct ~loc ~attrs (map_loc sub l) (map_opt (sub.pat sub) p)
          | Ppat_variant (l, p) -> variant ~loc ~attrs l (map_opt (sub.pat sub) p)
          | Ppat_record (lpl, cf) ->
              record ~loc ~attrs
                     (List.map (map_tuple (map_loc sub) (sub.pat sub)) lpl) cf
          | Ppat_array pl -> array ~loc ~attrs (List.map (sub.pat sub) pl)
          | Ppat_or (p1, p2) -> or_ ~loc ~attrs (sub.pat sub p1) (sub.pat sub p2)
          | Ppat_constraint (p, t) ->
              constraint_ ~loc ~attrs (sub.pat sub p) (sub.typ sub t)
          | Ppat_type s -> type_ ~loc ~attrs (map_loc sub s)
          | Ppat_lazy p -> lazy_ ~loc ~attrs (sub.pat sub p)
          | Ppat_unpack s -> unpack ~loc ~attrs (map_loc sub s)
          | Ppat_open (lid,p) -> open_ ~loc ~attrs (map_loc sub lid) (sub.pat sub p)
          | Ppat_exception p -> exception_ ~loc ~attrs (sub.pat sub p)
          | Ppat_extension x -> extension ~loc ~attrs (sub.extension sub x)
      end

      module CE = struct
        (* Value expressions for the class language *)

        let map sub {pcl_loc = loc; pcl_desc = desc; pcl_attributes = attrs} =
          let open Cl in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pcl_constr (lid, tys) ->
              constr ~loc ~attrs (map_loc sub lid) (List.map (sub.typ sub) tys)
          | Pcl_structure s ->
              structure ~loc ~attrs (sub.class_structure sub s)
          | Pcl_fun (lab, e, p, ce) ->
              fun_ ~loc ~attrs lab
                (map_opt (sub.expr sub) e)
                (sub.pat sub p)
                (sub.class_expr sub ce)
          | Pcl_apply (ce, l) ->
              apply ~loc ~attrs (sub.class_expr sub ce)
                (List.map (map_snd (sub.expr sub)) l)
          | Pcl_let (r, vbs, ce) ->
              let_ ~loc ~attrs r (List.map (sub.value_binding sub) vbs)
                (sub.class_expr sub ce)
          | Pcl_constraint (ce, ct) ->
              constraint_ ~loc ~attrs (sub.class_expr sub ce) (sub.class_type sub ct)
          | Pcl_extension x -> extension ~loc ~attrs (sub.extension sub x)
          | Pcl_open (ovf, lid, ce) ->
              open_ ~loc ~attrs ovf (map_loc sub lid) (sub.class_expr sub ce)

        let map_kind sub = function
          | Cfk_concrete (o, e) -> Cfk_concrete (o, sub.expr sub e)
          | Cfk_virtual t -> Cfk_virtual (sub.typ sub t)

        let map_field sub {pcf_desc = desc; pcf_loc = loc; pcf_attributes = attrs} =
          let open Cf in
          let loc = sub.location sub loc in
          let attrs = sub.attributes sub attrs in
          match desc with
          | Pcf_inherit (o, ce, s) ->
              inherit_ ~loc ~attrs o (sub.class_expr sub ce)
                (map_opt (map_loc sub) s)
          | Pcf_val (s, m, k) -> val_ ~loc ~attrs (map_loc sub s) m (map_kind sub k)
          | Pcf_method (s, p, k) ->
              method_ ~loc ~attrs (map_loc sub s) p (map_kind sub k)
          | Pcf_constraint (t1, t2) ->
              constraint_ ~loc ~attrs (sub.typ sub t1) (sub.typ sub t2)
          | Pcf_initializer e -> initializer_ ~loc ~attrs (sub.expr sub e)
          | Pcf_attribute x -> attribute ~loc (sub.attribute sub x)
          | Pcf_extension x -> extension ~loc ~attrs (sub.extension sub x)

        let map_structure sub {pcstr_self; pcstr_fields} =
          {
            pcstr_self = sub.pat sub pcstr_self;
            pcstr_fields = List.map (sub.class_field sub) pcstr_fields;
          }

        let class_infos sub f {pci_virt; pci_params = pl; pci_name; pci_expr;
                               pci_loc; pci_attributes} =
          Ci.mk
           ~virt:pci_virt
           ~params:(List.map (map_fst (sub.typ sub)) pl)
            (map_loc sub pci_name)
            (f pci_expr)
            ~loc:(sub.location sub pci_loc)
            ~attrs:(sub.attributes sub pci_attributes)
      end

      (* Now, a generic AST mapper, to be extended to cover all kinds and
         cases of the OCaml grammar.  The default behavior of the mapper is
         the identity. *)

      let default_mapper =
        {
          structure = (fun this l -> List.map (this.structure_item this) l);
          structure_item = M.map_structure_item;
          module_expr = M.map;
          signature = (fun this l -> List.map (this.signature_item this) l);
          signature_item = MT.map_signature_item;
          module_type = MT.map;
          with_constraint = MT.map_with_constraint;
          class_declaration =
            (fun this -> CE.class_infos this (this.class_expr this));
          class_expr = CE.map;
          class_field = CE.map_field;
          class_structure = CE.map_structure;
          class_type = CT.map;
          class_type_field = CT.map_field;
          class_signature = CT.map_signature;
          class_type_declaration =
            (fun this -> CE.class_infos this (this.class_type this));
          class_description =
            (fun this -> CE.class_infos this (this.class_type this));
          type_declaration = T.map_type_declaration;
          type_kind = T.map_type_kind;
          typ = T.map;
          type_extension = T.map_type_extension;
          extension_constructor = T.map_extension_constructor;
          value_description =
            (fun this {pval_name; pval_type; pval_prim; pval_loc;
                       pval_attributes} ->
              Val.mk
                (map_loc this pval_name)
                (this.typ this pval_type)
                ~attrs:(this.attributes this pval_attributes)
                ~loc:(this.location this pval_loc)
                ~prim:pval_prim
            );

          pat = P.map;
          expr = E.map;

          module_declaration =
            (fun this {pmd_name; pmd_type; pmd_attributes; pmd_loc} ->
               Md.mk
                 (map_loc this pmd_name)
                 (this.module_type this pmd_type)
                 ~attrs:(this.attributes this pmd_attributes)
                 ~loc:(this.location this pmd_loc)
            );

          module_type_declaration =
            (fun this {pmtd_name; pmtd_type; pmtd_attributes; pmtd_loc} ->
               Mtd.mk
                 (map_loc this pmtd_name)
                 ?typ:(map_opt (this.module_type this) pmtd_type)
                 ~attrs:(this.attributes this pmtd_attributes)
                 ~loc:(this.location this pmtd_loc)
            );

          module_binding =
            (fun this {pmb_name; pmb_expr; pmb_attributes; pmb_loc} ->
               Mb.mk (map_loc this pmb_name) (this.module_expr this pmb_expr)
                 ~attrs:(this.attributes this pmb_attributes)
                 ~loc:(this.location this pmb_loc)
            );


          open_description =
            (fun this {popen_lid; popen_override; popen_attributes; popen_loc} ->
               Opn.mk (map_loc this popen_lid)
                 ~override:popen_override
                 ~loc:(this.location this popen_loc)
                 ~attrs:(this.attributes this popen_attributes)
            );


          include_description =
            (fun this {pincl_mod; pincl_attributes; pincl_loc} ->
               Incl.mk (this.module_type this pincl_mod)
                 ~loc:(this.location this pincl_loc)
                 ~attrs:(this.attributes this pincl_attributes)
            );

          include_declaration =
            (fun this {pincl_mod; pincl_attributes; pincl_loc} ->
               Incl.mk (this.module_expr this pincl_mod)
                 ~loc:(this.location this pincl_loc)
                 ~attrs:(this.attributes this pincl_attributes)
            );


          value_binding =
            (fun this {pvb_pat; pvb_expr; pvb_attributes; pvb_loc} ->
               Vb.mk
                 (this.pat this pvb_pat)
                 (this.expr this pvb_expr)
                 ~loc:(this.location this pvb_loc)
                 ~attrs:(this.attributes this pvb_attributes)
            );


          constructor_declaration =
            (fun this {pcd_name; pcd_args; pcd_res; pcd_loc; pcd_attributes} ->
              Type.constructor
                (map_loc this pcd_name)
                ~args:(T.map_constructor_arguments this pcd_args)
                ?res:(map_opt (this.typ this) pcd_res)
                ~loc:(this.location this pcd_loc)
                ~attrs:(this.attributes this pcd_attributes)
            );

          label_declaration =
            (fun this {pld_name; pld_type; pld_loc; pld_mutable; pld_attributes} ->
               Type.field
                 (map_loc this pld_name)
                 (this.typ this pld_type)
                 ~mut:pld_mutable
                 ~loc:(this.location this pld_loc)
                 ~attrs:(this.attributes this pld_attributes)
            );

          cases = (fun this l -> List.map (this.case this) l);
          case =
            (fun this {pc_lhs; pc_guard; pc_rhs} ->
               {
                 pc_lhs = this.pat this pc_lhs;
                 pc_guard = map_opt (this.expr this) pc_guard;
                 pc_rhs = this.expr this pc_rhs;
               }
            );



          location = (fun _this l -> l);

          extension = (fun this (s, e) -> (map_loc this s, this.payload this e));
          attribute = (fun this (s, e) -> (map_loc this s, this.payload this e));
          attributes = (fun this l -> List.map (this.attribute this) l);
          payload =
            (fun this -> function
               | PStr x -> PStr (this.structure this x)
               | PSig x -> PSig (this.signature this x)
               | PTyp x -> PTyp (this.typ this x)
               | PPat (x, g) -> PPat (this.pat this x, map_opt (this.expr this) g)
            );
        }

      (* let extension_of_error (error : Locations.location_error) : extension = *)
        (* Locations.extension_of_error *)
          (* ~mk_pstr:(function *)
            (* | x :: l -> PStr (x :: x :: l) *)
            (* | l -> PStr l) *)
          (* ~mk_extension:(fun x -> Str.extension x) *)
          (* ~mk_string_constant:(fun x -> Str.eval (Exp.constant (Pconst_string (x, None)))) *)
          (* error *)

      let attribute_of_warning loc s =
        { loc; txt = "ocaml.ppwarning" },
        PStr ([Str.eval ~loc (Exp.constant (Pconst_string (s, None)))])

      (* include Locations.Helpers_impl *)

    end
  end
end

include struct
  module Convert = Ppxlib_ast.Select_ast (Ppxlib_ast__.Versions.OCaml_406)

  module To_ppxlib = Convert.Of_ocaml
  module Of_ppxlib = Convert.To_ocaml
  module To_current = struct
    let copy_structure str =
      To_ppxlib.copy_structure str |> Ppxlib.Selected_ast.To_ocaml.copy_structure
    let copy_signature str =
      To_ppxlib.copy_signature str |> Ppxlib.Selected_ast.To_ocaml.copy_signature
  end

  module From_current = struct
    let copy_structure str =
      str
      |> Ppxlib.Selected_ast.Of_ocaml.copy_structure
      |> Of_ppxlib.copy_structure
    let copy_signature sig_ =
      sig_
      |> Ppxlib.Selected_ast.Of_ocaml.copy_signature
      |> Of_ppxlib.copy_signature
  end

end

module Location = Ocaml_common.Location
