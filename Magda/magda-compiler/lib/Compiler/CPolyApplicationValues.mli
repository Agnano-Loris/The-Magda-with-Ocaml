(** type t substitute the CPolyApplicationValue class. It's a record with the corresponding values *)
type t = {
  poly_param : Program_tree.Ast.polymorphism_param list;
  value : CType.t
}

(** Expecting type t to be used in a list for the project
    [index_of_param param lst] returns [Some i] where [i] is the index of the element [el] where [param]
    is equal to [el.poly_param].
*)
val index_of_param : Program_tree.Ast.polymorphism_param -> t -> int option