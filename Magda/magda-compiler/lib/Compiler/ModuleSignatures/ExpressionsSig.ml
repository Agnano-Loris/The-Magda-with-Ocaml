open Types
module type MIXIN_EXPR = sig
	type t
	val get_type_exn: EnvTypes.method_environment -> t -> TypeElements.t
	val get_native_type_exn: EnvTypes.method_environment -> t -> TypeElements.t
  val gen_code_for_mixin_expression: Utils.CGenCodeHelper.TempCounter.t option -> EnvTypes.method_environment -> t -> unit
	val print: t -> unit
  val to_string: t -> string
end
