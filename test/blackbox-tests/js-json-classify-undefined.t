Test that `Js.Json.classify` distinguishes JavaScript `undefined`

  $ . ./setup.sh
  $ cat > x.ml <<EOF
  > let undefined_json : Js.Json.t = Obj.magic Js.undefined
  > 
  > let () =
  >   match Js.Json.classify undefined_json with
  >   | Js.Json.JSONUndefined -> Js.log "undefined"
  >   | Js.Json.JSONNull -> Js.log "null"
  >   | Js.Json.JSONObject _ -> Js.log "object"
  >   | _ -> Js.log "other"
  > EOF

  $ melc -ppx melppx x.ml > x.js
  $ NODE_PATH="$INSIDE_DUNE/../../node_modules" node x.js
  undefined
