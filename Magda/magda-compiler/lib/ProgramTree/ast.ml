(*** Records used later ***)

(* These sum types will be used to make the binary operations less verbose *)
(*** Binary Operations ***)
type binop = Add | Div | Eq | Leq | Less | Mul | Neq | StrongEq | Sub



(* These records will be used in the declarations to make the various sub-structures more readable *)

(*** Let ***)
and let_decl = {
  let_name: string;
  bound: expression;
}

(*** Field Declarations ***)
and field_decl = {
  field_name: string;
  field_type: mixin_expr;
}

(*** Parameter Declarations ***)
and parameter_decl = {
  param_name: string;
  param_type: mixin_expr;
}

(*** Init Module Parameters ***)
and init_param = {
  imixin_name: string;
  iparam_name: string;
  ivalue: expression;
}

(*** Source Parameters ***)
and source_param = {
  mixin_name: string;
  param_name: string;
  source_type: mixin_expr;
}

(*** Variable Declarations ***)
and variable_decl = {
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
      left: mixin_expr;
      right: mixin_expr;
  }
  | MixinExpressionApplication of {
      mixin_name : string;
      param_name : string;
      value : mixin_expr;
  }
  | MixinExpressionVoid

(*** LValues ***)
and lvalue =
  | VariableLValue of {
      var_name: string;
  }
  | FieldLValue of {
      mixin_name: string;
      field_name: string;
  }

(*** Instructions ***)
and instruction =
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
  | ThisExpression
  | NullExpression
  | IntegerLiteral of int
  | BooleanLiteral of bool
  | FloatLiteral of float
  | ByteLiteral of (* da capire se mettere string o no*) string
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
and declaration =
  | MixinDecl of mixin_decl
  | LetDecl of let_decl

(*** Method Declaration ***)
and method_declaration =
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


and program = declaration list