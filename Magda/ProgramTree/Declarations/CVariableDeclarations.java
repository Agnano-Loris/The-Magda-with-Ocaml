package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.MixinExpressions.*;

import java.util.*;

public class CVariableDeclarations extends CProgramElemVector<CVariableDeclaration>{
    
    private static final long serialVersionUID = 1L;
    
    public int indexOfName(String name){   
        for (int i=0; i<size(); i++)
	        if (get(i).VarName.equals (name) )
		        return i;
	  
        return -1;
    }

	public void CheckTypes(CInstrEnvironment env){ 
        for (int i=0; i<size(); i++)
	        get(i).Type.GetType(env);
	}

	public String ExpandVariablesInNative(String input){ 
        for (int i=0; i<size(); i++)
	        input = get(i).ExpandVariableInNative( input, i);		
	  
        return input;
	}

};
