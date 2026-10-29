open Utils
open Cst_resolve_includes
open PreParserStructures

module Ast = Program_tree.Ast

(** [resolution_error message] raises a [Magda_error] in [ResolutionPhase] without a position;
    the position is attached by the nearest enclosing {!Errors.adorn_error_with_span}.

    This function is not defined in the module interface.
*)
let resolution_error message = Errors.magda_raise Errors.ResolutionPhase message

(** {1 Resolution environment} *)

(** The information needed to resolve the names inside a method or ini module body:
    - [ctx]: the program context;
    - [polys]: for every mixin, its polymorphism parameters mapped to the head type of their bound;
    - [mixin]: the mixin containing the body;
    - [method_key]: the key of the body in the program context
      ([m] for a new method, [M.m] for an override, [initialize k] for an ini module).

    This type is not defined in the module interface.
*)
type env = {
  ctx : ProgramContext.t;
  polys : MagdaType.t StringMap.t StringMap.t;
  mixin : string;
  method_key : string;
}

(** [collect_polys program polys] adds to [polys] the polymorphism parameters of every mixin of [program],
    included programs too. Each parameter is mapped to the type of its bound, computed as in the index.

    This function is not defined in the module interface.
*)
let rec collect_polys (program : resolved_program) polys =
  List.fold_left (fun polys decl -> match decl with
    | DeclarationMixin (name, params, _, _) ->
      let bounds = List.fold_left
          (fun bounds (param, bound) -> StringMap.add param (Cst_to_context.mixin_expr_type bound) bounds)
          StringMap.empty params in
      StringMap.add name bounds polys
    | DeclarationLet _ -> polys
    | DeclarationInclude (_, included) -> collect_polys included polys)
    polys program

(** [type_of_names names] rebuilds a type from its mixin names, with the rule of {!Cst_to_context.mixin_expr_type}:
    one name gives a simple type, more names a [Composite].

    This function is not defined in the module interface.
*)
let type_of_names = function
  | [ name ] -> MagdaType.string_to_magdatype name
  | names -> MagdaType.Composite names

(** [substitute_poly env owner ty] replaces every name of [ty] that is a polymorphism parameter of the mixin [owner]
    with the names of the type of its bound; other names are kept.
    For example, with [t <= Vec], the type [t] becomes [Vec] and the type [t, Color] becomes [Vec, Color].
    [owner] is the mixin where [ty] was read: the current mixin for variables and parameters,
    the declaring mixin for fields and return types.

    This function is not defined in the module interface.
*)
let substitute_poly env owner (ty : MagdaType.t option) = match ty with
  | Some ((MagdaType.MixinType _ | MagdaType.Composite _) as t) ->
    let bounds = Option.value ~default:StringMap.empty (StringMap.find_opt owner env.polys) in
    let substitute name = match StringMap.find_opt name bounds with
      | Some bound -> MagdaType.names bound
      | None -> [ name ] in
    Some (type_of_names (List.concat_map substitute (MagdaType.names t)))
  | _ -> ty

(** {1 Mixin expressions and operators} *)

(** [mixin_expr mexpr] converts a {!Cst.mixin_expression}: parentheses are removed and
    a composition [A, B, C] is folded to the left, [Concat (Concat (A, B), C)], as [MixinExpression] in [Parser.jj].

    This function is not defined in the module interface.
*)
let rec mixin_expr (mexpr : Cst.mixin_expression) : Ast.mixin_expr = match mexpr with
  | Cst.RoundBracketMixinExpr inner -> mixin_expr inner
  | Cst.MixinExprComposition (head, rest) ->
    List.fold_left
      (fun left elem -> Ast.MixinExpressionConcat { Ast.left_mixin = left; right_mixin = mixin_concat elem })
      (Ast.MixinExpressionId head) rest

