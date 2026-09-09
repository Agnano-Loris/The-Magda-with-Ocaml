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

(** [anchor root fname] concat a relative include path [fname] to the project [root];
    an already absolute [fname] is returned unchanged.
*)
let anchor (root : string) (fname : string) : string =
  if Filename.is_relative fname then Filename.concat root fname
  else fname

(** [resolve_inner root checked cst] is used by [resolve_includes] to apply the ausiliary function [resolve_aux]
    to all the global declarations contained in [cst]; [checked] is an accumulator representing a Set of string 
    of the filenames visited. 

    This function is not defined in the module interface.
*)
let rec resolve_inner (root: string) (checked: StringSet.t) (cst: Cst.program) : StringSet.t * resolved_program =
  List.fold_left_map (resolve_aux root) checked cst


(** [resolve_aux root checked decl] resolves a single global declaration.
    [DeclarationMixin] and [DeclarationLet] are wrapped unchanged.
    [DeclarationInclude] is resolved by by anchoring its path to [root], 
    parsing the included file and recursively resolving its declarations;
    files already in [checked] are skipped, producing an empty program.

    This function is not defined in the module interface.
*)
and resolve_aux root checked = function
| Cst.DeclarationMixin d -> (checked, DeclarationMixin d)
| Cst.DeclarationLet l -> (checked, DeclarationLet l)
| Cst.DeclarationInclude fname -> 
  let resolved_path = anchor root fname in
  if (StringSet.mem resolved_path checked)  then 
    (checked ,DeclarationInclude (fname, []))
  else
    let checked = StringSet.add resolved_path checked in
    let include_cst = parse_file resolved_path in
    let (checked, resolved) = resolve_inner root checked include_cst in
      (checked, DeclarationInclude (fname, resolved))



(** Creates a [StringSet] initially containing only the [root_file_path], then pass it to [resolve_inner] with a {! Cst.program} and the [root], and return the resolved program*)      
let resolve_includes (root: string) (cst: Cst.program) (root_file_path: string) : resolved_program = 
  let checked = StringSet.singleton root_file_path in
  let (_, resolved) = resolve_inner root checked cst in
  resolved