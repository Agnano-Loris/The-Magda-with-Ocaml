type t =
  | Integer
  | Float
  | Bool
  | Byte
  | StringType
  | Object
  | Void
  | MixinType of string


let to_string = function
  | Integer -> "Integer"
  | Float -> "Float"
  | Bool -> "Boolean"
  | Byte -> "Byte"
  | StringType -> "String"
  | Object -> "Object"
  | Void -> "void"
  | MixinType name -> name

let string_to_magdatype = function
  | "Integer" -> Integer
  | "Float" -> Float
  | "Boolean" -> Bool
  | "Byte" -> Byte
  | "String" -> StringType
  | "Object" -> Object
  | "void" -> Void
  | name -> MixinType name