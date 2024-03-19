
  $ . ../setup.sh
  $ dune build @all --display=short
      ocamldep vlib/.vlib.objs/virt.intf.d
      ocamldep impl_melange/.impl_melange.objs/virt.impl.d
      ocamldep vlib/.vlib.objs/vlib.impl.d
          melc vlib/.vlib.objs/melange/virt.{cmi,cmti}
          melc vlib/.vlib.objs/melange/vlib.{cmi,cmj,cmt}
          melc impl_melange/.impl_melange.objs/melange/virt.{cmj,cmt}
          melc output/vlib/vlib.js
          melc .output.mobjs/melange/melange__Mel.{cmi,cmj,cmt}
          melc output/impl_melange/virt.js
          melc output/mel.js

  $ node _build/default/output/mel.js
  Result is: melange

