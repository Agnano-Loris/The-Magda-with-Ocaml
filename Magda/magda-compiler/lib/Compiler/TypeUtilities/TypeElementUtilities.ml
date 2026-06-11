module Make (TypeElements : ModuleSignatures.TypeElementSig.TypeElementsSig) : ModuleSignatures.TypeElementSig.S = struct
	open Program_tree.Ast
	open Declarations.EnvGDeclMaker
	include Types.TypeElement 

	module type MIXIN_EXPR_SIG = ModuleSignatures.ExpressionsSig.MIXIN_EXPR with type t := mixin_expr

	let rec get_caption = function
	| MixinDecl mixin_decl -> mixin_decl.mixin_name
	| PolymorphismDecl polymorphism_param-> (get_caption (MixinDecl (Option.get polymorphism_param.container))) ^ "." ^ polymorphism_param.base.poly_name

	let is_mixin_decl = function
	| MixinDecl _ -> true
	| _ -> false

	let is_poli_param_decl = function
	| PolymorphismDecl _ -> true
	| _ -> false  

	let get_name = function
		| MixinDecl m -> m.mixin_name
		| PolymorphismDecl p -> p.base.poly_name


	let rec get_applications (module MixinEXPR : MIXIN_EXPR_SIG) method_env = function
	| MixinDecl _ -> []
	| PolymorphismDecl p -> 
		let type_elements = MixinEXPR.get_type_exn method_env p.base.bound in
		let appl_list = List.map (get_applications (module MixinEXPR) method_env) type_elements.types in
		List.fold_left List.append type_elements.poly_app_val appl_list

	let print (module MixinEXPR : MIXIN_EXPR_SIG) = function
	| MixinDecl _ -> failwith "Not impl"
	| PolymorphismDecl p ->
		let code_string = p.base.poly_name ^ "<=" in
		Utils.GenCode.print_code code_string;
		MixinEXPR.print p.base.bound;
		Utils.GenCode.print_code ";"

	let code_for_mixin = function
	| MixinDecl m -> "CMagdaMixinSequence.globalList.getMixin(\""^ m.mixin_name ^"\")"
	| _ -> failwith "TypeElement.code_for_mixin not implemented for PolyMorphismDecl"


	let gen_code_for_mixin_expr = function
	| PolymorphismDecl _ -> failwith "TypeElement.code_for_mixin not yet implemented for PolyMorphismDecl"
	| MixinDecl m ->
		Utils.CGenCodeHelper.get_tab () ^ "tempList.add (" ^ code_for_mixin (MixinDecl m) ^");"
		|> Utils.GenCode.print_code

	let get_bounding_type (module MixinEXPR : MIXIN_EXPR_SIG) env = function
	| MixinDecl _ -> failwith "TypeElement.code_for_mixin not yet implemented for MixinDecl"
	| PolymorphismDecl p -> 
	let method_env = MethodEnvironment.new_method_environment env (Option.get p.container) in
	MixinEXPR.get_type_exn (method_env) p.base.bound

  
	let get_native_type (method_env : Types.EnvTypes.method_environment) (type_element:t):Types.TypeElements.t =
	match type_element with
	| MixinDecl m -> TypeElements.new_type_el_3 method_env.environment type_element
	| PolymorphismDecl _ -> failwith "TypeElementUtilities.get_native_type not supported by polymorphic param"

	let get_type_exn (method_env : Types.EnvTypes.method_environment) (type_element:t) = 
		let type_found = Types.TypeElement.TypeElementMap.find_opt type_element method_env.environment.calculated_types in
		if Option.is_some type_found then (Option.get type_found, method_env) 
		else 
			let new_env = fun new_type -> 
				Environment.new_environment 
					~calculated_types:(TypeElementMap.add type_element new_type method_env.environment.calculated_types) method_env.environment.decls in    
			match type_element with
			| MixinDecl _ ->
				let res = get_native_type method_env type_element in
				let method_env = {method_env with environment = {method_env.environment with calculated_types = (TypeElementMap.add type_element res method_env.environment.calculated_types)}} in
				(TypeElements.add_new_at_start res (TypeElements.new_type_el false(*BaseMixinExpression.GetType(env)*)), method_env)	
			| PolymorphismDecl _ -> 
				let res = TypeElements.new_type_el_3 method_env.environment type_element in
				(res, MethodEnvironment.new_method_environment (new_env res) (Option.get method_env.current_mixin))
				
  let module_contains_input_parameter_i_exn (source_param : Program_tree.Ast.source_param) (inimodule_size:int) (type_element:t):bool =
  let contains_param (param_el : Program_tree.Ast.source_param) = (param_el.param_name = source_param.param_name) &&  (param_el.mixin_name = source_param.mixin_name) in
  match type_element with
  | MixinDecl m -> List.filteri (fun i ini_module -> (i < inimodule_size) && List.exists contains_param ini_module.in_params) m.mixin_ini_module |> List.is_empty |> not
  | _ -> failwith "TypeElement.module_contains_input_parameter_exn can be called only on MixinDeclaration"

	let module_contains_input_parameter_exn (source_param : Program_tree.Ast.source_param) (type_element:t): bool =
  match type_element with
  | MixinDecl m -> module_contains_input_parameter_i_exn source_param (List.length m.mixin_ini_module) (type_element)
  | _ -> failwith "TypeElement.module_contains_input_parameter_exn can be called only on MixinDeclaration"

let calc_abstract_methods (method_env:Types.EnvTypes.method_environment) (prev_abstract_methods:Program_tree.Ast.method_declaration list) (type_element:t) : Program_tree.Ast.method_declaration list = 
	let get_method_name = function
		| AbstractMethod a -> a.abstract_method_name
		| OverrideMethod o -> o.override_method_name
		| NewMethod n -> n.new_method_name
	in
	let is_abstract = function
		| AbstractMethod _ -> true
		| _ -> false
	in
	let method_decl_to_override method_decl = match method_decl with
		| OverrideMethod o -> o
		| _ -> failwith "Only for Override method"	
	in
	let get_source_method (override_m_decl : override_method): new_method = 
		Declarations.EnvGDeclMaker.MethodEnvironment.get_mixin_exn override_m_decl.override_method_mixin_overridden method_env
		|> Declarations.EnvGDeclMaker.GlobalDeclararion.get_mixin_exn 
		|> fun m -> 
			List.map (function
				| NewMethod new_method -> new_method
				| _ -> failwith "Only using on new_methods") 
			m.mixin_new_methods
		|> fun m -> List.find (fun n_m -> n_m.new_method_name = override_m_decl.override_method_name) m
	in
	match type_element with
	| MixinDecl mixin -> 
		(
		List.filter 
			(fun abstract_mehtod -> 
				List.exists 
					(fun m -> (((method_decl_to_override m) |> get_source_method).new_method_name = (get_method_name abstract_mehtod)) |> not) 
					mixin.mixin_override_methods) 
			prev_abstract_methods
		)
		|> (@) (List.filter is_abstract mixin.mixin_new_methods)
  | _ -> failwith "TypeElement.calc_abstract_methods can be called only on MixinDeclaration"



end
	