(** [mixin_concat elem] converts one element of a composition.

    This function is not defined in the module interface.
*)
and mixin_concat : Cst.mixin_concat -> Ast.mixin_expr = function
  | Cst.ElemId name -> Ast.MixinExpressionId name
  | Cst.ElemHOApp (mixin, param, value) ->
    Ast.MixinExpressionApplication { Ast.app_mixin_name = mixin; app_param_name = param; app_value = mixin_expr value }
  | Cst.ElemRoundBracket inner -> mixin_expr inner

(** [mixin_expr_or_void mev] converts [void] to [MixinExpressionVoid], any other expression with [mixin_expr].

    This function is not defined in the module interface.
*)
let mixin_expr_or_void : Cst.mixin_expr_or_void -> Ast.mixin_expr = function
  | Cst.MixinVoid -> Ast.MixinExpressionVoid
  | Cst.MixinExpr mexpr -> mixin_expr mexpr

(** [binary op left right] builds a binary operation.
    [a > b] becomes [b < a] and [a >= b] becomes [b <= a], as in [Parser.jj];
    [a != b] keeps its operands in order (the Java swaps them).

    This function is not defined in the module interface.
*)
let binary (op : Cst.binop) left right : Ast.expression = match op with
  | Cst.Add -> Ast.BinaryOperation (Ast.Add, left, right)
  | Cst.Sub -> Ast.BinaryOperation (Ast.Sub, left, right)
  | Cst.Mul -> Ast.BinaryOperation (Ast.Mul, left, right)
  | Cst.Div -> Ast.BinaryOperation (Ast.Div, left, right)
  | Cst.StrongEq -> Ast.BinaryOperation (Ast.StrongEq, left, right)
  | Cst.Eq -> Ast.BinaryOperation (Ast.Eq, left, right)
  | Cst.Neq -> Ast.BinaryOperation (Ast.Neq, left, right)
  | Cst.Leq -> Ast.BinaryOperation (Ast.Leq, left, right)
  | Cst.Lt -> Ast.BinaryOperation (Ast.Less, left, right)
  | Cst.Gt -> Ast.BinaryOperation (Ast.Less, right, left)
  | Cst.Geq -> Ast.BinaryOperation (Ast.Leq, right, left)

(** [binary_type op] is the type of the result of [op]: [Boolean] for comparisons,
    unknown for arithmetic operations, whose mixin is chosen by the type checker.

    This function is not defined in the module interface.
*)
let binary_type : Cst.binop -> MagdaType.t option = function
  | Cst.Add | Cst.Sub | Cst.Mul | Cst.Div -> None
  | Cst.StrongEq | Cst.Eq | Cst.Neq | Cst.Leq | Cst.Lt | Cst.Gt | Cst.Geq -> Some MagdaType.Bool

(** {1 Member lookup} *)

(** [target_type kind name ty] is the type of the target of the abbreviated access to the member [name].
    Raises an error if the type is unknown or [void].

    This function is not defined in the module interface.
*)
let target_type kind name (ty : MagdaType.t option) = match ty with
  | None ->
    resolution_error (Printf.sprintf "Cannot resolve the %s %s: the type of its target is unknown, qualify the access" kind name)
  | Some MagdaType.Void ->
    resolution_error (Printf.sprintf "Cannot resolve the %s %s: its target has type void" kind name)
  | Some t -> t

(** [owners query member ty] is the set of mixins that introduce [member] for a target of type [ty]:
    the union of [query member m] over the mixins [m] of [ty].
    A union, not a list, so a member reached through a base mixin shared by two components counts once.
    It is the only place where a type becomes a set of candidate mixins.

    This function is not defined in the module interface.
*)
let owners query member (ty : MagdaType.t) =
  List.fold_left (fun acc mixin -> StringSet.union acc (query member mixin)) StringSet.empty (MagdaType.names ty)

(** [unique_owner kind name ty owners] returns the only element of [owners];
    raises an error if [owners] is empty (no such member) or has more than one element (ambiguous member).

    This function is not defined in the module interface.
*)
let unique_owner kind name ty owners =
  let type_name = MagdaType.to_string ty in
  match StringSet.elements owners with
  | [ owner ] -> owner
  | [] -> resolution_error (Printf.sprintf "No %s named %s for mixin of type %s" kind name type_name)
  | candidates ->
    resolution_error (Printf.sprintf "Ambiguous %s %s for mixin of type %s, possible mixins: %s"
                        kind name type_name (String.concat ", " candidates))

