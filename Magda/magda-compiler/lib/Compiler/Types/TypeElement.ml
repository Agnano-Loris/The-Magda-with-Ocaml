open Program_tree.Ast

type t = 
| MixinDecl of mixin_decl
| PolymorphismDecl of polymorphism_param

let of_global_decl_exn (g_decl:global_declaration) = match g_decl with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphismDecl polymorphism_param-> PolymorphismDecl polymorphism_param
| _ -> failwith("Let Declaration is not a TypeElement")

let to_global_decl (type_el:t):global_declaration = match type_el with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphismDecl polymorphism_param-> PolymorphismDecl polymorphism_param