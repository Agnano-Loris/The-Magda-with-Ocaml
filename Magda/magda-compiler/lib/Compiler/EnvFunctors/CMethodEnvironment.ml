open Program_tree.Ast
open ModuleSignatures
module Make (GlobalDeclaration : DeclSignatures.GLOBAL_DECL)(Env : EnvSig.ENV) : EnvSig.METHOD_ENV = struct
	module Environment = Env
	type t = Types.EnvTypes.method_environment

	let empty : t = {
		environment = Environment.empty;
		current_mixin = None
	}

	let new_method_environment environment mixin_decl : t = {current_mixin = Some mixin_decl;environment}

  	let new_method_environment_2 decls mixin_decl : t = 
		let environment = Environment.new_environment decls in
		{environment;current_mixin = Some mixin_decl}

	let get_type_element_exn el_name (method_environment:t) = 
		let mixin_polymorphism_params = let mixin = Option.get method_environment.current_mixin in mixin.mixin_polymorphism_params in
		let mixin_type = List.find_opt (fun poli_el -> poli_el.poly_name == el_name) mixin_polymorphism_params in
		let type_el_op = Option.bind mixin_type (fun x -> Some (Types.TypeElement.PolymorphismDecl (Types.PolymorphismParam.of_polymorphism_param x))) in
		Option.value type_el_op 
			~default:(Environment.get_mixin_exn el_name method_environment.environment |> Types.TypeElement.of_global_decl_exn)

	let get_declaration_exn el_name (method_environment : t) = 
		let mixin_polymorphism_params = let mixin = Option.get method_environment.current_mixin in mixin.mixin_polymorphism_params in
		let decl = List.find_opt (fun poli_el -> poli_el.poly_name == el_name) mixin_polymorphism_params in
    	let decl_op = Option.bind decl (fun x -> Some (Program_tree.Ast.PolymorphismDecl x)) in
		Option.value decl_op 
			~default:(Environment.get_declaration_exn el_name method_environment.environment)

	let get_mixin_exn name (method_environment : t) = Environment.get_mixin_exn name method_environment.environment
end