Cross-module optimization should report when an installed dependency's CMJ
file is unavailable, while still producing the dependent CMJ.

  $ . ./setup.sh
  $ mkdir -p src built installed app

Build the dependency normally, then stage only its CMI to reproduce the
missing installed CMJ dependency.

  $ cat > src/classify.ml <<'EOF'
  > let classify x = x
  > EOF
  $ melc --mel-cross-module-opt --mel-stop-after-cmj \
  >   src/classify.ml -o built/classify.cmj
  $ cp built/classify.cmi installed/

  $ cat > src/errors.ml <<'EOF'
  > let show x = Classify.classify x
  > EOF

  $ melc -I installed --mel-cross-module-opt --mel-stop-after-cmj \
  >   src/errors.ml -o app/errors.cmj
  $ ls app/errors.cmj
  app/errors.cmj
