type t
(** Method context type, represents the context of a given method.
    The context is composed by the types of all the parameters, variables, 
    and lastly the return type ([None] by default).
    The type t is mutable
*)

val create : unit -> t
(** [create] initialize the context of a method.
    @return the method_context initialized.
*)

val add_variable : t -> string -> string -> unit
(** [add_variable method_context variable_name variable_type] given [variable_name] and [variable_type], [add_variable] adds them to the [method_context].

    @param method_context the method context in which the function adds the variable
    @param variable_name the name of the variable to add
    @param variable_type the type of the variable to add
*)


val add_param : t -> string -> string -> unit
(** [add_param method_context param_name param_type] given [param_name] and [param_type], [add_param] adds them to the [method_context].

    @param method_context the method context in which the function adds the param
    @param param_name the name of the param to add
    @param param_type the type of the param to add
*)

val get_return_type : t -> string option
(** [get_return_type method_context] returns the return type of the method.

    @param method_context the method context of the method
    @return the return type of the method as a [Some string], if the return is not set then returns [None]
*)

val set_return_type : t -> string -> unit
(** [set_return_type method_context return_type] set the [return_type] of the in the [method_context].

    @param method_context the method context of the method
    @param return_type set the return type of the method
*)

val get_variable_type : t -> string -> string option
(** [get_variable_type method_context name] get the type of the [name] variable, if there isn't a variable with that name,
    returns the type of the parameter, if there is one with that name.
    
    @param method_context the method context of the method 
    @param name name of the variable/parameter to search
    @returns the type of the variable as [Some string], if it doesn't find it returns the type of the parameter, otherwise returns [None]
*)

val no_params : t -> bool
(** [no_params method_context] checks if there are parameters in the [method_context]
    
    @param method_context the method context of the method 
    @returns [true] if the [method_context] contains at least one parameter, otherwise returns [false]
*)

val to_string : t -> string
(** [to_string method_context] returns a string wich contains the information of all variables and parameters in the [method_context] 
    
    @param method_context the method context of the method 
    @returns a string wich contains the information of all variables and parameters in the [method_context] 
*)