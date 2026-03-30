package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Expressions.*;

public class CExprInstruction extends CInstruction{
	
    private static final long serialVersionUID = 1L;
    
    IExpression Expr;

	public CExprInstruction(IExpression aExpr){ 
        Expr = aExpr;
	}

	public void CheckTypes (CInstrEnvironment env){ 
        super.CheckTypes(env);
	    Expr.GetType(env);
	}

    public void print(java.io.PrintStream o){ 
        Expr.print(o);
	    o.println(";");
	}

	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){ 
        super.GenCode(o, env, h); 
	    Expr.GenCode(o,env,h, h.getTemp());
	}


};
