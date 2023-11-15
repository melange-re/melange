(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
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

(** JavaScript String API *)

type t = string

external make : 'a -> t = "String"

(** [make value] converts the given value to a string

{[
  make 3.5 = "3.5";;
  make [|1;2;3|]) = "1,2,3";;
]}
*)

external fromCharCode : int -> t = "String.fromCharCode"

(** [fromCharCode n]
  creates a string containing the character corresponding to that number; {i n} ranges from 0 to 65535. If out of range, the lower 16 bits of the value are used. Thus, [fromCharCode 0x1F63A] gives the same result as [fromCharCode 0xF63A].

{[
  fromCharCode 65 = "A";;
  fromCharCode 0x3c8 = {js|ψ|js};;
  fromCharCode 0xd55c = {js|한|js};;
  fromCharCode -64568 = {js|ψ|js};;
]}
*)

external fromCharCodeMany : int array -> t = "String.fromCharCode"
[@@mel.splice]
(** [fromCharCodeMany \[|n1;n2;n3|\]] creates a string from the characters corresponding to the given numbers, using the same rules as [fromCharCode].

{[
  fromCharCodeMany([|0xd55c, 0xae00, 33|]) = {js|한글!|js};;
]}
*)

external fromCodePoint : int -> t = "String.fromCodePoint"
(** [fromCodePoint n]
  creates a string containing the character corresponding to that numeric code point. If the number is not a valid code point, {b raises} [RangeError]. Thus, [fromCodePoint 0x1F63A] will produce a correct value, unlike [fromCharCode 0x1F63A], and [fromCodePoint -5] will raise a [RangeError].

{[
  fromCodePoint 65 = "A";;
  fromCodePoint 0x3c8 = {js|ψ|js};;
  fromCodePoint 0xd55c = {js|한|js};;
  fromCodePoint 0x1f63a = {js|😺|js};;
]}

*)

external fromCodePointMany : int array -> t = "String.fromCodePoint"
[@@mel.splice]
(** [fromCharCodeMany \[|n1;n2;n3|\]] creates a string from the characters corresponding to the given code point numbers, using the same rules as [fromCodePoint].

{[
  fromCodePointMany([|0xd55c; 0xae00; 0x1f63a|]) = {js|한글😺|js}
]}
*)

external length : t -> int = "length"
[@@mel.get]
(** [length s] returns the length of the given string.

{[
  length "abcd" = 4;;
]}

*)

external get : t -> int -> t = ""
[@@mel.get_index]
(** [get s n] returns as a string the character at the given index number. If [n] is out of range, this function returns [undefined], so at some point this function may be modified to return [t option].

{[
  get "Reason" 0 = "R";;
  get "Reason" 4 = "o";;
  get {js|Rẽasöń|js} 5 = {js|ń|js};;
]}
*)

external charAt : t -> pos:int -> t = "charAt"
[@@mel.send]
(** [charAt s ~pos] gets the character at index [pos] within string [s]. If
    [pos] is negative or greater than the length of [s], returns the empty
    string. If the string contains characters outside the range
    [\u0000-\uffff], it will return the first 16-bit value at that position in
    the string.

{[
  charAt "Reason" ~pos:0 = "R"
  charAt "Reason" ~pos:12 = "";
  charAt {js|Rẽasöń|js} ~pos:5 = {js|ń|js}
]}
*)

external charCodeAt : t -> pos:int -> float = "charCodeAt"
[@@mel.send]
(** [charCodeAt s ~pos] returns the character code at position [pos] in string
    [s]; the result is in the range 0-65535, unlke [codePointAt], so it will
    not work correctly for characters with code points greater than or equal to
    [0x10000].
    The return type is [float] because this function returns [NaN] if [pos] is
    less than zero or greater than the length of the string.

{[
  charCodeAt {js|😺|js} ~pos:0 returns 0xd83d
  codePointAt {js|😺|js} ~pos:0 returns Some 0x1f63a
]}
*)

