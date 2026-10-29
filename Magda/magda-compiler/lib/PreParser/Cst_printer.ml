open Utils

(** A generic tree, built from the CST and then laid out:
    [Node (name, children)] is printed as [name(child, ...)], [List items] as [[item; ...]],
    [Leaf s] as [s].

    This type is not defined in the module interface.
*)
type tree =
  | Node of string * tree list
  | List of tree list
  | Leaf of string

(** Width beyond which a node is split over several lines.

    This value is not defined in the module interface.
*)
let max_width = 100

(** [flat tree] prints [tree] on a single line.

    This function is not defined in the module interface.
*)
let rec flat = function
  | Leaf s -> s
  | Node (name, []) -> name
  | Node (name, children) -> name ^ "(" ^ String.concat ", " (List.map flat children) ^ ")"
  | List items -> "[" ^ String.concat "; " (List.map flat items) ^ "]"

(** [layout depth tree] prints [tree] at indentation [depth]: on one line if it fits in [max_width],
    otherwise with one child per line.

    This function is not defined in the module interface.
*)
let rec layout depth tree =
  let pad = String.make (2 * depth) ' ' in
  let one_line = flat tree in
  if String.length pad + String.length one_line <= max_width then pad ^ one_line
  else match tree with
    | Leaf s -> pad ^ s
    | Node (name, []) -> pad ^ name
    | Node (name, children) ->
      pad ^ name ^ "(\n" ^ String.concat ",\n" (List.map (layout (depth + 1)) children) ^ "\n" ^ pad ^ ")"
    | List items ->
      pad ^ "[\n" ^ String.concat ";\n" (List.map (layout (depth + 1)) items) ^ "\n" ^ pad ^ "]"

(** [position span] is the start of [span] as [row:column].

    This function is not defined in the module interface.
*)
let position ((start, _) : Errors.span) =
  Printf.sprintf "%d:%d" start.Lexing.pos_lnum (start.Lexing.pos_cnum - start.Lexing.pos_bol + 1)

