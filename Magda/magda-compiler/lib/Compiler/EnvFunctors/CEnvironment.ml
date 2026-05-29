open Program_tree.Ast
open ModuleSignatures


module Make (GlobalDeclaration : DeclSignatures.GLOBAL_DECL) : EnvSig.ENV = struct
	type t = Types.EnvTypes.environment

	let empty : t = {
		decls = [];
		calculated_types = OrderedGlobalDeclaration.DeclarationMap.empty
	}

	let new_environment ?(calculated_types = OrderedGlobalDeclaration.DeclarationMap.empty) decls : t = {decls;calculated_types}

	let get_mixin_exn name (environment : t) = 
		let find_mixin_decl (decl:global_declaration) = (GlobalDeclaration.is_mixin_decl decl) && (GlobalDeclaration.get_name decl == name) in
		try (List.find find_mixin_decl environment.decls) with Not_found -> failwith("Mixin " ^ name ^ " not found!")

	let get_declaration_exn name (environment:t) = 
		let find_declaration (d:global_declaration) = (=) name (GlobalDeclaration.get_name d) in
		try (List.find find_declaration environment.decls) with Not_found -> failwith("Declaration " ^ name ^ " not found!")
end