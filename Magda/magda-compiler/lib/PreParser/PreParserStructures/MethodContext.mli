type t
(** Method context type, represents the context of a given method.
    The context is composed by the types of all the parameters, variables, 
    and lastly the return type ([None] by default).
    The type t is not mutable

    t uses [Utils.MagdaType.t] to store all the types
*)

val empty : unit -> t
(** [empty] gives the empty context of a method.
    @return an empty method_context.
*)

val add_variable : string -> Utils.MagdaType.t -> t -> t
(** [add_variable variable_name variable_type method_context] given [variable_name] and [variable_type], [add_variable] adds them to the [method_context].

    @param variable_name the name of the variable to add
    @param variable_type the type of the variable to add
    @param method_context the method context in which the function will add the variable
    @return a new method context with the added variable
*)


val add_param : string -> Utils.MagdaType.t -> t -> t
(** [add_param param_name param_type method_context] given [param_name] and [param_type], [add_param] adds them to the [method_context].

    @param param_name the name of the parameter to add
    @param param_type the type of the parameter to add
    @param method_context the method context in which the function will add the parameter
    @return a new method context with the added parameter
*)

val get_return_type : t -> Utils.MagdaType.t option
(** [get_return_type method_context] returns the return type of the method.

    @param method_context the method context of the method
    @return the return type of the method as a [Some MagdaType], if the return has not been set then returns [None]
*)

val set_return_type : Utils.MagdaType.t option -> t -> t
(** [set_return_type return_type method_context] set the [return_type] of the in the [method_context].

    @param return_type set the return type of the method
    @param method_context the method context of the method
    @return a new method context with the new return_type
*)

val get_variable_type : string -> t -> Utils.MagdaType.t option
(** [get_variable_type name method_context] get the type of the [name] variable, if there isn't a variable with that name,
    returns the type of the parameter, if there is one with that name.
    
    @param name name of the variable/parameter to search    
    @param method_context the method context of the method 
    @returns the type of the variable as [Some Utils.MagdaType.t], if it doesn't find it returns the type of the parameter, otherwise returns [None]
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