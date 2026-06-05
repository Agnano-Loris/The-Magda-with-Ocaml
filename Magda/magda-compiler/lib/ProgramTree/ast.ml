type binop = Add | Div | Eq | Leq | Less | Mul | Neq | StrongEq | Sub


and let_decl = {

  let_name: string;
  bound: mixin_expr;
}



and field_decl = {

  field_name: string;
  field_type: mixin_expr;
}
and parameter_decl = {

  param_name: string;
  param_type: mixin_expr;
}

and init_param = {
  imixin_name: string;
  iparam_name: string;
  ivalue: expression;
}

and source_param = {
  mixin_name: string;
  param_name: string;
  source_type: mixin_expr;
}

and variable_decl = { 
  var_name: string;
  var_type: mixin_expr;
}

and polymorphism_param = {
  poly_name: string;
  bound: mixin_expr;
}

and method_body = {
  method_local_variables: variable_decl list;
  method_instructions: instruction list;
}

and ini_module_super = {
  super_name: string;
  super_params: init_param list;
}

and ini_module_body = {
  ini_module_variables: variable_decl list;
  ini_module_instructions_precall: instruction list;
  ini_module_super: ini_module_super;
  ini_module_instructions_postcall: instruction list;
}

and ini_module_decl = {
  is_required: bool;
  in_params: source_param list;
  out_params: source_param list;
  ini_module_body: ini_module_body;
}

and mixin_decl = {
  mixin_name: string;
  mixin_parent: mixin_expr;
  mixin_polymorphism_params: polymorphism_param list;
  mixin_fields: field_decl list;
  mixin_new_methods: method_declaration list;
  mixin_override_methods: method_declaration list;
  mixin_ini_module: ini_module_decl list;
}

and abstract_method = {

  abstract_method_name: string;
  abstract_method_params: parameter_decl list;
  abstract_method_return_type: mixin_expr;
}

and new_method = {
  new_method_name: string; 
  new_method_params: parameter_decl list;
  new_method_return_type: mixin_expr;
  new_method_body: method_body;
}

and override_method = {
  override_method_name: string;
  override_method_mixin_overridden: string;
  override_method_params: parameter_decl list;
  override_method_return_type: mixin_expr;
  override_method_body: method_body;
}

and object_creation = {
  object_creation_mixin_expr: mixin_expr;
  object_creation_init_params: init_param list;
}

and field_selection = {
  field_selection_target: expression;
  field_selection_mixin_name: string;
  field_selection_field_name: string;
}

and method_call = {

  method_call_target: expression;
  method_call_mixin_name: string;
  method_call_method_name: string;
  method_call_params: expression list;
}

and while_instruction = {

  while_condition: expression;
  while_instructions: instruction list;
}

and if_instruction = {

  if_condition: expression;
  if_true_instructions: instruction list;
  if_false_instructions: instruction list;
}

and ini_module_super_instruction = {

  ini_module_super_init_params: init_param list;
}

and mixin_expr_concat = {
(* The record [mixin_expr_concat] is used to express the concatenation of two mixin expressions. It contains the following fields:

    [left_mixin] that is a [mixin_expr] that is on the left side of the ',' character

    [right_mixin] that is a [mixin_expr] that is on the right side of the ',' character

    Syntax:
    [left_mixin] , [right_mixin]
*)
  left_mixin: mixin_expr;
  right_mixin: mixin_expr;
}

and mixin_expr_application = {
(* The record [mixin_expr_application] is used to express the application of a mixin to a mixin expression. It contains the following fields:

    [mixin_name] that is the name of the mixin being applied

    [param_name] that is the name of the parameter being applied. It follows the '.' character

    [value] that is a [mixin_expr] that is the value being applied to the parameter

    Syntax:
    [mixin_name] . [param_name] = ([value])
*)
  mixin_name: string;
  param_name: string;
  value: mixin_expr;
}

and field_lvalue = {
(* The record [field_lvalue] is used to express the field lvalue. It contains the following fields:

    [field_lvalue_mixin_name] that is the name of the mixin that contains the field being assigned

    [field_lvalue_field_name] that is the name of the field being assigned

    Syntax:
    [field_lvalue_mixin_name].[field_lvalue_field_name]
*)
  field_lvalue_mixin_name: string;
  field_lvalue_field_name: string;
}

(* Sum types created from the interfaces ***)

(* Mixin Expressions ***)
and mixin_expr =
(* A [mixin_expr] is used to express the type of declarations such as variables, parameters, fiels and return.

  A [mixin_expr] can be [MixinExpressionVoid] or [MixinExpressionId]. 
  
  It can be combined with other [mixin_expr]s using [MixinExpressionConcat].

  It can also be an application of a mixin to a [mixin_expr] using [MixinExpressionApplication].
*)
  | MixinExpressionId of string
  | MixinExpressionConcat of mixin_expr_concat
  | MixinExpressionApplication of mixin_expr_application
  | MixinExpressionVoid

(* LValues ***)
and lvalue =
(* A [lvalue] is a reference to a location in memory.
  It is used in the assignment instruction right before the ':=' operator.
  
  It can be either a variable [VariableLValue] or a field [FieldLValue].

  Syntax for [FieldLValue]:
  [mixin_name].[field_name]
  *)

  | VariableLValue of string
  | FieldLValue of field_lvalue

(* Instructions ***)
and instruction =
(* An [instruction] is one of the operations expressed in the guards.
  There is no need of 'instruction option' since an instruction can be an ExprInstruction
  and an ExprInstruction can be a NullExpression *)
  | Assignment of lvalue * expression
  | ExprInstruction of expression
  | IfInstruction of if_instruction
  | IniModuleSuperInstruction of ini_module_super_instruction
  | NativeInstruction of string
  | ReturnInstruction of expression
  | WhileInstruction of while_instruction

(* Expressions ***)
and expression =
(* An [expression] is one of the operations expressed in the guards.
  There is no need of 'expression option' since an expression can be a NullExpression.
*)
  | ThisExpression
  | NullExpression
  | IntegerLiteral of int
  | BooleanLiteral of bool
  | FloatLiteral of float
  | ByteLiteral of string
  | StringLiteral of string
  | Identifier of string
  | SuperExpression of expression list
  | MethodCallExpression of method_call
  | FieldSelectExpression of field_selection
  | ObjectCreationExpression of object_creation
  | BinaryOperation of binop * expression * expression


(* Declarations ***)
(* A [global_declaration] is either a [mixin_decl] or a [let_decl] statement *)
and global_declaration =
  | MixinDecl of mixin_decl
  | LetDecl of let_decl
  (* BEPPE VESSICCHIO *)

(* Method Declaration ***)
and method_declaration =
  (* A [method_declaration] is a bodyless abstract [AbstactMethod] or a concrete [NewMethod] or an override of an existing mixin [OverrideMethod]*)
  | AbstractMethod of abstract_method
  | NewMethod of new_method
  | OverrideMethod of override_method

(* Program ***)
(** The [program] is a list of [global_declaration]s*)
and program = global_declaration list
