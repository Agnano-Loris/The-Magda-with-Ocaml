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
