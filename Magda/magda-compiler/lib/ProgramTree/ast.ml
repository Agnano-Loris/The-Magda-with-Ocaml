(** Sum type [binop] has been made so the binary operations in [expression] are less verbose *)
type binop = Add | Div | Eq | Leq | Less | Mul | Neq | StrongEq | Sub


(* The following records are needed for the sum types [method_declaration] and [global_declaration].*)

(*** Let Declarations ***)
and let_decl = {
(** The record [let_decl] contains the following fields:

  [let_name] that is used for the name of the 'let' variable
  
  [bound] that is the expression that follows the '=' keyword.

  Syntax:
  let [let_name] = [bound]
  
  *)

  let_name: string;
  bound: expression;
}



(*** Field Declarations ***)
and field_decl = {
(** The record [field_decl] contains the following fields:

    [field_name] that is used for the name of the field

    [field_type] that is used to express the type of the field.

    Syntax:
    [field_name] : [field_type]
 *)

  field_name: string;
  field_type: mixin_expr;
}

(*** Parameter Declarations ***)
and parameter_decl = {
(** The record [parameter_decl] contains the following fields:

    [param_name] that is used for the name of the parameter

    [param_type] that is used to express the type of the parameter.

    Syntax:
    [param_name] : [param_type]
 *)

  param_name: string;
  param_type: mixin_expr;
}

(*** Init Module Parameters ***)
and init_param = {
(** The record [init_param] contains the following fields:

    [imixin_name] that is used for the name of the mixin

    [iparam_name] that is the name of the parameter. It follows the '.' character

    [ivalue] that is the expression that follows the '=' keyword.

    Syntax:
    [imixin_name].[iparam_name] = [ivalue]
 *)

  imixin_name: string;
  iparam_name: string;
  ivalue: expression;
}

(*** Source Parameters ***)
and source_param = {
(** The record [source_param] are the parameters in input/output.

  The record contains the following fields:

    [mixin_name] that is used for the name of the mixin

    [param_name] that is the name of the parameter. It follows the '.' character

    [source_type] explains if the parameter is an input or output parameter.

    Syntax:
    [mixin_name].[param_name] : [source_type]
  *)

  mixin_name: string;
  param_name: string;
  source_type: mixin_expr;
}

(** Variable Declarations ***)
and variable_decl = { 
(** The record [variable_decl] contains the following fields:

    [var_name] that is used for the name of the variable
    
    [var_type] that is used to express the type of the variable.

    Syntax:
    [var_name] : [var_type]
  *)

  var_name: string;
  var_type: mixin_expr;
}

(*** Polymorphism ***)
and polymorphism_param = {
(** The record [polymorphism_param] is used to define polymorphic parameters in [mixin_decl]. 
    
    The record contains the following fields:

    [poly_name] that is the name of the polymorphic parameter

    [bound] that is the [mixin_expr] that follows the '<=' keyword.

    Syntax:
    [poly_name] <= [bound]
 *)
  poly_name: string;
  bound: mixin_expr;
}

(*** Method Body ***)
and method_body = {
(** The record [method_body] is the body of a [NewMethod] or [OverrideMethod].

  The record contains the following fields:

  [method_local_variables] that is a list of variable declarations that are local to the method.
  [method_instructions] that is a list of instructions between the 'begin' and 'end' keywords.

  Syntax used in [NewMethod]:

  new [method_name] ([params])
  
  [method_local_variables]

      begin

            [method_instructions]
  
      end
*)
  method_local_variables: variable_decl list;
  method_instructions: instruction list;
}

(*** Ini Module super ***)
and ini_module_super = {
(** The record [ini_module_super] is the supercall of the inimodule. It contains the following fields:

    [super_name] that is the name of the super mixin

    [super_params] that is a list of [init_param]s.

    Syntax:
    super [super_name] ([super_params])
 *)
  super_name: string;
  super_params: init_param list;
}

(*** Ini Module Body ***)
and ini_module_body = {
(** The record [ini_module_body] is the body of an [ini_module_decl].
    
  The record contains the following fields:

  [ini_module_variables] that is a list of [variable_decl]s that are local to the ini module.

  [ini_module_instructions_precall] that is a list of [instruction]s between the 'begin' the [ini_module_super] call.

  [ini_module_super] that is the super call of the ini module. 

  [ini_module_instructions_postcall] that is a list of [instruction]s between the [ini_module_super] call and the 'end' keyword.

  Syntax:
  
  [ini_module_variables]

    begin

          [ini_module_instructions_precall]

          super \[[ini_module_super]\]

          [ini_module_instructions_postcall]

    end


  *)
  ini_module_variables: variable_decl list;
  ini_module_instructions_precall: instruction list;
  ini_module_super: ini_module_super;
  ini_module_instructions_postcall: instruction list;
}

