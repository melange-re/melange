module React = {
  include React;
  let jsx = createElement;
};
module Internal = {
  [@react.component]
  let header = () => assert(false);
};

[@react.component]
let make = () => <Internal.header />;
