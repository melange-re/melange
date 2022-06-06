open Bsb

let extensions =
  Literals.
    [
      suffix_ml;
      suffix_mli;
      suffix_mll;
      suffix_re;
      suffix_rei;
      suffix_res;
      suffix_resi;
    ]

let timer = ref None

let debounce ~f ms =
  match !timer with
  | Some t ->
      Bsb_log.debug "Waiting... next run in %ims@." (Luv.Timer.get_due_in t)
  | None -> (
      let ti = Result.get_ok (Luv.Timer.init ()) in
      timer := Some ti;
      match
        Luv.Timer.start ti ms (fun () ->
            f ();
            timer := None)
      with
      | Ok () -> Bsb_log.debug "Started timer, running in %ims@." ms
      | Error e ->
          Bsb_log.warn "Error starting the timer: %s@." (Luv.Error.strerror e))

module Task = struct
  type info = { fd : Luv.Process.t; paths : string list }

  type t =
    ?on_exit:(Luv.Process.t -> exit_status:int64 -> term_signal:int -> unit) ->
    unit ->
    info
end

module Job = struct
  type t = {
    mutable fd : Luv.Process.t option;
    mutable watchers : (string, Luv.FS_event.t) Hashtbl.t;
    task : Task.t;
  }

  let create ~task = { task; fd = None; watchers = Hashtbl.create 64 }

  let interrupt t =
    Ext_option.iter t.fd (fun fd ->
        if Luv.Handle.is_active fd then
          match Luv.Process.kill fd Luv.Signal.sigterm with
          | Ok () -> t.fd <- None
          | Error e ->
              Bsb_log.warn "Error trying to stop program:@\n  %s"
                (Luv.Error.strerror e))

  let restart ?started t =
    debounce 150 ~f:(fun () ->
        let new_task_info =
          match t.fd with
          | None -> t.task ()
          | Some fd ->
              if Luv.Handle.is_active fd then (
                interrupt t;
                t.task ())
              else t.task ()
        in
        Ext_option.iter started (fun f -> f new_task_info);
        t.fd <- Some new_task_info.fd)

  let stop_watchers t =
    Hashtbl.iter
      (fun _path watcher ->
        let (_ : _ result) = Luv.FS_event.stop watcher in
        ())
      t.watchers

  let stop t =
    interrupt t;
    stop_watchers t
end

(* TODO: bail and exit on errors *)
let rec watch ~(job : Job.t) paths =
  Ext_list.iter paths (fun path ->
      if Hashtbl.mem job.watchers path then ( (* Already being watched *) )
      else
        match Luv.FS_event.init () with
        | Error e ->
            Bsb_log.error "Error starting watcher for %s: %s@." path
              (Luv.Error.strerror e)
        | Ok watcher -> (
            let stat = Luv.File.Sync.stat path in
            match stat with
            | Error e ->
                Bsb_log.error "Error starting watcher for %s: %s@." path
                  (Luv.Error.strerror e)
            | Ok stat ->
                Hashtbl.replace job.watchers path watcher;
                let recursive = Luv.File.Mode.test [ `IFDIR ] stat.mode in

                Luv.FS_event.start ~recursive ~stat:true watcher path (function
                  | Error e ->
                      Bsb_log.error "Error watching %s: %s@." path
                        (Luv.Error.strerror e);
                      ignore (Luv.FS_event.stop watcher);
                      Luv.Handle.close watcher ignore
                  | Ok (file, _events) ->
                      let file_extension = Filename.extension file in
                      if Ext_list.mem_string extensions file_extension then
                        Job.restart
                          ~started:(fun { Task.paths; _ } ->
                            let new_watchers = Hashtbl.create 64 in

                            let new_paths =
                              Ext_list.fold_left paths [] (fun acc path ->
                                  match Hashtbl.find job.watchers path with
                                  | prev_watcher ->
                                      (* Remove existing watchers from the Hashtbl
                                         and add them to the new table *)
                                      Hashtbl.remove job.watchers path;
                                      Hashtbl.replace new_watchers path
                                        prev_watcher;
                                      acc
                                  | exception Not_found ->
                                      (* New watchers will be added on the recursive call *)
                                      path :: acc)
                            in
                            (* Stop the previous watchers *)
                            Hashtbl.iter
                              (fun _ watcher ->
                                let (_ : _ result) =
                                  Luv.FS_event.stop watcher
                                in
                                ())
                              job.watchers;
                            (* Drop the old watchers before creating the new ones *)
                            job.watchers <- new_watchers;

                            watch ~job new_paths)
                          job)))

let watch ~task paths =
  let job = Job.create ~task in
  watch ~job paths;
  match Luv.Signal.init () with
  | Ok handle -> (
      let handler () =
        prerr_endline "Exiting";
        Job.stop job;
        Luv.Handle.close handle ignore
      in
      match Luv.Signal.start handle Luv.Signal.sigint handler with _ -> ())
  | Error _ -> ()
