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
    transparent_modules = false;
    unboxed_types = false;
    unsafe_string = false;
    cookies =
      [("library-name", "flow_parser"); ("sedlex.regexps", ([%regexps ]))]
  }]
type t =
  | LibFile of string
  | SourceFile of string
  | JsonFile of string
  | ResourceFile of string [@@deriving (show, eq)]
include
  struct
    let _ = fun (_ : t) -> ()
    let rec pp :
      Format.formatter -> t -> unit
      =
      ((
          fun fmt ->
            function
            | LibFile a0 ->
                (Format.fprintf fmt
                   "(@[<2>File_key.LibFile@ ";
                 (Format.fprintf fmt "%S") a0;
                 Format.fprintf fmt "@])")
            | SourceFile a0 ->
                (Format.fprintf fmt
                   "(@[<2>File_key.SourceFile@ ";
                 (Format.fprintf fmt "%S") a0;
                 Format.fprintf fmt "@])")
            | JsonFile a0 ->
                (Format.fprintf fmt
                   "(@[<2>File_key.JsonFile@ ";
                 (Format.fprintf fmt "%S") a0;
                 Format.fprintf fmt "@])")
            | ResourceFile a0 ->
                (Format.fprintf fmt
                   "(@[<2>File_key.ResourceFile@ ";
                 (Format.fprintf fmt "%S") a0;
                 Format.fprintf fmt "@])"))
      [@ocaml.warning "-39"][@ocaml.warning "-A"])
    and show : t -> string =
      fun x -> Format.asprintf "%a" pp x[@@ocaml.warning
                                                               "-32"]
    let _ = pp
    and _ = show
    let rec equal : t -> t -> bool =
      ((
          fun lhs rhs ->
            match (lhs, rhs) with
            | (LibFile lhs0, LibFile rhs0) ->
                ((fun (a : string) b -> a = b)) lhs0 rhs0
            | (SourceFile lhs0, SourceFile rhs0) ->
                ((fun (a : string) b -> a = b)) lhs0 rhs0
            | (JsonFile lhs0, JsonFile rhs0) ->
                ((fun (a : string) b -> a = b)) lhs0 rhs0
            | (ResourceFile lhs0, ResourceFile rhs0) ->
                ((fun (a : string) b -> a = b)) lhs0 rhs0
            | _ -> false)
      [@ocaml.warning "-39"][@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    let _ = equal
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
let to_string =
  function | LibFile x | SourceFile x | JsonFile x | ResourceFile x -> x
let to_path =
  function | LibFile x | SourceFile x | JsonFile x | ResourceFile x -> Ok x
let compare =
  let order_of_filename =
    function
    | LibFile _ -> 1
    | SourceFile _ -> 2
    | JsonFile _ -> 2
    | ResourceFile _ -> 3 in
  fun a b ->
    let k = (order_of_filename a) - (order_of_filename b) in
    if k <> 0 then k else String.compare (to_string a) (to_string b)
let compare_opt a b =
  match (a, b) with
  | (Some _, None) -> (-1)
  | (None, Some _) -> 1
  | (None, None) -> 0
  | (Some a, Some b) -> compare a b
let is_lib_file =
  function
  | LibFile _ -> true
  | SourceFile _ -> false
  | JsonFile _ -> false
  | ResourceFile _ -> false
let map f =
  function
  | LibFile filename -> LibFile (f filename)
  | SourceFile filename -> SourceFile (f filename)
  | JsonFile filename -> JsonFile (f filename)
  | ResourceFile filename -> ResourceFile (f filename)
let exists f =
  function
  | LibFile filename | SourceFile filename | JsonFile filename | ResourceFile
    filename -> f filename
let check_suffix filename suffix =
  exists (fun fn -> Filename.check_suffix fn suffix) filename
let chop_suffix filename suffix =
  map (fun fn -> Filename.chop_suffix fn suffix) filename
let with_suffix filename suffix = map (fun fn -> fn ^ suffix) filename
