Test that `Js.Json.classify` treats JavaScript `undefined` as `JSONNull`

  $ . ./setup.sh
  $ cat > dune-project <<EOF
  > (lang dune 3.8)
  > (using melange 0.1)
  > EOF
  $ cat > dune <<EOF
  > (melange.emit
  >  (target out)
  >  (emit_stdlib false)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > x.ml <<EOF
  > let undefined_json : Js.Json.t = Obj.magic Js.undefined
  > 
  > let () =
  >   match Js.Json.classify undefined_json with
  >   | Js.Json.JSONNull -> Js.log "null"
  >   | Js.Json.JSONObject _ -> Js.log "object"
  >   | _ -> Js.log "other"
  > EOF

  $ dune build @melange
  $ node _build/default/out/x.js
  object
