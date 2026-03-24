(* Copyright (C) 2024- Authors of Melange
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)

(* Bigarray runtime support for Melange.

   OCaml Bigarray kind GADT constructors map to integers:
     Float32=0, Float64=1, Int8_signed=2, Int8_unsigned=3,
     Int16_signed=4, Int16_unsigned=5, Int32=6, Int64=7,
     Int=8, Nativeint=9, Complex32=10, Complex64=11, Char=12, Float16=13

   Layout GADT constructors:
     C_layout=0, Fortran_layout=1

   JS representation of a bigarray:
     { kind: int, layout: int, dims: int[], data: TypedArray }

   All [%raw] functions are self-contained — they do not reference
   other module functions, to avoid CommonJS module name issues. *)

let caml_ba_create : 'kind -> 'layout -> int array -> 'a =
  [%raw {|function(kind, layout, dims) {
    var num_dims = dims.length;
    if (num_dims < 0 || num_dims > 16) {
      throw new Error("Bigarray.create: bad number of dimensions");
    }
    var total_size = 1;
    for (var i = 0; i < num_dims; i++) {
      if (dims[i] < 0) {
        throw new Error("Bigarray.create: negative dimension");
      }
      total_size = total_size * dims[i];
    }
    var data;
    switch (kind) {
      case 0:  data = new Float32Array(total_size); break;
      case 1:  data = new Float64Array(total_size); break;
      case 2:  data = new Int8Array(total_size); break;
      case 3:  data = new Uint8Array(total_size); break;
      case 4:  data = new Int16Array(total_size); break;
      case 5:  data = new Uint16Array(total_size); break;
      case 6:  data = new Int32Array(total_size); break;
      case 7:  data = new Float64Array(total_size * 2); break;
      case 8:  data = new Int32Array(total_size); break;
      case 9:  data = new Int32Array(total_size); break;
      case 10: data = new Float32Array(total_size * 2); break;
      case 11: data = new Float64Array(total_size * 2); break;
      case 12: data = new Uint8Array(total_size); break;
      case 13: data = new Float32Array(total_size); break;
      default: throw new Error("Bigarray.create: unsupported kind " + kind);
    }
    return { kind: kind, layout: layout, dims: dims.slice(), data: data };
  }|}]

let caml_ba_num_dims : 'a -> int =
  [%raw {|function(ba) { return ba.dims.length; }|}]

let caml_ba_dim : 'a -> int -> int =
  [%raw {|function(ba, n) {
    if (n < 0 || n >= ba.dims.length) {
      throw [0, /* Invalid_argument */-3, "Bigarray.dim"];
    }
    return ba.dims[n];
  }|}]

let caml_ba_dim_1 : 'a -> int =
  [%raw {|function(ba) { return ba.dims[0]; }|}]

let caml_ba_dim_2 : 'a -> int =
  [%raw {|function(ba) { return ba.dims[1]; }|}]

let caml_ba_dim_3 : 'a -> int =
  [%raw {|function(ba) { return ba.dims[2]; }|}]

let caml_ba_kind : 'a -> 'b =
  [%raw {|function(ba) { return ba.kind; }|}]

let caml_ba_layout : 'a -> 'b =
  [%raw {|function(ba) { return ba.layout; }|}]

let caml_ba_get_generic : 'a -> int array -> 'b =
  [%raw {|function(ba, indices) {
    var num_dims = ba.dims.length;
    if (indices.length !== num_dims) {
      throw [0, -3, "Bigarray: wrong number of indices"];
    }
    var offset = 0;
    if (ba.layout === 0) {
      for (var i = 0; i < num_dims; i++) {
        if (indices[i] < 0 || indices[i] >= ba.dims[i])
          throw [0, -3, "Bigarray: index out of bounds"];
        offset = offset * ba.dims[i] + indices[i];
      }
    } else {
      for (var i = num_dims - 1; i >= 0; i--) {
        if (indices[i] < 1 || indices[i] > ba.dims[i])
          throw [0, -3, "Bigarray: index out of bounds"];
        offset = offset * ba.dims[i] + (indices[i] - 1);
      }
    }
    var kind = ba.kind;
    if (kind === 7) return [ba.data[offset * 2] | 0, ba.data[offset * 2 + 1] | 0];
    if (kind === 10 || kind === 11) return [254, ba.data[offset * 2], ba.data[offset * 2 + 1]];
    return ba.data[offset];
  }|}]

