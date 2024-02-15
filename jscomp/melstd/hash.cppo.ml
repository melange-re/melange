#if defined TYPE_IDENT
type key = Ident.t
type 'a t = (key, 'a)  Hash_gen.t
let key_index (h : _ t ) (key : key) =
  (Hashtbl.hash  ((Ident0.stamp key), (Ident.name key)) ) land (Stdlib.Array.length h.data - 1)
let eq_key = Ident0.equal
#elif defined TYPE_INT
type key = int
type 'a t = (key, 'a)  Hash_gen.t
let key_index (h : _ t ) (key : key) =
  (Hashtbl.hash key) land (Stdlib.Array.length h.data - 1)
let eq_key = Int.equal

#elif defined TYPE_FUNCTOR
module Make (Key : Hashtbl.HashedType) = struct
  type key = Key.t
  type 'a t = (key, 'a)  Hash_gen.t
  let key_index (h : _ t ) (key : key) =
    (Key.hash  key ) land (Stdlib.Array.length h.data - 1)
  let eq_key = Key.equal

#else
      [%error "unknown type"]
#endif

  type ('a, 'b) bucket = ('a,'b) Hash_gen.bucket
  let create = Hash_gen.create
  let clear = Hash_gen.clear
  let reset = Hash_gen.reset
  let iter = Hash_gen.iter
  let to_list = Hash_gen.to_list
  let fold = Hash_gen.fold
  let length = Hash_gen.length
  (* let stats = Hash_gen.stats *)



  let add (h : _ t) key data =
    let i = key_index h key in
    let h_data = h.data in
    Stdlib.Array.unsafe_set h_data i (Cons{key; data; next=Stdlib.Array.unsafe_get h_data i});
    h.size <- h.size + 1;
    if h.size > Stdlib.Array.length h_data lsl 1 then Hash_gen.resize key_index h

  (* after upgrade to 4.04 we should provide an efficient [replace_or_init] *)
  let add_or_update
      (h : 'a t)
      (key : key)
      ~update:(modf : 'a -> 'a)
      (default :  'a) : unit =
    let rec find_bucket (bucketlist : _ bucket) : bool =
      match bucketlist with
      | Cons rhs  ->
        if eq_key rhs.key key then begin rhs.data <- modf rhs.data; false end
        else find_bucket rhs.next
      | Empty -> true in
    let i = key_index h key in
    let h_data = h.data in
    if find_bucket (Stdlib.Array.unsafe_get h_data i) then
      begin
        Stdlib.Array.unsafe_set h_data i  (Cons{key; data=default; next = Stdlib.Array.unsafe_get h_data i});
        h.size <- h.size + 1 ;
        if h.size > Stdlib.Array.length h_data lsl 1 then Hash_gen.resize key_index h
      end

  let remove (h : _ t ) key =
    let i = key_index h key in
    let h_data = h.data in
    Hash_gen.remove_bucket h i key ~prec:Empty (Stdlib.Array.unsafe_get h_data i) eq_key

  (* for short bucket list, [find_rec is not called ] *)
  let rec find_rec key (bucketlist : _ bucket) = match bucketlist with
    | Empty ->
      raise Not_found
    | Cons rhs  ->
      if eq_key key rhs.key then rhs.data else find_rec key rhs.next

  let find_exn (h : _ t) key =
    match Stdlib.Array.unsafe_get h.data (key_index h key) with
    | Empty -> raise Not_found
    | Cons rhs  ->
      if eq_key key rhs.key then rhs.data else
        match rhs.next with
        | Empty -> raise Not_found
        | Cons rhs  ->
          if eq_key key rhs.key then rhs.data else
            match rhs.next with
            | Empty -> raise Not_found
            | Cons rhs ->
              if eq_key key rhs.key  then rhs.data else find_rec key rhs.next

  let find_opt (h : _ t) key =
    Hash_gen.small_bucket_opt eq_key key (Stdlib.Array.unsafe_get h.data (key_index h key))

  let find_key_opt (h : _ t) key =
    Hash_gen.small_bucket_key_opt eq_key key (Stdlib.Array.unsafe_get h.data (key_index h key))

  let find_default (h : _ t) key default =
    Hash_gen.small_bucket_default eq_key key default (Stdlib.Array.unsafe_get h.data (key_index h key))

  let find_all (h : _ t) key =
    let rec find_in_bucket (bucketlist : _ bucket) = match bucketlist with
      | Empty ->
        []
      | Cons rhs  ->
        if eq_key key rhs.key
        then rhs.data :: find_in_bucket rhs.next
        else find_in_bucket rhs.next in
    find_in_bucket (Stdlib.Array.unsafe_get h.data (key_index h key))


  let replace h key data =
    let i = key_index h key in
    let h_data = h.data in
    let l = Stdlib.Array.unsafe_get h_data i in
    if Hash_gen.replace_bucket key data l eq_key then
      begin
        Stdlib.Array.unsafe_set h_data i (Cons{key; data; next=l});
        h.size <- h.size + 1;
        if h.size > Stdlib.Array.length h_data lsl 1 then Hash_gen.resize key_index h;
      end

  let mem (h : _ t) key =
    Hash_gen.small_bucket_mem
      (Stdlib.Array.unsafe_get h.data (key_index h key))
      eq_key key


  let of_list2 ks vs =
    let len = Stdlib.List.length ks in
    let map = create len in
    Stdlib.List.iter2 (fun k v -> add map k v) ks vs ;
    map

#if defined TYPE_FUNCTOR
end
#endif
