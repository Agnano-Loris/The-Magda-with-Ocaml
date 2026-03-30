package Magda.mtj;

import java.util.function.BiFunction;

public interface CMagdaMethod extends IMagdaObjectElement{

	public abstract CMagdaObject Execute(CMagdaObject aSelf, CMagdaObject[] params);
    
    //public abstract void setExecuteFunction(BiFunction<CMagdaObject,CMagdaObject[],CMagdaObject> func);

};
