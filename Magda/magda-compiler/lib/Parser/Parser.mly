%{

  (** Menhir grammar for the Magda language.
      Produce a {!Cst.program}, a semantically neutral representation of the source syntax.
      The grammar accepts a superset of semantically valid programs:
      any base_expression can be followed by suffixes (e.g. true.A.b),
      and any expression can appear as a standalone instruction (e.g. 5;).
      Semantic constraints are enforced by downstream passes.

      Known conflicts:
      - shift/Reduce on DOT in suffix: Menhir, after DOT ID,  always shifts to consume more tokens rather than reducing immediately.
        This may produce a semantically incorrect grouping, which should be corrected during name resolution in another module. 
  *)
  open Utils.Cst

(** [expression_to_lvalue expr] converts an expression parsed on the
     left side of [:=] into a {!Cst.l_value}.
     Raises [Failure] if the expression is not a valid l_value. 
*)
  let expression_to_lvalue = function
  | ExprSuffix(ThisExpr, SpecificFieldSelect(m, f)) -> MixinField(m, f)
  | ExprSuffix(ThisExpr, DirectFieldSelect(f)) -> DirectField(f)
  | IdExpr(v) -> Variable(v)
  | _ -> failwith "Parse error: invalid lvalue"
%}

(** TOKEN DECLARATION *)

(* Declarations and structure *)
%token INCLUDE LET BEGIN END MIXIN OF
%token NEW ABSTRACT OVERRIDE
%token REQUIRED OPTIONAL INITIALIZES WHERE

(*Control flow*)
%token IF ELSE WHILE RETURN

(*Literal and reference*)
%token NULL TRUE FALSE VOID THIS SUPER

(*Operators*)
%token EQEQ LTE GTE NEQ EQUALS LT GT PLUS MINUS TIMES DIVIDE

(*Punctuation*)
%token LPAREN RPAREN LBRACKET RBRACKET SEMICOLON COMMA DOT ASSIGN COLON

%token EOF

(*Tokens with value*)

%token <string> NATIVEINSTRUCTION
%token <string> ID
%token <string> BYTE_LITERAL
%token <float> FLOAT_LITERAL 
%token <int> INTEGER_LITERAL 
%token <string> STRING_LITERAL

(*da fare, precedenza e associatività se serve, da vedere*)

%start <program> program

%%

program:
| decls = list( global_declaration ) EOF { decls }

global_declaration:
| d = mixin_declaration SEMICOLON { DeclarationMixin d }
| d = let_declaration SEMICOLON { DeclarationLet d }
| d = include_declaration { DeclarationInclude d }

include_declaration:
| INCLUDE s = STRING_LITERAL SEMICOLON { s }

let_declaration:
| LET i = ID EQUALS expr = mixin_expression { (i, expr) }

mixin_declaration:
| MIXIN nome = ID poly=loption(delimited(LT, separated_nonempty_list(SEMICOLON, polymorphism_param), GT)) OF parent = mixin_expr_or_void EQUALS members=list(terminated(other_declaration, SEMICOLON)) END
 {(nome, poly, parent, members)}

polymorphism_param: 
| param = ID LTE expr = mixin_expression { (param, expr) }

mixin_expr_or_void:
| VOID { MixinVoid }
| m = mixin_expression { MixinExpr m }

other_declaration: 
| name = ID COLON mixtype = mixin_expression { FieldDeclaration (name , mixtype) }
| OVERRIDE rtype = mixin_expr_or_void mixname = ID DOT name = ID param = delimited(LPAREN, separated_list(SEMICOLON, parameter_decl), RPAREN) body = method_body { OverrideMethodDeclaration (rtype, mixname, name, param, body) }
| o = new_method_declaration { NewMethodDeclaration o }
| header = ini_module_header mixname = ID input = delimited(LPAREN, separated_list(SEMICOLON, input_init_param), RPAREN) INITIALIZES output = delimited(LPAREN, separated_list(COMMA, output_init_param), RPAREN) body = ini_module_body 
  { IniModuleDeclaration (header, mixname, input, output, body) }

parameter_decl:
| name = ID COLON mixtype = mixin_expression { (name, mixtype) }

method_body:
| vars = list(local_variable_declaration) BEGIN instrs = list(instruction) END
{ { met_local_vars = vars; instructions = instrs } }

new_method_declaration:
| ABSTRACT rtype = mixin_expr_or_void name = ID param = delimited(LPAREN, separated_list(SEMICOLON, parameter_decl), RPAREN) { AbsMet (rtype, name, param) }
| NEW rtype = mixin_expr_or_void name = ID param = delimited(LPAREN, separated_list(SEMICOLON, parameter_decl), RPAREN) body = method_body { NewMet (rtype, name, param, body) }

local_variable_declaration:
| name = ID COLON ltype = mixin_expression SEMICOLON { (name, ltype) }

