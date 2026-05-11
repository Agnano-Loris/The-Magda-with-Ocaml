(** Types representing the Magda type system.
    Used to identify the type of variables, parameters, fields and method return values
*)

type t =
  | Integer               (** Integer numeric type *)
  | Float                 (** Floating-point numeric type *)
  | Bool                  (** Boolean type *)
  | Byte                  (** Byte type *)
  | StringType            (** String type *)
  | Object                (** Base object type *)
  | Void                  (** Void return type *)
  | MixinType of string   (** User-defined mixin type *)
  

val to_string : t -> string
(** [to_string magda_type] returns the string rapresentation of [magda_type], variable of type [t]

@param magda_type the Magda type to convert
@returns the string rapresentation of [magda_type]
*)