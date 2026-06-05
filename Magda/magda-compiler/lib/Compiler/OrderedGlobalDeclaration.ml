open Program_tree.Ast

type t = global_declaration

let compare (d1:t) (d2:t) = match d1, d2 with
	| LetDecl _, MixinDecl _ -> 1
	| MixinDecl _, LetDecl _ -> -1
	| MixinDecl m_d1, MixinDecl m_d2 -> String.compare m_d1.mixin_name m_d2.mixin_name
	| LetDecl l_d1, LetDecl l_d2 -> String.compare l_d1.let_name l_d2.let_name

module Declaration = struct
  type t = global_declaration
  let compare = compare
end

module DeclarationMap = Map.Make(Declaration:Map.OrderedType)
