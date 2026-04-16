type t
(** Method context type, represents the context of a given method.
	The context is composed by the types of all the parameters, variables of the method 
	and lastly its return type (set [None] by default).
	
    The type t is not mutable and uses {! Utils.MagdaType.t} to store all the types
*)

val empty : unit -> t
(** [empty] returns an empty method_context. *)

val add_variable : string -> Utils.MagdaType.t -> t -> t
(** [add_variable variable_name variable_type method_context] given [variable_name] and [variable_type], returns a new method_context with a [add_variable] them to the [method_context] *)


val add_param : string -> Utils.MagdaType.t -> t -> t
(** [add_param param_name param_type method_context] given [param_name] and [param_type], [add_param] adds them to the [method_context],
    then returns the new method_context. *)

val get_return_type : t -> Utils.MagdaType.t option
(** [get_return_type method_context] returns the return type of [method_context]. *)

val set_return_type : Utils.MagdaType.t option -> t -> t
(** [set_return_type return_type method_context] set the [return_type] in the in the [method_context] provided,
    then returns the new method_context. *)

val get_variable_type : string -> t -> Utils.MagdaType.t option
(** [get_variable_type name method_context] get the type of the [name] variable, if there isn't a variable with that name,
    searches in the parameter list instead. *)

val no_params : t -> bool
(** [no_params method_context] returns [true] if there are no parameters in the [method_context], otherwise [false] *)

val to_string : t -> string
(** [to_string method_context] returns a string wich contains the information of all variables and parameters in the [method_context] *)