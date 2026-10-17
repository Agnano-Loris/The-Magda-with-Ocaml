open Utils
open Cst_resolve_includes
open PreParserStructures

module Ast = Program_tree.Ast

let resolution_error message = Errors.magda_raise Errors.ResolutionPhase message

type env = {
  ctx : ProgramContext.t;
  polys : MagdaType.t StringMap.t StringMap.t;
  mixin : string;
  method_key : string;
}

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

let type_of_names = function
  | [ name ] -> MagdaType.string_to_magdatype name
  | names -> MagdaType.Composite names

let substitute_poly env owner (ty : MagdaType.t option) = match ty with
  | Some ((MagdaType.MixinType _ | MagdaType.Composite _) as t) ->
    let bounds = Option.value ~default:StringMap.empty (StringMap.find_opt owner env.polys) in
    let substitute name = match StringMap.find_opt name bounds with
      | Some bound -> MagdaType.names bound
      | None -> [ name ] in
    Some (type_of_names (List.concat_map substitute (MagdaType.names t)))
  | _ -> ty

let rec mixin_expr (mexpr : Cst.mixin_expression) : Ast.mixin_expr = match mexpr with
  | Cst.RoundBracketMixinExpr inner -> mixin_expr inner
  | Cst.MixinExprComposition (head, rest) ->
    List.fold_left
      (fun left elem -> Ast.MixinExpressionConcat { Ast.left_mixin = left; right_mixin = mixin_concat elem })
      (Ast.MixinExpressionId head) rest

and mixin_concat : Cst.mixin_concat -> Ast.mixin_expr = function
  | Cst.ElemId name -> Ast.MixinExpressionId name
  | Cst.ElemHOApp (mixin, param, value) ->
    Ast.MixinExpressionApplication { Ast.app_mixin_name = mixin; app_param_name = param; app_value = mixin_expr value }
  | Cst.ElemRoundBracket inner -> mixin_expr inner

let mixin_expr_or_void : Cst.mixin_expr_or_void -> Ast.mixin_expr = function
  | Cst.MixinVoid -> Ast.MixinExpressionVoid
  | Cst.MixinExpr mexpr -> mixin_expr mexpr

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

let binary_type : Cst.binop -> MagdaType.t option = function
  | Cst.Add | Cst.Sub | Cst.Mul | Cst.Div -> None
  | Cst.StrongEq | Cst.Eq | Cst.Neq | Cst.Leq | Cst.Lt | Cst.Gt | Cst.Geq -> Some MagdaType.Bool

let target_type kind name (ty : MagdaType.t option) = match ty with
  | None ->
    resolution_error (Printf.sprintf "Cannot resolve the %s %s: the type of its target is unknown, qualify the access" kind name)
  | Some MagdaType.Void ->
    resolution_error (Printf.sprintf "Cannot resolve the %s %s: its target has type void" kind name)
  | Some t -> t

let owners query member (ty : MagdaType.t) =
  List.fold_left (fun acc mixin -> StringSet.union acc (query member mixin)) StringSet.empty (MagdaType.names ty)

let unique_owner kind name ty owners =
  let type_name = MagdaType.to_string ty in
  match StringSet.elements owners with
  | [ owner ] -> owner
  | [] -> resolution_error (Printf.sprintf "No %s named %s for mixin of type %s" kind name type_name)
  | candidates ->
    resolution_error (Printf.sprintf "Ambiguous %s %s for mixin of type %s, possible mixins: %s"
                        kind name type_name (String.concat ", " candidates))

let abbreviated_field env field ty =
  let ty = target_type "field" field ty in
  let query field mixin = ProgramContext.contains_unambiguous_field field mixin env.ctx in
  let owner = unique_owner "field" field ty (owners query field ty) in
  (owner, substitute_poly env owner (ProgramContext.get_field_type field owner env.ctx))

let abbreviated_method env meth ty =
  let ty = target_type "method" meth ty in
  let query meth mixin = ProgramContext.contains_unambiguous_method meth mixin env.ctx in
  let owner = unique_owner "method" meth ty (owners query meth ty) in
  (owner, substitute_poly env owner (ProgramContext.get_method_return_type meth owner env.ctx))

let check_mixin env mixin =
  if not (ProgramContext.contains_mixin mixin env.ctx) then
    resolution_error (Printf.sprintf "Mixin %s has never been declared" mixin)

