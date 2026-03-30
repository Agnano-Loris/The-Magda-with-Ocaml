package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Expressions.*;


public class CReturnInstruction extends CInstruction{
    
    private static final long serialVersionUID = 1L;
	
    IExpression Expr;

	public CReturnInstruction(IExpression aExpr){ 
        Expr = aExpr;
	}

	public void CheckTypes (CInstrEnvironment env) throws CTypeError{  
        super.CheckTypes(env);
	    if (env.currentMethod == null)
 		    throw new CTypeError ("return not allowed in this context");
	   
        CType RetType = env.currentMethod.getResultType(env);
		 
	    if (!Expr.GetType(env).isSubTypeOf( env, RetType ))
 		    throw new CTypeError ("Wrong types in assignment");
	}

	public void print(java.io.PrintStream o){ 
        o.print ("return ");
	    Expr.print(o);
	    o.println(";");
	}

	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){ 
        super.GenCode(o, env, h); 
	    int temp= h.getTemp();
	    Expr.GenCode(o,env,h, temp);
	    
        StringBuilder str = new StringBuilder(100);
        str.append("\n");
        str.append(CGenCodeHelper.tab);
        str.append("if (true)\n");

        CGenCodeHelper.addTab();   
     
        str.append(CGenCodeHelper.tab);
        str.append("return ");str.append(h.tempAcc(temp));str.append(";");

        CGenCodeHelper.removeTab();

        o.println(str);
	}

}
