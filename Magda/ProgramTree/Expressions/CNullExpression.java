package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CNullExpression implements IExpression{
    
    private static final long serialVersionUID = 1L;
    
    public void print(java.io.PrintStream o){ 
        o.print("null");
    }

    public CType GetType (Magda.Compiler.CInstrEnvironment env){ 
        return CType.createCType(true);
    }
    
    public String GetTypeString (){
        // System.out.println("// CNullExpression.GetTypeString()->empty");
        return ("Integer");   // as default arithmetci operations about Integers
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){  
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append("=null;");

        o.println(str);
    }

};
