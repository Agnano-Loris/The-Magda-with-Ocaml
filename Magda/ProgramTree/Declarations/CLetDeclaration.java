package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CLetDeclaration implements IDeclaration{ 
    
    private static final long serialVersionUID = 1L;
  
    public String varName; 
    public IMixinExpression boundExpr;
    
    public CLetDeclaration (String avarName, IMixinExpression aboundExpr){ varName = avarName;
        boundExpr = aboundExpr;
    }

    public void print(java.io.PrintStream o){ 
        o.print("Let "+varName+ "= (" );
        boundExpr.print(o);
        o.println(")");
    }

    public CType GetType (CMethodEnvironment env){ 
        return boundExpr.GetType(env);
    }
  
    public CType GetNativeType (CMethodEnvironment env){ 
        return boundExpr.GetNativeType(env);
    }
        
    public void CheckTypes(CEnvironment env){ 
        //No body
    }
  
    public void GenCode (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){
        //No body
    }

    public String getName(){ 
        return varName;
	}

    public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){ 
        boundExpr.GenCodeForMixinExpression(o, env, h);
	}

}
