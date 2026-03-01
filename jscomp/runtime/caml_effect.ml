(* Copyright (C) 2026 Contributors to Melange
 *
 * This file is distributed under the terms of the GNU Lesser General Public
 * License version 3, with the special exception on linking described in the
 * file LICENSE.
 *)

type stack = {
  retc : Obj.t -> Obj.t;
  exnc : exn -> Obj.t;
  effc : Obj.t -> Obj.t -> Obj.t -> Obj.t;
  mutable parent : stack option;
  mutable replay_answers : replay_answer list;
  mutable replay_index : int;
}

and replay_answer =
  | Replay_value of Obj.t
  | Replay_exn of exn

type replay_payload = {
  stack : stack;
  comp : Obj.t -> Obj.t;
  arg : Obj.t;
  answers : replay_answer list;
  used : int;
}

type continuation_payload =
  | Replay_payload of replay_payload
  | Tail_payload of {
      stack : stack;
      k : Obj.t -> Obj.t;
    }

type continuation = Obj.t * Obj.t * bool ref * continuation_payload

exception Perform of Obj.t
exception Reperform of Obj.t * continuation * Obj.t
exception Perform_tail_exn of exn
exception Unhandled_effect of Obj.t
exception Unsupported_continuation_resumption

let current_stack : stack option ref = ref None

let default_last_fiber = Obj.repr 0
let empty_raw_backtrace = Obj.repr [||]
let continuation_already_resumed_exn : exn option ref = ref None
let unhandled_exn_constructor : (Obj.t -> exn) option ref = ref None

let caml_set_continuation_already_resumed exn =
  continuation_already_resumed_exn.contents <- Some exn

let caml_set_unhandled_exception_constructor mk =
  unhandled_exn_constructor.contents <- Some (Obj.magic mk : Obj.t -> exn)

let raise_continuation_already_resumed () =
  match continuation_already_resumed_exn.contents with
  | Some exn -> raise exn
  | None -> raise Unsupported_continuation_resumption

let raise_unhandled_effect eff =
  match unhandled_exn_constructor.contents with
  | Some mk -> raise (mk eff)
  | None -> raise (Unhandled_effect eff)

let caml_alloc_stack retc exnc effc =
  {
    retc = (Obj.magic retc : Obj.t -> Obj.t);
    exnc = (Obj.magic exnc : exn -> Obj.t);
    effc = (Obj.magic effc : Obj.t -> Obj.t -> Obj.t -> Obj.t);
    parent = None;
    replay_answers = [];
    replay_index = 0;
  }

let make_replay_continuation (stack : stack) (comp : Obj.t -> Obj.t)
    (arg : Obj.t) (answers : replay_answer list) (used : int) : continuation =
  ( Obj.repr stack,
    default_last_fiber,
    ref false,
    Replay_payload { stack; comp; arg; answers; used } )

let make_tail_continuation (stack : stack) (k : Obj.t -> Obj.t) : continuation =
  (Obj.repr stack, default_last_fiber, ref false, Tail_payload { stack; k })

let continuation_of_value (k : Obj.t) : continuation =
  let size = try Obj.size k with _ -> -1 in
  if size < 1 then raise (Invalid_argument "Effect: invalid continuation value")
  else Obj.obj k

let continuation_stack ((stack, _, _, _) : continuation) : stack = Obj.obj stack

let continuation_payload ((_, _, _, payload) : continuation) = payload

let mark_continuation_used ((_, _, used, _) : continuation) =
  if used.contents then raise_continuation_already_resumed ()
  else used.contents <- true

