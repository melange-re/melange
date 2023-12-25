[@@@mel.config
{
  flags =
    [|
      "-w";
      "@A-70";
    |];
}]

type t = A of (t -> int) [@@unboxed]

let g x = match x with A v -> v x

let loop = g (A g)
