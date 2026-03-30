package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CObjectCreation implements IExpression{
    
    private static final long serialVersionUID = 1L;

    CInitializationOfParams Init;
    IMixinExpression MixinExpr;

    public CObjectCreation( IMixinExpression aMixinExpr, CInitializationOfParams aInit){ 
        MixinExpr = aMixinExpr;
        Init = aInit;
    }

    public CType GetType(CInstrEnvironment env){ 
        Init.CheckTypes(env);
        //
        CType nativeType = MixinExpr.GetNativeType(env);
        CNewMethodDeclarations decls =  nativeType.calcAbstractMethods(env);
        if (decls.size() >0)
            throw new CTypeError("Cannot create object of type "+ nativeType +" with abstract methods, ie: "+decls.get(0).getMixinName() +"."+decls.get(0).getMethodName() );
        //
        nativeType.CheckIfBaseMixinsExist(env);
        //
        return MixinExpr.GetType(env);
    }
    
    public String GetTypeString (){
        // System.out.println("// CObjectCreation.GetTypeString()->empty");
        return ("Integer");   // as default arithmetci operations about Integers
    }

    public void print(java.io.PrintStream o){ 
        o.print("(new  ");
        MixinExpr.print(o);
        o.print("[");
        Init.print(o);
        o.print("])");
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){  
        StringBuilder str = new StringBuilder(100);
        
        o.print(CGenCodeHelper.tab+"{ //object creation for: "); MixinExpr.print(o); o.println("");

        CGenCodeHelper.addTab();        

        str.append(CGenCodeHelper.tab);
        str.append("CMagdaMixinSequence tempList= new CMagdaMixinSequence();\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("tempList.add( CMagdaMixinSequence.globalList.getMixin(\"Object\"));\n");

        o.println(str);
        str.setLength(0);        

        MixinExpr.GenCodeForMixinExpression (o, env,  h);
        
        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));str.append("= tempList.CreateObject();\n");
        
        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
        str.append("}");
        
        o.println(str);
        str.setLength(0);        
        
        String IniParamsSetter="";
        
        CGenCodeHelper.addTab();        
        for (int i=0; i<Init.size(); i++){ 
            int temp = h.getTemp();
            Init.get(i).Expr.GenCode(o, env, h, temp);
            IniParamsSetter += CGenCodeHelper.tab+"IniParamsObjectCreation.putParamValue(\""+Init.get(i).MixinName+"\",\""+Init.get(i).ParamName+"\","+h.tempAcc(temp)+");\n";
        }
        CGenCodeHelper.removeTab();        
      
        str.append(CGenCodeHelper.tab);
        str.append("{\n");

        CGenCodeHelper.addTab();

        str.append(CGenCodeHelper.tab);
        str.append("CMagdaIniParams IniParamsObjectCreation = new CMagdaIniParams();\n");
        
        //str.append(CGenCodeHelper.tab;
        str.append(IniParamsSetter);
        str.append("\n");

        str.append(CGenCodeHelper.tab);
        str.append("CMagdaIniModules modules = new CMagdaIniModules();\n");
        
        o.println(str);
        str.setLength(0);        
        
        int modulecount=MixinExpr.GetType(env).GenCodeForActivatedModules(o, env, h, Init);
        if (modulecount>0){ 
            str.append(CGenCodeHelper.tab);
            str.append("CMagdaIniModule firstModule = modules.remove(0);\n");
        
            str.append(CGenCodeHelper.tab);
            str.append("firstModule.Execute(");str.append(h.tempAcc(target));str.append(",modules, IniParamsObjectCreation);\n");
        }

        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
        str.append("}\n");

        /*Init.GenCode(o,  env, h, target);*/

        str.append(CGenCodeHelper.tab);
        str.append(h.tempAcc(target));
        str.append(".executeMethodByName(\"Object\", ");
        str.append(String.valueOf(env.getMixin("Object").getMethodOffset("Init")));
        str.append(", new CMagdaObject[0]);");

        o.println(str);

    }

};
