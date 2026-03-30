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
