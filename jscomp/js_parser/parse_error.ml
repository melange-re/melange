type t =
  | AccessorDataProperty
  | AccessorGetSet
  | AdjacentJSXElements
  | AmbiguousLetBracket
  | AsyncFunctionAsStatement
  | AwaitAsIdentifierReference
  | AwaitInAsyncFormalParameters
  | ComputedShorthandProperty
  | ConstructorCannotBeAccessor
  | ConstructorCannotBeAsync
  | ConstructorCannotBeGenerator
  | DeclareAsync
  | DeclareClassElement
  | DeclareClassFieldInitializer
  | DeclareOpaqueTypeInitializer
  | DuplicateConstructor
  | DuplicateExport of string
  | DuplicatePrivateFields of string
  | ElementAfterRestElement
  | EnumBigIntMemberNotInitialized of
  {
  enum_name: string ;
  member_name: string }
  | EnumBooleanMemberNotInitialized of
  {
  enum_name: string ;
  member_name: string }
  | EnumDuplicateMemberName of {
  enum_name: string ;
  member_name: string }
  | EnumInconsistentMemberValues of {
  enum_name: string }
  | EnumInvalidEllipsis of {
  trailing_comma: bool }
  | EnumInvalidExplicitType of
  {
  enum_name: string ;
  supplied_type: string option }
  | EnumInvalidExport
  | EnumInvalidInitializerSeparator of {
  member_name: string }
  | EnumInvalidMemberInitializer of
  {
  enum_name: string ;
  explicit_type: Enum_common.explicit_type option ;
  member_name: string }
  | EnumInvalidMemberName of {
  enum_name: string ;
  member_name: string }
  | EnumInvalidMemberSeparator
  | EnumNumberMemberNotInitialized of
  {
  enum_name: string ;
  member_name: string }
  | EnumStringMemberInconsistentlyInitialized of {
  enum_name: string }
  | EnumInvalidConstPrefix
  | ExpectedJSXClosingTag of string
  | ExpectedPatternFoundExpression
  | ExportSpecifierMissingComma
  | FunctionAsStatement of {
  in_strict_mode: bool }
  | GeneratorFunctionAsStatement
  | GetterArity
  | GetterMayNotHaveThisParam
  | IllegalBreak
  | IllegalContinue
  | IllegalReturn
  | IllegalUnicodeEscape
  | ImportSpecifierMissingComma
  | ImportTypeShorthandOnlyInPureImport
  | InexactInsideExact
  | InexactInsideNonObject
  | InvalidClassMemberName of
  {
  name: string ;
  static: bool ;
  method_: bool ;
  private_: bool }
  | InvalidComponentParamName
  | InvalidComponentRenderAnnotation of {
  has_nested_render: bool }
  | InvalidComponentStringParameterBinding of {
  optional: bool ;
  name: string }
  | InvalidFloatBigInt
  | InvalidIndexedAccess of {
  has_bracket: bool }
  | InvalidJSXAttributeValue
  | InvalidLHSInAssignment
  | InvalidLHSInExponentiation
  | InvalidLHSInForIn
  | InvalidLHSInForOf
  | InvalidOptionalIndexedAccess
  | InvalidRegExp
  | InvalidRegExpFlags of string
  | InvalidSciBigInt
  | InvalidTupleOptionalSpread
  | InvalidTupleVariance
  | InvalidTypeof
  | JSXAttributeValueEmptyExpression
  | LiteralShorthandProperty
  | MalformedUnicode
  | MatchNonLastRest of [ `Object  | `Array ]
  | MatchEmptyArgument
  | MatchSpreadArgument
  | MethodInDestructuring
  | MissingJSXClosingTag of string
  | MissingTypeParam
  | MissingTypeParamDefault
  | MultipleDefaultsInSwitch
  | NewlineAfterThrow
  | NewlineBeforeArrow
  | NoCatchOrFinally
  | NoUninitializedConst
  | NoUninitializedDestructuring
  | NullishCoalescingUnexpectedLogical of string
  | OptionalChainNew
  | OptionalChainTemplate
  | ParameterAfterRestParameter
  | PrivateDelete
  | PrivateNotInClass
  | PropertyAfterRestElement
  | Redeclaration of string * string
  | SetterArity
  | SetterMayNotHaveThisParam
  | StrictCatchVariable
  | StrictDelete
  | StrictDuplicateProperty
  | StrictFunctionName
  | StrictLHSAssignment
  | StrictLHSPostfix
  | StrictLHSPrefix
  | StrictModeWith
  | StrictNonOctalLiteral
  | StrictOctalLiteral
  | StrictParamDupe
  | StrictParamName
  | StrictParamNotSimple
  | StrictReservedWord
  | StrictVarName
  | SuperPrivate
  | TSAbstractClass
  | TSClassVisibility of [ `Public  | `Private  | `Protected ]
  | TSTemplateLiteralType
  | ThisParamAnnotationRequired
  | ThisParamBannedInArrowFunctions
  | ThisParamBannedInConstructor
  | ThisParamMayNotBeOptional
  | ThisParamMustBeFirst
  | TrailingCommaAfterRestElement
  | UnboundPrivate of string
  | Unexpected of string
  | UnexpectedEOS
  | UnexpectedExplicitInexactInObject
  | UnexpectedOpaqueTypeAlias
  | UnexpectedProto
  | UnexpectedReserved
  | UnexpectedReservedType
  | UnexpectedSpreadType
  | UnexpectedStatic
  | UnexpectedSuper
  | UnexpectedSuperCall
  | UnexpectedTokenWithSuggestion of string * string
  | UnexpectedTypeAlias
  | UnexpectedTypeAnnotation
  | UnexpectedTypeDeclaration
  | UnexpectedTypeExport
  | UnexpectedTypeImport
  | UnexpectedTypeInterface
  | UnexpectedVariance
  | UnexpectedWithExpected of string * string
  | UnknownLabel of string
  | UnsupportedDecorator
  | UnterminatedRegExp
  | WhitespaceInPrivateName
  | YieldAsIdentifierReference
  | YieldInFormalParameters [@@deriving ord]
let rec compare : t -> t -> int =
  let __42 () (a : string) b = Stdlib.compare a b
  and __41 () (a : string) b = Stdlib.compare a b
  and __40 () (a : string) b = Stdlib.compare a b
  and __39 () (a : string) b = Stdlib.compare a b
  and __38 () (a : string) b = Stdlib.compare a b
  and __37 () (a : string) b = Stdlib.compare a b
  and __36 () (a : string) b = Stdlib.compare a b
  and __35 () (a : string) b = Stdlib.compare a b
  and __34 () (a : string) b = Stdlib.compare a b
  and __33 () (a : string) b = Stdlib.compare a b
  and __32 () (a : string) b = Stdlib.compare a b
  and __31 () (a : string) b = Stdlib.compare a b
  and __30 () (a : bool) b = Stdlib.compare a b
  and __29 () (a : string) b = Stdlib.compare a b
  and __28 () (a : bool) b = Stdlib.compare a b
  and __27 () (a : bool) b = Stdlib.compare a b
  and __26 () (a : bool) b = Stdlib.compare a b
  and __25 () (a : bool) b = Stdlib.compare a b
  and __24 () (a : bool) b = Stdlib.compare a b
  and __23 () (a : string) b = Stdlib.compare a b
  and __22 () (a : bool) b = Stdlib.compare a b
  and __21 () (a : string) b = Stdlib.compare a b
  and __20 () (a : string) b = Stdlib.compare a b
  and __19 () (a : string) b = Stdlib.compare a b
  and __18 () (a : string) b = Stdlib.compare a b
  and __17 () (a : string) b = Stdlib.compare a b
  and __16 () (a : string) b = Stdlib.compare a b
  and __15 () (a : string) b = Stdlib.compare a b
  and __14 = Enum_common.compare_explicit_type
  and __13 () (a : string) b = Stdlib.compare a b
  and __12 () (a : string) b = Stdlib.compare a b
  and __11 () (a : string) b = Stdlib.compare a b
  and __10 () (a : string) b = Stdlib.compare a b
  and __9 () (a : bool) b = Stdlib.compare a b
  and __8 () (a : string) b = Stdlib.compare a b
  and __7 () (a : string) b = Stdlib.compare a b
  and __6 () (a : string) b = Stdlib.compare a b
  and __5 () (a : string) b = Stdlib.compare a b
  and __4 () (a : string) b = Stdlib.compare a b
  and __3 () (a : string) b = Stdlib.compare a b
  and __2 () (a : string) b = Stdlib.compare a b
  and __1 () (a : string) b = Stdlib.compare a b
  and __0 () (a : string) b = Stdlib.compare a b in
  ((
      fun lhs rhs ->
        match (lhs, rhs) with
        | (AccessorDataProperty, AccessorDataProperty) -> 0
        | (AccessorGetSet, AccessorGetSet) -> 0
        | (AdjacentJSXElements, AdjacentJSXElements) -> 0
        | (AmbiguousLetBracket, AmbiguousLetBracket) -> 0
        | (AsyncFunctionAsStatement, AsyncFunctionAsStatement) -> 0
        | (AwaitAsIdentifierReference, AwaitAsIdentifierReference) -> 0
        | (AwaitInAsyncFormalParameters, AwaitInAsyncFormalParameters)
            -> 0
        | (ComputedShorthandProperty, ComputedShorthandProperty) -> 0
        | (ConstructorCannotBeAccessor, ConstructorCannotBeAccessor) ->
            0
        | (ConstructorCannotBeAsync, ConstructorCannotBeAsync) -> 0
        | (ConstructorCannotBeGenerator, ConstructorCannotBeGenerator)
            -> 0
        | (DeclareAsync, DeclareAsync) -> 0
        | (DeclareClassElement, DeclareClassElement) -> 0
        | (DeclareClassFieldInitializer, DeclareClassFieldInitializer)
            -> 0
        | (DeclareOpaqueTypeInitializer, DeclareOpaqueTypeInitializer)
            -> 0
        | (DuplicateConstructor, DuplicateConstructor) -> 0
        | (DuplicateExport lhs0, DuplicateExport rhs0) ->
            (__0 ()) lhs0 rhs0
        | (DuplicatePrivateFields lhs0, DuplicatePrivateFields rhs0) ->
            (__1 ()) lhs0 rhs0
        | (ElementAfterRestElement, ElementAfterRestElement) -> 0
        | (EnumBigIntMemberNotInitialized
           { enum_name = lhsenum_name; member_name = lhsmember_name },
           EnumBigIntMemberNotInitialized
           { enum_name = rhsenum_name; member_name = rhsmember_name })
            ->
            (match (__2 ()) lhsenum_name rhsenum_name with
             | 0 -> (__3 ()) lhsmember_name rhsmember_name
             | x -> x)
        | (EnumBooleanMemberNotInitialized
           { enum_name = lhsenum_name; member_name = lhsmember_name },
           EnumBooleanMemberNotInitialized
           { enum_name = rhsenum_name; member_name = rhsmember_name })
            ->
            (match (__4 ()) lhsenum_name rhsenum_name with
             | 0 -> (__5 ()) lhsmember_name rhsmember_name
             | x -> x)
        | (EnumDuplicateMemberName
           { enum_name = lhsenum_name; member_name = lhsmember_name },
           EnumDuplicateMemberName
           { enum_name = rhsenum_name; member_name = rhsmember_name })
            ->
            (match (__6 ()) lhsenum_name rhsenum_name with
             | 0 -> (__7 ()) lhsmember_name rhsmember_name
             | x -> x)
        | (EnumInconsistentMemberValues { enum_name = lhsenum_name },
           EnumInconsistentMemberValues { enum_name = rhsenum_name })
            -> (__8 ()) lhsenum_name rhsenum_name
        | (EnumInvalidEllipsis { trailing_comma = lhstrailing_comma },
           EnumInvalidEllipsis { trailing_comma = rhstrailing_comma })
            -> (__9 ()) lhstrailing_comma rhstrailing_comma
        | (EnumInvalidExplicitType
           { enum_name = lhsenum_name; supplied_type = lhssupplied_type
             },
           EnumInvalidExplicitType
           { enum_name = rhsenum_name; supplied_type = rhssupplied_type
             })
            ->
            (match (__10 ()) lhsenum_name rhsenum_name with
             | 0 ->
                 ((fun x y ->
                     match (x, y) with
                     | (None, None) -> 0
                     | (Some a, Some b) -> (__11 ()) a b
                     | (None, Some _) -> (-1)
                     | (Some _, None) -> 1)) lhssupplied_type
                   rhssupplied_type
             | x -> x)
        | (EnumInvalidExport, EnumInvalidExport) -> 0
        | (EnumInvalidInitializerSeparator
           { member_name = lhsmember_name },
           EnumInvalidInitializerSeparator
           { member_name = rhsmember_name }) ->
            (__12 ()) lhsmember_name rhsmember_name
        | (EnumInvalidMemberInitializer
           { enum_name = lhsenum_name;
             explicit_type = lhsexplicit_type;
             member_name = lhsmember_name },
           EnumInvalidMemberInitializer
           { enum_name = rhsenum_name;
             explicit_type = rhsexplicit_type;
             member_name = rhsmember_name })
            ->
            (match (__13 ()) lhsenum_name rhsenum_name with
             | 0 ->
                 (match (fun x y ->
                           match (x, y) with
                           | (None, None) -> 0
                           | (Some a, Some b) -> __14 a b
                           | (None, Some _) -> (-1)
                           | (Some _, None) -> 1) lhsexplicit_type
                          rhsexplicit_type
                  with
                  | 0 -> (__15 ()) lhsmember_name rhsmember_name
                  | x -> x)
             | x -> x)
        | (EnumInvalidMemberName
           { enum_name = lhsenum_name; member_name = lhsmember_name },
           EnumInvalidMemberName
           { enum_name = rhsenum_name; member_name = rhsmember_name })
            ->
            (match (__16 ()) lhsenum_name rhsenum_name with
             | 0 -> (__17 ()) lhsmember_name rhsmember_name
             | x -> x)
        | (EnumInvalidMemberSeparator, EnumInvalidMemberSeparator) -> 0
        | (EnumNumberMemberNotInitialized
           { enum_name = lhsenum_name; member_name = lhsmember_name },
           EnumNumberMemberNotInitialized
           { enum_name = rhsenum_name; member_name = rhsmember_name })
            ->
            (match (__18 ()) lhsenum_name rhsenum_name with
             | 0 -> (__19 ()) lhsmember_name rhsmember_name
             | x -> x)
        | (EnumStringMemberInconsistentlyInitialized
           { enum_name = lhsenum_name },
           EnumStringMemberInconsistentlyInitialized
           { enum_name = rhsenum_name }) ->
            (__20 ()) lhsenum_name rhsenum_name
        | (EnumInvalidConstPrefix, EnumInvalidConstPrefix) -> 0
        | (ExpectedJSXClosingTag lhs0, ExpectedJSXClosingTag rhs0) ->
            (__21 ()) lhs0 rhs0
        | (ExpectedPatternFoundExpression,
           ExpectedPatternFoundExpression) -> 0
        | (ExportSpecifierMissingComma, ExportSpecifierMissingComma) ->
            0
        | (FunctionAsStatement { in_strict_mode = lhsin_strict_mode },
           FunctionAsStatement { in_strict_mode = rhsin_strict_mode })
            -> (__22 ()) lhsin_strict_mode rhsin_strict_mode
        | (GeneratorFunctionAsStatement, GeneratorFunctionAsStatement)
            -> 0
        | (GetterArity, GetterArity) -> 0
        | (GetterMayNotHaveThisParam, GetterMayNotHaveThisParam) -> 0
        | (IllegalBreak, IllegalBreak) -> 0
        | (IllegalContinue, IllegalContinue) -> 0
        | (IllegalReturn, IllegalReturn) -> 0
        | (IllegalUnicodeEscape, IllegalUnicodeEscape) -> 0
        | (ImportSpecifierMissingComma, ImportSpecifierMissingComma) ->
            0
        | (ImportTypeShorthandOnlyInPureImport,
           ImportTypeShorthandOnlyInPureImport) -> 0
        | (InexactInsideExact, InexactInsideExact) -> 0
        | (InexactInsideNonObject, InexactInsideNonObject) -> 0
        | (InvalidClassMemberName
           { name = lhsname; static = lhsstatic; method_ = lhsmethod_;
             private_ = lhsprivate_ },
           InvalidClassMemberName
           { name = rhsname; static = rhsstatic; method_ = rhsmethod_;
             private_ = rhsprivate_ })
            ->
            (match (__23 ()) lhsname rhsname with
             | 0 ->
                 (match (__24 ()) lhsstatic rhsstatic with
                  | 0 ->
                      (match (__25 ()) lhsmethod_ rhsmethod_ with
                       | 0 -> (__26 ()) lhsprivate_ rhsprivate_
                       | x -> x)
                  | x -> x)
             | x -> x)
        | (InvalidComponentParamName, InvalidComponentParamName) -> 0
        | (InvalidComponentRenderAnnotation
           { has_nested_render = lhshas_nested_render },
           InvalidComponentRenderAnnotation
           { has_nested_render = rhshas_nested_render }) ->
            (__27 ()) lhshas_nested_render rhshas_nested_render
        | (InvalidComponentStringParameterBinding
           { optional = lhsoptional; name = lhsname },
           InvalidComponentStringParameterBinding
           { optional = rhsoptional; name = rhsname }) ->
            (match (__28 ()) lhsoptional rhsoptional with
             | 0 -> (__29 ()) lhsname rhsname
             | x -> x)
        | (InvalidFloatBigInt, InvalidFloatBigInt) -> 0
        | (InvalidIndexedAccess { has_bracket = lhshas_bracket },
           InvalidIndexedAccess { has_bracket = rhshas_bracket }) ->
            (__30 ()) lhshas_bracket rhshas_bracket
        | (InvalidJSXAttributeValue, InvalidJSXAttributeValue) -> 0
        | (InvalidLHSInAssignment, InvalidLHSInAssignment) -> 0
        | (InvalidLHSInExponentiation, InvalidLHSInExponentiation) -> 0
        | (InvalidLHSInForIn, InvalidLHSInForIn) -> 0
        | (InvalidLHSInForOf, InvalidLHSInForOf) -> 0
        | (InvalidOptionalIndexedAccess, InvalidOptionalIndexedAccess)
            -> 0
        | (InvalidRegExp, InvalidRegExp) -> 0
        | (InvalidRegExpFlags lhs0, InvalidRegExpFlags rhs0) ->
            (__31 ()) lhs0 rhs0
        | (InvalidSciBigInt, InvalidSciBigInt) -> 0
        | (InvalidTupleOptionalSpread, InvalidTupleOptionalSpread) -> 0
        | (InvalidTupleVariance, InvalidTupleVariance) -> 0
        | (InvalidTypeof, InvalidTypeof) -> 0
        | (JSXAttributeValueEmptyExpression,
           JSXAttributeValueEmptyExpression) -> 0
        | (LiteralShorthandProperty, LiteralShorthandProperty) -> 0
        | (MalformedUnicode, MalformedUnicode) -> 0
        | (MatchNonLastRest lhs0, MatchNonLastRest rhs0) ->
            ((fun lhs rhs ->
                match (lhs, rhs) with
                | (`Object, `Object) -> 0
                | (`Array, `Array) -> 0
                | _ ->
                    let to_int = function | `Object -> 0 | `Array -> 1 in
                    Stdlib.compare (to_int lhs)
                      (to_int rhs))) lhs0 rhs0
        | (MatchEmptyArgument, MatchEmptyArgument) -> 0
        | (MatchSpreadArgument, MatchSpreadArgument) -> 0
        | (MethodInDestructuring, MethodInDestructuring) -> 0
        | (MissingJSXClosingTag lhs0, MissingJSXClosingTag rhs0) ->
            (__32 ()) lhs0 rhs0
        | (MissingTypeParam, MissingTypeParam) -> 0
        | (MissingTypeParamDefault, MissingTypeParamDefault) -> 0
        | (MultipleDefaultsInSwitch, MultipleDefaultsInSwitch) -> 0
        | (NewlineAfterThrow, NewlineAfterThrow) -> 0
        | (NewlineBeforeArrow, NewlineBeforeArrow) -> 0
        | (NoCatchOrFinally, NoCatchOrFinally) -> 0
        | (NoUninitializedConst, NoUninitializedConst) -> 0
        | (NoUninitializedDestructuring, NoUninitializedDestructuring)
            -> 0
        | (NullishCoalescingUnexpectedLogical lhs0,
           NullishCoalescingUnexpectedLogical rhs0) ->
            (__33 ()) lhs0 rhs0
        | (OptionalChainNew, OptionalChainNew) -> 0
        | (OptionalChainTemplate, OptionalChainTemplate) -> 0
        | (ParameterAfterRestParameter, ParameterAfterRestParameter) ->
            0
        | (PrivateDelete, PrivateDelete) -> 0
        | (PrivateNotInClass, PrivateNotInClass) -> 0
        | (PropertyAfterRestElement, PropertyAfterRestElement) -> 0
        | (Redeclaration (lhs0, lhs1), Redeclaration (rhs0, rhs1)) ->
            (match (__34 ()) lhs0 rhs0 with
             | 0 -> (__35 ()) lhs1 rhs1
             | x -> x)
        | (SetterArity, SetterArity) -> 0
        | (SetterMayNotHaveThisParam, SetterMayNotHaveThisParam) -> 0
        | (StrictCatchVariable, StrictCatchVariable) -> 0
        | (StrictDelete, StrictDelete) -> 0
        | (StrictDuplicateProperty, StrictDuplicateProperty) -> 0
        | (StrictFunctionName, StrictFunctionName) -> 0
        | (StrictLHSAssignment, StrictLHSAssignment) -> 0
        | (StrictLHSPostfix, StrictLHSPostfix) -> 0
        | (StrictLHSPrefix, StrictLHSPrefix) -> 0
        | (StrictModeWith, StrictModeWith) -> 0
        | (StrictNonOctalLiteral, StrictNonOctalLiteral) -> 0
        | (StrictOctalLiteral, StrictOctalLiteral) -> 0
        | (StrictParamDupe, StrictParamDupe) -> 0
        | (StrictParamName, StrictParamName) -> 0
        | (StrictParamNotSimple, StrictParamNotSimple) -> 0
        | (StrictReservedWord, StrictReservedWord) -> 0
        | (StrictVarName, StrictVarName) -> 0
        | (SuperPrivate, SuperPrivate) -> 0
        | (TSAbstractClass, TSAbstractClass) -> 0
        | (TSClassVisibility lhs0, TSClassVisibility rhs0) ->
            ((fun lhs rhs ->
                match (lhs, rhs) with
                | (`Public, `Public) -> 0
                | (`Private, `Private) -> 0
                | (`Protected, `Protected) -> 0
                | _ ->
                    let to_int =
                      function
                      | `Public -> 0
                      | `Private -> 1
                      | `Protected -> 2 in
                    Stdlib.compare (to_int lhs)
                      (to_int rhs))) lhs0 rhs0
        | (TSTemplateLiteralType, TSTemplateLiteralType) -> 0
        | (ThisParamAnnotationRequired, ThisParamAnnotationRequired) ->
            0
        | (ThisParamBannedInArrowFunctions,
           ThisParamBannedInArrowFunctions) -> 0
        | (ThisParamBannedInConstructor, ThisParamBannedInConstructor)
            -> 0
        | (ThisParamMayNotBeOptional, ThisParamMayNotBeOptional) -> 0
        | (ThisParamMustBeFirst, ThisParamMustBeFirst) -> 0
        | (TrailingCommaAfterRestElement,
           TrailingCommaAfterRestElement) -> 0
        | (UnboundPrivate lhs0, UnboundPrivate rhs0) ->
            (__36 ()) lhs0 rhs0
        | (Unexpected lhs0, Unexpected rhs0) -> (__37 ()) lhs0 rhs0
        | (UnexpectedEOS, UnexpectedEOS) -> 0
        | (UnexpectedExplicitInexactInObject,
           UnexpectedExplicitInexactInObject) -> 0
        | (UnexpectedOpaqueTypeAlias, UnexpectedOpaqueTypeAlias) -> 0
        | (UnexpectedProto, UnexpectedProto) -> 0
        | (UnexpectedReserved, UnexpectedReserved) -> 0
        | (UnexpectedReservedType, UnexpectedReservedType) -> 0
        | (UnexpectedSpreadType, UnexpectedSpreadType) -> 0
        | (UnexpectedStatic, UnexpectedStatic) -> 0
        | (UnexpectedSuper, UnexpectedSuper) -> 0
        | (UnexpectedSuperCall, UnexpectedSuperCall) -> 0
        | (UnexpectedTokenWithSuggestion (lhs0, lhs1),
           UnexpectedTokenWithSuggestion (rhs0, rhs1)) ->
            (match (__38 ()) lhs0 rhs0 with
             | 0 -> (__39 ()) lhs1 rhs1
             | x -> x)
        | (UnexpectedTypeAlias, UnexpectedTypeAlias) -> 0
        | (UnexpectedTypeAnnotation, UnexpectedTypeAnnotation) -> 0
        | (UnexpectedTypeDeclaration, UnexpectedTypeDeclaration) -> 0
        | (UnexpectedTypeExport, UnexpectedTypeExport) -> 0
        | (UnexpectedTypeImport, UnexpectedTypeImport) -> 0
        | (UnexpectedTypeInterface, UnexpectedTypeInterface) -> 0
        | (UnexpectedVariance, UnexpectedVariance) -> 0
        | (UnexpectedWithExpected (lhs0, lhs1), UnexpectedWithExpected
           (rhs0, rhs1)) ->
            (match (__40 ()) lhs0 rhs0 with
             | 0 -> (__41 ()) lhs1 rhs1
             | x -> x)
        | (UnknownLabel lhs0, UnknownLabel rhs0) -> (__42 ()) lhs0 rhs0
        | (UnsupportedDecorator, UnsupportedDecorator) -> 0
        | (UnterminatedRegExp, UnterminatedRegExp) -> 0
        | (WhitespaceInPrivateName, WhitespaceInPrivateName) -> 0
        | (YieldAsIdentifierReference, YieldAsIdentifierReference) -> 0
        | (YieldInFormalParameters, YieldInFormalParameters) -> 0
        | _ ->
            let to_int =
              function
              | AccessorDataProperty -> 0
              | AccessorGetSet -> 1
              | AdjacentJSXElements -> 2
              | AmbiguousLetBracket -> 3
              | AsyncFunctionAsStatement -> 4
              | AwaitAsIdentifierReference -> 5
              | AwaitInAsyncFormalParameters -> 6
              | ComputedShorthandProperty -> 7
              | ConstructorCannotBeAccessor -> 8
              | ConstructorCannotBeAsync -> 9
              | ConstructorCannotBeGenerator -> 10
              | DeclareAsync -> 11
              | DeclareClassElement -> 12
              | DeclareClassFieldInitializer -> 13
              | DeclareOpaqueTypeInitializer -> 14
              | DuplicateConstructor -> 15
              | DuplicateExport _ -> 16
              | DuplicatePrivateFields _ -> 17
              | ElementAfterRestElement -> 18
              | EnumBigIntMemberNotInitialized _ -> 19
              | EnumBooleanMemberNotInitialized _ -> 20
              | EnumDuplicateMemberName _ -> 21
              | EnumInconsistentMemberValues _ -> 22
              | EnumInvalidEllipsis _ -> 23
              | EnumInvalidExplicitType _ -> 24
              | EnumInvalidExport -> 25
              | EnumInvalidInitializerSeparator _ -> 26
              | EnumInvalidMemberInitializer _ -> 27
              | EnumInvalidMemberName _ -> 28
              | EnumInvalidMemberSeparator -> 29
              | EnumNumberMemberNotInitialized _ -> 30
              | EnumStringMemberInconsistentlyInitialized _ -> 31
              | EnumInvalidConstPrefix -> 32
              | ExpectedJSXClosingTag _ -> 33
              | ExpectedPatternFoundExpression -> 34
              | ExportSpecifierMissingComma -> 35
              | FunctionAsStatement _ -> 36
              | GeneratorFunctionAsStatement -> 37
              | GetterArity -> 38
              | GetterMayNotHaveThisParam -> 39
              | IllegalBreak -> 40
              | IllegalContinue -> 41
              | IllegalReturn -> 42
              | IllegalUnicodeEscape -> 43
              | ImportSpecifierMissingComma -> 44
              | ImportTypeShorthandOnlyInPureImport -> 45
              | InexactInsideExact -> 46
              | InexactInsideNonObject -> 47
              | InvalidClassMemberName _ -> 48
              | InvalidComponentParamName -> 49
              | InvalidComponentRenderAnnotation _ -> 50
              | InvalidComponentStringParameterBinding _ -> 51
              | InvalidFloatBigInt -> 52
              | InvalidIndexedAccess _ -> 53
              | InvalidJSXAttributeValue -> 54
              | InvalidLHSInAssignment -> 55
              | InvalidLHSInExponentiation -> 56
              | InvalidLHSInForIn -> 57
              | InvalidLHSInForOf -> 58
              | InvalidOptionalIndexedAccess -> 59
              | InvalidRegExp -> 60
              | InvalidRegExpFlags _ -> 61
              | InvalidSciBigInt -> 62
              | InvalidTupleOptionalSpread -> 63
              | InvalidTupleVariance -> 64
              | InvalidTypeof -> 65
              | JSXAttributeValueEmptyExpression -> 66
              | LiteralShorthandProperty -> 67
              | MalformedUnicode -> 68
              | MatchNonLastRest _ -> 69
              | MatchEmptyArgument -> 70
              | MatchSpreadArgument -> 71
              | MethodInDestructuring -> 72
              | MissingJSXClosingTag _ -> 73
              | MissingTypeParam -> 74
              | MissingTypeParamDefault -> 75
              | MultipleDefaultsInSwitch -> 76
              | NewlineAfterThrow -> 77
              | NewlineBeforeArrow -> 78
              | NoCatchOrFinally -> 79
              | NoUninitializedConst -> 80
              | NoUninitializedDestructuring -> 81
              | NullishCoalescingUnexpectedLogical _ -> 82
              | OptionalChainNew -> 83
              | OptionalChainTemplate -> 84
              | ParameterAfterRestParameter -> 85
              | PrivateDelete -> 86
              | PrivateNotInClass -> 87
              | PropertyAfterRestElement -> 88
              | Redeclaration _ -> 89
              | SetterArity -> 90
              | SetterMayNotHaveThisParam -> 91
              | StrictCatchVariable -> 92
              | StrictDelete -> 93
              | StrictDuplicateProperty -> 94
              | StrictFunctionName -> 95
              | StrictLHSAssignment -> 96
              | StrictLHSPostfix -> 97
              | StrictLHSPrefix -> 98
              | StrictModeWith -> 99
              | StrictNonOctalLiteral -> 100
              | StrictOctalLiteral -> 101
              | StrictParamDupe -> 102
              | StrictParamName -> 103
              | StrictParamNotSimple -> 104
              | StrictReservedWord -> 105
              | StrictVarName -> 106
              | SuperPrivate -> 107
              | TSAbstractClass -> 108
              | TSClassVisibility _ -> 109
              | TSTemplateLiteralType -> 110
              | ThisParamAnnotationRequired -> 111
              | ThisParamBannedInArrowFunctions -> 112
              | ThisParamBannedInConstructor -> 113
              | ThisParamMayNotBeOptional -> 114
              | ThisParamMustBeFirst -> 115
              | TrailingCommaAfterRestElement -> 116
              | UnboundPrivate _ -> 117
              | Unexpected _ -> 118
              | UnexpectedEOS -> 119
              | UnexpectedExplicitInexactInObject -> 120
              | UnexpectedOpaqueTypeAlias -> 121
              | UnexpectedProto -> 122
              | UnexpectedReserved -> 123
              | UnexpectedReservedType -> 124
              | UnexpectedSpreadType -> 125
              | UnexpectedStatic -> 126
              | UnexpectedSuper -> 127
              | UnexpectedSuperCall -> 128
              | UnexpectedTokenWithSuggestion _ -> 129
              | UnexpectedTypeAlias -> 130
              | UnexpectedTypeAnnotation -> 131
              | UnexpectedTypeDeclaration -> 132
              | UnexpectedTypeExport -> 133
              | UnexpectedTypeImport -> 134
              | UnexpectedTypeInterface -> 135
              | UnexpectedVariance -> 136
              | UnexpectedWithExpected _ -> 137
              | UnknownLabel _ -> 138
              | UnsupportedDecorator -> 139
              | UnterminatedRegExp -> 140
              | WhitespaceInPrivateName -> 141
              | YieldAsIdentifierReference -> 142
              | YieldInFormalParameters -> 143 in
            Stdlib.compare (to_int lhs) (to_int rhs))
    [@ocaml.warning "-A"]
    [@ocaml.warning "-39"])[@@ocaml.warning "-39"]
