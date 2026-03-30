package Magda.PreParser.PreParserStructures;

import java.util.HashMap;
import java.util.ArrayList;

public class MixinContext{

    private int counter = 0;    

    private HashMap<String,MethodContext> methodsContext = new HashMap<String,MethodContext>();
    private HashMap<String,String> fields = new HashMap<String,String>();
 
    private HashMap<ArrayList<String>,String> iniModulesNameSpace = new HashMap<ArrayList<String>,String>();

    private ArrayList<String> linkedMixins = new ArrayList<String>();

    public void addMethod(String name, MethodContext methodContext){
        methodsContext.put(name,methodContext);
    } 

    public String getIniModuleName(ArrayList<String> params){
        return iniModulesNameSpace.get(params);
    }

    public String addIniModule(ArrayList<String> params, MethodContext methodContext){
        for(ArrayList<String> allParams : iniModulesNameSpace.keySet()){
            for(String s : params){
                if(allParams.contains(s))
                    return s;
            }
        }

        String iniModuleName = "initialize " + (counter++);
        
        iniModulesNameSpace.put(params,iniModuleName);
        methodsContext.put(iniModuleName,methodContext);

        return null;
    }

    public boolean containsMethod(String methodName){
        if(methodsContext.containsKey(methodName))
            return true;
        else
            return false;
    }
    
    public boolean containsField(String fieldName){
        if(fields.containsKey(fieldName))
            return true;
        else
            return false;
    }

    public boolean emptyMainProgramParams(){
        if(methodsContext.containsKey("mainProgram"))
            return methodsContext.get("mainProgram").noParams();
        return false;
    }

    public void addField(String name, String type){
        fields.put(name,type);
    }
   
    public void addLinkedMixin(String name){
        linkedMixins.add(name);
    }

    public String getFieldType(String fieldName){
        if(fields.containsKey(fieldName))
            return fields.get(fieldName);
        return null;
    } 

    public String getMethodReturnType(String methodName){
        if(methodsContext.containsKey(methodName))
            return methodsContext.get(methodName).getReturnType();
        return null;
    }

    public String getMethodVariableType(String methodName, String variableName){
        return methodsContext.get(methodName).getVariableType(variableName);
    }

    public ArrayList<String> getLinkedMixins(){
        return new ArrayList<String>(linkedMixins);
    } 
   
    public String toString(){

        ArrayList<String> mckeys = new ArrayList<String>(methodsContext.keySet());
        ArrayList<String> fkeys = new ArrayList<String>(fields.keySet());

        String s = "";
        s+="  "+linkedMixins.toString()+"\n";

        s+="\tfields:\n";
        for(int i=0;i<fkeys.size();i++){
            s+="\t\t" + fkeys.get(i) + " : " + fields.get(fkeys.get(i)) + "\n";
        }
        
        s+="\tmethods:\n";
        for(int i=0;i<mckeys.size();i++){
            MethodContext tmp = methodsContext.get(mckeys.get(i));
            s+="\t\t" + mckeys.get(i) + " : " + tmp.getReturnType()+"\n";
            s+=tmp.toString();
        }

        return s;
    }
}