(*** Ini Module Declarations ***)
and ini_module_decl = {
(** The record [ini_module_decl] is the declaration of an ini module.
  The record contains the following fields:
  
     [in_params] that is a list of [source_param]s that are the input parameters of the ini module.

     [out_params] that is a list of [source_param]s that are the output parameters of the ini module.

     [ini_module_body] that is the body of the ini module.

*)
  in_params: source_param list;
  out_params: source_param list;
  ini_module_body: ini_module_body;
}

(*** Mixin Declarations ***)
and mixin_decl = {
(** The record [mixin_decl] contains the following fields:

    [mixin_name] that is the name of the mixin

    [mixin_polymorphism_params] that is a list of [polymorphism_param]s
    
    [mixin_fields] that is a list of [field_decl]s

    [mixin_new_methods] that is a list of [method_declaration]s that are [NewMethod]s

    [mixin_override_methods] that is a list of [method_declaration]s that are [OverrideMethod]s

    [mixin_ini_module] that is a list of [ini_module_decl]s
*)
  mixin_name: string;
  mixin_polymorphism_params: polymorphism_param list;
  mixin_fields: field_decl list;
  mixin_new_methods: method_declaration list;
  mixin_override_methods: method_declaration list;
  mixin_ini_module: ini_module_decl list;
}

and abstract_method = {
(** The record [abstract_method] is used to express the abstract methods of a mixin. It contains the following fields:

    [abstract_method_name] that is the name of the abstract method

    [abstract_method_params] that is a list of [parameter_decl]s that are the parameters of the abstract method

    [abstract_method_return_type] that is a [mixin_expr] that returns the type of the abstract method

    Syntax:
    abstract [abstract_method_return_type] [abstract_method_name] ([abstract_method_params])
*)
  abstract_method_name: string;
  abstract_method_params: parameter_decl list;
  abstract_method_return_type: mixin_expr;
}

and new_method = {
(** The record [new_method] is used to express the new methods of a mixin. It contains the following fields:

    [new_method_name] that is the name of the new method

    [new_method_params] that is a list of [parameter_decl]s that are the parameters of the new method

    [new_method_return_type] that is a [mixin_expr] that returns the type of the new method

    [new_method_body] that is a [method_body] that contains the body of the new method

    Syntax:
    new [new_method_return_type] [new_method_name] ([new_method_params])
    [new_method_body]
*)
  new_method_name: string; 
  new_method_params: parameter_decl list;
  new_method_return_type: mixin_expr;
  new_method_body: method_body;
}

and override_method = {
(** The record [override_method] is used to express the override methods of a mixin. It contains the following fields:

    [override_method_name] that is the name of the override method

    [override_method_mixin_overridden] that is the name of the mixin that is being overridden

    [override_method_params] that is a list of [parameter_decl]s that are the parameters of the override method

    [override_method_return_type] that is a [mixin_expr] that returns the type of the override method

    [override_method_body] that is a [method_body] that contains the body of the override method

    Syntax:
    override [override_method_return_type] [override_mixin_overridden].[override_method_name] ([override_method_params])
    [override_method_body]
*)
  override_method_name: string;
  override_method_mixin_overridden: string;
  override_method_params: parameter_decl list;
  override_method_return_type: mixin_expr;
  override_method_body: method_body;
}

and object_creation = {
(** The record [object_creation] is used to express the object creation expression. It contains the following fields:

    [object_creation_mixin_expr] that is a [mixin_expr] that expresses the type of the object being created

    [object_creation_init_params] that is a list of [expression]s that are the parameters of the object creation

    Syntax:
    new [object_creation_mixin_expr] ([object_creation_init_params])
*)
  object_creation_mixin_expr: mixin_expr;
  object_creation_init_params: expression list;
}

and field_selection = {
(** The record [field_selection] is used to express the field selection expression. It contains the following fields:

    [field_selection_target] that is an [expression] that follows the '=' character

    [field_selection_mixin_name] that is the name of the mixin that contains the field being selected

    [field_selection_field_name] that is the name of the field being selected

    Syntax:
    [field_selection_mixin_name].[field_selection_field_name] = [field_selection_target]
*)
  field_selection_target: expression;
  field_selection_mixin_name: string;
  field_selection_field_name: string;
}

and method_call = {
(** The record [method_call] is used to express the method call expression. It contains the following fields:

    [method_call_target] that is an [expression]. This should be written before the '=' character

    [method_call_mixin_name] that is the name of the mixin that contains the method being called

    [method_call_method_name] that is the name of the method being called

    [method_call_params] that is a list of [expression]s that are the parameters of the method call

    Syntax:
    [method_call_target] = [method_call_mixin_name].[method_call_method_name] ([method_call_params])
*)
  method_call_target: expression;
  method_call_mixin_name: string;
  method_call_method_name: string;
  method_call_params: expression list;
}

