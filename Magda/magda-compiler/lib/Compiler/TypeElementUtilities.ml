open Types

type t = TypeElements.t

let get_applications method_env (module TypeEl : ModuleSignatures.TypeElementSig.S with type t = TypeElement.t) (type_element:t) =     
	let appl_list = List.map (TypeEl.get_applications method_env) type_element.types in
	List.fold_left List.append type_element.poly_app_val

(*
public CPolyApplicationValues getApplications(CMethodEnvironment env){ 
        CPolyApplicationValues result = (CPolyApplicationValues) app.clone();
      
        for (int i=0; i<size(); i++)
            result.addAll( get(i).getApplications (env) );
      
        return result;
    }


package Magda.Compiler;
import Magda.ProgramTree.Declarations.*;
import Magda.ProgramTree.Expressions.*;

import java.util.ArrayList;


public class CType extends ArrayList<ITypeElement>{

    private static final long serialVersionUID = 1L;
   
    boolean isAll=false;

    private CPolyApplicationValues app;

    public CPolyApplicationValues getApplications(CMethodEnvironment env){ 
        CPolyApplicationValues result = (CPolyApplicationValues) app.clone();
      
        for (int i=0; i<size(); i++)
            result.addAll( get(i).getApplications (env) );
      
        return result;
    }
    
    public CType deepCopy(){
        CType res= (CType) this.clone();
        res.app = (CPolyApplicationValues) this.app.clone();
        return res;
    }
    
    //------------ static-factories ---------------
    
    /*

        To instanciate this class I opted for a static-factory approach, this allows us to create an instance of CType with the
        same logic as the old version, passing all the parameters that we used to, so we don't change the logc whatsoever.
        BUT this allow us to avoid any possible this-escape warning    

    */

    public static CType createCType(boolean isAll){
        CType res = new CType(isAll);
        
        res.app = new CPolyApplicationValues();

        return res;
    }
    
    public static CType createCType(CEnvironment env, CPolymorphismParam param, CType value){
        CType res = new CType(env,param,value);
        
        res.add (env.getMixin("Object"));
        res.app = new CPolyApplicationValues();
        res.app.add( new  CPolyApplicationValue(param, value) );

        return res;
    }

    public static CType createCType(CEnvironment env, ITypeElement aTypeElement){
        CType res = new CType(env,aTypeElement);
        
        res.app = new CPolyApplicationValues();
        res.add (env.getMixin("Object"));
        res.add (aTypeElement);

        return res;
    
    }

    //------------ constructors ---------------

    protected CType(boolean isAll){ 
        super();
        
        if (isAll)
            this.isAll= true;
      
        //app = new CPolyApplicationValues();
        //else - void
    }

    protected CType(CEnvironment env, CPolymorphismParam param, CType value){  
        super();
      
        //add (env.getMixin("Object"));
        //app = new CPolyApplicationValues();
        //app.add( new  CPolyApplicationValue(param, value) );
    
    }

    protected CType(CEnvironment env, ITypeElement aTypeElement){ 
        super();
      
        //app = new CPolyApplicationValues();
        //add (env.getMixin("Object"));
        //add (aTypeElement);
    }

    //------------ metody ---------------
    public void addNewAtStart ( CType other){ 
        for (int i=other.size()-1; i>=0; i--){ 
            if (contains(other.get(i)))
                remove( other.get(i) );
            add(0,other.get(i));
        }
	  
        app.addAll(other.app);
	}
    
    public CType sumWith (CType other){  
        CType res = deepCopy();
        res.addNew(other);
           
        return res;
    }

	public void addNew( CType other){ 
        for (int i=0; i<other.size(); i++)
		    if (!contains(other.get(i)))
		        add(other.get(i));
	  
        app.addAll(other.app);
	}


	public String toString(){ 
        String res = "(";
	    
        for (int i=0; i<size(); i++)
	        res += (i>0?", ":"")+ get(i).getCaption();
	    
        return res+")";
	}
	
	public void CheckIsSubTypeOf(CEnvironment env, CType other) throws CTypeError { 
        if (!isSubTypeOf(env, other) )
  	        throw new CTypeError( this+" is not subtype of "+other);
	}

    public boolean isIsomorphicTo(CEnvironment env, CType other ){ 
        
        return isSubTypeOf(env, other) && other.isSubTypeOf(env, this);
	
    }

    public boolean ModuleContainsInputParameter (CEnvironment env,  CSourceInitializationParameter par){ 
        for (int i=0; i<size(); i++){ 
            if (get(i) instanceof CPolymorphismParam){  
                if ( ((CPolymorphismParam) get(i)).GetBoundingType(env).ModuleContainsInputParameter(env, par) )
	                return true;
            } 
            else if (get(i) instanceof CMixinDeclaration){  
                if ( ((CMixinDeclaration) get(i)).ModuleContainsInputParameter(par) ) 
                    return true;
            } 
            else
                throw new Error("Unknown class of ITypeElement");
	    
	    }
	  
        return false;
	}
        
	private boolean containsTypeElem(CEnvironment env,  ITypeElement el){ 
        for (int i=0; i<size(); i++){ 
            if (get(i) == el)
	            return true;
	        if (get(i) instanceof CPolymorphismParam)
	            if ( ((CPolymorphismParam) get(i)).GetBoundingType(env).containsTypeElem(env, el) )
	                return true;
	    }
	  
        return false;
	}

    CType lastChecked = null;
	public boolean isSubTypeOf(CEnvironment env, CType other){ 
        if (lastChecked == other) //tu jest sprawdzenie zeby sie nie zapetlic przy zacyklonych typach (ale prostych)
	        return true;
	  
        try{
            lastChecked = other;
	        //
            if (isAll)
	            return true;
  	  
            for (int i=0; i<other.size();  i++)
	            if (!containsTypeElem(env, other.get(i)))
	                return false;
	        //
 	        return true;
        } 
        finally {
            lastChecked = null;
        }
	}

	public CNewMethodDeclarations calcAbstractMethods(CMethodEnvironment env){ 
        CNewMethodDeclarations res = new  CNewMethodDeclarations();
	    
        for (int i=0;  i<size(); i++)
	        res = ((CMixinDeclaration)get(i) ).calcAbstractMethods(env, res);
	  
        return res;
	}
        
        //returns the number of activated modules
	public int GenCodeForActivatedModules(java.io.PrintStream o, CInstrEnvironment env, CGenCodeHelper h, CInitializationOfParams Init) { 
        int result =0;
	    CInitializationOfParams localInit = (CInitializationOfParams) Init.clone();
	  
        for (int i=size()-1; i>=0; i--){ 
            CMixinDeclaration mix = (CMixinDeclaration)get(i);
	    
            for (int mod=mix.IniModules.size()-1; mod>=0; mod--){ 
                CIniModuleDeclaration moddecl=mix.IniModules.get(mod);
                if (moddecl.activatedBy(localInit) ){ 
                    if (o != null)
                        o.println(CGenCodeHelper.tab+"modules.add("+mix.CodeForMixin()+".IniModules["+mod+"]);");
	            moddecl.modifyParametersList(localInit);
		        result++;
  	            } 
                else
	                if (moddecl.isRequired)
	                    throw new Error("Required ini module in ["+ toString() +"] was not activated");
   	        }
	    }
	  
        if (localInit.size() != 0)
	        throw new Error("There is no ini module in ["+ toString() +"] to consume parameter: " + localInit.get(0).MixinName +"."+localInit.get(0).ParamName);
	    return result;
	}
        
    private boolean MixinExistsInPrefix(int PrefixEnd, CMixinDeclaration target){ 
        for(int i=0; i<=PrefixEnd; i++)
            if (get(i) == target)
                return true;
        
        return false;
    }
        
    public void CheckIfBaseMixinsExist( CMethodEnvironment env){ 
        for (int i=0; i<size(); i++){ 
            if (get(i) instanceof CMixinDeclaration) { 
                CMixinDeclaration decl =  (CMixinDeclaration) get(i);
                CType baseType = decl.BaseMixinExpression.GetType(env);
                
                for (int j=0; j<baseType.size(); j++){ 
                    CMixinDeclaration baseMixin = (CMixinDeclaration) baseType.get(j);
                    if (!MixinExistsInPrefix(i-1, baseMixin))
                        throw new CTypeError("Error in Expression used to create new object from: "+this+" : "+decl.MixinName+" requires "+baseMixin.MixinName+ " which is not present");
                }
            
            }
            else
                throw new Error("instantiation from the polymorphic params not yet supported!");
                //TODO: czy tu jako powinnismy polimorficzne parametry obsluzyc???? moze ich boundy posprawdzac
        }
        
    }

	public CType setPolyParamsFrom (CPolyApplicationValues vals){ 
        CType res = createCType(false);
	  
        for (int i=0; i<size(); i++)
	        if (get(i) instanceof CPolymorphismParam){ 
                int j = vals.indexOfParam( (CPolymorphismParam) get(i) );
                if (j>=0){  
                    res.addNew( vals.get(j).value );
	            }
                else
	                res.add(get(i));
            } 
            else
	            res.add( get(i) );
	    //
	    return res;
	}
};

*)
