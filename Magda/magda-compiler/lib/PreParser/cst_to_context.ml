open Utils
open Cst_resolve_includes

open PreParserStructures

let rec mixin_expr_root_id_name = function
| Cst.MixinExprComposition (name, _) -> name
| Cst.RoundBracketMixinExpr inner -> mixin_expr_root_id_name inner

let mixin_expr_head_type e = MagdaType.string_to_magdatype (mixin_expr_root_id_name e)
let extract_mixin_or_void_type = function 
| Cst.MixinVoid -> MagdaType.Void
| Cst.MixinExpr m -> mixin_expr_head_type m

let param_decl ((name, mixtype): Cst.parameter_decl) methCont = MethodContext.add_param name (mixin_expr_head_type mixtype) methCont

let add_local_vars (local_vars: Cst.local_variable_declaration list) methCont = 
  List.fold_left (fun methCont (name,mixtype) -> MethodContext.add_variable name (mixin_expr_head_type mixtype) methCont) methCont local_vars

let meth_body (body: Cst.method_body) methCont = 
  add_local_vars body.met_local_vars methCont 
let ini_module_body (inibody: Cst.ini_module_body) methCont =
  add_local_vars inibody.ini_local_vars methCont
let rec mixin_expr_ctx mixepr mixCont = match mixepr with
| Cst.MixinExprComposition (name, concatlist)-> let mixCont = MixinContext.add_linked_mixin name mixCont in
  List.fold_left (fun ctx mixconcat -> match mixconcat with 
  | Cst.ElemId id -> MixinContext.add_linked_mixin id ctx
  | Cst.ElemHOApp _ -> ctx
  | Cst.ElemRoundBracket e -> mixin_expr_ctx e ctx) mixCont concatlist
| Cst.RoundBracketMixinExpr inner -> mixin_expr_ctx inner mixCont

let new_meth_decl a mixCont = let methCont = MethodContext.empty () in match a with
| Cst.AbsMet (rtype, mixname, param) -> let restype = extract_mixin_or_void_type rtype in
let methCont = List.fold_left (fun methCont pdecl -> param_decl pdecl methCont) methCont param in 
let methCont = MethodContext.set_return_type (Some restype) methCont in
MixinContext.add_method mixname methCont mixCont
| Cst.NewMet (rtype, mixname, param, body) -> let restype = extract_mixin_or_void_type rtype in
let methCont = List.fold_left (fun methCont pdecl -> param_decl pdecl methCont) methCont param in 
let methCont = meth_body body methCont in
let methCont = MethodContext.set_return_type (Some restype) methCont in
MixinContext.add_method mixname methCont mixCont


let other_decl d current_mixin mixContext = match d with
| Cst.FieldDeclaration (name, expr) -> let ftype = mixin_expr_head_type expr in
MixinContext.add_field name ftype mixContext
| Cst.OverrideMethodDeclaration (rtype, mixname, name, param, body) -> let methCont = MethodContext.empty () in
let restype = extract_mixin_or_void_type rtype in
let methCont = List.fold_left (fun methCont pdecl -> param_decl pdecl methCont) methCont param in
let methCont = meth_body body methCont in
let methCont = MethodContext.set_return_type (Some restype) methCont in
MixinContext.add_method (mixname ^ "." ^ name) methCont mixContext
| Cst.NewMethodDeclaration o -> new_meth_decl o mixContext
| Cst.IniModuleDeclaration (_, _, input, _, body)-> let methCont = MethodContext.empty () in
let param_names = List.map fst input in
let methCont = List.fold_left (fun mc (name, expr) -> MethodContext.add_param name (mixin_expr_head_type expr) mc) methCont input in
let methCont = MethodContext.set_return_type (Some(MagdaType.string_to_magdatype current_mixin)) methCont in
let methCont = ini_module_body body methCont in
let result = MixinContext.add_inimodule param_names methCont mixContext in 
(match result with
| Ok mixCtx-> mixCtx
| Error err -> failwith ("Input parameter " ^ current_mixin ^ "." ^ err ^ " is declared in two different modules -> Line:")) (** Ricorda la gestione degli errori*)


let add_linked_mixin parent mixContext = match parent with
| Cst.MixinVoid -> MixinContext.add_linked_mixin "void" mixContext 
| Cst.MixinExpr m -> mixin_expr_ctx m mixContext  

let mix_decl (a:Cst.mixin_declaration) (ctx: ProgramContext.t) = 
  let res = MixinContext.empty () in 
  let (name, _, parent, members) = a in 
  let res = add_linked_mixin parent res in
  let res = List.fold_left (fun res odecl -> other_decl odecl name res) res members in
  ProgramContext.add_mixin name res ctx 

let rec global_decl a (ctx: ProgramContext.t) : ProgramContext.t = match a with
| DeclarationMixin a -> mix_decl a ctx
| DeclarationLet _ -> ctx
| DeclarationInclude (_fname, included_program) -> List.fold_left (fun ctx decl -> global_decl decl ctx) ctx included_program

let context (p:resolved_program) : ProgramContext.t = List.fold_left (fun ctx decl -> global_decl decl ctx) (ProgramContext.empty ())  p
