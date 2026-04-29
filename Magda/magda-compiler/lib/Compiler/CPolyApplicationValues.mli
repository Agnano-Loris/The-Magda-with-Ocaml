(** type t substitute the CPolyApplicationValue class by having a Pair with the corresponding values *)
type t = Program_tree.Declarations.CPolymorphismParam.t * CType.t

(** Expecting type t to be used in a list for the project
    [index_of_param param lst] returns [Some i] where [i] is the index of the element [el] where [param]
    is equal to [Pair.fst el]
*)
val index_of_param : Program_tree.Declarations.CPolymorphismParam.t -> t list -> int option