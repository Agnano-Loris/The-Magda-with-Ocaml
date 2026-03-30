package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;

import java.util.*;

import Magda.Compiler.*;


public class CSourceInitializationParameters extends CProgramElemVector<CSourceInitializationParameter>{
    
    private static final long serialVersionUID = 1L;

	public CParameterDeclarations toFlatParameters(){ 
        CParameterDeclarations result = new CParameterDeclarations();
	  
        for (int i=0; i< size() ; i++ ){  
            result.add( new CParameterDeclaration(get(i).ParName, get(i).Type));
	    }
	  
        return result;
    }
        
    public boolean containsParam(String MixinName, String ParName){ 
        for (int i=0; i<size(); i++)
            if (get(i).MixinName.equals(MixinName) && get(i).ParName.equals(ParName))
                return true;
        
        return false;
    }

    public ArrayList<String> getParamNames(){
        ArrayList<String> ret = new ArrayList<String>();

        for(CSourceInitializationParameter param : this)
            ret.add(param.ParName);

        return ret;
    }
                
    public void CheckTypes( CMethodEnvironment env)  throws CTypeError { 
        for (int i=0; i<size(); i++)
	        get(i).GetType(env);
	}

 
}
