type resolved_program = resolved_global_declaration list
(** Extended program type, represents the program unfolded by all its include clauses.
    Files are included at most once; subsequent includes of the same file produce an empty program.
*)

and resolved_global_declaration =
| DeclarationMixin of Utils.Cst.mixin_declaration
| DeclarationLet of Utils.Cst.let_declaration
| DeclarationInclude of string * resolved_program
(** Extended global declaration type, represents the basic declarations and the unfolded include declaration.
    [DeclarationMixin] and [DeclarationLet] wrap the corresponding CST type, [DeclarationInclude (filename, program)] contains
    the filename of a magda file and the recursively resolved program of the included file.
*)

val resolve_includes : Utils.Cst.program -> string -> resolved_program
(** [resolve_includes cst filename] resolves all include declarations in [cst], starting from [filename].
    Cyclic and duplicate includes are silently skipped.
*)
