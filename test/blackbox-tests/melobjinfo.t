`melobjinfo` reports the dependencies serialized in CMJ files.

  $ . ./setup.sh

CMJs with no dependencies are valid. Binary annotations are deliberately
disabled throughout this test: `melobjinfo` reads only the CMJ.

  $ cat > standalone.ml <<'EOF'
  > let value = 1
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj standalone.ml \
  >   -o standalone.cmj
  $ test ! -e standalone.cmt
  $ melobjinfo standalone.cmj
  File standalone.cmj
  Implementations imported:

Melange implementation dependencies retain their compilation-unit names,
including the names generated for wrapped libraries.

  $ cat > leaf.ml <<'EOF'
  > let value = 1
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj leaf.ml -o leaf.cmj

  $ cat > dep.ml <<'EOF'
  > let value = Leaf.value
  > EOF
  $ melc -I . --bs-no-bin-annot --mel-stop-after-cmj dep.ml -o dep.cmj

  $ cat > namespace__Dep.ml <<'EOF'
  > let value = 2
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj namespace__Dep.ml \
  >   -o namespace__Dep.cmj

A virtual module has an interface but no CMJ. It is still an implementation
dependency of a CMJ that refers to it.

  $ cat > virtual_dep.mli <<'EOF'
  > val value : int
  > EOF
  $ melc --bs-no-bin-annot --mel-cmi-only virtual_dep.mli
  $ test ! -e virtual_dep.cmj

  $ cat > implementation_imports.ml <<'EOF'
  > let ordinary = Dep.value
  > let namespaced = Namespace__Dep.value
  > let virtual_ = Virtual_dep.value
  > EOF
  $ melc -I . --bs-no-bin-annot --mel-stop-after-cmj \
  >   implementation_imports.ml -o implementation_imports.cmj
  $ test ! -e implementation_imports.cmt
  $ melobjinfo implementation_imports.cmj
  File implementation_imports.cmj
  Implementations imported:
    --------------------------------  Dep
    --------------------------------  Namespace__Dep
    --------------------------------  Virtual_dep

Dependencies used only by erased type declarations are not implementation
dependencies in the CMJ.

  $ cat > type_dependency.ml <<'EOF'
  > type t = int
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj type_dependency.ml \
  >   -o type_dependency.cmj
  $ cat > type_only_import.ml <<'EOF'
  > type t = Type_dependency.t
  > EOF
  $ melc -I . --bs-no-bin-annot --mel-stop-after-cmj type_only_import.ml \
  >   -o type_only_import.cmj
  $ melobjinfo type_only_import.cmj
  File type_only_import.cmj
  Implementations imported:

Dependency rows are immediate, rather than the transitive closure. Leaf is
reported by Dep, but not by Implementation_imports above.

  $ melobjinfo dep.cmj
  File dep.cmj
  Implementations imported:
    --------------------------------  Leaf

Cross-module optimization preserves the implementation dependencies needed to
build the resulting CMJ.

  $ cat > optimized_import.ml <<'EOF'
  > let value = Dep.value
  > EOF
  $ melc -I . --mel-cross-module-opt --bs-no-bin-annot \
  >   --mel-stop-after-cmj optimized_import.ml -o optimized_import.cmj
  $ melobjinfo optimized_import.cmj
  File optimized_import.cmj
  Implementations imported:
    --------------------------------  Dep

Multiple inputs are reported in argument order, including files with no
dependencies.

  $ melobjinfo standalone.cmj dep.cmj
  File standalone.cmj
  Implementations imported:
  File dep.cmj
  Implementations imported:
    --------------------------------  Leaf

If one input is malformed, the diagnostic identifies it without discarding
the output for preceding inputs.

  $ touch malformed.cmj
  $ melobjinfo standalone.cmj malformed.cmj >output 2>error
  [124]
  $ cat output
  File standalone.cmj
  Implementations imported:
  $ sed 's/malformed.cmj:.*/malformed.cmj: <error>/' error
  melobjinfo: malformed.cmj: <error>

Runtime dependencies are reported separately from implementation imports.

  $ cat > runtime_imports.ml <<'EOF'
  > let to_option value = Js.Nullable.toOption value
  > EOF
  $ melc --bs-no-bin-annot --mel-stop-after-cmj runtime_imports.ml \
  >   -o runtime_imports.cmj
  $ melobjinfo runtime_imports.cmj
  File runtime_imports.cmj
  Runtime modules imported:
    Caml_option
  Implementations imported:

JavaScript dependencies include package and relative module specifiers. Named
and default exports, whether statically or dynamically imported, are retained.
Module specifiers are sorted and deduplicated.

  $ cat > javascript_imports.ml <<'EOF'
  > external named_export : int = "named" [@@mel.module "package-name"]
  > external relative : int = "value" [@@mel.module "./relative.js"]
  > external default_export : int = "default"
  >   [@@mel.module "default-package"]
  > external dynamic_default : int = "default"
  >   [@@mel.module "dynamic-package"]
  > external dynamic_named : int = "named"
  >   [@@mel.module "dynamic-named-package"]
  > external duplicate_named : int = "named" [@@mel.module "same-package"]
  > external duplicate_default : int = "default"
  >   [@@mel.module "same-package"]
  > let named_export = named_export
  > let relative = relative
  > let default_export = default_export
  > let dynamic_default : int Js.promise = Js.import dynamic_default
  > let dynamic_named : int Js.promise = Js.import dynamic_named
  > let duplicate_named = duplicate_named
  > let duplicate_default = duplicate_default
  > EOF
  $ melc --ppx melppx --bs-no-bin-annot --mel-stop-after-cmj \
  >   javascript_imports.ml -o javascript_imports.cmj
  $ melobjinfo javascript_imports.cmj
  File javascript_imports.cmj
  JavaScript modules imported:
    ./relative.js
    default-package
    dynamic-named-package
    dynamic-package
    package-name
    same-package
  Implementations imported:

Dynamic imports of Melange modules remain implementation dependencies.

  $ cat > dynamic_import.ml <<'EOF'
  > module type Dependency = module type of Namespace__Dep
  > let dependency = Js.import (module Namespace__Dep : Dependency)
  > EOF
  $ melc -I . --bs-no-bin-annot --mel-stop-after-cmj dynamic_import.ml \
  >   -o dynamic_import.cmj
  $ melobjinfo dynamic_import.cmj
  File dynamic_import.cmj
  Implementations imported:
    --------------------------------  Namespace__Dep
