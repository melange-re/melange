[@bs.config {flags: [|"-bs-jsx", "3"|]}];

module React = React;
module Internal = {
  [@react.component]
  let header = () => assert(false);
};

[@react.component]
let make = () => <Internal.header />;
