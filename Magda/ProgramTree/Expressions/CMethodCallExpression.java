package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;
import Magda.Compiler.*;

import java.util.*;

public class CMethodCallExpression implements IExpression{ 
    
    private static final long serialVersionUID = 1L;

    public String typeString;
    
    public IExpression MethodTarget;
    String MixinName;
    String MethodName;
    CExpressionList Params;
    
    public CMethodCallExpression (IExpression aMethodTarget, String aMixinName, String aMethodName, CExpressionList aparams,String aTypeString){ 
        MethodTarget = aMethodTarget;
        MixinName = aMixinName;
        MethodName = aMethodName;
        Params  = aparams;
        typeString = aTypeString;
    }

    public CMethodCallExpression (IExpression aMethodTarget, String aMixinName, String aMethodName, CExpressionList aparams){ 
        MethodTarget = aMethodTarget;
        MixinName = aMixinName;
        MethodName = aMethodName;
        Params  = aparams;
        typeString = "Integer";
    }

    public void print(java.io.PrintStream o){ 
        o.print("(");
        MethodTarget.print(o);
        o.print(")");
        o.print(".call "+MixinName+"."+MethodName+"(");
        Params.print(o);
        o.print(")");
    }

    public CType GetType (CInstrEnvironment env){ 
        CMixinDeclaration targetMix= env.getMixin(MixinName);

        //
        CType targetType = MethodTarget.GetType(env);
        if (!targetType.isSubTypeOf( env, CType.createCType(env, targetMix) ) )
            throw new CTypeError ("Target object type "+targetType+" doesn't contain "+MixinName+" layer ");
        //
        targetMix.getNewMethod(MethodName).getFormalParameters().CheckTypesOfActualParameters(targetType, env, Params);
        //
        return env.getMixin(MixinName).getMethodResultType(env, MethodName).setPolyParamsFrom(targetType.getApplications(env)  ) ;
    }

    public String GetTypeString (){
        // System.out.println("// CMethodCallExpression.GetTypeString()->empty");
        return typeString; // as default arithmetci operations about Integers
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){  
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append("// preparing call to method ");str.append(MixinName);str.append(".");str.append(MethodName);

        o.println(str);
        str.setLength(0);
        
        int Target2 = h.getTemp();
        int MethodOffset = env.getMixin(MixinName).getMethodOffset(MethodName);
        MethodTarget.GenCode(o, env, h, Target2);

        Params.GenCodeForParams(o, env, h);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));
        str.append("=");
        str.append(h.tempAcc(Target2));
        str.append(".executeMethodByName (\"");
        str.append(MixinName);
        str.append("\", ");
        str.append(String.valueOf(MethodOffset));
        str.append(", ParamsToPass);\n");
       
        //mandatory after the GenCode of an ExpressionList
        CGenCodeHelper.removeTab();       
        
        str.append(CGenCodeHelper.tab); 
        str.append("}  // call to method");
        str.append(MixinName);
        str.append(".");
        str.append(MethodName);
        str.append(" finished ");
    
        o.println(str);
    }

};
