open Types
module type MIXIN_EXPR = sig
	type t
	val get_type_exn: EnvTypes.method_environment -> t -> TypeElements.t
	val get_native_type_exn: EnvTypes.method_environment -> t -> TypeElements.t
    val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> EnvTypes.method_environment -> t -> unit
	val print: t -> unit
end
