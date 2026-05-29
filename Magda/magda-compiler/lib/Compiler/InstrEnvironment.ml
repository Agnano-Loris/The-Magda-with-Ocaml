open Program_tree.Ast

type t = Types.EnvTypes.instr_environment

let find_param_or_variable_type name (instr_environment:t) = 
	let var = List.find_opt (fun v -> v.var_name == name) instr_environment.vars in
	if Option.is_none var then var else var


(*

public CType findParamOrVariableType(String name)
	{ int i;
	  //
          i = Vars.indexOfName(name);
	  if (0 <=i)
              return Vars.get(i).GetType(this);
          //
          i=Params.indexOfName(name);
	    if (0 <= i)
              return Params.get(i).GetType(this);
	  //	 
	  return null;
	}

module type INSTR_ENV = sig 
    type t = instr_environment
    val new_instr_environment : global_declaration list -> mixin_decl -> variable_decl -> parameter_decl -> ?current_method_or_inimodule: (method_declaration, ini_module_decl) Either.t -> t
    val find_param_or_variable_type : string -> t -> CType.t
    val get_variable_offset : string -> t -> int
    val get_parameter_offset : string -> t -> int
    val expand_variables_in_native : string -> t -> string

    (* FROM M_ENV *)
  val get_type_element : string -> t -> TypeElement.t
	val get_declaration_exn : string -> t -> global_declaration
  val get_mixin_exn : string -> t -> global_declaration
end

*)

(*
package Magda.Compiler;

import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;

public class CInstrEnvironment extends CMethodEnvironment
{

	public CVariableDeclarations Vars;
	public CParameterDeclarations Params;
	public IMethodDeclaration currentMethod;
	public CIniModuleDeclaration currentIniModule;

	public CInstrEnvironment(CGlobalDeclarations aDecls, CMixinDeclaration aCurrentMixin, CVariableDeclarations aVars,  
                 CParameterDeclarations aParams, IMethodDeclaration aCurrentMethod)
	{ super(aDecls, aCurrentMixin);
	  Vars = aVars;
	  Params =aParams;
	  currentMethod= aCurrentMethod;
	}

	public CInstrEnvironment(CGlobalDeclarations aDecls, CMixinDeclaration aCurrentMixin, CVariableDeclarations aVars,  
                 CParameterDeclarations aParams, CIniModuleDeclaration aCurrentIniModule)
	{ super(aDecls, aCurrentMixin);
	  Vars = aVars;
	  Params =aParams;
	  currentIniModule= aCurrentIniModule;
	}


	public CInstrEnvironment(CGlobalDeclarations aDecls, CMixinDeclaration aCurrentMixin, CVariableDeclarations aVars,  
                 CParameterDeclarations aParams)
	{ super(aDecls, aCurrentMixin);
	  Vars = aVars;
	  Params =aParams;
	}


	

	public int getVariableOffset(String name)
	{ return Vars.indexOfName(name);
	}

	public int getParameterOffset(String name)
	{ return Params.indexOfName(name);
	}

	public String ExpandVariablesInNative(String input)
	{ return Params.ExpandVariablesInNative( Vars.ExpandVariablesInNative(input) );
	}
};

*)