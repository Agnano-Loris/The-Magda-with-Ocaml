(** Implements the MethodContext by using a [MagdaType] option for the return types,
	and for the params and variables it uses OCaml's {! Map} module instantiated with {! String} keys and containing {! Utils.MagdaType.t} values.
*)
open Utils

module StringMap = Map.Make(String)

(** Type containing the data of the MixinContext*)
type t = {

	params : MagdaType.t StringMap.t; (** Formal parameters table: parameter_name -> parameter_type *)
  
	variables : MagdaType.t StringMap.t; (** Local variables table: variable_name -> variable_type *)
	
	res_type : MagdaType.t option (** Return type of the method, initially [None] *)
}


(** Creates a [MethodContext.t] type record with the Maps set to empty and the res_type to None *)
let empty () : t =  
	{
    	params = StringMap.empty;
    	variables = StringMap.empty;
    	res_type = None
	}


let add_variable var_name var_type method_context = 
	let variables = StringMap.add var_name var_type method_context.variables in
	{method_context with variables};;


let add_param param_name param_type method_context = 
let params = StringMap.add param_name param_type method_context.params in
	{method_context with params};;


let get_return_type method_context = method_context.res_type;;


let set_return_type res_type method_context : t = 
    {method_context with res_type};;


(** search the variable within the variables Map, if not found it searches the variable in the params Map *)
let get_variable_type name method_context = 
	match StringMap.find_opt name method_context.variables with
	| Some magdaType -> Some magdaType
	| None -> StringMap.find_opt name method_context.params
;;


let no_params method_context = StringMap.is_empty method_context.params ;;


(** [fold_func key value acc] is used by [to_string] as a fold function for {! StringMap.fold}, 
	[acc] is the accumulator, wich is concatenated with the string made
	from the [key] [value] parameters, theese two represent a key value couple in a [StringMap] witch uses {! Utils.MagdaType.t} as its values.

	This function is not defined in the module interface.
*)
let fold_func key value acc = acc ^ "\t\t\t\t" ^ key ^ " : " ^ (MagdaType.to_string value) ^ "\n"


(** [to_string method_context] uses the [StringMap.fold] function on [method_context.params] and [method_context.variables] 
	concatenating them and then returns the result.
	The fold function used is [fold_func].
*)
let to_string method_context = 
	let params_s = StringMap.fold fold_func method_context.params "" in
	let variables_s = StringMap.fold fold_func method_context.variables "" in
	"\t\t\tparams:\n" ^ params_s ^ "\t\t\tvariables:\n" ^ variables_s;;
