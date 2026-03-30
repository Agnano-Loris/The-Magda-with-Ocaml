package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.Compiler.*;
import Magda.ProgramTree.MixinExpressions.*;

public class COverrideMethodDeclaration implements IMethodDeclaration{
    
    private static final long serialVersionUID = 1L;
    
    String MixinName;
	String MethodName;
	CMethodBody Body;
	IMixinExpression ResType;
	CParameterDeclarations Pars;
	CMixinDeclaration ContainerMixin;

	int LineNo=-1;
	String ProgramFile;

	public CParameterDeclarations getFormalParameters(){ 
        return Pars;
	}
    
    /*

        To instanciate this class I opted for a static-factory approach, this allows us to create an instance of COverrideMethodDeclaration with the
        same logic as the old version, passing all the parameters that we used to, so we don't change the logc whatsoever.
        BUT this allow us to avoid any possible this-escape warning    

    */
	
    public static COverrideMethodDeclaration createCOverrideMethodDeclaration (IMixinExpression aResType, 
                                       String aMixinName, 
                                       String aMethodName, 
                                       CParameterDeclarations aPars, 
                                       CMethodBody aBody, 
                                       int aLineNo, 
                                       String aProgramFile){ 
        
        COverrideMethodDeclaration res = new COverrideMethodDeclaration(aResType,aMixinName,aMethodName,aPars,aBody,aLineNo,aProgramFile);
        
	    aPars.setMethod(res);

        return res;
	}

	protected COverrideMethodDeclaration (IMixinExpression aResType, 
                                       String aMixinName, 
                                       String aMethodName, 
                                       CParameterDeclarations aPars, 
                                       CMethodBody aBody, 
                                       int aLineNo, 
                                       String aProgramFile){ 
        MixinName = aMixinName;
	    MethodName= aMethodName;
 	    Body = aBody;
	    ResType = aResType;
	    Pars = aPars;
	    LineNo = aLineNo;
	    ProgramFile = aProgramFile;
	    //aPars.setMethod(this);
	}

    public void print(java.io.PrintStream o){ 
        o.println(" override method "+MixinName+" . "+MethodName);
	    Body.print(o);
	    o.println("end;");
	}

    public CType getResultType(CMethodEnvironment env){ 
        return ResType.GetType(env);
	}

    CInstrEnvironment BuildEnv (CMethodEnvironment env){ 
        return new CInstrEnvironment (env.Decls, env.CurrentMixin, Body.Decls, Pars, this);
	}

	public INewMethodDeclaration GetSourceMethod(CMethodEnvironment  env){ 
        return env.getMixin(MixinName).getNewMethod(MethodName);
	}

	public void CheckTypes(CMethodEnvironment env){ 
        CTypeError.LineNo = LineNo;
	    CTypeError.ProgramFile = ProgramFile;
	    ResType.GetType(env);
	    Pars.CheckTypes(env);
        //
	    if (!GetSourceMethod(env).getResultType(env).isIsomorphicTo(env, getResultType(env)))
		    throw new CTypeError ("Result type differs in overriding method " + MethodName);
	    //
	    if (!env.getMixin(MixinName).getNewMethod(MethodName).getFormalParameters().isIsomorphicTo(ContainerMixin.GetType(env), env, getFormalParameters()))
		    throw new CTypeError ("Parameter lists differs  in overriding method " + MethodName);
	    //
	    Body.CheckTypes( BuildEnv (env) );
	}

    public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h){ 	
        Body.GenCode(o, BuildEnv (env), h, MixinName, MethodName, true);
    }

	public CMixinDeclaration getMixin(){ 
        return ContainerMixin;
	}

   	public void setMixin (CMixinDeclaration container){ 
        ContainerMixin = container;
	}
};