let caml_ba_set_generic : 'a -> int array -> 'b -> unit =
  [%raw {|function(ba, indices, value) {
    var num_dims = ba.dims.length;
    if (indices.length !== num_dims) {
      throw [0, -3, "Bigarray: wrong number of indices"];
    }
    var offset = 0;
    if (ba.layout === 0) {
      for (var i = 0; i < num_dims; i++) {
        if (indices[i] < 0 || indices[i] >= ba.dims[i])
          throw [0, -3, "Bigarray: index out of bounds"];
        offset = offset * ba.dims[i] + indices[i];
      }
    } else {
      for (var i = num_dims - 1; i >= 0; i--) {
        if (indices[i] < 1 || indices[i] > ba.dims[i])
          throw [0, -3, "Bigarray: index out of bounds"];
        offset = offset * ba.dims[i] + (indices[i] - 1);
      }
    }
    var kind = ba.kind;
    if (kind === 7) {
      ba.data[offset * 2] = value[0]; ba.data[offset * 2 + 1] = value[1]; return;
    }
    if (kind === 10 || kind === 11) {
      ba.data[offset * 2] = value[1]; ba.data[offset * 2 + 1] = value[2]; return;
    }
    ba.data[offset] = value;
  }|}]

(* 1D access — fully self-contained *)
let caml_ba_get_1 : 'a -> int -> 'b =
  [%raw {|function(ba, i0) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0;
    } else {
      if (i0 < 1 || i0 > ba.dims[0])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0 - 1;
    }
    var kind = ba.kind;
    if (kind === 7) return [ba.data[offset * 2] | 0, ba.data[offset * 2 + 1] | 0];
    if (kind === 10 || kind === 11) return [254, ba.data[offset * 2], ba.data[offset * 2 + 1]];
    return ba.data[offset];
  }|}]

let caml_ba_set_1 : 'a -> int -> 'b -> unit =
  [%raw {|function(ba, i0, value) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0;
    } else {
      if (i0 < 1 || i0 > ba.dims[0])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0 - 1;
    }
    var kind = ba.kind;
    if (kind === 7) {
      ba.data[offset * 2] = value[0]; ba.data[offset * 2 + 1] = value[1]; return;
    }
    if (kind === 10 || kind === 11) {
      ba.data[offset * 2] = value[1]; ba.data[offset * 2 + 1] = value[2]; return;
    }
    ba.data[offset] = value;
  }|}]

(* 2D access — fully self-contained *)
let caml_ba_get_2 : 'a -> int -> int -> 'b =
  [%raw {|function(ba, i0, i1) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0] || i1 < 0 || i1 >= ba.dims[1])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0 * ba.dims[1] + i1;
    } else {
      if (i0 < 1 || i0 > ba.dims[0] || i1 < 1 || i1 > ba.dims[1])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = (i1 - 1) * ba.dims[0] + (i0 - 1);
    }
    var kind = ba.kind;
    if (kind === 7) return [ba.data[offset * 2] | 0, ba.data[offset * 2 + 1] | 0];
    if (kind === 10 || kind === 11) return [254, ba.data[offset * 2], ba.data[offset * 2 + 1]];
    return ba.data[offset];
  }|}]

