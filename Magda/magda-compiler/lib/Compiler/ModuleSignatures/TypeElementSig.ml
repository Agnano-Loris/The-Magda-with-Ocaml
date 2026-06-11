open Program_tree.Ast
module type S = sig 
	module type MIXIN_EXPR_SIG = ExpressionsSig.MIXIN_EXPR with type t := mixin_expr
	type t = Types.TypeElement.t
	val of_global_decl_exn : global_declaration -> t
	val to_global_decl : t -> global_declaration
	val get_name : t -> string
	val get_caption : t -> string
	val get_applications : (module MIXIN_EXPR_SIG) -> Types.EnvTypes.method_environment -> t -> Types.TypeElements.poly_application_value list
	val print : (module MIXIN_EXPR_SIG) -> t -> unit
	val get_native_type : Types.EnvTypes.method_environment -> t -> Types.TypeElements.t
	val code_for_mixin : t -> string
	val gen_code_for_mixin_expr : t -> unit
	val get_bounding_type : (module MIXIN_EXPR_SIG) -> Types.EnvTypes.environment -> t -> Types.TypeElements.t
	val module_contains_input_parameter_exn : Program_tree.Ast.source_param -> t -> bool
	val module_contains_input_parameter_i_exn : Program_tree.Ast.source_param -> int -> t -> bool
	val calc_abstract_methods: Types.EnvTypes.method_environment -> Program_tree.Ast.method_declaration list -> t -> Program_tree.Ast.method_declaration list
end

module type TypeElementsSig = sig
	module type InimoduleSig = DeclSignatures.INIMODULE_DECL with type t = Program_tree.Ast.ini_module_decl
	module type MixinEXPRSig = ExpressionsSig.MIXIN_EXPR with type t = Program_tree.Ast.mixin_expr

	type t = Types.TypeElements.t
	val get_applications : (module MixinEXPRSig) -> Types.EnvTypes.method_environment -> t -> Types.TypeElements.poly_application_value list
	val new_type_el : bool -> t
	val new_type_el_2 : Types.EnvTypes.environment -> Types.PolymorphismParam.t -> t -> t
	val new_type_el_3 : Types.EnvTypes.environment -> Types.TypeElement.t -> t   
	val add_new_at_start : t -> t -> t
	val add_new : t -> t -> t
	val sum_with : t -> t -> t
	val to_string : t -> string
	val contains_type_elem : Types.EnvTypes.environment -> Types.TypeElement.t -> t -> bool
	val is_subtype_of : Types.EnvTypes.environment -> t -> t -> bool
	val check_is_subtype_of_exn : Types.EnvTypes.environment -> t -> t -> TypeError.t -> unit
	val is_isomorphic_to : Types.EnvTypes.environment -> t -> t -> bool
	val module_contains_input_parameter_exn : Types.EnvTypes.environment -> Program_tree.Ast.source_param -> t -> bool
	val calc_abstract_methods : Types.EnvTypes.method_environment -> t -> Program_tree.Ast.method_declaration list
	val set_poly_params_from : Types.TypeElements.PolyApplicationValues.t -> t -> t
	val mixin_exists_in_prefix : int -> Types.TypeElement.t -> t -> bool
	val check_if_base_mixin_exist : (module MixinEXPRSig) -> Types.EnvTypes.method_environment -> t -> unit
	val gen_code_for_activated_modules_exn : (module InimoduleSig) -> Program_tree.Ast.init_param list -> t -> int
end