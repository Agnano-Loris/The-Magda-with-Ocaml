type t

val create : unit -> t

val add_variable : t -> string -> string -> unit

val add_param : t -> string -> string -> unit

val get_return_type : t -> string option

val set_res_type : t -> string option -> unit

val get_variable_type : t -> string -> string option

val no_params : t -> bool

val to_string : t -> string