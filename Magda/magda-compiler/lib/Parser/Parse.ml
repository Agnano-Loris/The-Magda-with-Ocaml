(**gestione errori? da vedere poi, gestione pos linea lex*)

let parse_file filename =
  let ic = open_in filename in
  Fun.protect ~finally:(fun () -> close_in ic) (fun () ->
    let lexbuf = Lexing.from_channel ic in
    Parser.program Lexer.token lexbuf
  )