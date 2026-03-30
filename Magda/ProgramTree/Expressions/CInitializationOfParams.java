package Magda.ProgramTree.Expressions;
import Magda.ProgramTree.*;
import Magda.Compiler.*;

import java.util.*;

public class CInitializationOfParams extends CProgramElemVector<CInitializationOfParam>{
    
    private static final long serialVersionUID = 1L;

    public void GenCode (java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, int target){ 
        for (int i=0; i<size(); i++)
	        get(i).GenCode(o, env, h, target);
	}

    public void CheckTypes (CInstrEnvironment env){ 
        for (int i=0; i<size(); i++)
	        get(i).CheckTypes(env);
	}

    public CInitializationOfParam locateParam(String MixinName, String ParamName){ 
        for (int i=0; i<size(); i++){ 
            if (get(i).MixinName.equals(MixinName) && get(i).ParamName.equals(ParamName))
	            return get(i);
	    }
      
        return null;
    }

   public void removeParam (String MixinName, String ParamName){ 
        if (locateParam(MixinName, ParamName) == null)
            throw  new Error("No parameter "+MixinName+"."+ParamName +" to remove");
     
        remove (locateParam(MixinName, ParamName));
   }

   public boolean containsParam(String MixinName, String ParamName){ 
        return locateParam(MixinName, ParamName) != null;
   }

}
