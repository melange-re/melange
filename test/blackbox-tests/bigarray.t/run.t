Test Bigarray stdlib module with various layouts and data types

  $ . ../setup.sh
  $ dune build @melange

Array1 float64 C layout: create, init, of_array, dim, size_in_bytes

  $ node _build/default/out/array1_float64_c.js
  0. 10. 20. 30. 40.
  0. 1. 4. 9.
  10. 20. 30.
  dim: 5
  size_in_bytes: 40

Array1 float64 Fortran layout: 1-indexed access

  $ node _build/default/out/array1_float64_fortran.js
  100. 200. 300. 400. 500.
  10. 20. 30.
  dim: 5

Array1 int32 C layout: signed 32-bit integers

  $ node _build/default/out/array1_int32_c.js
  42 -1 0 2147483647
  size_in_bytes: 16

Array1 integer kinds (int8s, int8u, int16s, int16u) C layout

  $ node _build/default/out/array1_int_kinds_c.js
  uint8: 0 127 255 42
  int8: -128 127 0
  uint16: 0 65535 1000
  int16: -32768 32767 0

Array1 char C layout

  $ node _build/default/out/array1_char_c.js
  Hello
  size_in_bytes: 5

Array1 float32 C layout

  $ node _build/default/out/array1_float32_c.js
  1.5 -2.25 0.
  size_in_bytes: 12

Array1 fill, blit, sub (shared storage)

  $ node _build/default/out/array1_fill_blit_sub.js
  fill: 7. 7. 7. 7.
  blit: 99. 7. 7. 7.
  sub dim: 3
  sub: 2. 3. 4.
  original[2] after mutation: 99

Array2 float64 C layout with slice_left

  $ node _build/default/out/array2_float64_c.js
  0 1 2 3
  10 11 12 13
  20 21 22 23
  dims: 3 x 4
  size_in_bytes: 96
  row1: 10 11 12 13

Array2 int32 Fortran layout

  $ node _build/default/out/array2_int32_fortran.js
  11 12 13
  21 22 23
  dims: 2 x 3

Array3 float64 C layout

  $ node _build/default/out/array3_float64_c.js
  dims: 2 x 3 x 4
  a[0][1][2] = 12
  a[1][2][3] = 123
  size_in_bytes: 192

Array3 float64 Fortran layout

  $ node _build/default/out/array3_float64_fortran.js
  a[1][2][3] = 123
  a[2][3][4] = 234

Genarray with 4 dimensions

  $ node _build/default/out/genarray_4d.js
  num_dims: 4
  dims: 2 3 4 5
  a[1][2][3][4] = 42

Array0 zero-dimensional scalar

  $ node _build/default/out/array0_scalar.js
  value: 3.14
  after set: 2.72

Reshape, change_layout, invalid conversion

  $ node _build/default/out/reshape_layout.js
  reshaped 2x3:
  1 2 3
  4 5 6
  C[0]=1 C[1]=2 C[2]=3
  F[1]=1 F[2]=2 F[3]=3
  caught: Bigarray.array2_of_genarray

kind_size_in_bytes for all kinds

  $ node _build/default/out/kind_size.js
  float32: 4
  float64: 8
  int8_signed: 1
  int8_unsigned: 1
  int16_signed: 2
  int16_unsigned: 2
  int32: 4
  char: 1
