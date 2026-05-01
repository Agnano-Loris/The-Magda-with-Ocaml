%{
  open Magda_cst.Cst

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
| vars = list(local_variable_declaration) BEGIN instrs = list(instruction) SUPER super = delimited(LBRACKET, separated_list(COMMA, init_param) , RBRACKET) SEMICOLON instrs2 = list(instruction) END
{ { ini_local_vars = vars;
instructions_pre_super = instrs;
super_call = super;
instructions_post_super = instrs2 } }

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

instruction_body:
| exprlvalue = expression ASSIGN expr = expression { Assignment(expression_to_value exprlvalue, expr) }
| expr = expression { ExprInstruction expr }
| RETURN expr = expression { Return expr }
| n = NATIVEINSTRUCTION { NativeInstruction n }
| WHILE LPAREN cond = expression RPAREN instrs = list(instruction) END { WhileLoop (cond, instrs) }
| IF LPAREN cond = expression RPAREN tinstr = list(instruction) finstr=option(preceded(ELSE, list(instruction))) END { IfCond (cond, tinstr, Option.value ~default:[] finstr) }

l_value:
| THIS DOT mixname = ID DOT fname = ID { MixinField(mixname, fname) }
| THIS DOT fname = ID { DirectField fname }
| vname = ID { Variable vname }

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

suffix:
| DOT i1 = ID DOT i2 = ID param = delimited(LPAREN,separated_list(COMMA, expression),RPAREN) { SpecificMethodCall (i1, i2, param) }
| DOT i = ID param = delimited(LPAREN,separated_list(COMMA, expression),RPAREN) { DirectMethodCall (i, param) }
| DOT i1 = ID DOT i2 = ID { SpecificFieldSelect (i1, i2) }
| DOT i = ID { DirectFieldSelect i }