external codePointAt : t -> pos:int -> int option = "codePointAt"
[@@mel.send]
(** [codePointAt s ~pos] returns the code point at position [pos] within string
    [s] as a [Some] value. The return value handles code points greater than or
    equal to [0x10000]. If there is no code point at the given position, the
    function returns [None].

{[
  codePointAt {js|¿😺?|js} 1 = Some 0x1f63a
  codePointAt "abc" 5 = None
]}
*)

(** ES2015 *)

external concat : t -> other:t -> t = "concat"
[@@mel.send]
(** [concat original ~other] returns a new string with [other] added
    after [original].

{[
  concat "cow" ~other:"bell" = "cowbell";;
]}
*)

external concatMany : t -> strings:t array -> t = "concat"
[@@mel.send] [@@mel.splice]
(** [concatMany original ~strings] returns a new string consisting of each item
    of the array of strings [strings] added to the [original] string.

{[
  concatMany "1st" ~strings:[|"2nd"; "3rd"; "4th"|] = "1st2nd3rd4th";;
]}
*)

external endsWith : t -> suffix:t -> bool = "endsWith"
[@@mel.send]
(** [endsWith str ~suffix] returns [true] if the [str] ends with [suffix],
    [false] otherwise.

{[
  endsWith "Hello, World!" ~suffix:"World!" = true;;
  endsWith "Hello, World!" ~suffix:"world!" = false;; (* case-sensitive *)
  endsWith "Hello, World!" ~suffix:"World" = false;; (* exact match *)
]}
*)

external endsWithFrom : t -> suffix:t -> len:int -> bool = "endsWith"
[@@mel.send]
(** [endsWithFrom str ~len ~suffix] returns [true] if the first [len]
    characters of [str] end with [ending], [false] otherwise. If [len] is
    greater than or equal to the length of [str], then it works like
    [endsWith].

{[
  endsWithFrom "abcd" ~suffix:"cd" ~len:4 = true;;
  endsWithFrom "abcde" ~suffix:"cd" ~len:3 = false;;
  endsWithFrom "abcde" ~suffix:"cde" ~len:99 = true;;
  endsWithFrom "example.dat" ~suffix:"ple" ~len:7 = true;;
]}
*)

external includes : t -> sub:t -> bool = "includes"
[@@mel.send]
(** [includes s ~sub:searchValue] returns [true] if [searchValue] is found
    anywhere within [s], [false] otherwise.

{[
  includes "programmer" ~sub:"gram" = true;;
  includes "programmer" ~sub:"er" = true;;
  includes "programmer" ~sub:"pro" = true;;
  includes "programmer" ~sub:"xyz" = false;;
]}
*)

external includesFrom : t -> sub:t -> pos:int -> bool = "includes"
[@@mel.send]
(**
  [includes s ~sub:searchValue ~start] returns [true] if [searchValue] is found
  anywhere within [s] starting at character number [start] (where 0 is the
  first character), [false] otherwise.

{[
  includesFrom "programmer" ~sub:"gram" ~pos:1 = true;;
  includesFrom "programmer" ~sub:"gram" ~pos:4 = false;;
  includesFrom {js|대한민국|js} ~sub:{js|한|js} ~pos:1 = true;;
]}
*)

external indexOf : t -> sub:t -> int = "indexOf"
[@@mel.send]
(**
  [indexOf s ~sub:searchValue ] returns the position at which [searchValue] was
  first found within [s], or [-1] if [searchValue] is not in [s].

{[
  indexOf "bookseller" ~sub:"ok" = 2;;
  indexOf "bookseller" ~sub:"sell" = 4;;
  indexOf "beekeeper" ~sub:"ee" = 1;;
  indexOf "bookseller" ~sub:"xyz" = -1;;
]}
*)

