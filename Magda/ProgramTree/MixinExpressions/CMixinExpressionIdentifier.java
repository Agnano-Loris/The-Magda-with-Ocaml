package Magda.ProgramTree.MixinExpressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CMixinExpressionIdentifier implements IMixinExpression{	
    
    private static final long serialVersionUID = 1L;
    
    String MixinName;

	public CMixinExpressionIdentifier (String aMixinName){ 
        MixinName = aMixinName;
	}

    public CType GetType (CMethodEnvironment env) throws CTypeError{ 
        return env.getDeclaration(MixinName).GetType(env);
	}
        
        
    public CType GetNativeType (CMethodEnvironment env) throws CTypeError{ 
        return env.getDeclaration(MixinName).GetNativeType(env);
	}
                
    public String toString(){  
        return MixinName;
    }

	public void print(java.io.PrintStream o){ 
        o.print(this);
	}

    public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){ 
        env.getDeclaration(MixinName).GenCodeForMixinExpression(o, env, h);
	}

};
