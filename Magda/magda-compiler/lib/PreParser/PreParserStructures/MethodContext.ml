(** Implements the MethodContext by using a string option reference for the string types,
	and for the params and variables it uses OCaml's [Hashtbl] module instantiated with [String] keys and containing [String] values.
*)

module StringTable = Hashtbl.Make(String)

type t = {
	params : string StringTable.t;
	(** Formal parameters table: parameter_name -> parameter_type *)
	variables : string StringTable.t;
	(** Local variables table: variable_name -> variable_type *)
	res_type : string option ref
	(** Mutable reference of the return type, initially [None] *)
}

let create () : t = 
	let expected_entries = 8 in
	{
		params = StringTable.create expected_entries;
		variables = StringTable.create expected_entries;
		res_type = ref (None : string option)
	}
(** [create] creates pre-sized tables to 8 entries, and initialize res_type to [None] *)

(** [add_variable] uses [StringTable.replace] to add the variable*)
let add_variable method_context name var_type = StringTable.replace method_context.variables name var_type ;;

(** [add_param] uses [StringTable.replace] to add the parameter*)
let add_param method_context name param_type = StringTable.replace method_context.params name param_type ;;

let get_return_type method_context = !(method_context.res_type);;

let set_return_type method_context new_res_type = method_context.res_type := Some new_res_type;;

(** [get_variable_type] uses [StringTable.find_opt] to search the variable type *)
let get_variable_type method_context variable_name = 
	match StringTable.find_opt method_context.variables variable_name with
	| Some str -> Some str
	| None -> StringTable.find_opt method_context.params variable_name
;;

let no_params method_context = StringTable.length method_context.params = 0 ;;

(** [fold_func key value acc] is used by [to_string] as a fold function for [StringTable.fold], 
	[acc] is the accumulator, wich is concatenated with the string made
	from the [key] [value] parameters, theese two represent a key value couple in a [StringTable].

	This function is not defined in the module interface.
*)
let fold_func key value acc = acc ^ "\t\t\t\t" ^ key ^ " : " ^ value ^ "\n"

(** [to_string method_context] uses the [StringTable.fold] function on [method_context.params] and [method_context.variables] 
		concatenating them and then returns the result.
		The fold function used is [fold_func].
	*)
let to_string method_context = 
	let params_s = StringTable.fold fold_func method_context.params "" in
	let variables_s = StringTable.fold fold_func method_context.variables "" in
	"\t\t\tparams:\n" ^ params_s ^ "\t\t\tvariables:\n" ^ variables_s;;
