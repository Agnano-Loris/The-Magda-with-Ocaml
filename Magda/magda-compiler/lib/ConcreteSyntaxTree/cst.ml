type l_value =
| MixinField of string * string
| DirectField of string
| Variable of string

and instruction =
| Assignment of l_value * expression
| ExprInstruction of expression
| Return of expression
| NativeInstruction of string
| WhileLoop of expression * instruction list 
| IfCond of expression * instruction list * instruction list
(*and serve per i tipi mutualmente ricorsivi, si chiamano a vicenda. nota: ricorda di fare la documentazione*)

and expression = 
| ThisExpr
| SuperExpression of expression list
| BoolLiteral of bool
| ByteLiteral of string
| IntegerLiteral of int
| FloatLiteral of float
| StringLiteral of string
| NullExpr
| IdExpr of string
| RoundBracketExpr of expression
| ObjectCreation of mixin_expression * init_param list
| BinaryOp of binop * expression * expression
| ExprSuffix of expression * suffix

and init_param = string * string * expression 

and binop = Add | Sub | Div | Mul | StrongEq | Eq | Leq | Lt | Geq | Gt | Neq

and suffix = 
| SpecificMethodCall of string * string * expression list
| DirectMethodCall of string * expression list
| SpecificFieldSelect of string * string
| DirectFieldSelect of string

and mixin_expression = 
| RoundBracketMixinExpr of mixin_expression
| MixinExprComposition of string * mixin_concat list

and mixin_concat = 
| ElemId of string
| ElemHOApp of string * string * mixin_expression
| ElemRoundBracket of mixin_expression

and mixin_expr_or_void =
|MixinVoid
|MixinExpr of mixin_expression

type mixin_declaration = string * polymorphism_param list * mixin_expr_or_void * other_declaration list

and polymorphism_param = string * mixin_expression

and other_declaration = 
| FieldDeclaration of string * mixin_expression
| OverrideMethodDeclaration of mixin_expr_or_void * string * string * parameter_decl list * method_body
| NewMethodDeclaration of new_method_declaration
| IniModuleDeclaration of ini_module_header * string * input_init_param list * output_init_param list * ini_module_body

and parameter_decl = string * mixin_expression

and method_body = {
met_local_vars : local_variable_declaration list;
instructions : instruction list
}

and local_variable_declaration = string * mixin_expression

and new_method_declaration = 
| AbsMet of mixin_expr_or_void * string * parameter_decl list
| NewMet of mixin_expr_or_void * string * parameter_decl list * method_body

and ini_module_header = Required | Optional 

and input_init_param = string * mixin_expression

and output_init_param = string * string

and ini_module_body = {
ini_local_vars : local_variable_declaration list;
instructions_pre_super : instruction list;
super_call : init_param list;
instructions_post_super : instruction list
}

and let_declaration = string * mixin_expression

and include_declaration = string

and global_declaration =
| DeclarationMixin of mixin_declaration
| DeclarationLet of let_declaration
| DeclarationInclude of include_declaration

and program = global_declaration list