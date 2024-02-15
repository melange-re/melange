let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = Mt.eq_suites ~test_id ~suites loc x y



type node = {
  value : int ;
  left : t;
  right : t
}
and t = node Js.undefined
[@@deriving jsProperties, getSet]



module S = Belt.MutableStack
module Q = Belt.MutableQueue

let inOrder (v : t) : int array =
  let current =  ref v in
  let s : node S.t = S.make () in
  let q : int Q.t = Q.make () in
  while !current != Js.undefined do
    let v = Js.Undefined.getUnsafe !current  in
    S.push s v;
    current := leftGet v;
  done ;
  while not (S.isEmpty s ) do
    current := S.popUndefined s ;
    let v = Js.Undefined.getUnsafe !current in
    Q.add q (valueGet v);
    current := rightGet v ;
    while !current != Js.undefined do
      let v = Js.Undefined.getUnsafe !current  in
      S.push s v;
      current := leftGet v;
    done ;
  done;
  Q.toArray q

let inOrder3 (v : t) : int array =
  let current =  ref v in
  let s : node S.t = S.make () in
  let q : int Q.t = Q.make () in
  while !current != Js.undefined do
    let v = Js.Undefined.getUnsafe !current  in
    S.push s v;
    current := leftGet v;
  done ;
  S.dynamicPopIter s begin fun  popped ->
    Q.add q (valueGet popped);
    let current = ref (rightGet popped) in
    while !current != Js.undefined do
      let v = Js.Undefined.getUnsafe !current in
      S.push s v;
      current := leftGet v
    done
  end;
  Q.toArray q

let inOrder2 (v : t) =
  let todo = ref true in
  let cursor = ref v in
  let s : node S.t = S.make () in
  let q : int Q.t = Q.make () in
  while !todo do
    if !cursor != Js.undefined then
      (
        let v = (Js.Undefined.getUnsafe !cursor) in
        S.push s v;
        cursor := leftGet v)
    else
      begin
        if not (S.isEmpty s) then
          (cursor := S.popUndefined s ;
           let current = Js.Undefined.getUnsafe !cursor in
           Q.add q (valueGet current);
           cursor := rightGet current)
        else
          todo := false
      end
  done

let n
    ?l ?r a =
  node   ~value:a
    ~left:(Js.Undefined.fromOption l)
    ~right:(Js.Undefined.fromOption r)


let test1 =
  n 1
    ~l:
      (n 2
         ~l:(n 4 )
         ~r:(n 5))
    ~r:(n 3)

let pushAllLeft st1 s1 =
  let current = ref st1 in
  while !current != Js.undefined do
    let v = Js.Undefined.getUnsafe !current  in
    S.push s1 v;
    current := leftGet v;
  done
;;


let test2 =
  n 3
  ~l:(
    n 1
    ~l:(
      n 5
      ~l:
      (n 2
      ~l:
      (n 4)
      )
    )
  )

let test3 =

    n 1
    ~l:(
      n 5
      ~l:
      (n 2
      ~l:
      (n 4)
      )
    )
  ~r:(n 3)

;; eq __LOC__
  (inOrder (Js.Undefined.return test1))
  [|4;2;5;1;3|]
;; eq __LOC__
  (inOrder3 (Js.Undefined.return test1))
  [|4;2;5;1;3|]

;; Mt.from_pair_suites __FILE__ !suites
