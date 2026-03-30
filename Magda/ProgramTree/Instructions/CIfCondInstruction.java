package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Expressions.*;

public class CIfCondInstruction extends CInstruction{  
    
    private static final long serialVersionUID = 1L;
    
    IExpression Cond;
	CInstructions TrueInstrs;
	CInstructions FalseInstrs;

    public CIfCondInstruction(IExpression aCond, CInstructions aTrueInstrs, CInstructions aFalseInstrs){ 
        Cond = aCond;
	    TrueInstrs =  aTrueInstrs;
	    FalseInstrs = aFalseInstrs;
	}

    public void CheckTypes (CInstrEnvironment env){ 
        super.CheckTypes(env);
	    if (! Cond.GetType(env).isSubTypeOf(env, CType.createCType(env, env.getMixin("Boolean") )) )
		    throw new CTypeError ("if condition has to have a type of Boolean");
	    TrueInstrs.CheckTypes(env);
	    FalseInstrs.CheckTypes(env);
	}

	public void print(java.io.PrintStream o){ 
        o.print("IF (");
	    Cond.print(o);
	    o.println(")");
        TrueInstrs.print(o);
	    o.println("ELSE");
        FalseInstrs.print(o);
   	    o.println("IF;");
	}

	public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){ 
        super.GenCode(o, env, h); 
	    int t = h.getTemp();
	    Cond.GenCode(o,env, h, t);
        
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append("if ( (Boolean) ");str.append(h.tempAcc(t));str.append(".internalPointer){");
         
        o.println(str);
        str.setLength(0);
        
        CGenCodeHelper.addTab();
        TrueInstrs.GenCode(o, env, h);
        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
        str.append("}\n");
        str.append(CGenCodeHelper.tab);
        str.append("else{");
        
        o.println(str);
        str.setLength(0);
	    
        CGenCodeHelper.addTab();
        FalseInstrs.GenCode(o,env, h);
        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("}");
        o.println(str);
	}

};
