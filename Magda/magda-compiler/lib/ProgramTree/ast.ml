(** Source range of a node, imported from {!Utils.Errors} *)
type span = Utils.Errors.span

(** The node paired with its source location, imported from {!Utils.Errors} *)
type 'a located = 'a Utils.Errors.located = {
  value : 'a;
  loc: span
}

(** Sum type [binop] has been made so the binary operations in [expression] are less verbose.
  Operations [Gt] and [Geq] doesn't exist, they are replaced with [Less] and [Leq]*)
type binop = Add | Div | Eq | Leq | Less | Mul | Neq | StrongEq | Sub


(* The following records are needed for the sum types [method_declaration] and [global_declaration].*)

(*** Let Declarations ***)

(** The record [let_decl] contains the following fields:

  [let_name] that is used for the name of the 'let' variable
  
  [let_bound] that is the [mixin_expr] that follows the '=' keyword.

  Syntax:
  let [let_name] = [let_bound]*)
and let_decl = {
  let_name: string;
  let_bound: mixin_expr
}


(*** Field Declarations ***)

(** The record [field_decl] contains the following fields:

    [field_name] that is used for the name of the field

    [field_type] that is used to express the type of the field.

    [field_loc] is the position of the declaration.

    Syntax:
    [field_name] : [field_type]
*)
and field_decl = {
  field_name: string;
  field_type: mixin_expr;
  field_loc: span
}

(*** Parameter Declarations ***)

(** The record [parameter_decl] contains the following fields:

    [param_name] that is used for the name of the parameter

    [param_type] that is used to express the type of the parameter.

    Syntax:
    [param_name] : [param_type]
*)
and parameter_decl = {
  param_name: string;
  param_type: mixin_expr
}

(*** Init Module Parameters ***)

(** The record [init_param] contains the following fields:

    [imixin_name] that is used for the name of the mixin

    [iparam_name] that is the name of the parameter. It follows the '.' character

    [ivalue] that is the expression that follows the '=' keyword.

    Syntax:
    [imixin_name].[iparam_name] = [ivalue]
*)
and init_param = {
  imixin_name: string;
  iparam_name: string;
  ivalue: expression
}

(*** EX-Source Parameters, splitted in [input_parameters] and [output_parameters] ***)

(*** Input parameters ***)

(** An [input_param] of a [ini_module_decl] contains the following fields:

    [input_param] represents the mixin denominated in the module header, imported from [cst_to_ast]

    [input_param_name] denomination of the input parameter

    [input_param_type] type [mixin_expr] for the input parameter

    Syntax:

      [input_param_name] : [input_param_type]
*)
and input_param = {
  input_param_mixin: string;
  input_param_name: string;
  input_param_type: mixin_expr
}

(*** Output paramaters ***)

(** An [output_param] is the parameter obtained through the super call to this module. The result
  doesn't carry its type, just the name. Fields:

    [output_param_mixin] mixin denomination imported from [cst_to_ast]

    [output_param_name] denomination of the parameter
  *)
and output_param = {
  output_param_mixin: string;
  output_param_name: string
}

(*** Variable Declarations ***)

(** The record [variable_decl] contains the following fields:

    [var_name] that is used for the name of the variable
    
    [var_type] that is used to express the type of the variable.

    Syntax:
    [var_name] : [var_type]
*)
and variable_decl = { 
  var_name: string;
  var_type: mixin_expr
}

(*** Polymorphism ***)

(** The record [polymorphism_param] is used to define polymorphic parameters in [mixin_decl]. 
    
    The record contains the following fields:

    [poly_name] that is the name of the polymorphic parameter

    [poly_bound] that is the [mixin_expr] that follows the '<=' keyword.

    Syntax:
    [poly_name] <= [poly_bound]
*)
and polymorphism_param = {
  poly_name: string;
  poly_bound: mixin_expr
}

(*** Method Body ***)

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
and method_body = {
  method_local_variables: variable_decl list;
  method_instructions: instruction located list
}

(*** Ini Module super ***)

(** The record [ini_module_super] is the super call of the inimodule. It contains the following fields:

    [super_params] that is a list of [init_param]s.

    [super_loc] position of the super call.

    Syntax:
    super [ [super_params] ]
*)
and ini_module_super = {
  super_params: init_param list;
  super_loc: span
}

(*** Ini Module Body ***)

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
and ini_module_body = {
  ini_module_variables: variable_decl list;
  ini_module_instructions_precall: instruction located list;
  ini_module_super: ini_module_super;
  ini_module_instructions_postcall: instruction located list
}

(*** Ini Module Declarations ***)

(** The record [ini_module_decl] is the declaration of an ini module.
  The record contains the following fields:

     [is_required] that represents if the ini module is required or optional.
      
     [ini_module_mixin_name] denomination of the ini module

     [in_params] that is a list of [input_param]s of the ini module.

     [out_params] that is a list of [output_param]s of the ini module.

     [ini_module_body] that is the body of the ini module.

     [ini_module_loc] position of the ini module.

*)
and ini_module_decl = {
  is_required: bool;
  ini_module_mixin_name: string;
  in_params: input_param list;
  out_params: output_param list;
  ini_module_body: ini_module_body;
  ini_module_loc: span
}

(*** Mixin Declarations ***)

(** The record [mixin_decl] contains the following fields:

    [mixin_name] that is the name of the mixin

    [mixin_polymorphism_params] that is a list of [polymorphism_param]s
    
    [mixin_parent] that is the [mixin_expr] that follows the 'of' keyword.

    [mixin_fields] that is a list of [field_decl]s

    [mixin_new_methods] that is a list of [new_method]s. Can be New of Abstact. 

    [mixin_override_methods] that is a list of [override_method]s

    [mixin_ini_module] that is a list of [ini_module_decl]s
*)
and mixin_decl = {
  mixin_name: string;
  mixin_polymorphism_params: polymorphism_param list;
  mixin_parent: mixin_expr;
  mixin_fields: field_decl list;
  mixin_new_methods: new_method_declaration list;
  mixin_override_methods: override_method list;
  mixin_ini_module: ini_module_decl list
}

(*** Abstract Method Declarations ***)

(** The record [abstract_method] is used to express the abstract methods of a mixin. It contains the following fields:

    [abstract_method_name] that is the name of the abstract method

    [abstract_method_params] that is a list of [parameter_decl]s that are the parameters of the abstract method

    [abstract_method_return_type] that is a [mixin_expr] that returns the type of the abstract method

    [abstract_method_loc] is the position of the [abstract_method]

    Syntax:
    abstract [abstract_method_return_type] [abstract_method_name] ([abstract_method_params])
*)

and abstract_method = {
  abstract_method_name: string;
  abstract_method_params: parameter_decl list;
  abstract_method_return_type: mixin_expr;
  abstract_method_loc: span
}

(*** New Method Declarations ***)

(** The record [new_method] is used to express the new methods of a mixin. It contains the following fields:

    [new_method_name] that is the name of the new method

    [new_method_params] that is a list of [parameter_decl]s that are the parameters of the new method

    [new_method_return_type] that is a [mixin_expr] that returns the type of the new method

    [new_method_body] that is a [method_body] that contains the body of the new metho

    [new_method_loc] is the location of the [new_method]

    Syntax:
    new [new_method_return_type] [new_method_name] ([new_method_params])
    [new_method_body]
*)
and new_method = {
  new_method_name: string; 
  new_method_params: parameter_decl list;
  new_method_return_type: mixin_expr;
  new_method_body: method_body;
  new_method_loc: span
}

(*** Override Method Declarations ***)

(** The record [override_method] is used to express the override methods of a mixin. It contains the following fields:

    [override_method_name] that is the name of the override method

    [override_method_mixin_overridden] that is the name of the mixin that is being overridden

    [override_method_params] that is a list of [parameter_decl]s that are the parameters of the override method

    [override_method_return_type] that is a [mixin_expr] that returns the type of the override method

    [override_method_body] that is a [method_body] that contains the body of the override method

    [override_method_loc] is the position of the [override_method]

    Syntax:
    override [override_method_return_type] [override_mixin_overridden].[override_method_name] ([override_method_params])
    [override_method_body]
*)
and override_method = {
  override_method_name: string;
  override_method_mixin_overridden: string;
  override_method_params: parameter_decl list;
  override_method_return_type: mixin_expr;
  override_method_body: method_body;
  override_method_loc: span
}

(*** Object Creation ***)

(** The record [object_creation] is used to express the object creation expression. It contains the following fields:

    [object_creation_mixin_expr] that is a [mixin_expr] that expresses the type of the object being created

    [object_creation_init_params] that is a list of [init_param]s that are the parameters of the object creation

    Syntax:
    new [object_creation_mixin_expr] [ [object_creation_init_params] ]
*)
and object_creation = {
  object_creation_mixin_expr: mixin_expr;
  object_creation_init_params: init_param list
}

(*** Field Selection ***)

(** The record [field_selection] is used to express the field selection expression. It contains the following fields:

    [field_selection_target] that is the [expression] located at the start of the syntax

    [field_selection_mixin_name] that is the name of the mixin that contains the field being selected

    [field_selection_field_name] that is the name of the field being selected

    Syntax:
    [field_selection_target].[field_selection_mixin_name].[field_selection_field_name]
*)
and field_selection = {
  field_selection_target: expression;
  field_selection_mixin_name: string;
  field_selection_field_name: string
}


(*** Method Call ***)

(** The record [method_call] is used to express the method call expression. It contains the following fields:

    [method_call_target] that is the [expression] located at the start of the syntax

    [method_call_mixin_name] that is the name of the mixin that contains the method being called

    [method_call_method_name] that is the name of the method being called

    [method_call_params] that is a list of [expression]s that are the parameters of the method call

    Syntax:
    [method_call_target].[method_call_mixin_name].[method_call_method_name] ([method_call_params])
*)
and method_call = {
  method_call_target: expression;
  method_call_mixin_name: string;
  method_call_method_name: string;
  method_call_params: expression list
}

(*** While Instruction ***)

(** The record [while_instruction] is used to express the while instruction. It contains the following fields:

    [while_condition] that is an [expression] inside the parentheses of the while instruction

    [while_instructions] that is a list of [instruction]s before the 'end' keyword

    Syntax:
    while ([while_condition])
      [while_instructions]
    end;
*)
and while_instruction = {
  while_condition: expression;
  while_instructions: instruction located list
}

(*** If Instruction ***)

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
and if_instruction = {
  if_condition: expression;
  if_true_instructions: instruction located list;
  if_false_instructions: instruction located list
}

(*** Mixin concatenated ***)

(** The record [mixin_expr_concat] is used to express the concatenation of two mixin expressions. It contains the following fields:

    [left_mixin] that is a [mixin_expr] that is on the left side of the ',' character

    [right_mixin] that is a [mixin_expr] that is on the right side of the ',' character

    Syntax:
    [left_mixin] , [right_mixin]
*)
and mixin_expr_concat = {
  left_mixin: mixin_expr;
  right_mixin: mixin_expr
}

(*** Mixin Application ***)

(** The record [mixin_expr_application] is used to express the application of a mixin to a mixin expression. It contains the following fields:

    [app_mixin_name] that is the name of the mixin being applied

    [app_param_name] that is the name of the parameter being applied. It follows the '.' character

    [app_value] that is a [mixin_expr] that is the value being applied to the parameter

    Syntax:
    [app_mixin_name] . [app_param_name] = ([app_value])
*)
and mixin_expr_application = {
  app_mixin_name: string;
  app_param_name: string;
  app_value: mixin_expr
}

(*** Field LValue ***)

(** The record [field_lvalue] is used to express the field lvalue. It contains the following fields:

    [field_lvalue_mixin_name] that is the name of the mixin that contains the field being assigned

    [field_lvalue_field_name] that is the name of the field being assigned

    Syntax:
    [field_lvalue_mixin_name].[field_lvalue_field_name]
*)
and field_lvalue = {
  field_lvalue_mixin_name: string;
  field_lvalue_field_name: string
}

(*** Sum types created from the interfaces ***)

(*** Mixin Expressions ***)

(** A [mixin_expr] is used to express the type of declarations such as variables, parameters, fiels and return.

  A [mixin_expr] can be [MixinExpressionVoid] or [MixinExpressionId]. 
  
  It can be combined with other [mixin_expr]s using [MixinExpressionConcat].

  It can also be an application of a mixin to a [mixin_expr] using [MixinExpressionApplication].
*)
and mixin_expr =
  | MixinExpressionId of string
  | MixinExpressionConcat of mixin_expr_concat
  | MixinExpressionApplication of mixin_expr_application
  | MixinExpressionVoid

(*** LValues ***)

(** A [lvalue] is a reference to a location in memory.
  It is used in the assignment instruction right before the ':=' operator.
  
  It can be either a variable [VariableLValue] or a field [FieldLValue].

  Syntax for [FieldLValue]:
  [mixin_name].[field_name]
*)
and lvalue =
  | VariableLValue of string
  | FieldLValue of field_lvalue

(*** Instructions ***)

(** An [instruction] is one of the operations expressed in the guards.
  There is no need of 'instruction option' since an instruction can be an ExprInstruction
  and an ExprInstruction can be a NullExpression *)
and instruction =
  | Assignment of lvalue * expression
  | ExprInstruction of expression
  | IfInstruction of if_instruction
  | NativeInstruction of string
  | ReturnInstruction of expression
  | WhileInstruction of while_instruction

(*** Expressions ***)

(** An [expression] is one of the operations expressed in the guards.
  There is no need of 'expression option' since an expression can be a NullExpression.
*)
and expression =
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

(*** New and Abstract Methods declarations ***)
(** A [new_method_declaration] is either a new or abstract method. *)
and new_method_declaration =
  | NewMethod of new_method
  | AbstractMethod of abstract_method

(*** Method Declarations ***)
(** A [method_declaration] is either a new or abstract method or an override method.
  New and abstract methods are in the same list due position.*)
and method_declaration =
  | NewOrAbstractMethod of new_method_declaration
  | OverrideMethod of override_method


(** A [global_declaration] is either a [mixin_decl] or a [let_decl] statement *)
and global_declaration =
  | MixinDecl of mixin_decl
  | LetDecl of let_decl
  | PolymorphismDecl of polymorphism_param (* THIS SHOULD NEVER BE A CASE BUT WE NEED THIS FOR GlobalDeclaration.ml 
   BEPPE VESSICCHIO *)

(*** Program ***)
(** The [program] is a list of [global_declaration]s*)
and program = global_declaration list
