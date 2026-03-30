package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import java.util.*;

public class CFieldSelectExpression implements IExpression{
    
    private static final long serialVersionUID = 1L;
    
    public IExpression SelectTarget;
    String MixinName;
    String FieldName;
    public String typeString;    
    
    public CFieldSelectExpression (IExpression aSelectTarget, String aMixinName, String aFieldName, String aTypeString){
        SelectTarget = aSelectTarget;
        MixinName = aMixinName;
        FieldName = aFieldName;
        typeString = aTypeString;
    }

    public CFieldSelectExpression (IExpression aSelectTarget, String aMixinName, String aFieldName){
        SelectTarget = aSelectTarget;
        MixinName = aMixinName;
        FieldName = aFieldName;
        typeString = "Integer";
    }

    public CType GetType (CInstrEnvironment env){
        return env.getMixin(MixinName).getFieldParamType(env, FieldName);
    }
    
    public String GetTypeString (){
        // System.out.println("// CFieldSelectExpression.GetTypeString()->empty");
        return typeString;   // as default arithmetci operations about Integers
    }

    public void print(java.io.PrintStream o){
        o.print("(");
        SelectTarget.print(o);
        o.print(")");
        o.print(".sel "+MixinName+"."+FieldName);
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){
        int Targetplace = h.getTemp();
        SelectTarget.GenCode(o, env, h, Targetplace);
        
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));
        str.append("=");
        str.append(h.tempAcc(Targetplace));
        str.append(".getStateHolderByName(\"");
        str.append(MixinName);
        str.append("\",");
        str.append(String.valueOf (env.getMixin(MixinName).getFieldParamOffset(FieldName)));
        str.append(").Value;");

        o.println(str);
    }

};
