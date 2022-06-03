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

module Job = struct
  type t =
    ?on_exit:(Luv.Process.t -> exit_status:int64 -> term_signal:int -> unit) ->
    unit ->
    Luv.Process.t

  let singleton : _ Luv.Handle.t option ref = ref None

  let stop fd =
    match Luv.Process.kill fd Luv.Signal.sigterm with
    | Ok () -> ()
    | Error e ->
        Bsb_log.warn "Error trying to stop program:@\n  %s"
          (Luv.Error.strerror e)

  let restart ~job =
    debounce 150 ~f:(fun () ->
        let new_fd =
          match !singleton with
          | None -> job ()
          | Some fd ->
              if Luv.Handle.is_active fd then (
                stop fd;
                job ())
              else job ()
        in
        singleton := Some new_fd)
end

let watch ~job paths =
  List.iter
    (fun path ->
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
              let recursive = Luv.File.Mode.test [ `IFDIR ] stat.mode in

              Luv.FS_event.start ~recursive ~stat:true watcher path (function
                | Error e ->
                    Bsb_log.error "Error watching %s: %s@." path
                      (Luv.Error.strerror e);
                    ignore (Luv.FS_event.stop watcher);
                    Luv.Handle.close watcher ignore
                | Ok (file, _events) ->
                    let file_extension = Filename.extension file in
                    if List.mem file_extension extensions then Job.restart ~job)
          ))
    paths
