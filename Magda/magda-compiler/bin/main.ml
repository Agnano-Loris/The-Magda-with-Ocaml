open Magda_parser
open Magda_pre_parser
open Utils
(*open Compiler*)
(*open Program_tree*)

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

let () =
  let argc = Array.length Sys.argv in
  if argc < 2 || argc > 3 then begin
    prerr_endline "Usage: magda-compiler FileName [root]";
    exit 1
  end;
  let file = Sys.argv.(1) in
  let root = if argc = 3 then Sys.argv.(2) else Sys.getcwd () in
  try
    let initial_path = Filename.concat root (program_relative_path file) in 
    let cst = Parse.parse_file initial_path in
    let resolved = Cst_resolve_includes.resolve_includes root cst initial_path in
    let ctx = Cst_to_context.context resolved in
    check_entry_point ctx;
    let snapshot_ctx = PreParserStructures.ProgramContext.to_string ctx in
    print_endline snapshot_ctx
  with Errors.Magda_error e->
    (match e.span with
     | Some span ->
         Printf.eprintf "%s: %s\n  at %s\n"
           (Errors.string_of_phase e.phase) e.message (Errors.string_of_span span)
     | None ->
         Printf.eprintf "%s: %s\n"
           (Errors.string_of_phase e.phase) e.message);
    exit 1
  
