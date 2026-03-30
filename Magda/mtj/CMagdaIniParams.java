package Magda.mtj;

import java.util.*;

public class CMagdaIniParams extends HashMap<String, CMagdaObject>{ 
  
    private static final long serialVersionUID = 1L;
    
    private String PairToString(String MixinName, String ParamName){ 
        return MixinName+" | "+ParamName;
    }
  
    public CMagdaObject removeParamValue (String MixinName, String ParamName){ 
        if (!containsKey(PairToString(MixinName,ParamName)))
            throw new Error("[Internal Error] No param value stored for "+MixinName+"."+ParamName+" to remove!");
    
        return remove(PairToString(MixinName,ParamName));
    }

    public CMagdaObject getParamValue (String MixinName, String ParamName, CMagdaObject value){  
        if (!containsKey(PairToString(MixinName,ParamName)))
            throw new Error("[Internal Error] No param value stored for "+MixinName+"."+ParamName+" to get!");
     
        return get(PairToString(MixinName,ParamName));
    }
  
    public void putParamValue (String MixinName, String ParamName, CMagdaObject value){ 
        put(PairToString(MixinName,ParamName), value);
    }
}
