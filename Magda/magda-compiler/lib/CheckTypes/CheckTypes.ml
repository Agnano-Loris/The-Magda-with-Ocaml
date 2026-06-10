open ProgramTree.Ast
open ModuleSignatures
open Types.EnvTypes

module TypeElement = TypeElementUtilities.CycleFix.TypeElementImpl
module TypeElements = TypeElementUtilities.CycleFix.TypeElementsImpl

module Make (GDecl : DeclSignatures.GLOBAL_DECL) (GEnv : EnvSig.ENV) (MethodEnv : EnvSig.METHOD_ENV) (InstrEnv : EnvSig.INSTR_ENV) (InimoduleEnv : EnvSig.INIMODULE_ENV) = struct
  let check_program (env : GEnv.t): unit =
    check_global_declarations env

  let check_global_declarations (env : GEnv.t) : unit = 
    let global_env = env.new_enviroment env.calculated_types env.decls in
      List.map (fun decl ->
        match decl with
        | MixinDecl mixin_decl -> 
          check_mixin_decl global_env mixin_decl
        | LetDecl {let_name; bound} ->
          check_let_decl global_env bound
      )

  let rec check_mixin_decl (env : GEnv.t) (mixin_decl : mixin_decl) : unit =
    check_mixin_expr env mixin_decl.mixin_parent;
    let method_env = MethodEnv.new_method_environment env mixin_decl in
      List.map (fun field -> check_mixin_expr method_env field.field_type) mixin_decl.mixin_fields;
      List.map (fun new_method -> check_method_decl method_env new_method) mixin_decl.mixin_new_methods;
      List.map (fun override_method -> check_method_decl method_env override_method) mixin_decl.mixin_override_methods;
      List.map (fun ini_module -> check_inimodule_decl method_env ini_module) mixin_decl.mixin_ini_module;
    
  let rec check_mixin_expr (env : MethodEnv.t) (mixin_expr : mixin_expr) : unit =
    match mixin_expr with
    | MixinExprVoid -> ()
    
    
end