(** [abbreviated_field env field ty] resolves the abbreviated access [.field] on a target of type [ty].
    Returns the introducing mixin and the type of the field.

    This function is not defined in the module interface.
*)
let abbreviated_field env field ty =
  let ty = target_type "field" field ty in
  let query field mixin = ProgramContext.contains_unambiguous_field field mixin env.ctx in
  let owner = unique_owner "field" field ty (owners query field ty) in
  (owner, substitute_poly env owner (ProgramContext.get_field_type field owner env.ctx))

(** [abbreviated_method env meth ty] same as [abbreviated_field], for the method [meth]; returns its return type.

    This function is not defined in the module interface.
*)
let abbreviated_method env meth ty =
  let ty = target_type "method" meth ty in
  let query meth mixin = ProgramContext.contains_unambiguous_method meth mixin env.ctx in
  let owner = unique_owner "method" meth ty (owners query meth ty) in
  (owner, substitute_poly env owner (ProgramContext.get_method_return_type meth owner env.ctx))

(** [check_mixin env mixin] raises an error if [mixin] is not declared.

    This function is not defined in the module interface.
*)
let check_mixin env mixin =
  if not (ProgramContext.contains_mixin mixin env.ctx) then
    resolution_error (Printf.sprintf "Mixin %s has never been declared" mixin)

(** [qualified_field env mixin field] checks that [mixin] declares [field] and returns the type of the field.
    It does not check that [mixin] belongs to the type of the target: that is a job for the type checker,
    which knows the whole mixin expression.

    This function is not defined in the module interface.
*)
let qualified_field env mixin field =
  check_mixin env mixin;
  match ProgramContext.get_field_type field mixin env.ctx with
  | Some _ as ty -> substitute_poly env mixin ty
  | None -> resolution_error (Printf.sprintf "No field named %s in mixin %s" field mixin)

(** [qualified_method env mixin meth] same as [qualified_field], for the method [meth]; returns its return type.
    Only methods introduced by [mixin] ([new] or [abstract]) are found.

    This function is not defined in the module interface.
*)
let qualified_method env mixin meth =
  check_mixin env mixin;
  if ProgramContext.contains_method meth mixin env.ctx then
    substitute_poly env mixin (ProgramContext.get_method_return_type meth mixin env.ctx)
  else resolution_error (Printf.sprintf "No method named %s in mixin %s" meth mixin)

(** [variable_type env name] returns the type of the variable or parameter [name] of the current body;
    raises an error if [name] is not declared there.
    Used both when a variable is read and when it is assigned.

    This function is not defined in the module interface.
*)
let variable_type env name =
  match ProgramContext.get_method_variable_type name env.method_key env.mixin env.ctx with
  | Some _ as ty -> substitute_poly env env.mixin ty
  | None -> resolution_error (Printf.sprintf "Variable %s has never been declared" name)

(** {1 Expressions} *)

(** An element of a flattened suffix chain: a name after a dot, or a method call.
    [this.a.b.m(x)] becomes the base [this] and the atoms [Name a; Name b; Call (m, [x])].

    This type is not defined in the module interface.
*)
type atom =
  | Name of string
  | Call of string * Cst.expression list

(** [atoms_of_suffix suffix] splits a suffix built by the parser into atoms.

    This function is not defined in the module interface.
*)
let atoms_of_suffix : Cst.suffix -> atom list = function
  | Cst.SpecificMethodCall (first, meth, args) -> [ Name first; Call (meth, args) ]
  | Cst.DirectMethodCall (meth, args) -> [ Call (meth, args) ]
  | Cst.SpecificFieldSelect (first, second) -> [ Name first; Name second ]
  | Cst.DirectFieldSelect field -> [ Name field ]

