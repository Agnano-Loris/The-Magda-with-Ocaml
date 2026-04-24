let tabs_strings = ref ""

let get_tab () = !tabs_strings

let add_tab () = tabs_strings := !tabs_strings ^ "\t";get_tab ()

let remove_tab () = 
	let string_len = String.length !tabs_strings in 
	if string_len > 0 then
		tabs_strings := String.sub !tabs_strings 0 (string_len - 1)
	;get_tab ()

let clear_tab () = 
	let string_value = !tabs_strings in 
	tabs_strings := "";string_value

module TempCounter = struct
  type t = int ref
  let start_counter () : t = ref 0
  let get_temp (temp_counter : t) = 
	let ret = !temp_counter in
		temp_counter := !temp_counter + 1;
		ret
	let temp_acc (temp_counter : t) = "temp[" ^ string_of_int !temp_counter ^ "]"
end
