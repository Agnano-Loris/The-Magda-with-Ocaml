(** Builds the {!ProgramContext.t} from a resolved CST.

    The main function walks the program and extracts the structure of names:
    which mixins exist, which fields and methods they declare, which parameters they take, and which base mixins they require.
    Everything inside method and ini module bodies (instructions,
    expressions, super calls) is ignored.
*)
val mixin_expr_type : Utils.Cst.mixin_expression -> Utils.MagdaType.t
(** [mixin_expr_type mexpr] is the type the index records for [mexpr]: the type of its only mixin
    for a simple expression, [Composite] with all its mixin names otherwise ([where] applications are ignored).
    Exported so that {!Cst_to_ast} computes the types of expressions with the same rule used to build the index. *)

val context : Cst_resolve_includes.resolved_program -> PreParserStructures.ProgramContext.t
(** [context resolved_program] walk through the [resolved_program] and return the populated {!ProgramContext.t}*)