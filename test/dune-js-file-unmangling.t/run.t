Showcase library name namespacing in dune

- The `leaf` library has a module that corresponds to the library name
- The `parent` library doesn't have any modules named `Parent`

  $ . ../setup.sh
  $ dune build @melange-dist

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

  $ tree --noreport _build/default/dist/leaf
  _build/default/dist/leaf
  |-- leaf.js
  |-- leaf__.js
  `-- other.js
  $ tree --noreport _build/default/dist/parent
  _build/default/dist/parent
  |-- m_a.js
  |-- m_b.js
  `-- parent.js
