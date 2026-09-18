Generated getters and setters satisfy the PPX location invariant

  $ . ./setup.sh
  $ cat > getset_intf.mli <<'EOF'
  > type ('a, 'b) record = {
  >   mutable first : 'a;
  >   second : ('b * string) option [@mel.optional];
  > }
  > [@@deriving getSet]
  > EOF
  $ cp getset_intf.mli getset_impl.ml
  $ melc -ppx 'melppx -locations-check' -c getset_intf.mli > /dev/null
  $ melc -ppx 'melppx -locations-check' -c getset_impl.ml > /dev/null

Generated types point back to their field names

  $ generated_type_locations () {
  >   ocamlc -ppx 'melppx' -dparsetree -stop-after parsing "$1" 2>&1 |
  >     awk '
  >       /primitive_description "(firstSet|firstGet|secondGet)"/ {
  >         match($0, /"(firstSet|firstGet|secondGet)"/)
  >         name = substr($0, RSTART + 1, RLENGTH - 2)
  >         checking_types = 1
  >         want_decl = 1
  >         next
  >       }
  >       checking_types && /core_type / &&
  >         ($0 !~ / ghost[[:space:]]*$/ || $0 ~ /_none_/) {
  >         invalid_type_location = 1
  >       }
  >       want_decl && /Pprim_decl/ {
  >         want_type = 1
  >         next
  >       }
  >       want_type && /core_type / {
  >         sub(/^ +/, "")
  >         print name ": " $0
  >         want_decl = 0
  >         want_type = 0
  >       }
  >       END {
  >         if (invalid_type_location) exit 1
  >         print "all generated core types have source-backed ghost locations"
  >       }
  >     '
  > }
  $ generated_type_locations getset_impl.ml
  firstSet: core_type (getset_impl.ml[2,25+10]..[2,25+15]) ghost
  firstGet: core_type (getset_impl.ml[2,25+10]..[2,25+15]) ghost
  secondGet: core_type (getset_impl.ml[3,47+2]..[3,47+8]) ghost
  all generated core types have source-backed ghost locations
  $ generated_type_locations getset_intf.mli
  firstSet: core_type (getset_intf.mli[2,25+10]..[2,25+15]) ghost
  firstGet: core_type (getset_intf.mli[2,25+10]..[2,25+15]) ghost
  secondGet: core_type (getset_intf.mli[3,47+2]..[3,47+8]) ghost
  all generated core types have source-backed ghost locations
