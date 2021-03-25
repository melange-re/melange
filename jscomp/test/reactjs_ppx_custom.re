[@bs.config
  {
    flags: [|
      "-bs-jsx",
      "3",
      "-dsource",
      // "-w","A",
      // "-warn-error", "a"
    |],
  }
];

module Internal = {
  [@react.component]
  let header = () => <div />;
};

[@react.component]
let make = () => <Internal.header />;
