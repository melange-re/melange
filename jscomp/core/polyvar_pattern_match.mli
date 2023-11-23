open Import

val make_test_sequence_variant_constant :
  Lambda.lambda option ->
  Lambda.lambda ->
  (int * (string * Lambda.lambda)) list ->
  Lambda.lambda

val call_switcher_variant_constant :
  Lambda.scoped_location ->
  Lambda.lambda option ->
  Lambda.lambda ->
  (int * (string * Lambda.lambda)) list ->
  Lambda.switch_names option ->
  Lambda.lambda

val call_switcher_variant_constr :
  Lambda.scoped_location ->
  Lambda.lambda option ->
  Lambda.lambda ->
  (int * (string * Lambda.lambda)) list ->
  Lambda.switch_names option ->
  Lambda.lambda
