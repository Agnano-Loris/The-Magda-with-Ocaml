open Program_tree.Ast

type t = {
  base: polymorphism_param;
  container: mixin_decl option
}

let of_polymorphism_param poly_param = {base = poly_param; container=None}