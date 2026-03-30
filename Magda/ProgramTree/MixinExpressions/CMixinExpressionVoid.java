package Magda.ProgramTree.MixinExpressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CMixinExpressionVoid implements IMixinExpression{	
    
    private static final long serialVersionUID = 1L;
	
    public CMixinExpressionVoid (){ 
	    // No body
    }

	public CType GetType (CMethodEnvironment env){ 
        return CType.createCType(false);
	}
        
    public CType GetNativeType (CMethodEnvironment env) throws CTypeError{ 
        return GetType(env);
    }

    public String toString(){ 
        return "void";
    }
        
	public void print(java.io.PrintStream o){ 
        o.print(this);
	}

    public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){
        // No body
	}

};
