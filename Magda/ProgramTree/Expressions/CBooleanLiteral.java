package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CBooleanLiteral implements IExpression{
    
    private static final long serialVersionUID = 1L;
    
    boolean Value;

    public CBooleanLiteral (boolean aValue){
        Value = aValue;
    }

    public CType GetType (CInstrEnvironment env){
        return (new CMixinExpressionIdentifier("Boolean")).GetType(env) ;
    }

    public String GetTypeString (){
        return ("Boolean");
    }

    public void print(java.io.PrintStream o){
        o.print(" boolean:<"+String.valueOf(Value)+">");
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        new CObjectCreation(new CMixinExpressionIdentifier("Boolean"), new CInitializationOfParams()).GenCode(o, env, h, target);
        //OLD VERSION
        //o.println ( h.tempAcc(target)+ ".internalPointer = new Boolean("+String.valueOf(Value)+");");
        //NEW VERSION
        
        StringBuilder str = new StringBuilder(100);
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append(".internalPointer = ");str.append(String.valueOf(Value));str.append(";");
        o.println(str);
    }

};
