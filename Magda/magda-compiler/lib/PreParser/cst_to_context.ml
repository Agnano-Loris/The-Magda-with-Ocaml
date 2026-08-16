open Utils
open Cst_resolve_includes

open PreParserStructures

(** [mixin_expr_root_id_name mexpr] extracts the root identifier name from a {!Cst.mixin_expression}.
    Returns only the head name: [A, B] returns ["A"]. 
*)
let rec mixin_expr_root_id_name = function
| Cst.MixinExprComposition (name, _) -> name
| Cst.RoundBracketMixinExpr inner -> mixin_expr_root_id_name inner

(** [mixin_expr_head_type mexpr] extracts the head name from a {!Cst.mixin_expression}
    and converts it to a {!MagdaType.t} via {!MagdaType.string_to_magdatype}. 
*)
let mixin_expr_head_type mexpr = MagdaType.string_to_magdatype (mixin_expr_root_id_name mexpr)

(** [extract_mixin_or_void_type mev] converts a {!Cst.mixin_expr_or_void} to a {!MagdaType.t}:
    [MixinVoid] becomes [Void], a mixin expression is handled by [mixin_expr_head_type]. 
*)
let extract_mixin_or_void_type = function 
| Cst.MixinVoid -> MagdaType.Void
| Cst.MixinExpr m -> mixin_expr_head_type m

(** [param_decl (name, mixtype) methCont] adds a single formal parameter to [methCont] with its head type. *)
let param_decl ((name, mixtype): Cst.parameter_decl) methCont =
   MethodContext.add_param name (mixin_expr_head_type mixtype) methCont

(** [add_local_vars local_vars methCont] helper function that folds over [local_vars],
    adding each variable and its head type to [methCont].
*)
let add_local_vars (local_vars: Cst.local_variable_declaration list) methCont = 
  List.fold_left (fun methCont (name,mixtype) -> MethodContext.add_variable name (mixin_expr_head_type mixtype) methCont) methCont local_vars

(** [meth_body body methCont] adds the local variables, handled by [add_local_vars], from a method body to [methCont].
    The instructions are ignored. 
*)
let meth_body (body: Cst.method_body) methCont = 
  add_local_vars body.met_local_vars methCont 

(** [ini_module_body inibody methCont] adds the local variables, handled by [add_local_vars], from an ini module body to [methCont].
    Instructions, super call and output parameters are ignored.
*)
let ini_module_body (inibody: Cst.ini_module_body) methCont =
  add_local_vars inibody.ini_local_vars methCont

(** [mixin_expr_ctx mexpr mixCont] processes a {!Cst.mixin_expression} and adds each referenced mixin name to [mixCont] as a linked mixin.
    [ElemHOApp] elements are ignored. 
*)
let rec mixin_expr_ctx mixepr mixCont = match mixepr with
| Cst.MixinExprComposition (name, concatlist)-> let mixCont = MixinContext.add_linked_mixin name mixCont in
  List.fold_left (fun ctx mixconcat -> match mixconcat with 
  | Cst.ElemId id -> MixinContext.add_linked_mixin id ctx
  | Cst.ElemHOApp _ -> ctx
  | Cst.ElemRoundBracket e -> mixin_expr_ctx e ctx) mixCont concatlist
| Cst.RoundBracketMixinExpr inner -> mixin_expr_ctx inner mixCont

(** [new_meth_decl decl mixCont] processes a {!Cst.new_method_declaration}:
    creates a {!MethodContext.t} with parameters, return type, and local variables (for [NewMet] only),
    then registers it in [mixCont].
*)
let new_meth_decl a mixCont = let methCont = MethodContext.empty () in match a with
| Cst.AbsMet (rtype, metname, param) -> let restype = extract_mixin_or_void_type rtype in
let methCont = List.fold_left (fun methCont pdecl -> param_decl pdecl methCont) methCont param in 
let methCont = MethodContext.set_return_type (Some restype) methCont in
MixinContext.add_method metname methCont mixCont
| Cst.NewMet (rtype, metname, param, body) -> let restype = extract_mixin_or_void_type rtype in
let methCont = List.fold_left (fun methCont pdecl -> param_decl pdecl methCont) methCont param in 
let methCont = meth_body body methCont in
let methCont = MethodContext.set_return_type (Some restype) methCont in
MixinContext.add_method metname methCont mixCont

(** [other_decl decl current_mixin mixContext] processes a single member declaration of the mixin named [current_mixin]:
    - [FieldDeclaration]: adds the field and its head type
    - [OverrideMethodDeclaration]: builds a {!MethodContext.t} with parameters, local variables and return type,
      then registers as ["MixinName.methodName"] where [MixinName] is the mixin of the overridden method
    - [NewMethodDeclaration]: delegates to [new_meth_decl]
    - [IniModuleDeclaration]: builds an empty {!MethodContext.t} with input parameters and the containing mixin as return type,
      then registers it via {!MixinContext.add_inimodule}; 
      raises a [Failure] on duplicate parameters across ini modules
*)
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

(** [add_linked_mixin parent mixContext] adds the parent mixin(s) from the [of] clause:
    ["void"] for [MixinVoid], or make [mixin_expr_ctx] handle the case of a full mixin expression. 
*)
let add_linked_mixin parent mixContext = match parent with
| Cst.MixinVoid -> MixinContext.add_linked_mixin "void" mixContext 
| Cst.MixinExpr m -> mixin_expr_ctx m mixContext  

(** [mix_decl decl ctx] processes a {!Cst.mixin_declaration}:
    creates an empty {!MixinContext.t}, adds the linked mixins from the parent,
    folds over the members with [other_decl], and registers the result in [ctx].
    Polymorphism parameters are ignored. 
*)
let mix_decl (a:Cst.mixin_declaration) (ctx: ProgramContext.t) = 
  let res = MixinContext.empty () in 
  let (name, _, parent, members) = a in 
  let res = add_linked_mixin parent res in
  let res = List.fold_left (fun res odecl -> other_decl odecl name res) res members in
  ProgramContext.add_mixin name res ctx 

(** [global_decl decl ctx] processes a single {!resolved_global_declaration}:
    - mixin declarations are handled by [mix_decl].
    - let declarations are ignored
    - includes are processed by recursively folding over their resolved content. 
*)
let rec global_decl a (ctx: ProgramContext.t) : ProgramContext.t = match a with
| DeclarationMixin a -> mix_decl a ctx
| DeclarationLet _ -> ctx
| DeclarationInclude (_fname, included_program) -> List.fold_left (fun ctx decl -> global_decl decl ctx) ctx included_program

(** [context resolved_program] create an empty instance of a {!ProgramContext.t} that is used
    as accumulator during the informations extraction of each [resolved_global_declaration] through the function [global_decl]
*)
let context (p:resolved_program) : ProgramContext.t = List.fold_left (fun ctx decl -> global_decl decl ctx) (ProgramContext.empty ())  p
