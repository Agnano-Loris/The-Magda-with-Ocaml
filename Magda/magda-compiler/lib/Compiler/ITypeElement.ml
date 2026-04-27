(** Ducumentation to do in later phases of the project *)
module type ITypeElement = sig
  type t
  val get_name : t -> string
  val get_caption : t -> string
  val get_applications : CPolyApplicationValues.t -> CMethodEnvironment.t
end