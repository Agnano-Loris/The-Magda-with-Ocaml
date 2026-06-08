open Program_tree.Ast
module type S = sig 
	type t
	val of_global_decl_exn : global_declaration -> t
	val to_global_decl : t -> global_declaration
	val get_name : t -> string
	val get_caption : t -> string
	val get_applications : (module ExpressionsSig.MIXIN_EXPR) -> Types.EnvTypes.method_environment -> t -> Types.TypeElements.poly_application_value list

end


module type PolymorphismParam = sig
	type t 
	include S with type t := t
	val print : t -> unit
	val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> Types.EnvTypes.environment -> t -> unit
	val check_types : Types.EnvTypes.environment -> t -> unit (* Needs to see wether to modify the signature *)
	val get_type : Types.EnvTypes.environment -> t -> Types.TypeElements.t
	val get_native_type : Types.EnvTypes.method_environment -> t -> Types.TypeElements.t
	val gen_code_for_mixin_expr : t -> unit
	val get_bounding_type : Types.EnvTypes.environment -> t -> Types.TypeElements.t
end

module type MixinDecl = sig
	type t 
	include S with type t := t
	val print : t -> unit
	val check_types : Types.EnvTypes.environment -> t -> unit (* Needs to see wether to modify the signature *)
	val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> Types.EnvTypes.environment -> t -> unit
	val gen_code_for_mixin_expr : t -> unit
	val code_for_mixin : t -> string
	val module_contains_input_parameter_exn : Program_tree.Ast.source_param -> t -> bool
	val module_contains_input_parameter_i_exn : Program_tree.Ast.source_param -> int -> t -> bool
	val calc_abstract_methods: Types.EnvTypes.method_environment -> Program_tree.Ast.new_method list -> t -> Program_tree.Ast.new_method list
end