(** [flatten expr atoms] removes the chain of [ExprSuffix] nodes from [expr];
    returns its base and the list of atoms, in source order, followed by [atoms].
    The grouping chosen by the parser is lost on purpose: the chain is split again by [consume].

    This function is not defined in the module interface.
*)
let rec flatten (expr : Cst.expression) atoms = match expr with
  | Cst.ExprSuffix (inner, suffix) -> flatten inner (atoms_of_suffix suffix @ atoms)
  | base -> (base, atoms)

(** [field_select target mixin field] builds a qualified field selection.

    This function is not defined in the module interface.
*)
let field_select target mixin field =
  Ast.FieldSelectExpression
    { Ast.field_selection_target = target; field_selection_mixin_name = mixin; field_selection_field_name = field }

(** [method_call target mixin meth args] builds a qualified method call.

    This function is not defined in the module interface.
*)
let method_call target mixin meth args =
  Ast.MethodCallExpression
    { Ast.method_call_target = target; method_call_mixin_name = mixin;
      method_call_method_name = meth; method_call_params = args }

(** [resolve_expr env expr] converts [expr] and computes its type, used only to resolve the accesses that follow it.
    The type is [None] when it is not known at this stage: [null], arithmetic operations,
    identifiers not found in the method.

    This function is not defined in the module interface.
*)
let rec resolve_expr env (expr : Cst.expression) : Ast.expression * MagdaType.t option =
  match expr with
  | Cst.ThisExpr -> (Ast.ThisExpression, Some (MagdaType.string_to_magdatype env.mixin))
  | Cst.SuperExpression args ->
    (Ast.SuperExpression (resolve_args env args),
     substitute_poly env env.mixin (ProgramContext.get_method_return_type env.method_key env.mixin env.ctx))
  | Cst.BoolLiteral b -> (Ast.BooleanLiteral b, Some MagdaType.Bool)
  | Cst.ByteLiteral b -> (Ast.ByteLiteral b, Some MagdaType.Byte)
  | Cst.IntegerLiteral n -> (Ast.IntegerLiteral n, Some MagdaType.Integer)
  | Cst.FloatLiteral f -> (Ast.FloatLiteral f, Some MagdaType.Float)
  | Cst.StringLiteral s -> (Ast.StringLiteral s, Some MagdaType.StringType)
  | Cst.NullExpr -> (Ast.NullExpression, None)
  | Cst.IdExpr name -> (Ast.Identifier name, variable_type env name)
  | Cst.RoundBracketExpr inner -> resolve_expr env inner
  | Cst.ObjectCreation (mexpr, params) ->
    (Ast.ObjectCreationExpression
       { Ast.object_creation_mixin_expr = mixin_expr mexpr;
         object_creation_init_params = List.map (init_param env) params },
     Some (Cst_to_context.mixin_expr_type mexpr))
  | Cst.BinaryOp (op, left, right) ->
    let (left, _) = resolve_expr env left in
    let (right, _) = resolve_expr env right in
    (binary op left right, binary_type op)
  | Cst.ExprSuffix _ ->
    let (base, atoms) = flatten expr [] in
    consume env (resolve_expr env base) atoms

(** [resolve_args env args] converts the actual parameters of a call; their types are not needed.

    This function is not defined in the module interface.
*)
and resolve_args env args = List.map (fun arg -> fst (resolve_expr env arg)) args

(** [init_param env param] converts an initialization parameter [M.p := expr].

    This function is not defined in the module interface.
*)
and init_param env ((mixin, param, value) : Cst.init_param) : Ast.init_param =
  { Ast.imixin_name = mixin; iparam_name = param; ivalue = fst (resolve_expr env value) }

