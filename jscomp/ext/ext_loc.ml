type t = Location.t = {
  loc_start : Lexing.position;
  loc_end : Lexing.position;
  loc_ghost : bool;
}

let of_pos (pos_fname, pos_lnum, cnum, enum) =
  let start : Lexing.position =
    { pos_fname; pos_lnum; pos_cnum = cnum; pos_bol = 0 }
  in
  {
    Location.loc_start = start;
    loc_end = { start with pos_cnum = enum };
    loc_ghost = false;
  }
