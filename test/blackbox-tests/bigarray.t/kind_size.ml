open Bigarray

let () =
  Printf.printf "float32: %d\n" (kind_size_in_bytes float32);
  Printf.printf "float64: %d\n" (kind_size_in_bytes float64);
  Printf.printf "int8_signed: %d\n" (kind_size_in_bytes int8_signed);
  Printf.printf "int8_unsigned: %d\n" (kind_size_in_bytes int8_unsigned);
  Printf.printf "int16_signed: %d\n" (kind_size_in_bytes int16_signed);
  Printf.printf "int16_unsigned: %d\n" (kind_size_in_bytes int16_unsigned);
  Printf.printf "int32: %d\n" (kind_size_in_bytes int32);
  Printf.printf "char: %d\n" (kind_size_in_bytes char)
