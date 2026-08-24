(** Concrete Syntax Tree types for the Magda language.
 
    This module defines the CST produced by the Menhir parser.
    The CST is a faithful representation of the source syntax: it preserves some
    parentheses, qualified vs. direct accesses, and member ordering without
    any semantic interpretation.
*)

(** The left side of an assignment:
    - [MixinField]: [this.MixinName.fieldName],
    - [DirectField]: [this.fieldName],
    - [Variable]: a bare identifier [x]. 
*)
type l_value =
| MixinField of string * string
| DirectField of string
| Variable of string

(** An instruction inside a method or ini module body.
    Every instruction is terminated by [;] in the source.
    - [Assignment] = [lvalue := expr]
    - [ExprInstruction] is an expression used as a statement, typically a method call executed for its side effects
    - [Return] = [return expr]
    - [NativeInstruction] is an Inline Java code between [%] delimeters.
    - [WhileLoop] = [while (cond) instructions end]
    - [IfCond] = [if (cond) trueInstrs [else falseInstrs] end]. The false branch is an empty list when there is no [else]
*)
type instruction =
| Assignment of l_value * expression
| ExprInstruction of expression
| Return of expression
| NativeInstruction of string
| WhileLoop of expression * instruction list 
| IfCond of expression * instruction list * instruction list

(** An expression in Magda:
    - [ThisExpr] = [this], reference to the current object
    - [SuperExpression] = [super(args)], call to the overridden method (not to be confused with the ini module super call [super[...]] in {!ini_module_body})
    - [BoolLiteral], [IntegerLiteral], [FloatLiteral], [StringLiteral], [NullExpr] are literal values
    - [ByteLiteral] is a hexadecimal byte literal, stored as raw string (e.g. ["0xFF"])
    - [IdExpr] is a bare identifier: could be a variable, a parameter, or a mixin name
    - [RoundBracketExpr] = [(expr)], parenthesized expression preserved as explicit node
    - [ObjectCreation] = [new MixinExpr [init_params]]
    - [BinaryOp] = [left op right]
    - [ExprSuffix] is an expression followed by a field access or method call {!suffix}
*)
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

(** An initialization parameter: [MixinName.paramName := expr].
    Used in object creation and ini module super calls. 
*)
and init_param = string * string * expression 

and binop = Add | Sub | Div | Mul | StrongEq | Eq | Leq | Lt | Geq | Gt | Neq
(** Binary operators *)

(** A suffix appended to an expression via [.].
    "Specific" means the access explicitly names the owning mixin;
    "Direct" means the mixin is omitted and must be inferred. 
    - [SpecificMethodCall] = [.MixinName.methodName(args)]
    - [DirectMethodCall] = [.methodName(args)]
    - [SpecificFieldSelect] = [.MixinName.fieldName]
    - [DirectFieldSelect] = [.fieldName]
    *)
and suffix = 
| SpecificMethodCall of string * string * expression list
| DirectMethodCall of string * expression list
| SpecificFieldSelect of string * string
| DirectFieldSelect of string

(** A mixin type expression, used for type annotations, parent declarations, and object creation targets:
    - Parenthesized, preserved as explicit node [RoundBracketMixinExpr] = [(MixinExpr)]
    - A mixin name optionally followed by comma-separeted elements [MixinExprComposition] (in [A, B] is [MixinExprComposition("A", [ElemId "B"])])
  *)
and mixin_expression = 
| RoundBracketMixinExpr of mixin_expression
| MixinExprComposition of string * mixin_concat list

(** An element following a comma in a {!mixin_expression} composition:
    - A plain mixin name [ElemId] (the [B] in [A, B])
    - An high-order application [ElemHOApp] = [where MixinName.ParamName := (MixinExpr)]
    - A parenthesized sub-expression: the [(C,D)] in [A, (C, D)]
    *)
and mixin_concat = 
| ElemId of string
| ElemHOApp of string * string * mixin_expression
| ElemRoundBracket of mixin_expression

(**A {!mixin_expression} or [void].
    Used where the grammar admits [void] as alternative
*)
type mixin_expr_or_void =
|MixinVoid
|MixinExpr of mixin_expression

