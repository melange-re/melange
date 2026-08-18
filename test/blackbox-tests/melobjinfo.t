`melobjinfo` reports the implementation dependencies serialized in CMJ files.

  $ . ./setup.sh

  $ cat > dep.ml <<'EOF'
  > let value = 1
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj dep.ml -o dep.cmj

  $ cat > main.ml <<'EOF'
  > let value = Dep.value
  > EOF
  $ melc -I . --bs-no-bin-annot --mel-stop-after-cmj main.ml -o main.cmj
  $ test ! -e dep.cmt
  $ test ! -e main.cmt

  $ melobjinfo dep.cmj main.cmj
  File dep.cmj
  Implementations imported:
  File main.cmj
  Implementations imported:
    --------------------------------  Dep
