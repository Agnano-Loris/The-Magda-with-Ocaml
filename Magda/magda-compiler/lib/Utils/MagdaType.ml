type t =
  | Integer
  | Float
  | Bool
  | Byte
  | StringType
  | Object
  | Void
  | MixinType of string
  | Composite of string list


let to_string = function
  | Integer -> "Integer"
  | Float -> "Float"
  | Bool -> "Boolean"
  | Byte -> "Byte"
  | StringType -> "String"
  | Object -> "Object"
  | Void -> "void"
  | MixinType name -> name
  | Composite names -> String.concat ", " names

let string_to_magdatype = function
  | "Integer" -> Integer
  | "Float" -> Float
  | "Boolean" -> Bool
  | "Byte" -> Byte
  | "String" -> StringType
  | "Object" -> Object
  | "void" -> Void
  | name -> MixinType name

  (** [names t] returns the mixin names [t] refers to: one for a simple type, all of them for a composite type. *)
 let names = function
  | Composite names -> names
  | t -> [to_string t] 