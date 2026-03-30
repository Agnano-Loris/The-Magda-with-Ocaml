package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CVariableDeclaration implements IProgramElem{
    
    private static final long serialVersionUID = 1L;
	
    String VarName;
	IMixinExpression Type;

	public CType GetType(CMethodEnvironment env){ 
        return Type.GetType(env);
	}

	public CVariableDeclaration (String aVarName, IMixinExpression aType){ 
        VarName = aVarName;
	    Type= aType;
	}
        
    public String toString(){ 
        return " var "+VarName+":"+Type;
    }

    public void print(java.io.PrintStream o){ 
        o.println(this);
	}

	public String ExpandVariableInNative(String input, int i){
	    return input.replaceAll("\\$"+VarName+"\\$", "localVars["+String.valueOf(i)+"]" );
	}

};