and while_instruction = {
(** The record [while_instruction] is used to express the while instruction. It contains the following fields:

    [while_condition] that is an [expression] inside the parentheses of the while instruction

    [while_instructions] that is a list of [instruction]s before the 'end' keyword

    Syntax:
    while ([while_condition])
      [while_instructions]
    end;
*)
  while_condition: expression;
  while_instructions: instruction list;
}

and if_instruction = {
(** The record [if_instruction] is used to express the if instruction. It contains the following fields:

    [if_condition] that is an [expression] inside the parentheses of the if instruction

    [if_true_instructions] that is a list of [instruction]s before the 'else' or 'end' keyword, depending on whether there is an 'else' block or not.

    [if_false_instructions] that is a list of [instruction]s before the 'end' keyword. This can be empty.

    Syntax:
    if ([if_condition])
      [if_true_instructions]
    else [if_false_instructions]
    end;
*)
  if_condition: expression;
  if_true_instructions: instruction list;
  if_false_instructions: instruction list;
}

and ini_module_super_instruction = {
(** The record [ini_module_super_instruction] is used to express the super call of an ini module. It contains the following fields:

[ini_module_super_params] that is a list of [expression]s that are the parameters of the super call
*)
  ini_module_super_params: expression list;
}

and mixin_expr_concat = {
(** The record [mixin_expr_concat] is used to express the concatenation of two mixin expressions. It contains the following fields:

    [left_mixin] that is a [mixin_expr] that is on the left side of the ',' character

    [right_mixin] that is a [mixin_expr] that is on the right side of the ',' character

    Syntax:
    [left_mixin] , [right_mixin]
*)
  left_mixin: mixin_expr;
  right_mixin: mixin_expr;
}

and mixin_expr_application = {
(** The record [mixin_expr_application] is used to express the application of a mixin to a mixin expression. It contains the following fields:

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
(** The record [field_lvalue] is used to express the field lvalue. It contains the following fields:

    [field_lvalue_mixin_name] that is the name of the mixin that contains the field being assigned

    [field_lvalue_field_name] that is the name of the field being assigned

    Syntax:
    [field_lvalue_mixin_name].[field_lvalue_field_name]
*)
  field_lvalue_mixin_name: string;
  field_lvalue_field_name: string;
}

(*** Sum types created from the interfaces ***)

(*** Mixin Expressions ***)
and mixin_expr =
(** A [mixin_expr] is used to express the type of declarations such as variables, parameters, fiels and return.

  A [mixin_expr] can be [MixinExpressionVoid] or [MixinExpressionId]. 
  
  It can be combined with other [mixin_expr]s using [MixinExpressionConcat].

  It can also be an application of a mixin to a [mixin_expr] using [MixinExpressionApplication].
*)
  | MixinExpressionId of string
  | MixinExpressionConcat of mixin_expr_concat
  | MixinExpressionApplication of mixin_expr_application
  | MixinExpressionVoid

(*** LValues ***)
and lvalue =
(** A [lvalue] is a reference to a location in memory.
  It is used in the assignment instruction right before the ':=' operator.
  
  It can be either a variable [VariableLValue] or a field [FieldLValue].

  Syntax for [FieldLValue]:
  [mixin_name].[field_name]
  *)

  | VariableLValue of string
  | FieldLValue of field_lvalue

(*** Instructions ***)
and instruction =
(** An [instruction] is one of the operations expressed in the guards.
  There is no need of 'instruction option' since an instruction can be an ExprInstruction
  and an ExprInstruction can be a NullExpression *)
  | Assignment of lvalue * expression
  | ExprInstruction of expression
  | IfInstruction of if_instruction
  | IniModuleSuperInstruction of ini_module_super_instruction
  | NativeInstruction of string
  | ReturnInstruction of expression
  | WhileInstruction of while_instruction

(*** Expressions ***)
and expression =
(** An [expression] is one of the operations expressed in the guards.
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


(*** Declarations ***)
(** A [global_declaration] is either a [mixin_decl] or a [let_decl] statement *)
and global_declaration =
  | MixinDecl of mixin_decl
  | LetDecl of let_decl
  | PolymorphismDecl of polymorphism_param (* THIS SHOULD NEVER BE A CASE BUT WE NEED THIS FOR GlobalDeclaration.ml 
   BEPPE VESSICCHIO *)

(*** Method Declaration ***)
and method_declaration =
  (** A [method_declaration] is a bodyless abstract [AbstactMethod] or a concrete [NewMethod] or an override of an existing mixin [OverrideMethod]*)
  | AbstractMethod of abstract_method
  | NewMethod of new_method
  | OverrideMethod of override_method

(*** Program ***)
(** The [program] is a list of [global_declaration]s*)
and program = global_declaration list

