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
[@@mel.variadic]
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
[@@mel.variadic]
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

external charAt : index:int -> t = "charAt"
[@@mel.send.pipe: t]
(** [charAt ~index s] gets the character at position [index] within string [s].
    If [index] is negative or greater than the length of [s], returns the empty
    string. If the string contains characters outside the range
    [\u0000-\uffff], it will return the first 16-bit value at that position in
    the string.

{[
  charAt ~index:0 "Reason" = "R"
  charAt ~index:12 "Reason" = "";
  charAt ~index:5 {js|Rẽasöń|js} = {js|ń|js}
]}
*)

external charCodeAt : index:int -> float = "charCodeAt"
[@@mel.send.pipe: t]
(** [charCodeAt s ~index] returns the character code at position [index] in string
    [s]; the result is in the range 0-65535, unlke [codePointAt], so it will
    not work correctly for characters with code points greater than or equal to
    [0x10000].
    The return type is [float] because this function returns [NaN] if [index] is
    less than zero or greater than the length of the string.

{[
  charCodeAt ~index:0 {js|😺|js} = 0xd83d
  codePointAt ~index:0 {js|😺|js} = Some 0x1f63a
]}
*)

external codePointAt : index:int -> int option = "codePointAt"
[@@mel.send.pipe: t]
(** [codePointAt s ~index] returns the code point at position [index] within string
    [s] as a [Some] value. The return value handles code points greater than or
    equal to [0x10000]. If there is no code point at the given position, the
    function returns [None].

{[
  codePointAt ~index:1 {js|¿😺?|js} = Some 0x1f63a
  codePointAt ~index:5 "abc" = None
]}
*)

(** ES2015 *)

external concat : other:t -> t = "concat"
[@@mel.send.pipe: t]
(** [concat ~other original] returns a new string with [other] added after
    [original].

{[
  concat ~other:"bell" "cow" = "cowbell";;
]}
*)

external concatMany : strings:t array -> t = "concat"
[@@mel.send.pipe: t] [@@mel.variadic]
(** [concatMany ~strings original] returns a new string consisting of each item
    of the array of strings [strings] added to the [original] string.

{[
  concatMany ~strings:[|"2nd"; "3rd"; "4th"|] "1st" = "1st2nd3rd4th";;
]}
*)

external endsWith : suffix:t -> ?len:int -> bool = "endsWith"
[@@mel.send.pipe: t]
(** [endsWith ~suffix ?len str] returns [true] if the [str] ends with [suffix],
    [false] otherwise. If [len] is specified, `endsWith` only takes into
    account the first [len] characters.

{[
  endsWith ~suffix:"cd" ~len:4 "abcd" = true;;
  endsWith ~suffix:"cd" ~len:3 "abcde" = false;;
  endsWith ~suffix:"cde" ~len:99 "abcde" = true;;
  endsWith ~suffix:"ple" ~len:7 "example.dat" = true;;
  endsWith ~suffix:"World!" "Hello, World!" = true;;
  endsWith ~suffix:"world!" "Hello, World!" = false;; (* case-sensitive *)
  endsWith ~suffix:"World" "Hello, World!" = false;; (* exact match *)
]}
*)

external includes : search:t -> ?start:int -> bool = "includes"
[@@mel.send.pipe: t]
(**
  [includes ~search ?start s] returns [true] if [search] is found anywhere
  within [s] starting at character number [start] (where 0 is the first
  character), [false] otherwise.

{[
  includes ~search:"gram" "programmer" = true;;
  includes ~search:"er" "programmer" = true;;
  includes ~search:"pro" "programmer" = true;;
  includes ~search:"xyz" "programmer" = false;;
  includes ~search:"gram" ~start:1 "programmer" = true;;
  includes ~search:"gram" ~start:4 "programmer" = false;;
  includes ~search:{js|한|js} ~start:1 {js|대한민국|js} = true;;
]}
*)

external indexOf : search:t -> ?start:int -> int = "indexOf"
[@@mel.send.pipe: t]
(** [indexOf ~search ?start s] returns the position at which [search] was found
    within [s] starting at character position [start], or [-1] if [search] is
    not found in that portion of [s]. The return value is relative to the
    beginning of the string, no matter where the search started from.

{[
  indexOf ~search:"ok" "bookseller" = 2;;
  indexOf ~search:"sell" "bookseller" = 4;;
  indexOf ~search:"ee" "beekeeper" = 1;;
  indexOf ~search:"xyz" "bookseller" = -1;;
  indexOf ~search:"ok" ~start:1 "bookseller" = 2;;
  indexOf ~search:"sell" ~start:2 "bookseller" = 4;;
  indexOf ~search:"sell" ~start:5 "bookseller" = -1;;
]}
*)

