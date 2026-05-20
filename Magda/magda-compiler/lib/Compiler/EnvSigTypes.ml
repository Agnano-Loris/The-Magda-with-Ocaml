open Program_tree.Ast

type environment = {
	decls: global_declaration list; 
	calculated_types: CType.t OrderedGlobalDeclaration.DeclarationMap.t
}
and method_environment =  {
    environment: environment;
    current_mixin: mixin_decl
}
and instr_environment = {
    method_environment: method_environment;
    vars: variable_decl list;
    params: parameter_decl list;
    current_method: method_declaration;
    current_inimodule: ini_module_decl
}
and inimodule_environment = {
	environment: environment;
	module_number: int
}

module type ENV = sig
	type t = environment
	val empty : t
	val new_environment : ?calculated_types:int OrderedGlobalDeclaration.DeclarationMap.t -> global_declaration list -> t
	val get_mixin_exn : string -> t -> global_declaration
	val get_declaration_exn : string -> t -> global_declaration
end

module type METHOD_ENV = sig
	module E : ENV
	type t = method_environment
    val empty : t
	val new_method_environment : E.t -> mixin_decl -> t
    val new_method_environment_2 : global_declaration list -> mixin_decl -> t
	val get_type_element : string -> t -> TypeElement.t
	val get_declaration_exn : string -> t -> global_declaration

    (* FROM ENV *)
    val get_mixin_exn : string -> t -> global_declaration
end

module type INSTR_ENV = sig 
    type t = instr_environment
    val new_instr_environment : global_declaration list -> mixin_decl -> variable_decl -> parameter_decl -> ?current_method_or_inimodule: (method_declaration, ini_module_decl) Either.t -> t
    val find_param_or_variable_type : string -> t -> CType.t
    val get_variable_offset : string -> t -> int
    val get_parameter_offset : string -> t -> int
    val expand_variables_in_native : string -> t -> string

    (* FROM M_ENV *)
    val get_type_element : string -> t -> TypeElement.t
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