package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

public class CIdentifierExpression implements IExpression{
    
    private static final long serialVersionUID = 1L;
  
    public String Name;
    public String typeString;    

    public CIdentifierExpression(String aName, String aTypeString){
        Name = aName;
        typeString = aTypeString;
    }

    public CIdentifierExpression(String aName){
        Name = aName;
        typeString = "Integer";
    }

    public void print(java.io.PrintStream o){
        o.print("ID:"+Name);
    }
    
    public CType GetType (CInstrEnvironment env){
        CType res = env.findParamOrVariableType(Name);
        if (res == null) {
            throw new Error ("Identifier "+Name+" not declared ");
        } 
        else {
            // System.out.println("// CIdentifierExpression.GetType()-> " + res.toString());
        }
    
        return res;
    }

    public String GetTypeString (){
        // System.out.println("// CIdentifierExpression.Name=" + Name);
        // System.out.println("// CIdentifierExpression.GetTypeString()->empty");
        return typeString;   // as default arithmetci operations about Integers
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append("=\n");

        int i = env.getVariableOffset(Name);
        if (i>=0) {
            str.append(CGenCodeHelper.tab);
            str.append("localVars[");str.append(String.valueOf(i));str.append("];");
        }
        else {
            i = env.getParameterOffset(Name);
            if (i<0)
                throw new Error ("Identifier "+Name+" not declared ");
            str.append(CGenCodeHelper.tab);
            str.append("params[");str.append(String.valueOf(i));str.append("];");
        }

        o.println(str);
    }

};
