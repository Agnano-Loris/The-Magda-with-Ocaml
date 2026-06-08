open Program_tree.Ast
include List

type t = {
	types: TypeElement.t list;
	is_all: bool;
	poly_app_val: poly_application_value list;
} 
and poly_application_value = {
  poly_param : PolymorphismParam.t;
  value : t
}

module PolyApplicationValues = struct
  type t = poly_application_value list
  let index_of_param (param:PolymorphismParam.t) (lst : t) : int option = List.find_index (fun x -> (x.poly_param.base.poly_name) == param.base.poly_name) lst
  let find_param (param_index:int) (lst : t) : poly_application_value option = match List.filteri (fun i _ -> i = param_index) lst with
  | [] -> None
  | x :: _ -> Some x

  let find_by_name param_name (lst:t) = List.find_opt (fun appl_value -> appl_value.poly_param.base.poly_name = param_name) lst
end