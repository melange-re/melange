module X = {
  type t = { id : int }
}

// https://github.com/melange-re/melange/pull/161
let builds_in_melange = () => {
  let { id } = { X.id: 0 }
  id
}
