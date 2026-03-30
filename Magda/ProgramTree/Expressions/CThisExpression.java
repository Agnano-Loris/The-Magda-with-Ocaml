package Magda.ProgramTree.Expressions;
import Magda.Compiler.*;
import Magda.ProgramTree.*;

public class CThisExpression implements IExpression{
    
    private static final long serialVersionUID = 1L;

    public String typeString;
    
    public CThisExpression(String aTypeString){
        typeString = aTypeString;
    }    

    public CThisExpression(){
        typeString = "Integer";
    }    

    public void print(java.io.PrintStream o){ 
        o.print("this");
    }

    public CType GetType (CInstrEnvironment env){ 
        if (env.CurrentMixin == null)
            throw new Error("this not allowed in this context");
     
        return env.CurrentMixin.GetType(env);
    }
    
    public String GetTypeString (){
        // System.out.println("// CThisExpression.GetTypeString()->empty");
        return typeString;   // as default arithmetci operations about Integers
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){  
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append("= aSelf;");

        o.println(str);
    }

};
