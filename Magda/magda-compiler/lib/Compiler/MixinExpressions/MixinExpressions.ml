

open Program_tree.Ast
open Declarations.EnvGDeclMaker
open Types.TypeElements
open TypeUtilities.CycleFix
type t = mixin_expr

module type S = ModuleSignatures.ExpressionsSig.MIXIN_EXPR

let rec get_type_exn method_env (mixin_expr:mixin_expr) = match mixin_expr with
	| MixinExpressionId id -> 
		let decl_or_param = MethodEnvironment.get_declaration_exn id method_env in
			(match decl_or_param with
			| Left _ ->  failwith "not implemented"
			| Right _ ->  failwith "not implemented")
	| MixinExpressionConcat mixin_expr_concat ->
		let left_type = get_type_exn method_env mixin_expr_concat.left_mixin in
		let right_type = get_type_exn method_env mixin_expr_concat.right_mixin in
		TypeElementsImpl.sum_with left_type right_type
	| MixinExpressionApplication mixin_expr_application ->
		let val_type = get_type_exn method_env mixin_expr_application.value in
		let poly_par = 
			MethodEnvironment.get_mixin_exn mixin_expr_application.mixin_name method_env 
			|> GlobalDeclararion.get_mixin_exn 
			|> fun m -> List.find (fun el -> mixin_expr_application.mixin_name = el.poly_name) m.mixin_polymorphism_params
		in
		if TypeElementsImpl.is_subtype_of method_env.environment (TypeElementImpl.get_bounding_type () method_env.environment (Types.TypeElement.PolymorphismDecl (Types.PolymorphismParam.of_polymorphism_param poly_par))) val_type 
     		then failwith "ni"
    	else
			val_type
	| MixinExpressionVoid -> TypeElementsImpl.new_type_el false
  | _ -> failwith "vsno"
let get_native_type_exn _ _ = failwith "not implemented"
let gen_code _ _ _ = failwith "not implemented"
let print _ = failwith "not implemented"


let to_string (_:t) : string = failwith "not implemented"