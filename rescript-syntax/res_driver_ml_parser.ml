module OcamlParser = Parser
module IO = Res_io

let setup ~filename =
  if String.length filename > 0 then (
    Location.input_name := filename;
    IO.readFile ~filename |> Lexing.from_string
  ) else
    Lexing.from_channel stdin

let extractOcamlConcreteSyntax filename =
  let lexbuf = if String.length filename > 0 then
    IO.readFile ~filename |> Lexing.from_string
  else
    Lexing.from_channel stdin
  in
  let stringLocs = ref [] in
  let commentData = ref [] in
  let rec next (prevTokEndPos : Lexing.position) () =
    let token = Lexer.token_with_comments lexbuf in
    match token with
    | OcamlParser.COMMENT (txt, loc) ->
      let comment = Res_comment.fromOcamlComment
        ~loc
        ~prevTokEndPos
        ~txt
      in
      commentData := comment::(!commentData);
      next loc.Location.loc_end ()
    | OcamlParser.STRING (_txt, _loc, None) ->
      let open Location in
      let loc = {
        loc_start = lexbuf.lex_start_p;
        loc_end = lexbuf.Lexing.lex_curr_p;
        loc_ghost = false;
      } in
      let len = loc.loc_end.pos_cnum - loc.loc_start.pos_cnum in
      let txt = Bytes.to_string (
        (Bytes.sub [@doesNotRaise]) lexbuf.Lexing.lex_buffer loc.loc_start.pos_cnum len
      ) in
      stringLocs := (txt, loc)::(!stringLocs);
      next lexbuf.Lexing.lex_curr_p ()
    | OcamlParser.EOF -> ()
    | _ -> next lexbuf.Lexing.lex_curr_p ()
  in
  next lexbuf.Lexing.lex_start_p ();
  (List.rev !stringLocs, List.rev !commentData)

open Import

let parsingEngine = {
  Res_driver.parseImplementation = begin fun ~forPrinter:_ ~filename ->
    let lexbuf = setup ~filename in
    let (stringData, comments) = extractOcamlConcreteSyntax !Location.input_name in
    let structure =
      Parse.implementation lexbuf
      |> From_current.copy_structure
      |> Res_ast_conversion.replaceStringLiteralStructure stringData
      |> Res_ast_conversion.structure
      |> To_current.copy_structure
    in {
      filename = !Location.input_name;
      source = Bytes.to_string lexbuf.lex_buffer;
      parsetree = structure;
      diagnostics = ();
      invalid = false;
      comments = comments;
    }
  end;
  parseInterface = begin fun  ~forPrinter:_ ~filename ->
    let lexbuf = setup ~filename in
    let (stringData, comments) = extractOcamlConcreteSyntax !Location.input_name in
    let signature =
      Parse.interface lexbuf
      |> From_current.copy_signature
      |> Res_ast_conversion.replaceStringLiteralSignature stringData
      |> Res_ast_conversion.signature
      |> To_current.copy_signature
    in {
      filename = !Location.input_name;
      source = Bytes.to_string lexbuf.lex_buffer;
      parsetree = signature;
      diagnostics = ();
      invalid = false;
      comments = comments;
    }
  end;
  stringOfDiagnostics = begin fun ~source:_ ~filename:_ _diagnostics -> () end;
}

let printEngine = Res_driver.{
  printImplementation = begin fun ~width:_ ~filename:_ ~comments:_ structure ->
    let structure = Ppxlib.Selected_ast.Of_ocaml.copy_structure structure in
    Pprintast.structure Format.std_formatter structure
  end;
  printInterface = begin fun ~width:_ ~filename:_ ~comments:_ signature ->
    let signature = Ppxlib.Selected_ast.Of_ocaml.copy_signature signature   in
    Pprintast.signature Format.std_formatter signature
  end;
}
