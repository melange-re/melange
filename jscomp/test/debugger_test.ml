let f x y =
  Js.log (x,y);
  x + y

let g () =
  ignore @@ f 1 2;
  [%mel.debugger ] ;
  ignore @@ f 1 2;
  [%mel.debugger];
  3


let exterme_g () =
  ignore @@ f 1 2;
  let v = [%mel.debugger ] in
  Js.log v ;
  ignore @@ f 1 2;
  [%mel.debugger];
  3
