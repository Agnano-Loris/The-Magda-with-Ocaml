package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

import java.util.*;

public class CInstructions extends CProgramElemVector<IInstruction>{

    private static final long serialVersionUID = 1L;
	
    public void CheckTypes (CInstrEnvironment env){ 
        for (int i=0; i<size();  i++)
		    get(i).CheckTypes(env);
	}

	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){ 
        for (int i=0; i<size();  i++)
		    get(i).GenCode(o, env, h);
	}

}
