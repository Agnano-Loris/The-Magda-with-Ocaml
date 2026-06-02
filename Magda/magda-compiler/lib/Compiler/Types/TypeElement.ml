open Program_tree.Ast

type t = 
| MixinDecl of mixin_decl
| PolymorphismDecl of PolymorphismParam.t 

let of_global_decl_exn (g_decl:global_declaration) = match g_decl with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphismDecl polymorphism_param-> PolymorphismDecl {base = polymorphism_param; container = None}
| _ -> failwith("Let Declaration is not a TypeElement")

let to_global_decl (type_el:t):global_declaration = match type_el with
| MixinDecl mixin_decl -> MixinDecl mixin_decl
| PolymorphismDecl polymorphism_param-> PolymorphismDecl polymorphism_param.base

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