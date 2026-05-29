(** The CTypeError module contains the declaration and utility function wich can be usefull to manage the CTypeError exception *)

(** [CTypeError] is an exception raised when a type error occour during compilation*)
exception TypeError of string

(** Type containing the error status, it contains the error message, the file name and the line number *)
type t

(** [empty_error_status ()] returns a t type that contains program file, error message set to "" and line number set to -1 *)
val empty_error_status : unit -> t


(** [set_error_status line_number program_file error_message] returns a t type with the data passed *)
val set_error_status : int -> string -> string -> t

(** [set_line_number line_number error_status] given [line_number] and [error_status] returns [error_status] with line number set to [line_number]*)
val set_line_number : int -> t -> t

(** [set_program_file program_file error_status] given [program_file] and [error_status] returns [error_status] with line number set to [program_file]*)
val set_program_file : string -> t -> t

(** [set_error_message error_message error_status] given [error_message] and [error_status] returns [error_status] with line number set to [error_message]*)
val set_error_message : string -> t -> t

(** [set_line_number error_status] given [error_status] returns the [line_number]*)
val get_line_number : t -> int

(** [set_program_file error_status] given [error_status] returns the [program_file]*)
val get_program_file : t -> string

(** [set_error_message error_status] given [error_status] returns the [error_message]*)
val get_error_message : t -> string


(** [raise_ctype_error error_status] raise CTypeError with a message based on the [error_status]*)
val raise_ctype_error : t -> 'a
