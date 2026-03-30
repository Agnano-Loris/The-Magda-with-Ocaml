package Magda.ProgramTree.Declarations;
import Magda.ProgramTree.*;
import Magda.ProgramTree.Expressions.*;
import Magda.ProgramTree.MixinExpressions.*;
import Magda.Compiler.*;
import java.io.*;

public class CIniModuleDeclaration  implements IProgramElem{
    
    private static final long serialVersionUID = 1L;
	
    CIniModuleBody Body;
	int PosInCode;
	String ProgramFile;
    public CSourceInitializationParameters InputParams, OutputParams;
    String MixinName;
	public boolean isRequired;

	public CIniModuleDeclaration (boolean aisRequired, String aMixinName, CSourceInitializationParameters aInputParams, CSourceInitializationParameters aOutputParams, CIniModuleBody aBody, int aPosInCode, String aProgramFile){ 
        
        Body = aBody;
	    InputParams = aInputParams;
	    OutputParams = aOutputParams;
	    MixinName = aMixinName;
	    isRequired = aisRequired;
	
    }

    public void printHeader(java.io.PrintStream o){ 
        o.println(" ini module "+ MixinName + "(");
	    InputParams.print(o); 
        o.print( " initializes (");
	    OutputParams.print(o);
	    o.println(")");
    }
        
    public String toString(){ 
        ByteArrayOutputStream s = new ByteArrayOutputStream();
        printHeader( new PrintStream(s));
        return s.toString();
    }
                
	public void print(java.io.PrintStream o){  
        printHeader(o);
        Body.print(o);
	}

    CInstrEnvironment BuildEnv (CMethodEnvironment env){ 
        return new CInstrEnvironment (env.Decls, env.CurrentMixin, Body.Decls, InputParams.toFlatParameters(), this);
	}

	public void CheckTypes(CIniModuleEnvironment env) throws CTypeError{ 
        InputParams.CheckTypes(env);
	    Body.CheckTypes( BuildEnv(env) );
        
        for (int i=0; i<OutputParams.size();i++){ 
            CSourceInitializationParameter par = OutputParams.get(i);
            if ( env.CurrentMixin.ModuleContainsInputParameter( par, env.moduleNumber ) )
                continue;
            if ( env.CurrentMixin.BaseMixinExpression.GetType(env).ModuleContainsInputParameter(env,  par ))
                continue;
            throw new CTypeError("Output parameter  [" + par.MixinName+"."+ par.ParName+"] does not refer to any another module declaration");
        }
        /*          
        for (int i=0; i< env.CurrentMixin.IniModules.size(); i++){ 
            CIniModuleDeclaration mod =env.CurrentMixin.IniModules.get(i);
            if (mod != this)
                for (int j=0; j<InputParams.size(); j++)
                    if(mod.InputParams.containsParam(InputParams.get(j).MixinName, InputParams.get(j).ParName ))
                        throw new CTypeError("Input parameter "+InputParams.get(j).MixinName +"."+InputParams.get(j).ParName+ " is declared in two different modules");
              
        }
        */
    }

    public void GenCode (java.io.PrintStream o, CMethodEnvironment env, CGenCodeHelper h){ 	
        Body.GenCode(o, BuildEnv(env), h, MixinName, InputParams);
    }

	public void modifyParametersList(CInitializationOfParams params){ 
        for (int i=0; i<InputParams.size(); i++)
  	        params.removeParam(InputParams.get(i).MixinName, InputParams.get(i).ParName);
	    for (int i=0; i<OutputParams.size(); i++)
	        params.add( new  CInitializationOfParam (OutputParams.get(i).MixinName, OutputParams.get(i).ParName, null));
	}

    public boolean activatedBy(CInitializationOfParams params){ 
        if (InputParams.size()==0)
	        return true;
	    boolean res = params.containsParam(InputParams.get(0).MixinName, InputParams.get(0).ParName);
	    for (int j=1; j<InputParams.size(); j++){  
            if (params.containsParam(InputParams.get(j).MixinName, InputParams.get(j).ParName) != res){ 
                throw new Error ("partial Instantiation of module "+MixinName +"("+InputParams.toString()+")");
	        }
	    }
        return res;
    }

};
