open Ast

(** [indent depth] is the indentation of a line at nesting level [depth].

    This function is not defined in the module interface.
*)
let indent depth = String.make (2 * depth) ' '

(** [escape_string s] writes [s] with the escape sequences of Magda string literals;
    non-printable characters are written as octal escapes.

    This function is not defined in the module interface.
*)
let escape_string s =
  let buf = Buffer.create (String.length s + 8) in
  String.iter (fun c -> match c with
      | '\n' -> Buffer.add_string buf "\\n"
      | '\t' -> Buffer.add_string buf "\\t"
      | '\b' -> Buffer.add_string buf "\\b"
      | '\r' -> Buffer.add_string buf "\\r"
      | '\012' -> Buffer.add_string buf "\\f"
      | '\\' -> Buffer.add_string buf "\\\\"
      | '"' -> Buffer.add_string buf "\\\""
      | c when Char.code c < 32 || Char.code c >= 127 -> Printf.bprintf buf "\\%03o" (Char.code c)
      | c -> Buffer.add_char buf c) s;
  Buffer.contents buf

(** [float_literal f] writes [f] with the fewest digits that read back as [f], always with a decimal point.

    This function is not defined in the module interface.
*)
let float_literal f =
  let rec shortest precision =
    let s = Printf.sprintf "%.*g" precision f in
    if precision >= 17 || float_of_string s = f then s else shortest (precision + 1) in
  let s = shortest 1 in
  if String.contains s '.' || String.contains s 'e' || String.contains s 'n' then s else s ^ ".0"

(** [binop_to_string op] is the source symbol of [op].

    This function is not defined in the module interface.
*)
let binop_to_string = function
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/"
  | StrongEq -> "==" | Eq -> "=" | Neq -> "!=" | Leq -> "<=" | Less -> "<"

let rec mixin_expr_to_string = function
  | MixinExpressionId name -> name
  | MixinExpressionVoid -> "void"
  | MixinExpressionConcat { left_mixin; right_mixin } ->
    mixin_expr_to_string left_mixin ^ ", " ^ concat_element right_mixin
  | MixinExpressionApplication { app_mixin_name; app_param_name; app_value } ->
    Printf.sprintf "where %s.%s := (%s)" app_mixin_name app_param_name (mixin_expr_to_string app_value)

(** [concat_element mexpr] prints the right side of a concatenation, in parentheses if it is a concatenation itself.

    This function is not defined in the module interface.
*)
and concat_element = function
  | MixinExpressionConcat _ as mexpr -> "(" ^ mixin_expr_to_string mexpr ^ ")"
  | mexpr -> mixin_expr_to_string mexpr

let rec expression_to_string = function
  | ThisExpression -> "this"
  | NullExpression -> "null"
  | IntegerLiteral n -> string_of_int n
  | BooleanLiteral b -> string_of_bool b
  | FloatLiteral f -> float_literal f
  | ByteLiteral b -> b
  | StringLiteral s -> "\"" ^ escape_string s ^ "\""
  | Identifier name -> name
  | SuperExpression args -> "super(" ^ args_to_string args ^ ")"
  | MethodCallExpression { method_call_target; method_call_mixin_name; method_call_method_name; method_call_params } ->
    Printf.sprintf "%s.%s.%s(%s)" (target_to_string method_call_target)
      method_call_mixin_name method_call_method_name (args_to_string method_call_params)
  | FieldSelectExpression { field_selection_target; field_selection_mixin_name; field_selection_field_name } ->
    Printf.sprintf "%s.%s.%s" (target_to_string field_selection_target)
      field_selection_mixin_name field_selection_field_name
  | ObjectCreationExpression { object_creation_mixin_expr; object_creation_init_params } ->
    Printf.sprintf "new %s[%s]" (mixin_expr_to_string object_creation_mixin_expr)
      (String.concat ", " (List.map init_param_to_string object_creation_init_params))
  | BinaryOperation (op, left, right) ->
    Printf.sprintf "%s %s %s" (expression_to_string left) (binop_to_string op) (right_operand right)

