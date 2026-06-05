open Types

(* first class module signatures *)
module type TypeElementSig = ModuleSignatures.TypeElementSig.S with type t = TypeElement.t
module type PolymorphismParamSig = ModuleSignatures.TypeElementSig.PolymorphismParam with type t = TypeElement.t
module type MixinDeclSig = ModuleSignatures.TypeElementSig.MixinDecl with type t = TypeElement.t
module type InimoduleSig = ModuleSignatures.DeclSignatures.INIMODULE_DECL with type t = Program_tree.Ast.ini_module_decl
module type MixinEXPRSig = ModuleSignatures.Expressions.MIXIN_EXPR with type t = Program_tree.Ast.mixin_expr

type t = TypeElements.t

let get_applications method_env (module TypeEl : TypeElementSig) (type_elements:t) =     
	let appl_list = List.map (TypeEl.get_applications method_env) type_elements.types in
	List.fold_left List.append type_elements.poly_app_val appl_list

let new_type_el is_all : t = {types=[];is_all;poly_app_val=[]}

let new_type_el_2 env poly_param (value:t) :t = 
	let types = [TypeElement.of_global_decl_exn (Declarations.EnvGDeclMaker.Environment.get_mixin_exn "Object" env)] in
	let is_all = false in
	let poly_app_val : Types.TypeElements.poly_application_value list = [{poly_param;value}] in
	{types;is_all;poly_app_val}

let new_type_el_3 env type_el :t = 
	let obj_el = TypeElement.of_global_decl_exn (Declarations.EnvGDeclMaker.Environment.get_mixin_exn "Object" env) in
	let types = [obj_el; type_el] in
	let is_all = false in
	let poly_app_val = [] in
	{types;is_all;poly_app_val}

let add_new_at_start (type_elements_1:t) (type_elements_2:t):t  = 
	let lst = List.filter (fun x -> not (List.mem x type_elements_1.types)) type_elements_2.types in
	{type_elements_1 with types = (type_elements_2.types@lst)}


let add_new (type_elements_1:t) (type_elements_2:t):t = 
	let type_el = add_new_at_start type_elements_1 type_elements_2 in
	{type_el with poly_app_val = type_elements_1.poly_app_val @ type_elements_2.poly_app_val}

let sum_with (type_elements_1:t) (type_elements_2:t) :t = 
	add_new type_elements_1 type_elements_2

let to_string (type_elements:t) = 
	let fold_func acc el = acc ^ ", " ^ (TypeElement.get_caption el) in
	let s = List.fold_left fold_func ("(" ^ (List.hd type_elements.types |> TypeElement.get_caption )) (List.tl type_elements.types) in 
	s ^ ")"

let rec contains_type_elem (module PolymorphismParam : PolymorphismParamSig) (env : Types.EnvTypes.environment) (el : TypeElement.t) (type_elements:t) =
    let check_bounding_type = function
    | TypeElement.PolymorphismDecl p -> PolymorphismParam.get_bounding_type env (PolymorphismDecl p) |> contains_type_elem (module PolymorphismParam) env el 
    | _ -> false 
    in
    List.exists (fun x -> (el = x) || check_bounding_type x ) type_elements.types

(*lastChecked is not in this version because upon code review it does not have any effect on the code this makes the funcion a lot more simple*)
let is_subtype_of (module PolymorphismParam : PolymorphismParamSig) env (type_elements_1:t) (type_elements_2:t) : bool =
        try
            type_elements_1.is_all || (List.for_all (fun el -> contains_type_elem (module PolymorphismParam) env el type_elements_1) type_elements_2.types)
        with 
            | _ -> false

let check_is_subtype_of_exn (module PolymorphismParam : PolymorphismParamSig) env (type_elements_1:t) (type_elements_2:t) error_status = 
    if not (is_subtype_of (module PolymorphismParam) env type_elements_1 type_elements_2) then 
        let error_message = (to_string type_elements_1) ^ " is not subtype of " ^ (to_string type_elements_2) in
        let error_status = TypeError.set_error_message error_message error_status in
        TypeError.raise_ctype_error error_status

let is_isomorphic_to (module PolymorphismParam : PolymorphismParamSig) env (type_elements_1:t) (type_elements_2:t) : bool =
    let is_subtype_of = is_subtype_of (module PolymorphismParam) env in
    is_subtype_of type_elements_1 type_elements_2 && is_subtype_of type_elements_2 type_elements_1

let rec module_contains_input_parameter_exn (module PolymorphismParam : PolymorphismParamSig) (module MixinDecl : MixinDeclSig) env (source_init_parameter : Program_tree.Ast.source_param) (type_elements:t) =
    let module_contains_input_parameter_exn = module_contains_input_parameter_exn (module PolymorphismParam) (module MixinDecl) in
    let check_function_exn (type_element:TypeElement.t) = match type_element with
    | PolymorphismDecl _ -> module_contains_input_parameter_exn env source_init_parameter (PolymorphismParam.get_bounding_type env type_element)
    | MixinDecl _ -> MixinDecl.module_contains_input_parameter_exn source_init_parameter type_element
    (*| _ -> failwith ("Unknown class of ITypeElement")*)
    in
    List.exists check_function_exn type_elements.types

