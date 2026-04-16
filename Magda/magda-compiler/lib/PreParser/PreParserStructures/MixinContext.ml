open Utils

module StringSet = Set.Make(String)
module StringMap = Map.Make(String)

(** Type containing the data of the MixinContext*)
type t = {

	linked_mixins : string List.t; (** String {! List.t} of Mixins linked to the mixin*)

	methods_context : MethodContext.t StringMap.t; (** [StringMap.t] containing the method contexts, method_name -> method_context *)
	
	fields : MagdaType.t StringMap.t; (** Local fields of the mixin field_name -> field_type *)

	inimodules_namespace : string StringMap.t; (** [StringMap.t] containing the name of the inimodules, inimodule_first_param -> inimodule_name,
		since there can't be two inimodule params with the same name in the same mixin
		the first parameter of an inimodule can be used as an id to access the inimodule name
	*)
	
	inimodules_params : StringSet.t; (** A [StringSet.t] containing all the inimodules params names, used to check if there are duplicate params in the inimodules *)

}

(** creates a [MixinContext.t] type record with all its fields set to empty *)
let empty () : t =
  {
	linked_mixins = [];
	methods_context = StringMap.empty;
	fields = StringMap.empty;
	inimodules_namespace = StringMap.empty;
	inimodules_params = StringSet.empty
  }

let add_method name context mixin_context =
	let methods_context = StringMap.add name context mixin_context.methods_context in
	{mixin_context with methods_context}

(** Searches the inimodule name given its parameters, to get the name it searches by using the first parameters
	if the params list is empty it uses the "" string as key
*)
let get_inimodule_name params mixin_context = 
	match params with
	| x :: _ -> StringMap.find_opt x mixin_context.inimodules_namespace
	| [] -> StringMap.find_opt "" mixin_context.inimodules_namespace

(** Checks by recursively cycling the params list of the inimodule,
    if a param with the same name was added in [inimodules_params] returns [Error x],
    where x is the param checked, otherwise it adds it to the
    [inimodules_params] Set and continues the cycle.
    At the end if no duplicate params occoured it returns [Ok inimodules_params]

    This function is not defined in the module interface.
*)
let rec check_duplicates params inimodules_params = 
    match params with
    | [] -> Ok inimodules_params
    | x :: xs -> 
        match StringSet.mem x inimodules_params with
        | true -> Error x
        | false -> StringSet.add x inimodules_params |> check_duplicates xs;;

(** Calls [check_duplicates] to check for duplicate params, and to 
    update the [inimodules_params] Set.
    If a duplicate was found returns [Error e] where e is the duplicated parameter.

    Otherwise if no duplicate was found, it creates the inimodule namespace and adds it to the [inimodules_namespace] StringMap 
    using the first parameter of the inimodule as key,
    adds the method context of the inimodule to the [methods_context] StringMap,
    and lastly returns the updated mixin_context as [Ok mixin_context].
*)
let add_inimodule params method_context mixin_context = 
    match check_duplicates params mixin_context.inimodules_params with
    | Error e -> Error e
    | Ok inimodules_params -> 
        let namespace = "initialize " ^ string_of_int (StringMap.cardinal mixin_context.inimodules_namespace) in
        let inimodules_namespace = StringMap.add (List.hd params) namespace mixin_context.inimodules_namespace in
        let methods_context = StringMap.add namespace method_context mixin_context.methods_context in
        Ok { mixin_context with inimodules_namespace;methods_context;inimodules_params}


let contains_method method_name mixin_context = StringMap.mem method_name mixin_context.methods_context

let contains_field field_name mixin_context = StringMap.mem field_name mixin_context.fields

let empty_main_program_params mixin_context = 
    match StringMap.find_opt "mainProgram" mixin_context.methods_context with
    | Some method_context -> MethodContext.no_params method_context
    | None -> false

let add_field field_name field_type mixin_context = 
    let fields = StringMap.add field_name field_type mixin_context.fields in 
    {mixin_context with fields}

let add_linked_mixin name mixin_context = 
    let linked_mixins = name :: mixin_context.linked_mixins in
    {mixin_context with linked_mixins}


let get_field_type field_name mixin_context = StringMap.find_opt field_name mixin_context.fields

let get_method_return_type method_name mixin_context = 
    let method_context_opt = StringMap.find_opt method_name mixin_context.methods_context in
    Option.bind method_context_opt (MethodContext.get_return_type)

let get_method_var_type var_name method_name mixin_context =
    let method_context_opt = StringMap.find_opt method_name mixin_context.methods_context in
    Option.bind method_context_opt (MethodContext.get_variable_type var_name)

(** [fold_func key value acc] is used by [to_string] as a fold function for [StringMap.fold], 
	[acc] is the accumulator, wich is concatenated with the string made from the [key] [value] parameters, 
    theese two represent a key value couple in a [StringMap] witch uses [MagdaType.t] as its values.

	This function is not defined in the module interface.
*)
let fold_func key value acc = acc ^ "\t\t" ^ key ^ " : " ^ (MagdaType.to_string value) ^ "\n"

(** Same concept as [fold_func] but with [MethodContext.t] as [value] 
    {! Option.fold} is used to get the string value of the return type,
    if [MethodContext.get_return_type value] returns [None] the string is "",
    otherwise if returns [Some s] the string is set to [MagdaType.to_string s].
*)
let fold_func2 key value acc =
    let string_value = Option.fold ~none:"" ~some:MagdaType.to_string (MethodContext.get_return_type value) in
    acc ^ "\t\t" ^ key ^ " : " ^ string_value ^ "\n" ^ MethodContext.to_string value

let to_string mixin_context = 
    let linked_mixins_s = "List: [" ^ (String.concat ", " mixin_context.linked_mixins) ^ "]" in
	let fields_s = StringMap.fold fold_func mixin_context.fields "" in
	let methods_s = StringMap.fold fold_func2 mixin_context.methods_context "" in
	" " ^ linked_mixins_s ^ "\n" ^ "\tfields:\n" ^ fields_s ^ "\tmethods:\n" ^ methods_s;;

