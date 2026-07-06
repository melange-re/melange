type t =
  | AbstractMethodInNonAbstractClass 
  | AbstractMethodWithBody 
  | AbstractPrivateMember 
  | AbstractPropertyInNonAbstractClass 
  | AbstractPropertyWithInitializer 
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
  | ConstructorCannotBeOptional 
  | DeclareAsync 
  | DeclareAsyncComponent 
  | DeclareAsyncHook 
  | DeclareClassElement 
  | DeclareClassFieldInitializer 
  | DeclareOpaqueTypeInitializer 
  | DuplicateConstructor 
  | DuplicateExport of string 
  | DuplicatePrivateFields of string 
  | ElementAfterRestElement 
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
  explicit_type: Flow_ast.Statement.EnumDeclaration.explicit_type option ;
  member_name: string } 
  | EnumInvalidMemberSeparator 
  | ExpectedJSXClosingTag of string 
  | ExpectedPatternFoundExpression 
  | ExportSpecifierMissingComma 
  | FunctionAsStatement of {
  in_strict_mode: bool } 
  | GeneratorFunctionAsStatement 
  | GetterArity 
  | GetterMayNotHaveThisParam 
  | IllegalBreak of {
  in_match_statement: bool } 
  | IllegalContinue 
  | IllegalReturn 
  | IllegalUnicodeEscape 
  | ImportAttributeMissingComma 
  | ImportSpecifierMissingComma 
  | ImportTypeShorthandOnlyInPureImport 
  | IndexSignatureInvalidModifier of string 
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
  | MatchExpressionAwait 
  | MatchExpressionYield 
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
  | OptionalMethodCannotBeAbstract 
  | OverrideOnConstructor 
  | ParameterAfterRestParameter 
  | PrivateDelete 
  | PrivateNotInClass 
  | PropertyAfterRestElement 
  | RecordComputedPropertyUnsupported 
  | RecordExtendsUnsupported 
  | RecordInvalidPropertyName of {
  name: string ;
  static: bool ;
  method_: bool } 
  | RecordPrivateElementUnsupported 
  | RecordPropertyAnnotationRequired 
  | Redeclaration of string * string 
  | SetterArity 
  | SetterMayNotHaveThisParam 
  | StaticAbstractMethod 
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
  | ThisParamAnnotationRequired 
  | ThisParamBannedInArrowFunctions 
  | ThisParamBannedInConstructor 
  | ThisParamBannedInConstructorType 
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
  | UnexpectedOptional 
  | OptionalDestructuringMustHaveDefault 
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
include
  struct
    let _ = fun (_ : t) -> ()
    let rec (compare : t -> t -> int) =
      ((let __0 = Flow_ast.Statement.EnumDeclaration.compare_explicit_type in
        ((let
            open! Stdlib[@@ocaml.warning
                                                                 "-A"] in
            fun lhs rhs ->
              match (lhs, rhs) with
              | (AbstractMethodInNonAbstractClass,
                 AbstractMethodInNonAbstractClass) -> 0
              | (AbstractMethodWithBody, AbstractMethodWithBody) -> 0
              | (AbstractPrivateMember, AbstractPrivateMember) -> 0
              | (AbstractPropertyInNonAbstractClass,
                 AbstractPropertyInNonAbstractClass) -> 0
              | (AbstractPropertyWithInitializer,
                 AbstractPropertyWithInitializer) -> 0
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
              | (ConstructorCannotBeOptional, ConstructorCannotBeOptional) ->
                  0
              | (DeclareAsync, DeclareAsync) -> 0
              | (DeclareAsyncComponent, DeclareAsyncComponent) -> 0
              | (DeclareAsyncHook, DeclareAsyncHook) -> 0
              | (DeclareClassElement, DeclareClassElement) -> 0
              | (DeclareClassFieldInitializer, DeclareClassFieldInitializer)
                  -> 0
              | (DeclareOpaqueTypeInitializer, DeclareOpaqueTypeInitializer)
                  -> 0
              | (DuplicateConstructor, DuplicateConstructor) -> 0
              | (DuplicateExport lhs0, DuplicateExport rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (DuplicatePrivateFields lhs0, DuplicatePrivateFields rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (ElementAfterRestElement, ElementAfterRestElement) -> 0
              | (EnumInvalidEllipsis { trailing_comma = lhstrailing_comma },
                 EnumInvalidEllipsis { trailing_comma = rhstrailing_comma })
                  ->
                  ((fun (a : bool) b -> Stdlib.compare a b))
                    lhstrailing_comma rhstrailing_comma
              | (EnumInvalidExplicitType
                 { enum_name = lhsenum_name; supplied_type = lhssupplied_type
                   },
                 EnumInvalidExplicitType
                 { enum_name = rhsenum_name; supplied_type = rhssupplied_type
                   })
                  ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhsenum_name
                           rhsenum_name
                   with
                   | 0 ->
                       ((fun x y ->
                           match (x, y) with
                           | (None, None) -> 0
                           | (Some a, Some b) ->
                               ((fun (a : string) b ->
                                   Stdlib.compare a b)) a b
                           | (None, Some _) -> (-1)
                           | (Some _, None) -> 1)) lhssupplied_type
                         rhssupplied_type
                   | x -> x)
              | (EnumInvalidExport, EnumInvalidExport) -> 0
              | (EnumInvalidInitializerSeparator
                 { member_name = lhsmember_name },
                 EnumInvalidInitializerSeparator
                 { member_name = rhsmember_name }) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhsmember_name rhsmember_name
              | (EnumInvalidMemberInitializer
                 { enum_name = lhsenum_name;
                   explicit_type = lhsexplicit_type;
                   member_name = lhsmember_name },
                 EnumInvalidMemberInitializer
                 { enum_name = rhsenum_name;
                   explicit_type = rhsexplicit_type;
                   member_name = rhsmember_name })
                  ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhsenum_name
                           rhsenum_name
                   with
                   | 0 ->
                       (match (fun x y ->
                                 match (x, y) with
                                 | (None, None) -> 0
                                 | (Some a, Some b) -> __0 a b
                                 | (None, Some _) -> (-1)
                                 | (Some _, None) -> 1) lhsexplicit_type
                                rhsexplicit_type
                        with
                        | 0 ->
                            ((fun (a : string) b ->
                                Stdlib.compare a b))
                              lhsmember_name rhsmember_name
                        | x -> x)
                   | x -> x)
              | (EnumInvalidMemberSeparator, EnumInvalidMemberSeparator) -> 0
              | (ExpectedJSXClosingTag lhs0, ExpectedJSXClosingTag rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (ExpectedPatternFoundExpression,
                 ExpectedPatternFoundExpression) -> 0
              | (ExportSpecifierMissingComma, ExportSpecifierMissingComma) ->
                  0
              | (FunctionAsStatement { in_strict_mode = lhsin_strict_mode },
                 FunctionAsStatement { in_strict_mode = rhsin_strict_mode })
                  ->
                  ((fun (a : bool) b -> Stdlib.compare a b))
                    lhsin_strict_mode rhsin_strict_mode
              | (GeneratorFunctionAsStatement, GeneratorFunctionAsStatement)
                  -> 0
              | (GetterArity, GetterArity) -> 0
              | (GetterMayNotHaveThisParam, GetterMayNotHaveThisParam) -> 0
              | (IllegalBreak { in_match_statement = lhsin_match_statement },
                 IllegalBreak { in_match_statement = rhsin_match_statement })
                  ->
                  ((fun (a : bool) b -> Stdlib.compare a b))
                    lhsin_match_statement rhsin_match_statement
              | (IllegalContinue, IllegalContinue) -> 0
              | (IllegalReturn, IllegalReturn) -> 0
              | (IllegalUnicodeEscape, IllegalUnicodeEscape) -> 0
              | (ImportAttributeMissingComma, ImportAttributeMissingComma) ->
                  0
              | (ImportSpecifierMissingComma, ImportSpecifierMissingComma) ->
                  0
              | (ImportTypeShorthandOnlyInPureImport,
                 ImportTypeShorthandOnlyInPureImport) -> 0
              | (IndexSignatureInvalidModifier lhs0,
                 IndexSignatureInvalidModifier rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (InexactInsideExact, InexactInsideExact) -> 0
              | (InexactInsideNonObject, InexactInsideNonObject) -> 0
              | (InvalidClassMemberName
                 { name = lhsname; static = lhsstatic; method_ = lhsmethod_;
                   private_ = lhsprivate_ },
                 InvalidClassMemberName
                 { name = rhsname; static = rhsstatic; method_ = rhsmethod_;
                   private_ = rhsprivate_ })
                  ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhsname rhsname
                   with
                   | 0 ->
                       (match (fun (a : bool) b ->
                                 Stdlib.compare a b) lhsstatic
                                rhsstatic
                        with
                        | 0 ->
                            (match (fun (a : bool) b ->
                                      Stdlib.compare a b)
                                     lhsmethod_ rhsmethod_
                             with
                             | 0 ->
                                 ((fun (a : bool) b ->
                                     Stdlib.compare a b))
                                   lhsprivate_ rhsprivate_
                             | x -> x)
                        | x -> x)
                   | x -> x)
              | (InvalidComponentParamName, InvalidComponentParamName) -> 0
              | (InvalidComponentRenderAnnotation
                 { has_nested_render = lhshas_nested_render },
                 InvalidComponentRenderAnnotation
                 { has_nested_render = rhshas_nested_render }) ->
                  ((fun (a : bool) b -> Stdlib.compare a b))
                    lhshas_nested_render rhshas_nested_render
              | (InvalidComponentStringParameterBinding
                 { optional = lhsoptional; name = lhsname },
                 InvalidComponentStringParameterBinding
                 { optional = rhsoptional; name = rhsname }) ->
                  (match (fun (a : bool) b ->
                            Stdlib.compare a b) lhsoptional
                           rhsoptional
                   with
                   | 0 ->
                       ((fun (a : string) b ->
                           Stdlib.compare a b)) lhsname rhsname
                   | x -> x)
              | (InvalidFloatBigInt, InvalidFloatBigInt) -> 0
              | (InvalidIndexedAccess { has_bracket = lhshas_bracket },
                 InvalidIndexedAccess { has_bracket = rhshas_bracket }) ->
                  ((fun (a : bool) b -> Stdlib.compare a b))
                    lhshas_bracket rhshas_bracket
              | (InvalidJSXAttributeValue, InvalidJSXAttributeValue) -> 0
              | (InvalidLHSInAssignment, InvalidLHSInAssignment) -> 0
              | (InvalidLHSInExponentiation, InvalidLHSInExponentiation) -> 0
              | (InvalidLHSInForIn, InvalidLHSInForIn) -> 0
              | (InvalidLHSInForOf, InvalidLHSInForOf) -> 0
              | (InvalidOptionalIndexedAccess, InvalidOptionalIndexedAccess)
                  -> 0
              | (InvalidRegExp, InvalidRegExp) -> 0
              | (InvalidRegExpFlags lhs0, InvalidRegExpFlags rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
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
              | (MatchExpressionAwait, MatchExpressionAwait) -> 0
              | (MatchExpressionYield, MatchExpressionYield) -> 0
              | (MethodInDestructuring, MethodInDestructuring) -> 0
              | (MissingJSXClosingTag lhs0, MissingJSXClosingTag rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
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
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (OptionalChainNew, OptionalChainNew) -> 0
              | (OptionalChainTemplate, OptionalChainTemplate) -> 0
              | (OptionalMethodCannotBeAbstract,
                 OptionalMethodCannotBeAbstract) -> 0
              | (OverrideOnConstructor, OverrideOnConstructor) -> 0
              | (ParameterAfterRestParameter, ParameterAfterRestParameter) ->
                  0
              | (PrivateDelete, PrivateDelete) -> 0
              | (PrivateNotInClass, PrivateNotInClass) -> 0
              | (PropertyAfterRestElement, PropertyAfterRestElement) -> 0
              | (RecordComputedPropertyUnsupported,
                 RecordComputedPropertyUnsupported) -> 0
              | (RecordExtendsUnsupported, RecordExtendsUnsupported) -> 0
              | (RecordInvalidPropertyName
                 { name = lhsname; static = lhsstatic; method_ = lhsmethod_ },
                 RecordInvalidPropertyName
                 { name = rhsname; static = rhsstatic; method_ = rhsmethod_ })
                  ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhsname rhsname
                   with
                   | 0 ->
                       (match (fun (a : bool) b ->
                                 Stdlib.compare a b) lhsstatic
                                rhsstatic
                        with
                        | 0 ->
                            ((fun (a : bool) b ->
                                Stdlib.compare a b)) lhsmethod_
                              rhsmethod_
                        | x -> x)
                   | x -> x)
              | (RecordPrivateElementUnsupported,
                 RecordPrivateElementUnsupported) -> 0
              | (RecordPropertyAnnotationRequired,
                 RecordPropertyAnnotationRequired) -> 0
              | (Redeclaration (lhs0, lhs1), Redeclaration (rhs0, rhs1)) ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhs0 rhs0
                   with
                   | 0 ->
                       ((fun (a : string) b ->
                           Stdlib.compare a b)) lhs1 rhs1
                   | x -> x)
              | (SetterArity, SetterArity) -> 0
              | (SetterMayNotHaveThisParam, SetterMayNotHaveThisParam) -> 0
              | (StaticAbstractMethod, StaticAbstractMethod) -> 0
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
              | (ThisParamAnnotationRequired, ThisParamAnnotationRequired) ->
                  0
              | (ThisParamBannedInArrowFunctions,
                 ThisParamBannedInArrowFunctions) -> 0
              | (ThisParamBannedInConstructor, ThisParamBannedInConstructor)
                  -> 0
              | (ThisParamBannedInConstructorType,
                 ThisParamBannedInConstructorType) -> 0
              | (ThisParamMayNotBeOptional, ThisParamMayNotBeOptional) -> 0
              | (ThisParamMustBeFirst, ThisParamMustBeFirst) -> 0
              | (TrailingCommaAfterRestElement,
                 TrailingCommaAfterRestElement) -> 0
              | (UnboundPrivate lhs0, UnboundPrivate rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (Unexpected lhs0, Unexpected rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (UnexpectedEOS, UnexpectedEOS) -> 0
              | (UnexpectedExplicitInexactInObject,
                 UnexpectedExplicitInexactInObject) -> 0
              | (UnexpectedOpaqueTypeAlias, UnexpectedOpaqueTypeAlias) -> 0
              | (UnexpectedProto, UnexpectedProto) -> 0
              | (UnexpectedReserved, UnexpectedReserved) -> 0
              | (UnexpectedReservedType, UnexpectedReservedType) -> 0
              | (UnexpectedOptional, UnexpectedOptional) -> 0
              | (OptionalDestructuringMustHaveDefault,
                 OptionalDestructuringMustHaveDefault) -> 0
              | (UnexpectedSpreadType, UnexpectedSpreadType) -> 0
              | (UnexpectedStatic, UnexpectedStatic) -> 0
              | (UnexpectedSuper, UnexpectedSuper) -> 0
              | (UnexpectedSuperCall, UnexpectedSuperCall) -> 0
              | (UnexpectedTokenWithSuggestion (lhs0, lhs1),
                 UnexpectedTokenWithSuggestion (rhs0, rhs1)) ->
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhs0 rhs0
                   with
                   | 0 ->
                       ((fun (a : string) b ->
                           Stdlib.compare a b)) lhs1 rhs1
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
                  (match (fun (a : string) b ->
                            Stdlib.compare a b) lhs0 rhs0
                   with
                   | 0 ->
                       ((fun (a : string) b ->
                           Stdlib.compare a b)) lhs1 rhs1
                   | x -> x)
              | (UnknownLabel lhs0, UnknownLabel rhs0) ->
                  ((fun (a : string) b -> Stdlib.compare a b))
                    lhs0 rhs0
              | (UnsupportedDecorator, UnsupportedDecorator) -> 0
              | (UnterminatedRegExp, UnterminatedRegExp) -> 0
              | (WhitespaceInPrivateName, WhitespaceInPrivateName) -> 0
              | (YieldAsIdentifierReference, YieldAsIdentifierReference) -> 0
              | (YieldInFormalParameters, YieldInFormalParameters) -> 0
              | _ ->
                  let to_int =
                    function
                    | AbstractMethodInNonAbstractClass -> 0
                    | AbstractMethodWithBody -> 1
                    | AbstractPrivateMember -> 2
                    | AbstractPropertyInNonAbstractClass -> 3
                    | AbstractPropertyWithInitializer -> 4
                    | AccessorDataProperty -> 5
                    | AccessorGetSet -> 6
                    | AdjacentJSXElements -> 7
                    | AmbiguousLetBracket -> 8
                    | AsyncFunctionAsStatement -> 9
                    | AwaitAsIdentifierReference -> 10
                    | AwaitInAsyncFormalParameters -> 11
                    | ComputedShorthandProperty -> 12
                    | ConstructorCannotBeAccessor -> 13
                    | ConstructorCannotBeAsync -> 14
                    | ConstructorCannotBeGenerator -> 15
                    | ConstructorCannotBeOptional -> 16
                    | DeclareAsync -> 17
                    | DeclareAsyncComponent -> 18
                    | DeclareAsyncHook -> 19
                    | DeclareClassElement -> 20
                    | DeclareClassFieldInitializer -> 21
                    | DeclareOpaqueTypeInitializer -> 22
                    | DuplicateConstructor -> 23
                    | DuplicateExport _ -> 24
                    | DuplicatePrivateFields _ -> 25
                    | ElementAfterRestElement -> 26
                    | EnumInvalidEllipsis _ -> 27
                    | EnumInvalidExplicitType _ -> 28
                    | EnumInvalidExport -> 29
                    | EnumInvalidInitializerSeparator _ -> 30
                    | EnumInvalidMemberInitializer _ -> 31
                    | EnumInvalidMemberSeparator -> 32
                    | ExpectedJSXClosingTag _ -> 33
                    | ExpectedPatternFoundExpression -> 34
                    | ExportSpecifierMissingComma -> 35
                    | FunctionAsStatement _ -> 36
                    | GeneratorFunctionAsStatement -> 37
                    | GetterArity -> 38
                    | GetterMayNotHaveThisParam -> 39
                    | IllegalBreak _ -> 40
                    | IllegalContinue -> 41
                    | IllegalReturn -> 42
                    | IllegalUnicodeEscape -> 43
                    | ImportAttributeMissingComma -> 44
                    | ImportSpecifierMissingComma -> 45
                    | ImportTypeShorthandOnlyInPureImport -> 46
                    | IndexSignatureInvalidModifier _ -> 47
                    | InexactInsideExact -> 48
                    | InexactInsideNonObject -> 49
                    | InvalidClassMemberName _ -> 50
                    | InvalidComponentParamName -> 51
                    | InvalidComponentRenderAnnotation _ -> 52
                    | InvalidComponentStringParameterBinding _ -> 53
                    | InvalidFloatBigInt -> 54
                    | InvalidIndexedAccess _ -> 55
                    | InvalidJSXAttributeValue -> 56
                    | InvalidLHSInAssignment -> 57
                    | InvalidLHSInExponentiation -> 58
                    | InvalidLHSInForIn -> 59
                    | InvalidLHSInForOf -> 60
                    | InvalidOptionalIndexedAccess -> 61
                    | InvalidRegExp -> 62
                    | InvalidRegExpFlags _ -> 63
                    | InvalidSciBigInt -> 64
                    | InvalidTupleOptionalSpread -> 65
                    | InvalidTupleVariance -> 66
                    | InvalidTypeof -> 67
                    | JSXAttributeValueEmptyExpression -> 68
                    | LiteralShorthandProperty -> 69
                    | MalformedUnicode -> 70
                    | MatchNonLastRest _ -> 71
                    | MatchEmptyArgument -> 72
                    | MatchSpreadArgument -> 73
                    | MatchExpressionAwait -> 74
                    | MatchExpressionYield -> 75
                    | MethodInDestructuring -> 76
                    | MissingJSXClosingTag _ -> 77
                    | MissingTypeParam -> 78
                    | MissingTypeParamDefault -> 79
                    | MultipleDefaultsInSwitch -> 80
                    | NewlineAfterThrow -> 81
                    | NewlineBeforeArrow -> 82
                    | NoCatchOrFinally -> 83
                    | NoUninitializedConst -> 84
                    | NoUninitializedDestructuring -> 85
                    | NullishCoalescingUnexpectedLogical _ -> 86
                    | OptionalChainNew -> 87
                    | OptionalChainTemplate -> 88
                    | OptionalMethodCannotBeAbstract -> 89
                    | OverrideOnConstructor -> 90
                    | ParameterAfterRestParameter -> 91
                    | PrivateDelete -> 92
                    | PrivateNotInClass -> 93
                    | PropertyAfterRestElement -> 94
                    | RecordComputedPropertyUnsupported -> 95
                    | RecordExtendsUnsupported -> 96
                    | RecordInvalidPropertyName _ -> 97
                    | RecordPrivateElementUnsupported -> 98
                    | RecordPropertyAnnotationRequired -> 99
                    | Redeclaration _ -> 100
                    | SetterArity -> 101
                    | SetterMayNotHaveThisParam -> 102
                    | StaticAbstractMethod -> 103
                    | StrictCatchVariable -> 104
                    | StrictDelete -> 105
                    | StrictDuplicateProperty -> 106
                    | StrictFunctionName -> 107
                    | StrictLHSAssignment -> 108
                    | StrictLHSPostfix -> 109
                    | StrictLHSPrefix -> 110
                    | StrictModeWith -> 111
                    | StrictNonOctalLiteral -> 112
                    | StrictOctalLiteral -> 113
                    | StrictParamDupe -> 114
                    | StrictParamName -> 115
                    | StrictParamNotSimple -> 116
                    | StrictReservedWord -> 117
                    | StrictVarName -> 118
                    | SuperPrivate -> 119
                    | ThisParamAnnotationRequired -> 120
                    | ThisParamBannedInArrowFunctions -> 121
                    | ThisParamBannedInConstructor -> 122
                    | ThisParamBannedInConstructorType -> 123
                    | ThisParamMayNotBeOptional -> 124
                    | ThisParamMustBeFirst -> 125
                    | TrailingCommaAfterRestElement -> 126
                    | UnboundPrivate _ -> 127
                    | Unexpected _ -> 128
                    | UnexpectedEOS -> 129
                    | UnexpectedExplicitInexactInObject -> 130
                    | UnexpectedOpaqueTypeAlias -> 131
                    | UnexpectedProto -> 132
                    | UnexpectedReserved -> 133
                    | UnexpectedReservedType -> 134
                    | UnexpectedOptional -> 135
                    | OptionalDestructuringMustHaveDefault -> 136
                    | UnexpectedSpreadType -> 137
                    | UnexpectedStatic -> 138
                    | UnexpectedSuper -> 139
                    | UnexpectedSuperCall -> 140
                    | UnexpectedTokenWithSuggestion _ -> 141
                    | UnexpectedTypeAlias -> 142
                    | UnexpectedTypeAnnotation -> 143
                    | UnexpectedTypeDeclaration -> 144
                    | UnexpectedTypeExport -> 145
                    | UnexpectedTypeImport -> 146
                    | UnexpectedTypeInterface -> 147
                    | UnexpectedVariance -> 148
                    | UnexpectedWithExpected _ -> 149
                    | UnknownLabel _ -> 150
                    | UnsupportedDecorator -> 151
                    | UnterminatedRegExp -> 152
                    | WhitespaceInPrivateName -> 153
                    | YieldAsIdentifierReference -> 154
                    | YieldInFormalParameters -> 155 in
                  Stdlib.compare (to_int lhs) (to_int rhs))
          [@ocaml.warning "-A"]))
      [@ocaml.warning "-39"])[@@ocaml.warning "-39"]
    let _ = compare
  end[@@ocaml.doc "@inline"][@@merlin.hide ]
exception Error of (Loc.t * t) * (Loc.t * t) list 
let error loc e = raise (Error ((loc, e), []))
module PP =
  struct
    let error =
      function
      | AbstractMethodInNonAbstractClass ->
          "Abstract methods can only appear within an abstract class."
      | AbstractMethodWithBody ->
          "Abstract methods cannot have an implementation."
      | AbstractPrivateMember ->
          "The `abstract` modifier cannot be used with a private identifier."
      | AbstractPropertyInNonAbstractClass ->
          "Abstract properties can only appear within an abstract class."
      | AbstractPropertyWithInitializer ->
          "Abstract properties cannot have an initializer."
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
      | ConstructorCannotBeOptional -> "Constructor can't be optional."
      | DeclareAsync ->
          "async is an implementation detail and isn't necessary for your declare function statement. "
            ^
            "It is sufficient for your declare function to just have a Promise return type."
      | DeclareAsyncComponent ->
          "async is an implementation detail and isn't necessary for declared components. Use `declare component` instead."
      | DeclareAsyncHook ->
          "async is an implementation detail and isn't necessary for declared hooks. Use `declare hook` instead."
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
           | Some (Flow_ast.Statement.EnumDeclaration.Symbol) ->
               Printf.sprintf
                 "Symbol enum members cannot be initialized. Use `%s,` in enum `%s`."
                 member_name enum_name
           | Some t ->
               let type_str = Flow_ast_utils.string_of_enum_explicit_type t in
               Printf.sprintf
                 "Enum `%s` has type `%s`, so the initializer of `%s` needs to be a %s literal."
                 enum_name type_str member_name type_str
           | None ->
               Printf.sprintf
                 "The enum member initializer for `%s` needs to be a literal (either a boolean, number, bigint, or string) in enum `%s`."
                 member_name enum_name)
      | EnumInvalidMemberSeparator ->
          "Enum members are separated with `,`. Replace `;` with `,`."
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
      | IllegalBreak { in_match_statement } ->
          let extra =
            if in_match_statement
            then
              " `break` statements are not required in `match` statements, as unlike `switch` statements, `match` statement cases do not fall-through by default."
            else "" in
          Printf.sprintf "Illegal break statement.%s" extra
      | IllegalContinue -> "Illegal continue statement"
      | IllegalReturn -> "Illegal return statement"
      | IllegalUnicodeEscape -> "Illegal Unicode escape"
      | ImportAttributeMissingComma ->
          "Missing comma between import attributes"
      | ImportSpecifierMissingComma ->
          "Missing comma between import specifiers"
      | ImportTypeShorthandOnlyInPureImport ->
          "The `type` and `typeof` keywords on named imports can only be used on regular `import` statements. "
            ^
            "It cannot be used with `import type` or `import typeof` statements"
      | IndexSignatureInvalidModifier modifier ->
          Printf.sprintf
            "`%s` modifier cannot be used with index signatures." modifier
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
      | MatchExpressionAwait ->
          "`await` is not yet supported in `match` expressions"
      | MatchExpressionYield ->
          "`yield` is not yet supported in `match` expressions"
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
      | OptionalMethodCannotBeAbstract ->
          "Optional methods can't be abstract."
      | OverrideOnConstructor ->
          "'override' modifier cannot appear on a constructor declaration"
      | ParameterAfterRestParameter ->
          "Rest parameter must be final parameter of an argument list"
      | PrivateDelete -> "Private fields may not be deleted."
      | PrivateNotInClass ->
          "Private fields can only be referenced from within a class."
      | PropertyAfterRestElement ->
          "Rest property must be final property of an object pattern"
      | RecordComputedPropertyUnsupported ->
          "Records do not support computed properties."
      | RecordExtendsUnsupported ->
          "Records to not support `extends`: they do not allow hierarchies. Implementing an interface by using `implements` is supported."
      | RecordInvalidPropertyName { name; static; method_ } ->
          let static_modifier = if static then "static " else "" in
          let category = if method_ then "methods" else "properties" in
          Printf.sprintf "Records may not have %s%s named `%s`."
            static_modifier category name
      | RecordPrivateElementUnsupported ->
          "Records to not support private elements. Remove the `#`."
      | RecordPropertyAnnotationRequired ->
          "Record properties must have a type annotation."
      | Redeclaration (what, name) ->
          Printf.sprintf "%s '%s' has already been declared" what name
      | SetterArity -> "Setter should have exactly one parameter"
      | SetterMayNotHaveThisParam ->
          "A setter cannot have a `this` parameter."
      | StaticAbstractMethod ->
          "`static` modifier can't be used with the `abstract` modifier."
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
      | ThisParamAnnotationRequired ->
          "A type annotation is required for the `this` parameter."
      | ThisParamBannedInArrowFunctions ->
          "Arrow functions cannot have a `this` parameter; arrow functions automatically bind `this` when declared."
      | ThisParamBannedInConstructor ->
          "Constructors cannot have a `this` parameter; constructors don't bind `this` like other functions."
      | ThisParamBannedInConstructorType ->
          "Constructor types cannot have a `this` parameter."
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
      | UnexpectedOptional ->
          "Unexpected `?` (optional modifier not allowed here)"
      | OptionalDestructuringMustHaveDefault ->
          "Optional destructuring patterns must use a default value (e.g., `{...}: T = {}`)."
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
