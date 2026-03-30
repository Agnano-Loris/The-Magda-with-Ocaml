package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Declarations.*;

public class CSuperCallExpression implements IExpression{
    
    private static final long serialVersionUID = 1L;
  
    CExpressionList Params;

    public String typeString;

    public CSuperCallExpression (CExpressionList aparams){ 
        Params = aparams;
        typeString = "Integer";
    }

    public CType GetType (CInstrEnvironment env){ 
        if (env.currentMethod == null)
            throw new CTypeError("super not allowed in this context");
        //
        if (env.currentMethod instanceof INewMethodDeclaration)
            throw new CTypeError("super allowed only in overriden methods");
        //
        env.currentMethod.getFormalParameters().CheckTypesOfActualParameters(env.currentMethod.getMixin().GetType(env), env, Params);
        //
        return env.currentMethod.getResultType(env);
    }
    
    public String GetTypeString (){
        // System.out.println("// CSuperCallExpression.GetTypeString()->empty");
        return typeString;   // as default arithmetci operations about Integers
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){  
        Params.GenCodeForParams(o, env, h);
        
 
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append("= SuperBody.Execute (aSelf, ParamsToPass);\n");
        
        //mandatory after the GenCode of an ExpressionList
        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
        str.append("}");

        o.println(str);
    }

    public void print(java.io.PrintStream o){ 
        o.print("super call (");
        Params.print(o);
        o.print(")");
    }


}
