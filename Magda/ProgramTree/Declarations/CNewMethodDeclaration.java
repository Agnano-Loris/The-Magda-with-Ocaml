package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;

public class CNewMethodDeclaration extends CInterfaceMethodDeclaration{
    
    private static final long serialVersionUID = 1L;

	CMethodBody Body;


    /*

        To instanciate this class I opted for a static-factory approach, this allows us to create an instance of CNewMethodDeclaration with the
        same logic as the old version, passing all the parameters that we used to, so we don't change the logc whatsoever.
        BUT this allow us to avoid any possible this-escape warning

        !!

        aPars.setMethod(. . .) was called in the abstract contructor of CInterfaceMethodDeclaration, it has been removed to avoid this-escapes
        if you intend to extend CInterfaceMethodDeclaration make sure to call aPars.setMethod()!         

        !!    

    */

    public static CNewMethodDeclaration createCNewMethodDeclaration( IMixinExpression aResType, 
                                                                     String aMethodName, 
                                                                     CParameterDeclarations aPars, 
                                                                     CMethodBody aBody, 
                                                                     int aPosInCode, 
                                                                     String aProgramFile){
        CNewMethodDeclaration res = new CNewMethodDeclaration(aResType,aMethodName,aPars,aBody,aPosInCode,aProgramFile);

        aPars.setMethod(res);
        
        return res;
    }

	private CNewMethodDeclaration ( IMixinExpression aResType, 
                                    String aMethodName, 
                                    CParameterDeclarations aPars, 
                                    CMethodBody aBody, 
                                    int aPosInCode, 
                                    String aProgramFile){ 
        super( aResType, aMethodName, aPars, aPosInCode, aProgramFile);
	    Body = aBody;
	}

    public void print(java.io.PrintStream o){ 
        o.println(" new method "+MethodName+ "(");
	    ResType.print(o);
	    Pars.print(o);
	    o.println(")");
	    Body.print(o);
	}

    CInstrEnvironment BuildEnv (CMethodEnvironment env){ 
        return new CInstrEnvironment (env.Decls, env.CurrentMixin, Body.Decls, Pars, this);
	}

	public void CheckTypes(CMethodEnvironment env){ 
        super.CheckTypes(env);
	    Body.CheckTypes( BuildEnv(env) );
	}

    public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h){ 	
        Body.GenCode(o, BuildEnv(env), h, env.CurrentMixin.MixinName, MethodName, false);
    }
};