external lastIndexOf : search:t -> ?start:int -> int = "lastIndexOf"
[@@mel.send.pipe: t]
(**
  [lastIndexOf ~search ~start s] returns the position of the {i last}
  occurrence of [searchValue] within [s], searching backwards from the given
  [start] position. Returns [-1] if [searchValue] is not in [s]. The return
  value is always relative to the beginning of the string.

{[
  lastIndexOf ~search:"ok" "bookseller" = 2;;
  lastIndexOf ~search:"ee" "beekeeper" = 4;;
  lastIndexOf ~search:"xyz" "abcdefg" = -1;;
  lastIndexOf ~search:"ok" ~start:6 "bookseller" = 2;;
  lastIndexOf ~search:"ee" ~start:8 "beekeeper" = 4;;
  lastIndexOf ~search:"ee" ~start:3 "beekeeper" = 1;;
  lastIndexOf ~search:"xyz" ~start:4 "abcdefg" = -1;;
]}
*)

(* extended by ECMA-402 *)

external localeCompare : other:t -> float = "localeCompare"
[@@mel.send.pipe: t]
(**
  [localeCompare ~other:comparison reference] returns:

{ul
  {- a negative value if [reference] comes before [comparison] in sort order}
  {- zero if [reference] and [comparison] have the same sort order}
  {- a positive value if [reference] comes after [comparison] in sort order}}

{[
  (localeCompare ~other:"ant" "zebra") > 0.0;;
  (localeCompare ~other:"zebra" "ant") < 0.0;;
  (localeCompare ~other:"cat" "cat") = 0.0;;
  (localeCompare ~other:"cat" "CAT") > 0.0;;
]}
*)