(** [consume env (target, ty) atoms] applies the atoms to [target], of type [ty], from left to right:
    - [Call m]: abbreviated call of [m];
    - [Name a; Call m]: if [a] is a mixin, qualified call [a.m]; otherwise abbreviated field [a], then [Call m];
    - [Name a; Name b]: if [a] is a mixin, qualified selection [a.b]; otherwise abbreviated field [a], then [Name b];
    - [Name a] alone: abbreviated field [a].
    When a name is both a mixin and a field, the mixin wins, as in [Parser.jj].

    This function is not defined in the module interface.
*)
and consume env (target, ty) atoms = match atoms with
  | [] -> (target, ty)
  | Call (meth, args) :: rest ->
    let (owner, return_type) = abbreviated_method env meth ty in
    consume env (method_call target owner meth (resolve_args env args), return_type) rest
  | Name mixin :: Call (meth, args) :: rest when ProgramContext.contains_mixin mixin env.ctx ->
    let return_type = qualified_method env mixin meth in
    consume env (method_call target mixin meth (resolve_args env args), return_type) rest
  | Name mixin :: Name field :: rest when ProgramContext.contains_mixin mixin env.ctx ->
    let field_type = qualified_field env mixin field in
    consume env (field_select target mixin field, field_type) rest
  | Name field :: rest ->
    let (owner, field_type) = abbreviated_field env field ty in
    consume env (field_select target owner field, field_type) rest

(** {1 Instructions} *)

(** [lvalue env lv] converts the left side of an assignment; [this.f] is resolved on the current mixin.

    This function is not defined in the module interface.
*)
let lvalue env : Cst.l_value -> Ast.lvalue = function
  | Cst.Variable name -> ignore (variable_type env name); Ast.VariableLValue name
  | Cst.MixinField (mixin, field) ->
    ignore (qualified_field env mixin field);
    Ast.FieldLValue { Ast.field_lvalue_mixin_name = mixin; field_lvalue_field_name = field }
  | Cst.DirectField field ->
    let (owner, _) = abbreviated_field env field (Some (MagdaType.string_to_magdatype env.mixin)) in
    Ast.FieldLValue { Ast.field_lvalue_mixin_name = owner; field_lvalue_field_name = field }

(** [instruction env instr] converts an instruction and keeps its position;
    errors raised inside it get that position.

    This function is not defined in the module interface.
*)
let rec instruction env (instr : Cst.instruction Cst.located) : Ast.instruction Ast.located =
  Errors.adorn_error_with_span instr.Cst.loc
    (fun () -> { instr with Cst.value = instruction_body env instr.Cst.value })

(** [instruction_body env instr] converts the content of an instruction.
    Its parts are converted in source order, so the first error raised is the first in the file:
    OCaml does not specify the evaluation order of the fields of a record or of the arguments of a constructor.

    This function is not defined in the module interface.
*)
and instruction_body env : Cst.instruction -> Ast.instruction = function
  | Cst.Assignment (lv, value) ->
    let target = lvalue env lv in
    let (value, _) = resolve_expr env value in
    Ast.Assignment (target, value)
  | Cst.ExprInstruction expr -> Ast.ExprInstruction (fst (resolve_expr env expr))
  | Cst.Return expr -> Ast.ReturnInstruction (fst (resolve_expr env expr))
  | Cst.NativeInstruction code -> Ast.NativeInstruction code
  | Cst.WhileLoop (cond, body) ->
    let (while_condition, _) = resolve_expr env cond in
    let while_instructions = List.map (instruction env) body in
    Ast.WhileInstruction { Ast.while_condition; while_instructions }
  | Cst.IfCond (cond, true_branch, false_branch) ->
    let (if_condition, _) = resolve_expr env cond in
    let if_true_instructions = List.map (instruction env) true_branch in
    let if_false_instructions = List.map (instruction env) false_branch in
    Ast.IfInstruction { Ast.if_condition; if_true_instructions; if_false_instructions }

(** {1 Declarations} *)

(** [variable_decl decl] converts a local variable declaration.

    This function is not defined in the module interface.
*)
let variable_decl ((name, ty) : Cst.local_variable_declaration) : Ast.variable_decl =
  { Ast.var_name = name; var_type = mixin_expr ty }

