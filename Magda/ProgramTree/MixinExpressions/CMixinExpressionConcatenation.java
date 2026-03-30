package Magda.ProgramTree.MixinExpressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CMixinExpressionConcatenation implements IMixinExpression{	
    
    private static final long serialVersionUID = 1L;
    
    String MixinName;

    IMixinExpression left, right;

	public CMixinExpressionConcatenation (IMixinExpression aleft, IMixinExpression aright){ 
        left = aleft;
	    right = aright;
	}

	public CType GetType (CMethodEnvironment env){ 
        return left.GetType(env).sumWith( right.GetType(env) );
	}
        
    public CType GetNativeType (CMethodEnvironment env) throws CTypeError { 
        return left.GetNativeType(env).sumWith( right.GetNativeType(env) );
    }

    public String toString(){ 
        return left+","+right;
    }
        
	public void print(java.io.PrintStream o){ 
        o.print(this);
	}


    public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){ 
        left.GenCodeForMixinExpression(o,env,h);
	    right.GenCodeForMixinExpression(o,env,h);
	}
};
