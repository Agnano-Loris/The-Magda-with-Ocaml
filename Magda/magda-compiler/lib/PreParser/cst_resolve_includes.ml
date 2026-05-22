(** Implements the resolution of all the includes declaration in a CST of a magda file
*)

open Utils
open Magda_parser.Parse

(** Type containing the program with all include clauses resolved into a tree structure*)
type resolved_program = resolved_global_declaration list

and resolved_global_declaration =
| DeclarationMixin of Cst.mixin_declaration (** Wrap of mixin_declaration*)
| DeclarationLet of Cst.let_declaration (** Wrap of let_declaration*)
| DeclarationInclude of string * resolved_program (** Contains the filename and the resolved program of the included file*)

(** [resolve_inner checked cst] is used by [resolve_includes] to apply the ausiliary function [resolve_aux]
    to all the global declarations contained in [cst]; [checked] is an accumulator representing a Set of string 
    of the filenames visited. 

    This function is not defined in the module interface.
*)
let rec resolve_inner (checked: StringSet.t) (cst: Cst.program) : StringSet.t * resolved_program =
  List.fold_left_map resolve_aux checked cst


(** [resolve_aux checked decl] resolves a single global declaration.
    [DeclarationMixin] and [DeclarationLet] are wrapped unchanged.
    [DeclarationInclude] is resolved by parsing the included file and
    recursively resolving its declarations; files already in [checked]
    are skipped, producing an empty program.
*)
and resolve_aux checked = function
| Cst.DeclarationMixin d -> (checked, DeclarationMixin d)
| Cst.DeclarationLet l -> (checked, DeclarationLet l)
| Cst.DeclarationInclude fname -> 
  if (StringSet.mem fname checked)  then 
    (checked ,DeclarationInclude (fname, []))
  else
    let checked = StringSet.add fname checked in
    let include_cst = parse_file fname in
    let (checked, resolved) = resolve_inner checked include_cst in
      (checked, DeclarationInclude (fname, resolved))



(** Creates a [StringSet] initially containing only the [filename], then pass it to [resolve_inner] with a {! Cst.program} and return the resolved program*)      
let resolve_includes (cst: Cst.program) (filename: string) : resolved_program = 
  let checked = StringSet.singleton filename in
  let (_, resolved) = resolve_inner checked  cst in
  resolved