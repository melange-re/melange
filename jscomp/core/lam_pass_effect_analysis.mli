open Import

type mode =
  | Conservative
  | Optimistic

(** Parse effect-analysis mode from environment.

    [MELANGE_EFFECT_ANALYSIS_MODE=optimistic] selects optimistic mode.
    Any other value (or missing variable) selects conservative mode.
*)
val mode_from_env : unit -> mode

(** Conservative effect analysis for top-level lambda bindings.

    A binding is considered effectful if:
    - it directly uses effect runtime primitives, or
    - it contains unknown calls we cannot classify precisely, or
    - it calls another local binding already classified as effectful, or
    - it calls a known effectful export from another module (via `.cmj` summary).
*)
val effectful_bindings : mode:mode -> Lam_group.t list -> Ident.Set.t

val mode_to_string : mode -> string
