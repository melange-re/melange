

(*let buffer_intervals (intervals : (int * int) list) buf ic oc =
  intervals
  |> List.iter
    (fun (start, stop) -> 
       let len = stop - start in 
       if len <> 0 then 
         begin
           seek_in ic start ; 
           Buffer.add_channel buf ic len ; 
           Buffer.output_buffer oc buf ; 
           Buffer.clear buf;
         end
    )*)


let preprocess fn oc = 
  let ic = open_in_bin fn in 
  let lexbuf = Lexing.from_channel ic in 
  let buf = Buffer.create 4096 in 
  Location.init lexbuf fn;
  Lexer.init ();
  lexbuf
  |> Rescript_cpp.filter_directive_from_lexbuf  ~token_with_comments:Lexer.token_with_comments
  (* Get a list of segments
     TODO: output line directive
  *)
  |> List.iter
    (fun (start, stop) ->       
       let len = stop - start in 
       if len <> 0 then 
         begin
           seek_in ic start ; 
           Buffer.add_channel buf ic len ; 
           Buffer.output_buffer oc buf ; 
           Buffer.clear buf;
         end
    );
  close_in ic 


let () = 
  preprocess Sys.argv.(1) stdout
