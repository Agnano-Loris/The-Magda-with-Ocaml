open Program_tree.Ast
module type S = sig 
	type t
	val of_global_decl_exn : global_declaration -> t
	val to_global_decl : t -> global_declaration
	val get_name : t -> string
	val get_caption : t -> string
  val get_applications : Types.EnvTypes.method_environment -> t -> Types.TypeElements.poly_application_values
end