let caml_ba_set_2 : 'a -> int -> int -> 'b -> unit =
  [%raw {|function(ba, i0, i1, value) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0] || i1 < 0 || i1 >= ba.dims[1])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = i0 * ba.dims[1] + i1;
    } else {
      if (i0 < 1 || i0 > ba.dims[0] || i1 < 1 || i1 > ba.dims[1])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = (i1 - 1) * ba.dims[0] + (i0 - 1);
    }
    var kind = ba.kind;
    if (kind === 7) {
      ba.data[offset * 2] = value[0]; ba.data[offset * 2 + 1] = value[1]; return;
    }
    if (kind === 10 || kind === 11) {
      ba.data[offset * 2] = value[1]; ba.data[offset * 2 + 1] = value[2]; return;
    }
    ba.data[offset] = value;
  }|}]

(* 3D access — fully self-contained *)
let caml_ba_get_3 : 'a -> int -> int -> int -> 'b =
  [%raw {|function(ba, i0, i1, i2) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0] || i1 < 0 || i1 >= ba.dims[1] ||
          i2 < 0 || i2 >= ba.dims[2])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = (i0 * ba.dims[1] + i1) * ba.dims[2] + i2;
    } else {
      if (i0 < 1 || i0 > ba.dims[0] || i1 < 1 || i1 > ba.dims[1] ||
          i2 < 1 || i2 > ba.dims[2])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = ((i2 - 1) * ba.dims[1] + (i1 - 1)) * ba.dims[0] + (i0 - 1);
    }
    var kind = ba.kind;
    if (kind === 7) return [ba.data[offset * 2] | 0, ba.data[offset * 2 + 1] | 0];
    if (kind === 10 || kind === 11) return [254, ba.data[offset * 2], ba.data[offset * 2 + 1]];
    return ba.data[offset];
  }|}]

let caml_ba_set_3 : 'a -> int -> int -> int -> 'b -> unit =
  [%raw {|function(ba, i0, i1, i2, value) {
    var offset;
    if (ba.layout === 0) {
      if (i0 < 0 || i0 >= ba.dims[0] || i1 < 0 || i1 >= ba.dims[1] ||
          i2 < 0 || i2 >= ba.dims[2])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = (i0 * ba.dims[1] + i1) * ba.dims[2] + i2;
    } else {
      if (i0 < 1 || i0 > ba.dims[0] || i1 < 1 || i1 > ba.dims[1] ||
          i2 < 1 || i2 > ba.dims[2])
        throw [0, -3, "Bigarray: index out of bounds"];
      offset = ((i2 - 1) * ba.dims[1] + (i1 - 1)) * ba.dims[0] + (i0 - 1);
    }
    var kind = ba.kind;
    if (kind === 7) {
      ba.data[offset * 2] = value[0]; ba.data[offset * 2 + 1] = value[1]; return;
    }
    if (kind === 10 || kind === 11) {
      ba.data[offset * 2] = value[1]; ba.data[offset * 2 + 1] = value[2]; return;
    }
    ba.data[offset] = value;
  }|}]

let caml_ba_fill : 'a -> 'b -> unit =
  [%raw {|function(ba, value) {
    var kind = ba.kind;
    if (kind === 7) {
      var len = ba.data.length;
      for (var i = 0; i < len; i += 2) {
        ba.data[i] = value[0];
        ba.data[i + 1] = value[1];
      }
      return;
    }
    if (kind === 10 || kind === 11) {
      var re = value[1], im = value[2];
      var len = ba.data.length;
      for (var i = 0; i < len; i += 2) {
        ba.data[i] = re;
        ba.data[i + 1] = im;
      }
      return;
    }
    ba.data.fill(value);
  }|}]

let caml_ba_blit : 'a -> 'a -> unit =
  [%raw {|function(src, dst) {
    dst.data.set(src.data);
  }|}]

