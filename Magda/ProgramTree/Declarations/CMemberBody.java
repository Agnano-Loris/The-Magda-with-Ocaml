package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.Instructions.*;


// the BODY of a Method or a Initialization module

public class CMemberBody implements IProgramElem{
    
    private static final long serialVersionUID = 1L;

    CVariableDeclarations Decls;
	CInstructions Instrs;

    public CMemberBody (CVariableDeclarations aDecls, CInstructions aInstrs){ 
        Decls = aDecls;
  	    Instrs = aInstrs;
	}

    public void print(java.io.PrintStream o){ 
        Decls.print(o);
	    o.println("");
	    o.println("begin");
	    Instrs.print(o);
	    o.println("end;");
    }

	public void CheckTypes(CInstrEnvironment env){ 
        Instrs.CheckTypes(env);
	    Decls.CheckTypes(env);
	}
	

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, boolean returnNull){
        StringBuilder str = new StringBuilder(100);

        str.append(CGenCodeHelper.tab);
        str.append("CMagdaObject[] temp = new CMagdaObject[100];\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("CMagdaObject[] localVars = new CMagdaObject [");str.append(String.valueOf(Decls.size()));str.append("];\n");          
        
        str.append(CGenCodeHelper.tab);
        str.append("String OldProgramFile = MagdaProgramFile;\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("int OldMagdaLineNo =  MagdaLineNo;\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("try {");

        o.println(str);
        str.setLength(0); 
 
        CGenCodeHelper.addTab();
        Instrs.GenCode( o, env, h);
        CGenCodeHelper.removeTab();        
 
        str.append(CGenCodeHelper.tab);
        str.append("}\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("finally{\n");
       
        CGenCodeHelper.addTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("MagdaProgramFile= OldProgramFile;\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("MagdaLineNo= OldMagdaLineNo;\n");
        
        CGenCodeHelper.removeTab();
        
        str.append(CGenCodeHelper.tab);
        str.append("}\n");
        
        if (returnNull){
            str.append(CGenCodeHelper.tab);
            str.append("return null;");
        }

        o.println(str);
        
        //o.println(" }; };");
    }

};
