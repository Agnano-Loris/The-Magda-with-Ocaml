type span = Lexing.position * Lexing.position

type phase = GenericPhase | ParsePhase | ContextPhase | ResolutionPhase | TypePhase

type magda_error = {
  phase    : phase;
  message : string;
  span    : span option;
}

exception Magda_error of magda_error

val magda_raise : phase -> string -> 'a

val magda_raise_at : span -> phase -> string -> 'a

val adorn_error_with_span : span -> (unit -> 'a) -> 'a

val string_of_span : span -> string

val string_of_phase : phase -> string