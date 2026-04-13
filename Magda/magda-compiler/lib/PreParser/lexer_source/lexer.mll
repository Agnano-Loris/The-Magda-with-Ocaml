(*** Lexer for the Magda language ***)

(*** Buffer for strings and native instructions ***)
let token_buffer = Buffer.create 64


(*** Token definitions ***)

rule token = parse
    (*** Skip whitespace ***)
    | [' ' '\n' '\t' '\r']+ { token lexbuf }

    (*** Comments ***)
    | "//" { single_line_comment lexbuf }
    | "/*" { multi_line_comment 1 lexbuf }

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
    | "&&" { AND }
    | "||" { OR }
    | "=" { EQUALS }
    | "<" { LT }
    | ">" { GT }
    | "!" { NOT }
    | "+" { PLUS }
    | "-" { MINUS }
    | "*" { TIMES }
    | "/" { DIVIDE }

    | "(" { LPAREN }
    | ")" { RPAREN }
    | "{" { LBRACE }
    | "}" { RBRACE }
    | "[" { LBRACKET }
    | "]" { RBRACKET }
    | ";" { SEMICOLON }
    | "," { COMMA }
    | "." { DOT }

    (*** Identifiers ***)

    (*  This token is used for native instructions.
        It also uses the global buffer initialized
        in the beginning of the program *)
    | '%' 
        {  
            Buffer.clear token_buffer;
            native_instruction lexbuf
        }

    |  ["a" - "z" "A" - "Z" "_"] (["a" - "z" "A" - "Z" "0" - "9" "_"])* as id { ID id }

    (* The '"' token is used for string literals. Unlike java
       we dont need to escape characters.
       It also uses the global buffer initialized
       in the beginning of the program *)
    | '"'
        {
            Buffer.clear token_buffer;
            string_literal lexbuf
        }
    | "0x" ['0' - '9' 'a' - 'f' 'A' - 'F']+ as byte { BYTE_LITERAL byte }
    | ['0' - '9']+ '.' ['0' - '9']* as float { FLOAT_LITERAL float }
    | ['0' - '9']+ as integer { INTEGER_LITERAL integer }

    (*** End of file ***)    
    | eof { EOF }
    
    (*** Catch-all for unrecognized characters ***)
    | _ as unk_ch { failwith "Error: Unrecognized character: " ^ String.make 1 unk_ch }


and single_line_comment = parse
    | '\n' { token lexbuf }
    | '\r' { token lexbuf }
    | eof { EOF }
    | _ { single_line_comment lexbuf }

and multi_line_comment depth = parse
    | "/*" { multi_line_comment (depth + 1) lexbuf }
    | "*/" { if depth = 1 then token lexbuf 
            else multi_line_comment (depth - 1) lexbuf }
    | eof { failwith "Error: Unterminated multi-line comment" }
    | _ { multi_line_comment depth lexbuf }

and native_instruction = parse
    | "\\%" { Buffer.add_char token_buffer '%'; native_instruction lexbuf }
    | '%' { NATIVEINSTRUCTION (Buffer.contents token_buffer) }
    | eof { failwith "Error: Expected '%' as native instruction terminator" }
    | _ as c { Buffer.add_char token_buffer c; native_instruction lexbuf }


and string_literal = parse

    (*  All characters except '"', '\\', '\n', and '\r'. These cases will be used in the second guard
        as escape characters *)
    | [^ '"' '\\' '\n' '\r' ] as ch { Buffer.add_char token_buffer ch; string_literal lexbuf }

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
        string_literal lexbuf
        }

    (* Octals *)
    | '\\' ((['0' - '3'] ['0' - '7'] ['0' - '7'] (* Three octal digits. First digit must be 0-3.*)
            | ['0' - '7'] ['0' - '7'] (* Two octal digits *)
            | ['0' - '7']) (* Single octal digit *)
            as oct)
            {
                let octal_value = int_of_string ("0o" ^ oct) in
                Buffer.add_char token_buffer (Char.chr octal_value);
                string_literal lexbuf
            }

    (* End of string literal *)
    | '"' { STRING_LITERAL (Buffer.contents token_buffer) }

    (*** Errors ***)

    (* Not ending string literals with '"' *)
    | eof { failwith "Error: Cannot end string literal with eof" }

    (*  Not ending string literals with '"' and using newline or carriage return instead *)
    | '\n' { failwith "Error: Cannot end string literal with newline" }
    | '\r' { failwith "Error: Cannot end string literal with carriage return" }