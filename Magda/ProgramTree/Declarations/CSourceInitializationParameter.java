package Magda.ProgramTree.Declarations;

import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CSourceInitializationParameter implements IProgramElem{   
    
    private static final long serialVersionUID = 1L;
    
    public String MixinName;
    public String ParName;
    IMixinExpression Type;

    public CSourceInitializationParameter (String aMixinName, String aParName, IMixinExpression aType){ 
        MixinName = aMixinName;
        ParName   = aParName;
        Type      = aType;
    }

    public void print(java.io.PrintStream o){ 
        o.print(" param "+ MixinName+ "." +ParName);
        o.print(",");
    }
    
    public CType GetType(CMethodEnvironment env){ 
        return Type.GetType(env);
    }


}
