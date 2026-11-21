Property and index operations require each object, key and value argument.

  $ . ./setup.sh
  $ cat > set_value.ml <<'EOF'
  > type t
  > external f : t -> unit -> unit = "x" [@@mel.set]
  > let run o = f o ()
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o set_value.js set_value.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > set_object.ml <<'EOF'
  > type t
  > external f : unit -> int -> unit = "x" [@@mel.set]
  > let run o = f () 1
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o set_object.js set_object.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > set_index_value.ml <<'EOF'
  > type t
  > external f : t -> string -> unit -> unit = "" [@@mel.set_index]
  > let run o = f o "x" ()
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o set_index_value.js set_index_value.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > set_index_object.ml <<'EOF'
  > type t
  > external f : unit -> string -> int -> unit = "" [@@mel.set_index]
  > let run o = f () "x" 1
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o set_index_object.js set_index_object.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > set_index_key.ml <<'EOF'
  > type t
  > external f : t -> unit -> int -> unit = "" [@@mel.set_index]
  > let run o = f o () 1
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o set_index_key.js set_index_key.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > get_index_key.ml <<'EOF'
  > type t
  > external f : t -> unit -> int = "" [@@mel.get_index]
  > let run o = f o ()
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o get_index_key.js get_index_key.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ cat > get_index_object.ml <<'EOF'
  > type t
  > external f : unit -> string -> int = "" [@@mel.get_index]
  > let run o = f () "x"
  > EOF
  $ melc --color=never -w -a -alert -unprocessed -ppx melppx -o get_index_object.js get_index_object.ml 2> error.log
  [125]
  $ sed -E 's/line [0-9]+/line LINE/g; s/characters [0-9]+-[0-9]+/characters RANGE/g; /^[[:space:]]*$/d' error.log
  melc: internal error, uncaught exception:
        File "jscomp/core/lam_compile_external_call.ml", line LINE, characters RANGE: Assertion failed
  $ head -n 2 set_value.ml > invalid.mli
  $ melc --color=never -alert -unprocessed -ppx melppx -c invalid.mli
  $ cat > valid.ml <<'EOF'
  > type obj
  > external set : obj -> 'a -> unit = "x" [@@mel.set]
  > external set_index : obj -> string -> 'a -> unit = "" [@@mel.set_index]
  > external get_index : obj -> string -> 'a = "" [@@mel.get_index]
  > external constant_get : (_ [@mel.as {json|{"x": 7}|json}]) -> int = "x" [@@mel.get]
  > let run o = set o (); set_index o "y" (); get_index o "z"
  > let constant = constant_get
  > EOF
  $ melc --color=never -ppx melppx -o valid.js valid.ml
  $ node <<'EOF'
  > const t = require('./valid.js');
  > const o = {z: 4};
  > console.log(t.run(o), Object.hasOwn(o, 'x'), Object.hasOwn(o, 'y'), o.x, o.y, t.constant);
  > EOF
  4 true true undefined undefined 7
