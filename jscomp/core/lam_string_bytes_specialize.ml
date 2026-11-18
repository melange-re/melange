open Import

let string_primitive : Lam_primitive.t -> Lam_primitive.t option = function
  | Pbyteslength -> Some Pstringlength
  | Pbytesrefs -> Some Pstringrefs
  | Pbytesrefu -> Some Pstringrefu
  | Pbytes_load_16 unsafe -> Some (Pstring_load_16 unsafe)
  | Pbytes_load_32 unsafe -> Some (Pstring_load_32 unsafe)
  (* The existing 64-bit readers differ for JavaScript code units above 255.
     Keep their conversion until the two paths have equivalent behavior. *)
  | _ -> None

exception Unsupported_use

let specialize (fn : Lam.lfunction) param =
  let has_read = ref false in
  let rec rewrite borrowed (lam : Lam.t) =
    match lam with
    | Lvar id | Lmutvar id ->
        if Ident.Set.mem id borrowed then raise_notrace Unsupported_use;
        lam
    | Llet (kind, id, (Lvar source as arg), body)
      when Ident.Set.mem source borrowed ->
        (* Alias bindings preserve the representation; their uses must satisfy
           the same restrictions as the original parameter. *)
        Lam.let_ kind id arg (rewrite (Ident.Set.add id borrowed) body)
    | (Lassign (id, _) | Lifused (id, _)) when Ident.Set.mem id borrowed ->
        raise_notrace Unsupported_use
    | Lprim { primitive; args = (Lvar id as arg) :: args; loc }
      when Ident.Set.mem id borrowed -> (
        match string_primitive primitive with
        | None -> raise_notrace Unsupported_use
        | Some primitive ->
            has_read := true;
            Lam.prim ~primitive
              ~args:(arg :: List.map args ~f:(rewrite borrowed))
              ~loc)
    | _ ->
        (* This also checks every nested closure. Returning a closure that only
           reads the captured string is safe; returning or storing the byte
           parameter itself reaches the rejected Lvar case above. *)
        Lam.inner_map lam (rewrite borrowed)
  in
  match rewrite (Ident.Set.singleton param) fn.body with
  | body ->
      if !has_read then
        Some
          (Lam.function_ ~arity:fn.arity ~params:fn.params ~body ~attr:fn.attr)
      else None
  | exception Unsupported_use -> None

let variants = function
  | Lam.Lfunction fn ->
      List.mapi fn.params ~f:(fun index param ->
          match specialize fn param with
          | Some lambda -> Some (index, lambda)
          | None -> None)
      |> List.filter_map ~f:Fun.id
  | _ -> []