(** A mixin declaration: [mixin Name <polyParams> of Parent = members end].
    The mixin is the only construct in Magda, there are no classes.
    It declares fields, methods and initialization modules, and inherits those of its parent mixin (or [void] if it has no parent).
    Fields: name, polymorphism parameters, parent, member declarations. 
*)
type mixin_declaration = string * polymorphism_param list * mixin_expr_or_void * other_declaration list

(** A polymorphism parameter: [T <= UpperBound]. 
    The string is the parameter name, the {!mixin_expression} is
    the upper bound constraint that the type argument must satisfy. 
*)
and polymorphism_param = string * mixin_expression

(** A member declaration inside a mixin body: 
    - A field in the mixin, with a name and a type [FieldDeclaration] = [fieldName : Type] 
    - An override of a method of a parent [OverrideMethodDeclaration] = [override ReturnType MixinName.methodName(params) body]
    - A new or an abstract method [NewMethodDeclaration] = {!new_method_declaration};
    - An initialization module, a composable piece of a constructor that receive input parameters,
      executes logic, and forwards values to parents modules via super call
      [IniModuleDeclaration] = [required|optional MixinName(inputs) initializes (outputs) body] 
*)
and other_declaration = 
| FieldDeclaration of string * mixin_expression
  (**The string is the field name and the mixin_expression is the type of said field*)
| OverrideMethodDeclaration of mixin_expr_or_void * string * string * parameter_decl list * method_body
  (**Fields: return type, overridden mixin name, method name, parameters, body*)
| NewMethodDeclaration of new_method_declaration
| IniModuleDeclaration of ini_module_header * string * input_init_param list * output_init_param list * ini_module_body
  (**Fields: required/optional flag, mixin name, input parameters, output parameters, body*)

(** A formal parameter of a method: [paramName : Type]. 
    The string is the parameter name and the mixin_expression is the type of said parameter.
*)
and parameter_decl = string * mixin_expression

(** The body of a method ([new] or [override]) as a record.
    It has two distinct part: the local variables of the method and a sequence of instructions.
*)
and method_body = {
met_local_vars : local_variable_declaration list;
instructions : instruction list
}

(** A local variable declaration: [varName : Type;].
    The string is the variable name and the mixin_expression is the type of said variable.
    Appears before [begin] in method and ini module bodies. 
*)
and local_variable_declaration = string * mixin_expression

(** An [abstract] or [new] method declaration: 
    - {!AbsMet}:[abstract ReturnType methodName(params)] - no body.
    - {!NewMet}:[new ReturnType methodName(params) body]
*)
and new_method_declaration = 
| AbsMet of mixin_expr_or_void * string * parameter_decl list
| NewMet of mixin_expr_or_void * string * parameter_decl list * method_body


and ini_module_header = Required | Optional
(** The [required] or [optional] flag of an ini module.*) 

(** An input parameter of an ini module: [paramName : Type]. 
    The string is the parameter name and the mixin_expression is the type of said parameter.
*)
and input_init_param = string * mixin_expression

(** An output parameter of an ini module: [MixinName.paramName].
    Declares a parent module parameter that this module will provide via its super call.
    First string is the target mixin, second is the parameter name;
    no type annotation.
*)
and output_init_param = string * string

(** The body of an ini module as a record. 
    It has four distinct parts: the local variables, the super call, who appears exactly once, and the pre-super and post-super instructions section.
    The super call [super[MixinName.param := expr, ...]] passes computed values to parent module parameters,
    fulfilling the commitments declared by the output parameters.
*)
and ini_module_body = {
ini_local_vars : local_variable_declaration list;
instructions_pre_super : instruction list;
super_call : init_param list;
instructions_post_super : instruction list
}

(** Let declaration type, binds a name to a mixin expression, allowing it to be used as a shorthand;
    [string], the alias, could be used in the code instead of the full {!mixin_expression} ([let AliasName = MixinExpression])
*)
type let_declaration = string * mixin_expression

(** Include declaration type, represents the inclusion of a Magda library into the code.
    [string] indicate the path of the included file ([include "path/to/the/file.magda";]).
*)
type include_declaration = string


(** Global declaration type, the top-level part in a Magda source file.
    It could be a {!mixin_declaration}, a {!let_declaration} or an {!include_declaration}
*)
type global_declaration =
| DeclarationMixin of mixin_declaration
| DeclarationLet of let_declaration
| DeclarationInclude of include_declaration


(** Program type, a program in Magda is a sequence of {!global_declaration}*)
type program = global_declaration list