(** [target_to_string expr] prints the target of a suffix, in parentheses if it is an operation or an object creation.

    This function is not defined in the module interface.
*)
and target_to_string = function
  | (BinaryOperation _ | ObjectCreationExpression _) as expr -> "(" ^ expression_to_string expr ^ ")"
  | expr -> expression_to_string expr

(** [right_operand expr] prints the right operand of an operation, in parentheses if it is an operation:
    operators are left associative and share one precedence level.

    This function is not defined in the module interface.
*)
and right_operand = function
  | BinaryOperation _ as expr -> "(" ^ expression_to_string expr ^ ")"
  | expr -> expression_to_string expr

(** [args_to_string args] prints actual parameters separated by commas.

    This function is not defined in the module interface.
*)
and args_to_string args = String.concat ", " (List.map expression_to_string args)

(** [init_param_to_string param] prints [M.p := expr].

    This function is not defined in the module interface.
*)
and init_param_to_string { imixin_name; iparam_name; ivalue } =
  Printf.sprintf "%s.%s := %s" imixin_name iparam_name (expression_to_string ivalue)

(** [lvalue_to_string lv] prints the left side of an assignment.

    This function is not defined in the module interface.
*)
let lvalue_to_string = function
  | VariableLValue name -> name
  | FieldLValue { field_lvalue_mixin_name; field_lvalue_field_name } ->
    Printf.sprintf "this.%s.%s" field_lvalue_mixin_name field_lvalue_field_name

(** [escape_native code] escapes [%] inside a native instruction.

    This function is not defined in the module interface.
*)
let escape_native code =
  String.concat "\\%" (String.split_on_char '%' code)

(** [instruction_to_string depth instr] prints an instruction at nesting level [depth], with its newline.

    This function is not defined in the module interface.
*)
let rec instruction_to_string depth (instr : instruction located) =
  let pad = indent depth in
  match instr.value with
  | Assignment (lv, value) -> Printf.sprintf "%s%s := %s;\n" pad (lvalue_to_string lv) (expression_to_string value)
  | ExprInstruction expr -> Printf.sprintf "%s%s;\n" pad (expression_to_string expr)
  | ReturnInstruction expr -> Printf.sprintf "%sreturn %s;\n" pad (expression_to_string expr)
  | NativeInstruction code -> Printf.sprintf "%s%%%s%%;\n" pad (escape_native code)
  | WhileInstruction { while_condition; while_instructions } ->
    Printf.sprintf "%swhile (%s)\n%s%send;\n" pad (expression_to_string while_condition)
      (instructions_to_string (depth + 1) while_instructions) pad
  | IfInstruction { if_condition; if_true_instructions; if_false_instructions } ->
    let else_branch = match if_false_instructions with
      | [] -> ""
      | instrs -> Printf.sprintf "%selse\n%s" pad (instructions_to_string (depth + 1) instrs) in
    Printf.sprintf "%sif (%s)\n%s%s%send;\n" pad (expression_to_string if_condition)
      (instructions_to_string (depth + 1) if_true_instructions) else_branch pad

(** [instructions_to_string depth instrs] prints a sequence of instructions.

    This function is not defined in the module interface.
*)
and instructions_to_string depth instrs = String.concat "" (List.map (instruction_to_string depth) instrs)

(** [params_to_string params] prints formal parameters separated by [;].

    This function is not defined in the module interface.
*)
let params_to_string params =
  String.concat "; "
    (List.map (fun { param_name; param_type } -> param_name ^ " : " ^ mixin_expr_to_string param_type) params)

(** [variables_to_string depth vars] prints local variable declarations, one per line.

    This function is not defined in the module interface.
*)
let variables_to_string depth vars =
  String.concat ""
    (List.map (fun { var_name; var_type } ->
         Printf.sprintf "%s%s : %s;\n" (indent depth) var_name (mixin_expr_to_string var_type)) vars)

(** [method_body_to_string body] prints the body of a method declared at nesting level 1.

    This function is not defined in the module interface.
*)
let method_body_to_string { method_local_variables; method_instructions } =
  variables_to_string 2 method_local_variables ^ indent 1 ^ "begin\n"
  ^ instructions_to_string 2 method_instructions ^ indent 1 ^ "end"

