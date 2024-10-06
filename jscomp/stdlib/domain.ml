(* Copyright (c) 2022 Gabriel Scherer

This implementation is provided under the MIT license -- see ../LICENSE. *)

type 'a t = {
  id: int;
  handle: 'a Js.Promise.t;
  status: 'a status ref;
}
and 'a status =
| Running
| Return of 'a
| Error of exn * Printexc.raw_backtrace

(* Our implementation assumes that it may run in a "concurrent"
   setting, and that its "domain-global" data structures must be
   protected / used atomically. For simplicity, we just use a lock.

   Potential sources of "concurrent" usage of this library are as follows:
   - A multi-threaded OCaml 4 program uses the library.
     A race between two threads calling DLS.get and DLS.set at the same time
     might result in incorrect results (in absence of explicit synchronization)
     if one thread yields in the middle of an internal hashtable operation.
   - An OCaml 5 program uses the library. I'm not sure why that would happen,
     but it sounds silly enough that it will probably be done someday.

   Most use of locks below are innocuous performance-wise, as it only
   occurs on domain lifetime event (deletion and termination). The
   exceptions are its usage in DLS.get and DLS.set, which may be
   performance-sensitive. Ideally we would use a data-structure that allows
   for lock-free thread-local storage.
*)
let atomic_lock = Mutex.create ()
let atomically : type a . (unit -> a) -> a =
  fun f ->
    Mutex.lock atomic_lock;
    Fun.protect ~finally:(fun () -> Mutex.unlock atomic_lock) f

let first_spawn_queue : (unit -> unit) Queue.t = Queue.create ()
let first_spawn_occurred = ref false

let before_first_spawn f =
  atomically @@ fun () ->
  if !first_spawn_occurred then invalid_arg "Domain.before_first_spawn";
  Queue.push f first_spawn_queue

let maybe_first_spawn () =
  atomically @@ fun () ->
  if not !first_spawn_occurred then begin
    first_spawn_occurred := true;
    while not (Queue.is_empty first_spawn_queue) do
      let f = Queue.take first_spawn_queue in
      f ()
    done;
  end

(* note: we store several bindings per key,
   each thread may have several exit callbacks. *)
let at_exit_table : (unit -> unit) list ref = ref []

let at_exit f =
  (* [at_exit_table] slots are domain-local in the sense that we never
     read or write the table at the other index than our own domain's.
     But hashtables may not be safe for concurrent separated accesses,
     so we still lock. *)
  atomically @@ fun () ->
  at_exit_table := f :: !at_exit_table

let do_at_exit status =
  let at_exit_callbacks =
    atomically @@ fun () -> !at_exit_table
  in
  match List.iter (fun f -> f ()) at_exit_callbacks with
  | () -> ()
  | exception exn ->
    begin match !status with
      | Running -> assert false
      | Error _ -> ()
      | Return _ ->
        let bt = Printexc.get_raw_backtrace () in
        status := Error (exn, bt)
    end

type id = int

let get_id t = t.id
let self () = 0

let cpu_relax () = ()

let first_domain = 0

let is_main_domain () =
  self () = first_domain

let self_index () = self ()

let recommended_domain_count () = 1

module DLS = struct
  type 'a key = {
    mutable table: 'a option;
    split_from_parent: ('a -> 'a) option;
    init: (unit -> 'a);
  }

  type some_key =
    Key : 'a key -> some_key

  let all_keys : some_key list ref = ref []

  let new_key ?split_from_parent init =
    let key = { table = None; split_from_parent; init } in
    (atomically @@ fun () -> all_keys := Key key :: !all_keys);
    key

  let get key =
    match key.table with
    | Some v -> v
    | None ->
      let v = key.init () in
      (atomically @@ fun () -> key.table <- Some v);
      v

  let set key v =
    atomically @@ fun () ->
    key.table <- Some v

  type some_key_value =
    Key_value : 'a key * 'a -> some_key_value

  let split_key_before_spawn key =
    match key.split_from_parent with
    | None -> None
    | Some split ->
      let current = get key in
      let child = split current in
      Some (Key_value (key, child))

  let prepare_split_keys_before_spawn () =
    List.filter_map (fun (Key key) -> split_key_before_spawn key) !all_keys

  let perform_split_after_spawn split_keys =
    let perform_split (Key_value (key, v)) = set key v in
    List.iter perform_split split_keys
end

let next_id =
  let next_id = ref 0 in
  fun () ->
    incr next_id;
    !next_id

let spawn f =
  maybe_first_spawn ();
  let status = ref Running in
  let split_keys = DLS.prepare_split_keys_before_spawn () in
  let handle =
    let run ~resolve ~reject (split_keys, status) =
      DLS.perform_split_after_spawn split_keys;
      begin
        match f () with
        | v ->
          status := Return v;
          resolve v [@u];
        | exception exn ->
          let bt = Printexc.get_raw_backtrace () in
          status := Error (exn, bt);
          reject exn [@u]
      end;
      do_at_exit status
    in
    Js.Promise.make (fun ~resolve ~reject ->
      run ~resolve ~reject (split_keys, status))
  in
  { id = next_id (); handle; status }

let join t =
  Js.Promise.then_ (fun _ ->
    match !(t.status) with
    | Running -> assert false
    | Return v -> Js.Promise.resolve v
    | Error (exn, _bt) ->
      raise exn
  ) t.handle
  |> Js.Promise.catch (fun _ ->
      match !(t.status) with
      | Running | Return _ -> assert false
      | Error (exn, _bt) -> raise exn)
