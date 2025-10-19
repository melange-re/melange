type t =
  | T_NUMBER of {
  kind: number_type ;
  raw: string }
  | T_BIGINT of {
  kind: bigint_type ;
  raw: string }
  | T_STRING of (Loc.t * string * string * bool)
  | T_TEMPLATE_PART of (Loc.t * string * string * bool * bool)
  | T_IDENTIFIER of {
  loc: Loc.t ;
  value: string ;
  raw: string }
  | T_REGEXP of Loc.t * string * string
  | T_LCURLY
  | T_RCURLY
  | T_LCURLYBAR
  | T_RCURLYBAR
  | T_LPAREN
  | T_RPAREN
  | T_LBRACKET
  | T_RBRACKET
  | T_SEMICOLON
  | T_COMMA
  | T_PERIOD
  | T_ARROW
  | T_ELLIPSIS
  | T_AT
  | T_POUND
  | T_FUNCTION
  | T_IF
  | T_IN
  | T_INSTANCEOF
  | T_RETURN
  | T_SWITCH
  | T_MATCH
  | T_THIS
  | T_THROW
  | T_TRY
  | T_VAR
  | T_WHILE
  | T_WITH
  | T_CONST
  | T_LET
  | T_NULL
  | T_FALSE
  | T_TRUE
  | T_BREAK
  | T_CASE
  | T_CATCH
  | T_CONTINUE
  | T_DEFAULT
  | T_DO
  | T_FINALLY
  | T_FOR
  | T_CLASS
  | T_EXTENDS
  | T_STATIC
  | T_ELSE
  | T_NEW
  | T_DELETE
  | T_TYPEOF
  | T_VOID
  | T_ENUM
  | T_EXPORT
  | T_IMPORT
  | T_SUPER
  | T_IMPLEMENTS
  | T_INTERFACE
  | T_PACKAGE
  | T_PRIVATE
  | T_PROTECTED
  | T_PUBLIC
  | T_YIELD
  | T_DEBUGGER
  | T_DECLARE
  | T_TYPE
  | T_OPAQUE
  | T_OF
  | T_ASYNC
  | T_AWAIT
  | T_CHECKS
  | T_RSHIFT3_ASSIGN
  | T_RSHIFT_ASSIGN
  | T_LSHIFT_ASSIGN
  | T_BIT_XOR_ASSIGN
  | T_BIT_OR_ASSIGN
  | T_BIT_AND_ASSIGN
  | T_MOD_ASSIGN
  | T_DIV_ASSIGN
  | T_MULT_ASSIGN
  | T_EXP_ASSIGN
  | T_MINUS_ASSIGN
  | T_PLUS_ASSIGN
  | T_NULLISH_ASSIGN
  | T_AND_ASSIGN
  | T_OR_ASSIGN
  | T_ASSIGN
  | T_PLING_PERIOD
  | T_PLING_PLING
  | T_PLING
  | T_COLON
  | T_OR
  | T_AND
  | T_BIT_OR
  | T_BIT_XOR
  | T_BIT_AND
  | T_EQUAL
  | T_NOT_EQUAL
  | T_STRICT_EQUAL
  | T_STRICT_NOT_EQUAL
  | T_LESS_THAN_EQUAL
  | T_GREATER_THAN_EQUAL
  | T_LESS_THAN
  | T_GREATER_THAN
  | T_LSHIFT
  | T_RSHIFT
  | T_RSHIFT3
  | T_PLUS
  | T_MINUS
  | T_DIV
  | T_MULT
  | T_EXP
  | T_MOD
  | T_NOT
  | T_BIT_NOT
  | T_INCR
  | T_DECR
  | T_INTERPRETER of Loc.t * string
  | T_ERROR of string
  | T_EOF
  | T_JSX_IDENTIFIER of {
  raw: string ;
  loc: Loc.t }
  | T_JSX_CHILD_TEXT of Loc.t * string * string
  | T_JSX_QUOTE_TEXT of Loc.t * string * string
  | T_ANY_TYPE
  | T_MIXED_TYPE
  | T_EMPTY_TYPE
  | T_BOOLEAN_TYPE of bool_or_boolean
  | T_NUMBER_TYPE
  | T_BIGINT_TYPE
  | T_NUMBER_SINGLETON_TYPE of
  {
  kind: number_type ;
  value: float ;
  raw: string }
  | T_BIGINT_SINGLETON_TYPE of
  {
  kind: bigint_type ;
  value: int64 option ;
  raw: string }
  | T_STRING_TYPE
  | T_VOID_TYPE
  | T_SYMBOL_TYPE
  | T_UNKNOWN_TYPE
  | T_NEVER_TYPE
  | T_UNDEFINED_TYPE
  | T_KEYOF
  | T_READONLY
  | T_INFER
  | T_IS
  | T_ASSERTS
  | T_IMPLIES
  | T_RENDERS_QUESTION
  | T_RENDERS_STAR
