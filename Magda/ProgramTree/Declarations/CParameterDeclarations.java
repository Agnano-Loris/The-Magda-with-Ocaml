package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.Expressions.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;


public class CParameterDeclarations extends CProgramElemVector<CParameterDeclaration>{
    
    private static final long serialVersionUID = 1L;
    
    public int indexOfName(String name){   
        for (int i=0; i<size(); i++)
	        if (get(i).ParName.equals (name) )
		        return i;
	    return -1;
    }

   	public String ExpandVariablesInNative(String input){ 
        for (int i=0; i<size(); i++){ 
	        input = get(i).ExpandVariableInNative( input, i );
		}
	    return input;
	}

    public void CheckTypes( CMethodEnvironment env)  throws CTypeError{ 
        for (int i=0; i<size(); i++)
	        get(i).GetType(env);
	}

    IMethodDeclaration method;

	public boolean isIsomorphicTo (CType targetType, CMethodEnvironment env, CParameterDeclarations other)  throws CTypeError{ 
        CMethodEnvironment envOfTargetObject = new CMethodEnvironment ( env, method.getMixin() );
	    //
        for (int i=0; i<size(); i++){
		    if ( !get(i).Type.GetType(envOfTargetObject).setPolyParamsFrom(targetType.getApplications(env)).isIsomorphicTo(env, other.get(i).Type.GetType(env)))
		        return false;
	    }
        return true;
	}

	public void setMethod(IMethodDeclaration amethod){ 
        method = amethod;
	}

	public void CheckTypesOfActualParameters( CType targetType, CInstrEnvironment env, CExpressionList ActualParams ) throws CTypeError{ 
        if (ActualParams.size() != size() )
		    throw new CTypeError ("Wrong number of arguments");
	    //
	    CMethodEnvironment envOfTargetObject = new CMethodEnvironment ( env, method.getMixin() );
	    //
	    for (int i=0; i<size(); i++)
	        ActualParams.get(i).GetType(env).CheckIsSubTypeOf( env, get(i).Type.GetType(envOfTargetObject).setPolyParamsFrom(targetType.getApplications(env)) );
	}

};
