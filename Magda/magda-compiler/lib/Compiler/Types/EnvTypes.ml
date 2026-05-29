open Program_tree.Ast

type environment = {
	decls: global_declaration list; 
	calculated_types: TypeElements.t OrderedGlobalDeclaration.DeclarationMap.t
}
and method_environment =  {
    environment: environment;
    current_mixin: mixin_decl option
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