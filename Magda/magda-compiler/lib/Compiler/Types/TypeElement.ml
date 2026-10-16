open Program_tree.Ast

type t = 
| MixinDecl of mixin_decl
| PolymorphismDecl of PolymorphismParam.t 

let compare (d1:t) (d2:t) = match d1, d2 with
	| PolymorphismDecl _, MixinDecl _ -> 1
	| MixinDecl _, PolymorphismDecl _ -> -1
	| MixinDecl m_d1, MixinDecl m_d2 -> String.compare m_d1.mixin_name m_d2.mixin_name
	| PolymorphismDecl p_d1, PolymorphismDecl p_d2 -> String.compare p_d1.base.poly_name p_d2.base.poly_name

let of_global_decl_exn (g_decl:global_declaration) = match g_decl with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| _ -> failwith("Let Declaration is not a TypeElement")

let to_global_decl (type_el:t):global_declaration = match type_el with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| _ -> failwith("Polymorphism Declaration is not a TypeElement")



type ord_el = t
module OrderedTypeElement = struct
  type t = ord_el
  let compare = compare
end

module TypeElementMap =  Map.Make(OrderedTypeElement:Map.OrderedType)