[@@@mel.config
{
  flags =
    [|
      "-w";
      "@A-70";
    |];
}]

type color = Orange | Color of string

let a = Color "#ffff"

let c =
  match a with Orange -> "orange" | Color "#ffff" -> "white" | Color s -> s
