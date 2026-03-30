package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Instructions.*;


public class CMethodBody extends CMemberBody{
    
    private static final long serialVersionUID = 1L;

	public CMethodBody (CVariableDeclarations aDecls, CInstructions aInstrs){ 
        super (aDecls, aInstrs);
	}

	

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, String aMixinName, String aMethodName, boolean override){ 
        StringBuilder str = new StringBuilder(100);        

        str.append(CGenCodeHelper.tab);
        str.append("// start of declaration of method ");str.append(aMixinName);str.append(".");str.append(aMethodName);str.append("\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("{\n");
        
        CGenCodeHelper.addTab();
        
        //this is all one line
        str.append(CGenCodeHelper.tab);
        str.append("int offset = AllSequence.getMixinOffsetByName(\"");
        str.append(aMixinName); 
        str.append("\")+");
        str.append(String.valueOf(env.getMixin(aMixinName).getMethodOffset(aMethodName)));
        str.append(";\n");
        

        if (override){
            str.append(CGenCodeHelper.tab);
            str.append("aObjectBody[offset] = new CMagdaMethodOverloaded ( (CMagdaMethod) aObjectBody[offset]);\n");
            
            str.append(CGenCodeHelper.tab);
            str.append("((CMagdaMethodOverloaded)aObjectBody[offset]).setExecuteFunction( (aSelf,params,SuperBody) -> {");

            o.println(str);		    
            str.setLength(0);
        
            CGenCodeHelper.addTab();
            super.GenCode(o, env, h, true);
            CGenCodeHelper.removeTab();		    

            str.append(CGenCodeHelper.tab);
            str.append("}); // end of declaration of method ");str.append(aMixinName);str.append(".");str.append(aMethodName);str.append("\n");
	    }
        else{
            str.append(CGenCodeHelper.tab);
            str.append("aObjectBody[offset] = (CMagdaMethod)(CMagdaObject aSelf, CMagdaObject[] params) -> {");
            
            o.println(str);		    
            str.setLength(0);
		    
            CGenCodeHelper.addTab();
            super.GenCode(o, env, h, true);
            CGenCodeHelper.removeTab();            

            str.append(CGenCodeHelper.tab);
            str.append("};\n");
        }
        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("};");
        
        o.println(str);
    }


};
