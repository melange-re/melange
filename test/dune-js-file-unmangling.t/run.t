Showcase library name namespacing in dune

- The `leaf` library has a module that corresponds to the library name
- The `parent` library doesn't have any modules named `Parent`

  $ export MELANGELIB="$INSIDE_DUNE/lib/melange"
  $ dune build @melange-dist --display=short
      ocamldep leaf/.leaf.objs/leaf.ml.d
          melc leaf/.leaf.objs/melange/leaf__.{cmi,cmj,cmt}
      ocamldep leaf/.leaf.objs/other.ml.d
      ocamldep parent/.parent.objs/m_a.ml.d
      ocamldep parent/.parent.objs/m_b.ml.d
          melc parent/.parent.objs/melange/parent.{cmi,cmj,cmt}
          melc dist/leaf/leaf__.js
          melc leaf/.leaf.objs/melange/leaf__Other.{cmi,cmj,cmt}
          melc dist/leaf/other.js
          melc leaf/.leaf.objs/melange/leaf.{cmi,cmj,cmt}
          melc dist/leaf/leaf.js
          melc parent/.parent.objs/melange/parent__M_a.{cmi,cmj,cmt}
          melc parent/.parent.objs/melange/parent__M_b.{cmi,cmj,cmt}
          melc dist/parent/parent.js
          melc dist/parent/m_a.js
          melc dist/parent/m_b.js
          melc .dist.mobjs/melange/melange__Entry_module.{cmi,cmj,cmt}
          melc dist/entry_module.js

  $ ls _build/default/leaf/.leaf.objs/melange
  leaf.cmi
  leaf.cmj
  leaf.cmt
  leaf__.cmi
  leaf__.cmj
  leaf__.cmt
  leaf__Other.cmi
  leaf__Other.cmj
  leaf__Other.cmt

  $ ls _build/default/parent/.parent.objs/melange
  parent.cmi
  parent.cmj
  parent.cmt
  parent__M_a.cmi
  parent__M_a.cmj
  parent__M_a.cmt
  parent__M_b.cmi
  parent__M_b.cmj
  parent__M_b.cmt

Generated JS files are unmangled

  $ tree _build/default/dist
  _build/default/dist
  |-- entry_module.js
  |-- leaf
  |   |-- leaf.js
  |   |-- leaf__.js
  |   `-- other.js
  `-- parent
      |-- m_a.js
      |-- m_b.js
      `-- parent.js

  2 directories, 7 files
