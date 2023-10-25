external describe : string -> (unit -> unit[@u]) -> unit = "describe"

external it : string -> (unit -> unit[@mel.uncurry]) -> unit = "it"
external it_promise : string -> (unit -> _ Js.Promise.t [@mel.uncurry]) -> unit = "it"

external eq : 'a -> 'a -> unit = "deepEqual" [@@mel.module "assert"]
external neq : 'a -> 'a -> unit = "notDeepEqual" [@@mel.module "assert"]

external strict_eq : 'a -> 'a -> unit = "strictEqual" [@@mel.module "assert"]
external strict_neq : 'a -> 'a -> unit = "notStrictEqual" [@@mel.module "assert"]

external ok : bool -> unit = "ok" [@@mel.module "assert"]
external fail : 'a -> 'a -> string Js.undefined -> string -> unit = "fail"
[@@mel.module "assert"]

external throws : (unit -> unit) -> unit = "throws" [@@mel.module "assert"]
(** There is a problem --
    it does not return [unit]
*)

let assert_equal = eq
let assert_notequal = neq
let assert_strict_equal = strict_eq
let assert_strict_notequal = strict_neq
let assert_ok = fun a -> ok a
let assert_fail = fun msg -> fail () () (Js.Undefined.return msg) ""

let is_mocha () =
  match Array.to_list Node.Process.process##argv with
  | _node :: mocha ::  _ ->
    let exec = Node.Path.basename mocha in
    exec = "mocha" || exec = "_mocha"
  | _ -> false
(* assert -- raises an AssertionError which mocha handls better
*)
let from_suites name (suite :  (string * ('a -> unit)) list) =
  match Array.to_list Node.Process.process##argv with
  | _cmd :: _ ->
    if is_mocha () then
      describe name (fun [@u] () ->
          List.iter (fun (name, code) -> it name code) suite)

  | _ -> ()

type eq =
  | Eq :  'a *'a  -> eq
  | Neq : 'a * 'a -> eq
  | StrictEq :  'a *'a  -> eq
  | StrictNeq : 'a * 'a -> eq
  | Ok : bool -> eq
  | Approx : float * float -> eq
  | ApproxThreshold : float * float * float -> eq
  | ThrowAny : (unit -> unit) -> eq
  | Fail : unit -> eq
  | FailWith : string -> eq
  (* TODO: | Exception : exn -> (unit -> unit) -> _ eq  *)

type  pair_suites = (string * (unit ->  eq)) list
type promise_suites = (string * eq Js.Promise.t) list
let close_enough ?(threshold=0.0000001 (* epsilon_float *)) a b =
  abs_float (a -. b) < threshold

let node_from_pair_suites (name : string) (suites :  pair_suites) =
  Js.log (name, "testing");
  List.iter (fun (name, code) ->
      match code () with
      | Eq(a,b) -> Js.log (name , a, "eq?", b )
      | Neq(a,b) -> Js.log (name, a, "neq?",   b )
      | StrictEq(a,b) -> Js.log (name , a, "strict_eq?", b )
      | StrictNeq(a,b) -> Js.log (name, a, "strict_neq?",   b )
      | Approx(a,b) -> Js.log (name, a, "~",  b)
      | ApproxThreshold(t, a, b) -> Js.log (name, a, "~", b, " (", t, ")")
      | ThrowAny _fn -> ()
      | Fail _ -> Js.log "failed"
      | FailWith msg -> Js.log ("failed: " ^ msg)
      | Ok a -> Js.log (name, a, "ok?")
    ) suites

let handleCode spec =

  match spec with
  | Eq(a,b) -> assert_equal a b
  | Neq(a,b) -> assert_notequal a b
  | StrictEq(a,b) -> assert_strict_equal a b
  | StrictNeq(a,b) -> assert_strict_notequal a b
  | Ok(a) -> assert_ok a
  | Approx(a, b) ->
    if not (close_enough a b) then assert_equal a b (* assert_equal gives better ouput *)
  | ApproxThreshold(t, a, b) ->
    if not (close_enough ~threshold:t a b) then assert_equal a b (* assert_equal gives better ouput *)
  | ThrowAny fn -> throws fn
  | Fail _ -> assert_fail "failed"
  | FailWith msg -> assert_fail msg

let from_pair_suites name (suites :  pair_suites) =
  match Array.to_list Node.Process.process##argv with
  | _cmd :: _ ->
    if is_mocha () then
      describe name (fun [@u] () ->
          suites |>
          List.iter (fun (name, code) ->
              it name (fun _ ->
                  handleCode (code ())
                )
            )
        )
    else node_from_pair_suites name suites
  | _ -> ()
let val_unit = Js.Promise.resolve ()
let from_promise_suites name (suites : (string * _ Js.Promise.t ) list) =
  match Array.to_list Node.Process.process##argv with
  | _cmd :: _ ->
    if is_mocha () then
      describe name (fun [@u] () ->
          suites |>
          List.iter (fun (name, code) ->
              it_promise name (fun _ ->
                  code |> Js.Promise.then_ (fun x -> handleCode x; val_unit)

                )
            )
        )
    else Js.log "promise suites" (* TODO*)
  | _ -> ()

(*
Note that [require] is a file local value,
we need type [require]

let is_top : unit -> bool = [%mel.raw{|
function (_){
console.log('hi');
if (typeof require === "undefined"){
  return false
} else {
  console.log("hey",require.main.filename);
  return require.main === module;
}
}
|}]

let from_pair_suites_non_top name suites =
    if not @@ is_top () then
      from_pair_suites name suites
*)

let eq_suites ~test_id ~suites loc x y  =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Eq(x,y))) :: !suites

let bool_suites  ~test_id ~suites loc x   =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Ok(x))) :: !suites

let throw_suites ~test_id ~suites loc x =
  incr test_id ;
  suites :=
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> ThrowAny(x))) :: !suites
