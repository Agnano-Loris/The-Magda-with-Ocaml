open Magda_parser
open Magda_pre_parser
open Utils
(*open Compiler*)
(*open Program_tree*)

let program_relative_path (name : string) : string =
  Filename.concat "Magda\\src" (Filename.concat name (name ^ ".magda"))

let () = 
  let argc = Array.length Sys.argv in 
  if argc <> 3 then begin
    prerr_endline "Incorrect number of arguments, usage: compile FileName <root>. Command: .\\compile.bat FileName";
    exit 1
  end;
  let file = Sys.argv.(1) in
  let root = Sys.argv.(2) in
  try
    let initial_path = Filename.concat root (program_relative_path file) in 
    let cst = Parse.parse_file initial_path in
    let resolved = Cst_resolve_includes.resolve_includes root cst initial_path in
    let _ctx = Cst_to_context.context resolved in
    print_endline "Ok"
  with Errors.Magda_error e->
    (match e.span with
     | Some span ->
         Printf.eprintf "%s: %s\n  at %s\n"
           (Errors.string_of_phase e.phase) e.message (Errors.string_of_span span)
     | None ->
         Printf.eprintf "%s: %s\n"
           (Errors.string_of_phase e.phase) e.message);
    exit 1
  
