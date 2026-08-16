(** Builds the {!ProgramContext.t} from a resolved CST.

    The main function walks the program and extracts the structure of names:
    which mixins exist, which fields and methods they declare, which parameters they take, and from whom they inherit.
    Everything inside method and ini module bodies (instructions,
    expressions, super calls) is ignored.
*)

val context : Cst_resolve_includes.resolved_program -> PreParserStructures.ProgramContext.t
(** [context resolved_program] walk through the [resolved_program] and return the populated {!ProgramContext.t}*)