type span = Lexing.position * Lexing.position
(*type code_ctx = CodeContext of (int * string) list  -- da spostare in un modulo e farlo magari in futuro, questione di rendering opzionale*)

type phase = GenericError | ParsePhase | ContextPhase | ResolutionPhase | TypePhase | InternalError (** Generic ed internal vanno poi spostati in kind of error in futuro*) 

type magda_error = { (** aggiungere kind: kind option in futuro? per errori specifici*)
  phase    : phase;
  message : string;
  span    : span option;
}
exception Magda_error of magda_error

let magda_raise phase message =
  raise (Magda_error { phase; message; span = None })

let magda_raise_at span phase message = 
  raise (Magda_error { phase; message; span = Some span })
    
let adorn_error_with_span span f =
  try f () with
  | Magda_error ({ span = None; _ } as e) -> raise (Magda_error { e with span = Some span })

let string_of_span ((start_pos, _):span) =
  let open Lexing in
  let file = if start_pos.pos_fname = "" then "<unknown>" else start_pos.pos_fname in
  Printf.sprintf "%s, row %d, column %d" file start_pos.pos_lnum (start_pos.pos_cnum - start_pos.pos_bol + 1)