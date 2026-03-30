package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CFieldDeclaration implements IProgramElem{
    
    private static final long serialVersionUID = 1L;
	
    public String VarName;
	public IMixinExpression Type;

	public CFieldDeclaration (String aVarName, IMixinExpression aType){ 
        VarName = aVarName;
	    Type= aType;
	}

    public void print(java.io.PrintStream o){ 
        o.print(" field "+VarName+":");
        Type.print(o);
        o.println(";");
    }
        
    public void CheckTypes(CMethodEnvironment env) throws CTypeError{ 
        GetType(env);
        
        for (int i=0; i<env.CurrentMixin.Flds.size(); i++)
            if ( (env.CurrentMixin.Flds.get(i) != this) && env.CurrentMixin.Flds.get(i).VarName.equals(VarName))
                throw new CTypeError("Field "+env.CurrentMixin.MixinName+"."+VarName+" redeclared");
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
        str.append(String.valueOf(env.CurrentMixin.getFieldParamOffset(VarName)));
        str.append(";\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("aObjectBody[offset] = new CMagdaProperty ();\n");

        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
        str.append("}");

        o.println(str);
	}


};
