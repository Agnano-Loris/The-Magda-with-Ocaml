

open Program_tree.Ast
(*open Declarations.EnvGDeclMaker*)
(*open Types.TypeElements*)
type t = mixin_expr

module type S = ModuleSignatures.ExpressionsSig.MIXIN_EXPR

let get_type_exn _ (_:mixin_expr) = failwith "not implemented"(*match mixin_expr with
	| MixinExpressionId id -> 
		let decl_or_param = MethodEnvironment.get_declaration_exn id method_env in
			(match decl_or_param with
			| Left _ ->  failwith "not implemented"
			| Right _ ->  failwith "not implemented")
	| MixinExpressionConcat mixin_expr_concat ->
		let left_type = get_type_exn method_env mixin_expr_concat.left_mixin in
		let right_type = get_type_exn method_env mixin_expr_concat.right_mixin in
		TypeElementUtilities.sum_with left_type right_type
	| MixinExpressionApplication mixin_expr_application ->
		let val_type = get_type_exn method_env mixin_expr_application.value in
		let poly_par = 
			MethodEnvironment.get_mixin_exn mixin_expr_application.mixin_name method_env 
			|> GlobalDeclararion.get_mixin_exn 
			|> fun m -> List.find (fun el -> mixin_expr_application.mixin_name = el.poly_name) m.mixin_polymorphism_params
		in
		if pl		 
	| MixinExpressionVoid -> TypeElementUtilities.new_type_el false*)
let get_native_type_exn _ _ = failwith "not implemented"
let gen_code _ _ _ = failwith "not implemented"
let print _ = failwith "not implemented"

