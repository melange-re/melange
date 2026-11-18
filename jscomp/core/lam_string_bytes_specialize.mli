(** Specialize read-only byte parameters for callers that have an immutable
    string. The ordinary byte representation and functions are unchanged. *)

val string_primitive : Lam_primitive.t -> Lam_primitive.t option
(** The string equivalent of a supported byte-reading primitive. *)

val variants : Lam.t -> (int * Lam.t) list
(** For each eligible parameter, return its zero-based index and a function
    whose reads of that parameter and its immutable aliases use string
    primitives. A parameter must actually be read. Any other use of the byte
    value, including mutation or escape, rejects the variant.

    Nested closures may capture the parameter when all their uses are eligible
    reads. Callers must separately establish that a variant is closed and
    relocatable before exporting it to another compilation unit. *)
