Decimal float formatting must preserve negative zero (melange-re/melange#2167).
The columns below exercise string_of_float, Float.to_string, and the Printf
conversions %f, %e, %E, %g, %G, %F, %h, and %H.

  $ . ./setup.sh
  $ cat > dune-project <<'EOF'
  > (lang dune 3.20)
  > (using melange 1.0)
  > EOF
  $ cat > dune <<'EOF'
  > (melange.emit
  >  (target out)
  >  (module_systems (commonjs cjs) (esm mjs)))
  > EOF
  $ cat > input.ml <<'EOF'
  > let show label x =
  >   Printf.printf "%s: %s|%s|%f|%e|%E|%g|%G|%F|%h|%H\n"
  >     label (string_of_float x) (Float.to_string x) x x x x x x x x
  > let flags label x =
  >   Printf.printf "%s: [%+010.2f]|[% 7.2f]|[%-7.2f]|[%.0f]|[%+.0e]|[%+g]|[%+F]\n"
  >     label x x x x x x x
  > let () =
  >   List.iter (fun (label, x) ->
  >     assert (1. /. x = neg_infinity);
  >     show label x)
  >     ["literal", -0.; "parsed", float_of_string "-0";
  >      "arithmetic", -. (float_of_string "0")];
  >   show "positive zero" 0.;
  >   show "negative one" (-1.);
  >   flags "negative zero flags" (-0.);
  >   flags "positive zero flags" 0.;
  >   Printf.printf "rounded: %.2f|%.2f\n" (-0.001) 0.001;
  >   Printf.printf "special: %g|%g|%g\n" neg_infinity infinity nan
  > EOF

Native OCaml preserves the sign in decimal and hexadecimal formats.

  $ ocaml input.ml
  literal: -0.|-0.|-0.000000|-0.000000e+00|-0.000000E+00|-0|-0|-0.|-0x0p+0|-0X0P+0
  parsed: -0.|-0.|-0.000000|-0.000000e+00|-0.000000E+00|-0|-0|-0.|-0x0p+0|-0X0P+0
  arithmetic: -0.|-0.|-0.000000|-0.000000e+00|-0.000000E+00|-0|-0|-0.|-0x0p+0|-0X0P+0
  positive zero: 0.|0.|0.000000|0.000000e+00|0.000000E+00|0|0|0.|0x0p+0|0X0P+0
  negative one: -1.|-1.|-1.000000|-1.000000e+00|-1.000000E+00|-1|-1|-1.|-0x1p+0|-0X1P+0
  negative zero flags: [-000000.00]|[  -0.00]|[-0.00  ]|[-0]|[-0e+00]|[-0]|[-0.]
  positive zero flags: [+000000.00]|[   0.00]|[0.00   ]|[0]|[+0e+00]|[+0]|[+0.]
  rounded: -0.00|0.00
  special: -inf|inf|nan

Both JavaScript module systems currently lose the sign in decimal formats.
Hexadecimal formatting and the other controls already match native OCaml.

  $ dune build @melange
  $ node _build/default/out/input.cjs > commonjs.output
  $ node _build/default/out/input.mjs > esm.output
  $ diff commonjs.output esm.output
  $ cat commonjs.output
  literal: 0.|0.|0.000000|0.000000e+00|0.000000E+00|0|0|0.|-0x0p+0|-0X0P+0
  parsed: 0.|0.|0.000000|0.000000e+00|0.000000E+00|0|0|0.|-0x0p+0|-0X0P+0
  arithmetic: 0.|0.|0.000000|0.000000e+00|0.000000E+00|0|0|0.|-0x0p+0|-0X0P+0
  positive zero: 0.|0.|0.000000|0.000000e+00|0.000000E+00|0|0|0.|0x0p+0|0X0P+0
  negative one: -1.|-1.|-1.000000|-1.000000e+00|-1.000000E+00|-1|-1|-1.|-0x1p+0|-0X1P+0
  negative zero flags: [+000000.00]|[   0.00]|[0.00   ]|[0]|[+0e+00]|[+0]|[+0.]
  positive zero flags: [+000000.00]|[   0.00]|[0.00   ]|[0]|[+0e+00]|[+0]|[+0.]
  rounded: -0.00|0.00
  special: -inf|inf|nan