(** [new_method_to_string decl] prints a [new] or [abstract] method.

    This function is not defined in the module interface.
*)
let new_method_to_string = function
  | NewMethod { new_method_name; new_method_params; new_method_return_type; new_method_body; _ } ->
    Printf.sprintf "%snew %s %s(%s)\n%s;\n" (indent 1) (mixin_expr_to_string new_method_return_type)
      new_method_name (params_to_string new_method_params) (method_body_to_string new_method_body)
  | AbstractMethod { abstract_method_name; abstract_method_params; abstract_method_return_type; _ } ->
    Printf.sprintf "%sabstract %s %s(%s);\n" (indent 1) (mixin_expr_to_string abstract_method_return_type)
      abstract_method_name (params_to_string abstract_method_params)

(** [override_method_to_string decl] prints an [override] method.

    This function is not defined in the module interface.
*)
let override_method_to_string { override_method_name; override_method_mixin_overridden; override_method_params;
                                override_method_return_type; override_method_body; _ } =
  Printf.sprintf "%soverride %s %s.%s(%s)\n%s;\n" (indent 1) (mixin_expr_to_string override_method_return_type)
    override_method_mixin_overridden override_method_name (params_to_string override_method_params)
    (method_body_to_string override_method_body)

(** [ini_module_to_string decl] prints an ini module, with its super call between the two instruction sequences.

    This function is not defined in the module interface.
*)
let ini_module_to_string { is_required; ini_module_mixin_name; in_params; out_params; ini_module_body; _ } =
  let inputs = String.concat "; "
      (List.map (fun { input_param_name; input_param_type; _ } ->
           input_param_name ^ " : " ^ mixin_expr_to_string input_param_type) in_params) in
  let outputs = String.concat ", "
      (List.map (fun { output_param_mixin; output_param_name } -> output_param_mixin ^ "." ^ output_param_name)
         out_params) in
  let { ini_module_variables; ini_module_instructions_precall; ini_module_super; ini_module_instructions_postcall } =
    ini_module_body in
  Printf.sprintf "%s%s %s(%s) initializes (%s)\n%s%sbegin\n%s%ssuper[%s];\n%s%send;\n"
    (indent 1) (if is_required then "required" else "optional") ini_module_mixin_name inputs outputs
    (variables_to_string 2 ini_module_variables) (indent 1)
    (instructions_to_string 2 ini_module_instructions_precall)
    (indent 2) (String.concat ", " (List.map init_param_to_string ini_module_super.super_params))
    (instructions_to_string 2 ini_module_instructions_postcall) (indent 1)

(** [mixin_to_string decl] prints a mixin declaration; members are grouped by kind.

    This function is not defined in the module interface.
*)
let mixin_to_string { mixin_name; mixin_polymorphism_params; mixin_parent; mixin_fields; mixin_new_methods;
                      mixin_override_methods; mixin_ini_module } =
  let polys = match mixin_polymorphism_params with
    | [] -> ""
    | params -> "<" ^ String.concat "; "
                  (List.map (fun { poly_name; poly_bound } -> poly_name ^ " <= " ^ mixin_expr_to_string poly_bound)
                     params) ^ ">" in
  let fields = List.map (fun { field_name; field_type; _ } ->
      Printf.sprintf "%s%s : %s;\n" (indent 1) field_name (mixin_expr_to_string field_type)) mixin_fields in
  let members = fields @ List.map new_method_to_string mixin_new_methods
                @ List.map override_method_to_string mixin_override_methods
                @ List.map ini_module_to_string mixin_ini_module in
  Printf.sprintf "mixin %s%s of %s =\n%send;" mixin_name polys (mixin_expr_to_string mixin_parent)
    (String.concat "\n" members)

let global_declaration_to_string = function
  | MixinDecl decl -> mixin_to_string decl
  | LetDecl { let_name; let_bound } -> Printf.sprintf "let %s = %s;" let_name (mixin_expr_to_string let_bound)

let program_to_string program =
  String.concat "\n\n" (List.map global_declaration_to_string program) ^ "\n"
