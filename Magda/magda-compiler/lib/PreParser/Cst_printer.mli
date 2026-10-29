open Utils

(** Prints a {!Cst.program} as a tree of constructors.

    Unlike {!Program_tree.Ast_printer}, the output is not Magda source: it shows the CST as the parser built it,
    including the grouping of suffixes ([this.a.b.c()] is
    [ExprSuffix(ExprSuffix(This, SpecificFieldSelect(a, b)), DirectMethodCall(c, []))])
    and the parentheses kept as nodes.
    Located nodes carry their start position as [@row:column].
    A node fits on one line when it is short enough, otherwise its children go on indented lines.
    Meant for tests and debugging.
*)

val expression_to_string : Cst.expression -> string
(** [expression_to_string expr] prints an expression. *)

val program_to_string : Cst.program -> string
(** [program_to_string program] prints all the global declarations of [program], one tree each. *)
