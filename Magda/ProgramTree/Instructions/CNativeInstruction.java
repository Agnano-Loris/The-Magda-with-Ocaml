package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CNativeInstruction extends CInstruction{ 
    
    private static final long serialVersionUID = 1L;
	
    String Code;

	public CNativeInstruction (String aValue){ 
        Code = aValue.substring(2, aValue.length()-1);
	}

  	public void CheckTypes (CInstrEnvironment env){ 
        super.CheckTypes(env);
	    //to nic nie idzie sprawdzac
	}

    public void print(java.io.PrintStream o){ 
        o.print("<JAVA> "+ Code +"</JAVA>");
	}

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){   
        super.GenCode (o, env, h);
	    o.println(CGenCodeHelper.tab+env.ExpandVariablesInNative(Code) );
    }

};