let qualified_field env mixin field =
  check_mixin env mixin;
  match ProgramContext.get_field_type field mixin env.ctx with
  | Some _ as ty -> substitute_poly env mixin ty
  | None -> resolution_error (Printf.sprintf "No field named %s in mixin %s" field mixin)

let qualified_method env mixin meth =
  check_mixin env mixin;
  if ProgramContext.contains_method meth mixin env.ctx then
    substitute_poly env mixin (ProgramContext.get_method_return_type meth mixin env.ctx)
  else resolution_error (Printf.sprintf "No method named %s in mixin %s" meth mixin)

type atom =
  | Name of string
  | Call of string * Cst.expression list

let atoms_of_suffix : Cst.suffix -> atom list = function
  | Cst.SpecificMethodCall (first, meth, args) -> [ Name first; Call (meth, args) ]
  | Cst.DirectMethodCall (meth, args) -> [ Call (meth, args) ]
  | Cst.SpecificFieldSelect (first, second) -> [ Name first; Name second ]
  | Cst.DirectFieldSelect field -> [ Name field ]

let rec flatten (expr : Cst.expression) atoms = match expr with
  | Cst.ExprSuffix (inner, suffix) -> flatten inner (atoms_of_suffix suffix @ atoms)
  | base -> (base, atoms)

let field_select target mixin field =
  Ast.FieldSelectExpression
    { Ast.field_selection_target = target; field_selection_mixin_name = mixin; field_selection_field_name = field }

let method_call target mixin meth args =
  Ast.MethodCallExpression
    { Ast.method_call_target = target; method_call_mixin_name = mixin;
      method_call_method_name = meth; method_call_params = args }

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
  | Cst.IdExpr name ->
    (Ast.Identifier name,
     substitute_poly env env.mixin (ProgramContext.get_method_variable_type name env.method_key env.mixin env.ctx))
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

and resolve_args env args = List.map (fun arg -> fst (resolve_expr env arg)) args

and init_param env ((mixin, param, value) : Cst.init_param) : Ast.init_param =
  { Ast.imixin_name = mixin; iparam_name = param; ivalue = fst (resolve_expr env value) }

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

let lvalue env : Cst.l_value -> Ast.lvalue = function
  | Cst.Variable name -> Ast.VariableLValue name
  | Cst.MixinField (mixin, field) ->
    ignore (qualified_field env mixin field);
    Ast.FieldLValue { Ast.field_lvalue_mixin_name = mixin; field_lvalue_field_name = field }
  | Cst.DirectField field ->
    let (owner, _) = abbreviated_field env field (Some (MagdaType.string_to_magdatype env.mixin)) in
    Ast.FieldLValue { Ast.field_lvalue_mixin_name = owner; field_lvalue_field_name = field }

let rec instruction env (instr : Cst.instruction Cst.located) : Ast.instruction Ast.located =
  Errors.adorn_error_with_span instr.Cst.loc
    (fun () -> { instr with Cst.value = instruction_body env instr.Cst.value })

and instruction_body env : Cst.instruction -> Ast.instruction = function
  | Cst.Assignment (lv, value) -> Ast.Assignment (lvalue env lv, fst (resolve_expr env value))
  | Cst.ExprInstruction expr -> Ast.ExprInstruction (fst (resolve_expr env expr))
  | Cst.Return expr -> Ast.ReturnInstruction (fst (resolve_expr env expr))
  | Cst.NativeInstruction code -> Ast.NativeInstruction code
  | Cst.WhileLoop (cond, body) ->
    Ast.WhileInstruction
      { Ast.while_condition = fst (resolve_expr env cond);
        while_instructions = List.map (instruction env) body }
  | Cst.IfCond (cond, true_branch, false_branch) ->
    Ast.IfInstruction
      { Ast.if_condition = fst (resolve_expr env cond);
        if_true_instructions = List.map (instruction env) true_branch;
        if_false_instructions = List.map (instruction env) false_branch }

let variable_decl ((name, ty) : Cst.local_variable_declaration) : Ast.variable_decl =
  { Ast.var_name = name; var_type = mixin_expr ty }

let parameter_decl ((name, ty) : Cst.parameter_decl) : Ast.parameter_decl =
  { Ast.param_name = name; param_type = mixin_expr ty }

