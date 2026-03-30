package Magda.ProgramTree.Declarations;

import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.MixinExpressions.*;

public class CAbstractMethodDeclaration extends CInterfaceMethodDeclaration{
    
    private static final long serialVersionUID = 1L;
    
    /*

        To instanciate this class I opted for a static-factory approach, this allows us to create an instance of CAbstractMethodDeclaration with the
        same logic as the old version, passing all the parameters that we used to, so we don't change the logc whatsoever.
        BUT this allow us to avoid any possible this-escape warning

        !!

        aPars.setMethod(. . .) was called in the abstract contructor of CInterfaceMethodDeclaration, it has been removed to avoid this-escapes
        if you intend to extend CInterfaceMethodDeclaration make sure to call aPars.setMethod()!         

        !!    

    */

    public static CAbstractMethodDeclaration createCAbstractMethodDeclaration(IMixinExpression aResType, 
                                       String aMethodName, 
                                       CParameterDeclarations aPars, 
                                       int aPosInCode, 
                                       String aProgramFile){

        CAbstractMethodDeclaration res = new CAbstractMethodDeclaration(aResType,aMethodName,aPars,aPosInCode,aProgramFile);
        
        aPars.setMethod(res);
        
        return res;
    }

    protected CAbstractMethodDeclaration (IMixinExpression aResType, 
                                       String aMethodName, 
                                       CParameterDeclarations aPars, 
                                       int aPosInCode, 
                                       String aProgramFile){ 
        super( aResType, aMethodName, aPars, aPosInCode, aProgramFile);
	}
	
    public void print(java.io.PrintStream o){ 
        o.println(" abstract method ");
	    ResType.print(o);
	    o.print(MethodName+ "(");
        Pars.print(o);
	    o.println(");");
	}

    public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h){ 
        o.println(CGenCodeHelper.tab+"//abstract method "+MethodName);
    }

};
