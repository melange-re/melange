

let write_runtime_coverage: out_channel -> unit =
  fun channel -> ignore(Format.formatter_of_out_channel(channel))
