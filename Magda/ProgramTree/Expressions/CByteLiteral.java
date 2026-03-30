package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CByteLiteral implements IExpression{
    
    private static final long serialVersionUID = 1L;
  
    byte Value;

    public CByteLiteral(byte aValue){
        Value = aValue;
    }

    public void print(java.io.PrintStream o){
        o.print(" byte:<"+Byte.toString(Value)+">");
    }
    
    public CType GetType (CInstrEnvironment env){
        return (new CMixinExpressionIdentifier("FullByte")).GetType(env) ;
    }

    public String GetTypeString (){
        return ("Byte");
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        new CObjectCreation(new CMixinExpressionIdentifier("FullByte"), new CInitializationOfParams()).GenCode(o, env, h, target);
        
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append(".internalPointer = (byte)");str.append(Value);str.append(";");

        o.println(str);
    }

};