external indexOfFrom : t -> sub:t -> pos:int -> int = "indexOf"
[@@mel.send]
(** [indexOfFrom s ~sub:searchValue ~start] returns the position at which
    [searchValue] was found within [s] starting at character position [start],
    or [-1] if [searchValue] is not found in that portion of [s]. The return
    value is relative to the beginning of the string, no matter where the
    search started from.

{[
  indexOfFrom "bookseller" ~sub:"ok" ~pos:1 = 2;;
  indexOfFrom "bookseller" ~sub:"sell" ~pos:2 = 4;;
  indexOfFrom "bookseller" ~sub:"sell" ~pos:5 = -1;;
]}
*)

external lastIndexOf : t -> sub:t -> int = "lastIndexOf"
[@@mel.send]
(**
  [lastIndexOf s ~sub:searchValue ] returns the position of the {i last}
  occurrence of [searchValue] within [s], searching backwards from the end of
  the string. Returns [-1] if [searchValue] is not in [s]. The return value is
  always relative to the beginning of the string.

{[
  lastIndexOf "bookseller" ~sub:"ok" = 2;;
  lastIndexOf "beekeeper" ~sub:"ee" = 4;;
  lastIndexOf "abcdefg" ~sub:"xyz" = -1;;
]}
*)

external lastIndexOfFrom : t -> sub:t -> pos:int -> int = "lastIndexOf"
[@@mel.send]
(**
  [lastIndexOfFrom s ~sub:searchValue ~start] returns the position of the {i
  last} occurrence of [searchValue] within [s], searching backwards from the
  given [start] position. Returns [-1] if [searchValue] is not in [s]. The
  return value is always relative to the beginning of the string.

{[
  lastIndexOfFrom "bookseller" ~sub:"ok" ~pos:6 = 2;;
  lastIndexOfFrom "beekeeper" ~sub:"ee" ~pos:8 = 4;;
  lastIndexOfFrom "beekeeper" ~sub:"ee" ~pos:3 = 1;;
  lastIndexOfFrom "abcdefg" ~sub:"xyz" ~pos:4 = -1;;
]}
*)

(* extended by ECMA-402 *)

external localeCompare : t -> other:t -> float = "localeCompare"
[@@mel.send]
(**
  [localeCompare reference ~other:comparison] returns:

{ul
  {- a negative value if [reference] comes before [comparison] in sort order}
  {- zero if [reference] and [comparison] have the same sort order}
  {- a positive value if [reference] comes after [comparison] in sort order}}

{[
  (localeCompare "zebra" "ant") > 0.0;;
  (localeCompare "ant" "zebra") < 0.0;;
  (localeCompare "cat" "cat") = 0.0;;
  (localeCompare "CAT" "cat") > 0.0;;
]}
*)

external match_ : t -> regexp:Js_re.t -> t option array option = "match"
[@@mel.send] [@@mel.return { null_to_opt }]
(**
  [match str ~regexp] matches a string against the given [regexp]. If there is
  no match, it returns [None]. For regular expressions without the [g]
  modifier, if there is a match, the return value is [Some array] where the
  array contains:

  {ul
    {- The entire matched string}
    {- Any capture groups if the [regexp] had parentheses}
  }

  For regular expressions with the [g] modifier, a matched expression returns
  [Some array] with all the matched substrings and no capture groups.

{[
  match "The better bats" ~regexp:[%re "/b[aeiou]t/"] = Some [|"bet"|]
  match "The better bats" ~regexp:[%re "/b[aeiou]t/g"] = Some [|"bet";"bat"|]
  match "Today is 2018-04-05." ~regexp:[%re "/(\\d+)-(\\d+)-(\\d+)/"] = Some [|"2018-04-05"; "2018"; "04"; "05"|]
  match "The large container." ~regexp:[%re "/b[aeiou]g/"] = None
]}
*)