external match_ : regexp:Js_re.t -> t option array option = "match"
[@@mel.send.pipe: t] [@@mel.return { null_to_opt }]
(**
  [match ~regexp str] matches a string against the given [regexp]. If there is
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

external normalize : ?form:[ `NFC | `NFD | `NFKC | `NFKD ] -> t = "normalize"
[@@mel.send.pipe: t]
(** [normalize ~form str] returns the normalized Unicode string using the
    specified form of normalization, which may be one of:

  {ul
    {- [`NFC] — Normalization Form Canonical Composition.}
    {- [`NFD] — Normalization Form Canonical Decomposition.}
    {- [`NFKC] — Normalization Form Compatibility Composition.}
    {- [`NFKD] — Normalization Form Compatibility Decomposition.}
  }

  If [form] is omitted, [`NFC] is used.

  Consider the character [ã], which can be represented as the single codepoint
  [\u00e3] or the combination of a lower case letter A [\u0061] and a combining
  tilde [\u0303]. Normalization ensures that both can be stored in an
  equivalent binary representation.

  @see <https://www.unicode.org/reports/tr15/tr15-45.html> Unicode technical
  report for details
*)

external repeat : count:int -> t = "repeat"
[@@mel.send.pipe: t]
(** [repeat ~count s] returns a string that consists of [count] repetitions of
    [s]. Raises [RangeError] if [n] is negative.

{[
  repeat ~count:3 "ha" = "hahaha"
  repeat ~count:0 "empty" = ""
]}
*)

external replace : search:t -> replacement:t -> t = "replace"
[@@mel.send.pipe: t]
(** [replace ~search ~replacement string] returns a new string which is
    identical to [string] except with the first matching instance of [search]
    replaced by [replacement].

    [search] is treated as a verbatim string to match, not a regular
    expression.

{[
  replace ~search:"old" ~replacement:"new" "old string" = "new string"
  replace ~search:"the" ~replacement:"this" "the cat and the dog" = "this cat and the dog"
]}
*)

external replaceByRe : regexp:Js_re.t -> replacement:t -> t = "replace"
[@@mel.send.pipe: t]
(** [replaceByRe ~regexp ~replacement string] returns a new string where
    occurrences matching [regexp] have been replaced by [replacement].

{[
  replaceByRe ~regexp:[%re "/[aeiou]/g"] ~replacement:"x" "vowels be gone" = "vxwxls bx gxnx"
  replaceByRe ~regexp:[%re "/(\\w+) (\\w+)/"] ~replacement:"$2, $1" "Juan Fulano" = "Fulano, Juan"
]}
*)

external unsafeReplaceBy0 :
  regexp:Js_re.t -> f:((t -> int -> t -> t)[@mel.uncurry]) -> t = "replace"
[@@mel.send.pipe: t]
(** [unsafeReplaceBy0 ~regexp ~f s] returns a new string with some or all
    matches of a pattern with no capturing parentheses replaced by the value
    returned from the given function. The function receives as its parameters
    the matched string, the offset at which the match begins, and the whole
    string being matched

{[
let str = "beautiful vowels"
let re = [%re "/[aeiou]/g"]
let matchFn matchPart offset wholeString = Js.String.toUpperCase matchPart

let replaced = Js.String.unsafeReplaceBy0 ~regexp:re ~f:matchFn str

let () = Js.log replaced (* prints "bEAUtifUl vOwEls" *)
]}

  @see
  <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter>
  MDN
*)

external unsafeReplaceBy1 :
  regexp:Js_re.t -> f:((t -> t -> int -> t -> t)[@mel.uncurry]) -> t = "replace"
[@@mel.send.pipe: t]
(** [unsafeReplaceBy1 ~regexp ~f s] returns a new string with some or all
    matches of a pattern with one set of capturing parentheses replaced by the
    value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

   {[
   let str = "increment 23"
   let re = [%re "/increment (\\d+)/g"]
   let matchFn matchPart p1 offset wholeString =
     wholeString ^ " is " ^ (string_of_int ((int_of_string p1) + 1))

   let replaced = Js.String.unsafeReplaceBy1 ~regexp:re ~f:matchFn str

   let () = Js.log replaced (* prints "increment 23 is 24" *)
   ]}

   @see
   <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter>
MDN
*)

external unsafeReplaceBy2 :
  regexp:Js_re.t -> f:((t -> t -> t -> int -> t -> t)[@mel.uncurry]) -> t
  = "replace"
[@@mel.send.pipe: t]
(** [unsafeReplaceBy2 ~regexp ~f s] returns a new string with some or all
    matches of a pattern with two sets of capturing parentheses replaced by the
    value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

{[
let str = "7 times 6"
let re = [%re "/(\\d+) times (\\d+)/"]
let matchFn matchPart p1 p2 offset wholeString =
  string_of_int ((int_of_string p1) * (int_of_string p2))

let replaced = Js.String.unsafeReplaceBy2 ~regexp:re ~f:matchFn str

let () = Js.log replaced (* prints "42" *)
]}

@see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter> MDN
*)

external unsafeReplaceBy3 :
  regexp:Js_re.t -> f:((t -> t -> t -> t -> int -> t -> t)[@mel.uncurry]) -> t
  = "replace"
[@@mel.send.pipe: t]
(** [unsafeReplaceBy3 ~regexp ~f s] returns a new string with some or all
    matches of a pattern with three sets of capturing parentheses replaced by
    the value returned from the given function. The function receives as its
    parameters the matched string, the captured strings, the offset at which
    the match begins, and the whole string being matched.

    @see <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter> MDN
*)

external search : regexp:Js_re.t -> int = "search"
[@@mel.send.pipe: t]
(** [search ~regexp str] returns the starting position of the first match of
    [regexp] in the given [str], or -1 if there is no match.

{[
search ~regexp:[%re "/\\d+/"] "testing 1 2 3" = 8;;
search ~regexp:[%re "/\\d+/"] "no numbers" = -1;;
]}
*)

external slice : ?start:int -> ?end_:int -> t = "slice"
[@@mel.send.pipe: t]
(** [slice ?start ?end str] returns the substring of [str] starting at
    character [start] up to but not including [end]

    If either [start] or [end] is negative, then it is evaluated as [length str
    - start] (or [length str - end]).

    If [end] is greater than the length of [str], then it is treated as [length
    str].

    If [start] is greater than [end], [slice] returns the empty string.

{[
  slice ~start:2 ~end_:5 "abcdefg" = "cde";;
  slice ~start:2 ~end_:9 "abcdefg" = "cdefg";;
  slice ~start:(-4) ~end_:(-2) "abcdefg" = "de";;
  slice ~start:5 ~end_:1 "abcdefg" = "";;
]}
*)

external split : ?sep:t -> ?limit:int -> t array = "split"
[@@mel.send.pipe: t]
(** [split ?sep ?limit str] splits the given [str] at every occurrence of
    [sep] and returns an array of the first [limit] resulting substrings. If
    [limit] is negative or greater than the number of substrings, the array
    will contain all the substrings.

{[
  split ~sep:"/" ~limit: 3 "ant/bee/cat/dog/elk" = [|"ant"; "bee"; "cat"|];;
  split ~sep:"/" ~limit: 0 "ant/bee/cat/dog/elk" = [| |];;
  split ~sep:"/" ~limit: 9 "ant/bee/cat/dog/elk" = [|"ant"; "bee"; "cat"; "dog"; "elk"|];;
]}
*)

external splitByRe : regexp:Js_re.t -> ?limit:int -> t option array = "split"
[@@mel.send.pipe: t]
(** [splitByRe str ~regexp ?limit ()] splits the given [str] at every
    occurrence of [regexp] and returns an array of the first [limit] resulting
    substrings. If [limit] is negative or greater than the number of
    substrings, the array will contain all the substrings.

{[
  splitByRe ~regexp:[%re "/\\s*:\\s*/"] ~limit:3 "one: two: three: four" = [|"one"; "two"; "three"|];;
  splitByRe ~regexp:[%re "/\\s*:\\s*/"] ~limit:0 "one: two: three: four" = [| |];;
  splitByRe ~regexp:[%re "/\\s*:\\s*/"] ~limit:8 "one: two: three: four" = [|"one"; "two"; "three"; "four"|];;
]};
*)

external startsWith : prefix:t -> ?start:int -> bool = "startsWith"
[@@mel.send.pipe: t]
(** [startsWith ~prefix ?start str] returns [true] if the [str] starts with
    [prefix] starting at position [start], [false] otherwise. If [start] is
    negative, the search starts at the beginning of [str].

{[
  startsWith ~prefix:"Hello" ~start:0 "Hello, World!" = true;;
  startsWith ~prefix:"World" ~start:7 "Hello, World!" = true;;
  startsWith ~prefix:"World" ~start:8 "Hello, World!" = false;;
]}
*)

external substr : ?start:int -> ?len:int -> t = "substr"
[@@mel.send.pipe: t]
[@@alert
  deprecated
    "This function is deprecated, see \
     https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/substr#sect1"]
(** [substr ?start ?len str] returns the substring of [str] of length [len]
    starting at position [start].

    If [start] is less than zero, the starting position is the length of [str]
    - [start].

    If [start] is greater than or equal to the length of [str], returns the
    empty string.

    If [len] is less than or equal to zero, returns the empty string.

{[
  substr ~start:3 ~len:4 "abcdefghij" = "defghij"
  substr ~start:(-3) ~len:4 "abcdefghij" = "hij"
  substr ~start:12 ~len:2 "abcdefghij" = ""
]}
*)

external substring : ?start:int -> ?end_:int -> t = "substring"
[@@mel.send.pipe: t]
(** [substring ~start ~end_ str] returns characters [start] up to but not
    including [end_] from [str].

    If [start] is less than zero, it is treated as zero.

    If [end_] is zero or negative, the empty string is returned.

    If [start] is greater than [end_], the start and finish points are swapped.

{[
  substring ~start:3 ~end_:6 "playground" = "ygr";;
  substring ~start:6 ~end_:3 "playground" = "ygr";;
  substring ~start:4 ~end_:12 "playground" = "ground";;
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
  toUpperCase {js|πς|js} = {js|ΠΣ|js};;
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

external anchor : name:t -> t = "anchor"
[@@mel.send.pipe: t]
[@@alert
  deprecated
    "This function is deprecated, see \
     https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/anchor#sect1"]
(** [anchor ~name:anchorName anchorText] creates a string with an HTML [<a>]
    element with [name] attribute of [anchorName] and [anchorText] as its
    content.

{[
  anchor ~name:"page1" "Page One" = "<a name=\"page1\">Page One</a>"
]}
*)

external link : href:t -> t = "link"
[@@mel.send.pipe: t]
[@@alert
  deprecated
    "This function is deprecated, see \
     https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/link#sect1"]
(** [link ~href:urlText linkText] creates a string with an HTML [<a>] element
    with [href] attribute of [urlText] and [linkText] as its content.

{[
  link ~href:"page2.html" "Go to page two" = "<a href=\"page2.html\">Go to page two</a>"
]}
*)

external unsafeToArrayLike : t -> t Js_array.array_like = "%identity"
