open ProgramTree.Ast
open Types.EnvTypes
open ModuleSignatures

module Make (GDecl : DeclSignatures.GLOBAL_DECL) (GEnv : EnvSig.ENV) (MethodEnv : EnvSig.METHOD_ENV) (InstrEnv : EnvSig.INSTR_ENV) (InimoduleEnv : EnvSig.INIMODULE_ENV) = struct
  let rec check_types_global_env (env : GEnv.t) (decl : )
end