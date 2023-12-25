[@@@mel.config {
  flags = [|
    "-w";
       "@A-70";
  |]
}]


module N = struct
  type 'a t = 'a option =
    | None
    | Some of 'a
end


let u = N.(None, Some 3)


let h = N.None
