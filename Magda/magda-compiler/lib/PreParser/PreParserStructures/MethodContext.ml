(* Test : creo due moduli che rappresentano le hashtable del methodContext*)

module StringTable = Hashtbl.Make(struct
	type t = string
	let equal = String.equal
	let hash = Hashtbl.hash
end)

type t = {
	params : string StringTable.t;
	variables : string StringTable.t;
	res_type : string option ref
}

let create () : t = 
	let expected_entries = 5 in
	{
		params = StringTable.create expected_entries;
		variables = StringTable.create expected_entries;
		res_type = ref (None : string option)
	}

let add_variable (context : t) name var_type = StringTable.add context.variables name var_type ;;

let add_param (context : t) name param_type = StringTable.add context.params name param_type ;;

let get_return_type (context : t) = !(context.res_type);;

let set_res_type (context : t) new_res_type = context.res_type := new_res_type;;

let get_variable_type (context : t) variable_name = 
	match StringTable.find_opt context.variables variable_name with
	| Some str -> Some str
	| None -> StringTable.find_opt context.params variable_name
;;

let no_params (context : t) = StringTable.length context.params = 0 ;;

let to_string (context : t) = 
	let fold_func key value acc = acc ^ "\t\t\t\t" ^ key ^ " : " ^ value ^ "\n" in 
	(* String obtained from a key , value couple *)
	let params_s = StringTable.fold fold_func context.params "" in
	(* Concatenate every params value *)
	let variables_s =StringTable.fold fold_func context.variables "" in
	(* Concatenate every variables value *)
	"\t\t\tparams:\n" ^ params_s ^ "\t\t\tvariables:\n" ^ variables_s;;
	(* Puts toghether the results *)