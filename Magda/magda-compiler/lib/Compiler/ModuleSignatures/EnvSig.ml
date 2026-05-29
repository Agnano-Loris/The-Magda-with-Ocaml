open Program_tree.Ast
open Types.EnvTypes

module type ENV = sig
	type t = environment
	val empty : t
	val new_environment : ?calculated_types:Types.TypeElements.t OrderedGlobalDeclaration.DeclarationMap.t -> global_declaration list -> t
	val get_mixin_exn : string -> t -> global_declaration
	val get_declaration_exn : string -> t -> global_declaration
end

module type METHOD_ENV = sig
	module Environment : ENV
	type t = method_environment
  val empty : t
	val new_method_environment : Environment.t -> mixin_decl -> t
  val new_method_environment_2 : global_declaration list -> mixin_decl -> t
	val get_type_element_exn : string -> t -> Types.TypeElement.t
	val get_declaration_exn : string -> t -> global_declaration

  (* FROM ENV *)
  val get_mixin_exn : string -> t -> global_declaration
end

module type INSTR_ENV = sig 
    type t = instr_environment
    val new_instr_environment : global_declaration list -> mixin_decl -> variable_decl -> parameter_decl -> ?current_method_or_inimodule: (method_declaration, ini_module_decl) Either.t -> t
    val find_param_or_variable_type : string -> t -> Types.TypeElements.t
    val get_variable_offset : string -> t -> int
    val get_parameter_offset : string -> t -> int
    val expand_variables_in_native : string -> t -> string

    (* FROM M_ENV *)
  val get_type_element : string -> t -> Types.TypeElement.t
	val get_declaration_exn : string -> t -> global_declaration
  val get_mixin_exn : string -> t -> global_declaration
end

module type INIMODULE_ENV = sig
    type t = inimodule_environment
    val new_inimodule_environment : global_declaration list -> mixin_decl -> int

    (* FROM ENV *)
    val get_mixin_exn : string -> t -> global_declaration
	val get_declaration_exn : string -> t -> global_declaration
end