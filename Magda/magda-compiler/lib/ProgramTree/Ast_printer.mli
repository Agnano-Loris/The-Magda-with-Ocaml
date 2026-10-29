(** Prints an {!Ast.program} as Magda source.

    The output is the program after name resolution: every field selection and method call
    is written in qualified form ([target.Mixin.member]), [>] and [>=] appear as [<] and [<=] with
    the operands swapped, includes are already flattened.
    Members of a mixin are printed grouped by kind (fields, new and abstract methods, overrides, ini modules).
    Meant for tests and debugging; the output is accepted by the parser.
*)

val mixin_expr_to_string : Ast.mixin_expr -> string
(** [mixin_expr_to_string mexpr] prints a mixin expression, [void] included. *)

val expression_to_string : Ast.expression -> string
(** [expression_to_string expr] prints an expression; parentheses are added only where the grammar needs them. *)

val global_declaration_to_string : Ast.global_declaration -> string
(** [global_declaration_to_string decl] prints a mixin or let declaration, terminated by [;]. *)

val program_to_string : Ast.program -> string
(** [program_to_string program] prints all the declarations of [program], separated by a blank line. *)
