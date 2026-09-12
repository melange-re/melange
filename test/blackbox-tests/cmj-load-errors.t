  $ . ./setup.sh

Missing CMJ files are allowed: this occurs for virtual-library modules.

  $ cat > dependency.ml <<'EOF'
  > let value = 1
  > EOF
  $ melc --mel-stop-after-cmj dependency.ml
  $ rm dependency.cmj
  $ cat > consumer.ml <<'EOF'
  > module type S = sig val value : int end
  > let packed = (module Dependency : S)
  > EOF
  $ melc -I . --mel-stop-after-cmj consumer.ml

Other CMJ loading errors must not be treated as a missing file.

  $ printf malformed > dependency.cmj
  $ if melc -I . --mel-stop-after-cmj consumer.ml >/dev/null 2>&1; then
  >   echo accepted
  > else
  >   echo rejected
  > fi
  rejected