and bool_or_boolean =
  | BOOL
  | BOOLEAN
and number_type =
  | BINARY
  | LEGACY_OCTAL
  | LEGACY_NON_OCTAL
  | OCTAL
  | NORMAL
and bigint_type =
  | BIG_BINARY
  | BIG_OCTAL
  | BIG_NORMAL [@@deriving eq]
include
  struct
    let _ = fun (_ : t) -> ()
    let _ = fun (_ : bool_or_boolean) -> ()
    let _ = fun (_ : number_type) -> ()
    let _ = fun (_ : bigint_type) -> ()
    let rec equal : t -> t -> bool =
      ((let __12 = equal_bigint_type
        and __11 = equal_number_type
        and __10 = equal_bool_or_boolean
        and __9 = Loc.equal
        and __8 = Loc.equal
        and __7 = Loc.equal
        and __6 = Loc.equal
        and __5 = Loc.equal
        and __4 = Loc.equal
        and __3 = Loc.equal
        and __2 = Loc.equal
        and __1 = equal_bigint_type
        and __0 = equal_number_type in
        ((            fun lhs rhs ->
              match (lhs, rhs) with
              | (T_NUMBER { kind = lhskind; raw = lhsraw }, T_NUMBER
                 { kind = rhskind; raw = rhsraw }) ->
                  (__0 lhskind rhskind) &&
                    (((fun (a : string) b -> a = b)) lhsraw rhsraw)
              | (T_BIGINT { kind = lhskind; raw = lhsraw }, T_BIGINT
                 { kind = rhskind; raw = rhsraw }) ->
                  (__1 lhskind rhskind) &&
                    (((fun (a : string) b -> a = b)) lhsraw rhsraw)
              | (T_STRING lhs0, T_STRING rhs0) ->
                  ((fun (lhs0, lhs1, lhs2, lhs3) (rhs0, rhs1, rhs2, rhs3) ->
                      (((__2 lhs0 rhs0) &&
                          ((fun (a : string) b -> a = b) lhs1 rhs1))
                         && ((fun (a : string) b -> a = b) lhs2 rhs2))
                        && ((fun (a : bool) b -> a = b) lhs3 rhs3))) lhs0
                    rhs0
              | (T_TEMPLATE_PART lhs0, T_TEMPLATE_PART rhs0) ->
                  ((fun (lhs0, lhs1, lhs2, lhs3, lhs4)
                      (rhs0, rhs1, rhs2, rhs3, rhs4) ->
                      ((((__3 lhs0 rhs0) &&
                           ((fun (a : string) b -> a = b) lhs1 rhs1))
                          && ((fun (a : string) b -> a = b) lhs2 rhs2))
                         && ((fun (a : bool) b -> a = b) lhs3 rhs3))
                        && ((fun (a : bool) b -> a = b) lhs4 rhs4))) lhs0
                    rhs0
              | (T_IDENTIFIER
                 { loc = lhsloc; value = lhsvalue; raw = lhsraw },
                 T_IDENTIFIER
                 { loc = rhsloc; value = rhsvalue; raw = rhsraw }) ->
                  ((__4 lhsloc rhsloc) &&
                     ((fun (a : string) b -> a = b) lhsvalue rhsvalue))
                    && (((fun (a : string) b -> a = b)) lhsraw rhsraw)
              | (T_REGEXP (lhs0, lhs1, lhs2), T_REGEXP (rhs0, rhs1, rhs2)) ->
                  ((__5 lhs0 rhs0) &&
                     ((fun (a : string) b -> a = b) lhs1 rhs1))
                    && (((fun (a : string) b -> a = b)) lhs2 rhs2)
              | (T_LCURLY, T_LCURLY) -> true
              | (T_RCURLY, T_RCURLY) -> true
              | (T_LCURLYBAR, T_LCURLYBAR) -> true
              | (T_RCURLYBAR, T_RCURLYBAR) -> true
              | (T_LPAREN, T_LPAREN) -> true
              | (T_RPAREN, T_RPAREN) -> true
              | (T_LBRACKET, T_LBRACKET) -> true
              | (T_RBRACKET, T_RBRACKET) -> true
              | (T_SEMICOLON, T_SEMICOLON) -> true
              | (T_COMMA, T_COMMA) -> true
              | (T_PERIOD, T_PERIOD) -> true
              | (T_ARROW, T_ARROW) -> true
              | (T_ELLIPSIS, T_ELLIPSIS) -> true
              | (T_AT, T_AT) -> true
              | (T_POUND, T_POUND) -> true
              | (T_FUNCTION, T_FUNCTION) -> true
              | (T_IF, T_IF) -> true
              | (T_IN, T_IN) -> true
              | (T_INSTANCEOF, T_INSTANCEOF) -> true
              | (T_RETURN, T_RETURN) -> true
              | (T_SWITCH, T_SWITCH) -> true
              | (T_MATCH, T_MATCH) -> true
              | (T_THIS, T_THIS) -> true
              | (T_THROW, T_THROW) -> true
              | (T_TRY, T_TRY) -> true
              | (T_VAR, T_VAR) -> true
              | (T_WHILE, T_WHILE) -> true
              | (T_WITH, T_WITH) -> true
              | (T_CONST, T_CONST) -> true
              | (T_LET, T_LET) -> true
              | (T_NULL, T_NULL) -> true
              | (T_FALSE, T_FALSE) -> true
              | (T_TRUE, T_TRUE) -> true
              | (T_BREAK, T_BREAK) -> true
              | (T_CASE, T_CASE) -> true
              | (T_CATCH, T_CATCH) -> true
              | (T_CONTINUE, T_CONTINUE) -> true
              | (T_DEFAULT, T_DEFAULT) -> true
              | (T_DO, T_DO) -> true
              | (T_FINALLY, T_FINALLY) -> true
              | (T_FOR, T_FOR) -> true
              | (T_CLASS, T_CLASS) -> true
              | (T_EXTENDS, T_EXTENDS) -> true
              | (T_STATIC, T_STATIC) -> true
              | (T_ELSE, T_ELSE) -> true
              | (T_NEW, T_NEW) -> true
              | (T_DELETE, T_DELETE) -> true
              | (T_TYPEOF, T_TYPEOF) -> true
              | (T_VOID, T_VOID) -> true
              | (T_ENUM, T_ENUM) -> true
              | (T_EXPORT, T_EXPORT) -> true
              | (T_IMPORT, T_IMPORT) -> true
              | (T_SUPER, T_SUPER) -> true
              | (T_IMPLEMENTS, T_IMPLEMENTS) -> true
              | (T_INTERFACE, T_INTERFACE) -> true
              | (T_PACKAGE, T_PACKAGE) -> true
              | (T_PRIVATE, T_PRIVATE) -> true
              | (T_PROTECTED, T_PROTECTED) -> true
              | (T_PUBLIC, T_PUBLIC) -> true
              | (T_YIELD, T_YIELD) -> true
              | (T_DEBUGGER, T_DEBUGGER) -> true
              | (T_DECLARE, T_DECLARE) -> true
              | (T_TYPE, T_TYPE) -> true
              | (T_OPAQUE, T_OPAQUE) -> true
              | (T_OF, T_OF) -> true
              | (T_ASYNC, T_ASYNC) -> true
              | (T_AWAIT, T_AWAIT) -> true
              | (T_CHECKS, T_CHECKS) -> true
              | (T_RSHIFT3_ASSIGN, T_RSHIFT3_ASSIGN) -> true
              | (T_RSHIFT_ASSIGN, T_RSHIFT_ASSIGN) -> true
              | (T_LSHIFT_ASSIGN, T_LSHIFT_ASSIGN) -> true
              | (T_BIT_XOR_ASSIGN, T_BIT_XOR_ASSIGN) -> true
              | (T_BIT_OR_ASSIGN, T_BIT_OR_ASSIGN) -> true
              | (T_BIT_AND_ASSIGN, T_BIT_AND_ASSIGN) -> true
              | (T_MOD_ASSIGN, T_MOD_ASSIGN) -> true
              | (T_DIV_ASSIGN, T_DIV_ASSIGN) -> true
              | (T_MULT_ASSIGN, T_MULT_ASSIGN) -> true
              | (T_EXP_ASSIGN, T_EXP_ASSIGN) -> true
              | (T_MINUS_ASSIGN, T_MINUS_ASSIGN) -> true
              | (T_PLUS_ASSIGN, T_PLUS_ASSIGN) -> true
              | (T_NULLISH_ASSIGN, T_NULLISH_ASSIGN) -> true
              | (T_AND_ASSIGN, T_AND_ASSIGN) -> true
              | (T_OR_ASSIGN, T_OR_ASSIGN) -> true
              | (T_ASSIGN, T_ASSIGN) -> true
              | (T_PLING_PERIOD, T_PLING_PERIOD) -> true
              | (T_PLING_PLING, T_PLING_PLING) -> true
              | (T_PLING, T_PLING) -> true
              | (T_COLON, T_COLON) -> true
              | (T_OR, T_OR) -> true
              | (T_AND, T_AND) -> true
              | (T_BIT_OR, T_BIT_OR) -> true
              | (T_BIT_XOR, T_BIT_XOR) -> true
              | (T_BIT_AND, T_BIT_AND) -> true
              | (T_EQUAL, T_EQUAL) -> true
              | (T_NOT_EQUAL, T_NOT_EQUAL) -> true
              | (T_STRICT_EQUAL, T_STRICT_EQUAL) -> true
              | (T_STRICT_NOT_EQUAL, T_STRICT_NOT_EQUAL) -> true
              | (T_LESS_THAN_EQUAL, T_LESS_THAN_EQUAL) -> true
              | (T_GREATER_THAN_EQUAL, T_GREATER_THAN_EQUAL) -> true
              | (T_LESS_THAN, T_LESS_THAN) -> true
              | (T_GREATER_THAN, T_GREATER_THAN) -> true
              | (T_LSHIFT, T_LSHIFT) -> true
              | (T_RSHIFT, T_RSHIFT) -> true
              | (T_RSHIFT3, T_RSHIFT3) -> true
              | (T_PLUS, T_PLUS) -> true
              | (T_MINUS, T_MINUS) -> true
              | (T_DIV, T_DIV) -> true
              | (T_MULT, T_MULT) -> true
              | (T_EXP, T_EXP) -> true
              | (T_MOD, T_MOD) -> true
              | (T_NOT, T_NOT) -> true
              | (T_BIT_NOT, T_BIT_NOT) -> true
              | (T_INCR, T_INCR) -> true
              | (T_DECR, T_DECR) -> true
              | (T_INTERPRETER (lhs0, lhs1), T_INTERPRETER (rhs0, rhs1)) ->
                  (__6 lhs0 rhs0) &&
                    (((fun (a : string) b -> a = b)) lhs1 rhs1)
              | (T_ERROR lhs0, T_ERROR rhs0) ->
                  ((fun (a : string) b -> a = b)) lhs0 rhs0
              | (T_EOF, T_EOF) -> true
              | (T_JSX_IDENTIFIER { raw = lhsraw; loc = lhsloc },
                 T_JSX_IDENTIFIER { raw = rhsraw; loc = rhsloc }) ->
                  ((fun (a : string) b -> a = b) lhsraw rhsraw) &&
                    (__7 lhsloc rhsloc)
              | (T_JSX_CHILD_TEXT (lhs0, lhs1, lhs2), T_JSX_CHILD_TEXT
                 (rhs0, rhs1, rhs2)) ->
                  ((__8 lhs0 rhs0) &&
                     ((fun (a : string) b -> a = b) lhs1 rhs1))
                    && (((fun (a : string) b -> a = b)) lhs2 rhs2)
              | (T_JSX_QUOTE_TEXT (lhs0, lhs1, lhs2), T_JSX_QUOTE_TEXT
                 (rhs0, rhs1, rhs2)) ->
                  ((__9 lhs0 rhs0) &&
                     ((fun (a : string) b -> a = b) lhs1 rhs1))
                    && (((fun (a : string) b -> a = b)) lhs2 rhs2)
              | (T_ANY_TYPE, T_ANY_TYPE) -> true
              | (T_MIXED_TYPE, T_MIXED_TYPE) -> true
              | (T_EMPTY_TYPE, T_EMPTY_TYPE) -> true
              | (T_BOOLEAN_TYPE lhs0, T_BOOLEAN_TYPE rhs0) -> __10 lhs0 rhs0
              | (T_NUMBER_TYPE, T_NUMBER_TYPE) -> true
              | (T_BIGINT_TYPE, T_BIGINT_TYPE) -> true
              | (T_NUMBER_SINGLETON_TYPE
                 { kind = lhskind; value = lhsvalue; raw = lhsraw },
                 T_NUMBER_SINGLETON_TYPE
                 { kind = rhskind; value = rhsvalue; raw = rhsraw }) ->
                  ((__11 lhskind rhskind) &&
                     ((fun (a : float) b -> a = b) lhsvalue rhsvalue))
                    && (((fun (a : string) b -> a = b)) lhsraw rhsraw)
              | (T_BIGINT_SINGLETON_TYPE
                 { kind = lhskind; value = lhsvalue; raw = lhsraw },
                 T_BIGINT_SINGLETON_TYPE
                 { kind = rhskind; value = rhsvalue; raw = rhsraw }) ->
                  ((__12 lhskind rhskind) &&
                     ((fun x y ->
                         match (x, y) with
                         | (None, None) -> true
                         | (Some a, Some b) ->
                             ((fun (a : int64) b -> a = b)) a b
                         | _ -> false) lhsvalue rhsvalue))
                    && (((fun (a : string) b -> a = b)) lhsraw rhsraw)
              | (T_STRING_TYPE, T_STRING_TYPE) -> true
              | (T_VOID_TYPE, T_VOID_TYPE) -> true
              | (T_SYMBOL_TYPE, T_SYMBOL_TYPE) -> true
              | (T_UNKNOWN_TYPE, T_UNKNOWN_TYPE) -> true
              | (T_NEVER_TYPE, T_NEVER_TYPE) -> true
              | (T_UNDEFINED_TYPE, T_UNDEFINED_TYPE) -> true
              | (T_KEYOF, T_KEYOF) -> true
              | (T_READONLY, T_READONLY) -> true
              | (T_INFER, T_INFER) -> true
              | (T_IS, T_IS) -> true
              | (T_ASSERTS, T_ASSERTS) -> true
              | (T_IMPLIES, T_IMPLIES) -> true
              | (T_RENDERS_QUESTION, T_RENDERS_QUESTION) -> true
              | (T_RENDERS_STAR, T_RENDERS_STAR) -> true
              | _ -> false)
          [@ocaml.warning "-A"]))
      [@ocaml.warning "-39"])[@@ocaml.warning "-39"]
    and equal_bool_or_boolean :
      bool_or_boolean -> bool_or_boolean -> bool =
      ((          fun lhs rhs ->
            match (lhs, rhs) with
            | (BOOL, BOOL) -> true
            | (BOOLEAN, BOOLEAN) -> true
            | _ -> false)
      [@ocaml.warning "-39"][@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    and equal_number_type :
      number_type -> number_type -> bool =
      ((          fun lhs rhs ->
            match (lhs, rhs) with
            | (BINARY, BINARY) -> true
            | (LEGACY_OCTAL, LEGACY_OCTAL) -> true
            | (LEGACY_NON_OCTAL, LEGACY_NON_OCTAL) -> true
            | (OCTAL, OCTAL) -> true
            | (NORMAL, NORMAL) -> true
            | _ -> false)
      [@ocaml.warning "-39"][@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    and equal_bigint_type :
      bigint_type -> bigint_type -> bool =
      ((          fun lhs rhs ->
            match (lhs, rhs) with
            | (BIG_BINARY, BIG_BINARY) -> true
            | (BIG_OCTAL, BIG_OCTAL) -> true
            | (BIG_NORMAL, BIG_NORMAL) -> true
            | _ -> false)
      [@ocaml.warning "-39"][@ocaml.warning "-A"])[@@ocaml.warning "-39"]
    let _ = equal
    and _ = equal_bool_or_boolean
    and _ = equal_number_type
    and _ = equal_bigint_type
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
let token_to_string =
  function
  | T_NUMBER _ -> "T_NUMBER"
  | T_BIGINT _ -> "T_BIGINT"
  | T_STRING _ -> "T_STRING"
  | T_TEMPLATE_PART _ -> "T_TEMPLATE_PART"
  | T_IDENTIFIER _ -> "T_IDENTIFIER"
  | T_REGEXP _ -> "T_REGEXP"
  | T_FUNCTION -> "T_FUNCTION"
  | T_IF -> "T_IF"
  | T_IN -> "T_IN"
  | T_INSTANCEOF -> "T_INSTANCEOF"
  | T_RETURN -> "T_RETURN"
  | T_SWITCH -> "T_SWITCH"
  | T_MATCH -> "T_MATCH"
  | T_THIS -> "T_THIS"
  | T_THROW -> "T_THROW"
  | T_TRY -> "T_TRY"
  | T_VAR -> "T_VAR"
  | T_WHILE -> "T_WHILE"
  | T_WITH -> "T_WITH"
  | T_CONST -> "T_CONST"
  | T_LET -> "T_LET"
  | T_NULL -> "T_NULL"
  | T_FALSE -> "T_FALSE"
  | T_TRUE -> "T_TRUE"
  | T_BREAK -> "T_BREAK"
  | T_CASE -> "T_CASE"
  | T_CATCH -> "T_CATCH"
  | T_CONTINUE -> "T_CONTINUE"
  | T_DEFAULT -> "T_DEFAULT"
  | T_DO -> "T_DO"
  | T_FINALLY -> "T_FINALLY"
  | T_FOR -> "T_FOR"
  | T_CLASS -> "T_CLASS"
  | T_EXTENDS -> "T_EXTENDS"
  | T_STATIC -> "T_STATIC"
  | T_ELSE -> "T_ELSE"
  | T_NEW -> "T_NEW"
  | T_DELETE -> "T_DELETE"
  | T_TYPEOF -> "T_TYPEOF"
  | T_VOID -> "T_VOID"
  | T_ENUM -> "T_ENUM"
  | T_EXPORT -> "T_EXPORT"
  | T_IMPORT -> "T_IMPORT"
  | T_SUPER -> "T_SUPER"
  | T_IMPLEMENTS -> "T_IMPLEMENTS"
  | T_INTERFACE -> "T_INTERFACE"
  | T_PACKAGE -> "T_PACKAGE"
  | T_PRIVATE -> "T_PRIVATE"
  | T_PROTECTED -> "T_PROTECTED"
  | T_PUBLIC -> "T_PUBLIC"
  | T_YIELD -> "T_YIELD"
  | T_DEBUGGER -> "T_DEBUGGER"
  | T_DECLARE -> "T_DECLARE"
  | T_TYPE -> "T_TYPE"
  | T_OPAQUE -> "T_OPAQUE"
  | T_OF -> "T_OF"
  | T_ASYNC -> "T_ASYNC"
  | T_AWAIT -> "T_AWAIT"
  | T_CHECKS -> "T_CHECKS"
  | T_LCURLY -> "T_LCURLY"
  | T_RCURLY -> "T_RCURLY"
  | T_LCURLYBAR -> "T_LCURLYBAR"
  | T_RCURLYBAR -> "T_RCURLYBAR"
  | T_LPAREN -> "T_LPAREN"
  | T_RPAREN -> "T_RPAREN"
  | T_LBRACKET -> "T_LBRACKET"
  | T_RBRACKET -> "T_RBRACKET"
  | T_SEMICOLON -> "T_SEMICOLON"
  | T_COMMA -> "T_COMMA"
  | T_PERIOD -> "T_PERIOD"
  | T_ARROW -> "T_ARROW"
  | T_ELLIPSIS -> "T_ELLIPSIS"
  | T_AT -> "T_AT"
  | T_POUND -> "T_POUND"
  | T_RSHIFT3_ASSIGN -> "T_RSHIFT3_ASSIGN"
  | T_RSHIFT_ASSIGN -> "T_RSHIFT_ASSIGN"
  | T_LSHIFT_ASSIGN -> "T_LSHIFT_ASSIGN"
  | T_BIT_XOR_ASSIGN -> "T_BIT_XOR_ASSIGN"
  | T_BIT_OR_ASSIGN -> "T_BIT_OR_ASSIGN"
  | T_BIT_AND_ASSIGN -> "T_BIT_AND_ASSIGN"
  | T_MOD_ASSIGN -> "T_MOD_ASSIGN"
  | T_DIV_ASSIGN -> "T_DIV_ASSIGN"
  | T_MULT_ASSIGN -> "T_MULT_ASSIGN"
  | T_EXP_ASSIGN -> "T_EXP_ASSIGN"
  | T_MINUS_ASSIGN -> "T_MINUS_ASSIGN"
  | T_PLUS_ASSIGN -> "T_PLUS_ASSIGN"
  | T_NULLISH_ASSIGN -> "T_NULLISH_ASSIGN"
  | T_AND_ASSIGN -> "T_AND_ASSIGN"
  | T_OR_ASSIGN -> "T_OR_ASSIGN"
  | T_ASSIGN -> "T_ASSIGN"
  | T_PLING_PERIOD -> "T_PLING_PERIOD"
  | T_PLING_PLING -> "T_PLING_PLING"
  | T_PLING -> "T_PLING"
  | T_COLON -> "T_COLON"
  | T_OR -> "T_OR"
  | T_AND -> "T_AND"
  | T_BIT_OR -> "T_BIT_OR"
  | T_BIT_XOR -> "T_BIT_XOR"
  | T_BIT_AND -> "T_BIT_AND"
  | T_EQUAL -> "T_EQUAL"
  | T_NOT_EQUAL -> "T_NOT_EQUAL"
  | T_STRICT_EQUAL -> "T_STRICT_EQUAL"
  | T_STRICT_NOT_EQUAL -> "T_STRICT_NOT_EQUAL"
  | T_LESS_THAN_EQUAL -> "T_LESS_THAN_EQUAL"
  | T_GREATER_THAN_EQUAL -> "T_GREATER_THAN_EQUAL"
  | T_LESS_THAN -> "T_LESS_THAN"
  | T_GREATER_THAN -> "T_GREATER_THAN"
  | T_LSHIFT -> "T_LSHIFT"
  | T_RSHIFT -> "T_RSHIFT"
  | T_RSHIFT3 -> "T_RSHIFT3"
  | T_PLUS -> "T_PLUS"
  | T_MINUS -> "T_MINUS"
  | T_DIV -> "T_DIV"
  | T_MULT -> "T_MULT"
  | T_EXP -> "T_EXP"
  | T_MOD -> "T_MOD"
  | T_NOT -> "T_NOT"
  | T_BIT_NOT -> "T_BIT_NOT"
  | T_INCR -> "T_INCR"
  | T_DECR -> "T_DECR"
  | T_KEYOF -> "T_KEYOF"
  | T_READONLY -> "T_READONLY"
  | T_INFER -> "T_INFER"
  | T_IS -> "T_IS"
  | T_ASSERTS -> "T_ASSERTS"
  | T_IMPLIES -> "T_IMPLIES"
  | T_RENDERS_QUESTION -> "T_RENDERS_QUESTION"
  | T_RENDERS_STAR -> "T_RENDERS_QUESTION"
  | T_INTERPRETER _ -> "T_INTERPRETER"
  | T_ERROR _ -> "T_ERROR"
  | T_EOF -> "T_EOF"
  | T_JSX_IDENTIFIER _ -> "T_JSX_IDENTIFIER"
  | T_JSX_CHILD_TEXT _ -> "T_JSX_TEXT"
  | T_JSX_QUOTE_TEXT _ -> "T_JSX_TEXT"
  | T_ANY_TYPE -> "T_ANY_TYPE"
  | T_MIXED_TYPE -> "T_MIXED_TYPE"
  | T_EMPTY_TYPE -> "T_EMPTY_TYPE"
  | T_BOOLEAN_TYPE _ -> "T_BOOLEAN_TYPE"
  | T_NUMBER_TYPE -> "T_NUMBER_TYPE"
  | T_BIGINT_TYPE -> "T_BIGINT_TYPE"
  | T_NUMBER_SINGLETON_TYPE _ -> "T_NUMBER_SINGLETON_TYPE"
  | T_BIGINT_SINGLETON_TYPE _ -> "T_BIGINT_SINGLETON_TYPE"
  | T_STRING_TYPE -> "T_STRING_TYPE"
  | T_VOID_TYPE -> "T_VOID_TYPE"
  | T_SYMBOL_TYPE -> "T_SYMBOL_TYPE"
  | T_UNKNOWN_TYPE -> "T_UNKNOWN_TYPE"
  | T_NEVER_TYPE -> "T_NEVER_TYPE"
  | T_UNDEFINED_TYPE -> "T_UNDEFINED_TYPE"
let value_of_token =
  function
  | T_NUMBER { raw;_} -> raw
  | T_BIGINT { raw;_} -> raw
  | T_STRING (_, _, raw, _) -> raw
  | T_TEMPLATE_PART (_, _, raw, is_head, is_tail) ->
      if is_head && is_tail
      then "`" ^ (raw ^ "`")
      else
        if is_head
        then "`" ^ (raw ^ "${")
        else if is_tail then "}" ^ (raw ^ "`") else "${" ^ (raw ^ "}")
  | T_IDENTIFIER { raw;_} -> raw
  | T_REGEXP (_, pattern, flags) -> "/" ^ (pattern ^ ("/" ^ flags))
  | T_LCURLY -> "{"
  | T_RCURLY -> "}"
  | T_LCURLYBAR -> "{|"
  | T_RCURLYBAR -> "|}"
  | T_LPAREN -> "("
  | T_RPAREN -> ")"
  | T_LBRACKET -> "["
  | T_RBRACKET -> "]"
  | T_SEMICOLON -> ";"
  | T_COMMA -> ","
  | T_PERIOD -> "."
  | T_ARROW -> "=>"
  | T_ELLIPSIS -> "..."
  | T_AT -> "@"
  | T_POUND -> "#"
  | T_FUNCTION -> "function"
  | T_IF -> "if"
  | T_IN -> "in"
  | T_INSTANCEOF -> "instanceof"
  | T_RETURN -> "return"
  | T_SWITCH -> "switch"
  | T_MATCH -> "match"
  | T_THIS -> "this"
  | T_THROW -> "throw"
  | T_TRY -> "try"
  | T_VAR -> "var"
  | T_WHILE -> "while"
  | T_WITH -> "with"
  | T_CONST -> "const"
  | T_LET -> "let"
  | T_NULL -> "null"
  | T_FALSE -> "false"
  | T_TRUE -> "true"
  | T_BREAK -> "break"
  | T_CASE -> "case"
  | T_CATCH -> "catch"
  | T_CONTINUE -> "continue"
  | T_DEFAULT -> "default"
  | T_DO -> "do"
  | T_FINALLY -> "finally"
  | T_FOR -> "for"
  | T_CLASS -> "class"
  | T_EXTENDS -> "extends"
  | T_STATIC -> "static"
  | T_ELSE -> "else"
  | T_NEW -> "new"
  | T_DELETE -> "delete"
  | T_TYPEOF -> "typeof"
  | T_VOID -> "void"
  | T_ENUM -> "enum"
  | T_EXPORT -> "export"
  | T_IMPORT -> "import"
  | T_SUPER -> "super"
  | T_IMPLEMENTS -> "implements"
  | T_INTERFACE -> "interface"
  | T_PACKAGE -> "package"
  | T_PRIVATE -> "private"
  | T_PROTECTED -> "protected"
  | T_PUBLIC -> "public"
  | T_YIELD -> "yield"
  | T_DEBUGGER -> "debugger"
  | T_DECLARE -> "declare"
  | T_TYPE -> "type"
  | T_OPAQUE -> "opaque"
  | T_OF -> "of"
  | T_ASYNC -> "async"
  | T_AWAIT -> "await"
  | T_CHECKS -> "%checks"
  | T_RSHIFT3_ASSIGN -> ">>>="
  | T_RSHIFT_ASSIGN -> ">>="
  | T_LSHIFT_ASSIGN -> "<<="
  | T_BIT_XOR_ASSIGN -> "^="
  | T_BIT_OR_ASSIGN -> "|="
  | T_BIT_AND_ASSIGN -> "&="
  | T_MOD_ASSIGN -> "%="
  | T_DIV_ASSIGN -> "/="
  | T_MULT_ASSIGN -> "*="
  | T_EXP_ASSIGN -> "**="
  | T_MINUS_ASSIGN -> "-="
  | T_PLUS_ASSIGN -> "+="
  | T_NULLISH_ASSIGN -> "??="
  | T_AND_ASSIGN -> "&&="
  | T_OR_ASSIGN -> "||="
  | T_ASSIGN -> "="
  | T_PLING_PERIOD -> "?."
  | T_PLING_PLING -> "??"
  | T_PLING -> "?"
  | T_COLON -> ":"
  | T_OR -> "||"
  | T_AND -> "&&"
  | T_BIT_OR -> "|"
  | T_BIT_XOR -> "^"
  | T_BIT_AND -> "&"
  | T_EQUAL -> "=="
  | T_NOT_EQUAL -> "!="
  | T_STRICT_EQUAL -> "==="
  | T_STRICT_NOT_EQUAL -> "!=="
  | T_LESS_THAN_EQUAL -> "<="
  | T_GREATER_THAN_EQUAL -> ">="
  | T_LESS_THAN -> "<"
  | T_GREATER_THAN -> ">"
  | T_LSHIFT -> "<<"
  | T_RSHIFT -> ">>"
  | T_RSHIFT3 -> ">>>"
  | T_PLUS -> "+"
  | T_MINUS -> "-"
  | T_DIV -> "/"
  | T_MULT -> "*"
  | T_EXP -> "**"
  | T_MOD -> "%"
  | T_NOT -> "!"
  | T_BIT_NOT -> "~"
  | T_INCR -> "++"
  | T_DECR -> "--"
  | T_KEYOF -> "keyof"
  | T_READONLY -> "readonly"
  | T_INFER -> "infer"
  | T_IS -> "is"
  | T_ASSERTS -> "asserts"
  | T_IMPLIES -> "implies"
  | T_RENDERS_QUESTION -> "renders?"
  | T_RENDERS_STAR -> "renders*"
  | T_INTERPRETER (_, str) -> str
  | T_ERROR raw -> raw
  | T_EOF -> ""
  | T_JSX_IDENTIFIER { raw;_} -> raw
  | T_JSX_CHILD_TEXT (_, _, raw) -> raw
  | T_JSX_QUOTE_TEXT (_, _, raw) -> raw
  | T_ANY_TYPE -> "any"
  | T_MIXED_TYPE -> "mixed"
  | T_EMPTY_TYPE -> "empty"
  | T_BOOLEAN_TYPE kind ->
      (match kind with | BOOL -> "bool" | BOOLEAN -> "boolean")
  | T_NUMBER_TYPE -> "number"
  | T_BIGINT_TYPE -> "bigint"
  | T_NUMBER_SINGLETON_TYPE { raw;_} -> raw
  | T_BIGINT_SINGLETON_TYPE { raw;_} -> raw
  | T_STRING_TYPE -> "string"
  | T_VOID_TYPE -> "void"
  | T_SYMBOL_TYPE -> "symbol"
  | T_UNKNOWN_TYPE -> "unknown"
  | T_NEVER_TYPE -> "never"
  | T_UNDEFINED_TYPE -> "undefined"
let quote_token_value value = Printf.sprintf "token `%s`" value
let explanation_of_token ?(use_article= false) token =
  let (value, article) =
    match token with
    | T_NUMBER_SINGLETON_TYPE _ | T_NUMBER _ -> ("number", "a")
    | T_BIGINT_SINGLETON_TYPE _ | T_BIGINT _ -> ("bigint", "a")
    | T_JSX_CHILD_TEXT _ | T_JSX_QUOTE_TEXT _ | T_STRING _ -> ("string", "a")
    | T_TEMPLATE_PART _ -> ("template literal part", "a")
    | T_JSX_IDENTIFIER _ | T_IDENTIFIER _ -> ("identifier", "an")
    | T_REGEXP _ -> ("regexp", "a")
    | T_EOF -> ("end of input", "the")
    | _ -> ((quote_token_value (value_of_token token)), "the") in
  if use_article then article ^ (" " ^ value) else value
