open Utils

type t = {
	mixins_context : MixinContext.t StringMap.t
}

let empty () : t = { mixins_context = StringMap.empty }

let add_mixin name context program_context = 
	let mixins_context = StringMap.add name context program_context.mixins_context in
	{mixins_context}

let contains_mixin mixin_name program_context = StringMap.mem mixin_name program_context.mixins_context

(** Check for cycles in the linked mixins, to do so for every mixin in the [program_context] 
    keeps a set containing the name of the mixins visited called [mixins_met], if a mixin is already
    a member of [mixins_met] then recursively check for every linked_mixin until either a cycle is found or 
    there are no more linked_mixins.
*)
let check_for_cycles program_context = 
    let rec check_mixins mixins_met mixin_name = 
        let linked_mixins = 
                StringMap.find_opt mixin_name program_context.mixins_context
                |> Option.fold ~none:[] ~some:MixinContext.get_linked_mixins in
        if mixin_name == "void" 
            then false 
        else if StringSet.mem mixin_name mixins_met 
            then true
        else
            StringSet.add mixin_name mixins_met 
            |> fun mixins_met -> List.exists (check_mixins mixins_met) linked_mixins in
    StringMap.exists (fun s _ -> check_mixins StringSet.empty s) program_context.mixins_context


let contains_unambiguous_field field_name mixin_name program_context = 
    (* Let declarations with usefull methods get_linked_mixins, contains_field and mixin_context*)
    let mixin_context mixin_name = (StringMap.find_opt mixin_name program_context.mixins_context) in
    (*  contains_field gives you None if there are no mixin_name in program_context, 
        Some true if the mixin contains the field, Some false otherwise. *)
    let contains_field mixin_name field_name =
        Option.map (MixinContext.contains_field field_name) (mixin_context mixin_name) in
    let get_linked_mixins mixin_name = Option.fold ~none:[] ~some:MixinContext.get_linked_mixins (mixin_context mixin_name) in
    let rec contains_unambiguous_field_tree field_name mixin_name =
        let recursive_call mixin_name acc = 
			(* List.fold_left (StringSet.union) (acc : StringSet.t) (linked_mixins_sets : StringSet.t list) applies union to every element of linked_mixins_sets
			linked_mixins_sets.t is obtained by recursive calling contains_unambiguous_field_tree on the linked_mixins*)
        	let linked_mixins_sets = (List.map (contains_unambiguous_field_tree field_name) (get_linked_mixins mixin_name)) in
            List.fold_left (StringSet.union) (acc) linked_mixins_sets in
        match mixin_name, (contains_field mixin_name field_name) with
        | "void", _ -> StringSet.empty
        | _, None -> StringSet.empty
        (* Makes a union operation of the Sets returned by the function contains_unambiguous_field_tree called on all the linked mixins + the set made by the mixin_name*)
        | _, Some true -> recursive_call mixin_name (StringSet.singleton mixin_name)
        (* Same as before but without the set made by the mixin_name*)
        | _, _ -> recursive_call mixin_name (StringSet.empty)
    in 
    match mixin_name, (contains_field mixin_name field_name) with
    | "void", _ -> StringSet.empty
    | _, Some true -> StringSet.singleton mixin_name
    | _, _ -> contains_unambiguous_field_tree field_name mixin_name

(* Same as contains_unambiguous_field but with method instead *)
let contains_unambiguous_method method_name mixin_name program_context = 
    (* Let declarations with usefull methods get_linked_mixins, contains_method and mixin_context*)
    let mixin_context mixin_name = (StringMap.find_opt mixin_name program_context.mixins_context) in
    (*  contains_method gives you None if there are no mixin_name in program_context, 
        Some true if the mixin contains the method, Some false otherwise. *)
    let contains_method mixin_name method_name =
        Option.map (MixinContext.contains_method method_name) (mixin_context mixin_name) in
    let get_linked_mixins mixin_name = Option.fold ~none:[] ~some:MixinContext.get_linked_mixins (mixin_context mixin_name) in
    (*  recursive function that starts on a mixin and is recursively called on the mixin linked_mixins. 
        Ends if the mixin name is "void" or there are no more linked_mixins *)
    let rec contains_unambiguous_method_tree method_name mixin_name =
		let recursive_call mixin_name acc = 
			(* List.fold_left (StringSet.union) (acc : StringSet.t) (linked_mixins_sets : StringSet.t list) applies union to every element of linked_mixins_sets
			linked_mixins_sets.t is obtained by recursive calling contains_unambiguous_field_tree on the linked_mixins*)
			let linked_mixins_sets = List.map (contains_unambiguous_method_tree method_name) (get_linked_mixins mixin_name) in
			List.fold_left (StringSet.union) (acc) linked_mixins_sets in
        match mixin_name, (contains_method mixin_name method_name) with
        | "void", _ -> StringSet.empty
        | _, None -> StringSet.empty
        | _, Some true -> recursive_call mixin_name (StringSet.singleton mixin_name)
        | _, _ -> recursive_call mixin_name StringSet.empty
    in 
    match mixin_name, (contains_method mixin_name method_name) with
    | "void", _ -> StringSet.empty
    | _, Some true -> StringSet.singleton mixin_name
    | _, _ -> contains_unambiguous_method_tree method_name mixin_name
    
let contains_method method_name mixin_name program_context = 
    let mixin_context = (StringMap.find_opt mixin_name program_context.mixins_context) in
    Option.fold ~none:false ~some:(MixinContext.contains_method method_name) mixin_context

let empty_main_program_params program_context =
    let mixin_context = (StringMap.find_opt "MainClass" program_context.mixins_context) in
    Option.fold ~none:false ~some:(MixinContext.empty_main_program_params) mixin_context

let get_inimodule_name params mixin_name program_context =
    let mixin_context = (StringMap.find_opt mixin_name program_context.mixins_context) in
    Option.bind mixin_context (MixinContext.get_inimodule_name params)

let get_field_type field_name mixin_name program_context =
    let mixin_context = (StringMap.find_opt mixin_name program_context.mixins_context) in
    Option.bind mixin_context (MixinContext.get_field_type field_name)

let get_method_return_type method_name mixin_name program_context = 
    let mixin_context = (StringMap.find_opt mixin_name program_context.mixins_context) in
    Option.bind mixin_context (MixinContext.get_method_return_type method_name) 

let get_method_variable_type var_name method_name mixin_name program_context = 
    let mixin_context = (StringMap.find_opt mixin_name program_context.mixins_context) in
    Option.bind mixin_context (MixinContext.get_method_var_type var_name method_name)

let add_all program_context context_to_add =
    let pick_fst _ v1 _ = Some v1 in
    let mixins_context = StringMap.union pick_fst program_context.mixins_context context_to_add.mixins_context in
    {mixins_context}

let to_string program_context = 
    let fold_func key value acc = acc ^ "Mixin : " ^ key ^ (MixinContext.to_string value) ^ "\n" in
    let mixin_list = List.map (Pair.fst) (StringMap.bindings program_context.mixins_context) in
    let mixins_names_s = "Parsed mixins:\n" ^ (String.concat ", " mixin_list) ^  "\n\n" in
	let mixins_s = StringMap.fold fold_func program_context.mixins_context "" in
	mixins_names_s ^ mixins_s