package Magda.ProgramTree.LValues;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CVariableLValue implements ILValue{ 
    
    private static final long serialVersionUID = 1L;
    
    String VarName;
  
    public CVariableLValue (String aVarName){ 
        VarName = aVarName;
    }
  
    public CType GetType (CInstrEnvironment env){ 
        CType res = env.findParamOrVariableType(VarName);
    
        if (res == null)
            throw new Error ("Identifier "+VarName+" not declared ");
    
        return res;
    }

	public void print(java.io.PrintStream o){ 
        o.print(VarName);
	}

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){  
        int i = env.getVariableOffset(VarName);

        StringBuilder str = new StringBuilder(100);	   
 
        str.append(CGenCodeHelper.tab);       

        if (i>=0){ 
            str.append("localVars[");str.append(String.valueOf(i));str.append("]");
	    } 
        else{ 
            i  = env.getParameterOffset(VarName);
		    if (i<0)
		        throw new Error ("Identifier "+VarName+" not declared ");
		    str.append("params[");str.append(String.valueOf(i));str.append("]");
	    }

        o.println(str);
    }
};
