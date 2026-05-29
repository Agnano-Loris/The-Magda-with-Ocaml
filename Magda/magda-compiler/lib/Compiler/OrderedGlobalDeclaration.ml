open Program_tree.Ast

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

module Declaration = struct
  type t = global_declaration
  let compare = compare
end

module DeclarationMap = Map.Make(Declaration:Map.OrderedType)
