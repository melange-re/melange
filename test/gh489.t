Repro for GitHub issue 489, first try setting values in nested objects with OCaml syntax

  $ . ./setup.sh
  $ cat > foo.ml <<EOF
  > type person = < age :int [@bs.set ] > Js.t
  > type entry = < person :person [@bs.set ] > Js.t
  > external entry : entry = "entry"[@@bs.val ]
  > let () = ((entry ## person) ##  age) #= 99
  > EOF
  $ melc foo.ml
  // Generated by Melange
  'use strict';
  
  
  entry.person.age = 99;
  
  /*  Not a pure module */

Now let's try with ReScript syntax

  $ cat > foo.res <<EOF
  > type person = {@set "age": int}
  > type entry = {@set "person": person}
  > @val external entry: entry = "entry"
  > entry["person"]["age"] = 99
  $ rescript_syntax -print=ml foo.res
  type nonrec person = < age: int [@set ]  >  Js.t
  type nonrec entry = < person: person [@set ]  >  Js.t
  external entry : entry = "entry"[@@val ]
  ;;((entry ## person) ## age) #= 99

  $ rescript_syntax -print=ml foo.res > foo.ml

  $ melc foo.ml
  // Generated by Melange
  'use strict';
  
  
  entry.person.age = 99;
  
  /*  Not a pure module */