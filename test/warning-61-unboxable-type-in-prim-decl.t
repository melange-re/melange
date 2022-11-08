Test showing unused record fields error with bs.deriving

  $ cat > main.ml <<EOF
  > type singleton
  > 
  > type singletonConfig = { overrides : string array }
  > 
  > external useSingletonWithConfig : singletonConfig -> singleton * singleton
  >   = "useSingleton"
  >   [@@bs.module "@tippyjs/react"] [@@bs.val]
  > EOF

  $ melc -nopervasives -w +61 main.ml -o main.cmj
  File "main.ml", lines 5-7, characters 0-43:
  5 | external useSingletonWithConfig : singletonConfig -> singleton * singleton
  6 |   = "useSingleton"
  7 |   [@@bs.module "@tippyjs/react"] [@@bs.val]
  Warning 61 [unboxable-type-in-prim-decl]: This primitive declaration uses type singletonConfig, whose representation
  may be either boxed or unboxed. Without an annotation to indicate
  which representation is intended, the boxed representation has been
  selected by default. This default choice may change in future
  versions of the compiler, breaking the primitive implementation.
  You should explicitly annotate the declaration of singletonConfig
  with [@@boxed] or [@@unboxed], so that its external interface
  remains stable in the future.