(** [located convert l] converts [l.value] and appends the position of [l] to the name of its root node.

    This function is not defined in the module interface.
*)
let located convert (l : 'a Cst.located) =
  let tag = "@" ^ position l.Cst.loc in
  match convert l.Cst.value with
  | Node (name, children) -> Node (name ^ " " ^ tag, children)
  | other -> Node (tag, [ other ])

(* Converters from CST types to trees: one function per CST type, named after the type.
   None of them is defined in the module interface. *)

let id name = Leaf name

let str s = Leaf (Printf.sprintf "%S" s)

let binop = function
  | Cst.Add -> "Add" | Cst.Sub -> "Sub" | Cst.Div -> "Div" | Cst.Mul -> "Mul" | Cst.StrongEq -> "StrongEq"
  | Cst.Eq -> "Eq" | Cst.Leq -> "Leq" | Cst.Lt -> "Lt" | Cst.Geq -> "Geq" | Cst.Gt -> "Gt" | Cst.Neq -> "Neq"

let rec mixin_expression = function
  | Cst.RoundBracketMixinExpr inner -> Node ("RoundBracketMixinExpr", [ mixin_expression inner ])
  | Cst.MixinExprComposition (head, rest) ->
    Node ("MixinExprComposition", [ id head; List (List.map mixin_concat rest) ])

and mixin_concat = function
  | Cst.ElemId name -> Node ("ElemId", [ id name ])
  | Cst.ElemHOApp (mixin, param, value) -> Node ("ElemHOApp", [ id mixin; id param; mixin_expression value ])
  | Cst.ElemRoundBracket inner -> Node ("ElemRoundBracket", [ mixin_expression inner ])

let mixin_expr_or_void = function
  | Cst.MixinVoid -> Leaf "MixinVoid"
  | Cst.MixinExpr mexpr -> Node ("MixinExpr", [ mixin_expression mexpr ])

let rec expression = function
  | Cst.ThisExpr -> Leaf "This"
  | Cst.SuperExpression args -> Node ("SuperExpression", [ List (List.map expression args) ])
  | Cst.BoolLiteral b -> Node ("BoolLiteral", [ Leaf (string_of_bool b) ])
  | Cst.ByteLiteral b -> Node ("ByteLiteral", [ Leaf b ])
  | Cst.IntegerLiteral n -> Node ("IntegerLiteral", [ Leaf (string_of_int n) ])
  | Cst.FloatLiteral f -> Node ("FloatLiteral", [ Leaf (string_of_float f) ])
  | Cst.StringLiteral s -> Node ("StringLiteral", [ str s ])
  | Cst.NullExpr -> Leaf "Null"
  | Cst.IdExpr name -> Node ("IdExpr", [ id name ])
  | Cst.RoundBracketExpr inner -> Node ("RoundBracketExpr", [ expression inner ])
  | Cst.ObjectCreation (mexpr, params) ->
    Node ("ObjectCreation", [ mixin_expression mexpr; List (List.map init_param params) ])
  | Cst.BinaryOp (op, left, right) -> Node ("BinaryOp", [ Leaf (binop op); expression left; expression right ])
  | Cst.ExprSuffix (target, s) -> Node ("ExprSuffix", [ expression target; suffix s ])

and init_param (mixin, param, value) = Node ("InitParam", [ id mixin; id param; expression value ])

and suffix = function
  | Cst.SpecificMethodCall (first, meth, args) ->
    Node ("SpecificMethodCall", [ id first; id meth; List (List.map expression args) ])
  | Cst.DirectMethodCall (meth, args) -> Node ("DirectMethodCall", [ id meth; List (List.map expression args) ])
  | Cst.SpecificFieldSelect (first, second) -> Node ("SpecificFieldSelect", [ id first; id second ])
  | Cst.DirectFieldSelect field -> Node ("DirectFieldSelect", [ id field ])

let l_value = function
  | Cst.MixinField (mixin, field) -> Node ("MixinField", [ id mixin; id field ])
  | Cst.DirectField field -> Node ("DirectField", [ id field ])
  | Cst.Variable name -> Node ("Variable", [ id name ])

let rec instruction = function
  | Cst.Assignment (lv, value) -> Node ("Assignment", [ l_value lv; expression value ])
  | Cst.ExprInstruction expr -> Node ("ExprInstruction", [ expression expr ])
  | Cst.Return expr -> Node ("Return", [ expression expr ])
  | Cst.NativeInstruction code -> Node ("NativeInstruction", [ str code ])
  | Cst.WhileLoop (cond, body) -> Node ("WhileLoop", [ expression cond; instructions body ])
  | Cst.IfCond (cond, t, f) -> Node ("IfCond", [ expression cond; instructions t; instructions f ])

and instructions instrs = List (List.map (located instruction) instrs)

let typed (name, ty) = Node (name, [ mixin_expression ty ])

let method_body (body : Cst.method_body) =
  Node ("MethodBody", [ List (List.map typed body.Cst.met_local_vars); instructions body.Cst.instructions ])

let ini_module_body (body : Cst.ini_module_body) =
  Node ("IniModuleBody",
        [ List (List.map typed body.Cst.ini_local_vars);
          instructions body.Cst.instructions_pre_super;
          located (fun params -> Node ("SuperCall", List.map init_param params)) body.Cst.super_call;
          instructions body.Cst.instructions_post_super ])

let other_declaration = function
  | Cst.FieldDeclaration (name, ty) -> Node ("FieldDeclaration", [ id name; mixin_expression ty ])
  | Cst.OverrideMethodDeclaration (rt, mixin, name, params, body) ->
    Node ("OverrideMethodDeclaration",
          [ mixin_expr_or_void rt; id mixin; id name; List (List.map typed params); method_body body ])
  | Cst.NewMethodDeclaration (Cst.AbsMet (rt, name, params)) ->
    Node ("AbsMet", [ mixin_expr_or_void rt; id name; List (List.map typed params) ])
  | Cst.NewMethodDeclaration (Cst.NewMet (rt, name, params, body)) ->
    Node ("NewMet", [ mixin_expr_or_void rt; id name; List (List.map typed params); method_body body ])
  | Cst.IniModuleDeclaration (header, mixin, inputs, outputs, body) ->
    Node ("IniModuleDeclaration",
          [ Leaf (match header with Cst.Required -> "Required" | Cst.Optional -> "Optional");
            id mixin; List (List.map typed inputs);
            List (List.map (fun (m, p) -> Leaf (m ^ "." ^ p)) outputs);
            ini_module_body body ])

let global_declaration = function
  | Cst.DeclarationMixin (name, polys, parent, members) ->
    Node ("DeclarationMixin",
          [ id name; List (List.map typed polys); mixin_expr_or_void parent;
            List (List.map (located other_declaration) members) ])
  | Cst.DeclarationLet (name, bound) -> Node ("DeclarationLet", [ id name; mixin_expression bound ])
  | Cst.DeclarationInclude path -> located (fun p -> Node ("DeclarationInclude", [ str p ])) path

let expression_to_string expr = layout 0 (expression expr)

let program_to_string program =
  String.concat "\n\n" (List.map (fun decl -> layout 0 (global_declaration decl)) program) ^ "\n"