(** [parameter_decl decl] converts a formal parameter.

    This function is not defined in the module interface.
*)
let parameter_decl ((name, ty) : Cst.parameter_decl) : Ast.parameter_decl =
  { Ast.param_name = name; param_type = mixin_expr ty }

(** [polymorphism_param param] converts a polymorphism parameter [t <= Bound].

    This function is not defined in the module interface.
*)
let polymorphism_param ((name, bound) : Cst.polymorphism_param) : Ast.polymorphism_param =
  { Ast.poly_name = name; poly_bound = mixin_expr bound }

(** [method_body env body] converts the body of a [new] or [override] method.

    This function is not defined in the module interface.
*)
let method_body env (body : Cst.method_body) : Ast.method_body =
  { Ast.method_local_variables = List.map variable_decl body.Cst.met_local_vars;
    method_instructions = List.map (instruction env) body.Cst.instructions }

(** [ini_module_body env body] converts the body of an ini module, in source order:
    instructions before the super call, super call, instructions after it.
    Errors in the super call get the position of the super call.

    This function is not defined in the module interface.
*)
let ini_module_body env (body : Cst.ini_module_body) : Ast.ini_module_body =
  let call = body.Cst.super_call in
  let ini_module_instructions_precall = List.map (instruction env) body.Cst.instructions_pre_super in
  let super_params =
    Errors.adorn_error_with_span call.Cst.loc (fun () -> List.map (init_param env) call.Cst.value) in
  let ini_module_instructions_postcall = List.map (instruction env) body.Cst.instructions_post_super in
  { Ast.ini_module_variables = List.map variable_decl body.Cst.ini_local_vars;
    ini_module_instructions_precall;
    ini_module_super = { Ast.super_params; super_loc = call.Cst.loc };
    ini_module_instructions_postcall }

(** A member of a mixin after conversion, tagged with its kind.
    Members are converted in one pass in source order, then sorted into the lists of {!Ast.mixin_decl}.

    This type is not defined in the module interface.
*)
type member =
  | Field of Ast.field_decl
  | NewOrAbstract of Ast.new_method_declaration
  | Override of Ast.override_method
  | IniModule of Ast.ini_module_decl

(** [new_method env_for loc decl] converts a [new] or [abstract] method.
    [env_for key] is the environment of the body whose key is [key].

    This function is not defined in the module interface.
*)
let new_method env_for loc : Cst.new_method_declaration -> Ast.new_method_declaration = function
  | Cst.AbsMet (return_type, name, params) ->
    Ast.AbstractMethod
      { Ast.abstract_method_name = name;
        abstract_method_params = List.map parameter_decl params;
        abstract_method_return_type = mixin_expr_or_void return_type;
        abstract_method_loc = loc }
  | Cst.NewMet (return_type, name, params, body) ->
    Ast.NewMethod
      { Ast.new_method_name = name;
        new_method_params = List.map parameter_decl params;
        new_method_return_type = mixin_expr_or_void return_type;
        new_method_body = method_body (env_for name) body;
        new_method_loc = loc }

(** [override_method env_for loc (return_type, overridden, name, params, body)] converts an [override] method.
    Its key in the program context is [M.m], as in {!Cst_to_context}.

    This function is not defined in the module interface.
*)
let override_method env_for loc (return_type, overridden, name, params, body) : Ast.override_method =
  { Ast.override_method_name = name;
    override_method_mixin_overridden = overridden;
    override_method_params = List.map parameter_decl params;
    override_method_return_type = mixin_expr_or_void return_type;
    override_method_body = method_body (env_for (overridden ^ "." ^ name)) body;
    override_method_loc = loc }