ini_module_header:
| REQUIRED { Required }
| OPTIONAL { Optional }

input_init_param:
| pname = ID COLON ptype = mixin_expression { (pname, ptype) }

output_init_param:
| mixname = ID DOT pname = ID { (mixname, pname) }

ini_module_body:
| vars = list(local_variable_declaration) BEGIN pre_and_super = ini_pre_and_super_instructions post = list(instruction) END
{ let (pre, super) = pre_and_super in
 { ini_local_vars = vars;
instructions_pre_super = pre;
super_call = super;
instructions_post_super = post } }

(* Collects pre-super instructions and the super call in an ini module body.
   Resolves the SUPER shift/reduce conflict: both options shift SUPER, deferring the decision to the next token;
   LBRACKET for the module super call, LPAREN for a super method call inside an instruction.
   Guarantees exactly one super call per ini module body. 
*)
ini_pre_and_super_instructions: 
| SUPER super = delimited(LBRACKET, separated_list(COMMA, init_param) , RBRACKET) SEMICOLON { ([], super) }
| instr = instruction rest = ini_pre_and_super_instructions { let (pre, super) = rest in ( instr :: pre , super ) }

init_param:
| mixname = ID DOT pname = ID ASSIGN expr = expression { (mixname, pname, expr) }

mixin_expression:
| LPAREN e = mixin_expression RPAREN { RoundBracketMixinExpr e }
| name = ID rest = list(preceded(COMMA, mixin_concat)) { MixinExprComposition(name, rest) }

mixin_concat:
| name = ID { ElemId name }
| WHERE t1 = ID DOT t2 = ID ASSIGN LPAREN e = mixin_expression RPAREN { ElemHOApp (t1, t2, e) }
| LPAREN e = mixin_expression RPAREN { ElemRoundBracket e }

instruction:
| i = instruction_body SEMICOLON { i }

(* The body of an instruction, before the terminating semicolon.
   Assignment is separate from expression as statement by the presence of [:=];
   the left side is parsed as an expression and converted to l_value by expression_to_lvalue.
*)
instruction_body:
| exprlvalue = expression ASSIGN expr = expression { Assignment(expression_to_lvalue exprlvalue, expr) }
| expr = expression { ExprInstruction expr }
| RETURN expr = expression { Return expr }
| n = NATIVEINSTRUCTION { NativeInstruction n }
| WHILE LPAREN cond = expression RPAREN instrs = list(instruction) END { WhileLoop (cond, instrs) }
| IF LPAREN cond = expression RPAREN tinstr = list(instruction) finstr=option(preceded(ELSE, list(instruction))) END { IfCond (cond, tinstr, Option.value ~default:[] finstr) }

(* An expression is a base_expression optionally followed by binary operators.
   The left operand recurses on expression and the right is a base_expression, making binary operators left-associative.
   Suffixes bind tighter since they are defined inside base_expression. 
*)
expression:
| e = base_expression { e }
| e = expression op = binop b = base_expression { BinaryOp(op, e, b) }

base_expression:
| THIS { ThisExpr }
| SUPER super = delimited(LPAREN,separated_list(COMMA, expression),RPAREN) { SuperExpression super }
| TRUE { BoolLiteral true }
| FALSE { BoolLiteral false }
| v = BYTE_LITERAL { ByteLiteral v }
| v = INTEGER_LITERAL { IntegerLiteral v }
| v = FLOAT_LITERAL { FloatLiteral v }
| v = STRING_LITERAL { StringLiteral v }
| NULL { NullExpr }
| v = ID { IdExpr v }
| LPAREN expr = expression RPAREN { RoundBracketExpr expr }
| NEW expr = mixin_expression init = delimited(LBRACKET, separated_list(COMMA, init_param) , RBRACKET) { ObjectCreation (expr, init) }
| expr = base_expression s = suffix { ExprSuffix (expr, s) }

binop:
| PLUS { Add }
| MINUS { Sub }
| DIVIDE { Div }
| TIMES { Mul }
| EQEQ { StrongEq }
| EQUALS { Eq }
| LTE { Leq }
| LT { Lt }
| GTE { Geq }
| GT { Gt }
| NEQ { Neq }

(* A DOT initiated suffix for field access or method call.
   The DOT shift/reduce conflict causes Menhir to group greedily:
   [this.A.b] is always parsed as SpecificFieldSelect("A", "b"), 
   regardless of whether A is a mixin name or a field name.
*)
suffix:
| DOT i1 = ID DOT i2 = ID param = delimited(LPAREN,separated_list(COMMA, expression),RPAREN) { SpecificMethodCall (i1, i2, param) }
| DOT i = ID param = delimited(LPAREN,separated_list(COMMA, expression),RPAREN) { DirectMethodCall (i, param) }
| DOT i1 = ID DOT i2 = ID { SpecificFieldSelect (i1, i2) }
| DOT i = ID { DirectFieldSelect i }