let calc_abstract_methods (module MixinDecl : MixinDeclSig) (method_environment : EnvTypes.method_environment) (type_elements:t) = 
    let res : Program_tree.Ast.new_method list = [] in
    let fold_func acc (type_element:TypeElement.t) = match type_element with
    | MixinDecl _ -> MixinDecl.calc_abstract_methods method_environment acc type_element
    | _ -> acc in
    List.fold_left fold_func res type_elements.types

let set_poly_params_from (poly_appl_values : TypeElements.PolyApplicationValues.t) (type_elements:t) =
    let res = new_type_el false in
    let fold_func (acc:t) (type_element:TypeElement.t) = match type_element with
    | PolymorphismDecl p ->  
        let j = TypeElements.PolyApplicationValues.index_of_param p poly_appl_values in 
        Option.fold 
            ~none:{acc with types = type_element::acc.types} 
            ~some:(fun j -> 
                    let poly_value = Option.get (TypeElements.PolyApplicationValues.find_param j poly_appl_values) in
                    add_new acc poly_value.value
                ) j 
    | _ -> {acc with types = type_element::acc.types} in
    List.fold_left fold_func res type_elements.types

let mixin_exists_in_prefix prefix_end mixin_target (type_elements:t) =
	let get_mixin (m:TypeElement.t) = match m with
	| MixinDecl m -> m
	| _ -> failwith("A mixin was expected") in
	let check_prefix (mixin:TypeElement.t) = match mixin with
        | MixinDecl m -> m = (get_mixin mixin_target)
        | _ -> false
    in
    List.filteri (fun i _ -> i <= prefix_end) type_elements.types 
    |> List.exists check_prefix 

let check_if_base_mixin_exist (module MixinEXPR : MixinEXPRSig)(module MixinDecl : MixinDeclSig) (method_environment : Types.EnvTypes.method_environment) (type_elements:t) =
	let check_mixin (type_element:TypeElement.t) = 
		match type_element with
		| MixinDecl mixin_decl -> 
			let base_type =  MixinEXPR.get_type_exn method_environment mixin_decl.mixin_parent in
			let check_list = List.filteri (fun x y -> not (mixin_exists_in_prefix x y type_elements)) base_type.types in
			if (not (List.is_empty check_list)) then failwith ("Error in Expression used to create new object from: " ^ (to_string type_elements) ^ " : " ^ mixin_decl.mixin_name ^ " requires " ^ (TypeElement.get_name type_element) ^ " which is not present") 
		| _ -> failwith("instantiation from the polymorphic params not yet supported!") in
	List.iter check_mixin type_elements.types

(* Took out InstrEnvironment from the parameters since it is not used *)    
let gen_code_for_activated_modules_exn (module MixinDecl : MixinDeclSig) (module InimoduleDecl : InimoduleSig) (initialization_of_params : Program_tree.Ast.init_param list) type_elements =
    let fold_func_inner ini_module (acc: int * Program_tree.Ast.init_param list * TypeElement.t) = 
        let result , t_init_params, mixin_decl = (acc) in
        if not (InimoduleDecl.activated_by t_init_params ini_module) then
            if (ini_module.is_required) then failwith("Required ini module in [" ^ (to_string type_elements) ^ "] was not activated")
            else acc
        else
            let code_string = (Utils.CGenCodeHelper.get_tab ()) ^ "modules.add(" ^ (MixinDecl.code_for_mixin mixin_decl) ^ ".IniModules[" ^ (InimoduleDecl.to_string ini_module) ^ "]);" in
                Utils.GenCode.print_code code_string;
                (result + 1 , (InimoduleDecl.modify_parameter_list t_init_params ini_module) , mixin_decl)
    in
    let fold_func_outer (mixin_decl:TypeElement.t) (acc: int * Program_tree.Ast.init_param list) = 
        let result , t_init_params = acc in
        let ini_module_list = match mixin_decl with
        | MixinDecl m -> m.mixin_ini_module
        | _ -> [] in
        List.fold_right fold_func_inner ini_module_list (result,t_init_params,mixin_decl) |>
        fun (result,t_init_params,_) -> (result,t_init_params)
    in
    List.fold_right fold_func_outer type_elements.types (0, initialization_of_params) |>
    fun (result, initialization_of_params) ->
        if (List.is_empty initialization_of_params) then
            result
        else
            failwith ("There is no ini module in [" ^ (to_string type_elements) ^ "] to consume parameter: " ^ (List.hd initialization_of_params |> fun init_param -> init_param.iparam_name^"."^init_param.iparam_name))
