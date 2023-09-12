include (struct
module StringMap = Map.Make(struct type t = string
  let compare
      (x : string) y = compare x y end)
external time : string -> unit = "console.time"
external timeEnd : string -> unit = "console.timeEnd"

let timing label f =
  begin
    time label;
    f ();
    timeEnd label;
  end

let assertion_test () =
  let m = ref StringMap.empty in
  let count = 1000000 in
  timing "building" @@ (fun _ ->

  for i = 0 to count do
    m := StringMap.add (string_of_int i) (string_of_int i) !m
  done);
  timing "querying" @@ (fun _ ->
  for i = 0 to count  do
    ignore (StringMap.find (string_of_int i) !m )
  done)


end : sig val assertion_test : unit -> unit end)
