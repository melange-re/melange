[@bs.config {flags: [|"-bs-jsx", "3"|]}];

module Internal = {
  [@react.component]
  let header = () => assert(false);
};

[@react.component]
let make = () => <Internal.header />;
