(* The MIT License

  Copyright (c) 2016 Jane Street Group, LLC <opensource@janestreet.com>

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
*)

let protectx x ~f ~finally =
  match f x with
  | y ->
      finally x;
      y
  | exception e ->
      finally x;
      raise e

let with_file_in ?(binary = true) fn ~f =
  protectx
    (if binary then Stdlib.open_in_bin fn else Stdlib.open_in fn)
    ~finally:close_in ~f

let with_file_in_fd fn ~f =
  protectx (Unix.openfile fn [ O_RDONLY; O_CLOEXEC ] 0) ~f ~finally:Unix.close

let read_file =
  let read_all_unless_large =
    let rec eagerly_input_acc ic s ~pos ~len acc =
      if len <= 0 then acc
      else
        match input ic s pos len with
        | 0 -> acc
        | r -> eagerly_input_acc ic s ~pos:(pos + r) ~len:(len - r) (acc + r)
    in
    let eagerly_input_string ic len =
      let buf = Bytes.create len in
      let r = eagerly_input_acc ic buf ~pos:0 ~len 0 in
      if r = len then Bytes.unsafe_to_string buf
      else Bytes.sub_string buf ~pos:0 ~len:r
    in
    (* We use 65536 because that is the size of OCaml's IO buffers. *)
    let chunk_size = 65536 in
    (* Generic function for channels such that seeking is unsupported or
       broken *)
    let read_all_generic t buffer =
      let rec loop () =
        Buffer.add_channel buffer t chunk_size;
        loop ()
      in
      try loop () with End_of_file -> Ok (Buffer.contents buffer)
    in
    fun t ->
      (* Optimisation for regular files: if the channel supports seeking, we
         compute the length of the file so that we read exactly what we need and
         avoid an extra memory copy. We expect that most files Dune reads are
         regular files so this optimizations seems worth it. *)
      match in_channel_length t with
      | exception Sys_error _ -> read_all_generic t (Buffer.create chunk_size)
      | n when n > Sys.max_string_length -> Error ()
      | n -> (
          (* For some files [in_channel_length] returns an invalid value. For
           instance for files in /proc it returns [0] and on Windows the
           returned value is larger than expected (it counts linebreaks as 2
           chars, even in text mode).

           To be robust in both directions, we: - use [eagerly_input_string]
           instead of [really_input_string] in case we reach the end of the file
           early - read one more character to make sure we did indeed reach the
           end of the file *)
          let s = eagerly_input_string t n in
          match input_char t with
          | exception End_of_file -> Ok s
          | c ->
              (* The [+ chunk_size] is to make sure there is at least [chunk_size]
              free space so that the first [Buffer.add_channel buffer t
             chunk_size] in [read_all_generic] does not grow the buffer. *)
              let buffer = Buffer.create (String.length s + 1 + chunk_size) in
              Buffer.add_string buffer s;
              Buffer.add_char buffer c;
              read_all_generic t buffer)
  in
  let read_file_chan ?binary fn =
    match with_file_in fn ~f:read_all_unless_large ?binary with
    | Ok x -> x
    | Error () ->
        failwith "read_file: file is larger than Sys.max_string_length"
  in
  let read_all_fd =
    let rec read fd buf pos left =
      match left with
      | 0 -> `Ok
      | left -> (
          match Unix.read fd buf pos left with
          | 0 -> `Eof
          | n -> read fd buf (pos + n) (left - n))
    in
    fun fd ->
      match Unix.fstat fd with
      | exception Unix.Unix_error (e, x, y) -> Error (`Unix (e, x, y))
      | { Unix.st_size; _ } -> (
          if st_size = 0 then Ok ""
          else if st_size > Sys.max_string_length then Error `Too_big
          else
            let b = Bytes.create st_size in
            match read fd b 0 st_size with
            | exception Unix.Unix_error (e, x, y) -> Error (`Unix (e, x, y))
            | `Eof -> Error `Retry
            | `Ok -> Ok (Bytes.unsafe_to_string b))
  in
  match Sys.backend_type with
  | Other _ ->
      (* use slow path for JSOO *)
      fun ?(binary = true) fn -> read_file_chan ~binary fn
  | Native | Bytecode ->
      fun ?(binary = true) fn ->
        if binary then
          with_file_in_fd fn ~f:(fun fd ->
              match read_all_fd fd with
              | Ok s -> s
              | Error `Retry -> read_file_chan ~binary fn
              | Error `Too_big ->
                  failwith
                    "read_file: file is larger than Sys.max_string_length"
              | Error (`Unix (e, c, s)) -> raise (Unix.Unix_error (e, c, s)))
        else read_file_chan ~binary fn

let default_out_perm = 0o666

let open_out ?(binary = true) ?(perm = default_out_perm) fn =
  let flags : Stdlib.open_flag list =
    [
      Open_wronly;
      Open_creat;
      Open_trunc;
      (if binary then Open_binary else Open_text);
    ]
  in
  Stdlib.open_out_gen flags perm fn

let with_file_out ?binary ?perm p ~f =
  protectx (open_out ?binary ?perm p) ~finally:close_out ~f

let with_file_out_fd ?(perm = default_out_perm) fn ~f =
  protectx
    (Unix.openfile fn [ O_WRONLY; O_CLOEXEC; O_CREAT; O_TRUNC ] perm)
    ~finally:Unix.close ~f

let rec write fd str ~off ~len =
  if len > 0 then
    let written = Unix.single_write_substring fd str off len in
    write fd str ~off:(off + written) ~len:(len - written)

let write_file =
  let write_file_fast ?(perm = default_out_perm) fn data =
    with_file_out_fd ~perm fn ~f:(fun fd ->
        write fd data ~off:0 ~len:(String.length data))
  in
  fun ?(binary = true) ?perm fn data ->
    if binary then write_file_fast ?perm fn data
    else with_file_out ~binary ?perm fn ~f:(fun oc -> output_string oc data)

let write_filev =
  let write_filev_fast ?(perm = default_out_perm) fn data =
    with_file_out_fd ~perm fn ~f:(fun fd ->
        List.iter
          ~f:(fun chunk -> write fd chunk ~off:0 ~len:(String.length chunk))
          data)
  in
  fun ?(binary = true) ?perm fn data ->
    if binary then write_filev_fast ?perm fn data
    else
      with_file_out ~binary ?perm fn ~f:(fun oc ->
          List.iter ~f:(output_string oc) data)
