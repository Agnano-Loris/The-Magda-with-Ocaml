package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CInitializationOfParam implements IProgramElem{	
    
    private static final long serialVersionUID = 1L;
	
    public String MixinName;
	public String ParamName;
	public IExpression Expr;

	public CInitializationOfParam (String aMixinName, String aParamName, IExpression aExpr){ 
        MixinName = aMixinName;
	    ParamName = aParamName;
	    Expr = aExpr;
	}

    public void print(java.io.PrintStream o){ 
        o.print(" "+MixinName+"."+ParamName+":=");
        Expr.print(o);
    	o.print(",");
	}
        
    public String toString(){ 
        return MixinName+"."+ParamName+ (Expr!=null ? ":=" +Expr : "");
    }

    public void CheckTypes (CInstrEnvironment env){ 
        Expr.GetType(env).CheckIsSubTypeOf( env, env.getMixin(MixinName).getIniParamType(env, ParamName) );
	}

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){ 
        int localTarget = h.getTemp();
        Expr.GenCode(o, env, h, localTarget);
	    
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));
        str.append(".getStateHolderByName(\"");
        str.append(MixinName);
        str.append("\", ");
        str.append(String.valueOf( env.getMixin(MixinName).getFieldParamOffset(ParamName) ));
        str.append(").Value = ");
        str.append(h.tempAcc(localTarget)+";");

        o.println(str);
	}


}
