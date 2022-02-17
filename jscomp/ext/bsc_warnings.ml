(* Copyright (C) 2020- Hongbo Zhang, Authors of ReScript
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)



(**
  See the meanings of the warning codes here: https://caml.inria.fr/pub/docs/manual-ocaml/comp.html#sec281

  - 30 Two labels or constructors of the same name are defined in two mutually recursive types.
  - 40 Constructor or label name used out of scope.

  - 6 Label omitted in function application.
  - 7 Method overridden.
  - 9 Missing fields in a record pattern. (*Not always desired, in some cases need [@@@warning "+9"] *)
  - 27 Innocuous unused variable: unused variable that is not bound with let nor as, and doesn’t start with an underscore (_) character.
  - 29 Unescaped end-of-line in a string constant (non-portable code).
  - 32 .. 39 Unused blabla
  - 44 Open statement shadows an already defined identifier.
  - 45 Open statement shadows an already defined label or constructor.
  - 48 Implicit elimination of optional arguments. https://caml.inria.fr/mantis/view.php?id=6352
  - 101 (bsb-specific) unsafe polymorphic comparison.
*)


(*
  The purpose of default warning set is to make it strict while
  not annoy user too much

  -4 Fragile pattern matching: matching that will remain complete even if additional con- structors are added to one of the variant types matched.
  We turn it off since common pattern
  {[
    match x with | A -> .. |  _ -> false
  ]}

  -9 Missing fields in a record pattern.
  only in some special cases that we need all fields being listed

  We encourage people to write code based on type based disambigution
  40,41,42 are enabled for compatiblity reasons
  -40 Constructor or label name used out of scope
  This is intentional, we should never warn it
  - 41 Ambiguous constructor or label name.
  It is turned off since it prevents such cases below:
  {[
    type a = A |B
    type b = A | B | C
  ]}
  - 42 Disambiguated constructor or label name (compatibility warning).

  - 50 Unexpected documentation comment.

  - 102 Bs_polymorphic_comparison
*)
let defaults_w = "+a-4-29-40-41-42-44-45-48-58-59-60-102"
let defaults_warn_error = "-a+5+6+101+109";;
(*TODO: add +10*)