let rec dispatch_effect (stack : stack) (eff : Obj.t) (k : continuation)
    (k_tail : Obj.t) =
  try stack.effc eff (Obj.repr k) k_tail with
  | Reperform (eff', k', k_tail') -> propagate_reperform stack eff' k' k_tail'

and propagate_reperform (stack : stack) (eff : Obj.t) (k : continuation)
    (k_tail : Obj.t) =
  match stack.parent with
  | Some parent -> dispatch_effect parent eff k k_tail
  | None -> raise_unhandled_effect eff

let caml_perform eff =
  match current_stack.contents with
  | Some stack -> (
      let idx = stack.replay_index in
      let answers = stack.replay_answers in
      let rec nth l i =
        match (l, i) with
        | [], _ -> None
        | x :: _, 0 -> Some x
        | _ :: xs, _ -> nth xs (i - 1)
      in
      match nth answers idx with
      | Some answer ->
          stack.replay_index <- idx + 1;
          (match answer with
          | Replay_value v -> Obj.obj v
          | Replay_exn exn -> raise exn)
      | None -> raise (Perform (Obj.repr eff)))
  | None -> raise_unhandled_effect (Obj.repr eff)

let caml_perform_tail eff k =
  match current_stack.contents with
  | Some stack ->
      let continuation =
        make_tail_continuation stack (Obj.magic k : Obj.t -> Obj.t)
      in
      (try
         Obj.obj
           (dispatch_effect stack (Obj.repr eff) continuation default_last_fiber)
       with exn -> raise (Perform_tail_exn exn))
  | None -> raise_unhandled_effect (Obj.repr eff)

let caml_reperform eff k k_tail =
  raise (Reperform (Obj.repr eff, continuation_of_value k, Obj.repr k_tail))

let append_replay_answer answers used answer =
  let rec take l n =
    match (l, n) with
    | _, n when n <= 0 -> []
    | [], _ -> []
    | x :: xs, _ -> x :: take xs (n - 1)
  in
  let rec append l tail =
    match l with
    | [] -> tail
    | x :: xs -> x :: append xs tail
  in
  append (take answers used) [ answer ]

let runstack_with_answers (stack : stack) (comp : Obj.t -> Obj.t) (arg : Obj.t)
    (answers : replay_answer list) =
  let parent = current_stack.contents in
  stack.parent <- parent;
  stack.replay_answers <- answers;
  stack.replay_index <- 0;
  current_stack.contents <- Some stack;
  let finish result =
    current_stack.contents <- parent;
    result
  in
  try
    let value = comp arg in
    Obj.obj (finish (stack.retc value))
  with
  | Perform eff ->
      let continuation =
        make_replay_continuation stack comp arg answers stack.replay_index
      in
      Obj.obj
        (finish (dispatch_effect stack eff continuation default_last_fiber))
  | Perform_tail_exn exn -> raise exn
  | Reperform (eff, k, k_tail) ->
      let result =
        match parent with
        | Some parent_stack -> dispatch_effect parent_stack eff k k_tail
        | None -> raise_unhandled_effect eff
      in
      Obj.obj (finish result)
  | exn -> Obj.obj (finish (stack.exnc exn))

let caml_runstack stack comp arg =
  let stack = (Obj.magic stack : stack) in
  let comp = (Obj.magic comp : Obj.t -> Obj.t) in
  runstack_with_answers stack comp (Obj.repr arg) []

let caml_resume stack resume_fun arg _last_fiber =
  let payload = (Obj.magic stack : continuation_payload) in
  let resume_fun = (Obj.magic resume_fun : Obj.t -> Obj.t) in
  match payload with
  | Replay_payload payload ->
      let answer =
        try Replay_value (resume_fun (Obj.repr arg)) with exn -> Replay_exn exn
      in
      let answers = append_replay_answer payload.answers payload.used answer in
      runstack_with_answers payload.stack payload.comp payload.arg answers
  | Tail_payload { stack; k } ->
      runstack_with_answers stack (fun arg -> k (resume_fun arg)) (Obj.repr arg) []

let caml_continuation_use_noexc k =
  let continuation = continuation_of_value k in
  mark_continuation_used continuation;
  let payload = continuation_payload continuation in
  Obj.repr payload

let caml_continuation_use_and_update_handler_noexc k retc exnc effc =
  let continuation = continuation_of_value k in
  mark_continuation_used continuation;
  let payload = continuation_payload continuation in
  match payload with
  | Replay_payload payload ->
      let stack = payload.stack in
      let updated = caml_alloc_stack retc exnc effc in
      updated.parent <- stack.parent;
      Obj.repr (Replay_payload { payload with stack = updated })
  | Tail_payload payload ->
      let stack = payload.stack in
      let updated = caml_alloc_stack retc exnc effc in
      updated.parent <- stack.parent;
      Obj.repr (Tail_payload { payload with stack = updated })

let caml_get_continuation_callstack k _ =
  let _continuation = continuation_of_value k in
  empty_raw_backtrace
