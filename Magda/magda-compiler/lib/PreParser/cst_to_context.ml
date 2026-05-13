open Utils.Cst

open PreParserStructures

let mix_decl a ctx = ctx 

let global_decl a (ctx: ProgramContext.t) : ProgramContext.t = match a with
| DeclarationMixin a -> mix_decl a ctx
| DeclarationLet _ -> ctx
| DeclarationInclude _ -> ctx

let context (p:program) : ProgramContext.t = List.fold_left (fun ctx decl -> global_decl decl ctx) (ProgramContext.empty ())  p
