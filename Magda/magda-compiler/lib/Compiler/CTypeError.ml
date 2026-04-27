exception CTypeError of string

type t = {
    line_number : Int.t;
    program_file : String.t;
    error_message : String.t
}

let empty_error_status () = {
    line_number = -1;
    program_file = "";
    error_message = ""
}

let set_error_status line_number program_file error_message = {line_number;program_file;error_message}

let set_line_number line_number error_status = {error_status with line_number} 

let set_program_file program_file error_status = {error_status with program_file}

let set_error_message error_message error_status = {error_status with error_message}

let get_line_number error_status = error_status.line_number

let get_program_file error_status = error_status.program_file

let get_error_message error_status = error_status.error_message

let raise_ctype_error error_status = 
    let s = error_status.error_message ^ " at line:" ^ (string_of_int error_status.line_number) ^ " in file " ^ error_status.program_file in
    raise(CTypeError s)