package Magda.mtj;

import java.util.function.BiConsumer;

public class CMagdaMixin{
	String name;
    int layerSize;    

    public CMagdaMixin (String name, int layerSize){ 
        this.name = name; 
        this.layerSize = layerSize;
    }

    private BiConsumer<CMagdaMixinSequence,IMagdaObjectElement[]> func;
        
    public void setMethods(CMagdaMixinSequence AllSequence, IMagdaObjectElement[] aObjectBody){
        this.func.accept(AllSequence,aObjectBody);
    }

    public void setSetMethodsFunction(BiConsumer<CMagdaMixinSequence,IMagdaObjectElement[]> func){
        this.func = func;
    }

    public int getObjectLayerSize(){
        return layerSize;
    }
	
    public CMagdaIniModule[] IniModules;
};
