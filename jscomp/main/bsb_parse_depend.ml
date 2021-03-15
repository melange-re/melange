module D = Dune_action_plugin.V1
module P = D.Path

open D.O

let (let*) p f = D.stage ~f p

let (//) = Ext_path.combine

let input_lines =
  let rec loop ic acc =
    match input_line ic with
    | exception End_of_file -> List.rev acc
    | line -> loop ic (line :: acc)
  in
  fun ic -> loop ic []

let split2 s ~sep =
  match String.index_opt s sep with
  | None -> None
  | Some i ->
    Some (String.sub s 0 i, String.sub s (i + 1) (String.length s - i - 1))

let extract_words s ~is_word_char =
  let rec skip_blanks i =
    if i = String.length s then
      []
    else if is_word_char s.[i] then
      parse_word i (i + 1)
    else
      skip_blanks (i + 1)
  and parse_word i j =
    if j = String.length s then
      [ String.sub s i (j - i) ]
    else if is_word_char s.[j] then
      parse_word i (j + 1)
    else
      String.sub s i (j - i) :: skip_blanks (j + 1)
  in
  skip_blanks 0

let extract_blank_separated_words s =
  extract_words s ~is_word_char:(function
    | ' '
    | '\t' ->
      false
    | _ -> true)

let parse_deps_exn lines =
  match lines with
  | [] -> []
  | line :: _ ->
    match split2 line ~sep:':' with
    | None -> assert false
    | Some (_basename, deps) ->
      extract_blank_separated_words deps

let single_file file =
  let chan = open_in_bin file in
  let deps = parse_deps_exn (input_lines chan) in
  close_in chan;
  let rules = List.map (fun file -> D.read_file ~path:(P.of_string file))
  deps
  in
  List.fold_left (fun acc item ->
    let+ _ = D.both acc item in ())
    (D.return ())
    rules

let parse_depends files =
  let rules = List.map single_file files in
  let rule = List.fold_left (fun acc item ->
    let+ _ = D.both acc item in ())
    (D.return ())
    rules
  in
  D.run rule


let () =
  let argv = Sys.argv in
  let l = Array.length argv in
  let current = ref 1 in
  let rev_list = ref [] in
  while !current < l do
    let s = argv.(!current) in
    incr current;
    if s <> "" && s.[0] = '-' then begin
      match s with
      | "-help" ->
        prerr_endline ("usage: bsb_parse_depend.exe [-help] file1 file2 ...");
        exit 0
      | s ->
        prerr_endline ("unknown option: " ^ s);
        prerr_endline ("usage: bsb_parse_depend.exe [-help] file1 file2 ...");
        exit 2
    end else
      rev_list := s :: !rev_list
  done;
  parse_depends !rev_list
;;

