package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CIntegerLiteral implements IExpression{
    
    private static final long serialVersionUID = 1L;
  
    int Value;

    public CIntegerLiteral (int aValue){
        Value = aValue;
    }

    public void print(java.io.PrintStream o){
        o.print(" int:<"+String.valueOf(Value)+">");
    }

    public CType GetType (CInstrEnvironment env){
        return (new CMixinExpressionIdentifier("FullInteger")).GetType(env) ;
    }
    
    public String GetTypeString (){
        return ("Integer");
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        new CObjectCreation(new CMixinExpressionIdentifier("FullInteger"), new CInitializationOfParams()).GenCode(o, env, h, target);
        //OLD VERSION
        //o.println ( h.tempAcc(target)+ ".internalPointer = new Integer("+Value+");");
        //NEW VERSION
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append(".internalPointer = (Integer)");str.append(Value);str.append(";");

        o.println(str);
    }

};
