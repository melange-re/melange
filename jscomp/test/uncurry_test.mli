type ('a0, 'a1) t = ('a0 -> 'a1 [@u])
val f0 : (unit -> int [@u0])
val f1 : ('a -> 'a [@u])
val f2 : ('a -> 'b -> 'a * 'b [@u])
val f3 : ('a -> 'b -> 'c -> 'a * 'b * 'c [@u])
val f4 : ('a -> 'b -> 'c -> 'd -> 'a * 'b * 'c * 'd [@u])
val f5 : ('a -> 'b -> 'c -> 'd -> 'e -> 'a * 'b * 'c * 'd * 'e [@u])
val f6 :
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'a * 'b * 'c * 'd * 'e * 'f [@u])
val f7 :
  ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'a * 'b * 'c * 'd * 'e * 'f * 'g
  [@u])
val f8 :
  ('a ->
   'b ->
   'c -> 'd -> 'e -> 'f -> 'g -> 'h -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h
  [@u])
val f9 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e -> 'f -> 'g -> 'h -> 'i -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i
  [@u])
val f10 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g -> 'h -> 'i -> 'j -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j
  [@u])
val f11 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i -> 'j -> 'k -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k
  [@u])
val f12 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k -> 'l -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l
  [@u])
val f13 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l -> 'm -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm
  [@u])
val f14 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n -> 'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n
  [@u])
val f15 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o
  [@u])
val f16 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p
  [@u])
val f17 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q
  [@u])
val f18 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'r ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q * 'r
  [@u])
val f19 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'r ->
   's ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q * 'r * 's
  [@u])
val f20 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'r ->
   's ->
   't ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q * 'r * 's * 't
  [@u])
val f21 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'r ->
   's ->
   't ->
   'u ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q * 'r * 's * 't * 'u
  [@u])
val f22 :
  ('a ->
   'b ->
   'c ->
   'd ->
   'e ->
   'f ->
   'g ->
   'h ->
   'i ->
   'j ->
   'k ->
   'l ->
   'm ->
   'n ->
   'o ->
   'p ->
   'q ->
   'r ->
   's ->
   't ->
   'u ->
   'v ->
   'a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i * 'j * 'k * 'l * 'm * 'n * 'o *
   'p * 'q * 'r * 's * 't * 'u * 'v
  [@u])

val xx : unit -> 'a [@u0]