let polymorphism_param ((name, bound) : Cst.polymorphism_param) : Ast.polymorphism_param =
  { Ast.poly_name = name; poly_bound = mixin_expr bound }

let method_body env (body : Cst.method_body) : Ast.method_body =
  { Ast.method_local_variables = List.map variable_decl body.Cst.met_local_vars;
    method_instructions = List.map (instruction env) body.Cst.instructions }

let ini_module_body env (body : Cst.ini_module_body) : Ast.ini_module_body =
  let call = body.Cst.super_call in
  { Ast.ini_module_variables = List.map variable_decl body.Cst.ini_local_vars;
    ini_module_instructions_precall = List.map (instruction env) body.Cst.instructions_pre_super;
    ini_module_super =
      { Ast.super_params =
          Errors.adorn_error_with_span call.Cst.loc (fun () -> List.map (init_param env) call.Cst.value);
        super_loc = call.Cst.loc };
    ini_module_instructions_postcall = List.map (instruction env) body.Cst.instructions_post_super }

let field_member loc : Cst.other_declaration -> Ast.field_decl option = function
  | Cst.FieldDeclaration (name, ty) -> Some { Ast.field_name = name; field_type = mixin_expr ty; field_loc = loc }
  | _ -> None

let new_member env_for loc : Cst.other_declaration -> Ast.new_method_declaration option = function
  | Cst.NewMethodDeclaration (Cst.AbsMet (return_type, name, params)) ->
    Some (Ast.AbstractMethod
            { Ast.abstract_method_name = name;
              abstract_method_params = List.map parameter_decl params;
              abstract_method_return_type = mixin_expr_or_void return_type;
              abstract_method_loc = loc })
  | Cst.NewMethodDeclaration (Cst.NewMet (return_type, name, params, body)) ->
    Some (Ast.NewMethod
            { Ast.new_method_name = name;
              new_method_params = List.map parameter_decl params;
              new_method_return_type = mixin_expr_or_void return_type;
              new_method_body = method_body (env_for name) body;
              new_method_loc = loc })
  | _ -> None

let override_member env_for loc : Cst.other_declaration -> Ast.override_method option = function
  | Cst.OverrideMethodDeclaration (return_type, overridden, name, params, body) ->
    Some { Ast.override_method_name = name;
           override_method_mixin_overridden = overridden;
           override_method_params = List.map parameter_decl params;
           override_method_return_type = mixin_expr_or_void return_type;
           override_method_body = method_body (env_for (overridden ^ "." ^ name)) body;
           override_method_loc = loc }
  | _ -> None

let ini_member (member : Cst.other_declaration Cst.located) = match member.Cst.value with
  | Cst.IniModuleDeclaration (header, header_mixin, inputs, outputs, body) ->
    Some (member.Cst.loc, (header, header_mixin, inputs, outputs, body))
  | _ -> None

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

let mixin_decl ctx polys ((name, params, parent, members) : Cst.mixin_declaration) : Ast.mixin_decl =
  let env_for method_key = { ctx; polys; mixin = name; method_key } in
  let members_of convert =
    List.filter_map
      (fun (member : Cst.other_declaration Cst.located) ->
         Errors.adorn_error_with_span member.Cst.loc (fun () -> convert member.Cst.loc member.Cst.value))
      members in
  { Ast.mixin_name = name;
    mixin_polymorphism_params = List.map polymorphism_param params;
    mixin_parent = mixin_expr_or_void parent;
    mixin_fields = members_of field_member;
    mixin_new_methods = members_of (new_member env_for);
    mixin_override_methods = members_of (override_member env_for);
    mixin_ini_module =
      List.mapi
        (fun index (loc, decl) ->
           Errors.adorn_error_with_span loc (fun () -> ini_module ctx name env_for index loc decl))
        (List.filter_map ini_member members) }

let rec global_decls ctx polys (program : resolved_program) : Ast.global_declaration list =
  List.concat_map (function
      | DeclarationMixin decl -> [ Ast.MixinDecl (mixin_decl ctx polys decl) ]
      | DeclarationLet (name, bound) -> [ Ast.LetDecl { Ast.let_name = name; let_bound = mixin_expr bound } ]
      | DeclarationInclude (_, included) -> global_decls ctx polys included)
    program

let ast (program : resolved_program) (ctx : ProgramContext.t) : Ast.program =
  global_decls ctx (collect_polys program StringMap.empty) program