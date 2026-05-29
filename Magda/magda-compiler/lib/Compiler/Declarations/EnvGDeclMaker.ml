open Program_tree.Ast
open ModuleSignatures

module GlobalDeclararion : DeclSignatures.GLOBAL_DECL = struct
  type t = global_declaration

  let compare (d1:t) (d2:t) = match d1, d2 with
	| PolymorphismDecl _, LetDecl _ -> 1
	| PolymorphismDecl _, MixinDecl _ -> 1
	| LetDecl _, PolymorphismDecl _ -> -1
	| MixinDecl _, PolymorphismDecl _ -> -1
	| LetDecl _, MixinDecl _ -> 1
	| MixinDecl _, LetDecl _ -> -1
	| MixinDecl m_d1, MixinDecl m_d2 -> String.compare m_d1.mixin_name m_d2.mixin_name
	| LetDecl l_d1, LetDecl l_d2 -> String.compare l_d1.let_name l_d2.let_name
	| PolymorphismDecl p_d1, PolymorphismDecl p_d2 -> String.compare p_d1.poly_name p_d2.poly_name

	let is_mixin_decl = function
	| MixinDecl _ -> true
	| _ -> false

	let is_let_decl = function
	| LetDecl _ -> true
	| _ -> false

	let is_poli_param_decl = function
	| PolymorphismDecl _ -> true
	| _ -> false    

	let get_name = function
	| MixinDecl m -> m.mixin_name
	| LetDecl l -> l.let_name
	| PolymorphismDecl p -> p.poly_name
end

module Environment : EnvSig.ENV = EnvFunctors.CEnvironment.Make(GlobalDeclararion) 

module MethodEnvironment : EnvSig.METHOD_ENV = EnvFunctors.CMethodEnvironment.Make(GlobalDeclararion)(Environment)