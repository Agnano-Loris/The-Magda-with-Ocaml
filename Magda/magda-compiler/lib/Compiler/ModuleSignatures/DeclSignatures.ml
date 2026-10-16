module type GLOBAL_DECL = sig
    type t = Program_tree.Ast.global_declaration
    val compare : t -> t -> int
    val is_mixin_decl : t -> bool
    val is_let_decl : t -> bool
    val get_name : t -> string

    val get_mixin_exn : t -> Program_tree.Ast.mixin_decl
    val get_let_exn : t -> Program_tree.Ast.let_decl
    (*

	verranno probabilmente gestiti dalle altre declaration
	val empty_mixin : Program_tree.Ast.mixin_decl
    val empty_let : Program_tree.Ast.let_decl
	val empty_poli_param : Program_tree.Ast.polymorphism_param
	val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> EnvSigTypes.environment -> t -> unit
    val check_types : EnvSigTypes.environment -> t -> unit (* Needs to see wether to modify the signature *)
	val get_type : EnvSigTypes.method_environment -> t -> CType.t
    val get_native_type : EnvSigTypes.method_environment -> t -> CType.t
    val gen_code_for_mixin_expr : Utils.CGenCodeHelper.TempCounter.t option -> EnvSigTypes.method_environment -> t -> unit
	*)
end

module type VARIABLE_DECL = sig
    type t
    val get_type : Types.EnvTypes.method_environment -> t -> Types.TypeElements.t
    val to_string : t -> string
    val print : t -> unit
    val expand_var_in_native : string -> int -> string
end


module type SOURCE_INIT_PARAM_DECL = sig
    type t
    val get_type : Types.EnvTypes.method_environment -> t -> Types.TypeElements.t
    val print : t -> unit
end

module type PARAM_DECL = sig
    type t
    val get_type : Types.EnvTypes.method_environment -> t -> Types.TypeElements.t
    val print : t -> unit
    val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> Types.EnvTypes.method_environment -> t -> unit
    val expand_var_in_native : string -> int -> string
end

module type INIMODULE_DECL = sig
    type t
    val print_header : t -> unit
    val to_string : t -> string
    val print : t -> unit
    val build_env : Types.EnvTypes.method_environment -> t -> Types.EnvTypes.instr_environment
    val check_types_exn : t -> unit
    val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> Types.EnvTypes.method_environment -> t -> unit
    val modify_parameter_list : Program_tree.Ast.init_param list -> t -> Program_tree.Ast.init_param list (*Assuming stateless modules*)
    val activated_by : Program_tree.Ast.init_param list -> t -> bool
end

(* Method declaration signatures *)

(* Generic method  - ex IMethodDeclaration *)
module type METHOD_DECL = sig
	type t
	val get_formal_parameters: t -> Program_tree.Ast.parameter_decl
	val get_result_type : Types.EnvTypes.method_environment -> t -> Types.TypeElement.t list
	val gen_code : Utils.CGenCodeHelper.TempCounter.t option -> Types.EnvTypes.method_environment -> t -> unit
	val check_types : t -> unit 
	val set_mixin : Program_tree.Ast.mixin_decl -> t
	val get_mixin : t -> Program_tree.Ast.mixin_decl
	val print : t -> unit
end

(* Method interface for new and signature for abstract method declarations - sig for - ex INewMethodDeclaration, CAbstractMethodDeclaration *)
module type METHOD_DECL_INTERFACE = sig
	type t
	include METHOD_DECL with type t := t
	val method_name : t -> string
	val mixin_name : t -> string
end

(* New method declaration - ex CNewMethodDeclaration *)
module type NEW_METHOD_DECL = sig
    type t
    include METHOD_DECL_INTERFACE with type t := t
	val build_env : Types.EnvTypes.method_environment -> t -> Types.EnvTypes.instr_environment
end

(* Override method declaration - ex COverrideMethodDeclaration*)
module type OVERRIDE_M_DECL = functor (N_M_DECL : METHOD_DECL_INTERFACE) -> sig
	type t
	include METHOD_DECL with type t := t
	val build_env : Types.EnvTypes.method_environment -> t -> Types.EnvTypes.method_environment
	val get_source_method : Types.EnvTypes.method_environment -> t -> N_M_DECL.t
end