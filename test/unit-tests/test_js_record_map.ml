open Melangelib
module M = Js_record_map
module Ident = Melstd.Ident

let expr expression_desc : J.expression =
  { expression_desc; comment = None; loc = None }

let return value : J.statement =
  { statement_desc = Return value; comment = None }

let check = Alcotest.(check bool)

let identity () =
  let value = expr (Object [ ("field", expr (Bool true)) ]) in
  let stmt : J.statement =
    {
      statement_desc =
        Try
          {
            body = [ return value ];
            catch = Some (Ident.create_local "exn", [ return value ]);
            finally = Some [ return value ];
          };
      comment = None;
    }
  in
  let program : J.program =
    { block = [ stmt ]; exports = []; export_set = Ident.Set.empty }
  in
  check "unchanged tree" true (M.super.program M.super program == program)

let changed_child () =
  let first = expr (Bool true) in
  let last = expr (Bool false) in
  let tail = [ ("last", last) ] in
  let fields = ("first", first) :: tail in
  let value = expr (Object fields) in
  let visited = ref [] in
  let replacement : J.expression =
    Marshal.from_string (Marshal.to_string first []) 0
  in
  let mapper =
    {
      M.super with
      expression =
        (fun self x ->
          visited := x :: !visited;
          if x == first then replacement else M.super.expression self x);
    }
  in
  let mapped = mapper.expression mapper value in
  check "all callbacks, in order" true
    (match List.rev !visited with
    | [ a; b; c ] -> a == value && b == first && c == last
    | _ -> false);
  check "equal but freshly allocated child" true (replacement != first);
  check "rebuilt parent" true (mapped != value);
  match mapped.expression_desc with
  | Object ((_, child) :: rest) ->
      check "uses the returned child" true (child == replacement);
      check "shares the unchanged list suffix" true (rest == tail)
  | _ -> Alcotest.fail "expected an object"

let mutable_metadata () =
  let info : Js_op.ident_info = { used_stats = NA } in
  let declaration : J.variable_declaration =
    {
      ident = Ident.create_local "x";
      value = None;
      property = Strict;
      ident_info = info;
    }
  in
  let mapper =
    {
      M.super with
      ident =
        (fun _ id ->
          info.used_stats <- Dead_pure;
          id);
    }
  in
  let mapped = mapper.variable_declaration mapper declaration in
  check "unchanged wrapper" true (mapped == declaration);
  check "metadata remains shared" true (mapped.ident_info == info);
  check "callback effect is retained" true (info.used_stats = Dead_pure)

let suite =
  [
    ("unchanged nodes", `Quick, identity);
    ("changed child and unchanged suffix", `Quick, changed_child);
    ("mutable metadata", `Quick, mutable_metadata);
  ]
