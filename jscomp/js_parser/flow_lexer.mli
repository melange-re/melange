[@@@ocaml.ppx.context
  {
    tool_name = "ppx_driver";
    include_dirs = [];
    hidden_include_dirs = [];
    load_path = ([], []);
    open_modules = [];
    for_package = None;
    debug = false;
    use_threads = false;
    use_vmthreads = false;
    recursive_types = false;
    principal = false;
    no_alias_deps = false;
    unboxed_types = false;
    unsafe_string = false;
    cookies = [("library-name", "flow_parser")]
  }]
val jsx_child : Lex_env.t -> (Lex_env.t * Lex_result.t)
val regexp : Lex_env.t -> (Lex_env.t * Lex_result.t)
val jsx_tag : Lex_env.t -> (Lex_env.t * Lex_result.t)
val template_tail : Lex_env.t -> (Lex_env.t * Lex_result.t)
val template_tail_start : Lex_env.t -> (Lex_env.t * Lex_result.t)
val advance_loc_by_char : Loc.t -> Loc.t
val type_token : Lex_env.t -> (Lex_env.t * Lex_result.t)
val token : Lex_env.t -> (Lex_env.t * Lex_result.t)
val is_valid_identifier_name : Flow_sedlexing.lexbuf -> bool
