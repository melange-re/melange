type position = {
  line: int ;
  column: int }[@@deriving (eq, show)]
include
  struct
    let _ = fun (_ : position) -> ()
    let rec equal_position :
      position -> position -> bool =
      ((
          fun lhs rhs ->
            ((fun (a : int) b -> a = b) lhs.line rhs.line) &&
              ((fun (a : int) b -> a = b) lhs.column rhs.column))
      [@ocaml.warning "-39"][@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    let _ = equal_position
    let rec pp_position :
      Format.formatter ->
        position -> unit
      =
      ((
          fun fmt x ->
            Format.fprintf fmt "@[<2>{ ";
            ((Format.fprintf fmt "@[%s =@ " "Loc.line";
              (Format.fprintf fmt "%d") x.line;
              Format.fprintf fmt "@]");
             Format.fprintf fmt ";@ ";
             Format.fprintf fmt "@[%s =@ " "column";
             (Format.fprintf fmt "%d") x.column;
             Format.fprintf fmt "@]");
            Format.fprintf fmt "@ }@]")
      [@ocaml.warning "-39"][@ocaml.warning "-A"])
    and show_position : position -> string =
      fun x -> Format.asprintf "%a" pp_position x
    [@@ocaml.warning "-32"]
    let _ = pp_position
    and _ = show_position
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
type t = {
  source: File_key.t option ;
  start: position ;
  _end: position }[@@deriving show]
include
  struct
    let _ = fun (_ : t) -> ()
    let rec pp :
      Format.formatter -> t -> unit
      =
      ((let __2 = pp_position
        and __1 = pp_position
        and __0 = File_key.pp in
        ((
            fun fmt x ->
              Format.fprintf fmt "@[<2>{ ";
              (((Format.fprintf fmt "@[%s =@ "
                   "Loc.source";
                 ((function
                   | None ->
                       Format.pp_print_string fmt "None"
                   | Some x ->
                       (Format.pp_print_string fmt
                          "(Some ";
                        (__0 fmt) x;
                        Format.pp_print_string fmt ")")))
                   x.source;
                 Format.fprintf fmt "@]");
                Format.fprintf fmt ";@ ";
                Format.fprintf fmt "@[%s =@ " "start";
                (__1 fmt) x.start;
                Format.fprintf fmt "@]");
               Format.fprintf fmt ";@ ";
               Format.fprintf fmt "@[%s =@ " "_end";
               (__2 fmt) x._end;
               Format.fprintf fmt "@]");
              Format.fprintf fmt "@ }@]")
          [@ocaml.warning "-A"]))
      [@ocaml.warning "-39"])
    and show : t -> string =
      fun x -> Format.asprintf "%a" pp x[@@ocaml.warning
                                                               "-32"]
    let _ = pp
    and _ = show
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
let none =
  {
    source = None;
    start = { line = 0; column = 0 };
    _end = { line = 0; column = 0 }
  }
let is_none (x : t) =
  (x == none) ||
    (match x with
     | { source = None; start = { line = 0; column = 0 };
         _end = { line = 0; column = 0 } } -> true
     | _ -> false)
let is_none_ignore_source (x : t) =
  (x == none) ||
    (match x with
     | { source = _; start = { line = 0; column = 0 };
         _end = { line = 0; column = 0 } } -> true
     | _ -> false)
let btwn loc1 loc2 =
  { source = (loc1.source); start = (loc1.start); _end = (loc2._end) }
let char_before loc =
  let start =
    let { line; column } = loc.start in
    let column = if column > 0 then column - 1 else column in
    { line; column } in
  let _end = loc.start in { loc with start; _end }
let first_char loc =
  let start = loc.start in
  let _end = { start with column = (start.column + 1) } in { loc with _end }
let pos_cmp a b =
  let k = a.line - b.line in if k = 0 then a.column - b.column else k
let span_compare a b =
  let k = File_key.compare_opt a.source b.source in
  if k = 0
  then
    let k = pos_cmp a.start b.start in
    (if k <= 0
     then let k = pos_cmp a._end b._end in (if k >= 0 then 0 else (-1))
     else 1)
  else k[@@ocaml.doc
          "\n * If `a` spans (completely contains) `b`, then returns 0.\n * If `b` starts before `a` (even if it ends inside), returns < 0.\n * If `b` ends after `a` (even if it starts inside), returns > 0.\n "]
let contains loc1 loc2 = (span_compare loc1 loc2) = 0[@@ocaml.doc
                                                       " [contains loc1 loc2] returns true if [loc1] entirely overlaps [loc2] "]
let intersects loc1 loc2 =
  ((File_key.compare_opt loc1.source loc2.source) = 0) &&
    (not
       (((pos_cmp loc1._end loc2.start) < 0) ||
          ((pos_cmp loc1.start loc2._end) > 0)))[@@ocaml.doc
                                                  " [intersects loc1 loc2] returns true if [loc1] intersects [loc2] at all "]
let lines_intersect loc1 loc2 =
  ((File_key.compare_opt loc1.source loc2.source) = 0) &&
    (not
       (((loc1._end).line < (loc2.start).line) ||
          ((loc1.start).line > (loc2._end).line)))[@@ocaml.doc
                                                    " [lines_intersect loc1 loc2] returns true if [loc1] and [loc2] cover any part of\n    the same line, even if they don't actually intersect.\n\n    For example, if [loc1] ends and then [loc2] begins later on the same line,\n    [intersects loc1 loc2] is false, but [lines_intersect loc1 loc2] is true. "]
let compare_ignore_source loc1 loc2 =
  match pos_cmp loc1.start loc2.start with
  | 0 -> pos_cmp loc1._end loc2._end
  | k -> k
let compare loc1 loc2 =
  let k = File_key.compare_opt loc1.source loc2.source in
  if k = 0 then compare_ignore_source loc1 loc2 else k
let equal loc1 loc2 = (compare loc1 loc2) = 0
let debug_to_string ?(include_source= false) loc =
  let source =
    if include_source
    then
      Printf.sprintf "%S: "
        (match loc.source with
         | Some src -> File_key.to_string src
         | None -> "<NONE>")
    else "" in
  let pos =
    Printf.sprintf "(%d, %d) to (%d, %d)" (loc.start).line (loc.start).column
      (loc._end).line (loc._end).column in
  source ^ pos[@@ocaml.doc
                "\n * This is mostly useful for debugging purposes.\n * Please don't dead-code delete this!\n "]
let to_string_no_source loc =
  let line = (loc.start).line in
  let start = (loc.start).column + 1 in
  let end_ = (loc._end).column in
  if line <= 0
  then "0:0"
  else
    if (line = (loc._end).line) && (start = end_)
    then Printf.sprintf "%d:%d" line start
    else
      if line != (loc._end).line
      then Printf.sprintf "%d:%d,%d:%d" line start (loc._end).line end_
      else Printf.sprintf "%d:%d-%d" line start end_
let start_pos_to_string_for_vscode_loc_uri_fragment loc =
  let line = (loc.start).line in
  let start = (loc.start).column + 1 in
  let (line, start) = if line <= 0 then (0, 0) else (line, start) in
  Printf.sprintf "#L%d,%d" line start
let mk_loc ?source (start_line, start_column) (end_line, end_column) =
  {
    source;
    start = { line = start_line; column = start_column };
    _end = { line = end_line; column = end_column }
  }
let source loc = loc.source
let cursor source line column =
  { source; start = { line; column }; _end = { line; column } }[@@ocaml.doc
                                                                 " Produces a zero-width Loc.t, where start = end "]
let start_loc loc = { loc with _end = (loc.start) }
let end_loc loc = { loc with start = (loc._end) }
