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
  | Some t -> (
      let due_in = Luv.Timer.get_due_in t in
      if due_in > 0 then Bsb_log.info "Waiting... next run in %ims" due_in
      else
        match Luv.Timer.again t with
        | Ok () -> ()
        | Error e ->
            Bsb_log.error "Error restarting the timer: %s"
              (Luv.Error.strerror e))
  | None -> (
      let ti = Result.get_ok (Luv.Timer.init ()) in
      timer := Some ti;
      match Luv.Timer.start ti ms f with
      | Ok () -> Bsb_log.info "Started timer, running in %ims" ms
      | Error e ->
          Bsb_log.error "Error restarting the timer: %s" (Luv.Error.strerror e))

module Job = struct
  let singleton : _ Luv.Handle.t option ref = ref None

  let stop () =
    let fd = Option.get !singleton in
    if not (Luv.Handle.is_closing fd) then
      match Luv.Process.kill fd Luv.Signal.sigterm with
      | Ok () -> ()
      | Error e ->
          Bsb_log.error "Error trying to stop program:@\n  %s"
            (Luv.Error.strerror e)

  let restart ~job =
    debounce 150 ~f:(fun () ->
        let fd = Option.get !singleton in
        if Luv.Handle.is_closing fd then singleton := Some (job ())
        else (
          stop ();
          singleton := Some (job ())))
end

let register_fs_events ~job paths =
  List.iter
    (fun path ->
      match Luv.FS_event.init () with
      | Error e ->
          Bsb_log.error "Error starting watcher: %s@." (Luv.Error.strerror e)
      | Ok watcher -> (
          let stat = Luv.File.Sync.stat path in
          match stat with
          | Error e ->
              Bsb_log.error "Error starting watcher: %s@."
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

let watch
    ~(job :
       ?on_exit:(Luv.Process.t -> exit_status:int64 -> term_signal:int -> unit) ->
       unit ->
       Luv.Process.t) paths =
  let fd =
    job
      ~on_exit:(fun _t ~exit_status:_ ~term_signal:_ ->
        Format.eprintf "Waiting for filesystem changes...@.")
      ()
  in
  Job.singleton := Some fd;
  register_fs_events ~job paths
