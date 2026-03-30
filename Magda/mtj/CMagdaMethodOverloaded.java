package Magda.mtj;
/* Magda to Java Converter Library
*/

import java.util.function.BiFunction;

public class CMagdaMethodOverloaded implements CMagdaMethod{    
    public CMagdaMethod SuperBody;

    private TriFunction<CMagdaObject,CMagdaObject[],CMagdaMethod,CMagdaObject> func;
 
    public CMagdaMethodOverloaded (CMagdaMethod aSuperBody){ 
        super();
 	    SuperBody = aSuperBody;
    }

    @Override
	public CMagdaObject Execute(CMagdaObject aSelf, CMagdaObject[] params){
        return this.func.apply(aSelf,params,SuperBody);
    }

    public void setExecuteFunction(TriFunction<CMagdaObject,CMagdaObject[],CMagdaMethod,CMagdaObject> func){
        this.func = func;
    }
};

