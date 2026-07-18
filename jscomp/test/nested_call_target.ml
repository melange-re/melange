let rec external_target x =
  if x <= 0 then 0 else 1 + external_target (x - 1)
