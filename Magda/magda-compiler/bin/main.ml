open Magda_parser
open Magda_pre_parser
open Utils
(*open Compiler*)

(** [check_entry_point ctx] checks the requirements of an executable program, as the Java
    entry point does: a mixin [MainClass] with a method [mainProgram] without parameters. *)
let check_entry_point ctx =
  let open PreParserStructures.ProgramContext in
  if not (contains_mixin "MainClass" ctx) then
    Errors.magda_raise Errors.ContextPhase "This program doesn't contain a MainClass mixin"
  else if not (contains_method "mainProgram" "MainClass" ctx) then
    Errors.magda_raise Errors.ContextPhase "The mixin MainClass doesn't contain a method called mainProgram"
  else if not (empty_main_program_params ctx) then
    Errors.magda_raise Errors.ContextPhase "The method mainProgram of the mixin MainClass shouldn't have any parameters"

let program_relative_path (name : string) : string =
  Filename.concat (Filename.concat "Magda" "src") (Filename.concat name (name ^ ".magda"))

let usage = "Usage: magda-compiler [options] FileName [root]\nOptions:"

(** [declared_names cst] is the names of the mixins and let aliases declared in [cst], includes excluded. *)
let declared_names (cst : Cst.program) =
  List.filter_map (function
      | Cst.DeclarationMixin (name, _, _, _) | Cst.DeclarationLet (name, _) -> Some name
      | Cst.DeclarationInclude _ -> None) cst

(** [declaration_name decl] is the name of a global declaration of the AST. *)
let declaration_name = function
  | Program_tree.Ast.MixinDecl decl -> decl.Program_tree.Ast.mixin_name
  | Program_tree.Ast.LetDecl decl -> decl.Program_tree.Ast.let_name

let () =
  let dump_cst = ref false and dump_context = ref false and dump_ast = ref false and dump_all = ref false in
  let positional = ref [] in
  let specs = Arg.align [
      ("--dump-cst", Arg.Set dump_cst, " Print the CST of the main file");
      ("--dump-context", Arg.Set dump_context, " Print the program context");
      ("--dump-ast", Arg.Set dump_ast, " Print the AST of the declarations of the main file");
      ("--all", Arg.Set dump_all, " With --dump-ast, print the included declarations too");
    ] in
  Arg.parse specs (fun arg -> positional := arg :: !positional) usage;
  let (file, root) = match List.rev !positional with
    | [ file ] -> (file, Sys.getcwd ())
    | [ file; root ] -> (file, root)
    | _ -> Arg.usage specs usage; exit 1 in
  try
    let initial_path = Filename.concat root (program_relative_path file) in
    let cst = Parse.parse_file initial_path in
    if !dump_cst then print_string (Cst_printer.program_to_string cst);
    let resolved = Cst_resolve_includes.resolve_includes root cst initial_path in
    let ctx = Cst_to_context.context resolved in
    if !dump_context then print_endline (PreParserStructures.ProgramContext.to_string ctx);
    check_entry_point ctx;
    let ast = Cst_to_ast.ast resolved ctx in
    if !dump_ast then begin
      let names = declared_names cst in
      let shown = if !dump_all then ast else List.filter (fun d -> List.mem (declaration_name d) names) ast in
      print_string (Program_tree.Ast_printer.program_to_string shown)
    end;
    if not (!dump_cst || !dump_context || !dump_ast) then print_endline "OK"
  with Errors.Magda_error e ->
    (match e.span with
     | Some span ->
       Printf.eprintf "%s: %s\n  at %s\n"
         (Errors.string_of_phase e.phase) e.message (Errors.string_of_span span)
     | None ->
       Printf.eprintf "%s: %s\n"
         (Errors.string_of_phase e.phase) e.message);
    exit 1