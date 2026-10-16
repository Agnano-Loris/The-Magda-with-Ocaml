(** GenCodeHelper is a module that contains utility function to generate code.
	It contains a mutable string called [tabs_strings] wich contains a number of \t characters
	and can be interacted with [get_tab] [add_tab] and [remove_tab] 
*)

(** [get_tab ()] returns the string stored by [tabs_strings]*)
val get_tab : unit -> string

(** [add_tab ()] returns the string stored by [tabs_strings] with a \t character added *)
val add_tab : unit -> string

(** [remove_tab ()] retuns the string stored by [tabs_strings] with one less \t character*)
val remove_tab : unit -> string

(** [clear_tab ()] clears [tab_strings] then retuns the previous string value*)
val clear_tab : unit -> string

(** TempCounter implements a temporary {b Integer} counter with some utility function*)
module TempCounter :
	sig
		(** Represents the temporary counter, [t] is mutable*)
		type t

		(** [start_counter ()] start a counter and returns it*)
		val start_counter : unit -> t

		(** [get_temp temp_counter] returns the integer value of the counter, then adds 1 to the [temp_counter] counter*)
		val get_temp : t -> int

		(** [temp_acc temp_counter] returns a string {"temp["^ x ^"]"} where [x] is the int value of [temp_counter] *)
		val temp_acc : t -> string
	end
