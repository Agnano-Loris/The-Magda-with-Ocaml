
open Program_tree.Ast
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
(*let gen_code (*temp_counter environment*) = failwith("Not Impl")*)

let get_bounding_type (module MixinEXPR : MIXIN_EXPR_SIG) env = function
| MixinDecl _ -> failwith "TypeElement.code_for_mixin not yet implemented for MixinDecl"
| PolymorphismDecl p -> 
  let method_env = EnvGDeclMaker.MethodEnvironment.new_method_environment env (Option.get p.container) in
  MixinEXPR.get_type_exn (method_env) p.base.bound

let get_type_exn (method_env : Types.EnvTypes.method_environment) type_element = 
	let type_found = Types.TypeElement.TypeElementMap.find_opt type_element method_env.environment.calculated_types in
	if Option.is_some type_found then Option.get type_found 
	else match type_element with
	| MixinDecl _ -> failwith "Not yet implemented" (*get_native_type*)
	| PolymorphismDecl p -> TypeElementsUtilities.new_type_el_3 method_env.environment type_element 


(*
POLY
    public CType GetType (CMethodEnvironment env){ 
        if (env.calculatedTypes.get(this) != null)
            return /*(CType)*/ env.calculatedTypes.get(this);
        //
        CType res = CType.createCType(env, this);
        env.calculatedTypes.put(this, res);
        return res;
        //
    }

MIXIN
    public CType GetType (CMethodEnvironment env){ 
        if (env.calculatedTypes.get(this) != null)
            return /*(CType)*/ env.calculatedTypes.get(this); //sprawdzamy czy nie jest juz w trakcie liczenia -zeby unknac zapetlenia
        //
        CType res = GetNativeType(env);
        env.calculatedTypes.put(this, res);
        res.addNewAtStart(BaseMixinExpression.GetType(env) );
        return res;
    }
*)