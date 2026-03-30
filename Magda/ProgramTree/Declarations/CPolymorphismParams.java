package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;


import java.util.*;

public class CPolymorphismParams extends CProgramElemVector<CPolymorphismParam>{
    
    private static final long serialVersionUID = 1L;
	
    public CPolymorphismParam findByName(String aName){ 
        for (int i=0; i<size(); i++)
	        if (get(i).getName().equals(aName))
	            return get(i);
	  
        return null;
    }

	public void setMixin (CMixinDeclaration container){ 
        for (int i=0; i<size(); i++)
		    get(i).setMixin(container);
	}
}
