open Utils
open Magda_parser.Parse

type resolved_program = resolved_global_declaration list

and resolved_global_declaration =
| DeclarationMixin of Cst.mixin_declaration
| DeclarationLet of Cst.let_declaration
| DeclarationInclude of string * resolved_program

let rec resolve_includes (cst: Cst.program) (checked : StringSet.t ) (filename: string) : resolved_program = 
  let checked = StringSet.add filename checked in
  let (_, resolved) = List.fold_left_map resolve_aux checked  cst in
  resolved

and resolve_aux checked = function
| Cst.DeclarationMixin d -> (checked, DeclarationMixin d)
| Cst.DeclarationLet l -> (checked, DeclarationLet l)
| Cst.DeclarationInclude fname -> 
  if (StringSet.mem fname checked)  then 
    (checked ,DeclarationInclude (fname, []))
  else
    let checked = StringSet.add fname checked in
    let include_cst = parse_file fname in
    let resolved_include_cst = resolve_includes include_cst checked fname in
      (checked, DeclarationInclude (fname, resolved_include_cst))

