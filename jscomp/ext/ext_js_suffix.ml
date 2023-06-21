type t = Js | Bs_js | Mjs | Cjs | Custom_extension of string

let to_string (x : t) =
  match x with
  | Js -> Literals.suffix_js
  | Bs_js -> Literals.suffix_bs_js
  | Mjs -> Literals.suffix_mjs
  | Cjs -> Literals.suffix_cjs
  | Custom_extension str -> str

let of_string (x : string) : t =
  match () with
  | () when x = Literals.suffix_js -> Js
  | () when x = Literals.suffix_bs_js -> Bs_js
  | () when x = Literals.suffix_mjs -> Mjs
  | () when x = Literals.suffix_cjs -> Cjs
  | () -> Custom_extension x

let default = Js
