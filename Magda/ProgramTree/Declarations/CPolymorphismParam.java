 package Magda.ProgramTree.Declarations;

import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class  CPolymorphismParam implements IProgramElem, ITypeElement, IDeclaration{    
    
    private static final long serialVersionUID = 1L;
    
    String Name;
    IMixinExpression BoundExpr;
    CMixinDeclaration container;

    public String getCaption(){ 
        return container.getCaption() +"."+getName();
    } 
     
    public String getName(){ 
        return Name;
    }
	
    public CPolyApplicationValues getApplications(CMethodEnvironment env){ 
        return BoundExpr.GetType (env).getApplications(env);
    }

    public void print (java.io.PrintStream o){ 
        o.print(Name);
	    o.print ("<=");
	    BoundExpr.print(o);
	    o.println(";");
    }

  	public void GenCodeForMixinExpression (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){ 
        throw new Error ("CPolymorphismParam.GenCodeForMixinExpression mnot yet implemented");
	}

    public CType GetBoundingType (CEnvironment env){ 
        return BoundExpr.GetType(new CMethodEnvironment(env, container));
    }

    public CType GetType (CMethodEnvironment env){ 
        if (env.calculatedTypes.get(this) != null)
            return /*(CType)*/ env.calculatedTypes.get(this);
        //
        CType res = CType.createCType(env, this);
        env.calculatedTypes.put(this, res);
        return res;
        //
    }
  
    public CType GetNativeType (CMethodEnvironment env){ 
        throw new CTypeError("GetNativeType not supported by polymorphic param");
    }

	public void setMixin (CMixinDeclaration acontainer){ 
        container = acontainer;
	}

	
	public void CheckTypes(CEnvironment env){ 
        BoundExpr.GetType(new CMethodEnvironment(env, container) );
	}

	public void GenCode (java.io.PrintStream o, CEnvironment env, CGenCodeHelper h){ 
        throw new Error ("CPolymorphismParam.GenCode shouldn't be called here");
    }

    public CPolymorphismParam(String aName, IMixinExpression aBoundExpr){ 
        Name= aName;
	    BoundExpr = aBoundExpr;
	}
};
