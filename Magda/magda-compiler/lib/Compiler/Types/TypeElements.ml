open Program_tree.Ast
include List

type t = {
	types: TypeElement.t list;
	is_all: bool;
	poly_app_val: poly_application_values
} 
and poly_application_value = {
  poly_param : polymorphism_param;
  value : t
} 

module PolyApplicationValues = struct
  type t = poly_application_value list
  let index_of_param param (lst : poly_application_value) : int option = List.find_index (fun x -> (x.poly_name) == param.poly_name) lst.poly_param
end