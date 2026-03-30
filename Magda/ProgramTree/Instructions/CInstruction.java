package Magda.ProgramTree.Instructions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;


public abstract class CInstruction implements IInstruction{
    
    private static final long serialVersionUID = 1L;

    public int PosInProgram;
    public String ProgramFile;

    public void CheckTypes (CInstrEnvironment env){ 
        CTypeError.LineNo = PosInProgram;
        CTypeError.ProgramFile = ProgramFile;
    }

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h){ 
        StringBuilder str = new StringBuilder(100);
        
        str.append(CGenCodeHelper.tab);
        str.append("MagdaLineNo= ");str.append(String.valueOf(PosInProgram));str.append(";\n");
        
        str.append(CGenCodeHelper.tab);
        str.append("MagdaProgramFile = \"");
        str.append(ProgramFile);
        str.append("\"; // Position in source: ");
        str.append(ProgramFile);
        str.append(".");
        str.append(String.valueOf(PosInProgram));

        o.println(str);

        h.resetTemp();
    }

}
