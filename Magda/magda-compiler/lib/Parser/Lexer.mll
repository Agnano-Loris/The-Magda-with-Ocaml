(*** Lexer for the Magda language ***)
{
    open Parser
    open Utils.Errors
    (*** Buffer for strings and native instructions ***)
    let token_buffer = Buffer.create 64

    let lex_error_at start lexbuf msg =
        magda_raise_at (start, Lexing.lexeme_end_p lexbuf) LexPhase msg

    let lex_error lexbuf msg =
        lex_error_at (Lexing.lexeme_start_p lexbuf) lexbuf msg
}



(*** Token definitions ***)

rule token = parse
    (*** Skip whitespace ***)
    | [' ' '\t' '\r']+ { token lexbuf }
    | '\n' { Lexing.new_line lexbuf; token lexbuf }

    (*** Comments ***)
    | "//" { single_line_comment lexbuf }
    | "/*" { multi_line_comment (Lexing.lexeme_start_p lexbuf) 1 lexbuf }

    (*** Keywords ***)
    | "include" { INCLUDE }
    | "let" { LET }
    | "null" { NULL }
    | "true" { TRUE }
    | "false" { FALSE }
    | "super" { SUPER }
    | "void" { VOID }
    | "this" { THIS }
    | "begin" { BEGIN }
    | "end" { END }
    | "new" { NEW }
    | "abstract" { ABSTRACT }
    | "override" { OVERRIDE }
    | "required" { REQUIRED }
    | "optional" { OPTIONAL }
    | "initializes" { INITIALIZES }
    | "if" { IF }
    | "else" { ELSE }
    | "while" { WHILE }
    | "mixin" { MIXIN }
    | "of" { OF }
    | "where" { WHERE }
    | "return" { RETURN }

    (*** Operators and punctuation ***)
    | "==" { EQEQ }
    | "<=" { LTE }
    | ">=" { GTE }
    | "!=" { NEQ }
    | "=" { EQUALS }
    | "<" { LT }
    | ">" { GT }
    | "+" { PLUS }
    | "-" { MINUS }
    | "*" { TIMES }
    | "/" { DIVIDE }

    | "(" { LPAREN }
    | ")" { RPAREN }
    | "[" { LBRACKET }
    | "]" { RBRACKET }
    | ";" { SEMICOLON }
    | "," { COMMA }
    | "." { DOT }
    | ":=" { ASSIGN }
    | ":" { COLON }

    (*** Identifiers ***)

    (*  This token is used for native instructions.
        It also uses the global buffer initialized
        in the beginning of the program *)
    | '%' 
        {  
            Buffer.clear token_buffer;
            native_instruction (Lexing.lexeme_start_p lexbuf) lexbuf
        }

    |  ['a' - 'z' 'A' - 'Z' '_'] (['a' - 'z' 'A' - 'Z' '0' - '9' '_'])* as id { ID id }

    (* The '"' token is used for string literals. Unlike java
       we dont need to escape characters.
       It also uses the global buffer initialized
       in the beginning of the program *)
    | '"'
        {
            Buffer.clear token_buffer;
            string_literal (Lexing.lexeme_start_p lexbuf) lexbuf
        }
    | "0x" ['0' - '9' 'a' - 'f' 'A' - 'F']+ as byte {
            match int_of_string_opt byte with
            | Some n when n >= 0 && n <= 0x7F -> BYTE_LITERAL byte
            | _ -> lex_error lexbuf ("Byte literal out of range (max 0x7F): " ^ byte)
        }
    | ['0' - '9']+ '.' ['0' - '9']+ as nfloat {   
        let f = float_of_string nfloat in
        if Float.is_finite (Int32.float_of_bits (Int32.bits_of_float f))
        then FLOAT_LITERAL f
        else lex_error lexbuf ("Float literal out of range: " ^ nfloat) }
    | ['0' - '9']+ as nint {
            match int_of_string_opt nint with
            | Some n when n <= Int32.to_int Int32.max_int -> INTEGER_LITERAL n
            | _ -> lex_error lexbuf ("Integer literal out of range (max 2147483647): " ^ nint)
        }

    (*** End of file ***)    
    | eof { EOF }
    
    (*** Catch-all for unrecognized characters ***)
    | _ as unk_ch { lex_error lexbuf (Printf.sprintf "Unrecognized character %C" unk_ch)  }


and single_line_comment = parse
    | '\n' { Lexing.new_line lexbuf; token lexbuf }
    | '\r' { token lexbuf }
    | eof { EOF }
    | _ { single_line_comment lexbuf }

and multi_line_comment start depth = parse
    | "/*" { multi_line_comment start (depth + 1) lexbuf }
    | "*/" { if depth = 1 then token lexbuf 
            else multi_line_comment start (depth - 1) lexbuf }
    | eof { lex_error_at start lexbuf "Unterminated multi-line comment" }
    | '\n' { Lexing.new_line lexbuf; multi_line_comment start depth lexbuf }
    | _ { multi_line_comment start depth lexbuf }

and native_instruction start = parse
    | "\\%" { Buffer.add_char token_buffer '%'; native_instruction start lexbuf }
    | '%' { NATIVEINSTRUCTION (Buffer.contents token_buffer) }
    | eof {lex_error_at start lexbuf "Unterminated native instruction: expected '%'" }
    | '\n' as c { Lexing.new_line lexbuf; Buffer.add_char token_buffer c; native_instruction start lexbuf }
    | _ as c { Buffer.add_char token_buffer c; native_instruction start lexbuf }


and string_literal start = parse

    (*  All characters except '"', '\\', '\n', and '\r'. These cases will be used in the second guard
        as escape characters *)
    | [^ '"' '\\' '\n' '\r' ] as ch { Buffer.add_char token_buffer ch; string_literal start lexbuf }

    (*  Escape characters *)
    | '\\' (['n' 't' 'b' 'r' 'f' '\\' '\'' '"'] as escape_ch)
        {
        let escaped_char = match escape_ch with
            | 'n'  -> '\n'
            | 't'  -> '\t'
            | 'b'  -> '\b'
            | 'r'  -> '\r'
            | 'f'  -> '\012'
            | '\\' -> '\\'
            | '\'' -> '\''
            | '"'  -> '"'
            | _    -> escape_ch
        in
        Buffer.add_char token_buffer escaped_char;
        string_literal start lexbuf
        }

    (* Octals *)
    | '\\' ((['0' - '3'] ['0' - '7'] ['0' - '7'] (* Three octal digits. First digit must be 0-3.*)
            | ['0' - '7'] ['0' - '7'] (* Two octal digits *)
            | ['0' - '7']) (* Single octal digit *)
            as oct)
            {
                let octal_value = int_of_string ("0o" ^ oct) in
                Buffer.add_char token_buffer (Char.chr octal_value);
                string_literal start lexbuf
            }
    | '\\' { lex_error lexbuf "Invalid escape sequence in string literal" }

    (* End of string literal *)
    | '"' { STRING_LITERAL (Buffer.contents token_buffer) }

    (*** Errors ***)

    (* Not ending string literals with '"' *)
    | eof { lex_error_at start lexbuf "Unterminated string literal: end of file" }

    (*  Not ending string literals with '"' and using newline or carriage return instead *)
    | ['\n' '\r'] { lex_error_at start lexbuf "Unterminated string literal: end of line" }