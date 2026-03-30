package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class  CStringLiteral implements IExpression{
    
    private static final long serialVersionUID = 1L;
  
    String Value;

    public CStringLiteral (String aValue){ 
        Value = aValue;
    }

    public void print(java.io.PrintStream o){
        o.print(" String: "+Value+"");
    }

    public CType GetType (CInstrEnvironment env){
        return CType.createCType(env, env.getMixin("String") );
    }
    
    public String GetTypeString (){
        return ("String");
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        new CObjectCreation(new CMixinExpressionIdentifier("String"), new CInitializationOfParams()).GenCode(o, env, h, target);
        
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append(".internalPointer =");str.append(Value);str.append(";");

        o.println(str);
    }

};
