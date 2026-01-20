
  $ . ./setup.sh
  $ cat >x.ml <<EOF
  > let x = "hello"
  > EOF
  $ melc -nostdlib -nostdlib -nopervasives x.ml 2>&1 | grep repeated
  melc: option '--nostdlib' cannot be repeated