external normalize : t -> t = "normalize"
[@@mel.send]
(** [normalize str] returns the normalized Unicode string using Normalization
    Form Canonical (NFC) Composition.

    Consider the character [ã], which can be represented as the single
    codepoint [\u00e3] or the combination of a lower case letter A [\u0061] and
    a combining tilde [\u0303]. Normalization ensures that both can be stored
    in an equivalent binary representation.

    @see <https://www.unicode.org/reports/tr15/tr15-45.html> Unicode technical
    report for details
*)

external normalizeByForm : t -> form:[ `NFC | `NFD | `NFKC | `NFKD ] -> t
  = "normalize"
[@@mel.send]
(** [normalize str ~form] returns the normalized Unicode string using the
    specified form of normalization, which may be one of:

  {ul
    {- [`NFC] — Normalization Form Canonical Composition.}
    {- [`NFD] — Normalization Form Canonical Decomposition.}
    {- [`NFKC] — Normalization Form Compatibility Composition.}
    {- [`NFKD] — Normalization Form Compatibility Decomposition.}
  }

  @see <https://www.unicode.org/reports/tr15/tr15-45.html> Unicode technical
  report for details
*)

external repeat : t -> n:int -> t = "repeat"
[@@mel.send]
(** [repeat s n] returns a string that consists of [n] repetitions of [s].
    Raises [RangeError] if [n] is negative.

{[
  repeat "ha" ~n:3 = "hahaha"
  repeat "empty" ~n:0 = ""
]}
*)

external replace : t -> sub:t -> replacement:t -> t = "replace"
[@@mel.send]
(** [replace string ~sub ~replacement] returns a new string which is
    identical to [string] except with the first matching instance of [sub]
    replaced by [replacement].

    [sub] is treated as a verbatim string to match, not a regular expression.

{[
  replace "old string" ~sub:"old" ~replacement:"new" = "new string"
  replace "the cat and the dog" ~sub:"the" ~replacement:"this" = "this cat and the dog"
]}
*)

external replaceByRe : t -> regexp:Js_re.t -> replacement:t -> t = "replace"
[@@mel.send]
(** [replaceByRe string ~regexp ~replacement] returns a new string where
    occurrences matching [regexp] have been replaced by [replacement].

{[
  replaceByRe "vowels be gone" ~regexp:[%re "/[aeiou]/g"] ~replacement:"x" = "vxwxls bx gxnx"
  replaceByRe "Juan Fulano" ~regexp:[%re "/(\\w+) (\\w+)/"] ~replacement:"$2, $1" = "Fulano, Juan"
]}
*)

external unsafeReplaceBy0 :
  t -> regexp:Js_re.t -> f:((t -> int -> t -> t)[@mel.uncurry]) -> t = "replace"
[@@mel.send]
(** [unsafeReplaceBy0 s ~regexp ~f] returns a new string with some or all
    matches of a pattern with no capturing parentheses replaced by the value
    returned from the given function. The function receives as its parameters
    the matched string, the offset at which the match begins, and the whole
    string being matched

{[
let str = "beautiful vowels"
let re = [%re "/[aeiou]/g"]
let matchFn matchPart offset wholeString = Js.String.toUpperCase matchPart

let replaced = Js.String.unsafeReplaceBy0 str ~regexp:re ~f:matchFn

let () = Js.log replaced (* prints "bEAUtifUl vOwEls" *)
]}

  @see
  <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter>
  MDN
*)

external unsafeReplaceBy1 :
  t -> regexp:Js_re.t -> f:((t -> t -> int -> t -> t)[@mel.uncurry]) -> t
  = "replace"
[@@mel.send]
(** [unsafeReplaceBy0 s ~regexp ~f] returns a new string with some or all
    matches of a pattern with one set of capturing parentheses replaced by the
    value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

   {[
   let str = "increment 23"
   let re = [%re "/increment (\\d+)/g"]
   let matchFn matchPart p1 offset wholeString =
     wholeString ^ " is " ^ (string_of_int ((int_of_string p1) + 1))

   let replaced = Js.String.unsafeReplaceBy1 str ~regexp:re ~f:matchFn

   let () = Js.log replaced (* prints "increment 23 is 24" *)
   ]}

   @see
   <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter>
MDN
*)

