(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

open Import
open Lambda
open Debuginfo.Scoped_location

(* Tail call info in annotation files *)

let rec emit_tail_infos is_tail lambda =
  match lambda with
  | Lvar _ -> ()
  | Lmutvar _ -> ()
  | Lconst _ -> ()
  | Lapply ap ->
      (* Note: is_tail does not take backend-specific logic into
           account (maximum number of parameters, etc.)  so it may
           over-approximate tail-callness.

           Trying to do something more fine-grained would result in
           different warnings depending on whether the native or
           bytecode compiler is used. *)
      (let maybe_warn ~is_tail ~expect_tail =
         if is_tail <> expect_tail then
           Location.prerr_warning (to_location ap.ap_loc)
             (Warnings.Wrong_tailcall_expectation expect_tail)
       in
       match ap.ap_tailcall with
       | Default_tailcall -> ()
       | Tailcall_expectation expect_tail -> maybe_warn ~is_tail ~expect_tail);
      emit_tail_infos false ap.ap_func;
      list_emit_tail_infos false ap.ap_args
#if OCAML_VERSION >= (5,2,0)
  | Lfunction lfun -> emit_tail_infos_lfunction is_tail lfun
#else
  | Lfunction { body = lam; _ } -> emit_tail_infos true lam
#endif
  | Llet (_, _k, _, lam, body) | Lmutlet (_k, _, lam, body) ->
      emit_tail_infos false lam;
      emit_tail_infos is_tail body
  | Lletrec (bindings, body) ->
#if OCAML_VERSION >= (5,2,0)
      List.iter
        ~f:(fun { def; _ } -> emit_tail_infos_lfunction is_tail def)
        bindings;
#else
      List.iter ~f:(fun (_, lam) -> emit_tail_infos false lam) bindings;
#endif
      emit_tail_infos is_tail body
  | Lprim ((Pbytes_to_string | Pbytes_of_string), [ arg ], _) ->
      emit_tail_infos is_tail arg
  | Lprim (Psequand, [ arg1; arg2 ], _) | Lprim (Psequor, [ arg1; arg2 ], _) ->
      emit_tail_infos false arg1;
      emit_tail_infos is_tail arg2
  | Lprim (_, l, _) -> list_emit_tail_infos false l
  | Lswitch (lam, sw, _loc) ->
      emit_tail_infos false lam;
      list_emit_tail_infos_fun snd is_tail sw.sw_consts;
      list_emit_tail_infos_fun snd is_tail sw.sw_blocks;
      Option.iter ~f:(emit_tail_infos is_tail) sw.sw_failaction
  | Lstringswitch (lam, sw, d, _) ->
      emit_tail_infos false lam;
      List.iter ~f:(fun (_, lam) -> emit_tail_infos is_tail lam) sw;
      Option.iter ~f:(emit_tail_infos is_tail) d
  | Lstaticraise (_, l) -> list_emit_tail_infos false l
  | Lstaticcatch (body, _, handler) ->
      emit_tail_infos is_tail body;
      emit_tail_infos is_tail handler
  | Ltrywith (body, _, handler) ->
      emit_tail_infos false body;
      emit_tail_infos is_tail handler
  | Lifthenelse (cond, ifso, ifno) ->
      emit_tail_infos false cond;
      emit_tail_infos is_tail ifso;
      emit_tail_infos is_tail ifno
  | Lsequence (lam1, lam2) ->
      emit_tail_infos false lam1;
      emit_tail_infos is_tail lam2
  | Lwhile (cond, body) ->
      emit_tail_infos false cond;
      emit_tail_infos false body
  | Lfor (_, low, high, _, body) ->
      emit_tail_infos false low;
      emit_tail_infos false high;
      emit_tail_infos false body
  | Lassign (_, lam) -> emit_tail_infos false lam
  | Lsend (_, meth, obj, args, _loc) ->
      emit_tail_infos false meth;
      emit_tail_infos false obj;
      list_emit_tail_infos false args
  | Levent (lam, _) -> emit_tail_infos is_tail lam
  | Lifused (_, lam) -> emit_tail_infos is_tail lam

and list_emit_tail_infos_fun f is_tail =
  List.iter ~f:(fun x -> emit_tail_infos is_tail (f x))

and list_emit_tail_infos is_tail = List.iter ~f:(emit_tail_infos is_tail)

#if OCAML_VERSION >= (5,2,0)
and emit_tail_infos_lfunction _is_tail lfun =
  (* Tail call annotations are only meaningful with respect to the
     current function; so entering a function resets the [is_tail] flag *)
  emit_tail_infos true lfun.body
#endif

let simplify_lambda lam =
  let lam = lam |> Tmc.rewrite in
  if
    !Clflags.annotations
    || Warnings.is_active (Warnings.Wrong_tailcall_expectation true)
  then emit_tail_infos true lam;
  lam
