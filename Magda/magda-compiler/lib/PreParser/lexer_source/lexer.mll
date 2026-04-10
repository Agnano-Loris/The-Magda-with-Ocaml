(*** Lexer for the Magda language ***)

(*** Buffer for native instructions ***)
let native_buffer = Buffer.create 64


(*** Token definitions ***)

rule token = parse
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
    | "abstact" { ABSTRACT }
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
    (*  This token is used for native instructions.
        It also uses the global buffer initialized
        in the beginning of the program *)
    | '%' 
        {  
            Buffer.clear native_buffer;
            native_instruction lexbuf
        }

    |  ["a" - "z" "A" - "Z" "_"] (["a" - "z" "A" - "Z" "0" - "9" "_"])* as id { ID id }

    (* The '"' token is used for string literals. Unlike java
       we dont need to escape characters.
       It also uses the global buffer initialized
       in the beginning of the program *)
    | '"'
        {
            Buffer.clear native_buffer;
            string_literal lexbuf
        }
    | "0x" ['0' - '9' 'a' - 'f' 'A' - 'F']+ as byte { BYTE_LITERAL byte }
    | ['0' - '9']+ as integer { INTEGER_LITERAL integer }
    | ['0 - '9']+ '.' ['0' - '9']* as float { FLOAT_LITERAL float }
    




and native_instruction = parse
    | "\\%" { Buffer.add_char native_buffer '%'; native_instruction lexbuf }
    | '%' { NATIVEINSTRUCTION (Buffer.contents native_buffer) }
    | eof { failwith "Error: Expected '%' as native instruction terminator" }
    | _ as c { Buffer.add_char native_buffer c; native_instruction lexbuf }

and string_literal = parse
(* TO do *)