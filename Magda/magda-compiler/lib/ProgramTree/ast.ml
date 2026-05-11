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
  super_name: string;
  super_params: init_param list;
}

(*** Ini Module Body ***)
and ini_module_body = {
  ini_module_variables: variable_decl list;
  ini_module_instructions: instruction list;
  ini_module_super: ini_module_super;
}

(*** Ini Module Declarations ***)
and ini_module_decl = {
  in_params: source_param list;
  out_params: source_param list;
  ini_module_body: ini_module_body;
}

(*** Mixin Declarations ***)
and mixin_decl = {
(** The record [mixin_decl] contains the following fields:

    [mixin_name] that is the name of the mixin

    [mixin_polymorphism_params]
  *)
  mixin_name: string;
  mixin_polymorphism_params: polymorphism_param list;
  mixin_fields: field_decl list;
  mixin_new_methods: method_declaration list;
  mixin_override_methods: method_declaration list;
  mixin_ini_module: ini_module_decl list;
}

(*** Sum types created from the interfaces ***)

(*** Mixin Expressions ***)
and mixin_expr =
  | MixinExpressionId of {
      mixin_name: string;
  }
  | MixinExpressionConcat of {
      left_mixin: mixin_expr;
      right_mixin: mixin_expr;
  }
  | MixinExpressionApplication of {
      mixin_name : string;
      param_name : string;
      value : mixin_expr;
  }
  | MixinExpressionVoid

(*** LValues ***)
and lvalue =
  (** A [lvalue] is a reference to a location in memory.
  It is used in the assignment instruction right before the ':=' operator.
  
  It can be either a variable [VariableLValue] or a field [FieldLValue].

  Syntax for [VariableLValue]:
  [var_name]

  Syntax for [FieldLValue]:
  [mixin_name].[field_name]
  *)

  | VariableLValue of {
      var_name: string;
  }
  | FieldLValue of {
      mixin_name: string;
      field_name: string;
  }

(*** Instructions ***)
and instruction =
(** An [instruction] is one of the operations expressed in the guards.
  There is no need of 'instruction option' since an instruction can be an ExprInstruction
  and an ExprInstruction can be a NullExpression *)
  | Assignment of lvalue * expression
  | ExprInstruction of expression
  | IfInstruction of {
      cond: expression;
      true_instructions: instruction list;
      false_instructions: instruction list;
  }
  | IniModuleSuperInstruction of {
      init_params: expression list;
  }
  | NativeInstruction of string
  | ReturnInstruction of expression
  | WhileInstruction of {
      cond: expression;
      instructions: instruction list;
  }

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
  | MethodCallExpression of {
      target: expression;
      mixin_name: string;
      method_name: string;
      params: expression list;
  }
  | FieldSelectExpression of {
      target: expression;
      mixin_name: string;
      field_name: string;
  }
  | ObjectCreationExpression of {
      mixin_expr: mixin_expr;
      init_params: expression list;
  }
  | BinaryOperation of binop * expression * expression


(*** Declarations ***)
(** A [global_declaration] is either a [mixin_decl] or a [let_decl] statement *)
and global_declaration =
  | MixinDecl of mixin_decl
  | LetDecl of let_decl

(*** Method Declaration ***)
and method_declaration =
  (** A [method_declaration] is a bodyless abstract [AbstactMethod] or a concrete [NewMethod] or an override of an existing mixin [OverrideMethod]*)

  | AbstractMethod of {
      name: string;
      params: parameter_decl list;
      return_type: mixin_expr;
  }
  | NewMethod of {
      name: string;
      params: parameter_decl list;
      return_type: mixin_expr;
      body: method_body;
  }
  | OverrideMethod of {
      name: string;
      mixin_overridden: string;
      params: parameter_decl list;
      return_type: mixin_expr;
      body: method_body;
  }

(*** Program ***)
(** The [program] is a list of [global_declaration]s*)
and program = global_declaration list