(** [ini_module ctx current_mixin env_for index loc decl] converts the ini module in position [index]
    among the ini modules of [current_mixin], in source order.
    Its key in the program context is {!PreParserStructures.MixinContext.inimodule_name}[ index]:
    {!Cst_to_context} registers the ini modules in the same order. The key is found by position, not through
    the input parameters, because two ini modules without inputs would share the same parameters.
    The input parameters take the mixin named in the header.

    This function is not defined in the module interface.
*)
let ini_module ctx current_mixin env_for index loc (header, header_mixin, inputs, outputs, body) : Ast.ini_module_decl =
  let key = MixinContext.inimodule_name index in
  if not (ProgramContext.contains_method key current_mixin ctx) then
    resolution_error (Printf.sprintf "Ini module %s of mixin %s is not in the program context" key current_mixin);
  { Ast.is_required = (match header with Cst.Required -> true | Cst.Optional -> false);
    ini_module_mixin_name = header_mixin;
    in_params = List.map (fun (name, ty) ->
        { Ast.input_param_mixin = header_mixin; input_param_name = name; input_param_type = mixin_expr ty })
        inputs;
    out_params = List.map (fun (mixin, name) ->
        { Ast.output_param_mixin = mixin; output_param_name = name })
        outputs;
    ini_module_body = ini_module_body (env_for key) body;
    ini_module_loc = loc }

(** [mixin_decl ctx polys decl] converts a mixin declaration.
    Members are converted in one pass in source order, so the first error raised is the first in the file;
    ini modules are numbered along the way. Then they are sorted by kind, each list keeping the source order:
    [new] and [abstract] methods share one list, because their position decides their slot in the generated code.
    Errors raised by a member get the position of the member, unless a more precise one is available.

    This function is not defined in the module interface.
*)
let mixin_decl ctx polys ((name, params, parent, members) : Cst.mixin_declaration) : Ast.mixin_decl =
  let env_for method_key = { ctx; polys; mixin = name; method_key } in
  let convert (ini_index, converted) (member : Cst.other_declaration Cst.located) =
    let loc = member.Cst.loc in
    Errors.adorn_error_with_span loc (fun () ->
        match member.Cst.value with
        | Cst.FieldDeclaration (field, ty) ->
          (ini_index, Field { Ast.field_name = field; field_type = mixin_expr ty; field_loc = loc } :: converted)
        | Cst.NewMethodDeclaration decl -> (ini_index, NewOrAbstract (new_method env_for loc decl) :: converted)
        | Cst.OverrideMethodDeclaration (return_type, overridden, meth, params, body) ->
          (ini_index, Override (override_method env_for loc (return_type, overridden, meth, params, body)) :: converted)
        | Cst.IniModuleDeclaration (header, header_mixin, inputs, outputs, body) ->
          let ini = ini_module ctx name env_for ini_index loc (header, header_mixin, inputs, outputs, body) in
          (ini_index + 1, IniModule ini :: converted)) in
  let (_, converted) = List.fold_left convert (0, []) members in
  let converted = List.rev converted in
  { Ast.mixin_name = name;
    mixin_polymorphism_params = List.map polymorphism_param params;
    mixin_parent = mixin_expr_or_void parent;
    mixin_fields = List.filter_map (function Field f -> Some f | _ -> None) converted;
    mixin_new_methods = List.filter_map (function NewOrAbstract m -> Some m | _ -> None) converted;
    mixin_override_methods = List.filter_map (function Override m -> Some m | _ -> None) converted;
    mixin_ini_module = List.filter_map (function IniModule m -> Some m | _ -> None) converted }

(** [global_decls ctx polys program] converts the declarations of [program];
    an include is replaced by the declarations of the included program.

    This function is not defined in the module interface.
*)
let rec global_decls ctx polys (program : resolved_program) : Ast.global_declaration list =
  List.concat_map (function
      | DeclarationMixin decl -> [ Ast.MixinDecl (mixin_decl ctx polys decl) ]
      | DeclarationLet (name, bound) -> [ Ast.LetDecl { Ast.let_name = name; let_bound = mixin_expr bound } ]
      | DeclarationInclude (_, included) -> global_decls ctx polys included)
    program

let ast (program : resolved_program) (ctx : ProgramContext.t) : Ast.program =
  global_decls ctx (collect_polys program StringMap.empty) program