exception Error of (Loc.t * t) * (Loc.t * t) list
let error loc e = raise (Error ((loc, e), []))
module PP =
  struct
    let error =
      function
      | AccessorDataProperty ->
          "Object literal may not have data and accessor property with the same name"
      | AccessorGetSet ->
          "Object literal may not have multiple get/set accessors with the same name"
      | AdjacentJSXElements ->
          "Unexpected token <. Remember, adjacent JSX elements must be wrapped in an enclosing parent tag"
      | AmbiguousLetBracket ->
          "`let [` is ambiguous in this position because it is either a `let` binding pattern, or a member expression."
      | AsyncFunctionAsStatement ->
          "Async functions can only be declared at top level or immediately within another function."
      | AwaitAsIdentifierReference ->
          "`await` is an invalid identifier in async functions"
      | AwaitInAsyncFormalParameters ->
          "`await` is not allowed in async function parameters."
      | ComputedShorthandProperty -> "Computed properties must have a value."
      | ConstructorCannotBeAccessor -> "Constructor can't be an accessor."
      | ConstructorCannotBeAsync -> "Constructor can't be an async function."
      | ConstructorCannotBeGenerator -> "Constructor can't be a generator."
      | DeclareAsync ->
          "async is an implementation detail and isn't necessary for your declare function statement. "
            ^
            "It is sufficient for your declare function to just have a Promise return type."
      | DeclareClassElement ->
          "`declare` modifier can only appear on class fields."
      | DeclareClassFieldInitializer ->
          "Unexpected token `=`. Initializers are not allowed in a `declare`."
      | DeclareOpaqueTypeInitializer ->
          "Unexpected token `=`. Initializers are not allowed in a `declare opaque type`."
      | DuplicateConstructor -> "Classes may only have one constructor"
      | DuplicateExport export ->
          Printf.sprintf "Duplicate export for `%s`" export
      | DuplicatePrivateFields name ->
          Printf.sprintf
            "Private fields may only be declared once. `#%s` is declared more than once."
            name
      | ElementAfterRestElement ->
          "Rest element must be final element of an array pattern"
      | EnumBigIntMemberNotInitialized { enum_name; member_name } ->
          Printf.sprintf
            "bigint enum members need to be initialized, e.g. `%s = 1n,` in enum `%s`."
            member_name enum_name
      | EnumBooleanMemberNotInitialized { enum_name; member_name } ->
          Printf.sprintf
            "Boolean enum members need to be initialized. Use either `%s = true,` or `%s = false,` in enum `%s`."
            member_name member_name enum_name
      | EnumDuplicateMemberName { enum_name; member_name } ->
          Printf.sprintf
            "Enum member names need to be unique, but the name `%s` has already been used before in enum `%s`."
            member_name enum_name
      | EnumInconsistentMemberValues { enum_name } ->
          Printf.sprintf
            "Enum `%s` has inconsistent member initializers. Either use no initializers, or consistently use literals (either booleans, numbers, or strings) for all member initializers."
            enum_name
      | EnumInvalidEllipsis { trailing_comma } ->
          if trailing_comma
          then
            "The `...` must come at the end of the enum body. Remove the trailing comma."
          else
            "The `...` must come after all enum members. Move it to the end of the enum body."
      | EnumInvalidExplicitType { enum_name; supplied_type } ->
          let suggestion =
            Printf.sprintf
              "Use one of `boolean`, `number`, `string`, `symbol`, or `bigint` in enum `%s`."
              enum_name in
          (match supplied_type with
           | Some supplied_type ->
               Printf.sprintf "Enum type `%s` is not valid. %s" supplied_type
                 suggestion
           | None ->
               Printf.sprintf "Supplied enum type is not valid. %s"
                 suggestion)
      | EnumInvalidExport ->
          "Cannot export an enum with `export type`, try `export enum E {}` or `module.exports = E;` instead."
      | EnumInvalidInitializerSeparator { member_name } ->
          Printf.sprintf
            "Enum member names and initializers are separated with `=`. Replace `%s:` with `%s =`."
            member_name member_name
      | EnumInvalidMemberInitializer
          { enum_name; explicit_type; member_name } ->
          (match explicit_type with
           | Some (Enum_common.Boolean as explicit_type) | Some
             (Enum_common.Number as explicit_type) | Some
             (Enum_common.String as explicit_type) | Some
             (Enum_common.BigInt as explicit_type) ->
               let explicit_type_str =
                 Enum_common.string_of_explicit_type explicit_type in
               Printf.sprintf
                 "Enum `%s` has type `%s`, so the initializer of `%s` needs to be a %s literal."
                 enum_name explicit_type_str member_name explicit_type_str
           | Some (Enum_common.Symbol) ->
               Printf.sprintf
                 "Symbol enum members cannot be initialized. Use `%s,` in enum `%s`."
                 member_name enum_name
           | None ->
               Printf.sprintf
                 "The enum member initializer for `%s` needs to be a literal (either a boolean, number, or string) in enum `%s`."
                 member_name enum_name)
      | EnumInvalidMemberName { enum_name; member_name } ->
          let suggestion = String.capitalize_ascii member_name in
          Printf.sprintf
            "Enum member names cannot start with lowercase 'a' through 'z'. Instead of using `%s`, consider using `%s`, in enum `%s`."
            member_name suggestion enum_name
      | EnumInvalidMemberSeparator ->
          "Enum members are separated with `,`. Replace `;` with `,`."
      | EnumNumberMemberNotInitialized { enum_name; member_name } ->
          Printf.sprintf
            "Number enum members need to be initialized, e.g. `%s = 1,` in enum `%s`."
            member_name enum_name
      | EnumStringMemberInconsistentlyInitialized { enum_name } ->
          Printf.sprintf
            "String enum members need to consistently either all use initializers, or use no initializers, in enum %s."
            enum_name
      | EnumInvalidConstPrefix ->
          "`const` enums are not supported. Flow Enums are designed to allow for inlining, however the inlining itself needs to be part of the build system (whatever you use) rather than Flow itself."
      | ExpectedJSXClosingTag name ->
          Printf.sprintf "Expected corresponding JSX closing tag for %s" name
      | ExpectedPatternFoundExpression ->
          "Expected an object pattern, array pattern, or an identifier but found an expression instead"
      | ExportSpecifierMissingComma ->
          "Missing comma between export specifiers"
      | FunctionAsStatement { in_strict_mode } ->
          if in_strict_mode
          then
            "In strict mode code, functions can only be declared at top level or "
              ^ "immediately within another function."
          else
            "In non-strict mode code, functions can only be declared at top level, "
              ^ "inside a block, or as the body of an if statement."
      | GeneratorFunctionAsStatement ->
          "Generators can only be declared at top level or immediately within another function."
      | GetterArity -> "Getter should have zero parameters"
      | GetterMayNotHaveThisParam ->
          "A getter cannot have a `this` parameter."
      | IllegalBreak -> "Illegal break statement"
      | IllegalContinue -> "Illegal continue statement"
      | IllegalReturn -> "Illegal return statement"
      | IllegalUnicodeEscape -> "Illegal Unicode escape"
      | ImportSpecifierMissingComma ->
          "Missing comma between import specifiers"
      | ImportTypeShorthandOnlyInPureImport ->
          "The `type` and `typeof` keywords on named imports can only be used on regular `import` statements. "
            ^
            "It cannot be used with `import type` or `import typeof` statements"
      | InexactInsideExact ->
          "Explicit inexact syntax cannot appear inside an explicit exact object type"
      | InexactInsideNonObject ->
          "Explicit inexact syntax can only appear inside an object type"
      | InvalidClassMemberName { name; static; method_; private_ } ->
          let static_modifier = if static then "static " else "" in
          let category = if method_ then "methods" else "fields" in
          let name = if private_ then "#" ^ name else name in
          Printf.sprintf "Classes may not have %s%s named `%s`."
            static_modifier category name
      | InvalidComponentParamName ->
          "Component params must be an identifier. If you'd like to destructure, you should use `name as {destructure}`"
      | InvalidComponentRenderAnnotation _ ->
          "Components use `renders` instead of `:` to annotate the render type of a component."
      | InvalidComponentStringParameterBinding { optional; name } ->
          let camelized_name = Parse_error_utils.camelize name in
          Printf.sprintf
            "String params require local bindings using `as` renaming. You can use `'%s' as %s%s: <TYPE>` "
            name camelized_name (if optional then "?" else "")
      | InvalidFloatBigInt -> "A bigint literal must be an integer"
      | InvalidIndexedAccess { has_bracket } ->
          let msg =
            if has_bracket
            then "Remove the period."
            else "Indexed access uses bracket notation." in
          Printf.sprintf "Invalid indexed access. %s Use the format `T[K]`."
            msg
      | InvalidJSXAttributeValue ->
          "JSX value should be either an expression or a quoted JSX text"
      | InvalidLHSInAssignment -> "Invalid left-hand side in assignment"
      | InvalidLHSInExponentiation ->
          "Invalid left-hand side in exponentiation expression"
      | InvalidLHSInForIn -> "Invalid left-hand side in for-in"
      | InvalidLHSInForOf -> "Invalid left-hand side in for-of"
      | InvalidOptionalIndexedAccess ->
          "Invalid optional indexed access. Indexed access uses bracket notation. Use the format `T?.[K]`."
      | InvalidRegExp -> "Invalid regular expression"
      | InvalidRegExpFlags flags ->
          Printf.sprintf "Invalid flags supplied to RegExp constructor '%s'"
            flags
      | InvalidSciBigInt ->
          "A bigint literal cannot use exponential notation"
      | InvalidTypeof ->
          "`typeof` can only be used to get the type of variables."
      | InvalidTupleOptionalSpread ->
          "Tuple spread elements cannot be optional."
      | InvalidTupleVariance ->
          "Tuple variance annotations can only be used with labeled tuple elements, e.g. `[+foo: number]`"
      | JSXAttributeValueEmptyExpression ->
          "JSX attributes must only be assigned a non-empty expression"
      | LiteralShorthandProperty ->
          "Literals cannot be used as shorthand properties."
      | MalformedUnicode -> "Malformed unicode"
      | MatchNonLastRest kind ->
          let kind =
            match kind with | `Object -> "object" | `Array -> "array" in
          Printf.sprintf
            "In match %s pattern, the rest must be the last element in the pattern"
            kind
      | MatchEmptyArgument -> "`match` argument must not be empty"
      | MatchSpreadArgument ->
          "`match` argument cannot contain spread elements"
      | MethodInDestructuring -> "Object pattern can't contain methods"
      | MissingJSXClosingTag name ->
          Printf.sprintf "JSX element %s has no corresponding closing tag."
            name
      | MissingTypeParam -> "Expected at least one type parameter."
      | MissingTypeParamDefault ->
          "Type parameter declaration needs a default, since a preceding type parameter declaration has a default."
      | MultipleDefaultsInSwitch ->
          "More than one default clause in switch statement"
      | NewlineAfterThrow -> "Illegal newline after throw"
      | NewlineBeforeArrow -> "Illegal newline before arrow"
      | NoCatchOrFinally -> "Missing catch or finally after try"
      | NoUninitializedConst -> "Const must be initialized"
      | NoUninitializedDestructuring ->
          "Destructuring assignment must be initialized"
      | NullishCoalescingUnexpectedLogical operator ->
          Printf.sprintf
            "Unexpected token `%s`. Parentheses are required to combine `??` with `&&` or `||` expressions."
            operator
      | OptionalChainNew ->
          "An optional chain may not be used in a `new` expression."
      | OptionalChainTemplate ->
          "Template literals may not be used in an optional chain."
      | ParameterAfterRestParameter ->
          "Rest parameter must be final parameter of an argument list"
      | PrivateDelete -> "Private fields may not be deleted."
      | PrivateNotInClass ->
          "Private fields can only be referenced from within a class."
      | PropertyAfterRestElement ->
          "Rest property must be final property of an object pattern"
      | Redeclaration (what, name) ->
          Printf.sprintf "%s '%s' has already been declared" what name
      | SetterArity -> "Setter should have exactly one parameter"
      | SetterMayNotHaveThisParam ->
          "A setter cannot have a `this` parameter."
      | StrictCatchVariable ->
          "Catch variable may not be eval or arguments in strict mode"
      | StrictDelete -> "Delete of an unqualified identifier in strict mode."
      | StrictDuplicateProperty ->
          "Duplicate data property in object literal not allowed in strict mode"
      | StrictFunctionName ->
          "Function name may not be eval or arguments in strict mode"
      | StrictLHSAssignment ->
          "Assignment to eval or arguments is not allowed in strict mode"
      | StrictLHSPostfix ->
          "Postfix increment/decrement may not have eval or arguments operand in strict mode"
      | StrictLHSPrefix ->
          "Prefix increment/decrement may not have eval or arguments operand in strict mode"
      | StrictModeWith -> "Strict mode code may not include a with statement"
      | StrictNonOctalLiteral ->
          "Number literals with leading zeros are not allowed in strict mode."
      | StrictOctalLiteral ->
          "Octal literals are not allowed in strict mode."
      | StrictParamDupe ->
          "Strict mode function may not have duplicate parameter names"
      | StrictParamName ->
          "Parameter name eval or arguments is not allowed in strict mode"
      | StrictParamNotSimple ->
          "Illegal \"use strict\" directive in function with non-simple parameter list"
      | StrictReservedWord -> "Use of reserved word in strict mode"
      | StrictVarName ->
          "Variable name may not be eval or arguments in strict mode"
      | SuperPrivate ->
          "You may not access a private field through the `super` keyword."
      | TSAbstractClass -> "Flow does not support abstract classes."
      | TSClassVisibility kind ->
          let (keyword, append) =
            match kind with
            | `Private ->
                ("private",
                  " You can try using JavaScript private fields by prepending `#` to the field name.")
            | `Public ->
                ("public",
                  " Fields and methods are public by default. You can simply omit the `public` keyword.")
            | `Protected -> ("protected", "") in
          Printf.sprintf "Flow does not support using `%s` in classes.%s"
            keyword append
      | TSTemplateLiteralType ->
          "Flow does not support template literal types."
      | ThisParamAnnotationRequired ->
          "A type annotation is required for the `this` parameter."
      | ThisParamBannedInArrowFunctions ->
          "Arrow functions cannot have a `this` parameter; arrow functions automatically bind `this` when declared."
      | ThisParamBannedInConstructor ->
          "Constructors cannot have a `this` parameter; constructors don't bind `this` like other functions."
      | ThisParamMayNotBeOptional ->
          "The `this` parameter cannot be optional."
      | ThisParamMustBeFirst ->
          "The `this` parameter must be the first function parameter."
      | TrailingCommaAfterRestElement ->
          "A trailing comma is not permitted after the rest element"
      | UnboundPrivate name ->
          Printf.sprintf
            "Private fields must be declared before they can be referenced. `#%s` has not been declared."
            name
      | Unexpected unexpected -> Printf.sprintf "Unexpected %s" unexpected
      | UnexpectedEOS -> "Unexpected end of input"
      | UnexpectedExplicitInexactInObject ->
          "Explicit inexact syntax must come at the end of an object type"
      | UnexpectedOpaqueTypeAlias ->
          "Opaque type aliases are not allowed in untyped mode"
      | UnexpectedProto -> "Unexpected proto modifier"
      | UnexpectedReserved -> "Unexpected reserved word"
      | UnexpectedReservedType -> "Unexpected reserved type"
      | UnexpectedSpreadType ->
          "Spreading a type is only allowed inside an object type"
      | UnexpectedStatic -> "Unexpected static modifier"
      | UnexpectedSuper -> "Unexpected `super` outside of a class method"
      | UnexpectedSuperCall ->
          "`super()` is only valid in a class constructor"
      | UnexpectedTokenWithSuggestion (token, suggestion) ->
          Printf.sprintf "Unexpected token `%s`. Did you mean `%s`?" token
            suggestion
      | UnexpectedTypeAlias -> "Type aliases are not allowed in untyped mode"
      | UnexpectedTypeAnnotation ->
          "Type annotations are not allowed in untyped mode"
      | UnexpectedTypeDeclaration ->
          "Type declarations are not allowed in untyped mode"
      | UnexpectedTypeExport ->
          "Type exports are not allowed in untyped mode"
      | UnexpectedTypeImport ->
          "Type imports are not allowed in untyped mode"
      | UnexpectedTypeInterface ->
          "Interfaces are not allowed in untyped mode"
      | UnexpectedVariance -> "Unexpected variance sigil"
      | UnexpectedWithExpected (unexpected, expected) ->
          Printf.sprintf "Unexpected %s, expected %s" unexpected expected
      | UnknownLabel label -> Printf.sprintf "Undefined label '%s'" label
      | UnsupportedDecorator ->
          "Found a decorator in an unsupported position."
      | UnterminatedRegExp -> "Invalid regular expression: missing /"
      | WhitespaceInPrivateName ->
          "Unexpected whitespace between `#` and identifier"
      | YieldAsIdentifierReference ->
          "`yield` is an invalid identifier in generators"
      | YieldInFormalParameters ->
          "Yield expression not allowed in formal parameter"
  end