let caml_ba_sub : 'a -> int -> int -> 'a =
  [%raw {|function(ba, ofs, len) {
    var num_dims = ba.dims.length;
    var changed_dim;
    var mul = 1;
    if (ba.layout === 0) {
      changed_dim = 0;
      for (var i = 1; i < num_dims; i++) mul *= ba.dims[i];
      if (ofs < 0 || len < 0 || ofs + len > ba.dims[0])
        throw [0, -3, "Bigarray.sub: bad sub-array"];
    } else {
      changed_dim = num_dims - 1;
      for (var i = 0; i < num_dims - 1; i++) mul *= ba.dims[i];
      if (ofs < 1 || len < 0 || ofs + len - 1 > ba.dims[changed_dim])
        throw [0, -3, "Bigarray.sub: bad sub-array"];
    }
    var elem_mul = (ba.kind === 7 || ba.kind === 10 || ba.kind === 11) ? 2 : 1;
    var start_ofs = (ba.layout === 0 ? ofs : ofs - 1) * mul * elem_mul;
    var new_data = ba.data.subarray(start_ofs, start_ofs + len * mul * elem_mul);
    var new_dims = ba.dims.slice();
    new_dims[changed_dim] = len;
    return { kind: ba.kind, layout: ba.layout, dims: new_dims, data: new_data };
  }|}]

let caml_ba_slice : 'a -> int array -> 'a =
  [%raw {|function(ba, indices) {
    var num_dims = ba.dims.length;
    var num_inds = indices.length;
    if (num_inds >= num_dims)
      throw [0, -3, "Bigarray.slice: too many indices"];
    var offset = 0;
    var elem_mul = (ba.kind === 7 || ba.kind === 10 || ba.kind === 11) ? 2 : 1;
    var new_dims, start, remaining_size;
    if (ba.layout === 0) {
      new_dims = ba.dims.slice(num_inds);
      for (var i = 0; i < num_inds; i++) {
        if (indices[i] < 0 || indices[i] >= ba.dims[i])
          throw [0, -3, "Bigarray.slice: index out of bounds"];
        offset = offset * ba.dims[i] + indices[i];
      }
      remaining_size = 1;
      for (var i = num_inds; i < num_dims; i++) remaining_size *= ba.dims[i];
      start = offset * remaining_size * elem_mul;
    } else {
      new_dims = ba.dims.slice(0, num_dims - num_inds);
      for (var i = num_inds - 1; i >= 0; i--) {
        var dim_idx = num_dims - num_inds + i;
        if (indices[i] < 1 || indices[i] > ba.dims[dim_idx])
          throw [0, -3, "Bigarray.slice: index out of bounds"];
        offset = offset * ba.dims[dim_idx] + (indices[i] - 1);
      }
      remaining_size = 1;
      for (var i = 0; i < num_dims - num_inds; i++) remaining_size *= ba.dims[i];
      start = offset * remaining_size * elem_mul;
    }
    var new_data = ba.data.subarray(start, start + remaining_size * elem_mul);
    return { kind: ba.kind, layout: ba.layout, dims: new_dims, data: new_data };
  }|}]

let caml_ba_change_layout : 'a -> 'b -> 'a =
  [%raw {|function(ba, layout) {
    var new_dims = ba.dims.slice();
    new_dims.reverse();
    return { kind: ba.kind, layout: layout, dims: new_dims, data: ba.data };
  }|}]

let caml_ba_reshape : 'a -> int array -> 'a =
  [%raw {|function(ba, new_dims) {
    var old_size = 1, new_size = 1;
    for (var i = 0; i < ba.dims.length; i++) old_size *= ba.dims[i];
    for (var i = 0; i < new_dims.length; i++) {
      if (new_dims[i] < 0)
        throw [0, -3, "Bigarray.reshape: negative dimension"];
      new_size *= new_dims[i];
    }
    if (old_size !== new_size)
      throw [0, -3, "Bigarray.reshape: size mismatch"];
    return { kind: ba.kind, layout: ba.layout, dims: new_dims.slice(), data: ba.data };
  }|}]