external unsafeReplaceBy2 :
  t -> regexp:Js_re.t -> f:((t -> t -> t -> int -> t -> t)[@mel.uncurry]) -> t
  = "replace"
[@@mel.send]
(** [unsafeReplaceBy2 s ~regexp ~f] returns a new string with some or all
    matches of a pattern with two sets of capturing parentheses replaced by the
    value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

{[
let str = "7 times 6"
let re = [%re "/(\\d+) times (\\d+)/"]
let matchFn matchPart p1 p2 offset wholeString =
  string_of_int ((int_of_string p1) * (int_of_string p2))

let replaced = Js.String.unsafeReplaceBy2 str ~regexp:re ~f:matchFn

let () = Js.log replaced (* prints "42" *)
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter> MDN
*)

external unsafeReplaceBy3 :
  t ->
  regexp:Js_re.t ->
  f:((t -> t -> t -> t -> int -> t -> t)[@mel.uncurry]) ->
  t = "replace"
[@@mel.send]
(** [unsafeReplaceBy3 s ~regexp ~f] returns a new string with some or all
    matches of a pattern with three sets of capturing parentheses replaced by
    the value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

    @see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter> MDN
*)

external search : t -> regexp:Js_re.t -> int = "search"
[@@mel.send]
(** [search str ~regexp] returns the starting position of the first match of
    [regexp] in the given [str], or -1 if there is no match.

{[
search "testing 1 2 3" [%re "/\\d+/"] = 8;;
search "no numbers" [%re "/\\d+/"] = -1;;
]}
*)

external slice : t -> from:int -> to_:int -> t = "slice"
[@@mel.send]
(** [slice from:n1 to_:n2 str] returns the substring of [str] starting at
    character [n1] up to but not including [n2]

    If either [n1] or [n2] is negative, then it is evaluated as [length str -
    n1] (or [length str - n2]).

    If [n2] is greater than the length of [str], then it is treated as [length
    str].

    If [n1] is greater than [n2], [slice] returns the empty string.

{[
  slice "abcdefg" ~from:2 ~to_:5 == "cde";;
  slice "abcdefg" ~from:2 ~to_:9 == "cdefg";;
  slice "abcdefg" ~from:(-4) ~to_:(-2) == "de";;
  slice "abcdefg" ~from:5 ~to_:1 == "";;
]}
*)

external sliceToEnd : t -> from:int -> t = "slice"
[@@mel.send]
(** [sliceToEnd from: n str] returns the substring of [str] starting at
    character [n] to the end of the string

    If [n] is negative, then it is evaluated as [length str - n].

    If [n] is greater than the length of [str], then [sliceToEnd] returns the
    empty string.

{[
  sliceToEnd "abcdefg" ~from: 4 == "efg";;
  sliceToEnd "abcdefg" ~from: (-2) == "fg";;
  sliceToEnd "abcdefg" ~from: 7 == "";;
]}
*)

external split : t -> sep:t -> t array = "split"
[@@mel.send]
(**
  [split str ~sep:delimiter] splits the given [str] at every occurrence of
  [delimiter] and returns an array of the resulting substrings.

{[
  split "2018-01-02" "-" = [|"2018"; "01"; "02"|];;
  split "a,b,,c" "," = [|"a"; "b"; ""; "c"|];;
  split "good::bad as great::awful" "::" = [|"good"; "bad as great"; "awful"|];;
  split "has-no-delimiter" ";" = [|"has-no-delimiter"|];;
]};
*)

external splitAtMost : t -> sep:t -> limit:int -> t array = "split"
[@@mel.send]
(** [splitAtMost delimiter ~limit: n str] splits the given [str] at every
    occurrence of [delimiter] and returns an array of the first [n] resulting
    substrings. If [n] is negative or greater than the number of substrings,
    the array will contain all the substrings.

{[
  splitAtMost "ant/bee/cat/dog/elk" ~sep:"/" ~limit: 3 = [|"ant"; "bee"; "cat"|];;
  splitAtMost "ant/bee/cat/dog/elk" ~sep:"/" ~limit: 0 = [| |];;
  splitAtMost "ant/bee/cat/dog/elk" ~sep:"/" ~limit: 9 = [|"ant"; "bee"; "cat"; "dog"; "elk"|];;
]}
*)

external splitByRe : t -> regexp:Js_re.t -> t option array = "split"
[@@mel.send]
(** [splitByRe str ~regexp] splits the given [str] at every occurrence of
    [regexp] and returns an array of the resulting substrings.

{[
  splitByRe "art; bed , cog ;dad" ~regexp:[%re "/\\s*[,;]\\s*/"] = [|"art"; "bed"; "cog"; "dad"|];;
  splitByRe "has:no:match" ~regexp:[%re "/[,;]/"] = [|"has:no:match"|];;
]};
*)

external splitByReAtMost : t -> regexp:Js_re.t -> limit:int -> t option array
  = "split"
[@@mel.send]
(** [splitByReAtMost ~regexp ~limit:n str] splits the given [str] at every
    occurrence of [regexp] and returns an array of the first [n] resulting
    substrings. If [n] is negative or greater than the number of substrings,
    the array will contain all the substrings.

{[
  splitByReAtMost "one: two: three: four" [%re "/\\s*:\\s*/"] ~limit: 3 = [|"one"; "two"; "three"|];;
  splitByReAtMost "one: two: three: four" [%re "/\\s*:\\s*/"] ~limit: 0 = [| |];;
  splitByReAtMost "one: two: three: four" [%re "/\\s*:\\s*/"] ~limit: 8 = [|"one"; "two"; "three"; "four"|];;
]};
*)

external startsWith : t -> prefix:t -> bool = "startsWith"
[@@mel.send]
(** [startsWith str ~prefix] returns [true] if the [str] starts with [prefix],
    [false] otherwise.

{[
  startsWith "Hello, World!" ~prefix:"Hello" = true;;
  startsWith "Hello, World!" ~prefix:"hello" = false;; (* case-sensitive *)
  startsWith "Hello, World!" ~prefix:"World" = false;; (* exact match *)
]}
*)

external startsWithFrom : t -> prefix:t -> pos:int -> bool = "startsWith"
[@@mel.send]
(** [startsWithFrom str ~prefix ~start] returns [true] if the [str] starts with
    [prefix] starting at position [start], [false] otherwise. If [n] is
    negative, the search starts at the beginning of [str].

{[
  startsWithFrom "Hello, World!" "Hello" 0 = true;;
  startsWithFrom "Hello, World!" "World" 7 = true;;
  startsWithFrom "Hello, World!" "World" 8 = false;;
]}
*)

external substr : t -> from:int -> t = "substr"
[@@mel.send]
(** [substr ~from:n str] returns the substring of [str] from position [n] to
    the end of the string.

    If [n] is less than zero, the starting position is the length of [str] -
    [n].

    If [n] is greater than or equal to the length of [str], returns the empty
    string.

{[
  substr "abcdefghij" ~from: 3 = "defghij"
  substr "abcdefghij" ~from: (-3) = "hij"
  substr "abcdefghij" ~from: 12 = ""
]}
*)

external substrAtMost : t -> from:int -> length:int -> t = "substr"
[@@mel.send]
(** [substrAtMost ~from:pos ~length:n str] returns the substring of [str] of
    length [n] starting at position [pos].

    If [pos] is less than zero, the starting position is the length of [str] -
    [pos].

    If [pos] is greater than or equal to the length of [str], returns the empty
    string.

    If [n] is less than or equal to zero, returns the empty string.

{[
  substrAtMost "abcdefghij" ~from: 3 ~length: 4 = "defghij"
  substrAtMost "abcdefghij" ~from: (-3) ~length: 4 = "hij"
  substrAtMost "abcdefghij" ~from: 12 ~ length: 2 = ""
]}
*)

external substring : t -> from:int -> to_:int -> t = "substring"
[@@mel.send]
(** [substring ~from: start ~to_: finish str] returns characters [start] up to
    but not including [finish] from [str].

    If [start] is less than zero, it is treated as zero.

    If [finish] is zero or negative, the empty string is returned.

    If [start] is greater than [finish], the start and finish points are
    swapped.

{[
  substring "playground" ~from: 3 ~to_: 6 = "ygr";;
  substring "playground" ~from: 6 ~to_: 3 = "ygr";;
  substring "playground" ~from: 4 ~to_: 12 = "ground";;
]}
*)

external substringToEnd : t -> from:int -> t = "substring"
[@@mel.send]
(** [substringToEnd ~from: start str] returns the substring of [str] from
    position [start] to the end.

    If [start] is less than or equal to zero, the entire string is returned.

    If [start] is greater than or equal to the length of [str], the empty
    string is returned.

{[
  substringToEnd "playground" ~from: 4 = "ground";;
  substringToEnd "playground" ~from: (-3) = "playground";;
  substringToEnd "playground" ~from: 12 = "";
]}
*)

external toLowerCase : t -> t = "toLowerCase"
[@@mel.send]
(** [toLowerCase str] converts [str] to lower case using the locale-insensitive
    case mappings in the Unicode Character Database. Notice that the conversion
    can give different results depending upon context, for example with the
    Greek letter sigma, which has two different lower case forms when it is the
    last character in a string or not.

{[
  toLowerCase "ABC" = "abc";;
  toLowerCase {js|ΣΠ|js} = {js|σπ|js};;
  toLowerCase {js|ΠΣ|js} = {js|πς|js};;
]}
*)

external toLocaleLowerCase : t -> t = "toLocaleLowerCase"
[@@mel.send]
(**
  [toLocaleLowerCase str] converts [str] to lower case using the current locale
*)

external toUpperCase : t -> t = "toUpperCase"
[@@mel.send]
(**
  [toUpperCase str] converts [str] to upper case using the locale-insensitive
  case mappings in the Unicode Character Database. Notice that the conversion
  can expand the number of letters in the result; for example the German [ß]
  capitalizes to two [S]es in a row.

{[
  toUpperCase "abc" = "ABC";;
  toUpperCase {js|Straße|js} = {js|STRASSE|js};;
  toLowerCase {js|πς|js} = {js|ΠΣ|js};;
]}
*)

external toLocaleUpperCase : t -> t = "toLocaleUpperCase"
[@@mel.send]
(** [toLocaleUpperCase str] converts [str] to upper case using the current
    locale
*)

external trim : t -> t = "trim"
[@@mel.send]
(** [trim str] returns a string that is [str] with whitespace stripped from
    both ends. Internal whitespace is not removed.

{[
  trim "   abc def   " = "abc def"
  trim "\n\r\t abc def \n\n\t\r " = "abc def"
]}
*)

(* HTML wrappers *)

external anchor : t -> name:t -> t = "anchor"
[@@mel.send]
(** [anchor anchorName ~text:anchorText] creates a string with an HTML [<a>]
    element with [name] attribute of [anchorName] and [anchorText] as its
    content.

{[
  anchor "page1" "Page One" = "<a name=\"page1\">Page One</a>"
]}
*)

external link : t -> href:t -> t = "link"
[@@mel.send]
(** [link linkText ~href:urlText] creates a string with an HTML [<a>] element
    with [href] attribute of [urlText] and [linkText] as its content.

{[
  link "Go to page two" "page2.html" = "<a href=\"page2.html\">Go to page two</a>"
]}
*)

external castToArrayLike : t -> t Js_array.array_like = "%identity"
(* FIXME: we should not encourage people to use [%identity], better
    to provide something using  so that we can track such
    casting
*)
