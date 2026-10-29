let parse_file filename =
  let ic = try
     open_in filename 
  with Sys_error _ -> 
    Utils.Errors.magda_raise Utils.Errors.GenericPhase ("Cannot open file " ^ filename)
  in
  Fun.protect ~finally:(fun () -> close_in ic) (fun () ->
    let lexbuf = Lexing.from_channel ic in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
    try
      Parser.program Lexer.token lexbuf
    with Parser.Error ->
      let span = (Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf) in
      Utils.Errors.magda_raise_at span Utils.Errors.ParsePhase "Syntax error"
  )