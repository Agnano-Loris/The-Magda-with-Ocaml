type t
(** 
    Program context type, represents the context of the program.
	The context is composed of the context of all its mixins.
	
    The type t is not mutable, and uses {! MixinContext.t} for the context of its mixins.
*)

val empty : unit -> t
(** [empty] returns an empty program_context.*)

val add_mixin : string -> MixinContext.t -> t -> t
(** [add_mixin name context program_context] given the [name] and the [program_context] 
    returns a new [program_context] with the with the mixin added.
*)

val contains_mixin : string -> t -> bool
(** [contains_mixin mixin_name program_context] returns [true] if [program_context] contains a mixin 
    with the name [mixin_name].
*)

val check_for_cycles : t -> bool
(** [check_for_cycles program_context] for every mixin contained in the mixin_context
    returns [true] if any of them has a cycle in its linked_mixins.
    
    For example: 
        mixin A of B, C
        mixin B of A
        mixin C
        Returns true because A -> B -> A ecc.
*)

val contains_unambiguous_field : string -> string -> t -> Utils.StringSet.t
(** [contains_unambiguous_field field_name mixin_name program_context] 
    checks if [field_name] is an unambiguous field in the mixin [mixin_name]
    
    returns a {! Utils.StringSet} with the mixins where [field_name] is contained
    the mixins considered are the linked_mixins of [mixin_name].

    If the {! Utils.StringSet} is empty, that means either that the [mixin_name] does not exist
    or that [field_name] is not part of mixin_name.
    
    If {! Utils.StringSet} contains one mixin, the field is unambiguous.
    If {! Utils.StringSet} contains more than one mixin, the field is ambiguous.

    This method assumes that there are no cycles in the mixins, use [check_for_cycles] to verify
*)

val contains_unambiguous_method : string -> string -> t -> Utils.StringSet.t
(** [contains_unambiguous_method method_name mixin_name program_context]
    same as [contains_unambiguous_field] but with a method [method_name] instead of a field [field_name].

    This method assumes that there are no cycles in the mixins, use [check_for_cycles] to verify
*)

val contains_method : string -> string -> t -> bool
(** [contains_method method_name mixin_name program_context] 
    returns [true] if [method_name] is contained in [mixin_name]
    
    This method assumes that [mixin_context] is contained in [program_context]
*)

val empty_main_program_params : t -> bool
(** [empty_main_program_params program_context]
    if [program_context] contains a "MainClass" mixin
    returns {! MixinContext.empty_main_program_params}
    otherwise returns [false].
*)

val get_inimodule_name : string list -> string -> t -> string option
(** [get_inimodule_name params mixin_name program_context]
    if found returns [Some inimodule_name] where [inimodule_name] is the name of the inimodule
    with the params list [params] contained in [mixin_name].

    returns [None] if the inimodule was not found or the mixin_name is not present in [program_context]
*)

val get_field_type : string -> string -> t -> Utils.MagdaType.t option
(** [get_field_type field_name mixin_name program_context]
    returns [Some field_type] if a [field_name] was found in [mixin_name] 
    and [program_context] contains [mixin_name].

    returns [None] if the field_name was not found or the mixin_name is not present in [program_context]
*)

val get_method_return_type : string -> string -> t -> Utils.MagdaType.t option
(** [get_method_return_type method_name mixin_name program_context]
    returns [Some return_type] if [return_type] was setted in [method_name],
    assuming [method_name] is contained in [mixin_name] and [mixin_name] contained in [program_context]

    Otherwise returns [None].
*)

val get_method_variable_type : string -> string -> string -> t -> Utils.MagdaType.t option
(** [get_method_variable_type var_name method_name mixin_name program_context]
    given [var_name], [method_name] and [mixin_name] uses {! MixinContext.get_method_var_type} to get the type.    
    If found returns [Some var_type], otherwise returns [None].
*)

val add_all : t -> t -> t
(** [add_all program_context context_to_add]
    Adds all the mixin contexts contained in [context_to_add] to [program_context].
    On mixins with the same name it preserves the mixin contained in [program_context].
*)

val to_string : t -> string
(** [to_string program_context] returns a string wich contains all the information in the [program_context] *)

