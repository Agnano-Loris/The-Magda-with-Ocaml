package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;


public abstract class CInterfaceMethodDeclaration implements INewMethodDeclaration{
    
    private static final long serialVersionUID = 1L;

    String MethodName;
	IMixinExpression ResType;
	CParameterDeclarations Pars;
	int PosInCode;
	String ProgramFile;
	CMixinDeclaration ContainerMixin;

    /*
        !!

        aPars.setMethod(. . .) was called here in the contructor of CInterfaceMethodDeclaration, it has been removed to avoid this-escapes
        if you intend to extend CInterfaceMethodDeclaration make sure to call aPars.setMethod() in a the static-factory of the extended class!         

        !!    
    */

    public CInterfaceMethodDeclaration(IMixinExpression aResType, String aMethodName, CParameterDeclarations aPars, int aPosInCode, String aProgramFile){ 
        ResType = aResType;
	    MethodName= aMethodName;
	    Pars = aPars;
	    PosInCode = aPosInCode;
	    ProgramFile = aProgramFile;
        
        // this is called in the factories of the classes that extends CInterfaceMethodDeclaration
        // aPars.setMethod(this);
    }

    public CParameterDeclarations getFormalParameters(){ 
        return Pars;
    }

    public void CheckTypes(CMethodEnvironment env) throws CTypeError {
        CTypeError.LineNo = PosInCode;
        CTypeError.ProgramFile = ProgramFile;
        ResType.GetType(env);
        Pars.CheckTypes(env);
        for (int i=0; i<env.CurrentMixin.NewMethods.size(); i++)
            if ( (env.CurrentMixin.NewMethods.get(i) != this) &&
                    (env.CurrentMixin.NewMethods.get(i).getMethodName().equals(MethodName)))
                throw new CTypeError("Method named "+env.CurrentMixin.MixinName+"."+MethodName+" redeclared!");
    }


    public String getMethodName(){ 
        return MethodName;
    }

    public CType getResultType(CMethodEnvironment env){ 
        return ResType.GetType(env);
    }

	public void setMixin (CMixinDeclaration container){ 
        ContainerMixin = container;
	}

	public CMixinDeclaration getMixin(){ 
        return ContainerMixin;
	}

    public String getMixinName(){ 
        return ContainerMixin.MixinName;
	}

}
