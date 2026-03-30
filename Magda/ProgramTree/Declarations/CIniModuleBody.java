package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Instructions.*;


public class CIniModuleBody extends CMemberBody{
    
    private static final long serialVersionUID = 1L;

	public CIniModuleBody (CVariableDeclarations aDecls, CInstructions aInstrs){ 
        super (aDecls, aInstrs);
	}

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, String aMixinName, CSourceInitializationParameters InputParams){ 	
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append("(aSelf, ModulesToExecute, IniParams) -> {");

        CGenCodeHelper.addTab();       
 
        str.append(CGenCodeHelper.tab);
        str.append("CMagdaObject[] params = new CMagdaObject[");
        str.append(InputParams.size());
        str.append("];  //preparing list of input parameters\n");
		
        for (int i=0; i<InputParams.size(); i++){ 
            str.append(CGenCodeHelper.tab);
            str.append("params[");
            str.append(i);
            str.append("] = IniParams.removeParamValue(\"");
            str.append(InputParams.get(i).MixinName);
            str.append("\",\"");
            str.append(InputParams.get(i).ParName);
            str.append("\");\n");
		}

        o.println(str);
        str.setLength(0);		

        super.GenCode(o, env, h, false);

        CGenCodeHelper.removeTab();

        str.append(CGenCodeHelper.tab);
		str.append("};");
        str.append(" // end of IniModule of ");str.append(aMixinName);

        o.println(str);
    }


};
