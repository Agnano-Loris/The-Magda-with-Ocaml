type t
(** 
    Method context type, represents the context of a given method.
	The context is composed by the types of all the parameters, variables of the method 
	and lastly its return type (set [None] by default).
	
    The type t is not mutable, uses {! Utils.MagdaType.t} to store all the types
    and {! MethodContext.t} for the context of its methods.
*)

val empty : unit -> t
(** [empty] returns an empty mixin_context.*)

val add_method : string -> MethodContext.t -> t -> t
(** [add_method name context mixin_context] returns a new [mixin_context], 
    with the [name] and the [context] of the method added to the [mixin_context]. *)

val get_inimodule_name : string list -> t -> string option
(** [get_inimodule_name params mixin_context] given the [mixin_context] returns the name of the inimodule associated with the [params] list*)

val add_inimodule : string list -> MethodContext.t -> t -> (t, string) result
(** [add_inimodule params method_context mixin_context] given the [params] and [method_context] of the inimodule, 
    if successfull it returns [Ok new_mixin_context] where [new_mixin_context] is [mixin_context] with the inimodule added.
    If there are any duplicate params either in the [params] list or in the other inimodules of the mixin,
    then [add_inimodule] returns [Error param] where [param] is the first duplicated param in the [params] list
*)

val contains_method : string -> t -> bool 
(** [contains_method method_name mixin_context] checks if there is a [method_name] method in the [mixin_context]*)

val contains_field : string -> t -> bool
(** [contains_field field_name mixin_context] checks if [mixin_context] contains the [field_name] field*)

val empty_main_program_params : t -> bool
(** [empty_main_program_params mixin_context] checks if there is a "mainProgram" method with no params in the [mixin_context]*)

val add_field : string -> Utils.MagdaType.t -> t -> t
(** [add_field field_name field_type mixin_context] returns a new [mixin_context] 
    with a field of name [field_name] and type [field_type] added. *)

val add_linked_mixin : string -> t -> t
(** [add_linked_mixin name mixin_context] returns a new [mixin_context] 
    with a linked_mixin of name [name] added. *)

val get_field_type : string -> t -> Utils.MagdaType.t option
(** [get_field_type field_name mixin_context] returns [Some type] where [type] is the type of [field_name] 
    if a field named [field_name] is found in the [mixin_context], otherwise returns [None] *)

val get_method_return_type : string -> t -> Utils.MagdaType.t option
(** [get_method_return_type method_name mixin_context] returns [Some type] where [type] is the type returned by [method_name]
    if a method named [field_name] is found in the [mixin_context], otherwise returns [None] *)

val get_method_var_type : string -> string -> t -> Utils.MagdaType.t option
(** [get_method_var_type var_name method_name mixin_context] returns [Some type]
    where [type] is the type of a variable/parameter named [var_name] in [method_name],
    assuming that [mixin_context] contains [method_name] and the method [method_name] contains [var_name], otherwise returns [None] *)

val to_string : t -> string
(** [to_string mixin_context] returns a string wich contains the information of all the information in the [mixin_context] *)