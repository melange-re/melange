Inlining must tolerate incompatible constants in unreachable constructor branches.
ReScript #6471 is already fixed; exercise both integer and block fallback paths.

  $ . ./setup.sh
  $ printf '%s\n' '(lang dune 3.9)' '(using melange 0.1)' > dune-project
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (libraries melange.js)
  >  (preprocess (pps melange.ppx)))
  > EOF
  $ cat > input.ml <<'EOF'
  > module Missing_field = struct
  >   type status = Vacations of int | Sabbatical of int | Sick
  >   type person = Teacher of { age : int } | Student of { status : status }
  >   let person = Teacher { age = 12345 }
  >   let message =
  >     match person with Student {status = Vacations _ | Sick} -> "student" | _ -> "teacher"
  > end
  > module Wrong_integer = struct
  >   type status = Vacations of int | Sabbatical of int | Sick | Present
  >   type person = Teacher of { age : int } | Student of { age : status }
  >   let person = Teacher { age = 12345 }
  >   let message = match person with
  >     | Student {age = Sick} -> "sick"
  >     | Student {age = Present} -> "present"
  >     | Student {age = Vacations _ | Sabbatical _} -> "away"
  >     | Teacher _ -> "teacher"
  > end
  > module Wrong_block = struct
  >   type payload = First of int | Second of int | Third of int
  >   type status = Vacations of int | Sabbatical of int | Sick
  >   type person = Teacher of { age : payload } | Student of { age : status }
  >   let person = Teacher { age = Third 12345 }
  >   let message = match person with
  >     | Student {age = Vacations _} -> "vacation"
  >     | Student {age = Sabbatical _} -> "sabbatical"
  >     | Student {age = Sick} -> "sick"
  >     | Teacher _ -> "teacher"
  > end
  > type status = Vacations of int | Sabbatical of int | Sick | Present
  > type report_card = {passing : bool; gpa : float}
  > type person =
  >   | Teacher of {name : string; age : int}
  >   | Student of {name : string; status : status; report_card : report_card}
  > let describe = function
  >   | Teacher {name = ("Mary" | "Joe"); _} -> "party"
  >   | Teacher {name; _} -> name
  >   | Student {report_card = {passing = true; _}; _} -> "passing"
  >   | Student {report_card = {gpa = 0.; _}; status = (Vacations _ | Sabbatical _); _} -> "away"
  >   | Student {status = Sick; _} -> "sick"
  >   | Student _ -> "semester"
  > let teacher = Teacher {name = "Jane"; age = 12345}
  > let teacher_message = describe teacher
  > let student status passing gpa = Student {name = "Alex"; status; report_card = {passing; gpa}}
  > let live = [|
  >   describe (Teacher {name = "Mary"; age = 10});
  >   describe (student Present true 4.);
  >   describe (student (Vacations 3) false 0.);
  >   describe (student (Sabbatical 3) false 0.);
  >   describe (student Sick false 0.);
  >   describe (student Present false 4.);
  > |]
  > EOF
  $ dune build @melange
  $ node <<'EOF'
  > const assert = require("node:assert/strict");
  > const m = require("./_build/default/out/input.js");
  > assert.equal(m.Missing_field.message, "teacher");
  > assert.equal(m.Wrong_integer.message, "teacher");
  > assert.equal(m.Wrong_block.message, "teacher");
  > assert.equal(m.teacher_message, "Jane");
  > assert.deepEqual(m.live, ["party", "passing", "away", "away", "sick", "semester"]);
  > const teacher = {TAG: 0, name: "Jane", age: 12345};
  > Object.defineProperties(teacher, {
  >   status: {get() { throw new Error("wrong constructor's status"); }},
  >   report_card: {get() { throw new Error("wrong constructor's report card"); }}
  > });
  > assert.equal(m.describe(teacher), "Jane");
  > EOF
