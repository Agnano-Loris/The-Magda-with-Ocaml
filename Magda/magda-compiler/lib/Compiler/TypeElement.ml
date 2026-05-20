open Program_tree.Ast

module type S = sig
	type t
	val get_name : t -> string
	val get_caption: t -> string
	val get_applications: t -> t(*PolyApplValues CT e P list*) -> t(*Cenv.t*)
end

type t = 
| MixinDecl of mixin_decl
| PolymorphysmDecl of polymorphism_param

let of_global_decl_exn (g_decl:global_declaration) = match g_decl with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphysmDecl polymorphism_param-> PolymorphysmDecl polymorphism_param
| _ -> failwith("Let Declaration is not a TypeElement")

let to_global_decl (type_el:t):global_declaration = match type_el with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphysmDecl polymorphism_param-> PolymorphysmDecl polymorphism_param
