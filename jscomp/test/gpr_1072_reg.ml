  type t


  external make :
    ?localeMatcher:
      ([`lookup | `best_fit [@mel.as "best fit"]] [@mel.string]) ->

    ?timeZone:string ->
    ?hour12:bool ->
    ?formatMatcher:
      ([`basic | `best_fit [@mel.as "best fit"]] [@mel.string]) ->

    ?weekday:([`narrow | `short | `long] ) ->
    ?era:([`narrow | `short | `long] ) ->
    ?year:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?month:
      ([`narrow |
        `short |
        `long |
        `numeric |
        `two_digit [@mel.as "2-digit"]] [@mel.string]) ->

    ?day:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?hour:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?minute:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?second:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?timeZoneName:([`short | `long] ) ->
    unit ->
    t =
    "" [@@mel.obj]


let v1 =
    make
    ~localeMatcher:`best_fit
    ~formatMatcher:`basic
    ~day:`two_digit
    ~timeZoneName:`short
    ()





(** In the future we might allow below cases , issues are [`num] maybe escaped
    we need prevent its escaping

  external make2 :
    ?localeMatcher:
      ([`lookup | `best_fit [@mel.as "best fit"]] [@mel.string]) ->

    ?timeZone:string ->
    ?hour12:bool ->
    ?formatMatcher:
      ([`basic | `best_fit [@mel.as "best fit"]] [@mel.string]) ->

    ?weekday:([`narrow | `short | `long] [@mel.string]) ->
    ?era:([`narrow | `short | `long] [@mel.string]) ->
    ?year:([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) ->
    ?month:
      ([`narrow |
        `short |
        `long |
        `numeric |
        `two_digit [@mel.as "2-digit"]] [@mel.string]) ->

    ?day:(([`numeric | `two_digit [@mel.as "2-digit"]] [@mel.string]) as 'num) ->
    ?hour:('num) ->
    ?minute:('num) ->
    ?second:('num) ->
    ?timeZoneName:([`short | `long] [@mel.string]) ->
    unit ->
    t =
    "" [@@mel.obj]


let v2 =
     make2
    ~localeMatcher:`best_fit
    ~formatMatcher:`basic
    ~day:`two_digit
    ~timeZoneName:`short
    ~hour:`two_digit
    ()
*)
