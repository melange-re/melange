let suites = Mt.[
    "make", (fun _ ->
      Eq("null", Js.String.make Js.null |. Js.String.concat ~other:"")
    );

    "fromCharCode", (fun _ ->
      Eq("a", Js.String.fromCharCode 97)
    );
    "fromCharCodeMany", (fun _ ->
      Eq("az", Js.String.fromCharCodeMany [| 97; 122 |])
    );

    (* es2015 *)
    "fromCodePoint", (fun _ ->
      Eq("a", Js.String.fromCodePoint 0x61)
    );
    "fromCodePointMany", (fun _ ->
      Eq("az", Js.String.fromCodePointMany [| 0x61; 0x7a |])
    );

    "length", (fun _ ->
      Eq(3, "foo" |. Js.String.length)
    );

    "get", (fun _ ->
      Eq("a", Js.String.get "foobar" 4)
    );

    "charAt", (fun _ ->
      Eq("a", "foobar" |. Js.String.charAt ~index:4)
    );

    "charCodeAt", (fun _ ->
      Eq(97., "foobar" |. Js.String.charCodeAt ~index:4)
    );

    (* es2015 *)
    "codePointAt", (fun _ ->
      Eq(Some 0x61, "foobar" |. Js.String.codePointAt ~index:4)
    );
    "codePointAt - out of bounds", (fun _ ->
      Eq(None, "foobar" |. Js.String.codePointAt ~index:98)
    );

    "concat", (fun _ ->
      Eq("foobar", "foo" |. Js.String.concat ~other:"bar")
    );
    "concatMany", (fun _ ->
      Eq("foobarbaz", "foo" |. Js.String.concatMany ~strings:[| "bar"; "baz" |])
    );

    (* es2015 *)
    "endsWith", (fun _ ->
      Eq(true, "foobar" |. Js.String.endsWith ~suffix:"bar")
    );
    "endsWithFrom", (fun _ ->
      Eq(false, "foobar" |. Js.String.endsWith ~suffix:"bar" ~len:1)
    );

    (* es2015 *)
    "includes", (fun _ ->
      Eq(true, "foobarbaz" |. Js.String.includes ~search:"bar")
    );
    "includesFrom", (fun _ ->
      Eq(false, "foobarbaz" |. Js.String.includes ~search:"bar" ~start:4)
    );

    "indexOf", (fun _ ->
      Eq(3, "foobarbaz" |. Js.String.indexOf ~search:"bar")
    );
    "indexOfFrom", (fun _ ->
      Eq((-1), "foobarbaz" |. Js.String.indexOf ~search:"bar" ~start:4)
    );

    "lastIndexOf", (fun _ ->
      Eq(3, "foobarbaz" |. Js.String.lastIndexOf ~search:"bar")
    );
    "lastIndexOfFrom", (fun _ ->
      Eq(3, "foobarbaz" |. Js.String.lastIndexOf ~search:"bar" ~start:4)
    );

    "localeCompare", (fun _ ->
      Eq(0., "foo" |. Js.String.localeCompare ~other:"foo")
    );

    "match", (fun _ ->
      Eq(Some [| Some "na"; Some "na" |], "banana" |. Js.String.match_ ~regexp:[%re "/na+/g"])
    );
    "match - no match", (fun _ ->
      Eq(None, "banana" |. Js.String.match_ ~regexp:[%re "/nanana+/g"])
    );
    "match - not found capture groups", (fun _ ->
      Eq(
        Some [| Some "hello "; None |],
        "hello word"
        |. Js.String.match_ ~regexp:[%re "/hello (world)?/"]
        |. Belt.Option.map Js.Array.copy )
    );

    (* es2015 *)
    "normalize", (fun _ ->
      Eq("foo", Js.String.normalize "foo")
    );
    "normalizeByForm", (fun _ ->
      Eq("foo", Js.String.normalize ~form:`NFKD "foo")
    );

    (* es2015 *)
    "repeat", (fun _ ->
      Eq("foofoofoo", "foo" |. Js.String.repeat ~count:3)
    );

    "replace", (fun _ ->
      Eq("fooBORKbaz", "foobarbaz" |. Js.String.replace ~search:"bar" ~replacement:"BORK")
    );
    "replaceByRe", (fun _ ->
      Eq("fooBORKBORK", "foobarbaz" |. Js.String.replaceByRe ~regexp:[%re "/ba./g"] ~replacement:"BORK")
    );
    "unsafeReplaceBy0", (fun _ ->
      let replace = fun whole offset s ->
        if whole = "bar" then "BORK"
        else "DORK"
      in
      Eq("fooBORKDORK", "foobarbaz" |. Js.String.unsafeReplaceBy0 ~regexp:[%re "/ba./g"] ~f:replace)
    );
    "unsafeReplaceBy1", (fun _ ->
      let replace = fun whole p1 offset s ->
        if whole = "bar" then "BORK"
        else "DORK"
      in
      Eq("fooBORKDORK", "foobarbaz" |. Js.String.unsafeReplaceBy1 ~regexp:[%re "/ba./g"] ~f:replace)
    );
    "unsafeReplaceBy2", (fun _ ->
      let replace = fun whole p1 p2 offset s ->
        if whole = "bar" then "BORK"
        else "DORK"
      in
      Eq("fooBORKDORK", "foobarbaz" |. Js.String.unsafeReplaceBy2 ~regexp:[%re "/ba./g"] ~f:replace)
    );
    "unsafeReplaceBy3", (fun _ ->
      let replace = fun whole p1 p2 p3 offset s ->
        if whole = "bar" then "BORK"
        else "DORK"
      in
      Eq("fooBORKDORK", "foobarbaz" |. Js.String.unsafeReplaceBy3 ~regexp:[%re "/ba./g"] ~f:replace)
    );

    "search", (fun _ ->
      Eq(3, "foobarbaz" |. Js.String.search ~regexp:[%re "/ba./g"])
    );

    "slice", (fun _ ->
      Eq("bar", "foobarbaz" |. Js.String.slice ~start:3 ~end_:6)
    );
    "sliceToEnd", (fun _ ->
      Eq("barbaz", "foobarbaz" |. Js.String.slice ~start:3)
    );

    "split", (fun _ ->
      Eq([| "foo"; "bar"; "baz" |], "foo bar baz" |. Js.String.split ~sep:" ")
    );
    "splitAtMost", (fun _ ->
      Eq([| "foo"; "bar" |], "foo bar baz" |. Js.String.split ~sep:" " ~limit:2)
    );
    "splitByRe", (fun _ ->
      Eq(
        [| Some "a"; Some "#"; None; Some "b"; Some "#"; Some ":"; Some "c" |],
        "a#b#:c" |. Js.String.splitByRe ~regexp:[%re "/(#)(:)?/"])
    );
    "splitByReAtMost", (fun _ ->
      Eq(
        [| Some "a"; Some "#"; None |],
        "a#b#:c" |. Js.String.splitByRe ~regexp:[%re "/(#)(:)?/"] ~limit:3)
    );

    (* es2015 *)
    "startsWith", (fun _ ->
      Eq(true, "foobarbaz" |. Js.String.startsWith ~prefix:"foo")
    );
    "startsWithFrom", (fun _ ->
      Eq(false, "foobarbaz" |. Js.String.startsWith ~prefix:"foo" ~start:1)
    );

    "substr", (fun _ ->
      Eq("barbaz", "foobarbaz" |. Js.String.substr ~start:3) [@ocaml.warning "-3"]
    );
    "substrAtMost", (fun _ ->
      Eq("bar", "foobarbaz" |. Js.String.substr ~start:3 ~len:3) [@ocaml.warning "-3"]
    );

    "substring", (fun _ ->
      Eq("bar", "foobarbaz" |. Js.String.substring ~start:3 ~end_:6)
    );
    "substringToEnd", (fun _ ->
      Eq("barbaz", "foobarbaz" |. Js.String.substring ~start:3)
    );

    "toLowerCase", (fun _ ->
      Eq("bork", "BORK" |. Js.String.toLowerCase)
    );
    "toLocaleLowerCase", (fun _ ->
      Eq("bork", "BORK" |. Js.String.toLocaleLowerCase)
    );
    "toUpperCase", (fun _ ->
      Eq("FUBAR", "fubar" |. Js.String.toUpperCase)
    );
    "toLocaleUpperCase", (fun _ ->
      Eq("FUBAR", "fubar" |. Js.String.toLocaleUpperCase)
    );

    "trim", (fun _ ->
      Eq("foo", "  foo  " |. Js.String.trim)
    );

    (* es2015 *)
    "anchor", (fun _ ->
      Eq("<a name=\"bar\">foo</a>", "foo" |. Js.String.anchor ~name:"bar") [@ocaml.warning "-3"]
    );
    "link", (fun _ ->
      Eq("<a href=\"https://reason.ml\">foo</a>", "foo" |. Js.String.link ~href:"https://reason.ml") [@ocaml.warning "-3"]
    );
    __LOC__ , (fun _ -> Ok (Js.String.includes "ab" ~search:"a"))
]
;; Mt.from_pair_suites __MODULE__ suites
