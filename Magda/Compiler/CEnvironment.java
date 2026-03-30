package Magda.Compiler;

import Magda.ProgramTree.*;
import Magda.ProgramTree.Declarations.*;
import java.util.*;

public class CEnvironment {

    public CGlobalDeclarations Decls;
	public Dictionary<IDeclaration,CType> calculatedTypes;

	public CEnvironment(CGlobalDeclarations adecls){ 
        Decls = adecls;
	    calculatedTypes = new Hashtable<IDeclaration,CType>();
	}

	public CEnvironment(CGlobalDeclarations adecls, Dictionary<IDeclaration,CType> acalculatedTypes){ 
        Decls  =adecls;
 	    calculatedTypes = acalculatedTypes;
    }


    public CMixinDeclaration getMixin(String name){ 
        for (int i=0; i<Decls.size(); i++){ 
            if (Decls.get(i) instanceof CMixinDeclaration){ 
                CMixinDeclaration aMixin = (CMixinDeclaration) Decls.get(i);
		        if (aMixin.MixinName.equals(name))
   	                return aMixin;
	        };
  	    };

	    throw new Error("mixin "+name+" not found!");
	}

	public IDeclaration getDeclaration(String name){ 
        for (int i=0; i<Decls.size(); i++)
	        if (Decls.get(i).getName().equals(name))
		        return Decls.get(i);

	    throw new Error("Declaration "+name+" not found!");
	}

};
