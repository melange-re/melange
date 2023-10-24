let rec map f = function
    [] -> []
  | a::l -> let r = f a [@u] in r :: map f l
