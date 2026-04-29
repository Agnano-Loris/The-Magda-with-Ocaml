(*Declared private first and second type for readability*)
type param = Program_tree.Declarations.CPolymorphismParam.t
type ctype = CType.t
type t = param * ctype

let index_of_param param (lst : t list) : int option = List.find_index (fun x -> (Pair.fst x) == param) lst