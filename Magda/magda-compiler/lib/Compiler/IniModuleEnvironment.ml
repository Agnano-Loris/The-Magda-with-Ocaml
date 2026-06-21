open Declarations.EnvGDeclMaker
type t = Types.EnvTypes.inimodule_environment

let empty:t = {
	method_environment = MethodEnvironment.empty;
	module_number = -1
}
let  new_inimodule_environment (decls:Program_tree.Ast.global_declaration list) (mixin_decl:Program_tree.Ast.mixin_decl) (module_number:int) :t =
	let method_environment = MethodEnvironment.new_method_environment_2 decls mixin_decl in
	{method_environment;module_number} 

let get_type_element_exn el_name (inimodule_environment:t) = 
	MethodEnvironment.get_type_element_exn el_name inimodule_environment.method_environment
	
let get_declaration_exn el_name (inimodule_environment : t) = 
	MethodEnvironment.get_declaration_exn el_name inimodule_environment.method_environment

let get_mixin_exn name (inimodule_environment : t) = MethodEnvironment.get_mixin_exn name inimodule_environment.method_environment
