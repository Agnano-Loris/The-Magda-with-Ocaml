package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.MixinExpressions.*;


public class CParameterDeclaration implements IProgramElem{   
    
    private static final long serialVersionUID = 1L;
    
    String ParName;
    IMixinExpression Type;
  
    public CParameterDeclaration(String aParName, IMixinExpression aType){ 
        ParName = aParName;
        Type = aType;
    }

    public void print(java.io.PrintStream o){ 
        o.print(" param "+ParName+":");
        Type.print(o);
        o.println(";");
    }

    public CType GetType(CMethodEnvironment env){ 
        return Type.GetType(env);
    }

 	public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h){ 
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append("{\n");

        CGenCodeHelper.addTab();        

        str.append(CGenCodeHelper.tab);
        str.append("int offset = AllSequence.getMixinOffsetByName(\"");
        str.append(env.CurrentMixin.MixinName);
        str.append("\")+");
        str.append(String.valueOf(env.CurrentMixin.getFieldParamOffset(ParName)));
        str.append(";\n");
        
        str.append(CGenCodeHelper.tab);
        o.println("aObjectBody[offset] = new CMagdaProperty ();");

        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("}");

        o.println(str);
	}


	public String ExpandVariableInNative(String input, int i){ 
		return input.replaceAll("\\$"+ParName+"\\$", "params["+String.valueOf(i)+"]" );
	}

};
