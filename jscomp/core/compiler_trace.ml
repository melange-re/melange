module Trace = Dune_action_trace

type args = (string * string) list

let context = lazy (Trace.Context.create ~name:"melc")

let enabled () =
  !Js_config.action_trace && Trace.Context.is_enabled (Lazy.force context)

let now_in_nanoseconds () = int_of_float (Unix.gettimeofday () *. 1_000_000_000.)

let encode_args args =
  List.map (fun (name, value) -> (name, Csexp.Atom value)) args

let emit event = Trace.Context.emit (Lazy.force context) event

let instant ?(args = []) ~category ~name () =
  if enabled () then
    emit
      (Trace.Event.instant ~args:(encode_args args) ~category ~name
         ~time_in_nanoseconds:(now_in_nanoseconds ()) ())

let with_span ?(args = []) ~category ~name f =
  if not (enabled ()) then f ()
  else
    let start_in_nanoseconds = now_in_nanoseconds () in
    match f () with
    | result ->
        let duration_in_nanoseconds =
          now_in_nanoseconds () - start_in_nanoseconds
        in
        emit
          (Trace.Event.span ~args:(encode_args args) ~category ~name
             ~start_in_nanoseconds ~duration_in_nanoseconds ());
        result
    | exception exn ->
        let duration_in_nanoseconds =
          now_in_nanoseconds () - start_in_nanoseconds
        in
        emit
          (Trace.Event.span
             ~args:(encode_args (("status", "error") :: args))
             ~category ~name ~start_in_nanoseconds ~duration_in_nanoseconds ());
        raise exn

let () =
  at_exit (fun () ->
      if Lazy.is_val context then Trace.Context.close (Lazy.force context))
